-- ==========================================
-- MIGRAÇÃO: Usuários Centralizados
-- Data: 2026-02-04
-- Descrição: Adiciona tabelas para autenticação
--            centralizada e memberships de sistemas
-- ==========================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- TABELA: users (Central)
-- Todos os usuários do ecossistema
-- ==========================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Identificação
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),

    -- Autenticação
    password_hash VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMP NULL,

    -- Perfil
    avatar_url VARCHAR(500),
    bio TEXT,
    birth_date DATE,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_blocked BOOLEAN DEFAULT FALSE,
    blocked_reason VARCHAR(255),

    -- Metadata
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uniq_users_email (email),
    INDEX idx_users_phone (phone),
    INDEX idx_users_active (is_active),
    INDEX idx_users_nickname (nickname)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: user_tenants (Memberships)
-- Quais sistemas/tenants cada usuário participa
-- ==========================================
CREATE TABLE IF NOT EXISTS user_tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    tenant_id INT NOT NULL,

    -- Papel no tenant
    role ENUM('player', 'admin', 'manager', 'viewer') DEFAULT 'player',

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP NULL,

    -- Dados extras por tenant (JSON flexível)
    metadata JSON,

    -- Quem aprovou (se precisar aprovação)
    approved_by INT NULL,
    approved_at TIMESTAMP NULL,

    CONSTRAINT fk_user_tenants_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_tenants_tenant
        FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_tenants_approver
        FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,

    UNIQUE KEY uniq_user_tenant (user_id, tenant_id),
    INDEX idx_user_tenants_user (user_id),
    INDEX idx_user_tenants_tenant (tenant_id),
    INDEX idx_user_tenants_role (role),
    INDEX idx_user_tenants_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: user_tenant_requests
-- Solicitações pendentes de entrada
-- ==========================================
CREATE TABLE IF NOT EXISTS user_tenant_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    tenant_id INT NOT NULL,

    -- Status da solicitação
    status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',

    -- Mensagem do usuário
    message TEXT,

    -- Resposta do admin
    response_message TEXT,
    responded_by INT NULL,
    responded_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_tenant_requests_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_tenant_requests_tenant
        FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_tenant_requests_responder
        FOREIGN KEY (responded_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_requests_user (user_id),
    INDEX idx_requests_tenant (tenant_id),
    INDEX idx_requests_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: user_sessions
-- Sessões ativas (para logout remoto, etc)
-- ==========================================
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    -- Token info
    token_hash VARCHAR(64) NOT NULL COMMENT 'SHA256 do token',

    -- Device info
    device_name VARCHAR(100),
    device_type ENUM('web', 'mobile', 'tablet', 'unknown') DEFAULT 'unknown',
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- Contexto atual
    current_tenant_id INT NULL,

    -- Timestamps
    expires_at TIMESTAMP NOT NULL,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Revogação
    revoked_at TIMESTAMP NULL,
    revoked_reason VARCHAR(100),

    CONSTRAINT fk_user_sessions_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_sessions_tenant
        FOREIGN KEY (current_tenant_id) REFERENCES tenants(id) ON DELETE SET NULL,

    INDEX idx_sessions_user (user_id),
    INDEX idx_sessions_token (token_hash),
    INDEX idx_sessions_expires (expires_at),
    INDEX idx_sessions_active (revoked_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- ATUALIZAÇÃO: systems
-- Adicionar sistema "lances" (câmeras)
-- ==========================================
INSERT INTO systems (slug, display_name, description, icon, color, base_route, display_order, is_active)
VALUES
('lances', 'Meus Lances', 'Câmeras e gravações dos seus jogos', 'video', '#8b5cf6', '/lances', 2, TRUE)
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    description = VALUES(description),
    icon = VALUES(icon),
    color = VALUES(color),
    base_route = VALUES(base_route),
    is_active = VALUES(is_active);

-- Reordenar sistemas
UPDATE systems SET display_order = 1 WHERE slug = 'jogador';
UPDATE systems SET display_order = 2 WHERE slug = 'lances';
UPDATE systems SET display_order = 3 WHERE slug = 'quadra';
UPDATE systems SET display_order = 4 WHERE slug = 'arbitro';

-- ==========================================
-- VIEW: user_tenants_full
-- Visão completa das memberships
-- ==========================================
CREATE OR REPLACE VIEW user_tenants_full AS
SELECT
    ut.id,
    ut.user_id,
    ut.tenant_id,
    ut.role,
    ut.is_active,
    ut.joined_at,
    u.name AS user_name,
    u.email AS user_email,
    u.avatar_url AS user_avatar,
    t.slug AS tenant_slug,
    t.display_name AS tenant_name,
    t.logo_url AS tenant_logo,
    t.primary_color AS tenant_color,
    s.slug AS system_slug,
    s.display_name AS system_name,
    s.icon AS system_icon,
    s.color AS system_color
FROM user_tenants ut
INNER JOIN users u ON ut.user_id = u.id
INNER JOIN tenants t ON ut.tenant_id = t.id
INNER JOIN systems s ON t.system_id = s.id;

-- ==========================================
-- VIEW: available_tenants
-- Tenants disponíveis para inscrição
-- ==========================================
CREATE OR REPLACE VIEW available_tenants AS
SELECT
    t.id,
    t.slug,
    t.display_name,
    t.logo_url,
    t.primary_color,
    t.welcome_message,
    t.allow_registration,
    s.slug AS system_slug,
    s.display_name AS system_name,
    s.icon AS system_icon,
    s.color AS system_color,
    (SELECT COUNT(*) FROM user_tenants ut WHERE ut.tenant_id = t.id AND ut.is_active = TRUE) AS member_count
FROM tenants t
INNER JOIN systems s ON t.system_id = s.id
WHERE t.is_active = TRUE
  AND t.maintenance_mode = FALSE;

SET FOREIGN_KEY_CHECKS = 1;
