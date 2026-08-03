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
| `server/events.lua:156` | `RSGCore:Server:SetMetaData` | Metadata / Stats | ⚠️ Requires Validation | Accepts arbitrary `meta` key and `data` payload directly from client without whitelisting. A client can manipulate metadata like hunger, thirst, or job attributes. | Restrict whitelisted metadata keys server-side; reject client calls for protected metadata keys (e.g. `isdead`, `inlaststand`, `craftingrep`). |
| `server/events.lua:164` | `RSGCore:ToggleDuty` | Job / Duty | ✅ OK | Binds `src = source`, verifies player exists, updates job duty state server-side. | Update event name to standard convention `RSG:Job:ToggleDuty`. |
| `server/events.lua:183` | `RSGCore:Server:UseItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:189` | `RSGCore:Server:RemoveItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. Does not execute item removal. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:195` | `RSGCore:Server:AddItem` | Inventory | ⚠️ Deprecated / Risk | Deprecated stub printing warning. Does not execute item addition. | Completely remove event in Phase 4 / inventory overhaul. |
| `server/events.lua:202` | `RSGCore:CallCommand` | Admin / Commands | ✅ OK | Validates `RSGCore.Functions.HasPermission(src, ...)` server-side before executing callback. | Rename event to `RSG:Command:Call`. |
| `server/events.lua:228` | `RSGCore:Server:KickCSRF` | Anti-Exploit | ⚠️ Requires Validation | Drops player on client trigger. Needs check to ensure false positives don't occur. | Ensure CSRF validation tokens are verified server-side. |
| `server/moneyitems.lua:192` | `RSGCore:Server:OnPlayerLoaded` | Economy / Items | ✅ OK | Internal initialization on player join. | Standardize naming to `RSG:Player:Loaded`. |
| `server/debug.lua:28` | `RSGCore:DebugSomething` | Debug | ⚠️ Requires Removal / Permission Check | Registered server event for debug output. If enabled in production without permission checks, allows log spam. | Wrap with `RSGCore.Config.Server.Debug` check and admin permission validation. |

---

## Next Steps for Phase 1 Fixes

1. Update `RSGCore:Server:SetMetaData` (`server/events.lua:156`) to whitelist allowed client-settable metadata fields.
2. Secure debug event handler in `server/debug.lua:28`.
