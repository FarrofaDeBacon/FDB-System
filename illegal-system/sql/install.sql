-- Sistema de Ilegal — Instalação Completa do Banco de Dados
-- Rodar uma vez na base do servidor. CREATE TABLE IF NOT EXISTS => idempotente.

-- =========================================
-- TABELAS DE JOGADOR E HISTÓRICO
-- =========================================
CREATE TABLE IF NOT EXISTS `player_criminal` (
    `citizenid`  VARCHAR(50) NOT NULL,
    `xp`         INT NOT NULL DEFAULT 0,
    `heat`       INT NOT NULL DEFAULT 0,
    `reputation` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crime_history` (
    `id`           INT NOT NULL AUTO_INCREMENT,
    `citizenid`    VARCHAR(50) NOT NULL,
    `crime_id`     VARCHAR(50) NOT NULL,
    `success`      TINYINT(1) NOT NULL DEFAULT 0,
    `reward_type`  VARCHAR(10) NOT NULL DEFAULT 'item',
    `reward_value` VARCHAR(255) NOT NULL DEFAULT '',
    `witness`      TINYINT(1) NOT NULL DEFAULT 0,
    `evidence`     TINYINT(1) NOT NULL DEFAULT 0,
    `created_at`   DATETIME NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_crime_history_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================
-- TABELAS DE CONTROLE DE COOLDOWN (PERSISTENTE)
-- =========================================
CREATE TABLE IF NOT EXISTS `illegal_grave_state` (
    `grave_id` VARCHAR(64) PRIMARY KEY,
    `last_robbed_at` DATETIME NOT NULL,
    `next_available_at` DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `robbed_stores` (
    `store_name` VARCHAR(100) PRIMARY KEY,
    `last_robbed_at` DATETIME NOT NULL,
    `next_available_at` DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================
-- TABELAS DO EDITOR DE LOJAS
-- =========================================
-- Removemos as tabelas antigas para forçar a criação com as colunas novas
DROP TABLE IF EXISTS `illegal_store_risk_spawns`;
DROP TABLE IF EXISTS `illegal_spawns`;
DROP TABLE IF EXISTS `illegal_stores`;

CREATE TABLE IF NOT EXISTS `illegal_stores` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(64) NOT NULL UNIQUE,
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `door_x` FLOAT, `door_y` FLOAT, `door_z` FLOAT,
    `register_x` FLOAT, `register_y` FLOAT, `register_z` FLOAT, `register_heading` FLOAT,
    `active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `illegal_store_risk_spawns` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `type` ENUM('dog', 'guard') NOT NULL,
    `x` FLOAT NOT NULL, `y` FLOAT NOT NULL, `z` FLOAT NOT NULL, `heading` FLOAT,
    `reaction` VARCHAR(50) DEFAULT 'combat',
    FOREIGN KEY (`store_id`) REFERENCES `illegal_stores`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================
-- INSERÇÕES PADRÃO DE DADOS (Valentine)
-- =========================================
INSERT IGNORE INTO `illegal_stores` (name, coords_x, coords_y, coords_z, door_x, door_y, door_z, register_x, register_y, register_z, register_heading)
VALUES
('Valentine General Store', -322.25, 804.05, 117.93, -319.70, 796.53, 116.94, -323.5, 804.5, 117.93, 0),
('Valentine Gunsmith', -278.43, 775.12, 119.52, -276.5, 774.5, 119.52, -280.1812, 778.8729, 119.5040, 301.1332),
('Valentine Doctor', -245.92, 781.08, 118.47, -247.5, 781.5, 118.47, -288.2099, 805.1098, 119.3859, 358.5668);

INSERT IGNORE INTO `illegal_store_risk_spawns` (store_id, type, x, y, z, heading)
SELECT id, 'dog', -315.0, 800.0, 118.0, 90.0 FROM `illegal_stores` WHERE name = 'Valentine General Store';

INSERT IGNORE INTO `illegal_store_risk_spawns` (store_id, type, x, y, z, heading)
SELECT id, 'guard', -318.0, 802.0, 118.0, 0.0 FROM `illegal_stores` WHERE name = 'Valentine General Store';

INSERT IGNORE INTO `illegal_store_risk_spawns` (store_id, type, x, y, z, heading)
SELECT id, 'guard', -316.0, 805.0, 118.0, 45.0 FROM `illegal_stores` WHERE name = 'Valentine General Store';

INSERT IGNORE INTO `illegal_store_risk_spawns` (store_id, type, x, y, z, heading)
SELECT id, 'guard', -314.0, 798.0, 118.0, 90.0 FROM `illegal_stores` WHERE name = 'Valentine General Store';
