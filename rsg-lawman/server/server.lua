local FDBCore = exports['fdb-core']:GetCoreObject()
lib.locale()

------------------------------------------
-- law test alert
------------------------------------------
FDBCore.Commands.Add('testalert', locale('sv_test'), {}, false, function(source)
    local src = source
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local text = locale('sv_test_a')
    TriggerClientEvent('fdb-lawman:client:lawmanAlert', src, playerCoords, text)
end)

------------------------------------------
-- search players inventory
------------------------------------------
FDBCore.Commands.Add('searchplayer', locale('sv_searchplayer'), {}, false, function(source)
    local src = source
    TriggerClientEvent('fdb-lawman:client:searchplayer', src)
end)

RegisterNetEvent('fdb-lawman:server:SearchPlayer', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local PlayerData = Player.PlayerData
    local player, distance = FDBCore.Functions.GetClosestPlayer(src)
    if player ~= -1 and distance < Config.SearchDistance then
        local SearchedPlayer = FDBCore.Functions.GetPlayer(tonumber(player))
        if not SearchedPlayer then return end
        exports['fdb-inventory']:OpenInventoryById(src, tonumber(player))
        TriggerClientEvent('ox_lib:notify', player,
            { title = locale('sv_info'), description = locale('sv_info_a'), type = 'info', duration = 7000 })
    else
        TriggerClientEvent('ox_lib:notify', src,
            { title = locale('sv_error'), description = locale('sv_error_a'), type = 'error', duration = 7000 })
    end
end)

------------------------------------------
-- law badge
------------------------------------------
FDBCore.Commands.Add('lawbadge', locale('sv_lawbadge'), {}, false, function(source, args)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    local jobname = Player.PlayerData.job.name
    local onduty = Player.PlayerData.job.onduty
    if onduty and Config.LawJobs[jobname] then
        TriggerClientEvent('fdb-lawman:client:lawbadge', src)
    else
        TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_need_duty'), type = 'error', duration = 5000 })
    end
end)

------------------------------------------
-- law on-duty callback
------------------------------------------
FDBCore.Functions.CreateCallback('fdb-lawman:server:getlaw', function(source, cb)
    local lawcount = 0
    local players = FDBCore.Functions.GetRSGPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            lawcount = lawcount + 1
        end
    end
    cb(lawcount)
end)

-- Add 'unjail' command
FDBCore.Commands.Add('unjail', locale('sv_unjail'), { { name = 'id', help = locale('sv_unjail_id') } }, true,
    function(source, args)
        local src = source
        local Player = FDBCore.Functions.GetPlayer(src)

        if Player.PlayerData.job.type == 'leo' then -- Check if the player issuing the command is a law enforcement officer
            local playerId = tonumber(args[1])
            if playerId then
                local TargetPlayer = FDBCore.Functions.GetPlayer(playerId)
                if TargetPlayer then
                    -- Trigger the unjail event for the target player
                    TriggerClientEvent('fdb-prison:client:freedom', TargetPlayer.PlayerData.source)
                    -- Notify the player issuing the command
                    TriggerClientEvent('ox_lib:notify', src,
                        { title = locale('sv_unjail_b'), description = locale('sv_unjail_c'), type = 'success', duration = 5000 })
                    -- Optionally notify the target player
                    TriggerClientEvent('ox_lib:notify', TargetPlayer.PlayerData.source,
                        { title = locale('sv_unjail_d'), description = locale('sv_unjail_e'), type = 'success', duration = 5000 })
                else
                    TriggerClientEvent('ox_lib:notify', src,
                        { title = locale('sv_unjail_f'), description = locale('sv_unjail_g'), type = 'error', duration = 5000 })
                end
            else
                TriggerClientEvent('ox_lib:notify', src,
                    { title = locale('sv_unjail_f'), description = locale('sv_unjail_h'), type = 'error', duration = 5000 })
            end
        else
            -- Notify the player issuing the command if they're not a law enforcement officer
            TriggerClientEvent('ox_lib:notify', src,
                { title = locale('sv_unjail_f'), description = locale('sv_unjail_j'), type = 'error', duration = 5000 })
        end
    end)

---------------------------
-- lawman alert
---------------------------
RegisterNetEvent('fdb-lawman:server:lawmanAlert', function(text, coords)
    local src = source
    local ped = GetPlayerPed(src)
    local pedcoords = GetEntityCoords(ped)
    local players = FDBCore.Functions.GetRSGPlayers()

    for _, v in pairs(players) do
        if v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            if coords then
                TriggerClientEvent('fdb-lawman:client:lawmanAlert', v.PlayerData.source, coords, text)
            else
                TriggerClientEvent('fdb-lawman:client:lawmanAlert', v.PlayerData.source, pedcoords, text)
            end
        end
    end
end)

