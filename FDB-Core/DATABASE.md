# DATABASE.md — FDB-Core Database Architecture & Migration System

## Overview

The `FDB-Core` database layer is designed for high-concurrency RedM servers, adhering strictly to:
1. **100% Async Execution**: Powered by `oxmysql` with non-blocking promises (`MySQL.prepare.await`, `MySQL.query.await`, `MySQL.insert`, `MySQL.transaction`).
2. **Prepared Statements**: All queries MUST use parameterized placeholders (`?` or `:name`) to prevent SQL Injection. String concatenation in queries is strictly prohibited.
3. **Optimized Indexes**: Key foreign keys and lookup columns (`citizenid`, `license`, `cid`) are indexed.
4. **Versioned Migration System**: Database schema changes are tracked sequentially in `FDB-Core/database/migrations/`.

---

## Migration Framework

Migrations are stored in `FDB-Core/database/migrations/` in ascending numeric order:

| Version | Migration File | Description |
| :--- | :--- | :--- |
| `001` | `001_initial_schema_and_indexes.sql` | Creates `schema_migrations` tracking table & indexes `players(citizenid, license)`. |
| `002` | `002_add_player_indices.sql` | Indexes `players(cid, name)`. |

---

## Query Safety Checklist

- [x] No `MySQL.Sync` or blocking synchronous SQL calls.
- [x] No raw string concatenation in SQL queries (`'SELECT * FROM table WHERE id = ' .. id`).
- [x] All player lookups utilize indexed columns (`citizenid`, `license`).
