-- ==========================================
-- SELETOR DE SISTEMA: SCHEMA COMPLETO
-- Banco: seletor_db
-- Versão: 2026-02-17 (merge de todas as migrations)
--
-- COMO USAR EM PRODUÇÃO:
--   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS seletor_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
--   mysql -u root -p seletor_db < schema-super-multitenant.sql
-- ==========================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- TABELA: systems
-- ==========================================
CREATE TABLE IF NOT EXISTS systems (
    id INT AUTO_INCREMENT PRIMARY KEY,

    slug VARCHAR(50) UNIQUE NOT NULL COMMENT 'jogador, quadra, lances, arbitro',
    display_name VARCHAR(100) NOT NULL COMMENT 'Campeonatos, Gestão de Quadras, etc',
    description TEXT COMMENT 'Descrição do sistema',

    icon VARCHAR(100) COMMENT 'Ícone: trophy, building, video, whistle',
    color VARCHAR(7) DEFAULT '#ef4444' COMMENT 'Cor do card',

    base_route VARCHAR(100) COMMENT 'Rota base: /jogador, /quadra',
    is_active BOOLEAN DEFAULT TRUE,

    display_order INT DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_slug (slug),
    INDEX idx_active (is_active),
    INDEX idx_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: tenants
-- ==========================================
CREATE TABLE IF NOT EXISTS tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,

    system_id INT NOT NULL COMMENT 'ID do sistema (jogador, quadra, etc)',

    slug VARCHAR(50) UNIQUE NOT NULL COMMENT 'URL-friendly: copa-brahma, arena-sport',
    display_name VARCHAR(100) NOT NULL COMMENT 'Nome para exibição',

    database_name VARCHAR(64) NOT NULL COMMENT 'Nome real do DB (onde app roda)',
    database_host VARCHAR(255) DEFAULT 'db' COMMENT 'Host do MySQL do app (ex: varzea-prime-db)',

    logo_url VARCHAR(255) COMMENT 'URL do logo',
    favicon_url VARCHAR(255) COMMENT 'Favicon customizado',

    primary_color VARCHAR(7) DEFAULT '#ef4444',
    secondary_color VARCHAR(7) DEFAULT '#f59e0b',
    accent_color VARCHAR(7) DEFAULT '#3b82f6',
    background_color VARCHAR(7) DEFAULT '#09090b',

    welcome_message TEXT,
    footer_text VARCHAR(255),

    address TEXT COMMENT 'Endereço completo',
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(100),
    cnpj VARCHAR(18) COMMENT 'CNPJ do estabelecimento',

    allow_registration BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    maintenance_mode BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_tenants_system
      FOREIGN KEY (system_id) REFERENCES systems(id) ON DELETE CASCADE,

    INDEX idx_slug (slug),
    INDEX idx_system (system_id),
    INDEX idx_active (is_active),
    INDEX idx_maintenance (maintenance_mode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: tenant_features
-- ==========================================
CREATE TABLE IF NOT EXISTS tenant_features (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,

    feature_name VARCHAR(50) NOT NULL COMMENT 'ranking, reservas, pagamentos',
    is_enabled BOOLEAN DEFAULT TRUE,
    config JSON,

    CONSTRAINT fk_tenant_features_tenant
      FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,

    UNIQUE KEY unique_tenant_feature (tenant_id, feature_name),
    INDEX idx_feature (feature_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: super_admins
-- ==========================================
CREATE TABLE IF NOT EXISTS super_admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uniq_super_admins_email (email),
    INDEX idx_super_admins_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: users (Central Hub)
-- Todos os usuários do ecossistema
-- ==========================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Identificação
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),

    -- Documentos
    cpf VARCHAR(14),
    cnpj VARCHAR(18),

    -- Endereço normalizado
    address TEXT,
    cep VARCHAR(9),
    logradouro VARCHAR(200),
    numero VARCHAR(20),
    bairro VARCHAR(100),
    complemento VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(2),
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',

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
    INDEX idx_users_nickname (nickname),
    INDEX idx_users_cpf (cpf),
    INDEX idx_users_cnpj (cnpj),
    INDEX idx_users_cep (cep),
    INDEX idx_users_city (city),
    INDEX idx_users_state (state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- TABELA: user_tenants (Memberships)
-- ==========================================
CREATE TABLE IF NOT EXISTS user_tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    tenant_id INT NOT NULL,

    role ENUM('player', 'admin', 'manager', 'viewer') DEFAULT 'player',

    is_active BOOLEAN DEFAULT TRUE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP NULL,

    metadata JSON,

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

    status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',

    message TEXT,

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
-- ==========================================
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    token_hash VARCHAR(64) NOT NULL COMMENT 'SHA256 do token',

    device_name VARCHAR(100),
    device_type ENUM('web', 'mobile', 'tablet', 'unknown') DEFAULT 'unknown',
    ip_address VARCHAR(45),
    user_agent TEXT,

    current_tenant_id INT NULL,

    expires_at TIMESTAMP NOT NULL,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

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
-- TABELA: user_interests (Lead Capture)
-- ==========================================
CREATE TABLE IF NOT EXISTS user_interests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    system_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_interests_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_interests_system FOREIGN KEY (system_id) REFERENCES systems(id) ON DELETE CASCADE,

    UNIQUE KEY uniq_user_interest (user_id, system_id),
    INDEX idx_user_interests_system (system_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- SEED: systems (idempotente)
-- ==========================================
INSERT INTO systems (slug, display_name, description, icon, color, base_route, display_order, is_active)
VALUES
('jogador', 'Campeonatos',        'Gerencie seus campeonatos de futebol',               'trophy',   '#ef4444', '/jogador', 1, TRUE),
('lances',  'Meus Lances',        'Câmeras e gravações dos seus jogos',                 'video',    '#8b5cf6', '/lances',  2, TRUE),
('quadra',  'Gestão de Quadras',  'Reservas e gestão de espaços esportivos',            'building', '#3b82f6', '/quadra',  3, TRUE),
('arbitro', 'Portal do Árbitro',  'Escalas e gestão de arbitragem',                     'whistle',  '#f59e0b', '/arbitro', 4, FALSE)
ON DUPLICATE KEY UPDATE
display_name = VALUES(display_name),
description  = VALUES(description),
icon         = VALUES(icon),
color        = VALUES(color),
base_route   = VALUES(base_route),
display_order= VALUES(display_order),
is_active    = VALUES(is_active);

-- ==========================================
-- SEED: tenants (idempotente)
-- allow_registration = FALSE (exige aprovação do admin)
-- ==========================================
INSERT INTO tenants (
  system_id, slug, display_name, database_name, database_host,
  primary_color, secondary_color, accent_color, welcome_message,
  is_active, allow_registration, maintenance_mode
)
VALUES
(
  (SELECT id FROM systems WHERE slug='jogador' LIMIT 1),
  'copa-brahma', 'Copa Brahma', 'copa_brahma_db', 'varzea-prime-db',
  '#FFD700', '#000000', '#FFFFFF', 'Bem-vindo à Copa Brahma - O melhor futebol amador!',
  TRUE, FALSE, FALSE
),
(
  (SELECT id FROM systems WHERE slug='jogador' LIMIT 1),
  'copa-aposentados', 'Copa AposentadoS', 'copa_aposentados', 'varzea-prime-db',
  '#ef4444', '#f59e0b', '#3b82f6', 'Bem-vindo à Copa AposentadoS - Experiência em campo!',
  TRUE, FALSE, FALSE
),
(
  (SELECT id FROM systems WHERE slug='jogador' LIMIT 1),
  'liga-ouro', 'Liga Ouro', 'liga_ouro_db', 'varzea-prime-db',
  '#F4C430', '#C0C0C0', '#CD7F32', 'Bem-vindo à Liga Ouro - Onde campeões são forjados!',
  TRUE, FALSE, FALSE
),
(
  (SELECT id FROM systems WHERE slug='quadra' LIMIT 1),
  'arena-sport', 'Arena Sport Center', 'arena_sport_db', 'varzea-prime-db',
  '#10b981', '#059669', '#3b82f6', 'Bem-vindo à Arena Sport - Reserve sua quadra!',
  TRUE, FALSE, FALSE
),
(
  (SELECT id FROM systems WHERE slug='quadra' LIMIT 1),
  'society-club', 'Society Club', 'society_club_db', 'varzea-prime-db',
  '#8b5cf6', '#7c3aed', '#3b82f6', 'Society Club - A melhor infraestrutura para seu jogo',
  TRUE, FALSE, FALSE
),
(
  (SELECT id FROM systems WHERE slug='lances' LIMIT 1),
  'lance-de-ouro', 'Lance de Ouro', 'scl_db', 'varzea-prime-db-1',
  '#8b5cf6', '#7c3aed', '#a78bfa',
  'Lance de Ouro - Câmeras e gravações dos seus jogos. Assista e compartilhe seus melhores momentos!',
  TRUE, FALSE, FALSE
)
ON DUPLICATE KEY UPDATE
display_name       = VALUES(display_name),
database_name      = VALUES(database_name),
database_host      = VALUES(database_host),
primary_color      = VALUES(primary_color),
secondary_color    = VALUES(secondary_color),
accent_color       = VALUES(accent_color),
welcome_message    = VALUES(welcome_message),
is_active          = VALUES(is_active),
allow_registration = VALUES(allow_registration),
maintenance_mode   = VALUES(maintenance_mode);

-- Ajusta endereços dos tenants quadra
UPDATE tenants SET
  address = 'Rua do Esporte, 123 - Centro',
  city    = 'São Paulo',
  state   = 'SP',
  zip_code= '01234-567',
  phone   = '(11) 98765-4321',
  email   = 'contato@arenasport.com.br'
WHERE slug = 'arena-sport';

UPDATE tenants SET
  address = 'Av. Principal, 456 - Jardim',
  city    = 'Campo Grande',
  state   = 'MS',
  zip_code= '79000-000',
  phone   = '(67) 99876-5432',
  email   = 'reservas@societyclub.com.br'
WHERE slug = 'society-club';

-- ==========================================
-- SEED: tenant_features (idempotente)
-- ==========================================
INSERT INTO tenant_features (tenant_id, feature_name, is_enabled, config)
VALUES
((SELECT id FROM tenants WHERE slug='copa-brahma' LIMIT 1), 'ranking', TRUE, '{"show_photos": true, "items_per_page": 20}'),
((SELECT id FROM tenants WHERE slug='copa-brahma' LIMIT 1), 'statistics', TRUE, '{"show_advanced": false}'),
((SELECT id FROM tenants WHERE slug='copa-brahma' LIMIT 1), 'photos', TRUE, '{"max_size_mb": 5}'),
((SELECT id FROM tenants WHERE slug='copa-brahma' LIMIT 1), 'cards', TRUE, '{"enable_fifa_cards": true}'),

((SELECT id FROM tenants WHERE slug='copa-aposentados' LIMIT 1), 'ranking', TRUE, '{"show_photos": true, "items_per_page": 50}'),
((SELECT id FROM tenants WHERE slug='copa-aposentados' LIMIT 1), 'statistics', TRUE, '{"show_advanced": true}'),
((SELECT id FROM tenants WHERE slug='copa-aposentados' LIMIT 1), 'photos', TRUE, '{"max_size_mb": 10}'),
((SELECT id FROM tenants WHERE slug='copa-aposentados' LIMIT 1), 'cards', TRUE, '{"enable_fifa_cards": true}'),

((SELECT id FROM tenants WHERE slug='arena-sport' LIMIT 1), 'reservas', TRUE, '{"min_hours": 1, "max_days_advance": 30}'),
((SELECT id FROM tenants WHERE slug='arena-sport' LIMIT 1), 'pagamentos', TRUE, '{"accept_pix": true, "accept_card": true}'),
((SELECT id FROM tenants WHERE slug='arena-sport' LIMIT 1), 'calendario', TRUE, '{"show_availability": true}'),

((SELECT id FROM tenants WHERE slug='society-club' LIMIT 1), 'reservas', TRUE, '{"min_hours": 2, "max_days_advance": 15}'),
((SELECT id FROM tenants WHERE slug='society-club' LIMIT 1), 'pagamentos', TRUE, '{"accept_pix": true}'),
((SELECT id FROM tenants WHERE slug='society-club' LIMIT 1), 'calendario', TRUE, '{"show_availability": true}'),
((SELECT id FROM tenants WHERE slug='society-club' LIMIT 1), 'lanchonete', TRUE, '{"enable_orders": true}')
ON DUPLICATE KEY UPDATE
is_enabled = VALUES(is_enabled),
config      = VALUES(config);

-- ==========================================
-- SEED: super_admin (Radael Ivan)
-- Senha: MA13036619.1802
-- ==========================================
INSERT INTO super_admins (name, email, password_hash, is_active)
VALUES (
    'Radael Ivan da Silva Insfran',
    'radaelivan@gmail.com',
    'scrypt:32768:8:1$vNjkThXMZOPYJNro$78f0be83d0b0a66ed49fb7cc9d6fcc4e68f7002266f98a354de3ef48b4a7288b99e66217a9c4512e8f3d8320c268f4c217264888fa4b5da10647e45677491930',
    TRUE
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    password_hash = VALUES(password_hash),
    is_active = VALUES(is_active);

-- ==========================================
-- SEED: users do copa_aposentados
-- Radael: senha real MA13036619.1802
-- Demais: senha temporária "mudar123"
-- ==========================================
INSERT INTO users (name, nickname, email, phone, password_hash, is_active, email_verified_at)
VALUES (
    'Radael Ivan da Silva Insfran', 'RadaHell', 'radaelivan@gmail.com', NULL,
    'scrypt:32768:8:1$vNjkThXMZOPYJNro$78f0be83d0b0a66ed49fb7cc9d6fcc4e68f7002266f98a354de3ef48b4a7288b99e66217a9c4512e8f3d8320c268f4c217264888fa4b5da10647e45677491930',
    TRUE, NOW()
)
ON DUPLICATE KEY UPDATE name = VALUES(name), nickname = VALUES(nickname);

INSERT INTO users (name, nickname, email, phone, password_hash, is_active) VALUES
('Matheus Figueiredo', 'Leo Figueira', 'figueiredomatheus397@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Matheus Cunha Flores Monteiro', 'El cucunha', 'mrmatheuscunha@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('EZEQUIAS DA SILVA CORREA FILHO', 'Mesut Kilo', 'ezequiascorrea660@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Marcos Poquiviqui Santana', 'Poke', 'vikpoke666@gmail.com', '65996822631', 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Rodrigo Leon', 'Rodrigol', 'goncalvesalencar@hotmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Felipe Eduardo da Silva Campos', 'Buzz', 'drackaru@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Guilherme Coelho Soares', 'Gui Negão', 'coelhovrf@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Luciano Lopes', 'Lulu Depay', 'lopez.luciano9522@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Michael Douglas', 'D''Michael', 'mayconreua@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Gabriel Rossi Soares', 'Messi', 'gabisrossi2002@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Gabriel Almeida de Oliveira', 'Paolo Almeidini', 'almeida270415@gmail.com', '67999575709', 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Lothar Mateus', 'Big', 'lothar.mateussc@hotmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Victor Moraes Miranda', 'Vitão', 'mirandarotvic123@gmail.com', '67999399865', 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Gabriel Januario Garcia Martins', 'Januba', 'paudaplaca7@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('BRUNO ARIEL DINIZ DA SILVA', 'BRUNERA', 'bdiniiz22@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Joaquim Clink Ribeiro', 'Estevão', 'joaquimclinkribeiro@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Matheus Guilherme Durães Fernandes', 'Gui neguinho', 'fernandesfernandes@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Luan Cassaro', 'Sanfoneiro', 'lcassaro2015@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Matheus Guilherme Durães Fernandes', 'Guizinho negãozinho', 'fernandesfernandes1377@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Bruno Marinho Maciel', 'Brunou14', 'brunomarinhomaciel17@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Caio Cezar Braga Bressan', 'Caio', 'redentorms@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Nathan Vinícius Ferreira Diniz', 'Tanan', 'dzferreira20@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Renato Gonçalves Martins', 'Comi o de cima 🤣', 'gauduny@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('elinson', 'Elinson', 'elinson@copa.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('teste', 'teste', 'teste@copa.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Welyton Jhonny', 'Muro', 'Welyton@copa.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('João Vitor Ferreira', 'TotinRabando', 'joao261099vitor@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Lucas de Graauw Zimpel', 'Lucas', 'lucasgraauw14@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Marcos Vinicius', 'McQueen', 'marcosalved@hotmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Mateus Augusto Colman Cheung', 'Cheung', 'cheungmateus@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Lucas Abdiel Vargas Martines', 'Lucas m', 'abdiel.lucaseliane@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Diego Massanori', 'Massanori', 'dmot0896@gmail.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Substituto 1', 'Substituto 1', 'substituto1@copaaposentado.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Substituto 2', 'Substituto 2', 'subistituto2@copaaposentados.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE),
('Substituto 3', 'Substituto 3', 'subistituto3@dopaaposentados.com', NULL, 'scrypt:32768:8:1$0b9cJsYgNCsi6Qrb$e61db080e195a1cd92ad72f0d88a675d8bb0a9cee946dee91839e846dcf9c01789dec949d6bd4274e9178064b923e0ed7182f7786ac40978c8d9df1b89927429', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name), nickname = VALUES(nickname);

-- ==========================================
-- SEED: user_tenants (memberships copa-aposentados)
-- ==========================================

-- Admins
INSERT INTO user_tenants (user_id, tenant_id, role, is_active)
SELECT u.id, (SELECT id FROM tenants WHERE slug='copa-aposentados'), 'admin', TRUE
FROM users u WHERE u.email IN (
    'radaelivan@gmail.com',
    'ezequiascorrea660@gmail.com',
    'lothar.mateussc@hotmail.com',
    'mirandarotvic123@gmail.com',
    'substituto1@copaaposentado.com',
    'subistituto2@copaaposentados.com',
    'subistituto3@dopaaposentados.com'
)
ON DUPLICATE KEY UPDATE role = 'admin', is_active = TRUE;

-- Players (todos os demais)
INSERT INTO user_tenants (user_id, tenant_id, role, is_active)
SELECT u.id, (SELECT id FROM tenants WHERE slug='copa-aposentados'), 'player', TRUE
FROM users u
WHERE u.email NOT IN (
    'radaelivan@gmail.com',
    'ezequiascorrea660@gmail.com',
    'lothar.mateussc@hotmail.com',
    'mirandarotvic123@gmail.com',
    'substituto1@copaaposentado.com',
    'subistituto2@copaaposentados.com',
    'subistituto3@dopaaposentados.com'
)
ON DUPLICATE KEY UPDATE role = 'player', is_active = TRUE;

-- Radael → admin do Lance de Ouro
INSERT INTO user_tenants (user_id, tenant_id, role, is_active)
SELECT u.id, (SELECT id FROM tenants WHERE slug='lance-de-ouro'), 'admin', TRUE
FROM users u WHERE u.email = 'radaelivan@gmail.com'
ON DUPLICATE KEY UPDATE role = 'admin', is_active = TRUE;

-- ==========================================
-- VIEWS ÚTEIS
-- ==========================================
CREATE OR REPLACE VIEW systems_overview AS
SELECT
  s.id, s.slug, s.display_name, s.icon, s.color, s.is_active,
  COUNT(t.id) AS total_tenants,
  SUM(CASE WHEN t.is_active = TRUE THEN 1 ELSE 0 END) AS active_tenants
FROM systems s
LEFT JOIN tenants t ON s.id = t.system_id
GROUP BY s.id
ORDER BY s.display_order;

CREATE OR REPLACE VIEW tenants_full AS
SELECT
  t.id, t.slug, t.display_name, t.database_name, t.database_host,
  t.primary_color, t.is_active, t.maintenance_mode,
  s.slug AS system_slug, s.display_name AS system_name,
  s.icon AS system_icon, s.color AS system_color
FROM tenants t
INNER JOIN systems s ON t.system_id = s.id;

CREATE OR REPLACE VIEW user_tenants_full AS
SELECT
    ut.id, ut.user_id, ut.tenant_id, ut.role, ut.is_active, ut.joined_at,
    u.name AS user_name, u.email AS user_email, u.avatar_url AS user_avatar,
    t.slug AS tenant_slug, t.display_name AS tenant_name,
    t.logo_url AS tenant_logo, t.primary_color AS tenant_color,
    s.slug AS system_slug, s.display_name AS system_name,
    s.icon AS system_icon, s.color AS system_color
FROM user_tenants ut
INNER JOIN users u ON ut.user_id = u.id
INNER JOIN tenants t ON ut.tenant_id = t.id
INNER JOIN systems s ON t.system_id = s.id;

CREATE OR REPLACE VIEW available_tenants AS
SELECT
    t.id, t.slug, t.display_name, t.logo_url, t.primary_color,
    t.welcome_message, t.allow_registration,
    s.slug AS system_slug, s.display_name AS system_name,
    s.icon AS system_icon, s.color AS system_color,
    (SELECT COUNT(*) FROM user_tenants ut WHERE ut.tenant_id = t.id AND ut.is_active = TRUE) AS member_count
FROM tenants t
INNER JOIN systems s ON t.system_id = s.id
WHERE t.is_active = TRUE AND t.maintenance_mode = FALSE;
