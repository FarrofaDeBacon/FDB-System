local FDBCore = exports['fdb-core']:GetCoreObject()

-- Anti-exploit: cooldowns por jogador para eventos sem validação de posição
local playerCooldowns = {} -- [src] = { [eventName] = timestamp }

local function CheckCooldown(src, eventName, cooldownSeconds)
    local now = os.time()
    if not playerCooldowns[src] then playerCooldowns[src] = {} end
    if playerCooldowns[src][eventName] and (now - playerCooldowns[src][eventName]) < cooldownSeconds then
        return false -- ainda em cooldown
    end
    playerCooldowns[src][eventName] = now
    return true -- liberado
end

-- Limpa cooldowns quando o jogador desconecta
AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)

----------------------------------------------------------------------
-- WATER CANTEEN LOGIC
----------------------------------------------------------------------

FDBCore.Functions.CreateUseableItem('canteen100', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'canteen100')
end)

FDBCore.Functions.CreateUseableItem('canteen75', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'canteen75')
end)

FDBCore.Functions.CreateUseableItem('canteen50', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'canteen50')
end)

FDBCore.Functions.CreateUseableItem('canteen25', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'canteen25')
end)

FDBCore.Functions.CreateUseableItem('canteen0', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'canteen0')
end)

FDBCore.Functions.CreateUseableItem('empty_bottle', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'empty_bottle')
end)

local function RefillCanteen(src, fromItem)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(fromItem, 1)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[fromItem], 'remove', 1)
    Player.Functions.AddItem('canteen100', 1)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items['canteen100'], 'add', 1)
end

RegisterServerEvent('fdb-water:server:givefullcanteen')
AddEventHandler('fdb-water:server:givefullcanteen', function()
    RefillCanteen(source, 'canteen0')
end)

RegisterServerEvent('fdb-water:server:refillbottle')
AddEventHandler('fdb-water:server:refillbottle', function()
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.RemoveItem('empty_bottle', 1)
    TriggerClientEvent('fdb-inventory:client:ItemBox', source, FDBCore.Shared.Items['empty_bottle'], 'remove', 1)
    Player.Functions.AddItem('water', 1)
    TriggerClientEvent('fdb-inventory:client:ItemBox', source, FDBCore.Shared.Items['water'], 'add', 1)
end)

RegisterServerEvent('fdb-water:server:givefullcanteen25')
AddEventHandler('fdb-water:server:givefullcanteen25', function()
    RefillCanteen(source, 'canteen25')
end)

RegisterServerEvent('fdb-water:server:givefullcanteen50')
AddEventHandler('fdb-water:server:givefullcanteen50', function()
    RefillCanteen(source, 'canteen50')
end)

RegisterServerEvent('fdb-water:server:givefullcanteen75')
AddEventHandler('fdb-water:server:givefullcanteen75', function()
    RefillCanteen(source, 'canteen75')
end)

RegisterServerEvent('fdb-water:server:degradecanteen')
AddEventHandler('fdb-water:server:degradecanteen', function(item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local downgradeMap = {
        canteen100 = 'canteen75',
        canteen75 = 'canteen50',
        canteen50 = 'canteen25',
        canteen25 = 'canteen0'
    }

    local nextItem = downgradeMap[item]
    if not nextItem then return end

    Player.Functions.RemoveItem(item, 1)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item], 'remove', 1)
    Player.Functions.AddItem(nextItem, 1)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[nextItem], 'add', 1)
end)

RegisterServerEvent('fdb-water:server:refillcanteen')
AddEventHandler('fdb-water:server:refillcanteen', function(fromItem)
    local src = source
    local valid = {
        canteen0 = true,
        canteen25 = true,
        canteen50 = true,
        canteen75 = true
    }

    if not valid[fromItem] then
        print(('[fdb-water] Invalid refill attempt from item: %s'):format(fromItem))
        return
    end

    RefillCanteen(src, fromItem)
end)


----------------------------------------------------------------------
-- BATHING LOGIC
----------------------------------------------------------------------

BathingSessions = {}

-- Export para que outros recursos (fdb-survival) possam validar sessões ativas
exports('GetBathingSessions', function()
    return BathingSessions
end)

RegisterServerEvent('fdb-water:server:canEnterBath')
AddEventHandler('fdb-water:server:canEnterBath', function(town)
    local src = source
    if not Config.BathingZones[town] then return end

    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local currentMoney = Player.PlayerData.money['cash']

    if not BathingSessions[town] then
        if currentMoney >= Config.NormalBathPrice then
            Player.Functions.RemoveMoney('cash', Config.NormalBathPrice)
            BathingSessions[town] = src
            TriggerClientEvent('fdb-water:client:ToggleInvincibility', src, true)
            TriggerClientEvent('fdb-water:client:StartBath', src, town)
        else
            TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_not_enough_money'), type = 'error', duration = 5000 })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { title = locale('notify_occupied'), type = 'error', duration = 5000 })
    end
end)

