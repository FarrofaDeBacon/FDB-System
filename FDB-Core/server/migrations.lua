-- Automatic Database Migration Runner
-- Runs pending SQL migrations in FDB-Core/database/migrations/ sequentially on startup

local function RunDatabaseMigrations()
    MySQL.ready(function()
        local resourceName = GetCurrentResourceName()

        -- Ensure schema_migrations table exists safely
        local initOk, initErr = pcall(function()
            MySQL.query.await([[
                CREATE TABLE IF NOT EXISTS `schema_migrations` (
                    `id` INT AUTO_INCREMENT PRIMARY KEY,
                    `version` VARCHAR(50) NOT NULL UNIQUE,
                    `name` VARCHAR(255) NOT NULL,
                    `executed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]])
        end)

        if not initOk then
            FDBCore.ShowError(resourceName, ('[MIGRATION FATAL] Failed to initialize schema_migrations table: %s'):format(to_string(initErr)))
            return
        end

        local migrations = {
            { version = '001', name = '001_create_migrations_table_and_core_indexes.sql' },
            { version = '002', name = '002_add_player_indices.sql' }
        }

        for _, mig in ipairs(migrations) do
            local executed = false
            local checkOk, checkErr = pcall(function()
                executed = MySQL.scalar.await('SELECT 1 FROM schema_migrations WHERE version = ?', { mig.version })
            end)

            if not checkOk then
                FDBCore.ShowError(resourceName, ('[MIGRATION ERROR] Failed checking status of version %s: %s'):format(mig.version, tostring(checkErr)))
                return
            end

            if not executed then
                local fileContent = LoadResourceFile(resourceName, 'database/migrations/' .. mig.name)
                if not fileContent or fileContent:match('^%s*$') then
                    FDBCore.ShowError(resourceName, ('[MIGRATION ERROR] Migration file missing or empty: database/migrations/%s'):format(mig.name))
                    return
                end

                -- Split migration by semicolon to safely support multi-statement files.
                -- NOTE/LIMITATION: Migration SQL files should avoid embedded semicolons inside string literals
                -- or complex CREATE TRIGGER/PROCEDURE blocks to ensure reliable statement splitting.
                local statements = {}
                for statement in fileContent:gmatch('[^;]+') do
                    local trimmed = statement:match('^%s*(.-)%s*$')
                    if trimmed and #trimmed > 0 and not trimmed:match('^%-%-') then
                        table.insert(statements, trimmed)
                    end
                end

                local migrationSuccess = true
                for idx, stmt in ipairs(statements) do
                    local stmtOk, stmtErr = pcall(function()
                        MySQL.query.await(stmt)
                    end)

                    if not stmtOk then
                        local errStr = tostring(stmtErr)
                        -- Ignore duplicate index / duplicate key name errors (MySQL 1061 ER_DUP_KEYNAME) for DDL idempotency
                        if errStr:find('1061') or errStr:find('Duplicate key name') or errStr:find('already exists') then
                            FDBCore.ShowSuccess(resourceName, ('[MIGRATION NOTICE] Skipped existing index/table in %s (statement %d)'):format(mig.name, idx))
                        else
                            FDBCore.ShowError(resourceName, ('[MIGRATION ERROR] Failed applying %s (statement %d): %s'):format(mig.name, idx, errStr))
                            migrationSuccess = false
                            break
                        end
                    end
                end

                if migrationSuccess then
                    local recordOk, recordErr = pcall(function()
                        MySQL.insert.await('INSERT INTO schema_migrations (version, name) VALUES (?, ?)', { mig.version, mig.name })
                    end)

                    if recordOk then
                        FDBCore.ShowSuccess(resourceName, ('Executed Migration [%s]: %s'):format(mig.version, mig.name))
                    else
                        FDBCore.ShowError(resourceName, ('[MIGRATION ERROR] Applied %s but failed to record status: %s'):format(mig.name, tostring(recordErr)))
                        return
                    end
                else
                    FDBCore.ShowError(resourceName, ('[MIGRATION HALTED] Stopped execution at migration [%s] due to error'):format(mig.version))
                    return
                end
            end
        end
    end)
end

CreateThread(function()
    RunDatabaseMigrations()
end)
