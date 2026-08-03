-- Migration 002: Add player inventory metadata indices
-- Author: Antigravity / FDB-System

ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_cid` (`cid`);
ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_name` (`name`);
