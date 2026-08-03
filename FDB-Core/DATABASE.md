# DATABASE.md — FDB-Core Database Architecture & Migration System

## Overview

The `FDB-Core` database layer is designed for high-concurrency RedM servers, adhering strictly to:
1. **100% Async Execution**: Powered by `oxmysql` with non-blocking promises (`MySQL.prepare.await`, `MySQL.query.await`, `MySQL.insert`, `MySQL.transaction`).
2. **Prepared Statements**: All DML queries MUST use parameterized placeholders (`?` or `:name`) to prevent SQL Injection.
3. **Database Compatibility**: Minimum recommended versions: **MySQL 8.0+** or **MariaDB 10.4+**.
4. **Automatic Versioned Migration Runner**: On resource startup (`onResourceStart`), `FDB-Core/server/migrations.lua` checks pending migrations in `FDB-Core/database/migrations/` against `schema_migrations`, handles multi-statement SQL parsing safely, and executes them with full `pcall` error isolation.

---

## Migration Index

Migrations are stored in `FDB-Core/database/migrations/` in ascending numeric order:

| Version | Migration File | Description |
| :--- | :--- | :--- |
| `001` | `001_create_migrations_table_and_core_indexes.sql` | Creates `schema_migrations` tracking table & indexes `players(license)`. |
| `002` | `002_add_player_indices.sql` | Composite index `players(citizenid, cid)` for character slot lookups. |

---

## Automatic Migration Runner & Safety Mechanisms

- **`pcall` Error Isolation**: Every migration step is wrapped in `pcall`. If a statement fails, an explicit `[MIGRATION ERROR]` is printed, and execution stops immediately before recording the version.
- **Missing File Protection**: If a migration file is missing or empty, an explicit error is logged and migration halts safely.
- **Multi-Statement SQL Parsing**: SQL files containing multiple statements (separated by `;`) are parsed and executed iteratively. *Note*: Avoid embedded semicolons within string literals or multi-statement triggers in `.sql` migration files.
- **DDL Idempotency Requirement**: Because DDL statements trigger auto-commits in MySQL, ALL DDL statements in migration files MUST be written idempotently (`CREATE TABLE IF NOT EXISTS`, `DROP TABLE IF EXISTS`). For index creation in standard MySQL (where `ALTER TABLE ... ADD INDEX IF NOT EXISTS` is non-standard), the runner catches duplicate key errors (`1061 / ER_DUP_KEYNAME`) via `pcall` as non-fatal warnings.

---

## Query Safety Checklist

- [x] No `MySQL.Sync` or blocking synchronous SQL calls.
- [x] Prepared DML statements with placeholders (`?`) for user input.
- [x] Automated migration runner tracking schema state via `schema_migrations` with `pcall` error isolation.
- [x] Strict DDL idempotency enforced on all SQL migration files.
