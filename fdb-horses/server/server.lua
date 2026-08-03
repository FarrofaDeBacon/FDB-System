local RSGCore = exports['rsg-core']:GetCoreObject()
local HorseSettings = lib.load('shared.horse_settings')
local HorseComp = lib.load('shared.horse_comp')
lib.locale()

----------------------------------
-- security helpers
----------------------------------
local tradeRequests = {} -- Store pending trade requests

local function VerifyHorseOwnership(citizenid, horseid)
    local result = MySQL.scalar.await('SELECT COUNT(*) FROM fdb_horses WHERE citizenid = ? AND horseid = ?', {citizenid, horseid})
    return result and result > 0
end

local function ValidateComponents(components)
    if type(components) ~= "table" then
        return false, "Invalid component type"
    end
    
    for category, value in pairs(components) do
        if not HorseComp[category] then
            return false, "Invalid category: " .. tostring(category)
        end
        
        if type(value) ~= "number" or value < 0 or value > #HorseComp[category] then
            return false, "Invalid component value for " .. category
        end
    end
    
    return true
end

----------------------------------
-- commands
----------------------------------
RSGCore.Commands.Add('findhorse', locale('sv_command_find'), {}, false, function(source)
    local src = source
    TriggerClientEvent('fdb-horses:client:gethorselocation', src)
end)

RSGCore.Commands.Add('accepttrade', locale('sv_command_accept_trade'), {}, false, function(source)
    local src = source
    local trade = tradeRequests[src]
    
    if not trade then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_trade_request'), type = 'error', duration = 5000 })
        return
    end
    
    TriggerServerEvent('fdb-horses:server:AcceptTrade', trade.from)
end)

----------------------------------
-- get all horses
----------------------------------
RSGCore.Functions.CreateCallback('fdb-horses:server:GetAllHorses', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local horses = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid=@citizenid', { ['@citizenid'] = Player.PlayerData.citizenid })    
    if horses[1] ~= nil then
        cb(horses)
    else
        cb(nil)
    end
end)

----------------------------------
-- horse use items
----------------------------------
-- brush horse: servidor remove item, calcula limpeza, persiste, notifica client
RSGCore.Functions.CreateUseableItem('horse_brush', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item.name], 'remove', 1)

        local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
        if not activehorse then
            TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_error_no_horse_out'), type = 'error', duration = 5000 })
            return
        end

        -- Lê metadata atual, aplica limpeza, persiste
        local row = MySQL.query.await('SELECT metadata FROM fdb_horses WHERE id = ?', {activehorse})
        local meta = (row and row[1] and row[1].metadata and json.decode(row[1].metadata)) or {}
        meta.dirt = 0

        MySQL.update('UPDATE fdb_horses SET dirt = 0, metadata = ? WHERE id = ?', { json.encode(meta), activehorse })

        -- Notifica client com o campo calculado pelo servidor
        TriggerClientEvent('fdb-horses:client:stateChanged', src, { dirt = 0 })
        TriggerClientEvent('fdb-horses:client:playerbrushhorse', src, item.name)
    end
end)

-- player horselantern
RSGCore.Functions.CreateUseableItem('horse_lantern', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    TriggerClientEvent('fdb-horses:client:equipHorseLantern', source, item.name)
end)

 -- horse stimulant
RSGCore.Functions.CreateUseableItem('horse_stimulant', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item.name], 'remove', 1)
        -- Estimulante restaura vida/stamina core nativos; não altera metadata de sobrevivência
        TriggerClientEvent('fdb-horses:client:playerfeedhorse', src, item.name)
    end
end)

-- horse medicine (cura illness + poison): registrar item antes de usar
if RSGCore.Shared.Items['horse_medicine'] then
    RSGCore.Functions.CreateUseableItem('horse_medicine', function(source, item)
        local src = source
        local Player = RSGCore.Functions.GetPlayer(src)
        if not Player then return end
        if Player.Functions.RemoveItem(item.name, 1, item.slot) then
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item.name], 'remove', 1)

            local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
            if not activehorse then return end

            local row = MySQL.query.await('SELECT metadata FROM fdb_horses WHERE id = ?', {activehorse})
            local meta = (row and row[1] and row[1].metadata and json.decode(row[1].metadata)) or {}
            local feedData = Config.HorseFeed[item.name]
            meta.illness = 0
            meta.poison  = 0

            MySQL.update('UPDATE fdb_horses SET metadata = ? WHERE id = ?', { json.encode(meta), activehorse })

            -- Envia de volta ao client apenas os campos alterados
            TriggerClientEvent('fdb-horses:client:stateChanged', src, { illness = 0, poison = 0 })
            TriggerClientEvent('fdb-horses:client:playerfeedhorse', src, item.name)
        end
    end)
end

