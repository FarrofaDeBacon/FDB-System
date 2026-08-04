-- fdb-hudpremium/client/configui_sync.lua

RegisterNetEvent('fdb-hudpremium:client:syncConfig')
AddEventHandler('fdb-hudpremium:client:syncConfig', function(newConfig)
    -- Atualiza a tabela Config global
    Config = newConfig
end)
