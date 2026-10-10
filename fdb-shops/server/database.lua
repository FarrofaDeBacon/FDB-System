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

    -- Garante que os templates básicos existam para integridade de chaves estrangeiras
    local baseTemplates = {
        { id = 'normal', label = 'Armazém Geral' },
        { id = 'general', label = 'Armazém Geral' },
        { id = 'weapons', label = 'Armeiro' },
        { id = 'saloon', label = 'Saloon' },
        { id = 'armoury', label = 'Arsenal Policial' },
        { id = 'medic', label = 'Farmácia' },
        { id = 'prison', label = 'Cantina Prisional' }
    }
    for _, t in ipairs(baseTemplates) do
        pcall(function()
            MySQL.insert.await([[
                INSERT INTO shop_templates (template_id, label, sellable_items, default_config)
                VALUES (?, ?, '[]', '{}')
                ON DUPLICATE KEY UPDATE label = VALUES(label)
            ]], { t.id, t.label })
        end)
    end

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
            city VARCHAR(50) DEFAULT 'outros',
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

    -- Migration idempotente para coluna city na tabela shops
    local hasCity = MySQL.scalar.await("SHOW COLUMNS FROM `shops` LIKE 'city'")
    if not hasCity then
        MySQL.query.await("ALTER TABLE `shops` ADD COLUMN `city` VARCHAR(50) DEFAULT 'outros' AFTER `region_id`")
        MySQL.query.await("UPDATE `shops` SET `city` = 'outros' WHERE `city` IS NULL")
        print('^2[' .. resourceName .. '] Migration: Column `city` added to `shops`.^7')
    end

    local hasStockMode = MySQL.scalar.await("SHOW COLUMNS FROM `shops` LIKE 'stock_mode'")
    if not hasStockMode then
        MySQL.query.await("ALTER TABLE `shops` ADD COLUMN `stock_mode` VARCHAR(20) DEFAULT 'infinite'")
        MySQL.query.await("UPDATE `shops` SET `stock_mode` = 'physical' WHERE `owner_id` IS NOT NULL AND `owner_id` != ''")
        print('^2[' .. resourceName .. '] Migrations for stock_mode applied.^7')
    end

    -- Itens do catálogo de cada loja (preço e ativação específicos por loja)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS shop_catalog_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id VARCHAR(50) NOT NULL,
            item_name VARCHAR(100) NOT NULL,
            price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
            is_active TINYINT(1) NOT NULL DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uq_shop_item (shop_id, item_name),
            FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Migration: Se shop_catalog_items estiver vazio, popula a partir de shops.buy_catalog
    local catalogCount = MySQL.scalar.await("SELECT COUNT(*) FROM shop_catalog_items")
    if catalogCount == 0 then
        local existingShops = MySQL.query.await("SELECT shop_id, buy_catalog FROM shops WHERE buy_catalog IS NOT NULL")
        if existingShops then
            for _, s in ipairs(existingShops) do
                local buyCat = json.decode(s.buy_catalog)
                if buyCat and type(buyCat) == 'table' then
                    for _, item in ipairs(buyCat) do
                        if item.name then
                            pcall(function()
                                MySQL.insert.await("INSERT IGNORE INTO shop_catalog_items (shop_id, item_name, price, is_active) VALUES (?, ?, ?, 1)", {
                                    s.shop_id, item.name, tonumber(item.price) or 0.0
                                })
                            end)
                        end
                    end
                end
            end
            print('^2[' .. resourceName .. '] Migration: Seeded shop_catalog_items from existing shops.buy_catalog.^7')
        end
    end

    -- Migration idempotente para colunas de cargos e serviço em shop_employees
    local empCols = {
        { name = 'grade_level', sql = "ALTER TABLE `shop_employees` ADD COLUMN `grade_level` INT DEFAULT 1 AFTER `player_id`" },
        { name = 'role_name',   sql = "ALTER TABLE `shop_employees` ADD COLUMN `role_name` VARCHAR(50) DEFAULT 'Auxiliar' AFTER `grade_level`" },
        { name = 'is_duty',     sql = "ALTER TABLE `shop_employees` ADD COLUMN `is_duty` TINYINT(1) DEFAULT 0 AFTER `role_name`" }
    }
    for _, col in ipairs(empCols) do
        local exists = MySQL.scalar.await("SHOW COLUMNS FROM `shop_employees` LIKE ?", { col.name })
        if not exists then
            local success, err = pcall(function()
                MySQL.query.await(col.sql)
            end)
            if success then
                print('^2[' .. resourceName .. '] Migration: Column `' .. col.name .. '` added to shop_employees.^7')
            else
                print('^1[' .. resourceName .. '] Migration Error adding `' .. col.name .. '` to shop_employees: ' .. tostring(err) .. '^7')
            end
        end
    end

    -- Migration idempotente para detalhes em shop_transactions
    local txCols = {
        { name = 'buyer_name',     sql = "ALTER TABLE `shop_transactions` ADD COLUMN `buyer_name` VARCHAR(100) DEFAULT NULL AFTER `region_id`" },
        { name = 'payment_method', sql = "ALTER TABLE `shop_transactions` ADD COLUMN `payment_method` VARCHAR(50) DEFAULT 'cash' AFTER `buyer_name`" },
        { name = 'metadata',       sql = "ALTER TABLE `shop_transactions` ADD COLUMN `metadata` JSON DEFAULT NULL AFTER `payment_method`" }
    }
    pcall(function()
        MySQL.query.await("ALTER TABLE `shop_transactions` MODIFY `transaction_type` VARCHAR(50) NOT NULL")
    end)
    for _, col in ipairs(txCols) do
        local exists = MySQL.scalar.await("SHOW COLUMNS FROM `shop_transactions` LIKE ?", { col.name })
        if not exists then
            local success, err = pcall(function()
                MySQL.query.await(col.sql)
            end)
            if success then
                print('^2[' .. resourceName .. '] Migration: Column `' .. col.name .. '` added to shop_transactions.^7')
            else
                print('^1[' .. resourceName .. '] Migration Error adding `' .. col.name .. '` to shop_transactions: ' .. tostring(err) .. '^7')
            end
        end
    end

    print('^2[' .. resourceName .. '] Database schema initialized.^7')
