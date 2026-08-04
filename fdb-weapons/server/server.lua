local FDBCore = exports['fdb-core']:GetCoreObject()

lib.locale()
------------------------------------
-- callback to get weapon info
-----------------------------------
FDBCore.Functions.CreateCallback('fdb-weapons:server:getweaponinfo', function(source, cb, weaponserial)
-- lib.callback.register('fdb-weapons:server:getweaponinfo', function(source, cb, weaponserial)
    local weaponinfo = MySQL.query.await('SELECT * FROM player_weapons WHERE serial=@weaponserial', { ['@weaponserial'] = weaponserial })
    if weaponinfo[1] == nil then return end
    cb(weaponinfo)
end)

-----------------------------------
-- Degrade Weapon
-----------------------------------
local cooldowns = {}

local function isRateLimited(src)
    local now = GetGameTimer()
    if cooldowns[src] and now - cooldowns[src] < 100 then
        return true
    end
    cooldowns[src] = now
    return false
end

RegisterNetEvent('fdb-weapons:server:degradeWeapon', function(degradationQueue) 
    local src = source
    if isRateLimited(src) then return end

    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then 
        return 
    end
    local items = Player.PlayerData.items
    local hasChanged = false
    for serial, shotCount in pairs(degradationQueue) do
        if type(serial) ~= 'string' or #serial > 32 then return end
        local capped = math.min(shotCount or 0, 10)
        if capped <= 0 then return end

        local svslot = nil
        for _, v in pairs(items) do
            if v.type == 'weapon' and v.info.serie == serial then
                svslot = v.slot
                break 
            end
        end
        if svslot and items[svslot] then
            local totalDegradation = (Config.DegradeRate * capped)
            local currentQuality = items[svslot].info.quality
            local newQuality = currentQuality - totalDegradation

            if newQuality <= 0 then
                newQuality = 0
                items[svslot].info.quality = newQuality
                TriggerClientEvent('fdb-weapons:client:UseWeapon', src, items[svslot])
            else
                items[svslot].info.quality = newQuality
            end
            
            hasChanged = true
        end
    end
    if hasChanged then
        Player.Functions.SetInventory(items)
    end
end)
------------------------------------------
-- use weapon repair kit
------------------------------------------
FDBCore.Functions.CreateUseableItem('weapon_repair_kit', function(source, item)
    TriggerClientEvent('fdb-weapons:client:repairweapon', source)
end)

-----------------------------------
-- repair weapon
-----------------------------------
RegisterNetEvent('fdb-weapons:server:repairweapon', function(serie)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local kitCount = 0
    for _, v in pairs(Player.PlayerData.items) do
        if v.name == 'weapon_repair_kit' then
            kitCount = kitCount + (v.amount or 1)
        end
    end
    if kitCount < 1 then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('cl_item_need'), type = 'error', duration = 5000 })
        return
    end
    Player.Functions.RemoveItem('weapon_repair_kit', 1)

    local svslot = nil
    for _, v in pairs(Player.PlayerData.items) do
        if v.type == 'weapon' and v.info.serie == serie then
            svslot = v.slot
            break
        end
    end
    if not svslot then
        Player.Functions.AddItem('weapon_repair_kit', 1)
        return
    end

    Player.PlayerData.items[svslot].info.quality = 100
    Player.Functions.SetInventory(Player.PlayerData.items)
    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_weapon_repaired'), type = 'success', duration = 5000 })
end)

---------------------------------------------
-- remove item
---------------------------------------------
RegisterServerEvent('fdb-weapons:server:removeitem')
AddEventHandler('fdb-weapons:server:removeitem', function(item, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not FDBCore.Shared.Items[item] then return end
    local count = 0
    for _, v in pairs(Player.PlayerData.items) do
        if v.name == item then
            count = count + (v.amount or 1)
        end
    end
    if count < (amount or 1) then return end
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item], 'remove', amount)
end)

RegisterNetEvent('fdb-weapons:server:saveEquippedWeapon', function(weaponData, isEquipped)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    if type(weaponData) ~= 'table' or type(weaponData.info) ~= 'table' then return end

    if isEquipped then
        local found = false
        for _, v in pairs(Player.PlayerData.items) do
            if v.type == 'weapon' and v.info.serie == weaponData.info.serie then
                found = true
                break
            end
        end
        if not found then return end
    end

    local equippedWeapons = Player.PlayerData.metadata.equippedweapons or {}
    if isEquipped then
        equippedWeapons[weaponData.info.serie] = {
            name = weaponData.name,
            serie = weaponData.info.serie,
            slot = weaponData.slot
        }
    else
        equippedWeapons[weaponData.info.serie] = nil
    end
    Player.Functions.SetMetaData('equippedweapons', equippedWeapons)
end)

RegisterNetEvent('fdb-weapons:server:saveEquippedKnife', function(knifeName, equipped)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    if type(knifeName) ~= 'string' then return end

    if equipped then
        local found = false
        for _, v in pairs(Player.PlayerData.items) do
            if v.name == knifeName then
                found = true
                break
            end
        end
        if not found then return end
    end

    local equippedKnives = Player.PlayerData.metadata.equippedknives or {}
    if equipped then
        equippedKnives[knifeName] = true
    else
        equippedKnives[knifeName] = nil
    end
    Player.Functions.SetMetaData('equippedknives', equippedKnives)
end)

FDBCore.Functions.CreateCallback('fdb-weapons:server:getEquippedWeapons', function(source, cb)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end
    cb(Player.PlayerData.metadata.equippedweapons or {})
end)

FDBCore.Functions.CreateCallback('fdb-weapons:server:getEquippedKnives', function(source, cb)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then cb({}) return end
    cb(Player.PlayerData.metadata.equippedknives or {})
end)

FDBCore.Functions.CreateCallback('fdb-weapons:server:getWeaponBySerial', function(source, cb, serial)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end
    for _, item in pairs(Player.PlayerData.items) do
        if item and item.name and item.info and item.info.serie == serial then
            cb(item)
            return
        end
    end
    cb(nil)
end)

---------------------------------------------
-- Infinityammo for admin
---------------------------------------------
RegisterNetEvent('fdb-weapons:requestToggle', function()
    local src = source
    if FDBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('fdb-weapons:toggle', src)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Infinity Ammo',
            description = 'You do not have permission to use this command.',
            type = 'error'
        })
    end
end)