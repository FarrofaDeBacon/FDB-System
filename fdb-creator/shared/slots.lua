-- ============================================================
-- FDB System | fdb-creator | shared/slots.lua
-- Character slot configuration
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
-- Slots configuration is now in config.lua
-- This file maintains compatibility with existing code

Slots = Config.Slots or {
    default = 5,
    role = {
        superadmin = 5,
        admin = 5,
    },
    identifier = {}
}

PedPermission = Config.PedPermission or {
    default = true,
    role = {
        superadmin = true,
        admin = true,
    },
    identifier = {}
}
