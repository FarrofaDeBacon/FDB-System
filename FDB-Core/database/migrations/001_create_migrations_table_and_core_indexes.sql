-- Migration 001: Create schema_migrations table and core player indexes
-- Author: Antigravity / FDB-System

CREATE TABLE IF NOT EXISTS `schema_migrations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `version` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(255) NOT NULL,
    `executed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Core Lookup Indexes
-- Note: Requires MySQL 8.0.29+ / MariaDB 10.5.2+ for native 'IF NOT EXISTS' syntax.
ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_license` (`license`);