-- carrot: servidor lê Config.HorseFeed, calcula, persiste, envia ao client
RSGCore.Functions.CreateUseableItem('horse_carrot', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item.name], 'remove', 1)

        local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
        if not activehorse then return end

        local row = MySQL.query.await('SELECT metadata FROM fdb_horses WHERE id = ?', {activehorse})
        local meta = (row and row[1] and row[1].metadata and json.decode(row[1].metadata)) or {}
        local feedData = Config.HorseFeed[item.name]

        meta.hunger = math.min(100, (meta.hunger or 100) + (feedData.hunger or 0))
        meta.thirst = math.min(100, (meta.thirst or 100) + (feedData.thirst or 0))
        meta.agitation = math.max(0, (meta.agitation or 0) - 20)

        MySQL.update('UPDATE fdb_horses SET metadata = ? WHERE id = ?', { json.encode(meta), activehorse })

        TriggerClientEvent('fdb-horses:client:stateChanged', src, { hunger = meta.hunger, thirst = meta.thirst, agitation = meta.agitation })
        TriggerClientEvent('fdb-horses:client:playerfeedhorse', src, item.name)
    end
end)

-- apple: mesmo padrão que carrot
RSGCore.Functions.CreateUseableItem('horse_apple', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item.name], 'remove', 1)

        local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
        if not activehorse then return end

        local row = MySQL.query.await('SELECT metadata FROM fdb_horses WHERE id = ?', {activehorse})
        local meta = (row and row[1] and row[1].metadata and json.decode(row[1].metadata)) or {}
        local feedData = Config.HorseFeed[item.name]

        meta.hunger = math.min(100, (meta.hunger or 100) + (feedData.hunger or 0))
        meta.thirst = math.min(100, (meta.thirst or 100) + (feedData.thirst or 0))
        meta.agitation = math.max(0, (meta.agitation or 0) - 20)

        MySQL.update('UPDATE fdb_horses SET metadata = ? WHERE id = ?', { json.encode(meta), activehorse })

        TriggerClientEvent('fdb-horses:client:stateChanged', src, { hunger = meta.hunger, thirst = meta.thirst, agitation = meta.agitation })
        TriggerClientEvent('fdb-horses:client:playerfeedhorse', src, item.name)
    end
end)

-- feed horse sugarcube
RSGCore.Functions.CreateUseableItem('sugarcube', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-horses:client:playerfeedhorse', source, item.name)
    end
end)

-- feed horse haysnack
RSGCore.Functions.CreateUseableItem('haysnack', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-horses:client:playerfeedhorse', source, item.name)
    end
end)

-- feed horse horsemeal
RSGCore.Functions.CreateUseableItem('horsemeal', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-horses:client:playerfeedhorse', source, item.name)
    end
end)

----------------------------------
-- horse reviver
----------------------------------
RSGCore.Functions.CreateUseableItem('horse_reviver', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid=@citizenid AND active=@active', { ['@citizenid'] = cid, ['@active'] = 1 })

    if not result[1] then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_active_horse'), type = 'error', duration = 5000 })
        return
    end

    -- remove item first (server-authoritative), then trigger revive
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item.name], 'remove', 1)
        TriggerClientEvent('fdb-horses:client:revivehorse', src, item, result[1])
    end
end)

----------------------------------
-- buy & active
----------------------------------
RegisterServerEvent('fdb-horses:server:BuyHorse', function(model, stable, horsename, gender)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    -- SECURITY: Validate horse name
    if not horsename or type(horsename) ~= "string" then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_invalid_horse_name'), type = 'error', duration = 5000 })
        return
    end
    horsename = string.gsub(horsename, "[^%w%s%-_]", "")
    if #horsename < 1 or #horsename > 50 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_horse_name_length'), type = 'error', duration = 5000 })
        return
    end

    local horseInfo = nil
    for k,v in pairs(HorseSettings) do
        if v.horsemodel == model then
            horseInfo = v
            break
        end
    end

    if not horseInfo then
        warn(('fdb-horses: Buy Horse. Unexpected horse model %s'):format(model))
        return
    end

    local price = horseInfo.horseprice
    
    -- SECURITY: Atomic transaction - remove money first
    if not Player.Functions.RemoveMoney('cash', price) then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_cash'), type = 'error', duration = 5000 })
        return
    end
    
    -- Money removed successfully, now safe to create horse
    local horseid = GenerateHorseid()
    MySQL.insert('INSERT INTO fdb_horses(stable, citizenid, horseid, name, horse, gender, active, born) VALUES(@stable, @citizenid, @horseid, @name, @horse, @gender, @active, @born)', {
        ['@stable'] = stable,
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@horseid'] = horseid,
        ['@name'] = horsename,
        ['@horse'] = model,
        ['@gender'] = gender,
        ['@active'] = false,
        ['@born'] = os.time()
    })
    
    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_horse_owned'), type = 'success', duration = 5000 })
end)

-----------------------------------
-- set horse active
-----------------------------------
RegisterServerEvent('fdb-horses:server:SetHoresActive', function(id)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local owned = MySQL.scalar.await('SELECT COUNT(*) FROM fdb_horses WHERE id = ? AND citizenid = ?', {id, Player.PlayerData.citizenid})
    if not owned or owned == 0 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_horse'), type = 'error', duration = 5000 })
        return
    end
    
    local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
    if activehorse then
        MySQL.update('UPDATE fdb_horses SET active = ? WHERE id = ? AND citizenid = ?', { false, activehorse, Player.PlayerData.citizenid })
    end
    MySQL.update('UPDATE fdb_horses SET active = ? WHERE id = ? AND citizenid = ?', { true, id, Player.PlayerData.citizenid })
end)

