local FDBCore = exports['fdb-core']:GetCoreObject()
lib.locale()

---------------------------------
-- SaltyChat integration
---------------------------------
CreateThread(function()
    if not Config.SaltyChat then return end

    Wait(0)

    if GetResourceState('saltychat') ~= 'started' then
        print('^1[fdb-medic] Config.SaltyChat is enabled, but saltychat is not started. Start saltychat before fdb-medic.^0')
    elseif Config.Debug then
        print('^2[fdb-medic] SaltyChat death voice integration enabled.^0')
    end
end)

RegisterNetEvent('fdb-medic:server:setSaltyChatAlive', function(isAlive)
    if not Config.SaltyChat then return end

    local src = source
    if type(isAlive) ~= 'boolean' then return end

    if GetResourceState('saltychat') ~= 'started' then
        if Config.Debug then
            print('[fdb-medic] SaltyChat integration is enabled, but saltychat is not started')
        end
        return
    end

    exports['saltychat']:SetPlayerAlive(src, isAlive)

    if Config.Debug then
        print(('[fdb-medic] SaltyChat player %s alive state set to %s'):format(src, isAlive))
    end
end)

-----------------------
-- use bandage
-----------------------
FDBCore.Functions.CreateUseableItem('bandage', function(source, item)
    local src = source
    TriggerClientEvent('fdb-medic:client:usebandage', src, item.name)
end)

---------------------------------
-- medic storage
---------------------------------
RegisterNetEvent('fdb-medic:server:openstash', function(location)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local data = { label = locale('sv_medical_storage'), maxweight = Config.StorageMaxWeight, slots = Config.StorageMaxSlots }
    local stashName = 'medic_' .. location
    exports['fdb-inventory']:OpenInventory(src, stashName, data)
end)

----------------------------------
-- Admin Revive Player
----------------------------------
FDBCore.Commands.Add('revive', locale('sv_revive'), {{name = 'id', help = locale('sv_revive_2')}}, false, function(source, args)
    local src = source

    if not args[1] then
        TriggerClientEvent('fdb-medic:client:adminRevive', src)
        return
    end

    local Player = FDBCore.Functions.GetPlayer(tonumber(args[1]))
    if not Player then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_no_online'), type = 'error', duration = 7000 })
        return
    end

    TriggerClientEvent('fdb-medic:client:adminRevive', Player.PlayerData.source)
end, 'admin')

-- Admin Kill Player
FDBCore.Commands.Add('kill', locale('sv_kill'), {{name = 'id', help = locale('sv_kill_id')}}, true, function(source, args)
    local src = source
    local target = tonumber(args[1])

    local Player = FDBCore.Functions.GetPlayer(target)
    if not Player then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_no_online'), type = 'error', duration = 7000 })
        return
    end

    TriggerClientEvent('fdb-medic:client:KillPlayer', Player.PlayerData.source)
end, 'admin')

FDBCore.Commands.Add('heal', locale('sv_heal'), {{name = 'id', help = locale('sv_heal_2')}}, false, function(source, args)
    local src = source

    if not args[1] then
        TriggerClientEvent('fdb-medic:client:adminHeal', src)
        return
    end

    local Player = FDBCore.Functions.GetPlayer(tonumber(args[1]))
    if not Player then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_no_online'), type = 'error', duration = 7000 })
        return
    end

    TriggerClientEvent('fdb-medic:client:adminHeal', Player.PlayerData.source)
end, 'admin')

----------------------
-- EVENTS 
-----------------------
-- Death Actions: Remove Inventory / Cash
RegisterNetEvent('fdb-medic:server:deathactions', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)

    if Config.WipeInventoryOnRespawn then
        Player.Functions.ClearInventory()
        MySQL.Async.execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lost_all'), type = 'info', duration = 7000 })
    end

    if Config.WipeCashOnRespawn then
        Player.Functions.SetMoney('cash', 0)
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lost_cash'), type = 'info', duration = 7000 })
    end
    if Config.WipeBloodmoneyOnRespawn then
        Player.Functions.SetMoney('bloodmoney', 0)
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lost_bloodmoney'), type = 'info', duration = 7000 })
    end
end)

-- Medic Revive Player
RegisterNetEvent('fdb-medic:server:RevivePlayer', function(playerId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(playerId)

    if not Patient then return end

    if Player.PlayerData.job.name ~= Config.JobRequired then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_not_medic'), type = 'error', duration = 7000 })
        return
    end

    if Player.Functions.RemoveItem('firstaid', 1) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items['firstaid'], 'remove')
        TriggerClientEvent('fdb-medic:client:playerRevive', Patient.PlayerData.source)
    end
end)

-- Medic Treat Wounds
RegisterNetEvent('fdb-medic:server:TreatWounds', function(playerId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(playerId)

    if not Patient then return end

    if Player.PlayerData.job.name ~= Config.JobRequired then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_not_medic'), type = 'error', duration = 7000 })
        return
    end

    if Player.Functions.RemoveItem('bandage', 1) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items['bandage'], 'remove')
        TriggerClientEvent('fdb-medic:client:HealInjuries', Patient.PlayerData.source)
    end
end)

-- Medic Alert
RegisterNetEvent('fdb-medic:server:medicAlert', function(text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = FDBCore.Functions.GetRSGPlayers()

    for _, v in pairs(players) do
        if v.PlayerData.job.name == 'medic' and v.PlayerData.job.onduty then
            TriggerClientEvent('fdb-medic:client:medicAlert', v.PlayerData.source, coords, text)
        end
    end
end)

--------------------------
-- Medics On-Duty Callback
-------------------------
FDBCore.Functions.CreateCallback('fdb-medic:server:getmedics', function(source, cb)
    local amount = 0
    local players = FDBCore.Functions.GetRSGPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == Config.JobRequired and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)

---------------------------------
-- remove item
---------------------------------
RegisterServerEvent('fdb-medic:server:removeitem', function(item, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item], 'remove', amount)
end)
