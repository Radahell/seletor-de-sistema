from __future__ import annotations

import logging
import os
import re
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import OperationalError, SQLAlchemyError

logger = logging.getLogger(__name__)

# ============================================================
# Paths
# ============================================================
APP_DIR = Path(__file__).resolve().parent
TEMPLATES_DIR = APP_DIR / "templates_sql"

# ============================================================
# ENV / CONFIG
# ============================================================
# Banco MASTER do Seletor (systems/tenants/super_admins)
MASTER_DATABASE_URL = os.getenv("DATABASE_URL") or os.getenv("MASTER_DB_URL")
if not MASTER_DATABASE_URL:
    raise RuntimeError("DATABASE_URL or MASTER_DB_URL is required for Seletor (master DB).")

ENV = os.getenv("ENV", "dev")

# Target (MySQL do Varzea onde os DBs dos tenants serão criados)
TENANT_DB_HOST = os.getenv("TENANT_DB_HOST", "varzea-prime-db-1")
TENANT_DB_PORT = int(os.getenv("TENANT_DB_PORT", "3306"))
TENANT_DB_USER = os.getenv("TENANT_DB_USER", "root")
TENANT_DB_PASS = os.getenv("TENANT_DB_PASS", "")

if ENV != "dev" and not TENANT_DB_PASS:
    raise RuntimeError("TENANT_DB_PASS is required in non-dev environments.")

# ============================================================
# Engines (cache simples)
# ============================================================
_master_engine: Optional[Engine] = None
_target_admin_engines: Dict[str, Engine] = {}


def get_master_engine() -> Engine:
    """
    Engine do banco MASTER do Seletor (onde ficam systems/tenants/super_admins).
    """
    global _master_engine
    if _master_engine is None:
        _master_engine = create_engine(
            MASTER_DATABASE_URL,
            pool_pre_ping=True,
            future=True,
        )
    return _master_engine


def get_target_admin_engine(host: Optional[str] = None) -> Engine:
    """
    Engine para conectar no MySQL do Varzea SEM schema (apenas para CREATE/DROP DATABASE).
    Cache por host.
    """
    h = (host or "").strip() or TENANT_DB_HOST
    if h in _target_admin_engines:
        return _target_admin_engines[h]

    # Conexão "sem database" para comandos de administração
    admin_url = f"mysql+pymysql://{TENANT_DB_USER}:{TENANT_DB_PASS}@{h}:{TENANT_DB_PORT}"
    eng = create_engine(
        admin_url,
        isolation_level="AUTOCOMMIT",
        pool_pre_ping=True,
        future=True,
    )
    _target_admin_engines[h] = eng
    return eng


# ============================================================
# SQL helpers (MASTER DB)
# ============================================================
def execute_sql(sql: str, params: Optional[Dict[str, Any]] = None) -> None:
    eng = get_master_engine()
    with eng.begin() as conn:
        conn.execute(text(sql), params or {})


def fetch_one(sql: str, params: Optional[Dict[str, Any]] = None) -> Optional[Dict[str, Any]]:
    eng = get_master_engine()
    with eng.connect() as conn:
        res = conn.execute(text(sql), params or {})
        row = res.mappings().first()
        return dict(row) if row else None


