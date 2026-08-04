local FDBCore = exports['fdb-core']:GetCoreObject()
lib.locale()

-- Build valid component name lookup for server-side validation
local function buildValidComponentNames()
    local names = {}
    for _, group in pairs(Config.Shared) do
        for _, list in pairs(group) do
            for _, name in ipairs(list) do
                names[name] = true
            end
        end
    end
    for _, weaponData in pairs(Config.Specific) do
        for _, list in pairs(weaponData) do
            for _, name in ipairs(list) do
                names[name] = true
            end
        end
    end
    return names
end
local ValidComponents = buildValidComponentNames()

-- When player uses the gunsmith item, open the prop placer
FDBCore.Functions.CreateUseableItem(Config.Gunsmithitem, function(source)
  TriggerClientEvent('fdb-weaponcomp:client:createprop', source, {
    propmodel = Config.Gunsmithprop,
    item      = Config.Gunsmithitem
  })
end)

--------------------------------------------
-- COMMAND 
--------------------------------------------
FDBCore.Commands.Add(Config.Commandinspect, locale('cl_lang_30'), {}, false, function(source)
    local src = source
    TriggerClientEvent('fdb-weaponcomp:client:InspectionWeapon', src)
end)

FDBCore.Commands.Add(Config.Commandloadweapon, locale('cl_lang_31'), {}, false, function(source)
    local src = source
    TriggerEvent('fdb-weaponcomp:server:check_comps', src)
end)

-- Helper para buscar el item de arma por serie
local function GetWeaponItemEntry(Player, serial)
    for _, item in pairs(Player.PlayerData.items) do
        if item.type == 'weapon'
        and item.info
        and item.info.serie == serial
        then
            return item
        end
    end
    return nil
end

-- EQUIPAR SCOPE
FDBCore.Functions.CreateCallback('fdb-weaponcomp:server:equipScope', function(source, cb, serial)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    local weaponItem = GetWeaponItemEntry(Player, serial)
    if not weaponItem then
        return cb(false)
    end

    if weaponItem.info.equippedScope then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cl_scope_already_on') })
        return cb(false)
    end

    weaponItem.info.equippedScope = true
    Player.Functions.SetInventory(Player.PlayerData.items)
    cb(true)
end)

-- REMOVER SCOPE
FDBCore.Functions.CreateCallback('fdb-weaponcomp:server:unequipScope', function(source, cb, serial)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    local weaponItem = GetWeaponItemEntry(Player, serial)
    if not weaponItem then
        return cb(false)
    end

    if not weaponItem.info.equippedScope then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cl_scope_already_off') })
        return cb(false)
    end

    weaponItem.info.equippedScope = false
    Player.Functions.SetInventory(Player.PlayerData.items)
    cb(true)
end)

--------------------------------------------
-- Callback
--------------------------------------------
-- Count how many sites player has
FDBCore.Functions.CreateCallback('fdb-weaponcomp:server:countprop', function(source, cb, proptype)
  local ply = FDBCore.Functions.GetPlayer(source)
  local res = MySQL.prepare.await( "SELECT COUNT(*) as count FROM player_weapons_custom WHERE citizenid = ? AND item = ?",
    { ply.PlayerData.citizenid, proptype }
  )
  cb(res or 0)
end)

FDBCore.Functions.CreateCallback('fdb-weaponcomp:server:getItemBySerial', function(source, cb, serial)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then cb(nil); return end

    for _, item in pairs(Player.PlayerData.items) do
        if item.type == 'weapon' and item.info and item.info.serie == serial then
            cb({ components = item.info.componentshash})
            return
        end
    end

    cb(nil)
end)

FDBCore.Functions.CreateCallback('fdb-weaponcomp:server:getPlayerWeaponComponents', function(source, cb, serial)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then cb(nil); return end

    for _, item in pairs(Player.PlayerData.items) do
        if item.type == 'weapon'
        and item.info
        and item.info.serie == serial
        then
            local comps = item.info.componentshash or {}
            local labels = item.info.components or {}

            if not item.info.equippedScope then
                local filtered = {}
                local filteredLabels = {}
                for cat, name in pairs(comps) do
                    if cat ~= "SCOPE" then
                        filtered[cat] = name
                        filteredLabels[cat] = labels[cat]
                    end
                end
                comps = filtered
                labels = filteredLabels
            end

            return cb({ components = comps, labels = labels })
        end
    end

    cb(nil)
end)

---------------------------------------------
-- create new gunsite in database
---------------------------------------------
-- create gunsite id
local function CreategunsiteId()
    local UniqueFound = false
    local gunsiteId = nil
    while not UniqueFound do
        gunsiteId = 'CSID' .. math.random(11111111, 99999999)
        local query = "%" .. gunsiteId .. "%"
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM player_weapons_custom WHERE gunsiteid LIKE ?", { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return gunsiteId
end

