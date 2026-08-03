local RSGCore = exports['rsg-core']:GetCoreObject()

lib.callback.register('rsg-inventory:server:getPlayerName', function(source, targetId)
    local Player = RSGCore.Functions.GetPlayer(targetId)
    if not Player then return GetPlayerName(targetId) end
    local char = Player.PlayerData.charinfo
    if char and char.firstname then
        return char.firstname .. ' ' .. char.lastname
    end
    return GetPlayerName(targetId)
end)

-- Register a server callback for giving an item from one player to another
lib.callback.register('rsg-inventory:server:giveItem', function(source, target, item, amount, slot, info, fromInventory)
    -- Get the player object for the source (the giver)
    local player = RSGCore.Functions.GetPlayer(source)
    -- Check if the source player exists and is not dead, in last stand, or handcuffed
    if not player or player.PlayerData.metadata.isdead or player.PlayerData.metadata.inlaststand or player.PlayerData.metadata.ishandcuffed then
        return false
    end

    -- Get the player object for the target (the receiver)
    local Target = RSGCore.Functions.GetPlayer(target)
    -- Check if the target player exists and is not dead, in last stand, or handcuffed
    if not Target or Target.PlayerData.metadata.isdead or Target.PlayerData.metadata.inlaststand or Target.PlayerData.metadata.ishandcuffed then
        return false
    end

    -- Check if the distance between source and target is within 5 units
    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(target))) > Inventory.MAX_DIST then
        return false
    end

    -- Get item information from the shared items list
    local itemInfo = RSGCore.Shared.Items[item:lower()]
    if not itemInfo then
        return false
    end

    -- Fetch the real item from the source's inventory by slot (don't trust client-sent info/metadata)
    local invItem
    if fromInventory and fromInventory ~= 'player' then
        if fromInventory == 'equipment' then
            local Player = RSGCore.Functions.GetPlayer(source)
            invItem = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots[slot]
        else
            invItem = Inventory.GetItem(fromInventory, source, slot)
        end
    else
        invItem = Inventory.GetItemBySlot(source, slot)
    end

    if not invItem or invItem.name:lower() ~= item:lower() or invItem.amount <= 0 or tonumber(amount) > invItem.amount then
        return false
    end

    -- Use server-side item info (prevents serial/quality forgery)
    local serverInfo = invItem.info or {}

    -- Initialize a flag to track if the item is a weapon
    local isMove = false
    if itemInfo.type == 'weapon' then
        isMove = true
        -- FIX: pass the real server-fetched item (has .info.serie) instead of
        -- just the item name string, so CheckWeapon can resolve the serial.
        Inventory.CheckWeapon(source, invItem)
    end

    local fromId = source
    if fromInventory and fromInventory ~= 'player' and fromInventory ~= 'equipment' then
        fromId = Inventory.GetIdentifier(fromInventory, source)
    end

    -- Remove from source first, then add to target (prevents duplication)
    if fromInventory == 'equipment' then
        local metadata = Player.PlayerData.metadata
        metadata.equipmentSlots[slot] = nil
        Player.Functions.SetMetaData('equipmentSlots', metadata.equipmentSlots)
        
        -- Detach visual object
        if slot == 'backpack' then
            TriggerClientEvent('fdb-backpacks:client:detachBackpack', source)
        elseif slot == 'satchel' then
            TriggerClientEvent('fdb-backpacks:client:detachSatchel', source)
        end
    else
        if not Inventory.RemoveItem(fromId, item, amount, slot, ('Item given to ID #%s'):format(target), isMove) then
            return false
        end
    end

    if not Inventory.AddItem(target, item, amount, false, serverInfo, ('Item given from ID #%s'):format(source)) then
        -- Rollback: give item back to source if add to target fails
        if fromInventory == 'equipment' then
            local metadata = Player.PlayerData.metadata
            metadata.equipmentSlots[slot] = invItem
            Player.Functions.SetMetaData('equipmentSlots', metadata.equipmentSlots)
            TriggerClientEvent('fdb-backpacks:client:attachDirectly', source, invItem.stashId, invItem.itemName)
        else
            Inventory.AddItem(fromId, item, amount, false, serverInfo, 'rollback give item')
        end
        return false
    end

    -- Trigger give animation for both players
    TriggerClientEvent('rsg-inventory:client:giveAnim', source)
    TriggerClientEvent('rsg-inventory:client:ItemBox', source, itemInfo, 'remove', amount)
    TriggerClientEvent('rsg-inventory:client:giveAnim', target)
    TriggerClientEvent('rsg-inventory:client:ItemBox', target, itemInfo, 'add', amount)

    -- Update the target's inventory if they are marked as busy
    if Player(target).state.inv_busy then
        TriggerClientEvent('rsg-inventory:client:updateInventory', target)
    end

    -- Return true to indicate success
    return true
end)