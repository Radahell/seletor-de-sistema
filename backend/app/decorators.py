"""
Decorators compartilhados entre main.py e blueprints.

`super_admin_required`:
    Exige token JWT valido (via `login_required` em auth_routes.py)
    + que o email do usuario esteja em `super_admins` com is_active=TRUE.

    Usar em todas as rotas /api/super-admin/* (exceto a propria rota de login).
"""
from __future__ import annotations

from functools import wraps

from flask import g, jsonify

from app.db import fetch_one
from app.routes.auth_routes import login_required


def super_admin_required(f):
    """Decorator: exige login (sessao valida) + super admin."""
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