end)

Database = Database or {}

function Database.UpdateShopId(originalId, targetId)
    if not originalId or not targetId or originalId == targetId then return false, "Invalid IDs" end
    
    local queries = {
        { query = 'SET FOREIGN_KEY_CHECKS = 0' },
        { query = 'UPDATE shops SET shop_id = ? WHERE shop_id = ?', values = {targetId, originalId} },
        { query = 'UPDATE shop_stations SET shop_id = ? WHERE shop_id = ?', values = {targetId, originalId} },
        { query = 'UPDATE shop_employees SET shop_id = ? WHERE shop_id = ?', values = {targetId, originalId} },
        { query = 'UPDATE shop_catalog_items SET shop_id = ? WHERE shop_id = ?', values = {targetId, originalId} },
        { query = 'UPDATE shop_transactions SET shop_id = ? WHERE shop_id = ?', values = {targetId, originalId} },
        { query = 'UPDATE inventories SET identifier = ? WHERE identifier = ?', values = {'shop_stock_' .. targetId, 'shop_stock_' .. originalId} },
        { query = 'UPDATE inventories SET identifier = ? WHERE identifier = ?', values = {'shop_register_' .. targetId, 'shop_register_' .. originalId} },
        { query = 'SET FOREIGN_KEY_CHECKS = 1' }
    }
    
    local success = MySQL.transaction.await(queries)
    if not success then
        print('^1[' .. resourceName .. '] Erro na transação ao atualizar shop_id no banco!^7')
        return false, "Transaction failed"
    end

    -- Invalida cache de inventário em memória se fdb-inventory estiver rodando
    pcall(function()
        if exports['fdb-inventory'] and exports['fdb-inventory'].DeleteInventory then
            exports['fdb-inventory']:DeleteInventory('shop_stock_' .. originalId)
            exports['fdb-inventory']:DeleteInventory('shop_register_' .. originalId)
        end
    end)
    
    return true
end

