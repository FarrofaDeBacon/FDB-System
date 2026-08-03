-- Migration 001: Initial schema migrations table & player indices
-- Author: Antigravity / FDB-System

CREATE TABLE IF NOT EXISTS `schema_migrations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `version` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(255) NOT NULL,
    `executed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add performance indexes for high-frequency player lookups
ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_citizenid` (`citizenid`);
ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_license` (`license`);
