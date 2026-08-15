-- Migration 003: Adiciona tabela de estado persistente para cooldown de roubo de lojas.
-- Usada para manter as lojas roubadas em cooldown mesmo após restart do servidor.
--
-- Idempotente: CREATE TABLE IF NOT EXISTS.
-- Rodar uma vez no banco do servidor.

CREATE TABLE IF NOT EXISTS `robbed_stores` (
    `store_name` VARCHAR(100) PRIMARY KEY,
    `last_robbed_at` DATETIME NOT NULL,
    `next_available_at` DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
