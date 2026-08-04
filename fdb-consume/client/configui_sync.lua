-- fdb-consume/client/configui_sync.lua

RegisterNetEvent('fdb-consume:client:syncConfig')
AddEventHandler('fdb-consume:client:syncConfig', function(newConfig)
    -- Atualiza a tabela Config global
    Config = newConfig
end)
