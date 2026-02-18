"""
Rotas de administração de usuários (super admin only).

Lista usuários diretamente dos bancos de dados dos tenants.

Endpoints:
- GET    /api/admin/users           - Lista paginada de usuários (de TODOS os tenants)
- PATCH  /api/admin/users/<id>      - Editar usuário no hub
- POST   /api/admin/users/<id>/activate   - Ativar no hub
- POST   /api/admin/users/<id>/deactivate - Desativar no hub
- DELETE /api/admin/users/<id>      - Soft delete no hub
"""
from __future__ import annotations

import traceback
from functools import wraps

from flask import Blueprint, g, jsonify, request
from sqlalchemy import create_engine, text

from app.db import (
    execute_sql, fetch_all, fetch_one, safe_db_error, ENV,
    build_tenant_database_url, TENANT_DB_HOST,
)
from app.routes.auth_routes import login_required

admin_user_bp = Blueprint("admin_users", __name__, url_prefix="/api/admin")


def _super_admin_required(f):
    """Decorator: exige login + super admin."""
    @wraps(f)
    @login_required
    def decorated(*args, **kwargs):
        sa = fetch_one(
            "SELECT 1 FROM super_admins WHERE email = :email AND is_active = TRUE",
            {"email": g.current_user["email"]},
        )
        if not sa:
            return jsonify({"error": "Acesso restrito a super administradores"}), 403
        return f(*args, **kwargs)
    return decorated


def _user_to_item(row):
    """Converte row do DB para item compatível com o frontend admin."""
    return {
        "id": row["id"],
        "name": row["name"],
        "nickname": row.get("nickname"),
        "email": row["email"],
        "phone": row.get("phone"),
        "cpf": row.get("cpf"),
        "cnpj": row.get("cnpj"),
        "city": row.get("city"),
        "state": row.get("state"),
        "timezone": row.get("timezone"),
        "avatar_url": row.get("avatar_url"),
        "is_active": bool(row.get("is_active", True)),
        "is_blocked": bool(row.get("is_blocked", False)),
        "last_login_at": row["last_login_at"].isoformat() if row.get("last_login_at") else None,
        "created_at": row["created_at"].isoformat() if row.get("created_at") else None,
        "tenants": [],
    }


def _query_tenant_users(db_host, db_name, tenant_info):
    """Conecta num banco de tenant e retorna todos os usuários."""
    users = []
    try:
        url = build_tenant_database_url(db_host, db_name)
        engine = create_engine(url, pool_pre_ping=True, future=True)
        with engine.connect() as conn:
            # Descobre colunas disponíveis na tabela users
            cols_rows = conn.execute(
                text("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = :db AND TABLE_NAME = 'users'"),
                {"db": db_name},
            ).fetchall()
            available_cols = {r[0] for r in cols_rows}

            if "id" not in available_cols or "email" not in available_cols:
                return users

            # Monta SELECT com colunas que existem
            select_cols = ["id", "email"]
            for col in ["name", "nickname", "phone", "cpf", "city", "state",
                         "photo", "is_admin", "is_approved", "is_blocked",
                         "is_monthly", "fk_id_user_hub", "role", "created_at",
                         "skill_rating", "preferred_position", "timezone"]:
                if col in available_cols:
                    select_cols.append(col)

            rows = conn.execute(text(f"SELECT {', '.join(select_cols)} FROM users")).mappings().all()

            for row in rows:
                u = dict(row)
                u["_tenant_id"] = tenant_info["id"]
                u["_tenant_slug"] = tenant_info["slug"]
                u["_tenant_name"] = tenant_info["display_name"]
                u["_system_slug"] = tenant_info["system_slug"]
                u["_system_name"] = tenant_info["system_name"]
                u["_db_name"] = db_name
                users.append(u)

        engine.dispose()
    except Exception as e:
        print(f"[admin] Erro ao consultar tenant {db_name}: {e}", flush=True)
        if ENV == "dev":
            traceback.print_exc()
    return users