-----------------------------------
-- set horse unactive
-----------------------------------
RegisterServerEvent('fdb-horses:server:SetHoresUnActive', function(id, stableid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local owned = MySQL.scalar.await('SELECT COUNT(*) FROM fdb_horses WHERE id = ? AND citizenid = ?', {id, Player.PlayerData.citizenid})
    if not owned or owned == 0 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_horse'), type = 'error', duration = 5000 })
        return
    end
    
    MySQL.update('UPDATE fdb_horses SET active = ? WHERE citizenid = ? AND active = ?', { false, Player.PlayerData.citizenid, true })
    MySQL.update('UPDATE fdb_horses SET stable = ? WHERE id = ? AND citizenid = ?', { stableid, id, Player.PlayerData.citizenid })
end)

-----------------------------------
-- store horse when flee is used
-----------------------------------
RegisterServerEvent('fdb-horses:server:fleeStoreHorse', function(stableid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    if not activehorse then return end
    MySQL.update('UPDATE fdb_horses SET active = ? WHERE id = ? AND citizenid = ?', { 0, activehorse, Player.PlayerData.citizenid })
    MySQL.update('UPDATE fdb_horses SET stable = ? WHERE id = ? AND citizenid = ?', { stableid, activehorse, Player.PlayerData.citizenid })
end)

-----------------------------------
-- rename horse
-----------------------------------
RegisterServerEvent('fdb-horses:renameHorse', function(name)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- SECURITY: Validate input
    if not name or type(name) ~= "string" then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_invalid_horse_name'), type = 'error', duration = 5000 })
        return
    end
    
    -- Remove special characters
    name = string.gsub(name, "[^%w%s%-_]", "")
    
    if #name < 1 or #name > 50 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_horse_name_length'), type = 'error', duration = 5000 })
        return
    end
    
    local newName = MySQL.query.await('UPDATE fdb_horses SET name = ? WHERE citizenid = ? AND active = ?' , {name, Player.PlayerData.citizenid, 1})

    if newName == nil then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_name_change_failed'), type = 'error', duration = 5000 })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_name_change').. ' \''..name..'\' '..locale('sv_success_successfully'), type = 'success', duration = 5000 })
end)

----------------------------------
-- horse death handler
----------------------------------
RegisterServerEvent('fdb-horses:server:HorseDied', function(horseid, horsename)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    
    -- Get horse data (must be active/spawned to die)
    local horse = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid = @citizenid AND horseid = @horseid AND active = @active', {
        ['@citizenid'] = cid,
        ['@horseid'] = horseid,
        ['@active'] = 1
    })
    
    if horse[1] then
        local horsestash = horse[1].name .. ' ' .. horseid
        
        -- Clear horse inventory stash from database
        -- Horse stashes are stored as identifiers in the inventories table
        MySQL.update('DELETE FROM inventories WHERE identifier = ?', {horsestash})
        
        -- Remove horse from database
        MySQL.update('DELETE FROM fdb_horses WHERE citizenid = ? AND horseid = ?', {cid, horseid})
        
        -- Log the death
        TriggerEvent('rsg-log:server:CreateLog', 'horsetrainer', locale('sv_log_horse_trainer'), 'red', horsename .. ' ' .. locale('sv_log_horse_belong') .. ' ' .. cid .. ' ' .. locale('sv_log_horse_dead'))
        
        lib.notify(src, {title = locale('sv_error_horse_died'), type = 'error', duration = 7000})
    end
end)

----------------------------------
-- sell horse
----------------------------------
RegisterServerEvent('fdb-horses:server:deletehorse', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local horseid = data.horseid
    
    -- SECURITY: Verify ownership before selling
    local fdb_horses = MySQL.query.await('SELECT * FROM fdb_horses WHERE id = @id AND `citizenid` = @citizenid', {
        ['@id'] = horseid,
        ['@citizenid'] = Player.PlayerData.citizenid
    })
    
    if not fdb_horses or #fdb_horses == 0 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_horse'), type = 'error', duration = 5000 })
        return
    end
    
    local modelHorse = nil
    for i = 1, #fdb_horses do
        if tonumber(fdb_horses[i].id) == tonumber(horseid) then
            modelHorse = fdb_horses[i].horse
            
            -- Delete horse inventory
            local horsestash = fdb_horses[i].name .. ' ' .. fdb_horses[i].horseid
            MySQL.update('DELETE FROM inventories WHERE identifier = ?', {horsestash})
            
            -- Delete horse
            MySQL.update('DELETE FROM fdb_horses WHERE id = ? AND citizenid = ?', { data.horseid, Player.PlayerData.citizenid })
        end
    end
    
    for k, v in pairs(HorseSettings) do
        if v.horsemodel == modelHorse then
            local sellprice = v.horseprice * 0.5
            Player.Functions.AddMoney('cash', sellprice)
            TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_horse_sold_for')..sellprice, type = 'success', duration = 5000 })
            break
        end
    end
end)

-----------------------------------
-- get horses
-----------------------------------
lib.callback.register('fdb-horses:server:GetHorse', function(source, stable)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return {} end
    local Result = {}
    if stable and stable ~= '' then
        Result = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid = ? AND stable = ?', { Player.PlayerData.citizenid, stable })
    else
        Result = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid = ?', { Player.PlayerData.citizenid })
    end
    return Result or {}
end)

