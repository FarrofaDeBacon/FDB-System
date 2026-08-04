local RSGCore = exports['rsg-core']:GetCoreObject()

-- globals
math = lib.math
--
Inventories = {}
Drops = {}
RegisteredShops = {}
ShopsStockCache = {}

CreateThread(function()
    MySQL.query('SELECT * FROM inventories', {}, function(result)
        if result and #result > 0 then
            for i = 1, #result do
                local inventory = result[i]
                local cacheKey = inventory.identifier
                Inventories[cacheKey] = {
                    items = json.decode(inventory.items) or {},
                    isOpen = false
                }
            end
            print(#result .. ' inventories successfully loaded')
        end
    end)
end)

local config = require 'shared.config'
CreateThread(function()
    while true do
        for k, v in pairs(Drops) do
            if v and (v.createdTime + (config.CleanupDropTime * 60) < os.time()) and not Drops[k].isOpen then
                local entity = NetworkGetEntityFromNetworkId(v.entityId)
                if DoesEntityExist(entity) then DeleteEntity(entity) end
                Drops[k] = nil
            end
        end
        Wait(config.CleanupDropInterval * 60000)
    end
end)

RegisterNetEvent('rsg-inventory:server:EquipItem', function(slot, equipmentType)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local slotNum = tonumber(slot)
    if not slotNum then return end

    local item = Player.Functions.GetItemBySlot(slotNum)
    if not item then return end

    local ValidWalletItems = {
        ['wallet_small'] = true,
        ['wallet_large'] = true,
        ['wallet'] = true,
        ['carteira'] = true,
    }

    local ValidHolsterItems = {
        ['holster_small'] = true,
        ['holster_large'] = true,
        ['holster'] = true,
        ['cinto'] = true,
    }

    local isValid = false
    if equipmentType == 'backpack' then
        if item.name:sub(1, 9) == "backpack_" then isValid = true end
    elseif equipmentType == 'satchel' then
        if item.name:sub(1, 8) == "satchel_" then isValid = true end
    elseif equipmentType == 'wallet' then
        if ValidWalletItems[item.name] then isValid = true end
    elseif equipmentType == 'holster' then
        if ValidHolsterItems[item.name] then isValid = true end
    end

    if not isValid then
        TriggerClientEvent('RSGCore:Notify', src, "Este item nao cabe neste slot!", "error")
        TriggerClientEvent('rsg-inventory:client:updateInventory', src)
        return
    end

    if equipmentType == 'backpack' or equipmentType == 'satchel' then
        exports['rsg-inventory']:UseItem(item.name, src, item)
        return
    end

    local metadata = Player.PlayerData.metadata
    if not metadata.equipmentSlots then
        metadata.equipmentSlots = { backpack = nil, satchel = nil, wallet = nil, holster = nil }
    end

    local currentlyEquipped = metadata.equipmentSlots[equipmentType]
    
    metadata.equipmentSlots[equipmentType] = {
        name = item.name,
        label = item.label,
        amount = 1,
        image = item.image,
        weight = item.weight,
        info = item.info,
        slot = equipmentType
    }

    Player.Functions.RemoveItem(item.name, 1, slotNum)

    if currentlyEquipped then
        Player.Functions.AddItem(currentlyEquipped.name, 1, slotNum, currentlyEquipped.info)
    end

    Player.Functions.SetMetaData('equipmentSlots', metadata.equipmentSlots)
    TriggerClientEvent('rsg-inventory:client:updateInventory', src)
end)

RegisterNetEvent('rsg-inventory:server:UnequipItem', function(equipmentType, targetSlot)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local metadata = Player.PlayerData.metadata
    if not metadata.equipmentSlots or not metadata.equipmentSlots[equipmentType] then 
        return 
    end

    if equipmentType == 'backpack' then
        TriggerEvent('fdb-backpacks:server:unequipBackpackToPocket', src)
        return
    elseif equipmentType == 'satchel' then
        TriggerEvent('fdb-backpacks:server:unequipSatchel', src)
        return
    end

    local item = metadata.equipmentSlots[equipmentType]
    local targetSlotNum = tonumber(targetSlot)

    local firstFreeSlot = nil
    if targetSlotNum then
        local targetItem = Player.Functions.GetItemBySlot(targetSlotNum)
        if not targetItem then
            firstFreeSlot = targetSlotNum
        end
    end

    if not firstFreeSlot then
        for i = 1, Player.PlayerData.slots do
            if not Player.Functions.GetItemBySlot(i) then
                firstFreeSlot = i
                break
            end
        end
    end

    if not firstFreeSlot then
        TriggerClientEvent('RSGCore:Notify', src, "Seu bolso esta cheio!", "error")
        TriggerClientEvent('rsg-inventory:client:updateInventory', src)
        return
    end

    metadata.equipmentSlots[equipmentType] = nil
    Player.Functions.AddItem(item.name, 1, firstFreeSlot, item.info)
    Player.Functions.SetMetaData('equipmentSlots', metadata.equipmentSlots)
    TriggerClientEvent('rsg-inventory:client:updateInventory', src)
end)

RegisterNetEvent('rsg-inventory:server:DropEquipmentItem', function(equipmentType)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local metadata = Player.PlayerData.metadata
    if not metadata.equipmentSlots or not metadata.equipmentSlots[equipmentType] then 
        return 
    end

    if equipmentType == 'backpack' then
        TriggerEvent('fdb-backpacks:server:unequipBackpack', src)
    elseif equipmentType == 'satchel' then
        TriggerEvent('fdb-backpacks:server:unequipSatchelToGround', src)
    end
end)

RSGCore.Commands.Add("clearequip", "Limpar slots de equipamentos corrompidos", {}, false, function(source, args)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        local metadata = Player.PlayerData.metadata
        metadata.equipmentSlots = { backpack = nil, satchel = nil, wallet = nil, holster = nil }
        Player.Functions.SetMetaData('equipmentSlots', metadata.equipmentSlots)
        TriggerClientEvent('rsg-inventory:client:updateInventory', source)
        TriggerClientEvent('RSGCore:Notify', source, "Slots de equipamento limpos!", "success")
    end
end)