RegisterServerEvent('fdb-water:server:canEnterDeluxeBath')
AddEventHandler('fdb-water:server:canEnterDeluxeBath', function(town)
    local src = source
    TriggerClientEvent('ox_lib:notify', src, { title = 'Banho de luxo temporariamente indisponível', type = 'error', duration = 5000 })
    TriggerClientEvent('fdb-water:client:HideDeluxePrompt', src)
end)

RegisterServerEvent('fdb-water:server:setBathAsFree')
AddEventHandler('fdb-water:server:setBathAsFree', function(town)
    if BathingSessions[town] == source then
        BathingSessions[town] = nil
        TriggerClientEvent('fdb-water:client:ToggleInvincibility', source, false)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for town, player in pairs(BathingSessions) do
        if player == src then
            BathingSessions[town] = nil
        end
    end
end)

RegisterServerEvent('fdb-water:server:undressPlayer')
AddEventHandler('fdb-water:server:undressPlayer', function()
    exports['fdb-wardrobe']:RemovePlayerClothing(source)
end)

RegisterServerEvent('fdb-water:server:dressPlayer')
AddEventHandler('fdb-water:server:dressPlayer', function()
    exports['fdb-wardrobe']:DressPlayer(source)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for town, player in pairs(BathingSessions) do
            TriggerClientEvent('fdb-water:client:ToggleInvincibility', player, false)
        end
        BathingSessions = {}
    end
end)

----------------------------------------------------------------------
-- WASHING & TOWEL LOGIC
----------------------------------------------------------------------

RegisterNetEvent('fdb-water:server:washAtPump', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not CheckCooldown(src, 'washAtPump', 30) then
        return
    end

    local soapItem = Player.Functions.GetItemByName('soap')
    if soapItem and soapItem.amount > 0 then
        Player.Functions.RemoveItem('soap', 1)
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items['soap'], 'remove', 1)
        exports['fdb-survival']:AddCleanliness(src, 100)
    else
        exports['fdb-survival']:AddCleanliness(src, 30)
    end
    
    -- Mark player as wet
    exports['fdb-survival']:SetWet(src, true)
end)

FDBCore.Functions.CreateUseableItem('towel', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Towel is not consumed (unique = true). We just trigger the client event.
    TriggerClientEvent('fdb-water:client:useTowel', src)
end)

RegisterNetEvent('fdb-water:server:dryPlayer', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['fdb-survival']:SetWet(src, false)
end)

RegisterNetEvent('fdb-water:server:FillContainerFromPrompt', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local canteenItem = Player.Functions.GetItemByName('canteen0')
    local bottleItem = Player.Functions.GetItemByName('empty_bottle')

    if canteenItem and canteenItem.amount > 0 then
        TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'canteen0')
    elseif bottleItem and bottleItem.amount > 0 then
        TriggerClientEvent('fdb-water:client:drink', src, Config.DrinkAmount, 'empty_bottle')
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Aviso', description = 'Você não tem cantis ou garrafas vazias.', type = 'error'})
    end
end)

RegisterNetEvent('fdb-water:server:WashInRiver', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- SEGURANÇA: Cooldown de 30s para impedir spam de limpeza grátis
    if not CheckCooldown(src, 'WashInRiver', 30) then
        print(('[fdb-water] WashInRiver rejeitado: cooldown ativo para src %s'):format(src))
        return
    end
    
    -- Using the WashInWater value from config (25.0)
    exports['fdb-survival']:AddCleanliness(src, 25.0)
end)

RegisterNetEvent('fdb-water:server:DrinkNaturalWater', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- SEGURANÇA: Cooldown de 10s para impedir spam de sede grátis
    if not CheckCooldown(src, 'DrinkNaturalWater', 10) then
        print(('[fdb-water] DrinkNaturalWater rejeitado: cooldown ativo para src %s'):format(src))
        return
    end
    
    exports['fdb-survival']:AddThirst(src, 15)
    
    -- 30% chance of getting a waterborne illness
    if math.random(1, 100) <= 30 then
        exports['fdb-survival']:AddIllness(src, 40)
        TriggerClientEvent('ox_lib:notify', src, {title = 'Água Estranha', description = 'A água tinha um gosto estranho...', type = 'warning'})
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Refrescado', description = 'Você bebeu um pouco de água fresca.', type = 'success'})
    end
end)

RegisterNetEvent('fdb-water:server:makeWet', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['fdb-survival']:SetWet(src, true)
end)