-----------------------------------
-- jail player command (law only)
-----------------------------------
FDBCore.Commands.Add('jail', locale('sv_jail'),
    { { name = 'id', help = locale('sv_jail_a') }, { name = 'time', help = locale('sv_jail_b') } }, true,
    function(source, args)
        local src = source
        local Player = FDBCore.Functions.GetPlayer(src)
        if Player.PlayerData.job.type == 'leo' then
            local playerId = tonumber(args[1])
            local time = tonumber(args[2])
            if time > 0 then
                jailPlayerByPlayer(playerId, src, time)
            else
                TriggerClientEvent('ox_lib:notify', src,
                    { title = locale('sv_jail_c'), description = locale('sv_jail_d'), type = 'inform', duration = 5000 })
            end
        end
    end)

--------------------------------------------------------------------------------------------------
-- jail player
--------------------------------------------------------------------------------------------------
function jailPlayerByPlayer(targetPlayer, byPlayer, minutes)
    local Player = FDBCore.Functions.GetPlayer(byPlayer)
    local OtherPlayer = FDBCore.Functions.GetPlayer(targetPlayer)
    local time = minutes

    local currentDate = os.date('*t')
    if currentDate.day == 31 then
        currentDate.day = 30
    end

    if Player.PlayerData.job.type == 'leo' then
        if OtherPlayer then
            OtherPlayer.Functions.SetMetaData('injail', time)
            OtherPlayer.Functions.SetMetaData('criminalrecord', { ['hasRecord'] = true, ['date'] = currentDate })
            TriggerClientEvent('fdb-lawman:client:sendtojail', OtherPlayer.PlayerData.source, time)
            TriggerClientEvent('ox_lib:notify', byPlayer,
                { title = locale('sv_injail') .. ' ' .. time, type = 'success', duration = 5000 })
        end
    end
end

RegisterNetEvent('fdb-lawman:server:jailplayer', function(playerId, minutes)
    jailPlayerByPlayer(playerId, source, minutes)
end)

------------------------------------------
-- handcuff player command
------------------------------------------
FDBCore.Commands.Add('cuff', locale('sv_cuff'), {}, false, function(source, args)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' then
        TriggerClientEvent('fdb-lawman:client:cuffplayer', src)
    end
end)

------------------------------------------
-- handcuff player use
------------------------------------------
FDBCore.Functions.CreateUseableItem('handcuffs', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent('fdb-lawman:client:cuffplayer', src)
    end
end)

------------------------------------------
-- handcuff player
------------------------------------------
RegisterNetEvent('fdb-lawman:server:cuffplayer', function(playerId, isSoftcuff)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' then
        local CuffedPlayer = FDBCore.Functions.GetPlayer(playerId)
        if CuffedPlayer then
            if Player.Functions.GetItemByName('handcuffs') then
                TriggerClientEvent('fdb-lawman:client:getcuffed', CuffedPlayer.PlayerData.source,
                    Player.PlayerData.source, isSoftcuff)
            end
        end
    end
end)

------------------------------------------
-- set handcuff status
------------------------------------------
RegisterNetEvent('fdb-lawman:server:sethandcuffstatus', function(isHandcuffed)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData('ishandcuffed', isHandcuffed)
    end
end)

------------------------------------------
-- escort player command
------------------------------------------
FDBCore.Commands.Add('escort', locale('sv_escort'), {}, false, function(source, args)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.type == 'leo' then
        TriggerClientEvent('fdb-lawman:client:escortplayer', src)
    end
end)

------------------------------------------
-- set escort status
------------------------------------------
RegisterNetEvent('fdb-lawman:server:setescortstatus', function(isEscorted)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData('isescorted', isEscorted)
    end
end)

------------------------------------------
-- escort player
------------------------------------------
RegisterNetEvent('fdb-lawman:server:escortplayer', function(playerId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.type == 'leo' then
        local EscortPlayer = FDBCore.Functions.GetPlayer(playerId)
        if EscortPlayer then
            if (EscortPlayer.PlayerData.metadata['ishandcuffed'] or EscortPlayer.PlayerData.metadata['isdead']) then
                TriggerClientEvent('fdb-lawman:client:getescorted', EscortPlayer.PlayerData.source,
                    Player.PlayerData.source)
            else
                lib.notify({ title = locale('sv_handcuffedordead'), type = 'error', duration = 5000 })
            end
        end
    end
end)

---------------------------------
-- open law storage
---------------------------------
RegisterServerEvent('fdb-lawman:server:storage', function(jobname)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local data = { label = locale('sv_storage'), maxweight = Config.StorageMaxWeight, slots = Config.StorageMaxSlots }
    local stashName = 'lawstorage' .. jobname
    exports['fdb-inventory']:OpenInventory(src, stashName, data)
end)

---------------------------------
-- update outlaw status
---------------------------------
RegisterServerEvent('fdb-lawman:server:updateoutlawstatus', function(amount, reason)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT outlawstatus FROM players WHERE citizenid = ?', { citizenid })
    local newoutlawstatus = (result[1].outlawstatus + amount)
    MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { newoutlawstatus, citizenid })
end)
