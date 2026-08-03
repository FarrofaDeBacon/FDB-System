# AUDIT.md — Phase 1 Security Audit Matrix

This document tracks the audit of all net events handling money, items, metadata, permissions, and server actions.

## Acceptance Criteria for Phase 1
- **Criteria 1**: NO event mutating player currency (`money`), inventory (`items`), or permissions can trust arbitrary data from the client without server-side validation.
- **Criteria 2**: Any event callable from client (`RegisterNetEvent`) MUST bind `source` server-side and validate distance/context where applicable.
- **Criteria 3**: Deprecated client-invokable item/money addition/removal events MUST be removed or strictly locked down.

---

## Net Event Audit Matrix

| File & Line | Event Name | Category | Current Status | Vulnerability / Analysis | Required Remediation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `server/events.lua:104` | `FDBCore:Server:CloseServer` | Server Admin | ✅ OK | Validates `FDBCore.Functions.HasPermission(src, 'admin')` server-side before kicking players/closing server. Kicks unauthorized invoker. | Rename to `FDB:Server:Close` in Phase 3. |
| `server/events.lua:120` | `FDBCore:Server:OpenServer` | Server Admin | ✅ OK | Validates `FDBCore.Functions.HasPermission(src, 'admin')` server-side before reopening server. Kicks unauthorized invoker. | Rename to `FDB:Server:Open` in Phase 3. |
| `server/events.lua:132` | `FDBCore:Server:TriggerClientCallback` | Callbacks | ✅ OK | Internal callback resolution handling for client-triggered callbacks. | Standardize naming in Phase 3. |
| `server/events.lua:140` | `FDBCore:Server:TriggerCallback` | Callbacks | ✅ OK | Binds `src = source` server-side and routes registered callbacks. | Standardize naming in Phase 3. |
| `server/events.lua:149` | `FDBCore:UpdatePlayer` | Player Save | ✅ OK | Binds `src = source`, verifies player instance exists, triggers `Player.Functions.Save()`. | Standardize naming in Phase 3. |
| `server/events.lua:162` | `FDBCore:Server:SetMetaData` | Metadata / Stats | ✅ RESOLVED | Whitelist added (`AllowedClientMetaData`). Only non-critical stats (`hunger`, `thirst`) can be set directly via client trigger. Protected metadata (e.g. `isdead`, `job`, `gang`, `money`) is blocked server-side. | Whitelist enforced. |
| `server/events.lua:170` | `FDBCore:ToggleDuty` | Job / Duty | ✅ OK | Binds `src = source`, verifies player exists, updates job duty state server-side. | Update event name to standard convention `FDB:Job:ToggleDuty` in Phase 3. |
| `server/events.lua:189` | `FDBCore:Server:UseItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:195` | `FDBCore:Server:RemoveItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. Does not execute item removal. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:201` | `FDBCore:Server:AddItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. Does not execute item addition. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:208` | `FDBCore:CallCommand` | Admin / Commands | ✅ OK | Validates `FDBCore.Functions.HasPermission(src, ...)` server-side before executing callback. | Rename event to `FDB:Command:Call` in Phase 3. |
| `server/events.lua:234` | `FDBCore:Server:KickCSRF` | Anti-Exploit | ✅ OK | Drops player on CSRF token validation failure. Binds `source` server-side. | None. |
| `server/moneyitems.lua:192` | `FDBCore:Server:OnPlayerLoaded` | Economy / Items | ✅ OK | Internal handler executed when player finishes loading player data. | Standardize naming in Phase 3. |
| `server/debug.lua:28` | `FDBCore:DebugSomething` | Debug | ✅ RESOLVED | Added check: if invoked from client, requires `admin` permission. Client net triggers without admin privileges are ignored. | Admin validation enforced. |

---

## 📌 Audit Scope Note & Roadmap

> [!IMPORTANT]
> **Core vs. Companion Resource Security Boundaries**:
> The `FDB-Core` framework manages core player state, licensing, callbacks, and player objects. Actual item management, transactions, banking, and shop interactions are delegated to separate companion resources (e.g., `fdb-inventory`, `fdb-banking`, `fdb-shops`).
> 
> Auditing `FDB-Core` guarantees that the base core layer is secure against direct privilege escalation via core net events. However, complete end-to-end security requires auditing the companion resources.
> 
> **Roadmap Schedule**:
> - **Phase 1.5 (Security Audit - Companion Resources)**: Dedicated security audit of `fdb-inventory`, `fdb-banking`, and shop resources for distance validation, duplicate transaction exploits, and server-side item verification.
