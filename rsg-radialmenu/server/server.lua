local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('walkstyles:server:sync')
AddEventHandler('walkstyles:server:sync', function(clipset, style)
    local src = source
    TriggerClientEvent('walkstyles:client:syncRemote', -1, src, clipset, style)
end)
