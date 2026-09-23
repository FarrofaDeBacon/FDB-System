-- fdb-propeditor/server/main.lua

RegisterNetEvent('fdb-propeditor:server:RequestPermission', function(ticket)
    local src = source
    local allowed = IsPlayerAceAllowed(src, 'command.propedit')
    TriggerClientEvent('fdb-propeditor:client:ReceivePermission_' .. ticket, src, allowed)
end)
