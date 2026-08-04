# ARCHITECTURE.md — FDB-Core Premium Fork Architecture & Engineering Standards

## 1. Vision & Core Philosophy

This repository is a high-performance, server-authoritative, highly secure framework for RedM servers.
It serves as the open-source foundation for custom scripts, jobs, and enterprise RedM server ecosystems.

### Fundamental Non-Negotiable Rules

1. **Server-Authoritative Design**:
   - The client MUST NEVER be trusted for sensitive operations (currency, inventory, permissions, job levels).
   - The client sends intent (`FDB:Server:RequestPurchase`), the server verifies distance, inventory capacity, balance, permissions, and executes the transaction server-side.

2. **Standardized Naming Conventions**:
   - **Server/Client Net Events**: `FDB:<Module>:<Action>` (e.g., `FDB:Money:AddCash`, `FDB:Inventory:ItemUsed`).
   - **Exports / Functions**: `FDB.<Module>.<Action>` (e.g., `FDB.Player.GetMoney`, `FDB.Functions.GetPlayer`).
   - Legacy FDB/QBCore naming styles MUST be systematically audited and refactored.

3. **Client Responsibilities**:
   - UI Rendering (NUI/Svelte/HTML).
   - Local Animations, Visual Effects, Audio.
   - User Input & Target Interactions.
   - Sending structured requests to server events.

4. **Database Access Rules**:
   - ALL database queries MUST be asynchronous using `oxmysql` via promises or callbacks (`exports.oxmysql:execute`, `exports.oxmysql:fetch`).
   - NO synchronous blocking queries (`MySQL.Sync`) are permitted anywhere in core or extension modules.

5. **Module Standard & Documentation Requirements**:
   - File Header comment explaining module responsibility.
   - JSDoc / LDoc structured comments above export declarations (Parameters, Returns, Examples).
   - Every modified/added module MUST include an entry in `CHANGELOG.md`.

---

## 2. Directory Structure

```
d:/BASE NOVA/
├── .github/
│   └── workflows/          # CI Workflows (Lua Syntax & Linting)
├── README.md               # Root ecosystem README
└── FDB-Core/               # Core framework resource
    ├── client/             # Client-side scripts (UI, Animations, Input)
    ├── server/             # Server-side authoritative logic (DB, Auth, Economy)
    ├── shared/             # Shared data structures, items, jobs, locales
    ├── locale/             # Multi-language translation dictionaries
    ├── ARCHITECTURE.md     # Architecture standards and guidelines
    ├── AUDIT.md            # Phase 1 Security audit matrix
    ├── CHANGELOG.md        # Version change history
    ├── LICENSE             # GNU General Public License v3.0
    └── README.md           # Installation & usage instructions
```

---

## 3. Workflow & Contribution Model

- **Branching Model**: Features and fixes MUST be developed on dedicated topic branches (`fix/security-inventory`, `refactor/db-layer`, `audit/security-pass`).
- **Direct Commits**: Direct commits to `main` are strictly forbidden.
- **Code Review**: Every PR is evaluated against the 4 pillars: **Security → Performance → Architecture → Documentation**.

---

## 4. Mandatory External Dependencies

- **oxmysql**: Asynchronous database interaction.
- **ox_lib**: Core library for UI components (context menus, input dialogs, notifications).
- **jo_libs**: Mandatory foundational UI library for visual menus (character creator, barbershop, etc).
  - License: LGPL-3.0
  - Repository: `https://github.com/Jump-On-Studios/RedM-jo_libs`
  - Purpose: Provides standardized, RedM-native styled NUI menus for all FDB scripts, replacing the legacy `fdb-menubase`.
