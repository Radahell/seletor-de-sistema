"""
Rotas inter-service para consulta de perfil de usuário.

Permite que tenants (varzea-prime, lance-de-ouro) busquem dados
do perfil centralizado no hub via SERVICE_API_KEY.

Endpoints:
- GET /api/users/<id>/profile - Perfil completo do usuário (inter-service)
"""
from __future__ import annotations

import os
import traceback
from functools import wraps
from typing import Any, Dict

from flask import Blueprint, jsonify, request

from app.db import fetch_all, fetch_one, safe_db_error

user_bp = Blueprint("users", __name__, url_prefix="/api/users")

ENV = os.getenv("ENV", "dev")
SERVICE_API_KEY = os.getenv("SERVICE_API_KEY", "")


def _service_auth_required(f):
    """Decorator que exige X-Service-Key válida."""
    @wraps(f)
    def decorated(*args, **kwargs):
        key = request.headers.get("X-Service-Key", "")
        if not SERVICE_API_KEY or key != SERVICE_API_KEY:
            return jsonify({"error": "Acesso negado"}), 403
        return f(*args, **kwargs)
    return decorated


def _user_profile_dto(row: Dict[str, Any]) -> Dict[str, Any]:
    """Converte row do banco para DTO de perfil inter-service."""
    return {
        "id": row["id"],
        "name": row["name"],
        "nickname": row.get("nickname"),
        "email": row["email"],
        "phone": row.get("phone"),
        "cpf": row.get("cpf"),
        "cnpj": row.get("cnpj"),
        "avatarUrl": row.get("avatar_url"),
        "bio": row.get("bio"),
        "cep": row.get("cep"),
        "logradouro": row.get("logradouro"),
        "numero": row.get("numero"),
        "bairro": row.get("bairro"),
        "complemento": row.get("complemento"),
        "city": row.get("city"),
        "state": row.get("state"),
        "timezone": row.get("timezone"),
        "isActive": bool(row.get("is_active", True)),
        "createdAt": row.get("created_at").isoformat() if row.get("created_at") else None,
    }


@user_bp.get("/<int:user_id>/profile")
@_service_auth_required
def get_user_profile(user_id: int):
    """Retorna perfil completo de um usuário (para uso inter-service)."""
    try:
        user = fetch_one(
            "SELECT * FROM users WHERE id = :id",
            {"id": user_id},
        )
        if not user:
            return jsonify({"error": "Usuário não encontrado"}), 404

        # Buscar interesses
        interests = fetch_all(
            """
            SELECT s.id, s.slug, s.display_name
            FROM user_interests ui
            INNER JOIN systems s ON s.id = ui.system_id
            WHERE ui.user_id = :user_id
            ORDER BY s.display_order, s.id
            """,
            {"user_id": user_id},
        )

        dto = _user_profile_dto(user)
        dto["interests"] = [
            {"id": i["id"], "slug": i["slug"], "displayName": i["display_name"]}
            for i in interests
        ]

        return jsonify(dto)

    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@user_bp.get("/by-tenant/<slug>")
@_service_auth_required
def get_users_by_tenant(slug: str):
    """Retorna usuarios vinculados a um tenant (inter-service).

    Usado pelo SGQ e outros sistemas para listar membros/clientes.
    """
    try:
        tenant = fetch_one(
            "SELECT id FROM tenants WHERE slug = :slug AND is_active = TRUE",
            {"slug": slug},
        )
        if not tenant:
            return jsonify({"error": "Tenant não encontrado"}), 404

        rows = fetch_all(
            """
            SELECT u.*, ut.role, ut.joined_at
            FROM user_tenants ut
            INNER JOIN users u ON ut.user_id = u.id
            WHERE ut.tenant_id = :tid AND ut.is_active = TRUE
            ORDER BY u.name
            """,
            {"tid": tenant["id"]},
        )

        users = []
        for r in rows:
            dto = _user_profile_dto(r)
            dto["role"] = r.get("role", "player")
            dto["joinedAt"] = r["joined_at"].isoformat() if r.get("joined_at") else None
            users.append(dto)

        return jsonify({"users": users, "total": len(users)})

    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500