-----------------------------------
-- get active horse
-----------------------------------
RSGCore.Functions.CreateCallback('fdb-horses:server:GetActiveHorse', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid=@citizenid AND active=@active', { ['@citizenid'] = cid, ['@active'] = 1 })
    if (result[1] ~= nil) then
        cb(result[1])
    else
        return
    end
end)

-----------------------------------
-- horse customization
----------------------------------
-- get active horse components callback
RSGCore.Functions.CreateCallback('fdb-horses:server:CheckComponents', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local Playercid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid=@citizenid AND active=@active', {
        ['@citizenid'] = Playercid,
        ['@active'] = 1
    })
    if (result[1] ~= nil) then
        cb(result[1])
    else
        return
    end
end)

-----------------------------------
-- save saddle
-----------------------------------
RegisterNetEvent('fdb-horses:server:SaveComponents', function(newComponents, horseid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    -- SECURITY: Validate components
    local valid, error = ValidateComponents(newComponents)
    if not valid then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_invalid_components') .. error, type = 'error', duration = 5000 })
        return
    end

    local citizenid = Player.PlayerData.citizenid
    
    -- SECURITY: Verify ownership
    local result = MySQL.query.await('SELECT * FROM fdb_horses WHERE citizenid=@citizenid AND horseid=@horseid', { ['@citizenid'] = citizenid, ['@horseid'] = horseid })
    local horseData = result[1]
    
    if not horseData then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_horse'), type = 'error', duration = 5000 })
        return
    end
    
    local currentComponents = json.decode(horseData.components) or {}
    local price = CalculatePrice(newComponents, currentComponents)

    if Player.Functions.RemoveMoney('cash', price) then
        MySQL.update('UPDATE fdb_horses SET components = @components WHERE id = @id', {['@components'] = json.encode(newComponents), ['@id'] = horseData.id})
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_component_saved') .. price, type = 'success', duration = 5000 })
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_cash'), type = 'error', duration = 5000 })
    end
end)

-----------------------------------
-- trade horse (request)
-----------------------------------
RegisterNetEvent('fdb-horses:server:TradeHorse', function(playerId, horseId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Target = RSGCore.Functions.GetPlayer(playerId)
    
    if not Player or not Target then return end
    
    -- SECURITY: Verify ownership
    local horse = MySQL.query.await('SELECT * FROM fdb_horses WHERE horseid = ? AND citizenid = ? AND active = ?', 
        {horseId, Player.PlayerData.citizenid, 1})
    
    if not horse or not horse[1] then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_or_active'), type = 'error', duration = 5000 })
        return
    end
    
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    if not playerPed or not targetPed then return end
    
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > 5.0 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_player_too_far'), type = 'error', duration = 5000 })
        return
    end
    
    -- Send trade request to target
    tradeRequests[playerId] = {
        from = src,
        horseId = horseId,
        horseName = horse[1].name,
        horseModel = horse[1].horse,
        expires = os.time() + 30
    }
    
    TriggerClientEvent('ox_lib:notify', playerId, {
        title = locale('sv_trade_request_title'), 
        description = string.format(locale('sv_trade_request_desc'), GetPlayerName(src), horse[1].name),
        type = 'info', 
        duration = 30000 
    })
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = string.format(locale('sv_trade_request_sent'), GetPlayerName(playerId)), 
        type = 'success', 
        duration = 5000 
    })
end)

-----------------------------------
-- trade horse (accept)
-----------------------------------
RegisterNetEvent('fdb-horses:server:AcceptTrade', function(fromId)
    local src = source
    local trade = tradeRequests[src]
    
    if not trade then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_trade_request'), type = 'error', duration = 5000 })
        return
    end
    
    if trade.from ~= fromId then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_invalid_trade_request'), type = 'error', duration = 5000 })
        return
    end
    
    if os.time() > trade.expires then
        tradeRequests[src] = nil
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_trade_expired'), type = 'error', duration = 5000 })
        return
    end
    
    local Target = RSGCore.Functions.GetPlayer(src)
    local Sender = RSGCore.Functions.GetPlayer(fromId)
    
    if not Target or not Sender then
        tradeRequests[src] = nil
        return
    end
    
    -- Verify horse still exists and is owned by sender
    local horse = MySQL.query.await('SELECT * FROM fdb_horses WHERE horseid = ? AND citizenid = ?', 
        {trade.horseId, Sender.PlayerData.citizenid})
    
    if not horse or not horse[1] then
        tradeRequests[src] = nil
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_horse_unavailable'), type = 'error', duration = 5000 })
        TriggerClientEvent('ox_lib:notify', fromId, {title = locale('sv_error_trade_failed'), type = 'error', duration = 5000 })
        return
    end
    
    -- Proceed with trade
    MySQL.update('UPDATE fdb_horses SET citizenid = ?, active = ? WHERE horseid = ?', {Target.PlayerData.citizenid, 0, trade.horseId})
    
    -- Deactivate target's current active horse if they have one
    MySQL.update('UPDATE fdb_horses SET active = ? WHERE citizenid = ? AND active = ?', {0, Target.PlayerData.citizenid, 1})
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = string.format(locale('sv_trade_received'), trade.horseName), 
        type = 'success', 
        duration = 7000 
    })
    
    TriggerClientEvent('ox_lib:notify', fromId, {
        title = string.format(locale('sv_trade_success'), GetPlayerName(src)), 
        type = 'success', 
        duration = 7000 
    })
    
    tradeRequests[src] = nil
