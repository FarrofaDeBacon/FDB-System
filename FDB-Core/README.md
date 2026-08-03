# FDB-Core Premium Fork

[![CI](https://github.com/Rexshack-RedM/fdb-core/actions/workflows/ci.yml/badge.svg)](https://github.com/Rexshack-RedM/fdb-core/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

An enterprise-grade, server-authoritative RedM framework derived from FDB-Core, focused on extreme code quality, strict security validation, optimized database execution, and comprehensive documentation.

---

## Key Features & Architecture Standards

- **Server-Authoritative**: All currency, inventory, job, and permission mutations are strictly validated on the server.
- **Async Database Layer**: Exclusively utilizes `oxmysql` with non-blocking promises and callbacks.
- **Standardized Conventions**: Events use `FDB:<Module>:<Action>` and exports use `FDB.<Module>.<Action>`.
- **Automated CI**: Built-in syntax and lint validation on every push and pull request.

---

## Installation

1. Clone this repository into your server's `resources/[framework]/fdb-core` folder:
   ```bash
   git clone <YOUR_FORK_URL> fdb-core
   ```
2. Ensure `oxmysql` is started prior to `fdb-core` in your `server.cfg`:
   ```cfg
   ensure oxmysql
   ensure fdb-core
   ```
3. Import the required database schema into MySQL.

---

## Documentation

- Refer to [ARCHITECTURE.md](file:///d:/BASE%20NOVA/ARCHITECTURE.md) for architectural guidelines, coding standards, and conventions.
- Refer to [AUDIT.md](file:///d:/BASE%20NOVA/AUDIT.md) for the security audit matrix and server event status.
- Refer to [CHANGELOG.md](file:///d:/BASE%20NOVA/CHANGELOG.md) for release notes.

---

## License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](file:///d:/BASE%20NOVA/LICENSE) file for details.