-- create prop id
local function CreatePropId()
    local UniqueFound = false
    local PropId = nil
    while not UniqueFound do
        PropId = 'PID' .. math.random(11111111, 99999999)
        local query = "%" .. PropId .. "%"
        local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM player_weapons_custom WHERE propid LIKE ?", { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return PropId
end

local PropsDirty = false

local function MarkPropsDirty()
    PropsDirty = true
end

RegisterServerEvent('fdb-weaponcomp:server:createnewprop')
AddEventHandler('fdb-weaponcomp:server:createnewprop', function(propmodel, item, coords, heading)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Server-side distance validation
    local ped = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(ped)
    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(coords.x, coords.y, coords.z))
    if distance > Config.PlaceDistance + 2.0 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = locale('cl_lang_16') })
        return
    end

    local gunsiteid = CreategunsiteId()
    local propid = CreatePropId()
    local citizenid = Player.PlayerData.citizenid

    local PropData =
    {
        gunsitename = locale('cl_lang_32'),
        gunsiteid = gunsiteid,
        propid = propid,
        item = item,
        x = coords.x,
        y = coords.y,
        z = coords.z,
        h = heading,
        propmodel = propmodel,
        citizenid = citizenid,
        buildttime = os.time()
    }

    local newpropdata = json.encode(PropData)

    -- add gunsite to database
    MySQL.Async.execute('INSERT INTO player_weapons_custom (gunsiteid, propid, citizenid, item, propdata) VALUES (@gunsiteid, @propid, @citizenid, @item, @propdata)', {
        ['@gunsiteid'] = gunsiteid,
        ['@propid'] = propid,
        ['@citizenid'] = citizenid,
        ['@item'] = item,
        ['@propdata'] = newpropdata
    })

    table.insert(Config.PlayerProps, PropData)
    Player.Functions.RemoveItem(Config.Gunsmithitem, 1)
    lib.notify(src, { title = 'Gunsmith', description = '1 x ' .. FDBCore.Shared.Items[Config.Gunsmithitem].label, type = 'success' })
    TriggerEvent('fdb-weaponcomp:server:updateProps', src)
    MarkPropsDirty()

end)

---------------------------------------------
-- update props
---------------------------------------------
RegisterServerEvent('fdb-weaponcomp:server:updateProps')
AddEventHandler('fdb-weaponcomp:server:updateProps', function()
    local src = source
    TriggerClientEvent('fdb-weaponcomp:client:updatePropData', src, Config.PlayerProps)
end)

-- Client requests prop data on resource start (handles server-restart / late-join)
RegisterNetEvent('fdb-weaponcomp:server:requestPropData')
AddEventHandler('fdb-weaponcomp:server:requestPropData', function()
    local src = source
    TriggerClientEvent('fdb-weaponcomp:client:updatePropData', src, Config.PlayerProps)
end)

-- update prop
CreateThread(function()
    while true do
        Wait(5000)
        if PropsLoaded and PropsDirty then
            TriggerClientEvent('fdb-weaponcomp:client:updatePropData', -1, Config.PlayerProps)
            PropsDirty = false
        end
    end
end)

CreateThread(function()
    TriggerEvent('fdb-weaponcomp:server:getProps')
    PropsLoaded = true
end)

RegisterServerEvent('fdb-weaponcomp:server:getProps')
AddEventHandler('fdb-weaponcomp:server:getProps', function()
    local result = MySQL.query.await('SELECT * FROM player_weapons_custom')
    if not result[1] then return end
    for i = 1, #result do
        local success, propData = pcall(json.decode, result[i].propdata)
        if not success or not propData then
            print(('[%s] Failed to decode propdata for row %d'):format(GetCurrentResourceName(), i))
            goto continue
        end
        if Config.LoadNotification then print(locale('sv_lang_1')..propData.item..locale('sv_lang_2')..propData.propid) end
        table.insert(Config.PlayerProps, propData)
        ::continue::
    end
    PropsDirty = true
end)

---------------------------------------------
-- items
---------------------------------------------
-- add item
RegisterServerEvent('fdb-weaponcomp:server:additem')
AddEventHandler('fdb-weaponcomp:server:additem', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item, amount = Config.Gunsmithitem, 1
    Player.Functions.AddItem(item, amount)
    lib.notify(src, { title = 'Gunsmith', description = amount .. ' x ' .. FDBCore.Shared.Items[item].label, type = 'success' })
end)

