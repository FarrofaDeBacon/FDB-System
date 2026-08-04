-- fdb-water/client/configui_sync.lua

RegisterNetEvent('fdb-water:client:syncConfig')
AddEventHandler('fdb-water:client:syncConfig', function(newConfig)
    -- Atualiza a tabela Config global
    Config = newConfig
end)
