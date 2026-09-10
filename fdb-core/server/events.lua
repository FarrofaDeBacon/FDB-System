-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not FDBCore.Players[src] then return end
    local Player = FDBCore.Players[src]
    TriggerEvent('fdb-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' .. '\n **Reason:** ' .. reason)
    TriggerEvent('FDBCore:Server:PlayerDropped', Player)
    Player.Functions.Save()
    FDBCore.Player_Buckets[Player.PlayerData.license] = nil
    FDBCore.Players[src] = nil
end)

local readyFunction = MySQL.ready
local databaseConnected, bansTableExists = readyFunction == nil, readyFunction == nil
if readyFunction ~= nil then
    MySQL.ready(function()
        databaseConnected = true
    end)
end

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    for src, Player in pairs(FDBCore.Players) do
        if Player then
            FDBCore.Player.SaveOffline(Player.PlayerData)
        end
    end
end)

if readyFunction ~= nil then
    MySQL.ready(function()
        local DatabaseInfo = FDBCore.Functions.GetDatabaseInfo()
        if not DatabaseInfo or not DatabaseInfo.exists then return end

        local result = MySQL.query.await('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = "bans";', {DatabaseInfo.database})
        if result and result[1] then
            bansTableExists = true
        end
        
        local resultColumns = MySQL.query.await('SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = "players" AND COLUMN_NAME IN ("weight", "slots");', {DatabaseInfo.database})
        local columnsExist = {}
        if resultColumns then
            for _, column in ipairs(resultColumns) do
            columnsExist[column.COLUMN_NAME] = true
            end
        end

        if not columnsExist["weight"] or not columnsExist["slots"] then
            local defaultWeight = tonumber(FDBCore.Config.Player.PlayerDefaults.weight) or 100000
            local defaultSlots = tonumber(FDBCore.Config.Player.PlayerDefaults.slots) or 40
            -- Check if players table exists before altering
            local tableCheck = MySQL.query.await('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = "players";', {DatabaseInfo.database})
            if tableCheck and tableCheck[1] then
                if not columnsExist["weight"] then
                    pcall(function() MySQL.query.await(string.format('ALTER TABLE players ADD COLUMN weight INT DEFAULT %d;', defaultWeight)) end)
                end
                if not columnsExist["slots"] then
                    pcall(function() MySQL.query.await(string.format('ALTER TABLE players ADD COLUMN slots INT DEFAULT %d;', defaultSlots)) end)
                end
                FDBCore.ShowSuccess(GetCurrentResourceName(), 'Ensured weight and slots columns exist in players table')
            end
        end
    end)
end

-- Player Connecting
local function onPlayerConnecting(name, _, deferrals)
    local src = source
    deferrals.defer()

    if FDBCore.Config.Server.Closed and not IsPlayerAceAllowed(src, 'fdbadmin.join') then
        return deferrals.done(FDBCore.Config.Server.ClosedReason)
    end

    if not databaseConnected then
        return deferrals.done(Lang:t('error.connecting_database_error'))
    end

    if FDBCore.Config.Server.Whitelist then
        Wait(0)
        deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))
        if not FDBCore.Functions.IsWhitelisted(src) then
            return deferrals.done(Lang:t('error.not_whitelisted'))
        end
    end

    Wait(0)
    deferrals.update(string.format('Hello %s. Your license is being checked', name))
    local license = FDBCore.Functions.GetIdentifier(src, 'license')

    if not license then
        return deferrals.done(Lang:t('error.no_valid_license'))
    elseif FDBCore.Config.Server.CheckDuplicateLicense and FDBCore.Functions.IsLicenseInUse(license) then
        return deferrals.done(Lang:t('error.duplicate_license'))
    end

    Wait(0)
    deferrals.update(string.format(Lang:t('info.checking_ban'), name))

    if not bansTableExists then
        return deferrals.done(Lang:t('error.ban_table_not_found'))
    end

    local success, isBanned, reason = pcall(FDBCore.Functions.IsPlayerBanned, src)
    if not success then return deferrals.done(Lang:t('error.connecting_database_error')) end
    if isBanned then return deferrals.done(reason) end

    Wait(0)
    deferrals.update(string.format(Lang:t('info.join_server'), name))
    deferrals.done()

    TriggerClientEvent('FDBCore:Client:SharedUpdate', src, FDBCore.Shared)
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('FDBCore:Server:CloseServer', function(reason)
    local src = source
    if FDBCore.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        FDBCore.Config.Server.Closed = true
        FDBCore.Config.Server.ClosedReason = reason
        for k in pairs(FDBCore.Players) do
            if not FDBCore.Functions.HasPermission(k, FDBCore.Config.Server.WhitelistPermission) then
                FDBCore.Functions.Kick(k, reason, nil, nil)
            end
        end
    else
        FDBCore.Functions.Kick(src, Lang:t('error.no_permission'), nil, nil)
    end
end)

