-- ============================================================
-- FDB System | fdb-shops | server/database.lua
-- Schema initialization and data persistence
-- ============================================================

local resourceName = GetCurrentResourceName()

CreateThread(function()
    Wait(1500) -- Aguarda conexão com o banco

    -- Templates são o "tipo de negócio" (armaria, ferraria, saloon...)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS shop_templates (
            template_id VARCHAR(50) PRIMARY KEY,
            label VARCHAR(100) NOT NULL,
            craftable_recipes JSON,
            sellable_items JSON,
            default_config JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Instância de uma loja
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS shops (
            shop_id VARCHAR(50) PRIMARY KEY,
            template_id VARCHAR(50) NOT NULL,
            label VARCHAR(100) NOT NULL,
            owner_id VARCHAR(50),
            enabled_recipes JSON,
            enabled_sell_items JSON,
            buy_catalog JSON,
            sell_catalog JSON,
            cash_balance FLOAT DEFAULT 0,
            owner_price_variation FLOAT DEFAULT 0.0,
            max_price_variation FLOAT DEFAULT 0.15,
            region_id VARCHAR(50),
            config JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (template_id) REFERENCES shop_templates(template_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Funcionários
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS shop_employees (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id VARCHAR(50) NOT NULL,
            player_id VARCHAR(50) NOT NULL,
            perm_atender TINYINT(1) DEFAULT 0,
            perm_repor_estoque TINYINT(1) DEFAULT 0,
            perm_craftar TINYINT(1) DEFAULT 0,
            perm_financeiro TINYINT(1) DEFAULT 0,
            perm_editar_precos TINYINT(1) DEFAULT 0,
            perm_gerenciar_funcionarios TINYINT(1) DEFAULT 0,
            hired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY shop_player (shop_id, player_id),
            FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Estações físicas (registradora, baú, craft, venda, npc)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS shop_stations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id VARCHAR(50) NOT NULL,
            type ENUM('registradora', 'bau', 'craft', 'venda', 'npc', 'supply_board', 'admin_panel') NOT NULL,
            position JSON NOT NULL,
            allowed_recipes JSON,
            prop_model VARCHAR(100),
            animation_dict VARCHAR(100),
            animation_name VARCHAR(100),
            npc_model VARCHAR(100),
            npc_heading FLOAT,
            spawn_condition ENUM('always', 'onlyIfHasOwner', 'onlyIfNoOwner') DEFAULT 'always',
            hide_when_owner_present TINYINT(1) DEFAULT 0,
            hide_radius FLOAT DEFAULT 50.0,
            fallback_npc JSON,
            config JSON,
            metadata JSON DEFAULT NULL,
            label VARCHAR(50) DEFAULT NULL,
            FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Log de transações da loja
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS shop_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id VARCHAR(50) NOT NULL,
            player_id VARCHAR(50) NOT NULL,
            transaction_type ENUM('buy', 'sell', 'craft', 'supply_delivery', 'salary', 'deposit', 'withdraw') NOT NULL,
            item_name VARCHAR(100),
            quantity INT,
            unit_price FLOAT,
            total_price FLOAT,
            region_id VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX(shop_id),
            INDEX(region_id),
            INDEX(created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Migrations para Business System
    local hasMetadata = MySQL.scalar.await("SHOW COLUMNS FROM `shop_stations` LIKE 'metadata'")
    if not hasMetadata then
        MySQL.query.await("ALTER TABLE `shop_stations` MODIFY `type` ENUM('registradora', 'bau', 'craft', 'venda', 'npc', 'supply_board', 'admin_panel') NOT NULL")
        MySQL.query.await("ALTER TABLE `shop_stations` ADD COLUMN `metadata` JSON DEFAULT NULL")
        MySQL.query.await("ALTER TABLE `shop_stations` ADD COLUMN `label` VARCHAR(50) DEFAULT NULL")
        MySQL.query.await("UPDATE `shop_stations` SET `label` = CONCAT(`type`, ' ', `id`) WHERE `label` IS NULL")
        print('^2[' .. resourceName .. '] Migrations for Business System applied.^7')
    end

    print('^2[' .. resourceName .. '] Database schema initialized.^7')
end)