@admin_user_bp.get("/users")
@_super_admin_required
def list_users():
    """Lista paginada de usuários de TODOS os bancos de tenant."""
    try:
        page = max(1, int(request.args.get("page", 1)))
        per_page = min(100, max(1, int(request.args.get("per_page", 20))))

        q = request.args.get("q", "").strip().lower()
        status_filter = request.args.get("status", "").strip()
        tenant_filter = request.args.get("tenant", "").strip()
        sort_by_param = request.args.get("sort_by", "name")
        sort_dir_param = request.args.get("sort_dir", "asc")

        # 1) Buscar todos os tenants ativos
        tenant_sql = """
            SELECT t.id, t.slug, t.display_name, t.database_name, t.database_host,
                   s.slug AS system_slug, s.display_name AS system_name
            FROM tenants t
            INNER JOIN systems s ON t.system_id = s.id
            WHERE t.is_active = TRUE
            ORDER BY t.display_name
        """
        tenants = fetch_all(tenant_sql)

        if tenant_filter:
            tenants = [t for t in tenants if t["slug"] == tenant_filter]

        # 2) Para cada tenant, buscar usuários do banco
        all_raw_users = []
        for tenant in tenants:
            db_name = tenant["database_name"]
            db_host = tenant.get("database_host") or TENANT_DB_HOST
            users = _query_tenant_users(db_host, db_name, tenant)
            all_raw_users.extend(users)

        # 3) Agrupar por email (mesmo usuário em vários tenants)
        email_map: dict = {}
        for u in all_raw_users:
            email = (u.get("email") or "").lower()
            if not email:
                continue

            if email not in email_map:
                email_map[email] = {
                    "id": u.get("fk_id_user_hub") or u["id"],
                    "name": u.get("name") or "",
                    "nickname": u.get("nickname"),
                    "email": u["email"],
                    "phone": u.get("phone"),
                    "cpf": u.get("cpf"),
                    "city": u.get("city"),
                    "state": u.get("state"),
                    "timezone": u.get("timezone"),
                    "photo": u.get("photo"),
                    "is_active": True,
                    "is_blocked": bool(u.get("is_blocked", False)),
                    "is_admin": bool(u.get("is_admin", False)),
                    "skill_rating": u.get("skill_rating"),
                    "preferred_position": u.get("preferred_position"),
                    "created_at": str(u["created_at"]) if u.get("created_at") else None,
                    "tenants": [],
                }

            email_map[email]["tenants"].append({
                "id": u["_tenant_id"],
                "slug": u["_tenant_slug"],
                "name": u["_tenant_name"],
                "system": u["_system_name"],
                "role": u.get("role") or ("admin" if u.get("is_admin") else "jogador"),
            })

        # 4) Converter para lista
        items = list(email_map.values())

        # 5) Aplicar filtros
        if q:
            items = [
                i for i in items
                if q in (i["name"] or "").lower()
                or q in (i["email"] or "").lower()
                or q in (i["phone"] or "").lower()
                or q in (i["cpf"] or "").lower()
            ]

        if status_filter == "active":
            items = [i for i in items if i["is_active"] and not i["is_blocked"]]
        elif status_filter == "inactive":
            items = [i for i in items if not i["is_active"] or i["is_blocked"]]

        if request.args.get("missing_contact") == "true":
            items = [i for i in items if not i.get("phone")]

        # 6) Ordenar
        reverse = sort_dir_param == "desc"
        if sort_by_param == "email":
            items.sort(key=lambda x: (x.get("email") or "").lower(), reverse=reverse)
        elif sort_by_param == "created_at":
            items.sort(key=lambda x: x.get("created_at") or "", reverse=reverse)
        else:
            items.sort(key=lambda x: (x.get("name") or "").lower(), reverse=reverse)

        # 7) Paginar
        total = len(items)
        offset = (page - 1) * per_page
        paged_items = items[offset:offset + per_page]
        pages = max(1, (total + per_page - 1) // per_page) if total > 0 else 0

        return jsonify({
            "items": paged_items,
            "pagination": {
                "page": page,
                "per_page": per_page,
                "total": total,
                "pages": pages,
            },
        })

    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.patch("/users/<int:user_id>")
@_super_admin_required
def update_user(user_id: int):
    """Atualiza dados de um usuário no hub."""
    try:
        user = fetch_one("SELECT id FROM users WHERE id = :id", {"id": user_id})
        if not user:
            return jsonify({"error": "Usuário não encontrado"}), 404

        payload = request.get_json(force=True)
        allowed = {"name", "phone", "email", "nickname", "cpf", "cnpj",
                    "city", "state", "timezone"}
        sets = []
        params: dict = {"id": user_id}
        for field in allowed:
            if field in payload:
                sets.append(f"{field} = :{field}")
                params[field] = payload[field]

        if not sets:
            return jsonify({"error": "Nenhum campo para atualizar"}), 400

        execute_sql(
            f"UPDATE users SET {', '.join(sets)} WHERE id = :id",
            params,
        )
        updated = fetch_one("SELECT * FROM users WHERE id = :id", {"id": user_id})
        return jsonify(_user_to_item(updated))

    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.post("/users/<int:user_id>/activate")
@_super_admin_required
def activate_user(user_id: int):
    """Ativar usuário."""
    try:
        execute_sql(
            "UPDATE users SET is_active = TRUE, is_blocked = FALSE WHERE id = :id",
            {"id": user_id},
        )
        return jsonify({"message": "Usuário ativado", "id": user_id})
    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.post("/users/<int:user_id>/deactivate")
@_super_admin_required
def deactivate_user(user_id: int):
    """Desativar usuário."""
    try:
        execute_sql(
            "UPDATE users SET is_active = FALSE WHERE id = :id",
            {"id": user_id},
        )
        return jsonify({"message": "Usuário desativado", "id": user_id})
    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.delete("/users/<int:user_id>")
@_super_admin_required
def delete_user(user_id: int):
    """Soft delete: desativa e bloqueia."""
    try:
        execute_sql(
            "UPDATE users SET is_active = FALSE, is_blocked = TRUE, blocked_reason = 'deleted_by_admin' WHERE id = :id",
            {"id": user_id},
        )
        return jsonify({"message": "Usuário removido", "id": user_id})
    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500
