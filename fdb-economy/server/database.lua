-- ============================================================
-- FDB System | fdb-economy | server/database.lua
-- Schema initialization and data persistence
-- ============================================================

local resourceName = GetCurrentResourceName()

CreateThread(function()
    Wait(1000) -- Aguarda conexão com o banco

    -- Tabela principal de economia regional
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS region_economy (
            region_id VARCHAR(50) PRIMARY KEY,
            base_rate FLOAT NOT NULL DEFAULT 1.0,
            category_modifiers JSON,
            min_rate FLOAT NOT NULL DEFAULT 0.5,
            max_rate FLOAT NOT NULL DEFAULT 2.0,
            volume_weight FLOAT NOT NULL DEFAULT 0.3,
            money_supply_weight FLOAT NOT NULL DEFAULT 0.2,
            recalc_interval_minutes INT NOT NULL DEFAULT 30,
            decay_toward_baseline FLOAT NOT NULL DEFAULT 0.05,
            transaction_volume INT DEFAULT 0,
            last_recalc TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Tabela de log de transações (alimenta o recálculo de volume)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS economy_transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            region_id VARCHAR(50) NOT NULL,
            shop_id VARCHAR(50),
            item_name VARCHAR(100),
            category VARCHAR(50),
            quantity INT NOT NULL DEFAULT 1,
            unit_price FLOAT NOT NULL,
            total_price FLOAT NOT NULL,
            transaction_type ENUM('buy', 'sell', 'craft', 'supply') NOT NULL DEFAULT 'buy',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_region (region_id),
            INDEX idx_created (created_at),
            INDEX idx_region_created (region_id, created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Seed: cria as regiões padrão se não existirem
    for regionId, _ in pairs(Config.RegionZones) do
        MySQL.query.await([[
            INSERT IGNORE INTO region_economy (region_id, base_rate, category_modifiers, min_rate, max_rate, volume_weight, money_supply_weight, recalc_interval_minutes, decay_toward_baseline)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            regionId, 
            Config.DefaultBaseRate,
            json.encode(Config.CategoryModifiers),
            Config.DefaultMinRate,
            Config.DefaultMaxRate,
            Config.VolumeWeight,
            Config.MoneySupplyWeight,
            Config.RecalcIntervalMinutes,
            Config.DecayTowardBaseline
        })
    end

    -- Limpeza automática de transações antigas
    if Config.MaxTransactionHistoryDays and Config.MaxTransactionHistoryDays > 0 then
        MySQL.query.await([[
            DELETE FROM economy_transactions WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
        ]], { Config.MaxTransactionHistoryDays })
    end

    print('^2[' .. resourceName .. '] Database schema initialized.^7')
end)
