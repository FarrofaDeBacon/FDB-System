local FDBCore = exports['fdb-core']:GetCoreObject()
BathingSessions = {}

RegisterServerEvent('fdb-bathing:server:canEnterBath')
AddEventHandler('fdb-bathing:server:canEnterBath', function(town)
    local src = source
    if not Config.BathingZones[town] then return end

    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local currentMoney = Player.PlayerData.money['cash']

    if not BathingSessions[town] then
        if currentMoney >= Config.NormalBathPrice then
            Player.Functions.RemoveMoney('cash', Config.NormalBathPrice)
            BathingSessions[town] = src
            TriggerClientEvent('fdb-bathing:client:ToggleInvincibility', src, true)
            TriggerClientEvent('fdb-bathing:client:StartBath', src, town)
        else
            TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_not_enough_money'), type = 'error', duration = 5000 })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_occupied'), type = 'error', duration = 5000 })
    end
end)

RegisterServerEvent('fdb-bathing:server:canEnterDeluxeBath')
AddEventHandler('fdb-bathing:server:canEnterDeluxeBath', function(town)
    local src = source
    if not Config.BathingZones[town] then return end
    if BathingSessions[town] == src then

        local Player = FDBCore.Functions.GetPlayer(src)
        if not Player then return end
        local currentMoney = Player.PlayerData.money['cash']

        if currentMoney >= Config.DeluxeBathPrice then
            Player.Functions.RemoveMoney('cash', Config.DeluxeBathPrice)
            TriggerClientEvent('fdb-bathing:client:StartDeluxeBath', src, town)
        else
            TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_not_enough_money'), type = 'error', duration = 5000 })
            TriggerClientEvent('fdb-bathing:client:HideDeluxePrompt', src)
        end
    end
end)

RegisterServerEvent('fdb-bathing:server:setBathAsFree')
AddEventHandler('fdb-bathing:server:setBathAsFree', function(town)
    if BathingSessions[town] == source then
        BathingSessions[town] = nil
        TriggerClientEvent('fdb-bathing:client:ToggleInvincibility', source, false)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for town, player in pairs(BathingSessions) do
        if player == src then
            BathingSessions[town] = nil
        end
    end
end)

RegisterServerEvent('fdb-bathing:server:undressPlayer')
AddEventHandler('fdb-bathing:server:undressPlayer', function()
    exports['fdb-wardrobe']:RemovePlayerClothing(source)
end)

RegisterServerEvent('fdb-bathing:server:dressPlayer')
AddEventHandler('fdb-bathing:server:dressPlayer', function()
    exports['fdb-wardrobe']:DressPlayer(source)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for town, player in pairs(BathingSessions) do
            TriggerClientEvent('fdb-bathing:client:ToggleInvincibility', player, false)
        end
        BathingSessions = {}
    end
end)