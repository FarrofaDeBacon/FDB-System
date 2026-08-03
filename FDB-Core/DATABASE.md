# DATABASE.md — FDB-Core Database Architecture & Migration System

## Overview

The `FDB-Core` database layer is designed for high-concurrency RedM servers, adhering strictly to:
1. **100% Async Execution**: Powered by `oxmysql` with non-blocking promises (`MySQL.prepare.await`, `MySQL.query.await`, `MySQL.insert`, `MySQL.transaction`).
2. **Prepared Statements**: All DML queries MUST use parameterized placeholders (`?` or `:name`) to prevent SQL Injection.
3. **Database Compatibility**: Minimum recommended versions: **MySQL 8.0.29+** or **MariaDB 10.5.2+** (supports `ALTER TABLE ... ADD INDEX IF NOT EXISTS`).
4. **Automatic Versioned Migration Runner**: On resource startup (`onResourceStart`), `FDB-Core/server/migrations.lua` checks pending migrations in `FDB-Core/database/migrations/` against the `schema_migrations` table and executes them in sequence.

---

## Migration Index

Migrations are stored in `FDB-Core/database/migrations/` in ascending numeric order:

| Version | Migration File | Description |
| :--- | :--- | :--- |
| `001` | `001_create_migrations_table_and_core_indexes.sql` | Creates `schema_migrations` tracking table & indexes `players(license)`. |
| `002` | `002_add_player_indices.sql` | Indexes `players(cid)`. |

---

## Automatic Migration Runner (`FDB-Core/server/migrations.lua`)

```lua
local function RunDatabaseMigrations()
    MySQL.ready(function()
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
                    MySQL.query.await(fileContent)
                    MySQL.insert.await('INSERT INTO schema_migrations (version, name) VALUES (?, ?)', { mig.version, mig.name })
                    RSGCore.ShowSuccess(resourceName, ('Executed Migration [%s]: %s'):format(mig.version, mig.name))
                end
            end
        end
    end)
end
```

---

## Query Safety Checklist

- [x] No `MySQL.Sync` or blocking synchronous SQL calls.
- [x] Prepared DML statements with placeholders (`?`) for user input.
- [x] Automated migration runner tracking schema state via `schema_migrations`.
