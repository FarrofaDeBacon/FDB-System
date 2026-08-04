--[[ 
    Server Event: Close a player's inventory
    Handles regular inventories, other player inventories, shops, and dropped items.
--]]
local RSGCore = exports['rsg-core']:GetCoreObject()

-- Releases the inv_busy lock when player closes their own pocket inventory
RegisterNetEvent('rsg-inventory:server:releaseBusy', function()
    local src = source
    Player(src).state.inv_busy = false
end)

RegisterNetEvent('rsg-inventory:server:closeInventory', function(inventory)
    local src = source
    local RSGPlayer = RSGCore.Functions.GetPlayer(src)
    if not RSGPlayer then return end

    -- Mark player's inventory as no longer busy
    Player(src).state.inv_busy = false

    -- Do nothing if it's a shop inventory
    if inventory:find('shop-') then return end

    -- Handle other player's inventory
    if inventory:find('otherplayer-') then
        local targetId = tonumber(inventory:match('otherplayer%-(.+)'))
        -- Only clear inv_busy if source is near the target (prevents forging otherplayer-<id>)
        local targetPed = GetPlayerPed(targetId)
        local srcPed = GetPlayerPed(src)
        if targetPed and DoesEntityExist(targetPed) and DoesEntityExist(srcPed) then
            if #(GetEntityCoords(srcPed) - GetEntityCoords(targetPed)) <= Inventory.MAX_DIST then
                Player(targetId).state.inv_busy = false
            end
        end
        return
    end

    -- Handle dropped item inventories
    if Drops[inventory] then
        Drops[inventory].isOpen = false
        if next(Drops[inventory].items) == nil and not Drops[inventory].isOpen then 
            TriggerClientEvent('rsg-inventory:client:removeDropTarget', -1, Drops[inventory].entityId)
            Wait(500)
            -- Re-check state after yield (another player may have opened the drop)
            if not Drops[inventory] or Drops[inventory].isOpen then return end
            local entity = NetworkGetEntityFromNetworkId(Drops[inventory].entityId)
            if DoesEntityExist(entity) then DeleteEntity(entity) end
            Drops[inventory] = nil
        end
        return
    end

    -- Handle persistent inventories (like storage)
    if not Inventories[inventory] then return end
    Inventories[inventory].isOpen = false
    MySQL.prepare('INSERT INTO inventories (identifier, items) VALUES (?, ?) ON DUPLICATE KEY UPDATE items = ?', 
        { inventory, json.encode(Inventories[inventory].items), json.encode(Inventories[inventory].items) })
end)


