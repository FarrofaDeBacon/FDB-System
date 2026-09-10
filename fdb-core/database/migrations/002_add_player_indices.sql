-- Migration 002: Add player composite character slot index
-- Author: Antigravity / FDB-System

-- Index composite lookup (citizenid, cid)
-- Optimizes queries filtering player character slot (cid) belonging to specific player identifier (citizenid).
ALTER TABLE `players` ADD INDEX IF NOT EXISTS `idx_players_citizenid_cid` (`citizenid`, `cid`);
