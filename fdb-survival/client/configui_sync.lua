-- fdb-survival/client/configui_sync.lua

RegisterNetEvent('fdb-survival:client:syncConfig')
AddEventHandler('fdb-survival:client:syncConfig', function(newConfig)
    -- Atualiza a tabela Config global
    Config = newConfig
end)
