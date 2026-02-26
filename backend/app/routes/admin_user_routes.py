"""
Rotas de administração de usuários (super admin only).

Lista usuários diretamente do banco central (hub).

Endpoints:
- GET    /api/admin/users                       - Lista paginada de usuários do hub
- PATCH  /api/admin/users/<id>                  - Editar usuário no hub
- POST   /api/admin/users/<id>/activate         - Ativar no hub
- POST   /api/admin/users/<id>/deactivate       - Desativar no hub
- DELETE /api/admin/users/<id>                  - Soft delete no hub
- GET    /api/admin/users/<id>/tenants          - Listar tenants do user
- POST   /api/admin/users/<id>/tenants/<tid>    - Adicionar user a tenant
- DELETE /api/admin/users/<id>/tenants/<tid>    - Remover user de tenant
- GET    /api/admin/tenants                     - Listar todos os tenants (para dropdown)
"""
from __future__ import annotations

import traceback
from functools import wraps

from flask import Blueprint, g, jsonify, request

from app.db import execute_sql, fetch_all, fetch_one, safe_db_error, ENV
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
    """Converte row do hub para item compatível com o frontend admin."""
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


@admin_user_bp.get("/users")
@_super_admin_required
def list_users():
    """Lista paginada de usuários do hub central."""
    try:
        page = max(1, int(request.args.get("page", 1)))
        per_page = min(100, max(1, int(request.args.get("per_page", 20))))

        q = request.args.get("q", "").strip().lower()
        status_filter = request.args.get("status", "").strip()
        tenant_filter = request.args.get("tenant", "").strip()
        sort_by_param = request.args.get("sort_by", "name")
        sort_dir_param = request.args.get("sort_dir", "asc")

        # Build WHERE clause
        where_parts = ["1=1"]
        params: dict = {}

        if q:
            where_parts.append(
                "(LOWER(u.name) LIKE :q OR LOWER(u.email) LIKE :q "
                "OR LOWER(COALESCE(u.phone,'')) LIKE :q "
                "OR LOWER(COALESCE(u.cpf,'')) LIKE :q "
                "OR LOWER(COALESCE(u.nickname,'')) LIKE :q)"
            )
            params["q"] = f"%{q}%"

        if status_filter == "active":
            where_parts.append("u.is_active = TRUE AND (u.is_blocked = FALSE OR u.is_blocked IS NULL)")
        elif status_filter == "inactive":
            where_parts.append("(u.is_active = FALSE OR u.is_blocked = TRUE)")

        if tenant_filter:
            where_parts.append(
                "EXISTS (SELECT 1 FROM user_tenants ut2 "
                "INNER JOIN tenants t2 ON ut2.tenant_id = t2.id "
                "WHERE ut2.user_id = u.id AND t2.slug = :tenant AND ut2.is_active = TRUE)"
            )
            params["tenant"] = tenant_filter

        if request.args.get("missing_contact") == "true":
            where_parts.append("(u.phone IS NULL OR u.phone = '')")

        where_sql = " AND ".join(where_parts)

        # Sort
        sort_map = {"name": "u.name", "email": "u.email", "created_at": "u.created_at"}
        sort_col = sort_map.get(sort_by_param, "u.name")
        sort_dir = "DESC" if sort_dir_param == "desc" else "ASC"

        # Count
        count_row = fetch_one(
            f"SELECT COUNT(*) AS total FROM users u WHERE {where_sql}",
            params,
        )
        total = count_row["total"] if count_row else 0

        # Fetch page
        offset = (page - 1) * per_page
        params["limit_val"] = per_page
        params["offset_val"] = offset

        users = fetch_all(
            f"""
            SELECT u.*
            FROM users u
            WHERE {where_sql}
            ORDER BY {sort_col} {sort_dir}
            LIMIT :limit_val OFFSET :offset_val
            """,
            params,
        )

        # Batch fetch tenants for all users on this page
        tenant_map: dict = {}
        if users:
            user_ids = [u["id"] for u in users]
            placeholders = ",".join(str(uid) for uid in user_ids)
            memberships = fetch_all(
                f"""
                SELECT ut.user_id, t.id, t.slug, t.display_name,
                       s.slug AS system_slug, s.display_name AS system_name,
                       ut.role
                FROM user_tenants ut
                INNER JOIN tenants t ON ut.tenant_id = t.id
                INNER JOIN systems s ON t.system_id = s.id
                WHERE ut.user_id IN ({placeholders}) AND ut.is_active = TRUE
                ORDER BY s.display_order, t.display_name
                """
            )
            for m in memberships:
                uid = m["user_id"]
                if uid not in tenant_map:
                    tenant_map[uid] = []
                tenant_map[uid].append({
                    "id": m["id"],
                    "slug": m["slug"],
                    "name": m["display_name"],
                    "system": m["system_name"],
                    "systemSlug": m["system_slug"],
                    "role": m["role"],
                })

        # Build response items
        items = []
        for u in users:
            item = _user_to_item(u)
            item["tenants"] = tenant_map.get(u["id"], [])
            items.append(item)

        pages = max(1, (total + per_page - 1) // per_page) if total > 0 else 0

        return jsonify({
            "items": items,
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


# ─── Gerenciamento de tenants por user (super admin) ──────────────
@admin_user_bp.get("/users/<int:user_id>/tenants")
@_super_admin_required
def list_user_tenants(user_id: int):
    """Lista todos os tenants de um user."""
    try:
        memberships = fetch_all(
            """
            SELECT ut.id AS membership_id, ut.role, ut.is_active, ut.joined_at,
                   t.id AS tenant_id, t.slug, t.display_name,
                   s.slug AS system_slug, s.display_name AS system_name
            FROM user_tenants ut
            INNER JOIN tenants t ON ut.tenant_id = t.id
            INNER JOIN systems s ON t.system_id = s.id
            WHERE ut.user_id = :user_id
            ORDER BY s.display_order, t.display_name
            """,
            {"user_id": user_id},
        )
        return jsonify({
            "tenants": [
                {
                    "membershipId": m["membership_id"],
                    "tenantId": m["tenant_id"],
                    "slug": m["slug"],
                    "displayName": m["display_name"],
                    "systemSlug": m["system_slug"],
                    "systemName": m["system_name"],
                    "role": m["role"],
                    "isActive": bool(m["is_active"]),
                    "joinedAt": m["joined_at"].isoformat() if m.get("joined_at") else None,
                }
                for m in memberships
            ],
        })
    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.post("/users/<int:user_id>/tenants/<int:tenant_id>")
@_super_admin_required
def add_user_to_tenant(user_id: int, tenant_id: int):
    """Adicionar user a um tenant (super admin)."""
    try:
        # Verificar user e tenant existem
        user = fetch_one("SELECT id FROM users WHERE id = :id", {"id": user_id})
        if not user:
            return jsonify({"error": "Usuário não encontrado"}), 404

        tenant = fetch_one(
            "SELECT id, display_name FROM tenants WHERE id = :id AND is_active = TRUE",
            {"id": tenant_id},
        )
        if not tenant:
            return jsonify({"error": "Tenant não encontrado"}), 404

        data = request.get_json(silent=True) or {}
        role = data.get("role", "player")
        valid_roles = ("player", "admin", "manager", "viewer", "client")
        if role not in valid_roles:
            role = "player"

        execute_sql(
            """
            INSERT INTO user_tenants (user_id, tenant_id, role, approved_by, approved_at)
            VALUES (:user_id, :tenant_id, :role, :admin_id, NOW())
            ON DUPLICATE KEY UPDATE
                is_active = TRUE, left_at = NULL, role = :role,
                approved_by = :admin_id, approved_at = NOW()
            """,
            {
                "user_id": user_id,
                "tenant_id": tenant_id,
                "role": role,
                "admin_id": g.current_user_id,
            },
        )

        return jsonify({
            "message": f"Usuário adicionado ao {tenant['display_name']}",
        }), 201

    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.delete("/users/<int:user_id>/tenants/<int:tenant_id>")
@_super_admin_required
def remove_user_from_tenant(user_id: int, tenant_id: int):
    """Remover user de um tenant (super admin)."""
    try:
        execute_sql(
            """
            UPDATE user_tenants
            SET is_active = FALSE, left_at = NOW()
            WHERE user_id = :user_id AND tenant_id = :tenant_id
            """,
            {"user_id": user_id, "tenant_id": tenant_id},
        )
        return jsonify({"message": "Usuário removido do tenant"})
    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500


@admin_user_bp.get("/tenants")
@_super_admin_required
def list_all_tenants():
    """Lista todos os tenants ativos (para dropdown de seleção)."""
    try:
        tenants = fetch_all(
            """
            SELECT t.id, t.slug, t.display_name, t.primary_color,
                   s.slug AS system_slug, s.display_name AS system_name,
                   s.icon AS system_icon, s.color AS system_color
            FROM tenants t
            INNER JOIN systems s ON t.system_id = s.id
            WHERE t.is_active = TRUE
            ORDER BY s.display_order, t.display_name
            """
        )
        return jsonify({
            "tenants": [
                {
                    "id": t["id"],
                    "slug": t["slug"],
                    "displayName": t["display_name"],
                    "primaryColor": t.get("primary_color"),
                    "systemSlug": t["system_slug"],
                    "systemName": t["system_name"],
                    "systemIcon": t.get("system_icon"),
                    "systemColor": t.get("system_color"),
                }
                for t in tenants
            ],
        })
    except Exception as e:
        if ENV == "dev":
            traceback.print_exc()
        return jsonify({"error": safe_db_error(e)}), 500
