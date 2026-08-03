-- Migration 002: Add player character slot index
-- Author: Antigravity / FDB-System

-- Index character slot (cid) and citizenid composite lookup
-- Note: 'citizenid' is the Primary Key of 'players' table; 'cid' identifies character slot number.
ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_cid` (`cid`);
