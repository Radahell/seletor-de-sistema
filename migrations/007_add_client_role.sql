-- Migration 007: Adicionar 'client' ao ENUM de role em user_tenants
-- Necessario para sistemas auto-approve (quadra) que adicionam users como client

ALTER TABLE user_tenants
  MODIFY COLUMN role ENUM('player', 'admin', 'manager', 'viewer', 'client') DEFAULT 'player';
