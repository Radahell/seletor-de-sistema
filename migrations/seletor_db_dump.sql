-- MySQL dump 10.13  Distrib 8.4.7, for Linux (x86_64)
--
-- Host: localhost    Database: seletor_db
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `available_tenants`
--

DROP TABLE IF EXISTS `available_tenants`;
/*!50001 DROP VIEW IF EXISTS `available_tenants`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `available_tenants` AS SELECT 
 1 AS `id`,
 1 AS `slug`,
 1 AS `display_name`,
 1 AS `logo_url`,
 1 AS `primary_color`,
 1 AS `welcome_message`,
 1 AS `allow_registration`,
 1 AS `system_slug`,
 1 AS `system_name`,
 1 AS `system_icon`,
 1 AS `system_color`,
 1 AS `member_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `super_admins`
--

DROP TABLE IF EXISTS `super_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `super_admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_super_admins_email` (`email`),
  KEY `idx_super_admins_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `super_admins`
--

LOCK TABLES `super_admins` WRITE;
/*!40000 ALTER TABLE `super_admins` DISABLE KEYS */;
INSERT INTO `super_admins` VALUES (1,'Radael Ivan da Silva Insfran','radaelivan@gmail.com','scrypt:32768:8:1$ohcEFKyG5KVLAabk$34f53f2fd9f85923676cd436316b32dd3c8d38a19b0087536f69bff3f9f20daf0f69ac69337bec148616015a84039466ba29ac7c54e770066c1ee6be36862d3a',1,'2026-02-15 08:41:33');
/*!40000 ALTER TABLE `super_admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `systems`
--

DROP TABLE IF EXISTS `systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `systems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `slug` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'jogador, quadra, arbitro',
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Sistema de Jogadores, Gestão de Quadras',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT 'Descrição do sistema',
  `icon` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Ícone: trophy, building, whistle',
  `color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#ef4444' COMMENT 'Cor do card',
  `base_route` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Rota base: /jogador, /quadra',
  `is_active` tinyint(1) DEFAULT '1',
  `display_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_slug` (`slug`),
  KEY `idx_active` (`is_active`),
  KEY `idx_order` (`display_order`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `systems`
--

LOCK TABLES `systems` WRITE;
/*!40000 ALTER TABLE `systems` DISABLE KEYS */;
INSERT INTO `systems` VALUES (1,'jogador','Sistema de Jogadores','Gestão de campeonatos e jogadores','trophy','#ef4444','/jogador',1,1,'2026-02-15 07:21:09','2026-02-15 07:21:09'),(2,'quadra','Gestão de Quadras','Reservas e gestão de espaços esportivos','building','#3b82f6','/quadra',1,3,'2026-02-15 07:21:09','2026-02-15 08:27:14'),(3,'arbitro','Portal do Árbitro','Escalas e gestão de arbitragem','whistle','#f59e0b','/arbitro',1,4,'2026-02-15 07:21:09','2026-02-15 08:27:14'),(4,'lances','Meus Lances','Câmeras e gravações dos seus jogos','video','#8b5cf6','/lances',1,2,'2026-02-15 08:27:14','2026-02-15 08:27:14');
/*!40000 ALTER TABLE `systems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `systems_overview`
--

DROP TABLE IF EXISTS `systems_overview`;
/*!50001 DROP VIEW IF EXISTS `systems_overview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `systems_overview` AS SELECT 
 1 AS `id`,
 1 AS `slug`,
 1 AS `display_name`,
 1 AS `icon`,
 1 AS `color`,
 1 AS `is_active`,
 1 AS `total_tenants`,
 1 AS `active_tenants`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tenant_features`
--

DROP TABLE IF EXISTS `tenant_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenant_features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` int NOT NULL,
  `feature_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ranking, reservas, pagamentos',
  `is_enabled` tinyint(1) DEFAULT '1',
  `config` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tenant_feature` (`tenant_id`,`feature_name`),
  KEY `idx_feature` (`feature_name`),
  CONSTRAINT `fk_tenant_features_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenant_features`
--

LOCK TABLES `tenant_features` WRITE;
/*!40000 ALTER TABLE `tenant_features` DISABLE KEYS */;
INSERT INTO `tenant_features` VALUES (1,1,'ranking',1,'{\"show_photos\": true, \"items_per_page\": 20}'),(2,1,'statistics',1,'{\"show_advanced\": false}'),(3,1,'photos',1,'{\"max_size_mb\": 5}'),(4,1,'cards',1,'{\"enable_fifa_cards\": true}'),(5,2,'ranking',1,'{\"show_photos\": true, \"items_per_page\": 50}'),(6,2,'statistics',1,'{\"show_advanced\": true}'),(7,2,'photos',1,'{\"max_size_mb\": 10}'),(8,2,'cards',1,'{\"enable_fifa_cards\": true}'),(9,4,'reservas',1,'{\"min_hours\": 1, \"max_days_advance\": 30}'),(10,4,'pagamentos',1,'{\"accept_pix\": true, \"accept_card\": true}'),(11,4,'calendario',1,'{\"show_availability\": true}'),(12,5,'reservas',1,'{\"min_hours\": 2, \"max_days_advance\": 15}'),(13,5,'pagamentos',1,'{\"accept_pix\": true}'),(14,5,'calendario',1,'{\"show_availability\": true}'),(15,5,'lanchonete',1,'{\"enable_orders\": true}');
/*!40000 ALTER TABLE `tenant_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenants`
--

DROP TABLE IF EXISTS `tenants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `system_id` int NOT NULL COMMENT 'ID do sistema (jogador, quadra, etc)',
  `slug` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'URL-friendly: copa-brahma, arena-sport',
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nome para exibição',
  `database_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nome real do DB (onde app roda)',
  `database_host` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'db' COMMENT 'Host do MySQL do app (ex: varzea-prime-db-1)',
  `logo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'URL do logo',
  `favicon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Favicon customizado',
  `primary_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#ef4444',
  `secondary_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#f59e0b',
  `accent_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#3b82f6',
  `background_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#09090b',
  `welcome_message` text COLLATE utf8mb4_unicode_ci,
  `footer_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci COMMENT 'Endereço completo',
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zip_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cnpj` varchar(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `allow_registration` tinyint(1) DEFAULT '1',
  `is_active` tinyint(1) DEFAULT '1',
  `maintenance_mode` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_slug` (`slug`),
  KEY `idx_system` (`system_id`),
  KEY `idx_active` (`is_active`),
  KEY `idx_maintenance` (`maintenance_mode`),
  CONSTRAINT `fk_tenants_system` FOREIGN KEY (`system_id`) REFERENCES `systems` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenants`
--

LOCK TABLES `tenants` WRITE;
/*!40000 ALTER TABLE `tenants` DISABLE KEYS */;
INSERT INTO `tenants` VALUES (1,1,'copa-brahma','Copa Brahma','copa_brahma_db','varzea-prime-db',NULL,NULL,'#FFD700','#000000','#FFFFFF','#09090b','Bem-vindo à Copa Brahma - O melhor futebol amador!',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,'2026-02-15 07:21:09','2026-02-15 08:50:33'),(2,1,'copa-aposentados','Copa AposentadoS','copa_aposentados','varzea-prime-db',NULL,NULL,'#ef4444','#f59e0b','#3b82f6','#09090b','Bem-vindo à Copa AposentadoS - Experiência em campo!',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,'2026-02-15 07:21:09','2026-02-15 08:50:33'),(3,1,'liga-ouro','Liga Ouro','liga_ouro_db','varzea-prime-db',NULL,NULL,'#F4C430','#C0C0C0','#CD7F32','#09090b','Bem-vindo à Liga Ouro - Onde campeões são forjados!',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,'2026-02-15 07:21:09','2026-02-15 08:50:33'),(4,2,'arena-sport','Arena Sport Center','arena_sport_db','varzea-prime-db',NULL,NULL,'#10b981','#059669','#3b82f6','#09090b','Bem-vindo à Arena Sport - Reserve sua quadra!',NULL,'Rua do Esporte, 123 - Centro','São Paulo','SP','01234-567','(11) 98765-4321','contato@arenasport.com.br',NULL,1,1,0,'2026-02-15 07:21:09','2026-02-15 08:50:33'),(5,2,'society-club','Society Club','society_club_db','varzea-prime-db',NULL,NULL,'#8b5cf6','#7c3aed','#3b82f6','#09090b','Society Club - A melhor infraestrutura para seu jogo',NULL,'Av. Principal, 456 - Jardim','Campo Grande','MS','79000-000','(67) 99876-5432','reservas@societyclub.com.br',NULL,1,1,0,'2026-02-15 07:21:09','2026-02-15 08:50:33'),(6,4,'lance-de-ouro','Lance de Ouro','scl_db','varzea-prime-db',NULL,NULL,'#8b5cf6','#7c3aed','#a78bfa','#09090b','Lance de Ouro - Câmeras e gravações dos seus jogos. Assista e compartilhe seus melhores momentos!',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,'2026-02-15 08:48:19','2026-02-15 08:50:33');
/*!40000 ALTER TABLE `tenants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `tenants_full`
--

DROP TABLE IF EXISTS `tenants_full`;
/*!50001 DROP VIEW IF EXISTS `tenants_full`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `tenants_full` AS SELECT 
 1 AS `id`,
 1 AS `slug`,
 1 AS `display_name`,
 1 AS `database_name`,
 1 AS `database_host`,
 1 AS `primary_color`,
 1 AS `is_active`,
 1 AS `maintenance_mode`,
 1 AS `system_slug`,
 1 AS `system_name`,
 1 AS `system_icon`,
 1 AS `system_color`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `user_interests`
--

DROP TABLE IF EXISTS `user_interests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_interests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `system_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_interest` (`user_id`,`system_id`),
  KEY `idx_user_interests_system` (`system_id`),
  CONSTRAINT `fk_user_interests_system` FOREIGN KEY (`system_id`) REFERENCES `systems` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_interests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_interests`
--

LOCK TABLES `user_interests` WRITE;
/*!40000 ALTER TABLE `user_interests` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_interests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token_hash` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'SHA256 do token',
  `device_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_type` enum('web','mobile','tablet','unknown') COLLATE utf8mb4_unicode_ci DEFAULT 'unknown',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `current_tenant_id` int DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `last_activity_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `revoked_reason` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_sessions_tenant` (`current_tenant_id`),
  KEY `idx_sessions_user` (`user_id`),
  KEY `idx_sessions_token` (`token_hash`),
  KEY `idx_sessions_expires` (`expires_at`),
  KEY `idx_sessions_active` (`revoked_at`),
  CONSTRAINT `fk_user_sessions_tenant` FOREIGN KEY (`current_tenant_id`) REFERENCES `tenants` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
INSERT INTO `user_sessions` VALUES (1,1,'ff9d23fbfd09d977d9835945542fa560f0b38ce60560f2a4dd7befe8b03e521f',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 08:44:37','2026-02-15 08:57:19','2026-02-15 08:44:37','2026-02-15 08:57:19','user_logout'),(2,1,'70f3482475a34b94ef137cdfdabb881ecc9e572ea67e6084c21a8965a06ad0d4',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 08:57:22','2026-02-15 09:05:18','2026-02-15 08:57:22',NULL,NULL),(3,1,'8cbe2b07edc1c227b047e820d77c71064e2a9e3504103cc438909869d799c275',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:03:06','2026-02-15 09:03:29','2026-02-15 09:03:06',NULL,NULL),(4,1,'a8edc5c9da48eaae2c76a65f3bbc7596b2ae30f9df158b586870e275387f93f6',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 09:03:39','2026-02-15 09:03:38','2026-02-15 09:03:38',NULL,NULL),(5,1,'545e43c04ef8c977a110f4f00875be63eaf3192592550c570a672aedb3c9cf29',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:03:58','2026-02-15 09:04:05','2026-02-15 09:03:57',NULL,NULL),(6,1,'02e393bb63cb010efe41712756d0c06db081980f893c9133a06a5b23464cb481',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 09:04:24','2026-02-15 09:04:23','2026-02-15 09:04:23',NULL,NULL),(7,1,'2eafbb93f7a41b31168241ca7e1dc1cadbf0d5b21e93f296a10f1863d03587e2',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:05:21','2026-02-15 09:38:58','2026-02-15 09:05:20',NULL,NULL),(8,1,'e263d97e00b07aff54613c325ff0165dd2922c97c810966080b20e7d807afee9',NULL,'mobile','172.21.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:08:51','2026-02-15 09:09:16','2026-02-15 09:08:51',NULL,NULL),(9,1,'da4d334f4140b6442eb26daf88562e212606e8713bd58fe16428af4bc8011afc',NULL,'mobile','172.21.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:10:48','2026-02-15 15:04:13','2026-02-15 09:10:48','2026-02-15 15:04:13','user_logout'),(10,1,'39a6e96361f4082f2d5026b1ac69d35daeb150bb9f49ec8e3064f6cf84281e54',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 09:24:12','2026-02-15 09:24:11','2026-02-15 09:24:11',NULL,NULL),(11,1,'4861559f28fa3f1bfeebed3d37e2fe9ca3530f4e8c3723bdd8599fd66f0cb124',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 09:24:37','2026-02-15 09:24:36','2026-02-15 09:24:36',NULL,NULL),(12,1,'4c58bf93f76470c56681ab4a2d489ae3f681c91f6005c9d32733ca6334d98802',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 09:25:05','2026-02-15 09:25:04','2026-02-15 09:25:04',NULL,NULL),(13,1,'aa60b10c5476dbee01da8ae889c8d55062a5fc7495c972501ae71c2afe3f5b33',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:34:58','2026-02-15 09:35:57','2026-02-15 09:34:58',NULL,NULL),(14,1,'863f5280b9a6d037c941d8946f5290a9384685a43b2c534ac8e3076c75047dbf',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 09:39:02','2026-02-15 09:39:02','2026-02-15 09:39:02',NULL,NULL),(15,1,'4a70be0de25b43677a2c4d7fa05e23da3356139af58bdb4daaed912b7f523ac2',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 13:35:14','2026-02-15 13:35:13','2026-02-15 13:35:13',NULL,NULL),(16,1,'ea6f02e2f24d223b51ecb243f6bfbb07a6c59bf69ca22320c7c5f02b29572c2f',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 13:36:04','2026-02-15 13:36:04','2026-02-15 13:36:04',NULL,NULL),(17,1,'ce3a2bf82165b6180f1f162d857903e3dc2c0d29cff26ab1e87c76103768fd28',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 13:37:46','2026-02-15 13:37:45','2026-02-15 13:37:45',NULL,NULL),(18,1,'dbd43809a42a372f28a7a53c8ce2c01ac865975c40dafc65febffdb1c373ee84',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 13:38:15','2026-02-15 13:38:15','2026-02-15 13:38:15',NULL,NULL),(19,1,'ad37104d2068bf13c837b9c706fb74c299fa0b572f0dc91c76931e3da96781b2',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 13:58:43','2026-02-15 17:11:38','2026-02-15 13:58:42',NULL,NULL),(20,1,'eb484f40763fdfb79f9d714dccc320a0b815bb5b1ab72dc09df2be67cc6115dd',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 17:11:42','2026-02-16 00:19:52','2026-02-15 17:11:41',NULL,NULL),(21,1,'ae4151f74a64d41087c61910bca3e72c9d553dec1f79aead39980cafb93cfb12',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 17:49:35','2026-02-15 17:50:01','2026-02-15 17:49:34',NULL,NULL),(22,1,'7538fa2471fb868d47b8adf6c81453f3d34d4913b83c09edf87f01a5f2507b3e',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 17:50:07','2026-02-15 17:50:34','2026-02-15 17:50:06',NULL,NULL),(23,1,'19b13e91861e2fffcde6b7fe894b4de4ac4bad3b7e5c10d2476c6319df454498',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 17:50:40','2026-02-15 18:06:28','2026-02-15 17:50:40',NULL,NULL),(24,1,'f5e7680cb97f0646f38ec229ebfacca2d34c0f461e5171224a6e5a324a39ecd4',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 18:06:31','2026-02-15 18:06:40','2026-02-15 18:06:31','2026-02-15 18:06:40','user_logout'),(25,26,'35fda9926627cefaefd8fd47f07489b00a57e1b0129c5f71d4e050c8e9701d00',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 18:07:03','2026-02-15 18:11:04','2026-02-15 18:07:02','2026-02-15 18:11:04','user_logout'),(26,1,'d402151228a04e238829f02889c53811422a329e2282f77c2532c52b0bfd78a6',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 18:11:07','2026-02-15 18:18:18','2026-02-15 18:11:06','2026-02-15 18:18:18','user_logout'),(27,1,'575ad51592ae73cf9740f8ae31ceda7ad40c3ad197fa6c4080d580b81b37b9ff',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 18:18:21','2026-02-15 19:20:17','2026-02-15 18:18:21',NULL,NULL),(28,1,'866799c267152c133318757806070640100ec47bc401b3989298a5e6e93735a5',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 19:20:20','2026-02-15 19:48:17','2026-02-15 19:20:20','2026-02-15 19:48:17','user_logout'),(29,1,'9031e467a6096558c7f32e2e93dc8735396661c1ed5ea51e0e069ef709990d7e',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 19:31:49','2026-02-15 19:31:49','2026-02-15 19:31:48',NULL,NULL),(30,1,'86b192fdfc16b226153c33e67a1786d19d98d5cd09680f08d696d4507efa91cd',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 19:37:17','2026-02-15 19:37:17','2026-02-15 19:37:17',NULL,NULL),(31,1,'82c07723c2554f1099e32fedd4b247a9e0f14a4c356000ca940d44249ef7fae1',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 19:39:27','2026-02-15 19:39:27','2026-02-15 19:39:27',NULL,NULL),(32,1,'4bff9affd38cfa8ba3d193cbec107fcd883c095df13514b38f88c31441793fda',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 19:44:38','2026-02-15 19:44:38','2026-02-15 19:44:38',NULL,NULL),(33,26,'90e595e3720c757c2773330f21b57c9bd576aa6ca83f4b7a61bdbd72457f3779',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 19:48:24','2026-02-15 20:02:57','2026-02-15 19:48:24','2026-02-15 20:02:57','user_logout'),(34,1,'a11769d23f4ec39d3cb15ebd05f8e4fd57b21b1412418286303a863228c0e61b',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 20:39:34','2026-02-15 20:39:33','2026-02-15 20:39:33',NULL,NULL),(35,1,'2b2cab3038a1c479c8fb21ff098b04c848de37b9bf585862e5b30171e1eb4144',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:00:11','2026-02-15 21:00:10','2026-02-15 21:00:10',NULL,NULL),(36,1,'9da4154770a8f65107e5feacfecd9ed5584b798425ae8016265712582202f93f',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:13:08','2026-02-15 21:13:08','2026-02-15 21:13:08',NULL,NULL),(37,27,'1a85b4d5be5bb10fe2e7ba9064bd4b3ab6a5ffccc579b3bc4e3e594ed742e811',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:16:01','2026-02-15 21:16:00','2026-02-15 21:16:00',NULL,NULL),(38,27,'498e0274d47ac2f634c1fbff4662c92fe286ebe42f8c396355dcd2855bf63bb1',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:16:01','2026-02-15 21:16:01','2026-02-15 21:16:01',NULL,NULL),(39,27,'4acd629880c18c140c4f5a47630a5339a72c2fb04fcdfefacc924db29b5076ad',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:16:33','2026-02-15 21:16:32','2026-02-15 21:16:32',NULL,NULL),(40,1,'1e0d34b1197e8830608d2efb0ce07f7cbfb558684ab299f62d18c9b2377a9a8a',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:25:30','2026-02-15 21:25:30','2026-02-15 21:25:30',NULL,NULL),(41,27,'50b0d1d8e42938297c47d7f5a311b0033185837833a767f467b55575936589e2',NULL,'web','172.21.0.1','curl/8.5.0',NULL,'2026-02-16 21:28:37','2026-02-15 21:28:36','2026-02-15 21:28:36',NULL,NULL),(42,10,'f5832df95e7786aafe55f70b6a51af77f446dabc226c3d383de9b64542bcae4f',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:30:02','2026-02-15 21:30:02','2026-02-15 21:30:02',NULL,NULL),(43,27,'a28f7dd766742f14254d656369077cef62154eec9a9f8c2663884c294cec0d4b',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:31:02','2026-02-15 21:31:02','2026-02-15 21:31:02',NULL,NULL),(44,10,'eae32aeec38e0b3642c72fbc996813201878e9838d1d32c36270e248a3e0abeb',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:31:02','2026-02-15 21:31:02','2026-02-15 21:31:02',NULL,NULL),(45,10,'eae32aeec38e0b3642c72fbc996813201878e9838d1d32c36270e248a3e0abeb',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 21:31:03','2026-02-15 21:31:02','2026-02-15 21:31:02',NULL,NULL),(46,1,'0b03cbe87f6481825eead50f09e5a15194604df927c3054aa297b3f9796a1bc7',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 21:43:19','2026-02-15 21:43:28','2026-02-15 21:43:19','2026-02-15 21:43:28','user_logout'),(47,34,'92a801ec2d133df3e24382afc47c2797c46c3cc1c59f5c4a2be5a20e39b887b9',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 21:43:34','2026-02-15 21:43:33','2026-02-15 21:43:33',NULL,NULL),(48,34,'a8ea8bec2b2470f694561dc7c777da47fd1cf8285fe19edf686a8e421ffe3418',NULL,'web','172.21.0.7','Python-urllib/3.12',NULL,'2026-02-16 22:21:16','2026-02-15 22:21:22','2026-02-15 22:21:15',NULL,NULL),(49,34,'ee8d3e2b16781e1cff9eba5085240e1df61c08728b977dee1cf7d4f5cc3120f7',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-16 22:21:24','2026-02-16 00:20:02','2026-02-15 22:21:24','2026-02-16 00:20:02','user_logout'),(50,1,'28de5a0fd5b13bff8d5b3ed595f7936c51a1624caea64b07a65231e5a0b376fb',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 23:02:21','2026-02-15 23:46:02','2026-02-15 23:02:21',NULL,NULL),(51,1,'2136f1ce9d48168239be0d2eea4d7a8ab6dbf489c7607cb0145415760597081c',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 23:44:34','2026-02-15 23:44:58','2026-02-15 23:44:33',NULL,NULL),(52,1,'898c6cc72b2c549f02c99ba3ff69abfa105b0436b0a850bf5f6680e0c4f5ae18',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-16 23:45:45','2026-02-15 23:45:45','2026-02-15 23:45:45',NULL,NULL),(53,1,'c26369aa357449934535ed6b5ba505f0393c0f48fd105d9e5e5fb97494851b61',NULL,'mobile','172.21.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-16 23:46:30','2026-02-15 23:46:43','2026-02-15 23:46:30',NULL,NULL),(54,1,'523b3cb98afe3ff10a5af7097cdc2c7ddf6c4888e69b97f687bd21653e1147c9',NULL,'mobile','172.21.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-16 23:48:12','2026-02-15 23:50:01','2026-02-15 23:48:11',NULL,NULL),(55,1,'78c04ab5b21837691bddfafe861475d8e15ee7a0d231190a5f95843a7011f0bf',NULL,'mobile','172.21.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-16 23:50:04','2026-02-15 23:58:03','2026-02-15 23:50:04',NULL,NULL),(56,1,'89f85a3a0d1b8a0a216ace73a01dfd3d8c4c8dd441f880640c72af2cbe029336',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:08:07','2026-02-16 00:08:25','2026-02-16 00:08:07',NULL,NULL),(57,1,'faca6f4273d22830a10c73c6111e78d496680bcbdec2b8b3ce45278891bd875c',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:08:31','2026-02-16 00:09:40','2026-02-16 00:08:31',NULL,NULL),(58,1,'4a514132fc87f6a31b097e162ba3df9d88183797b246d71ae863f6c0e54639ac',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:09:43','2026-02-16 00:10:24','2026-02-16 00:09:42',NULL,NULL),(59,1,'e1d079ecaa6ed3131586c4a726ceac0d8611d4fcfd230179b8d2800cd48326b2',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:10:27','2026-02-16 00:11:34','2026-02-16 00:10:27','2026-02-16 00:11:34','user_logout'),(60,34,'a79413db905b27f93fe09d220095bd56ab8ada96d3029b93d83a72bd20b918fd',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:12:22','2026-02-16 00:12:27','2026-02-16 00:12:21','2026-02-16 00:12:27','user_logout'),(61,26,'316e92c2b56b21adb79a2bdb5a629ea1587ea79a2bc91adcfc53e0e1b8e7bf08',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:12:44','2026-02-16 00:13:55','2026-02-16 00:12:44','2026-02-16 00:13:55','user_logout'),(62,1,'5612de12a480fa6260faa45e027899d44be7a2bf9ca1fa6afd9ea0a8ce6fa43d',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:14:02','2026-02-16 00:14:37','2026-02-16 00:14:01',NULL,NULL),(63,1,'4306ec5e40293c14fb663763563b7d38e482e46926d7d13978dcaccaccd3a414',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:14:42','2026-02-16 00:15:57','2026-02-16 00:14:42',NULL,NULL),(64,1,'95d6f9f02a100a7f40253cc0319160a2db524699155993660827995c820c4c6e',NULL,'web','172.21.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:16:00','2026-02-16 00:49:14','2026-02-16 00:16:00',NULL,NULL),(65,1,'c9fa1ecf1b4bdd424f3bb2aba2cd20df9171adf887cab80173605c4a3a7316d3',NULL,'web','172.20.0.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 00:20:08','2026-02-16 03:13:37','2026-02-16 00:20:07',NULL,NULL),(66,1,'1e5e7c250da3bb082df5908b21268f0223bf7dcd7b9bd2afc9f31dd7801e35c0',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 00:29:25','2026-02-16 05:12:39','2026-02-16 00:29:25',NULL,NULL),(67,1,'325adfe25e9a38c8afc954622c19eeef6806f8bfd17bfd9dfda4434e47a687c3',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:48:08','2026-02-16 00:48:07','2026-02-16 00:48:07',NULL,NULL),(68,1,'325adfe25e9a38c8afc954622c19eeef6806f8bfd17bfd9dfda4434e47a687c3',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:48:08','2026-02-16 00:48:07','2026-02-16 00:48:07',NULL,NULL),(69,1,'4d247d1c93eca15d722efee2e215411250f87fbbef1f7d61e000e58e05bccf27',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',NULL,'2026-02-17 00:49:19','2026-02-16 00:49:19','2026-02-16 00:49:19',NULL,NULL),(70,1,'5256203651eeb25fc935f9ff1dd60912fb9f370a9f30c1d8c31c7a2d48076c59',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 00:52:42','2026-02-16 02:56:28','2026-02-16 00:52:42',NULL,NULL),(71,19,'ab01395cd1bde0dac21a8a2277e854f75d79fba5650501b5b88614c8021a445c',NULL,'mobile','172.20.0.11','Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1',NULL,'2026-02-17 00:54:19','2026-02-16 00:54:19','2026-02-16 00:54:19',NULL,NULL),(72,1,'ca1d2c003c977de49f9c6392c4c53c4fc22ee39e56534bfc975e990eec3b15b6',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 00:54:34','2026-02-16 00:54:34','2026-02-16 00:54:34',NULL,NULL),(73,1,'ca1d2c003c977de49f9c6392c4c53c4fc22ee39e56534bfc975e990eec3b15b6',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 00:54:34','2026-02-16 00:54:34','2026-02-16 00:54:34',NULL,NULL),(74,1,'2e3cfea3d231b21283e9bff6a20e81bbc07846fbfde2f54c7b442081bd4793f4',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 01:10:16','2026-02-16 01:10:16','2026-02-16 01:10:16',NULL,NULL),(75,1,'2e3cfea3d231b21283e9bff6a20e81bbc07846fbfde2f54c7b442081bd4793f4',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 01:10:16','2026-02-16 01:10:16','2026-02-16 01:10:16',NULL,NULL),(76,1,'c0412cf110be71ec1b746baa3d9fbaf0a59a7b976792baf63fcdbe41a7270935',NULL,'web','172.20.0.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 02:49:38','2026-02-16 02:53:00','2026-02-16 02:49:38',NULL,NULL),(77,1,'1110c8c32aa4321164f917353cc56fe41a630207b1bd43f11649aa509342d382',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 02:52:21','2026-02-16 02:52:21','2026-02-16 02:52:21',NULL,NULL),(78,1,'1110c8c32aa4321164f917353cc56fe41a630207b1bd43f11649aa509342d382',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 02:52:21','2026-02-16 02:52:21','2026-02-16 02:52:21',NULL,NULL),(79,1,'528354d9e95b7d4e10d2778f9c468d653084c587c0c1293859ad1e14d21834cd',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 02:56:36','2026-02-16 05:36:32','2026-02-16 02:56:36','2026-02-16 05:36:32','user_logout'),(80,1,'baac0987ad026010502b93565dc3175399363bd5c15f54038d77944dfe838065',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 03:13:26','2026-02-16 03:13:26','2026-02-16 03:13:26',NULL,NULL),(81,1,'baac0987ad026010502b93565dc3175399363bd5c15f54038d77944dfe838065',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 03:13:26','2026-02-16 03:13:26','2026-02-16 03:13:26',NULL,NULL),(82,1,'806db0575c59d7050ee5f4266a1a27dabfc3699d2ab7030febccee8e185a3321',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 03:13:40','2026-02-16 04:32:13','2026-02-16 03:13:40',NULL,NULL),(83,1,'755b7cb8a783971e87835e7851ff7b82d24879f0db29568a35c724cc25c9e80c',NULL,'web','172.20.0.7','Python-urllib/3.12',NULL,'2026-02-17 04:05:39','2026-02-16 04:05:38','2026-02-16 04:05:38',NULL,NULL),(84,1,'2a82676520c9c103f0f33bd2134a729e727c7cf3b3f6a5f434f999576d1b7785',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 04:32:16','2026-02-16 05:26:03','2026-02-16 04:32:15',NULL,NULL),(85,1,'e47827be90ce5427b871424fbcd8b9b4641fd1c9131b3df90cb8ca26c34a4440',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:32:58','2026-02-16 04:32:58','2026-02-16 04:32:58',NULL,NULL),(86,1,'a08d100eaf9a09273cce6a9bcffef984d3c7dc6baa30d84c73dda92ccf48ab3b',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:35:14','2026-02-16 04:35:13','2026-02-16 04:35:13',NULL,NULL),(87,1,'45b2475e57d9b486a214be8a2cc3a00a9547055097da0e2a827f5bbd1bad9741',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:37:06','2026-02-16 04:37:05','2026-02-16 04:37:05',NULL,NULL),(88,1,'784fb120a5df80456e5d8e0abda729d15abd6371ff39e849cdb888a0d5494896',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:52:35','2026-02-16 04:52:34','2026-02-16 04:52:34',NULL,NULL),(89,1,'604191d377654ecc450de5edb0b03ec96c4e57d7b37fc9a0dcab276df3187ffa',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:53:08','2026-02-16 04:53:07','2026-02-16 04:53:07',NULL,NULL),(90,1,'fbb78b7d428144709da2a6f89507fb0b4e35f42f7150cf1d16764f2ca146d308',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:56:03','2026-02-16 04:56:03','2026-02-16 04:56:03',NULL,NULL),(91,1,'a4283988214b07914e6b2326591008fc93110bdf028d21d7d91868be3f9d042c',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 04:58:21','2026-02-16 05:09:47','2026-02-16 04:58:21',NULL,NULL),(92,1,'8629a44c03f86862fff5cae91336ca6b28c36417b9bd65e1759411d11eecd982',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 04:58:44','2026-02-16 04:58:43','2026-02-16 04:58:43',NULL,NULL),(93,1,'1888698d2d938de6980c71d25176556a90a857aa908c628585e4c260a7be9e02',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:02:49','2026-02-16 05:02:49','2026-02-16 05:02:49',NULL,NULL),(94,1,'1ee5476070a60b2bfb7c8be5c23c5db60968325f5ab9064299b000f1d7b9a557',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:04:43','2026-02-16 05:04:43','2026-02-16 05:04:43',NULL,NULL),(95,1,'a83c6c493a4b620762e3a7131d78441a261e7b17851beb2b069e4e4aa3dba1f1',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:05:16','2026-02-16 05:05:15','2026-02-16 05:05:15',NULL,NULL),(96,1,'25ffd1b1379a8cd1bff04e818690d3bad5ed3932624a08de143bb8d67ebdd6c9',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:08:16','2026-02-16 05:08:16','2026-02-16 05:08:16',NULL,NULL),(97,1,'cd558a560fef413e9b9b045f3ba24a88145e64a5889dfdb7e8f8d2949f06c370',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 05:09:50','2026-02-16 05:54:57','2026-02-16 05:09:50',NULL,NULL),(98,1,'d6a38e8b854c789a52d5b503accf7741dd5ad9ceef6525c4f256143d323cc855',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:09:56','2026-02-16 05:09:55','2026-02-16 05:09:55',NULL,NULL),(99,1,'b4cd479adf768da21adb22e4ed17b4371fdd8aaf076bcf6b545e67224486e5cb',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:10:59','2026-02-16 05:10:58','2026-02-16 05:10:58',NULL,NULL),(100,1,'80765788472eb8b29b152b79592cf41e7ef194c5e8e91e83d1c23025bd4fadac',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:12:42','2026-02-16 05:12:42','2026-02-16 05:12:42',NULL,NULL),(101,1,'87004e96c1a2c55a5c1a7ebb78338e7a866df243aa65237a60368cf2f147c7b2',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:14:47','2026-02-16 05:14:47','2026-02-16 05:14:47',NULL,NULL),(102,1,'65f786e5917de2d899094123319b0f0021b83d0cf862db8f771862c9da0ddc7e',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:25:48','2026-02-16 05:25:48','2026-02-16 05:25:48',NULL,NULL),(103,1,'a8881b794bed27bc3bd8134f67578ec971b37d884c7442063893654b1b13c0de',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:26:06','2026-02-16 05:53:58','2026-02-16 05:26:06',NULL,NULL),(104,1,'a95bbc5398411302ae4e7491cd2a82b3e6fe9903553c98be292a42054e55f69a',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:27:38','2026-02-16 05:27:38','2026-02-16 05:27:38',NULL,NULL),(105,1,'02c7d75cdbe0672bfebb4f15529c1960b1542eeb56a9548b98d8d8f9f6d61632',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:30:22','2026-02-16 05:30:22','2026-02-16 05:30:22',NULL,NULL),(106,1,'57bdc5992433adc1dfc4e7459af1fe486451c786428bb1cf529930a1a1bf200b',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:32:23','2026-02-16 05:32:23','2026-02-16 05:32:23',NULL,NULL),(107,1,'1cacb25c2e33f0f079f2a6cf83ac6a609bfa1c9bfe8fff54f9dce457bd111f63',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:34:56','2026-02-16 05:34:56','2026-02-16 05:34:56',NULL,NULL),(108,1,'fe784c07696bb437b11e4ca400e7dbf56cf17f1b62d5291f22f4c47aa7196392',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:36:05','2026-02-16 05:36:04','2026-02-16 05:36:04',NULL,NULL),(109,1,'31495bf828e5b1d09f11bbeffc047163de04a1138052125a91d5aa45aee24e47',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 05:37:58','2026-02-16 06:10:17','2026-02-16 05:37:58',NULL,NULL),(110,1,'a552b1ce4c174af83dc13edc0572197a38b66d5cf5a4417bab593d85a242b891',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:41:10','2026-02-16 05:41:09','2026-02-16 05:41:09',NULL,NULL),(111,1,'fdeb52a8fa37e962232681cfe35953e888fd322d10d878cf24b5a31a73cd2670',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:54:01','2026-02-16 05:58:21','2026-02-16 05:54:01',NULL,NULL),(112,1,'f19711169e8cd4a01f08a8fde9048adfbb2c8eddaf5bf581de1aeab86ed70bc6',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0',NULL,'2026-02-17 05:54:34','2026-02-16 05:54:33','2026-02-16 05:54:33',NULL,NULL),(113,1,'32a89e039ee1e45b58b90b75a3aeabdd55ce732069e55804da7947806ffe9228',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:55:29','2026-02-16 05:55:28','2026-02-16 05:55:28',NULL,NULL),(114,1,'a10e500ee23be9343242aeaa67606dab2a62a8667e5120208dcdf2c8211f0a20',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:56:31','2026-02-16 05:56:30','2026-02-16 05:56:30',NULL,NULL),(115,1,'7ea5c08e2e4f365a447b1c2f30634e5104a7a2d7168d83a89ef5155ceb4523d5',NULL,'web','172.20.0.2','python-httpx/0.28.1',NULL,'2026-02-17 05:57:40','2026-02-16 05:57:40','2026-02-16 05:57:40',NULL,NULL),(116,1,'c3077f6359a0bfdcf480303e56db20a7cc0dcfcc239b76770c9bca9ab34aa24d',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:58:23','2026-02-16 05:58:30','2026-02-16 05:58:23',NULL,NULL),(117,1,'c764fc334feeae3931b52ba22737086c5c52f90260c9800e10de809b90cff8e6',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:58:33','2026-02-16 05:58:38','2026-02-16 05:58:32',NULL,NULL),(118,1,'086c8ffc57129248606af712dab66eaf39eb316c7b33dc0f2342062c0314a952',NULL,'web','172.20.0.11','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',NULL,'2026-02-17 05:58:40','2026-02-16 05:58:45','2026-02-16 05:58:40',NULL,NULL),(119,1,'e22398f3a475defeeb2d76db3b6e92e6147e402fb9343d9232ea23ad750addeb',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 06:10:20','2026-02-16 11:52:34','2026-02-16 06:10:19',NULL,NULL),(120,1,'dfc3af00055be7105da44ec3b37e036a6ab6210429c92cff05106434978eda4b',NULL,'mobile','172.20.0.11','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Mobile Safari/537.36',NULL,'2026-02-17 11:52:37','2026-02-16 11:52:42','2026-02-16 11:52:36',NULL,NULL);
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tenant_requests`
--

DROP TABLE IF EXISTS `user_tenant_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tenant_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `tenant_id` int NOT NULL,
  `status` enum('pending','approved','rejected','cancelled') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `message` text COLLATE utf8mb4_unicode_ci,
  `response_message` text COLLATE utf8mb4_unicode_ci,
  `responded_by` int DEFAULT NULL,
  `responded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_user_tenant_requests_responder` (`responded_by`),
  KEY `idx_requests_user` (`user_id`),
  KEY `idx_requests_tenant` (`tenant_id`),
  KEY `idx_requests_status` (`status`),
  CONSTRAINT `fk_user_tenant_requests_responder` FOREIGN KEY (`responded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_tenant_requests_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_tenant_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tenant_requests`
--

LOCK TABLES `user_tenant_requests` WRITE;
/*!40000 ALTER TABLE `user_tenant_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_tenant_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tenants`
--

DROP TABLE IF EXISTS `user_tenants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tenants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `tenant_id` int NOT NULL,
  `role` enum('player','admin','manager','viewer') COLLATE utf8mb4_unicode_ci DEFAULT 'player',
  `is_active` tinyint(1) DEFAULT '1',
  `joined_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at` timestamp NULL DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_tenant` (`user_id`,`tenant_id`),
  KEY `fk_user_tenants_approver` (`approved_by`),
  KEY `idx_user_tenants_user` (`user_id`),
  KEY `idx_user_tenants_tenant` (`tenant_id`),
  KEY `idx_user_tenants_role` (`role`),
  KEY `idx_user_tenants_active` (`is_active`),
  CONSTRAINT `fk_user_tenants_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_tenants_tenant` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_tenants_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tenants`
--

LOCK TABLES `user_tenants` WRITE;
/*!40000 ALTER TABLE `user_tenants` DISABLE KEYS */;
INSERT INTO `user_tenants` VALUES (1,1,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(2,4,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(3,13,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(4,14,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(5,34,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(6,35,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(7,36,2,'admin',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(8,32,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(9,12,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(10,16,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(11,21,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(12,31,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(13,8,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(14,33,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(15,7,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(16,23,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(17,25,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(18,18,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(19,20,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(20,2,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(21,11,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(22,24,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(23,6,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(24,28,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(25,17,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(26,19,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(27,9,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(28,29,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(29,30,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(30,10,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(31,3,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(32,15,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(33,22,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(34,26,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(35,5,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(36,27,2,'player',1,'2026-02-15 08:41:33',NULL,NULL,NULL,NULL),(45,1,6,'admin',1,'2026-02-15 08:48:19',NULL,NULL,NULL,NULL),(46,1,4,'player',1,'2026-02-15 09:09:14',NULL,NULL,NULL,NULL),(47,1,5,'player',1,'2026-02-15 16:17:06',NULL,NULL,NULL,NULL),(48,26,6,'player',1,'2026-02-15 19:48:43',NULL,NULL,NULL,NULL),(49,34,6,'player',1,'2026-02-15 22:21:30',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `user_tenants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `user_tenants_full`
--

DROP TABLE IF EXISTS `user_tenants_full`;
/*!50001 DROP VIEW IF EXISTS `user_tenants_full`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_tenants_full` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `tenant_id`,
 1 AS `role`,
 1 AS `is_active`,
 1 AS `joined_at`,
 1 AS `user_name`,
 1 AS `user_email`,
 1 AS `user_avatar`,
 1 AS `tenant_slug`,
 1 AS `tenant_name`,
 1 AS `tenant_logo`,
 1 AS `tenant_color`,
 1 AS `system_slug`,
 1 AS `system_name`,
 1 AS `system_icon`,
 1 AS `system_color`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nickname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cpf` varchar(14) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cnpj` varchar(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `cep` varchar(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logradouro` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bairro` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `complemento` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timezone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'America/Sao_Paulo',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `avatar_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `birth_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_blocked` tinyint(1) DEFAULT '0',
  `blocked_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_users_email` (`email`),
  KEY `idx_users_phone` (`phone`),
  KEY `idx_users_active` (`is_active`),
  KEY `idx_users_nickname` (`nickname`),
  KEY `idx_users_cpf` (`cpf`),
  KEY `idx_users_city` (`city`),
  KEY `idx_users_state` (`state`),
  KEY `idx_users_cnpj` (`cnpj`),
  KEY `idx_users_cep` (`cep`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Radael Ivan da Silva Insfran','RadaHell','radaelivan@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','scrypt:32768:8:1$CY2BMAGiFcCpT3yt$aaf37467fdb0353c4adc426fd361d8f5ff006e0be34d0a0d16cbbc65833bf01a61648e4778884c842f4d1c58aee1825bee22e318daf0b3a6c4721173e5cb9df3','2026-02-15 08:41:33',NULL,NULL,NULL,1,0,NULL,'2026-02-16 11:52:36','2026-02-15 08:41:33','2026-02-16 11:52:36'),(2,'Matheus Figueiredo','Leo Figueira','figueiredomatheus397@gmail.com','11999998888',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','7c4b15dbb37296016e4372f656544f53b4aa91aced8004286fbdd580f27a9fb0',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(3,'Matheus Cunha Flores Monteiro','El cucunha','mrmatheuscunha@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','4f02b59f56967a5673568134b393603f8c0f05ad9b808612ef696810cd6c5831',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(4,'EZEQUIAS DA SILVA CORREA FILHO','Mesut Kilo','ezequiascorrea660@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','351f561c06aae3bc8b35b624bc1be7355bfda5365f589349dd7c4b00f50e73ca',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(5,'Marcos Poquiviqui Santana','Poke','vikpoke666@gmail.com','65996822631',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','9d95abe2bdaec09af0150943c523395d2b58144e7465bceb3ef0a3d9087fd3ce',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(6,'Rodrigo Leon','Rodrigol','goncalvesalencar@hotmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','29148362cdba65a1d0d708d804dac2fb155d91deae5e25e27befb2462651f933',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(7,'Felipe Eduardo da Silva Campos','Buzz','drackaru@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','4c3c0d4d97995565e7886106e50777f86fb1bcbe108113258cfde1821af3af61',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(8,'Guilherme Coelho Soares','Gui Negão','coelhovrf@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','4669a4ed13a8d79b7aafec8441f8fa07bd04189f5dc13c752b05a0743edf002b',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(9,'Luciano Lopes','Lulu Depay','lopez.luciano9522@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','cb32e3c72fe3d100f250a523b6e5792d58558ad2619709672902e2806d3cf319',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(10,'Michael Douglas','D\'Michael','mayconreua@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','scrypt:32768:8:1$b12RQ2ROrioiQKw7$44eb1ce6b71cc2b2a4902b1c61dd5aa436ceb381d55e7e96612d292d661aee2e336460f972029e6a9e2d58af6a07289019cf8a8364418de3d5e24e6efbbab00b',NULL,NULL,NULL,NULL,1,0,NULL,'2026-02-15 21:31:02','2026-02-15 08:41:33','2026-02-15 21:31:02'),(11,'Gabriel Rossi Soares','Messi','gabisrossi2002@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','cc70ae3c4a57e60b416298d354c5e858f1b5fb496d7259ab550040f541babd12',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(12,'Gabriel Almeida de Oliveira','Paolo Almeidini','almeida270415@gmail.com','67999575709',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','8aa1f7d6708dc6952378ddf13233732452220b074e96855d80dc7c6a61b48809',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(13,'Lothar Mateus','Big','lothar.mateussc@hotmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','570fe300347afb4d8733085ef269510663c621997cb55727009e5d57097eb6a9',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(14,'Victor Moraes Miranda','Vitão','mirandarotvic123@gmail.com','67999399865',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','7dd128fd4ee0eb87eb673004d13729cb42393b0a24d4c89cad740e37cd2cc3ab',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(15,'Gabriel Januario Garcia Martins','Januba','paudaplaca7@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(16,'BRUNO ARIEL DINIZ DA SILVA','BRUNERA','bdiniiz22@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','759ee9a0b08e68056acab72e17f683dfc86eb6058811768c5ae634d1341adc10',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(17,'Joaquim Clink Ribeiro','Estevão','joaquimclinkribeiro@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','c06f94cf82d8af1504e29c8388f861bed8d31607368033f3a8ac7407cb03cbe4',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(18,'Matheus Guilherme Durães Fernandes','Gui neguinho','fernandesfernandes@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','100cfe02981c0d376d7495328d3f09b8138e49c9b4d8fd423b29b0576527b27e',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(19,'Luan Cassaro','Sanfoneiro','lcassaro2015@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','scrypt:32768:8:1$tFczQlg9ubsP6bRd$dea8ce303fba0da5de047572e9d48f1682249e7f8cb5c0b6e7917c112c402e9f7753b070231bd38403cdbc7f2e561d46b54566439ded62c18e787395df8e102e',NULL,NULL,NULL,NULL,1,0,NULL,'2026-02-16 00:54:19','2026-02-15 08:41:33','2026-02-16 00:54:19'),(20,'Matheus Guilherme Durães Fernandes','Guizinho negãozinho','fernandesfernandes1377@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','38520d9e60b235d7888b4ed11d826374c8c25141dbd6b399ce941a8168e6533f',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(21,'Bruno Marinho Maciel','Brunou14','brunomarinhomaciel17@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','33a5dc2f4c65ed3f7155af1f9e15b30e2ff796433392a348275f579222d0a677',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(22,'Caio Cezar Braga Bressan','Caio','redentorms@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','bc2aa7b2ee575486ce3f62f608a50906338f74781c26e93985059dd356275274',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(23,'Nathan Vinícius Ferreira Diniz','Tanan','dzferreira20@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','eb85ee14444d3fa47ab683357ab798e64b00a1904054d7d9de621255709ed11a',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(24,'Renato Gonçalves Martins','Comi o de cima 🤣','gauduny@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','e0094a0be48566f27c7cde203c23db2acbcfa6928754473da84013129b6a1c6d',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(25,'elinson','Elinson','elinson@copa.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','e1fcc111063e7ac9b49c116ab3e13f92af264f2e928131e181b0c5a0dd5e7811',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(26,'teste','teste','teste@copa.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','scrypt:32768:8:1$eyxmnB43v6lOFChQ$35745915c38cbfbbd66349a9455b9ad613152b57c68829dd5d526363b54f14f4bd65e227f86d0f8f61e5caa4c23a81d9aea86cf359f4732766e0a5ab205b7c29',NULL,NULL,NULL,NULL,1,0,NULL,'2026-02-16 00:12:44','2026-02-15 08:41:33','2026-02-16 00:12:44'),(27,'Welyton Jhonny','Muro','Welyton@copa.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','scrypt:32768:8:1$mq9oGk6e8wAB4QOE$3c5c52d497bc376d692479d0454721ce27c0e6644c943aab84fdabc2c5760b8c2e2cac1d8e3edc2e9150cedb89cb8ef03e3759479107a210f7854a09dd25918c',NULL,NULL,NULL,NULL,1,0,NULL,'2026-02-15 21:31:02','2026-02-15 08:41:33','2026-02-15 21:31:02'),(28,'João Vitor Ferreira','TotinRabando','joao261099vitor@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','d72c49f413f5c84a5bb2473642cb77e4d5149b0ea51f7cea4178eb04e9662434',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(29,'Lucas de Graauw Zimpel','Lucas','lucasgraauw14@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','5de1c10ed9b3d47e71ea438772bbed66fa0369f93bdf3b4d7cd72ff656f26fc9',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(30,'Marcos Vinicius','McQueen','marcosalved@hotmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','fe673a701b4d3d227f977cefd8ee13898e4aedab3d68a8d3c83cef0d7480df6a',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(31,'Mateus Augusto Colman Cheung','Cheung','cheungmateus@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','1ddc8ecf2b0f01583e8a7e73924bfa85a79a678cbd824eb605d7d1d25484f7f8',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(32,'Lucas Abdiel Vargas Martines','Lucas m','abdiel.lucaseliane@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','07b8c37d1e2d5ef39e952cb84b577ca9ce68edc11a3d1d174d738ffcd30745f7',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(33,'Diego Massanori','Massanori','dmot0896@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','add7fcf9a46d6817b7bea912a3cd7b88ac3c3292272df407714e8d19be14e38a',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(34,'Substituto 1','Substituto 1','substituto1@copaaposentado.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','scrypt:32768:8:1$lEv7hmBwhdh05TBy$1e3099aed1ba79c1573ffb9a3a1bf7a703443486a8dee6e40a11d9bd7f4abb73d57a2a2c0b521842d7baa5186a321c942b0599cbbb293f1badabaedc9506f1b7',NULL,NULL,NULL,NULL,1,0,NULL,'2026-02-16 00:12:21','2026-02-15 08:41:33','2026-02-16 00:12:21'),(35,'Substituto 2','Substituto 2','subistituto2@copaaposentados.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','84191740edd95203389cc6c0f87a2b3ffcfc587ea47b87b50c5e9ed1e88f7a20',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01'),(36,'Substituto 3','Substituto 3','subistituto3@dopaaposentados.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'America/Sao_Paulo','e4782fff20fac2a3902a4e0d94d5cb99c28e7dc77bd6be101e9ba008518a9f1e',NULL,NULL,NULL,NULL,1,0,NULL,NULL,'2026-02-15 08:41:33','2026-02-15 21:27:01');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `available_tenants`
--

/*!50001 DROP VIEW IF EXISTS `available_tenants`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `available_tenants` AS select `t`.`id` AS `id`,`t`.`slug` AS `slug`,`t`.`display_name` AS `display_name`,`t`.`logo_url` AS `logo_url`,`t`.`primary_color` AS `primary_color`,`t`.`welcome_message` AS `welcome_message`,`t`.`allow_registration` AS `allow_registration`,`s`.`slug` AS `system_slug`,`s`.`display_name` AS `system_name`,`s`.`icon` AS `system_icon`,`s`.`color` AS `system_color`,(select count(0) from `user_tenants` `ut` where ((`ut`.`tenant_id` = `t`.`id`) and (`ut`.`is_active` = true))) AS `member_count` from (`tenants` `t` join `systems` `s` on((`t`.`system_id` = `s`.`id`))) where ((`t`.`is_active` = true) and (`t`.`maintenance_mode` = false)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `systems_overview`
--

/*!50001 DROP VIEW IF EXISTS `systems_overview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `systems_overview` AS select `s`.`id` AS `id`,`s`.`slug` AS `slug`,`s`.`display_name` AS `display_name`,`s`.`icon` AS `icon`,`s`.`color` AS `color`,`s`.`is_active` AS `is_active`,count(`t`.`id`) AS `total_tenants`,sum((case when (`t`.`is_active` = true) then 1 else 0 end)) AS `active_tenants` from (`systems` `s` left join `tenants` `t` on((`s`.`id` = `t`.`system_id`))) group by `s`.`id` order by `s`.`display_order` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `tenants_full`
--

/*!50001 DROP VIEW IF EXISTS `tenants_full`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `tenants_full` AS select `t`.`id` AS `id`,`t`.`slug` AS `slug`,`t`.`display_name` AS `display_name`,`t`.`database_name` AS `database_name`,`t`.`database_host` AS `database_host`,`t`.`primary_color` AS `primary_color`,`t`.`is_active` AS `is_active`,`t`.`maintenance_mode` AS `maintenance_mode`,`s`.`slug` AS `system_slug`,`s`.`display_name` AS `system_name`,`s`.`icon` AS `system_icon`,`s`.`color` AS `system_color` from (`tenants` `t` join `systems` `s` on((`t`.`system_id` = `s`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_tenants_full`
--

/*!50001 DROP VIEW IF EXISTS `user_tenants_full`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_tenants_full` AS select `ut`.`id` AS `id`,`ut`.`user_id` AS `user_id`,`ut`.`tenant_id` AS `tenant_id`,`ut`.`role` AS `role`,`ut`.`is_active` AS `is_active`,`ut`.`joined_at` AS `joined_at`,`u`.`name` AS `user_name`,`u`.`email` AS `user_email`,`u`.`avatar_url` AS `user_avatar`,`t`.`slug` AS `tenant_slug`,`t`.`display_name` AS `tenant_name`,`t`.`logo_url` AS `tenant_logo`,`t`.`primary_color` AS `tenant_color`,`s`.`slug` AS `system_slug`,`s`.`display_name` AS `system_name`,`s`.`icon` AS `system_icon`,`s`.`color` AS `system_color` from (((`user_tenants` `ut` join `users` `u` on((`ut`.`user_id` = `u`.`id`))) join `tenants` `t` on((`ut`.`tenant_id` = `t`.`id`))) join `systems` `s` on((`t`.`system_id` = `s`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-16 19:20:45