RegisterNetEvent('FDBCore:Server:OpenServer', function()
    local src = source
    if FDBCore.Functions.HasPermission(src, 'admin') then
        FDBCore.Config.Server.Closed = false
    else
        FDBCore.Functions.Kick(src, Lang:t('error.no_permission'), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('FDBCore:Server:TriggerClientCallback', function(name, ...)
    if FDBCore.ClientCallbacks[name] then
        FDBCore.ClientCallbacks[name](...)
        FDBCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
RegisterNetEvent('FDBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    FDBCore.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('FDBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('FDBCore:UpdatePlayer', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.Save()
end)

-- Whitelisted metadata keys allowed to be updated directly by client request
local AllowedClientMetaData = {}

RegisterNetEvent('FDBCore:Server:SetMetaData', function(meta, data)
    local src = source
    if not meta or not AllowedClientMetaData[meta] then return end
    if type(data) ~= 'number' or data < 0 or data > 100 then return end
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData(meta, data)
end)

RegisterNetEvent('FDBCore:ToggleDuty', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('info.off_duty'), type = 'info', duration = 5000 })
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('info.on_duty'), type = 'info', duration = 5000 })
    end

    TriggerEvent('FDBCore:Server:SetDuty', src, Player.PlayerData.job.onduty)
    TriggerClientEvent('FDBCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- Items

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('FDBCore:Server:UseItem', function(item)
    print(string.format('%s triggered FDBCore:Server:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check fdb-inventory for the right use on this event.', GetInvokingResource(), source))
    FDBCore.Debug(item)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot)
RegisterNetEvent('FDBCore:Server:RemoveItem', function(itemName, amount)
    local src = source
    print(string.format('%s triggered FDBCore:Server:RemoveItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.', GetInvokingResource(), src, amount, itemName))
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot, info)
RegisterNetEvent('FDBCore:Server:AddItem', function(itemName, amount)
    local src = source
    print(string.format('%s triggered FDBCore:Server:AddItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.', GetInvokingResource(), src, amount, itemName))
end)

-- Non-Chat Command Calling (ex: fdb-adminmenu)

RegisterNetEvent('FDBCore:CallCommand', function(command, args)
    local src = source
    if not FDBCore.Commands.List[command] then return end
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local hasPerm = FDBCore.Functions.HasPermission(src, 'command.' .. FDBCore.Commands.List[command].name)
    if hasPerm then
        if FDBCore.Commands.List[command].argsrequired and #FDBCore.Commands.List[command].arguments ~= 0 and not args[#FDBCore.Commands.List[command].arguments] then
            TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('error.missing_args2'), type = 'error', duration = 5000 })
        else
            FDBCore.Commands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {title = Lang:t('error.no_access'), type = 'error', duration = 5000 })
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
FDBCore.Functions.CreateCallback('FDBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local veh = FDBCore.Functions.SpawnVehicle(source, model, coords, warp)
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

RegisterNetEvent('FDBCore:Server:KickCSRF', function()
    DropPlayer(source, 'CSRF validation failed')
end)