--[[ 
    Server Event: Use an item from player's inventory
    Handles weapons, throwable weapons, equipment, and regular items
--]]
RegisterNetEvent('rsg-inventory:server:useItem', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return false end
    
    local itemData
    if item.inventory and item.inventory ~= "player" then
        local metadata = Player.PlayerData.metadata
        local equip = metadata.equipmentSlots or {}
        local stashId = nil
        if item.inventory == "satchel" and equip.satchel then
            stashId = equip.satchel.stashId
        elseif item.inventory == "wallet" and equip.wallet then
            stashId = equip.wallet.stashId
        elseif item.inventory == "holster" and equip.holster then
            stashId = equip.holster.stashId
        elseif item.inventory == "backpack" and metadata.equippedBackpack then
            stashId = metadata.equippedBackpack.stashId
        end
        
        if stashId and Inventories[stashId] then
            for _, it in pairs(Inventories[stashId].items) do
                if it.slot == item.slot then
                    itemData = it
                    break
                end
            end
        end
    else
        itemData = Inventory.GetItemBySlot(src, item.slot)
    end
    
    if not itemData then return end
    local itemInfo = RSGCore.Shared.Items[itemData.name]
    local allowedDuringMelee = {
        weapon = true,
        weapon_thrown = true,
        -- equipment = true  you can add more 
    }

    local inMelee = lib.callback.await('rsg-inventory:client:isInMelee', src)
    if inMelee and not allowedDuringMelee[itemData.type] then
        TriggerClientEvent('lib:notify', src, {
            title = 'Inventory',
            description = locale('error.error'),
            type = 'error'
        })
        return
    end
    if itemData.type == 'weapon' then
        local result = MySQL.Sync.fetchAll(
            'SELECT * FROM player_weapons WHERE serial = @serial and citizenid = @citizenid',
            { serial = itemData.info.serie, citizenid = Player.PlayerData.citizenid }
        )
        if not result[1] then
            MySQL.Sync.execute(
                'INSERT INTO player_weapons (serial, citizenid) VALUES (@serial, @citizenid)',
                { serial = itemData.info.serie, citizenid = Player.PlayerData.citizenid }
            )
        end
        TriggerClientEvent('fdb-weapons:client:UseWeapon', src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')

    elseif itemData.type == 'weapon_thrown' then
        TriggerClientEvent('fdb-weapons:client:UseThrownWeapon', src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')

    elseif itemData.type == 'equipment' then
        TriggerClientEvent('fdb-weapons:client:UseEquipment', src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')

    else
        Inventory.UseItem(itemData.name, src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for dropId, drop in pairs(Drops) do
        if drop.openedBy == src then
            drop.isOpen = false
            drop.openedBy = nil
        end
    end
end)

-- REMOVED (rename cleanup): this callback was registered under the dead
-- 'rsg-weapons:server:getWeaponBySerial' name and was never reachable after
-- the fdb-weapons rename (the client calls 'fdb-weapons:server:getWeaponBySerial').
-- Its logic (pocket + satchel/holster/backpack lookup) was merged into
-- fdb-weapons/server/server.lua's own getWeaponBySerial callback, which is
-- the one actually called by the client. Keeping both registered under
-- different names would just be dead code maintained in two places.

RegisterNetEvent('rsg-inventory:server:UseHotbarSlot', function(slot)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local hotbarItems, _ = Inventory.GetHotbarItems(Player)
    local itemData = hotbarItems[slot]
    print(("[rsg-inventory DEBUG] UseHotbarSlot triggered. Slot: %s, ItemData: %s"):format(tostring(slot), json.encode(itemData)))
    if not itemData then return end

    local itemInfo = RSGCore.Shared.Items[itemData.name]
    
    local inMelee = lib.callback.await('rsg-inventory:client:isInMelee', src)
    if inMelee and not (itemData.type == 'weapon' or itemData.type == 'weapon_thrown') then
        TriggerClientEvent('lib:notify', src, {
            title = 'Inventory',
            description = locale('error.error'),
            type = 'error'
        })
        return
    end

    if itemData.type == 'weapon' then
        print("[rsg-inventory DEBUG] Item is weapon, preparing player_weapons entry...")
        local result = MySQL.Sync.fetchAll(
            'SELECT * FROM player_weapons WHERE serial = @serial and citizenid = @citizenid',
            { serial = itemData.info.serie, citizenid = Player.PlayerData.citizenid }
        )
        if not result[1] then
            MySQL.Sync.execute(
                'INSERT INTO player_weapons (serial, citizenid) VALUES (@serial, @citizenid)',
                { serial = itemData.info.serie, citizenid = Player.PlayerData.citizenid }
            )
        end
        print("[rsg-inventory DEBUG] Triggering fdb-weapons:client:UseWeapon")
        TriggerClientEvent('fdb-weapons:client:UseWeapon', src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')

    elseif itemData.type == 'weapon_thrown' then
        TriggerClientEvent('fdb-weapons:client:UseThrownWeapon', src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')

    elseif itemData.type == 'equipment' then
        TriggerClientEvent('fdb-weapons:client:UseEquipment', src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')

    else
        Inventory.UseItem(itemData.name, src, itemData)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, itemInfo, 'use')
    end
end)


--[[ 
    Server Event: Update player's hotbar
    Sends the first 5 inventory slots to the client for UI update
--]]
RegisterNetEvent('rsg-inventory:server:updateHotbar', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local items, activeSlots = Inventory.GetHotbarItems(Player)

    TriggerClientEvent('rsg-inventory:client:updateHotbar', src, items, activeSlots)
end)


-- Rate limiting for inventory move/split/swap
local setInventoryCooldowns = {}

--[[ 
    Server Event: Move or swap items between inventories
    Handles stacking, splitting, moving, and swapping items between inventories
--]]
lib.callback.register('rsg-inventory:server:SetInventoryData', function(source, fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount)
    -- Rate limit per player (100ms)
    local src = source
    local now = GetGameTimer()
    if setInventoryCooldowns[src] and now - setInventoryCooldowns[src] < 100 then return false, 'cooldown' end
    setInventoryCooldowns[src] = now

    -- Prevent moving items to shops
    if toInventory:find('shop-') then return false, 'shop' end
    if not fromInventory or not toInventory or not fromSlot or not toSlot or not fromAmount or not toAmount then return false, 'invalid_args' end

    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return false, 'no_player' end

    local isMove = false
    fromSlot, toSlot, fromAmount, toAmount = tonumber(fromSlot), tonumber(toSlot), tonumber(fromAmount), tonumber(toAmount)

    -- Auth: restrict access to other player inventories (must be dead/handcuffed, within 3.0)
    local function getOtherPlayerId(inv)
        if inv:find('otherplayer-') then
            return tonumber(inv:match('otherplayer%-(.+)'))
        end
    end
    local targetId = getOtherPlayerId(fromInventory) or getOtherPlayerId(toInventory)
    if targetId then
        local Target = RSGCore.Functions.GetPlayer(targetId)
        if not Target then
            Inventory.CloseInventory(src, fromInventory)
            Inventory.CloseInventory(src, toInventory)
            return false, 'no_target'
        end
        local srcPed, targetPed = GetPlayerPed(src), GetPlayerPed(targetId)
        if #(GetEntityCoords(srcPed) - GetEntityCoords(targetPed)) > 3.0 then
            Inventory.CloseInventory(src, fromInventory)
            Inventory.CloseInventory(src, toInventory)
            TriggerClientEvent('ox_lib:notify', src, { title = 'Error', description = locale('error.player_too_far'), type = 'error', duration = 5000 })
            return false, 'target_too_far'
        end
        local targetMeta = Target.PlayerData.metadata
        if not targetMeta.isdead and not targetMeta.ishandcuffed then
            Inventory.CloseInventory(src, fromInventory)
            Inventory.CloseInventory(src, toInventory)
            TriggerClientEvent('ox_lib:notify', src, { title = 'Error', description = locale('error.target_needs_restrained'), type = 'error', duration = 5000 })
            return false, 'target_not_restrained'
        end
        local hasPerm = RSGCore.Functions.HasPermission(src, 'police') or Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name == 'marshal'
        if not hasPerm and not targetMeta.isdead then
            Inventory.CloseInventory(src, fromInventory)
            Inventory.CloseInventory(src, toInventory)
            return false, 'no_permission'
        end
    end

    -- Auth: restrict access to stashes with restricted prefixes
    local restrictedPatterns = { '^police%-', '^marshal%-', '^gang%-', '^admin%-', '^evidence%-' }
    for _, invName in pairs({ fromInventory, toInventory }) do
        for _, pattern in ipairs(restrictedPatterns) do
            if invName:match(pattern) then
                local stashType = pattern:gsub('[%-^]', ''):gsub('%-', '')
                local hasAccess = false
                if stashType == 'police' or stashType == 'marshal' then
                    hasAccess = RSGCore.Functions.HasPermission(src, 'police') or Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name == 'marshal'
                elseif stashType == 'gang' then
                    local gangName = invName:match('gang%-(.+)%-')
                    hasAccess = Player.PlayerData.gang and Player.PlayerData.gang.name == gangName
                else
                    hasAccess = RSGCore.Functions.HasPermission(src, 'admin')
                end
                if not hasAccess then
                    Inventory.CloseInventory(src, invName)
                    TriggerClientEvent('ox_lib:notify', src, { title = 'Access Denied', description = 'No permission', type = 'error', duration = 5000 })
                    return false, 'restricted_access'
                end
            end
        end
    end

    local fromId, fromType = Inventory.GetIdentifier(fromInventory, src)
    local toId, toType = Inventory.GetIdentifier(toInventory, src)
    if fromId ~= toId then isMove = true end

    -- Distance check (except admin)
    if not RSGCore.Functions.HasPermission(src, 'admin') then
        local srcCoords = GetEntityCoords(GetPlayerPed(src))
        local maxDist = Inventory.MAX_DIST
        local isInventoryTooFar = function(inventoryCoords)
            return inventoryCoords and #(srcCoords - inventoryCoords) > maxDist
        end
        local fromTooFar = isInventoryTooFar(Inventory.GetCoords(fromInventory, src))
        local toTooFar = isInventoryTooFar(Inventory.GetCoords(toInventory, src))
        if fromTooFar or toTooFar then
            Inventory.CloseInventory(src, fromId)
            Inventory.CloseInventory(src, toId)
            local message = fromTooFar and locale('error.source_inv_too_far') or locale('error.target_inv_too_far')
            TriggerClientEvent('ox_lib:notify', src, { title = message, type = 'error', duration = 5000 })
            return false, 'too_far'
        end
    end

    local fromItem = Inventory.GetItem(fromInventory, src, fromSlot)
    local toItem = Inventory.GetItem(toInventory, src, toSlot)

    if fromItem then
        -- Item restrictions for specific stashes (e.g. Wallet only accepts money, holster only accepts weapons/ammo)
        if toInventory:sub(1, 3) == "bp_" then
            local stash = Inventories[toInventory]
            local model = stash and stash.model
            if not model then
                local targetUid = toInventory:sub(4)
                local bpData = exports['fdb-backpacks']:GetBackpackByUid(targetUid)
                if bpData then
                    model = bpData.model
                end
            end
            if model then
                local isWalletModel = (model == "p_wallet01x" or model == "p_wallet02x" or model:sub(1, 7) == "wallet_")
                local isHolsterModel = (model == "p_holster01x" or model == "p_holster02x" or model:sub(1, 8) == "holster_")
                
                -- Wallet restriction: Only accepts money items
                if isWalletModel then
                    local allowed = (fromItem.name == "cash" or fromItem.name == "money" or fromItem.name == "dollar" or fromItem.name == "cent" or fromItem.name == "blood_dollar" or fromItem.name == "blood_cent" or fromItem.name == "gold_bar" or fromItem.name == "gold_chunk" or fromItem.name:find("money") or fromItem.name:find("cash") or fromItem.name:find("dollar") or fromItem.name:find("cent"))
                    if not allowed then
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Carteira',
                            description = 'Esta carteira só aceita dinheiro!',
                            type = 'error',
                            duration = 5000
                        })
                        return false, 'wallet_restriction'
                    end
                end
                -- Holster restriction: Only accepts weapons and ammunition
                if isHolsterModel then
                    local isWeapon = (fromItem.type == "weapon" or fromItem.name:sub(1, 7) == "weapon_")
                    local isAmmo = (fromItem.type == "ammo" or fromItem.name:sub(1, 5) == "ammo_" or fromItem.name:find("ammo"))
                    if not (isWeapon or isAmmo) then
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Cinto/Coldre',
                            description = 'Este coldre só aceita armas e munição!',
                            type = 'error',
                            duration = 5000
                        })
                        return false, 'holster_restriction'
                    end
                end
            end
        end

        if not toItem and toAmount > fromItem.amount then return false, 'invalid_amount' end

        if fromInventory == 'player' and toInventory ~= 'player' then
            isMove = true
            Inventory.CheckWeapon(src, fromItem)
        end

        -- Stack items if same type & quality
        if toItem and fromItem.name == toItem.name and fromItem.info.quality == toItem.info.quality then
            if toId ~= fromId then
                if Inventory.CanAddItem(toId, fromItem.name, toAmount) then
                    if Inventory.RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'stacked item', isMove) then
                        if not Inventory.AddItem(toId, toItem.name, toAmount, toSlot, toItem.info, 'stacked item') then
                            Inventory.AddItem(fromId, fromItem.name, toAmount, fromSlot, fromItem.info, 'rollback stacked item')
                            return false, 'add_failed'
                        end
                        return true
                    end
                    return false, 'remove_failed'
                else
                    Inventory.SaveStash(fromId)
                    TriggerClientEvent('ox_lib:notify', src, {
                        title = 'Cheio',
                        description = 'Este container está cheio!',
                        type = 'error',
                        duration = 5000
                    })
                    return false, 'slots'
                end
            else
                if Inventory.RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'stacked item', isMove) then
                    Inventory.AddItem(toId, toItem.name, toAmount, toSlot, toItem.info, 'stacked item')
                    return true
                end
                return false, 'remove_failed'
            end

        -- Split items if moving part of the stack
        elseif not toItem and toAmount < fromAmount then
            if fromId ~= toId then
                if Inventory.CanAddItem(toId, fromItem.name, toAmount) then
                    if Inventory.RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item', isMove) then
                        if not Inventory.AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item') then
                            Inventory.AddItem(fromId, fromItem.name, toAmount, fromSlot, fromItem.info, 'rollback split item')
                            return false, 'add_failed'
                        end
                        return true
                    end
                    return false, 'remove_failed'
                else
                    Inventory.SaveStash(fromId)
                    TriggerClientEvent('ox_lib:notify', src, {
                        title = 'Cheio',
                        description = 'Este container está cheio!',
                        type = 'error',
                        duration = 5000
                    })
                    return false, 'slots'
                end
            else
                if Inventory.RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'split item', isMove) then
                    Inventory.AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'split item')
                    return true
                end
                return false, 'remove_failed'
            end

        -- Swap items between slots
        else
            if toItem then
                local fromItemAmount = fromItem.amount
                local toItemAmount = toItem.amount

                if toId ~= fromId then
                    local addSuccessFrom = Inventory.CanAddItem(toId, fromItem.name, fromItemAmount)
                    local addSuccessTo = Inventory.CanAddItem(fromId, toItem.name, toItemAmount)

                    if not addSuccessFrom or not addSuccessTo then
                        Inventory.SaveStash(fromId)
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Cheio',
                            description = 'Este container está cheio!',
                            type = 'error',
                            duration = 5000
                        })
                        return false, 'slots'
                    end

                    if addSuccessFrom and addSuccessTo then
                        if Inventory.RemoveItem(fromId, fromItem.name, fromItemAmount, fromSlot, 'swapped item', isMove) and
                           Inventory.RemoveItem(toId, toItem.name, toItemAmount, toSlot, 'swapped item', isMove) then
                            if not Inventory.AddItem(toId, fromItem.name, fromItemAmount, toSlot, fromItem.info, 'swapped item') then
                                Inventory.AddItem(fromId, fromItem.name, fromItemAmount, fromSlot, fromItem.info, 'swap rollback')
                                Inventory.AddItem(toId, toItem.name, toItemAmount, toSlot, toItem.info, 'swap rollback')
                                return false, 'add_failed'
                            elseif not Inventory.AddItem(fromId, toItem.name, toItemAmount, fromSlot, toItem.info, 'swapped item') then
                                Inventory.RemoveItem(toId, fromItem.name, fromItemAmount, toSlot, 'swap rollback', true)
                                Inventory.AddItem(fromId, fromItem.name, fromItemAmount, fromSlot, fromItem.info, 'swap rollback')
                                Inventory.AddItem(toId, toItem.name, toItemAmount, toSlot, toItem.info, 'swap rollback')
                                return false, 'add_failed'
                            end
                            return true
                        end
                        return false, 'remove_failed'
                    end
                else
                    if Inventory.RemoveItem(fromId, fromItem.name, fromItemAmount, fromSlot, 'swapped item', isMove) and
                       Inventory.RemoveItem(toId, toItem.name, toItemAmount, toSlot, 'swapped item', isMove) then
                        Inventory.AddItem(toId, fromItem.name, fromItemAmount, toSlot, fromItem.info, 'swapped item')
                        Inventory.AddItem(fromId, toItem.name, toItemAmount, fromSlot, toItem.info, 'swapped item')
                        return true
                    end
                    return false, 'remove_failed'
                end

            -- Move items to empty slots
            else
                if toId ~= fromId then
                    local fromItemAmount = fromItem.amount
                    if not Inventory.CanAddItem(toId, fromItem.name, fromItemAmount) then
                        Inventory.SaveStash(fromId)
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Cheio',
                            description = 'Este container está cheio!',
                            type = 'error',
                            duration = 5000
                        })
                        return false, 'slots'
                    else
                        if Inventory.RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item', isMove) then
                            if not Inventory.AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item') then
                                Inventory.AddItem(fromId, fromItem.name, toAmount, fromSlot, fromItem.info, 'rollback moved item')
                                return false, 'add_failed'
                            end
                            return true
                        end
                        return false, 'remove_failed'
                    end
                else
                    if Inventory.RemoveItem(fromId, fromItem.name, toAmount, fromSlot, 'moved item', isMove) then
                        Inventory.AddItem(toId, fromItem.name, toAmount, toSlot, fromItem.info, 'moved item')
                        return true
                    end
                    return false, 'remove_failed'
                end
            end
        end
    end
    return false, 'no_from_item'
