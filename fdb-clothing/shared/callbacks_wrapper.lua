-- ============================================================
-- FDB System | fdb-clothing | shared/callbacks_wrapper.lua
-- Wrapper for client-server callbacks
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
Callback = {}

if IsDuplicityVersion() then
    -- Server Side
    local CORE = exports['fdb-core']:GetCoreObject()
    Callback.registerServer = function(name, cb)
        CORE.Functions.CreateCallback(name, cb)
    end
else
    -- Client Side
    local CORE = exports['fdb-core']:GetCoreObject()
    Callback.triggerServer = function(name, cb, ...)
        CORE.Functions.TriggerCallback(name, cb, ...)
    end
end