-- remove
RegisterServerEvent('fdb-weaponcomp:server:removeitem')
AddEventHandler('fdb-weaponcomp:server:removeitem', function(item, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(item, amount)
    lib.notify(src, { title = 'Gunsmith', description = amount .. ' x ' .. FDBCore.Shared.Items[item].label, type = 'error' })
end)

-- remove gunsite props
RegisterServerEvent('fdb-weaponcomp:server:removegunsiteprops')
AddEventHandler('fdb-weaponcomp:server:removegunsiteprops', function(propid)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM player_weapons_custom WHERE propid = ?', { propid })
    if not result or not result[1] then return end
    local propData = json.decode(result[1].propdata)

    if propData.citizenid ~= citizenid then print(locale('sv_lang_3')) return end

    MySQL.Async.execute('DELETE FROM player_weapons_custom WHERE propid = @propid', { ['@propid'] = propid })

    for k, v in pairs(Config.PlayerProps) do
        if v.propid == propid then
            table.remove(Config.PlayerProps, k)
            break
        end
    end

    -- print((locale('sv_lang_4').. " %s ".. locale('sv_lang_5') .." %s"):format(citizenid, propid))

    TriggerClientEvent('fdb-weaponcomp:client:updatePropData', -1, Config.PlayerProps)
    TriggerClientEvent('fdb-weaponcomp:client:ExitCam', src)
    MarkPropsDirty()
end)

-------------------------------------------
-- Save / Payment
-------------------------------------------
local function saveWeaponComponents(serial, comps, compslabel, Player)

    for _, item in pairs(Player.PlayerData.items) do
        if item.type == 'weapon' and item.info.serie == serial then
            item.info.componentshash = (type(comps) == "table" and next(comps)) and comps or nil
            item.info.components = (type(compslabel) == "table" and next(compslabel)) and compslabel or nil
            break
        end
    end

    Player.Functions.SetInventory(Player.PlayerData.items)

    -- Logging
    local msg = table.concat({
        locale('sv_lang_6') .. ':** '..Player.PlayerData.citizenid..'**',
        locale('sv_lang_7') .. ':** '..Player.PlayerData.cid..'**',
        locale('sv_lang_8') .. ':** '..serial..'**',
        locale('sv_lang_9') .. ':** '..json.encode(comps)
    }, '\n')
    TriggerEvent('fdb-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, msg)
end

local function CalculatePrice(selection)
    local total = 0
    for cat, _ in pairs(selection or {}) do
        total = total + (Config.price[cat] or 0)
    end
    return total
end

RegisterServerEvent('fdb-weaponcomp:server:setComponents', function(objecthash, serial, selectedCache, selectedLabels)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Validate components server-side
    if type(selectedCache) ~= 'table' then return end
    for cat, compName in pairs(selectedCache) do
        if type(cat) ~= 'string' or type(compName) ~= 'string' then return end
        if not ValidComponents[compName] then
            TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_lang_10', 0), description = 'Invalid component detected', type = 'error' })
            return
        end
    end
    
    -- Only charge for components that are new (not already saved on the weapon)
    local existingComps = {}
    local weaponItem = GetWeaponItemEntry(Player, serial)
    if weaponItem and weaponItem.info and weaponItem.info.componentshash then
        existingComps = weaponItem.info.componentshash
    end
    local newComps = {}
    for cat, name in pairs(selectedCache) do
        if existingComps[cat] ~= name then
            newComps[cat] = name
        end
    end
    local price = CalculatePrice(newComps)
    
    local currentCash = Player.Functions.GetMoney(Config.PaymentType)
    
    if currentCash < price then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_lang_10', price),
            description = locale('sv_lang_11'),
            type = 'error'
        })
        TriggerClientEvent('fdb-weaponcomp:client:ExitCam', src)
        return
    end
    
    if price > 0 then
        Player.Functions.RemoveMoney(Config.PaymentType, price)
    end
    saveWeaponComponents(serial, selectedCache, selectedLabels, Player)
    TriggerClientEvent('fdb-weaponcomp:client:animationSaved', src, objecthash, serial)
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('cl_notify_9'),
        description = '$' .. price,
        type = 'success',
        duration = 5000,
    })
end)

RegisterNetEvent('fdb-weaponcomp:server:removeComponents', function(objecthash, serial)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local item = GetWeaponItemEntry(Player, serial)
    if not item then
        return
    end

    local currentCash = Player.Functions.GetMoney(Config.PaymentType)
    local comps = item.info and item.info.componentshash or {}
    local price = CalculatePrice(comps) * Config.RemovePrice
    
    if currentCash < price then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_lang_10', price),
            description = locale('sv_lang_11'),
            type = 'error'
        })
        TriggerClientEvent('fdb-weaponcomp:client:ExitCam', src)
        return
    end
    
    Player.Functions.RemoveMoney(Config.PaymentType, price)
    saveWeaponComponents(serial, nil, nil, Player)
    TriggerClientEvent('fdb-weaponcomp:client:animationSaved', src, objecthash, serial)
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('cl_notify_11'),
        description = '$' .. price,
        type = 'success',
        duration = 5000,
    })
end)

RegisterNetEvent('fdb-weaponcomp:server:check_comps') -- EQUIPED
AddEventHandler('fdb-weaponcomp:server:check_comps', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-weaponcomp:client:reloadWeapon', src)
end)
