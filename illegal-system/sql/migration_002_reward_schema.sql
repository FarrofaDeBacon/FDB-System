-- Migration 002: Corrige schema da coluna reward em crime_history.
-- Antes: reward INT NOT NULL DEFAULT 0 (recebia strings de nomes de item, tipo errado)
-- Depois: reward_type VARCHAR(10) + reward_value VARCHAR(255) (suporta item e cash)
--
-- Idempotente: usa IF NOT EXISTS para a coluna nova e só dropa a antiga se existir.
-- Rodar uma vez no banco do servidor.

-- Passo 1: Adiciona coluna reward_type se não existir
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'crime_history' AND column_name = 'reward_type');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE crime_history ADD COLUMN reward_type VARCHAR(10) NOT NULL DEFAULT \'item\' AFTER success', 
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Passo 2: Converte a coluna reward (INT) para reward_value (VARCHAR)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'crime_history' AND column_name = 'reward');
SET @col_new_exists = (SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'crime_history' AND column_name = 'reward_value');
SET @sql = IF(@col_exists > 0 AND @col_new_exists = 0, 
    'ALTER TABLE crime_history CHANGE COLUMN reward reward_value VARCHAR(255) NOT NULL DEFAULT \'\'', 
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
