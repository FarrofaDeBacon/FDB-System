-- Sistema de Ilegal — tabelas base (Etapa 1)
-- Rodar uma vez na base do cliente. CREATE TABLE IF NOT EXISTS => idempotente.

CREATE TABLE IF NOT EXISTS `player_criminal` (
    `citizenid`  VARCHAR(50) NOT NULL,
    `xp`         INT NOT NULL DEFAULT 0,
    `heat`       INT NOT NULL DEFAULT 0,
    `reputation` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crime_history` (
    `id`         INT NOT NULL AUTO_INCREMENT,
    `citizenid`  VARCHAR(50) NOT NULL,
    `crime_id`   VARCHAR(50) NOT NULL,
    `success`    TINYINT(1) NOT NULL DEFAULT 0,
    `reward`     INT NOT NULL DEFAULT 0,
    `witness`    TINYINT(1) NOT NULL DEFAULT 0,
    `evidence`   TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_crime_history_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
