--[[
    Metade client-side do bridge fdb. Separado de fdb_bridge.lua porque
    aquele é server_script e este precisa ser client_script (ver fxmanifest).

    Bridge.RegisterTargetEntity ainda não está implementado de verdade —
    depende de qual sistema de target o servidor do cliente usa
    (ox_target, fdb-target, etc.). Ver ROADMAP.md > "Pendências de decisão".
]]

if Config.Framework ~= 'fdb' then return end

Bridge = Bridge or {}

function Bridge.RegisterTargetEntity(entity, options)
    exports['fdb-libs']:addLocalEntity(entity, options)
end

function Bridge.RegisterGlobalPedTarget(options)
    exports['fdb-libs']:addGlobalPed(options)
end