end)
RegisterNetEvent('rsg-inventory:server:openPlayerInventory', function(targetId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Target = RSGCore.Functions.GetPlayer(targetId)

    if not Player or not Target then return end

    -- Security checks
    local srcPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(targetId)
    local srcCoords = GetEntityCoords(srcPed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(srcCoords - targetCoords)

    -- Check if target is close enough (max 3.0 units)
    if distance > 3.0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = locale('error.player_too_far'),
            type = 'error',
            duration = 5000
        })
        return
    end

    -- Check if target player is unconscious/dead (required for looting)
    local targetMeta = Target.PlayerData.metadata
    if not targetMeta.isdead and not targetMeta.ishandcuffed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = locale('error.target_needs_restrained'),
            type = 'error',
            duration = 5000
        })
        return
    end

    -- Additional permission check for law enforcement
    local hasPermission = RSGCore.Functions.HasPermission(src, 'police') or
                         Player.PlayerData.job.name == 'police' or
                         Player.PlayerData.job.name == 'marshal'

    if not hasPermission and not targetMeta.isdead then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'Insufficient permissions',
            type = 'error',
            duration = 5000
        })
        return
    end

    Inventory.OpenInventoryById(src, targetId)
end)

RegisterNetEvent('rsg-inventory:server:openStash', function(stashId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player then return end

    -- Basic validation
    if not stashId or type(stashId) ~= 'string' then
        return TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = locale('error.invalid_stash_identifier'),
            type = 'error',
            duration = 5000
        })
    end

    -- Prevent access to restricted stashes (add your patterns here)
    local restrictedPatterns = {
        '^police%-',      -- Police stashes
        '^marshal%-',     -- Marshal stashes
        '^gang%-',        -- Gang stashes (unless player is in that gang)
        '^admin%-',       -- Admin stashes
        '^evidence%-'     -- Evidence stashes
    }

    local isRestricted = false
    local stashType = nil

    for _, pattern in ipairs(restrictedPatterns) do
        if stashId:match(pattern) then
            isRestricted = true
            stashType = pattern:gsub('[%-^]', ''):gsub('%-', '')
            break
        end
    end

    if isRestricted then
        local hasAccess = false

        -- Check specific permissions based on stash type
        if stashType == 'police' or stashType == 'marshal' then
            hasAccess = RSGCore.Functions.HasPermission(src, 'police') or
                       Player.PlayerData.job.name == 'police' or
                       Player.PlayerData.job.name == 'marshal'
        elseif stashType == 'gang' then
            -- Extract gang name from stash ID (e.g., 'gang-lemoyne-stash' -> 'lemoyne')
            local gangName = stashId:match('gang%-(.+)%-')
            hasAccess = Player.PlayerData.gang and Player.PlayerData.gang.name == gangName
        elseif stashType == 'admin' or stashType == 'evidence' then
            hasAccess = RSGCore.Functions.HasPermission(src, 'admin')
        end

        if not hasAccess then
            return TriggerClientEvent('ox_lib:notify', src, {
                title = locale('error.access_denied'),
                description = locale('error.no_permission_stash'),
                type = 'error',
                duration = 5000
            })
        end
    end

    -- Additional distance check for world stashes
    local stashCoords = Inventory.GetCoords(stashId, src)
    if stashCoords then
        local playerCoords = GetEntityCoords(GetPlayerPed(src))
        local distance = #(playerCoords - stashCoords)

        if distance > Inventory.MAX_DIST then
            return TriggerClientEvent('ox_lib:notify', src, {
                title = 'Error',
                description = locale('error.stash_too_far'),
                type = 'error',
                duration = 5000
            })
        end
    end

    Inventory.OpenInventory(src, stashId)
end)

AddEventHandler('playerDropped', function()
    local src = source
    for dropId, drop in pairs(Drops) do
        if drop.openedBy == src then
            drop.isOpen = false
            drop.openedBy = nil
        end
    end
end)