def fetch_all(sql: str, params: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
    eng = get_master_engine()
    with eng.connect() as conn:
        res = conn.execute(text(sql), params or {})
        rows = res.mappings().all()
        return [dict(r) for r in rows]


def safe_db_error(err: Exception) -> str:
    """
    Evita vazar stacktrace em produção.
    """
    if ENV == "dev":
        return f"{type(err).__name__}: {err}"
    return "Erro interno no banco de dados."


# ============================================================
# Startup init (MASTER DB)
# ============================================================
def init_db(retries: int = 5, sleep_seconds: int = 2) -> None:
    """
    Apenas garante que o MASTER DB está acessível no boot.
    (Não cria schema automaticamente aqui para não interferir com seu processo.)
    """
    last_err: Optional[Exception] = None
    for attempt in range(1, retries + 1):
        try:
            eng = get_master_engine()
            with eng.connect() as conn:
                conn.execute(text("SELECT 1"))
            return
        except OperationalError as e:
            last_err = e
            logger.warning("MASTER DB não pronto (tentativa %s/%s): %s", attempt, retries, e)
            time.sleep(sleep_seconds)
    raise RuntimeError(f"MASTER DB not reachable after retries: {last_err}")


# ============================================================
# Validation helpers (slug/db_name)
# ============================================================
def validate_slug(slug: str) -> str:
    s = (slug or "").strip().lower()
    if not s:
        raise ValueError("slug é obrigatório")
    if not re.match(r"^[a-z0-9-]+$", s):
        raise ValueError("Slug inválido. Use apenas letras minúsculas, números e hífens.")
    return s


def build_db_name_from_slug(slug: str) -> str:
    """
    Converte slug em nome físico de DB no MySQL:
      copa-brahma -> copa_brahma_db
    Regex estrita pois será usado em CREATE/DROP DATABASE.
    """
    db_name = f"{slug.replace('-', '_')}_db"
    if not re.match(r"^[a-z0-9_]+$", db_name):
        raise ValueError("database_name inválido")
    return db_name


# ============================================================
# SQL template apply (bem melhor que split(';'))
# ============================================================

def _split_sql_statements(sql_text: str) -> list[str]:
    """
    Split de script SQL por ';' ignorando comentários de linha iniciados com '--'
    e protegendo contra ';' dentro de aspas simples/dobras.
    """
    # remove comentários "-- ..."
    lines = []
    for line in sql_text.splitlines():
        if line.lstrip().startswith("--"):
            continue
        lines.append(line)
    text_clean = "\n".join(lines).strip()
    if not text_clean:
        return []

    stmts: list[str] = []
    buf: list[str] = []
    in_str = False
    quote = None
    prev = ""

    for ch in text_clean:
        if ch in ("'", '"'):
            if not in_str:
                in_str = True
                quote = ch
            elif quote == ch and prev != "\\":  # fecha string (escape simples)
                in_str = False
                quote = None

        if ch == ";" and not in_str:
            stmt = "".join(buf).strip()
            buf = []
            if stmt:
                stmts.append(stmt)
        else:
            buf.append(ch)

        prev = ch

    tail = "".join(buf).strip()
    if tail:
        stmts.append(tail)

    return stmts


def apply_sql_template(conn, template_path: str) -> None:
    sql_text = Path(template_path).read_text(encoding="utf-8")
    statements = _split_sql_statements(sql_text)

    db = conn.exec_driver_sql("SELECT DATABASE()").scalar()
    if not db:
        raise RuntimeError("Nenhum database selecionado (DATABASE() retornou NULL).")

    def norm(s: str) -> str:
        return re.sub(r"\s+", " ", s.strip()).lower()

    create_tables: list[str] = []
    alters_add_fk: list[str] = []
    others: list[str] = []

    for stmt in statements:
        s = norm(stmt)

        # separa ALTER TABLE que adiciona constraint/foreign key
        if s.startswith("alter table") and (" foreign key " in s or " add constraint " in s):
            alters_add_fk.append(stmt)
            continue

        # separa CREATE TABLE
        if s.startswith("create table"):
            create_tables.append(stmt)
            continue

        others.append(stmt)

    # 1) CREATE TABLE primeiro
    for i, stmt in enumerate(create_tables, start=1):
        try:
            conn.exec_driver_sql(stmt)
        except Exception as e:
            snippet = (stmt[:600] + "...") if len(stmt) > 600 else stmt
            raise RuntimeError(f"Falha CREATE TABLE (db={db}) stmt#{i}:\n{snippet}") from e

    # 2) restante (INSERTs, CREATE INDEX, etc)
    for i, stmt in enumerate(others, start=1):
        try:
            conn.exec_driver_sql(stmt)
        except Exception as e:
            snippet = (stmt[:600] + "...") if len(stmt) > 600 else stmt
            raise RuntimeError(f"Falha template (db={db}) stmt#{i}:\n{snippet}") from e

    # 3) por último, FKs
    for i, stmt in enumerate(alters_add_fk, start=1):
        try:
            conn.exec_driver_sql(stmt)
        except Exception as e:
            snippet = (stmt[:600] + "...") if len(stmt) > 600 else stmt
            raise RuntimeError(f"Falha FK/CONSTRAINT (db={db}) stmt#{i}:\n{snippet}") from e

    users_exists = conn.exec_driver_sql("SHOW TABLES LIKE 'users'").fetchone()
    if not users_exists:
        raise RuntimeError(f"Template aplicado mas 'users' não existe no db={db}.")

# ============================================================
# Tenant DB operations (no MySQL do Varzea)
# ============================================================
def create_physical_database(target_host: Optional[str], db_name: str) -> None:
    """
    Cria o database físico no MySQL do Varzea.
    """
    host = (target_host or "").strip() or TENANT_DB_HOST
    eng = get_target_admin_engine(host)
    with eng.connect() as conn:
        conn.execute(
            text(
                f"CREATE DATABASE IF NOT EXISTS `{db_name}` "
                f"CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
            )
        )


def drop_physical_database(target_host: Optional[str], db_name: str) -> None:
    """
    Remove o database físico no MySQL do Varzea.
    """
    host = (target_host or "").strip() or TENANT_DB_HOST
    eng = get_target_admin_engine(host)
    with eng.connect() as conn:
        conn.execute(text(f"DROP DATABASE IF EXISTS `{db_name}`"))


def build_tenant_database_url(target_host: Optional[str], db_name: str) -> str:
    """
    URL completa para conectar no DB do tenant no MySQL do Varzea.
    """
    host = (target_host or "").strip() or TENANT_DB_HOST
    return f"mysql+pymysql://{TENANT_DB_USER}:{TENANT_DB_PASS}@{host}:{TENANT_DB_PORT}/{db_name}"
