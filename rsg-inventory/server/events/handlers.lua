local RSGCore = exports['rsg-core']:GetCoreObject()
-- Player Disconnect Handler
AddEventHandler('playerDropped', function()
    for invId, inv in pairs(Inventories) do
        if inv.isOpen == source then
            inv.isOpen = false
            MySQL.prepare('INSERT INTO inventories (identifier, items) VALUES (?, ?) ON DUPLICATE KEY UPDATE items = ?',
                { invId, json.encode(inv.items), json.encode(inv.items) })
        end
    end
end)

-- Server Shutdown Handler
AddEventHandler('txAdmin:events:serverShuttingDown', function()
    for inventory, data in pairs(Inventories) do
        if data.isOpen then
            MySQL.prepare(
                'INSERT INTO inventories (identifier, items) VALUES (?, ?) ON DUPLICATE KEY UPDATE items = ?',
                { inventory, json.encode(data.items), json.encode(data.items) }
            )
        end
    end
end)


AddEventHandler('RSGCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source

    -- Migrate legacy metadata
    local metadata = Player.PlayerData.metadata
    local changed = false

    -- Detect ANY corrupted equipmentSlots format.
    -- Valid structure only has keys: backpack, satchel, wallet, holster.
    -- If any other key is found (e.g. name, stash, info, slot, amount) the data is corrupt.
    local validEquipKeys = { backpack = true, satchel = true, wallet = true, holster = true }
    if metadata.equipmentSlots then
        local isCorrupted = false
        for k, _ in pairs(metadata.equipmentSlots) do
            if not validEquipKeys[k] then
                isCorrupted = true
                break
            end
        end
        if isCorrupted then
            print(('[rsg-inventory] [MIGRATION] Player ' .. tostring(src) .. ' had corrupted equipmentSlots (key: ' .. tostring(next(metadata.equipmentSlots)) .. '). Resetting.'))
            metadata.equipmentSlots = { backpack = nil, satchel = nil, wallet = nil, holster = nil }
            changed = true
        end
    end

    if not metadata.equipmentSlots then
        metadata.equipmentSlots = { backpack = nil, satchel = nil, wallet = nil, holster = nil }
        changed = true
    end

    local backpackItemsLookup = {
        backpack_tiny = { label = 'Mochila de Lona Mini', image = 'p_ambpack01x.png' },
        backpack_small = { label = 'Mochila de Lona Pequena', image = 'p_ambpack05x.png' },
        backpack_medium = { label = 'Mochila de Lona Média', image = 'p_ambpack02x.png' },
        backpack_large = { label = 'Mochila de Lona Grande', image = 'p_ambpack04x.png' }
    }
    local satchelItemsLookup = {
        satchel_small = { label = 'Bolsa de Couro Pequena', image = 'backpack_small.png' },
        satchel_medium = { label = 'Bolsa de Couro Média', image = 'backpack_medium.png' },
        satchel_large = { label = 'Bolsa de Couro Grande', image = 'backpack_large.png' }
    }

    if metadata.equippedBackpack then
        if type(metadata.equippedBackpack) == 'table' and metadata.equippedBackpack.itemName then
            local bpName = metadata.equippedBackpack.itemName
            local lookup = backpackItemsLookup[bpName] or { label = 'Mochila', image = 'p_ambpack02x.png' }
            metadata.equipmentSlots.backpack = {
                name = bpName,
                label = lookup.label,
                amount = 1,
                image = lookup.image,
                weight = 1000,
                info = { quality = 100, stashId = metadata.equippedBackpack.stashId },
                slot = 'backpack'
            }
        else
            metadata.equipmentSlots.backpack = nil
        end
        metadata.equippedBackpack = nil
        changed = true
    end

    if metadata.equippedSatchel then
        if type(metadata.equippedSatchel) == 'table' and metadata.equippedSatchel.itemName then
            local satName = metadata.equippedSatchel.itemName
            local lookup = satchelItemsLookup[satName] or { label = 'Bolsa', image = 'backpack_medium.png' }
            metadata.equipmentSlots.satchel = {
                name = satName,
                label = lookup.label,
                amount = 1,
                image = lookup.image,
                weight = 1000,
                info = { quality = 100, stashId = metadata.equippedSatchel.stashId },
                slot = 'satchel'
            }
        else
            metadata.equipmentSlots.satchel = nil
        end
        metadata.equippedSatchel = nil
        changed = true
    end

    -- Robust post-migration check for players who already have equipmentSlots but with incomplete objects
    if metadata.equipmentSlots then
        if metadata.equipmentSlots.backpack then
            local bpName = metadata.equipmentSlots.backpack.itemName or metadata.equipmentSlots.backpack.name
            local stash = metadata.equipmentSlots.backpack.stashId or (metadata.equipmentSlots.backpack.info and metadata.equipmentSlots.backpack.info.stashId)
            
            if bpName and stash and (not metadata.equipmentSlots.backpack.name or not metadata.equipmentSlots.backpack.stashId) then
                local lookup = backpackItemsLookup[bpName] or { label = 'Mochila', image = 'p_ambpack02x.png' }
                metadata.equipmentSlots.backpack = {
                    name = bpName,
                    label = lookup.label,
                    amount = 1,
                    image = lookup.image,
                    weight = 1000,
                    info = { quality = 100, stashId = stash },
                    slot = 'backpack',
                    stashId = stash,
                    itemName = bpName
                }
                changed = true
            end
        end

        if metadata.equipmentSlots.satchel then
            local satName = metadata.equipmentSlots.satchel.itemName or metadata.equipmentSlots.satchel.name
            local stash = metadata.equipmentSlots.satchel.stashId or (metadata.equipmentSlots.satchel.info and metadata.equipmentSlots.satchel.info.stashId)

            if satName and stash and (not metadata.equipmentSlots.satchel.name or not metadata.equipmentSlots.satchel.stashId) then
                local lookup = satchelItemsLookup[satName] or { label = 'Bolsa', image = 'backpack_medium.png' }
                metadata.equipmentSlots.satchel = {
                    name = satName,
                    label = lookup.label,
                    amount = 1,
                    image = lookup.image,
                    weight = 1000,
                    info = { quality = 100, stashId = stash },
                    slot = 'satchel',
                    stashId = stash,
                    itemName = satName
                }
                changed = true
            end
        end
    end

    if changed then
        Player.Functions.SetMetaData('equipmentSlots', metadata.equipmentSlots)
        Player.Functions.SetMetaData('equippedBackpack', nil)
        Player.Functions.SetMetaData('equippedSatchel', nil)
    end

    -- Force slots count to 12 to clean up legacy character configurations
    Player.Functions.SetPlayerData('slots', 12)

    -- Voeg inventaris functies toe aan de speler
    local methods = {
        AddItem = function(item, amount, slot, info, reason)
            return Inventory.AddItem(src, item, amount, slot, info, reason)
        end,
        RemoveItem = function(item, amount, slot, reason)
            -- Server-side authoritative deequip for weapons; isMove=true is a client-side fallback.
            local itemDef = RSGCore.Shared.Items[item:lower()]
            if itemDef and itemDef['type'] == 'weapon' then
                local invItem = Inventory.GetItemBySlot(src, slot) or Inventory.GetItemByName(src, item)
                Inventory.CheckWeapon(src, invItem or item)
            end
            return Inventory.RemoveItem(src, item, amount, slot, reason, true)
        end,
        GetItemBySlot = function(slot)
            return Inventory.GetItemBySlot(src, slot)
        end,
        GetItemByName = function(item)
            return Inventory.GetItemByName(src, item)
        end,
        GetItemsByName = function(item)
            return Inventory.GetItemsByName(src, item)
        end,
        ClearInventory = function(filterItems)
            Inventory.ClearInventory(src, filterItems)
        end,
        SetInventory = function(items)
            Inventory.SetInventory(src, items)
        end
    }

    for methodName, methodFunc in pairs(methods) do
        RSGCore.Functions.AddPlayerMethod(src, methodName, methodFunc)
    end
end)

