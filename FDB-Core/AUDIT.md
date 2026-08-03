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
| `server/events.lua:104` | `RSGCore:Server:CloseServer` | Server Admin | ✅ OK | Validates `RSGCore.Functions.HasPermission(src, 'admin')` server-side before kicking players/closing server. Kicks unauthorized invoker. | Rename to `RSG:Server:Close` in Phase 3. |
| `server/events.lua:120` | `RSGCore:Server:OpenServer` | Server Admin | ✅ OK | Validates `RSGCore.Functions.HasPermission(src, 'admin')` server-side before reopening server. Kicks unauthorized invoker. | Rename to `RSG:Server:Open` in Phase 3. |
| `server/events.lua:132` | `RSGCore:Server:TriggerClientCallback` | Callbacks | ✅ OK | Internal callback resolution handling for client-triggered callbacks. | Standardize naming in Phase 3. |
| `server/events.lua:140` | `RSGCore:Server:TriggerCallback` | Callbacks | ✅ OK | Binds `src = source` server-side and routes registered callbacks. | Standardize naming in Phase 3. |
| `server/events.lua:149` | `RSGCore:UpdatePlayer` | Player Save | ✅ OK | Binds `src = source`, verifies player instance exists, triggers `Player.Functions.Save()`. | Standardize naming in Phase 3. |
| `server/events.lua:162` | `RSGCore:Server:SetMetaData` | Metadata / Stats | ✅ RESOLVED | Whitelist added (`AllowedClientMetaData`). Only non-critical stats (`hunger`, `thirst`) can be set directly via client trigger. Protected metadata (e.g. `isdead`, `job`, `gang`, `money`) is blocked server-side. | Whitelist enforced. |
| `server/events.lua:170` | `RSGCore:ToggleDuty` | Job / Duty | ✅ OK | Binds `src = source`, verifies player exists, updates job duty state server-side. | Update event name to standard convention `RSG:Job:ToggleDuty` in Phase 3. |
| `server/events.lua:189` | `RSGCore:Server:UseItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:195` | `RSGCore:Server:RemoveItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. Does not execute item removal. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:201` | `RSGCore:Server:AddItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. Does not execute item addition. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:208` | `RSGCore:CallCommand` | Admin / Commands | ✅ OK | Validates `RSGCore.Functions.HasPermission(src, ...)` server-side before executing callback. | Rename event to `RSG:Command:Call` in Phase 3. |
| `server/events.lua:234` | `RSGCore:Server:KickCSRF` | Anti-Exploit | ✅ OK | Drops player on CSRF token validation failure. Binds `source` server-side. | None. |
| `server/moneyitems.lua:192` | `RSGCore:Server:OnPlayerLoaded` | Economy / Items | ✅ OK | Internal handler executed when player finishes loading player data. | Standardize naming in Phase 3. |
| `server/debug.lua:28` | `RSGCore:DebugSomething` | Debug | ✅ RESOLVED | Added check: if invoked from client, requires `admin` permission. Client net triggers without admin privileges are ignored. | Admin validation enforced. |

---

## Next Steps for Phase 1 Fixes

1. Update `RSGCore:Server:SetMetaData` (`server/events.lua:156`) to whitelist allowed client-settable metadata fields.
2. Secure debug event handler in `server/debug.lua:28`.
