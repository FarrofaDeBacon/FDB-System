-- Automatic Database Migration Runner
-- Runs pending SQL migrations in FDB-Core/database/migrations/ sequentially on startup

local function RunDatabaseMigrations()
    MySQL.ready(function()
        -- Ensure schema_migrations table exists
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `schema_migrations` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `version` VARCHAR(50) NOT NULL UNIQUE,
                `name` VARCHAR(255) NOT NULL,
                `executed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])

        local migrations = {
            { version = '001', name = '001_create_migrations_table_and_core_indexes.sql' },
            { version = '002', name = '002_add_player_indices.sql' }
        }

        for _, mig in ipairs(migrations) do
            local executed = MySQL.scalar.await('SELECT 1 FROM schema_migrations WHERE version = ?', { mig.version })
            if not executed then
                local resourceName = GetCurrentResourceName()
                local fileContent = LoadResourceFile(resourceName, 'database/migrations/' .. mig.name)
                if fileContent then
                    -- Execute SQL migration
                    MySQL.query.await(fileContent)
                    -- Record migration execution
                    MySQL.insert.await('INSERT INTO schema_migrations (version, name) VALUES (?, ?)', { mig.version, mig.name })
                    RSGCore.ShowSuccess(resourceName, ('Executed Migration [%s]: %s'):format(mig.version, mig.name))
                else
                    RSGCore.ShowError(resourceName, ('Failed to load migration file: database/migrations/%s'):format(mig.name))
                end
            end
        end
    end)
end

CreateThread(function()
    RunDatabaseMigrations()
end)
