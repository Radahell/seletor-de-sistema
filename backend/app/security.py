from __future__ import annotations

import hashlib

from werkzeug.security import (
    check_password_hash,
    generate_password_hash,
)


def hash_password(password: str) -> str:
    """Hash de senha com salt usando werkzeug (pbkdf2:sha256 por padrão).

    Substitui o antigo SHA-256 puro (sem salt), que era vulnerável a
    rainbow tables. O formato gerado pelo werkzeug ("method$salt$hash")
    é auto-descritivo e suportado por ``check_password_hash``.
    """
    return generate_password_hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    """Verifica senha, com compatibilidade retroativa para SHA-256 legado.

    - Novos hashes (gerados por ``hash_password``) seguem o formato
      werkzeug e são verificados via ``check_password_hash``.
    - Hashes legados (SHA-256 hex de 64 caracteres, sem prefixo) ainda
      são aceitos para permitir login durante a migração — recomenda-se
      regravar o hash via ``hash_password`` após login bem-sucedido.
    """
    if not password_hash:
        return False

    # Hash novo (werkzeug): contém '$' separando method/salt/hash
    if "$" in password_hash or password_hash.startswith("pbkdf2:") or password_hash.startswith("scrypt:"):
        try:
            return check_password_hash(password_hash, password)
        except Exception:
            return False

    # Fallback legado: SHA-256 sem salt (64 hex chars)
    legacy = hashlib.sha256(password.encode("utf-8")).hexdigest()
    return legacy == password_hash