-- Resource Start Event
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    local Players = RSGCore.Functions.GetRSGPlayers()
    for k in pairs(Players) do
        local methods = {
            AddItem = function(item, amount, slot, info)
                return Inventory.AddItem(k, item, amount, slot, info)
            end,
            RemoveItem = function(item, amount, slot)
                -- Server-side authoritative deequip for weapons; isMove=true is a client-side fallback.
                local itemDef = RSGCore.Shared.Items[item:lower()]
                if itemDef and itemDef['type'] == 'weapon' then
                    local invItem = Inventory.GetItemBySlot(k, slot) or Inventory.GetItemByName(k, item)
                    Inventory.CheckWeapon(k, invItem or item)
                end
                return Inventory.RemoveItem(k, item, amount, slot, nil, true)
            end,
            GetItemBySlot = function(slot)
                return Inventory.GetItemBySlot(k, slot)
            end,
            GetItemByName = function(item)
                return Inventory.GetItemByName(k, item)
            end,
            GetItemsByName = function(item)
                return Inventory.GetItemsByName(k, item)
            end,
            ClearInventory = function(filterItems)
                Inventory.ClearInventory(k, filterItems)
            end,
            SetInventory = function(items)
                Inventory.SetInventory(k, items)
            end
        }

        for methodName, methodFunc in pairs(methods) do
            RSGCore.Functions.AddPlayerMethod(k, methodName, methodFunc)
        end

        -- Update slots dynamically on resource restart
        local ply = RSGCore.Functions.GetPlayer(k)
        if ply then
            ply.Functions.SetPlayerData('slots', 12)
        end

        -- Reset inventory busy state
        Player(k).state.inv_busy = false
    end
end)