end)

-----------------------------------
-- move horse between stables
-----------------------------------
RegisterServerEvent('fdb-horses:server:MoveHorse', function(horseId, newStableId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    -- verify player is near a stable
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local nearStable = false
    for _, stable in pairs(Config.StableSettings) do
        if #(coords - stable.coords) < 10.0 then
            nearStable = true
            break
        end
    end
    if not nearStable then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_at_stable'), type = 'error', duration = 5000 })
        return
    end

    local horse = MySQL.query.await('SELECT * FROM fdb_horses WHERE id = ? AND citizenid = ?', {horseId, citizenid})
    
    if not horse or not horse[1] then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_horse'), type = 'error', duration = 5000 })
        return
    end

    local currentStable = nil
    local newStable = nil
    
    for _, stableConfig in pairs(Config.StableSettings) do
        if stableConfig.stableid == horse[1].stable then
            currentStable = stableConfig
        end
        if stableConfig.stableid == newStableId then
            newStable = stableConfig
        end
    end

    if not newStable then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_invalid_stable'), type = 'error', duration = 5000 })
        return
    end

    if horse[1].stable == newStableId then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_horse_already_there'), type = 'error', duration = 5000 })
        return
    end

    if not currentStable then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_invalid_stable'), type = 'error', duration = 5000 })
        return
    end

    local baseFee = Config.MoveHorseBasePrice
    local feePerMeter = Config.MoveFeePerMeter
    local distance = #(currentStable.coords - newStable.coords)
    local moveFee = math.ceil(baseFee + (distance * feePerMeter))

    if not Player.Functions.RemoveMoney('cash', moveFee) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_error_insufficient_funds'),
            description = string.format('Cost: $%d', moveFee),
            type = 'error',
            duration = 5000
        })
        return
    end

    MySQL.update('UPDATE fdb_horses SET stable = ? WHERE id = ? AND citizenid = ?', {newStableId, horseId, citizenid})

    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('sv_success_horse_moved'),
        description = string.format(locale('sv_success_horse_moved_desc'), horse[1].name, newStableId, moveFee),
        type = 'success',
        duration = 5000
    })
end)

-----------------------------------
-- generate horseid
-----------------------------------
function GenerateHorseid()
    local UniqueFound = false
    local horseid = nil
    while not UniqueFound do
        horseid = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM fdb_horses WHERE horseid = ?', { horseid })
        if result == 0 then
            UniqueFound = true
        end
    end
    return horseid
end

----------------------------------
-- others
----------------------------------
-- Check if Player has horsebrush before brush the horse
RegisterServerEvent('fdb-horses:server:brushhorse', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemByName(item) then
        TriggerClientEvent('fdb-horses:client:playerbrushhorse', source, item)
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_brush')..' '..item, type = 'error', duration = 5000 })
    end
end)

-----------------------------------
-- horse attributes to database
-----------------------------------
RegisterServerEvent('fdb-horses:server:sethorseAttributes', function(dirt)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    dirt = tonumber(dirt)
    if not dirt or dirt < 0 or dirt > 100 then return end

    local activehorse = MySQL.scalar.await('SELECT id FROM fdb_horses WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
    if not activehorse then return end
    MySQL.update('UPDATE fdb_horses SET dirt = ? WHERE id = ? AND citizenid = ?', { dirt, activehorse, Player.PlayerData.citizenid })
end)

RegisterServerEvent('fdb-horses:server:SetPlayerBucket', function(random, ped)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if not ped or type(ped) ~= "number" or ped <= 0 then return end
    if random then
        local BucketID = RSGCore.Shared.RandomInt(1000, 9999)
        SetRoutingBucketPopulationEnabled(BucketID, false)
        SetPlayerRoutingBucket(source, BucketID)
        SetPlayerRoutingBucket(ped, BucketID)
    else
        SetPlayerRoutingBucket(source, 0)
        SetPlayerRoutingBucket(ped, 0)
    end
end)

---------------------------------
-- horse inventory
---------------------------------
RegisterNetEvent('fdb-horses:server:openhorseinventory', function(horseid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    -- verify ownership
    local horse = MySQL.query.await('SELECT * FROM fdb_horses WHERE horseid = ? AND citizenid = ?', {horseid, Player.PlayerData.citizenid})
    if not horse[1] then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_not_own_horse'), type = 'error', duration = 5000 })
        return
    end

    local horsestash = horse[1].name .. ' ' .. horse[1].horseid
    local horsexp = horse[1].horsexp

    -- calculate inventory capacity based on xp (server-authoritative)
    local invWeight, invSlots
    if horsexp <= 99 then
        invWeight = Config.Level1InvWeight
        invSlots = Config.Level1InvSlots
    elseif horsexp <= 199 then
        invWeight = Config.Level2InvWeight
        invSlots = Config.Level2InvSlots
    elseif horsexp <= 299 then
        invWeight = Config.Level3InvWeight
        invSlots = Config.Level3InvSlots
    elseif horsexp <= 399 then
        invWeight = Config.Level4InvWeight
        invSlots = Config.Level4InvSlots
    elseif horsexp <= 499 then
        invWeight = Config.Level5InvWeight
        invSlots = Config.Level5InvSlots
    elseif horsexp <= 999 then
        invWeight = Config.Level6InvWeight
        invSlots = Config.Level6InvSlots
    elseif horsexp <= 1999 then
        invWeight = Config.Level7InvWeight
        invSlots = Config.Level7InvSlots
    elseif horsexp <= 2999 then
        invWeight = Config.Level8InvWeight
        invSlots = Config.Level8InvSlots
    elseif horsexp <= 3999 then
        invWeight = Config.Level9InvWeight
        invSlots = Config.Level9InvSlots
    else
        invWeight = Config.Level10InvWeight
        invSlots = Config.Level10InvSlots
    end

    local data = { label = locale('sv_horse_inventory'), maxweight = invWeight, slots = invSlots }
    exports['rsg-inventory']:OpenInventory(src, horsestash, data)
end)

--------------------------------------
-- register shop
--------------------------------------
CreateThread(function()
    Wait(2000) -- Aguarda carregamento do inventário
    local shopData = {
        name = 'horse',
        label = locale('cl_horse_shop'),
        slots = #Config.horsesShopItems,
        items = Config.horsesShopItems,
        persistentStock = Config.PersistStock,
    }
    local success, err = pcall(function()
        if GetResourceState('fdb-inventory') == 'started' then
            return exports['fdb-inventory']:CreateShop(shopData)
        elseif GetResourceState('rsg-inventory') == 'started' then
            return exports['rsg-inventory']:CreateShop(shopData)
        end
    end)
    if not success then
        print(('[fdb-horses] Erro ao criar loja de cavalos no inventario: %s'):format(tostring(err)))
    end
end)

--------------------------------------
-- open shop
--------------------------------------
RegisterNetEvent('fdb-horses:server:openShop', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    -- verify player is near a stable
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local nearStable = false
    for _, stable in pairs(Config.StableSettings) do
        if #(coords - stable.coords) < 10.0 then
            nearStable = true
            break
        end
    end

    if not nearStable then return end

    local success, err = pcall(function()
        if GetResourceState('fdb-inventory') == 'started' then
            return exports['fdb-inventory']:OpenShop(src, 'horse')
        elseif GetResourceState('rsg-inventory') == 'started' then
            return exports['rsg-inventory']:OpenShop(src, 'horse')
        end
    end)
    if not success then
        print(('[fdb-horses] Erro ao abrir loja de cavalos para src %s: %s'):format(src, tostring(err)))
        TriggerClientEvent('ox_lib:notify', src, { title = 'Erro ao abrir loja de itens.', type = 'error', duration = 5000 })
    end
end)

----------------------------------
-- horse check system
----------------------------------
UpkeepInterval = function()

    local result = MySQL.query.await('SELECT * FROM fdb_horses')

    if not result then return end

    for i = 1, #result do
        local id = result[i].id
        local horsetype = result[i].horse
        local horsename = result[i].name
        local ownercid = result[i].citizenid
        local currentTime = os.time()
        local timeDifference = currentTime - result[i].born
        local daysPassed = math.floor(timeDifference / (24 * 60 * 60))

        --print(id, horsetype, horsename, ownercid, daysPassed)

        if horsetype == 'a_c_horse_mp_mangy_backup' and daysPassed >= Config.StarterHorseDieAge then
            
            -- Get horseid for inventory cleanup
            local horsedata = MySQL.query.await('SELECT horseid FROM fdb_horses WHERE id = ?', {id})
            if horsedata[1] then
                local horsestash = horsename .. ' ' .. horsedata[1].horseid
                
                -- Clear horse inventory stash from database
                MySQL.update('DELETE FROM inventories WHERE identifier = ?', {horsestash})
            end

            -- delete horse
            MySQL.update('DELETE FROM fdb_horses WHERE id = ?', {id})
            TriggerEvent('rsg-log:server:CreateLog', 'horsetrainer', locale('sv_log_horse_trainer'), 'red', horsename..' '..locale('sv_log_horse_belong')..' '..ownercid..' '..locale('sv_log_horse_dead'))

            -- telegram message to the horse owner
            MySQL.insert('INSERT INTO telegrams (citizenid, recipient, sender, sendername, subject, sentDate, message) VALUES (?, ?, ?, ?, ?, ?, ?)',
            {   ownercid,
                locale('sv_telegram_owner'),
                '22222222',
                locale('sv_telegram_stables'),
                horsename..' '..locale('sv_telegram_away'),
                os.date('%x'),
                locale('sv_telegram_inform')..' '..horsename..' '..locale('sv_telegram_has_passed'),
            })

            goto continue
        end

        if daysPassed >= Config.HorseDieAge then
            
            -- Get horseid for inventory cleanup
            local horsedata = MySQL.query.await('SELECT horseid FROM fdb_horses WHERE id = ?', {id})
            if horsedata[1] then
                local horsestash = horsename .. ' ' .. horsedata[1].horseid
                
                -- Clear horse inventory
                local success = pcall(function()
                    exports['rsg-inventory']:ClearInventory(horsestash)
                end)
                
                if not success then
                    MySQL.update('DELETE FROM inventories WHERE identifier = ?', {horsestash})
                end
            end

            -- delete horse
            MySQL.update('DELETE FROM fdb_horses WHERE id = ?', {id})
            TriggerEvent('rsg-log:server:CreateLog', 'horsetrainer', locale('sv_log_horse_trainer'), 'red', horsename..' '..locale('sv_log_horse_belong')..' '..ownercid..' '..locale('sv_log_horse_dead'))

            -- telegram message to the horse owner
            MySQL.insert('INSERT INTO telegrams (citizenid, recipient, sender, sendername, subject, sentDate, message) VALUES (?, ?, ?, ?, ?, ?, ?)',
            {   ownercid,
                locale('sv_telegram_owner'),
                '22222222',
                locale('sv_telegram_stables'),
                horsename..' '..locale('sv_telegram_away'),
                os.date('%x'),
                locale('sv_telegram_inform')..' '..horsename..' '..locale('sv_telegram_has_passed'),
            })

            goto continue
        end

        ::continue::
    end

    if Config.EnableServerNotify then
        print(locale('sv_print'))
    end

    SetTimeout(Config.CheckCycle * (60 * 1000), UpkeepInterval)
end

SetTimeout(Config.CheckCycle * (60 * 1000), UpkeepInterval)


-- ============================================================
-- FASE C — Registro de NetworkId de cavalos ativos
-- Client envia o netId ao spawnar/despawnar.
-- Servidor usa isso para escrever statebags na entidade.
-- NENHUM client escreve dirtTier/agitationTier/isExhausted.
-- ============================================================
local activeHorseNetIds = {}  -- [citizenid] = networkId

RegisterNetEvent('fdb-horses:server:RegisterHorseNet', function(netId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if type(netId) ~= 'number' then return end

    -- Valida que a entidade existe e é um ped
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return end
    if GetEntityType(entity) ~= 3 then return end  -- 3 = ped

    -- Cruza com o banco: confirma que o modelo da entidade bate com o cavalo
    -- ativo deste jogador. Impede que client registre netId de entidade arbitrária.
    local row = MySQL.query.await(
        'SELECT horse FROM fdb_horses WHERE citizenid = ? AND active = 1',
        { Player.PlayerData.citizenid }
    )
    if not row or not row[1] or not row[1].horse then return end

    local expectedModel = GetHashKey(row[1].horse)
    if GetEntityModel(entity) ~= expectedModel then
        print(('[fdb-horses] RegisterHorseNet rejeitado: modelo inesperado de src %s (cidadao: %s)'):format(src, Player.PlayerData.citizenid))
        return
    end

    activeHorseNetIds[Player.PlayerData.citizenid] = netId
end)

RegisterNetEvent('fdb-horses:server:UnregisterHorseNet', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    activeHorseNetIds[Player.PlayerData.citizenid] = nil
end)

-- Helper: converte valor numérico em categoria (nunca exposto ao client como número bruto)
local function GetDirtTier(dirt)
    if dirt >= 90 then return 'filthy'
    elseif dirt >= 61 then return 'dirty'
    elseif dirt >= 26 then return 'dusty'
    else return 'clean'
    end
end

local function GetAgitationTier(agitation)
    if agitation >= 66 then return 'agitated'
    elseif agitation >= 31 then return 'nervous'
    else return 'calm'
    end
end

-- ============================================================
-- LOOP DE METABOLISMO SERVER-SIDE (espelho exato do fdb-survival)
-- O servidor é o único que calcula e persiste dreno de fome/sede/sujeira/doença.
-- O client só recebe o resultado via stateChanged e aplica efeitos visuais.
-- ============================================================
CreateThread(function()
    while true do
        Wait(Config.Metabolism.DrainInterval)

        -- Busca todos os cavalos ativos no momento
        local activeHorses = MySQL.query.await(
            'SELECT id, citizenid, metadata, dirt FROM fdb_horses WHERE active = 1'
        )
        if not activeHorses or #activeHorses == 0 then goto continue_metabolism end

        for _, horse in ipairs(activeHorses) do
            local horseId   = horse.id
            local citizenid = horse.citizenid
            local meta      = (horse.metadata and horse.metadata ~= '' and json.decode(horse.metadata)) or {}

            -- Lê valores atuais com defaults seguros
            local hunger    = math.max(0, math.min(100, tonumber(meta.hunger)    or 100))
            local thirst    = math.max(0, math.min(100, tonumber(meta.thirst)    or 100))
            local dirt      = math.max(0, math.min(100, tonumber(meta.dirt)      or (horse.dirt or 0)))
            local illness   = math.max(0, math.min(100, tonumber(meta.illness)   or 0))
            local poison    = math.max(0, math.min(100, tonumber(meta.poison)    or 0))
            local agitation = math.max(0, math.min(100, tonumber(meta.agitation) or 0))

            -- Multiplicador de doença (igual ao player: dobra o dreno)
            local illnessMult = (illness > 0) and 2.0 or 1.0

            -- Calcula novos valores — SERVIDOR é o único que faz isso
            local newHunger    = math.max(0, hunger - (Config.Metabolism.HungerDrain * illnessMult))
            local newThirst    = math.max(0, thirst - (Config.Metabolism.ThirstDrain * illnessMult))
            local newDirt      = math.min(100, dirt + Config.Metabolism.DirtAccumulation)
            local newAgitation = math.max(0, agitation - Config.Metabolism.AgitationDecay)

            -- Doença por sujeira extrema (2% de chance por tick, igual ao padrão definido)
            local newIllness = illness
            if newDirt >= 90 and illness < 100 then
                if math.random(1, 100) <= 2 then
                    newIllness = math.min(100, illness + 10)
                end
            end

            -- Persiste no banco
            meta.hunger    = math.floor(newHunger)
            meta.thirst    = math.floor(newThirst)
            meta.dirt      = math.floor(newDirt)
            meta.illness   = math.floor(newIllness)
            meta.poison    = math.floor(poison)
            meta.agitation = math.floor(newAgitation)

            MySQL.update(
                'UPDATE fdb_horses SET metadata = ?, dirt = ? WHERE id = ?',
                { json.encode(meta), math.floor(newDirt), horseId }
            )

            -- Encontra o src do dono do cavalo (se estiver online)
            local players = RSGCore.Functions.GetPlayers()
            for _, src in ipairs(players) do
                local Player = RSGCore.Functions.GetPlayer(src)
                if Player and Player.PlayerData.citizenid == citizenid then
                    -- Envia campos atualizados ao client — client só lê, nunca calcula dreno
                    TriggerClientEvent('fdb-horses:client:stateChanged', src, {
                        hunger    = meta.hunger,
                        thirst    = meta.thirst,
                        dirt      = meta.dirt,
                        illness   = meta.illness,
                        poison    = meta.poison,
                        agitation = meta.agitation
                    })

            -- Notifica se ficou doente neste tick
                    if newIllness > illness then
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Seu cavalo parece doente por falta de higiene.',
                            type = 'error', duration = 5000
                        })
                    end

                    -- ============================================================
                    -- FASE C: Statebags do cavalo (escritas só pelo servidor)
                    -- dirtTier, agitationTier, isExhausted são categorias/booleano
                    -- — nunca número bruto, nunca escritas pelo client
                    -- ============================================================
                    local netId = activeHorseNetIds[citizenid]
                    if netId then
                        local entity = NetworkGetEntityFromNetworkId(netId)
                        if entity and entity ~= 0 and DoesEntityExist(entity) then
                            Entity(entity).state:set('dirtTier',      GetDirtTier(meta.dirt),          true)
                            Entity(entity).state:set('agitationTier', GetAgitationTier(meta.agitation), true)
                            Entity(entity).state:set('isExhausted',   meta.hunger < 10 or meta.thirst < 10, true)
                        end
                    end

                    break
                end
            end
        end

        ::continue_metabolism::
    end
end)

-- ============================================================
-- FASE D — Comandos de teste ISOLADOS para natives de agitação
-- Padrão idêntico ao /sickme e /poisonme do fdb-survival:
--   servidor valida admin, dispara evento pro client
--   client executa a native e reporta resultado
-- NÃO conectado ao loop de agitação — só para validar a native em jogo
-- ============================================================

-- /testhorse rear   → cavalo empina (native TASK_PLAY_ANIM_ON_MOUNT)
-- /testhorse eject  → jogador é ejetado do cavalo
-- /testhorse agit   → força agitação máxima no metadata (sem native, valida o loop)
RSGCore.Commands.Add('testhorse', 'Fase D: testa natives de agitação do cavalo (admin)',
    {{ name = 'acao', help = 'rear | eject | agit' }},
    false,
    function(source, args)
        local src = source
        local Player = RSGCore.Functions.GetPlayer(src)
        if not Player then return end

        local action = args[1] and string.lower(args[1]) or 'rear'

        if action == 'empinar' or action == 'passolateral' or action == 'conduzir' or action == 'rear' or action == 'eject' or action == 'flee' then
            -- Client executa a native e responde com resultado via notification
            TriggerClientEvent('fdb-horses:client:debug:TestTrainerNative', src, action)

        elseif action == 'agit' then
            -- Força agitação máxima no banco — valida o loop de broadcast sem native
            local activehorse = MySQL.scalar.await(
                'SELECT id FROM fdb_horses WHERE citizenid = ? AND active = 1',
                { Player.PlayerData.citizenid }
            )
            if not activehorse then
                TriggerClientEvent('ox_lib:notify', src, { title = '[D] Nenhum cavalo ativo.', type = 'error', duration = 4000 })
                return
            end
            local row = MySQL.query.await('SELECT metadata FROM fdb_horses WHERE id = ?', { activehorse })
            local meta = (row and row[1] and row[1].metadata and json.decode(row[1].metadata)) or {}
            meta.agitation = 100
            MySQL.update('UPDATE fdb_horses SET metadata = ? WHERE id = ?', { json.encode(meta), activehorse })
            TriggerClientEvent('fdb-horses:client:stateChanged', src, { agitation = 100 })
            TriggerClientEvent('ox_lib:notify', src, {
                title = '[Fase D] Agitação forçada para 100',
                description = 'Aguarde o próximo tick do loop para ver agitationTier = agitated',
                type = 'inform', duration = 6000
            })

        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = '[Fase D] Ação inválida. Use: rear | eject | agit',
                type = 'error', duration = 4000
            })
        end
    end,
'admin')