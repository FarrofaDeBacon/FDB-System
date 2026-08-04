local FDBCore = exports['fdb-core']:GetCoreObject()

-- -------------------------------------------------------
-- Registro de Itens Utilizáveis (Consumíveis de Sobrevivência)
-- -------------------------------------------------------

-- 1. Sopas/Alimentos Quentes (Dão coldResistance)
FDBCore.Functions.CreateUseableItem('hot_soup', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item.name], "remove")
        TriggerClientEvent('fdb-survival:client:EatThermalItem', src, 'cold', Config.Buffs.ThermalDuration)
    end
end)

-- 2. Bebidas Geladas (Dão heatResistance)
FDBCore.Functions.CreateUseableItem('cold_drink', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item.name], "remove")
        TriggerClientEvent('fdb-survival:client:EatThermalItem', src, 'heat', Config.Buffs.ThermalDuration)
        
        -- Aumenta a bexiga
        local currentBladder = Player.PlayerData.metadata["bladder"] or 0
        Player.Functions.SetMetaData("bladder", math.min(100, currentBladder + 40))
    end
end)

-- 3. Antídoto contra Veneno
FDBCore.Functions.CreateUseableItem('antidote', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item.name], "remove")
        TriggerClientEvent('fdb-survival:client:CurePoison', src)
        Player.Functions.SetMetaData("poison", 0)
    end
end)

-- 4. Remédio para Gripe/Resfriado
FDBCore.Functions.CreateUseableItem('medicine', function(source, item)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[item.name], "remove")
        TriggerClientEvent('fdb-survival:client:CureIllness', src)
        Player.Functions.SetMetaData("illness", 0)
    end
end)

-- -------------------------------------------------------
-- Sincronização de Metadados via Tick (com validação server-side)
-- -------------------------------------------------------
local allowedMetas = {
    cleanliness = true,
    bladder = true,
    poison = true,
    illness = true
}

local lastSaveTime = {} -- [src][meta] = timestamp

RegisterNetEvent('fdb-survival:server:SaveMeta', function(meta, value)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not allowedMetas[meta] then
        print(("[fdb-survival] SaveMeta rejeitado: meta inválido '%s' de src %s"):format(tostring(meta), src))
        return
    end

    if type(value) ~= 'number' then
        print(("[fdb-survival] SaveMeta rejeitado: value não-numérico de src %s"):format(src))
        return
    end

    -- Rate limit per meta (cliente envia os 4 ao mesmo tempo a cada 16s)
    local now = os.time()
    if not lastSaveTime[src] then lastSaveTime[src] = {} end
    
    if lastSaveTime[src][meta] and (now - lastSaveTime[src][meta]) < 10 then
        print(("[fdb-survival] SaveMeta rejeitado: rate limit de src %s para meta %s"):format(src, meta))
        return
    end

    local safeValue = math.floor(math.max(0, math.min(100, value)))

    local maxDeltaPerSync = {
        cleanliness = 40, -- cobre o pior caso plausível de sangue+lama dentro da janela de 16s
        bladder = 5
    }
    if maxDeltaPerSync[meta] then
        local current = Player.PlayerData.metadata[meta] or 0
        local delta = math.abs(safeValue - current)
        if delta > maxDeltaPerSync[meta] then
            print(("[fdb-survival] SaveMeta limitado: delta de %d (acima do max de %d) em '%s' de src %s (citizenid: %s)"):format(delta, maxDeltaPerSync[meta], meta, src, Player.PlayerData.citizenid))
            safeValue = math.floor(math.max(0, math.min(100, current + (safeValue > current and maxDeltaPerSync[meta] or -maxDeltaPerSync[meta]))))
        end
    end

    lastSaveTime[src][meta] = now
    Player.Functions.SetMetaData(meta, safeValue)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    lastSaveTime[src] = nil
end)

-- -------------------------------------------------------
-- EXPORTS DE MANIPULAÇÃO DIRETA
-- -------------------------------------------------------
RegisterNetEvent('fdb-survival:server:ForceClean', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    Player.Functions.SetMetaData("cleanliness", 100)
    TriggerClientEvent('fdb-survival:client:ForceClean', src)
end)

RegisterNetEvent('fdb-survival:server:EmptyBladder', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData("bladder", 0)
    if lastSaveTime[src] then lastSaveTime[src]["bladder"] = os.time() end
end)

RegisterNetEvent('fdb-survival:server:PeeAccident', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData("bladder", 0)
    Player.Functions.SetMetaData("cleanliness", 0)
    if lastSaveTime[src] then 
        lastSaveTime[src]["bladder"] = os.time() 
        lastSaveTime[src]["cleanliness"] = os.time() 
    end
end)

exports('AddHunger', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["hunger"] or 100
    local newHunger = math.max(0, math.min(100, current + amount))
    Player.Functions.SetMetaData("hunger", newHunger)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'food', value = math.floor(newHunger) })
end)

exports('AddThirst', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["thirst"] or 100
    local newThirst = math.max(0, math.min(100, current + amount))
    Player.Functions.SetMetaData("thirst", newThirst)
    TriggerClientEvent('fdb-survival:client:AddThirst', src, newThirst)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'water', value = math.floor(newThirst) })
end)

exports('AddStress', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["stress"] or 0
    local newStress = math.max(0, math.min(100, current + amount))
    Player.Functions.SetMetaData("stress", newStress)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'stress', value = math.floor(newStress) })
end)

exports('AddAlcohol', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["alcohol"] or 0
    local newAlcohol = math.max(0, math.min(Config.Alcohol.MaxAlcoholLevel, current + amount))
    Player.Functions.SetMetaData("alcohol", newAlcohol)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'drunkenness', value = math.floor(newAlcohol) })
end)
exports('AddBladder', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["bladder"] or 0
    Player.Functions.SetMetaData("bladder", math.max(0, math.min(100, current + amount)))
end)

exports('AddCleanliness', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["cleanliness"] or 100
    local newClean = math.max(0, math.min(100, current + amount))
    Player.Functions.SetMetaData("cleanliness", newClean)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'cleanliness', value = newClean })
end)

exports('SetWet', function(src, isWet)
    local playerState = Player(src).state
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData("isWet", isWet)
    playerState:set('isWet', isWet, true)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'isWet', value = isWet })
end)

exports('CurePoison', function(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData("poison", 0)
    TriggerClientEvent('fdb-survival:client:CurePoison', src)
end)

exports('CureIllness', function(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData("illness", 0)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'illness', value = 0 })
end)

exports('AddIllness', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["illness"] or 0
    local newIllness = math.max(0, math.min(100, current + amount))
    Player.Functions.SetMetaData("illness", newIllness)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'illness', value = newIllness })
end)

exports('AddPoison', function(src, amount)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local current = Player.PlayerData.metadata["poison"] or 0
    local newPoison = math.max(0, math.min(100, current + amount))
    Player.Functions.SetMetaData("poison", newPoison)
    TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'poison', value = newPoison })
end)

exports('AddColdResistance', function(src, seconds)
    TriggerClientEvent('fdb-survival:client:EatThermalItem', src, 'cold', seconds)
end)

exports('AddHeatResistance', function(src, seconds)
    TriggerClientEvent('fdb-survival:client:EatThermalItem', src, 'heat', seconds)
end)

-- ==========================================
-- LOOPS PASSIVOS (METABOLISMO E ÁLCOOL)
-- ==========================================
CreateThread(function()
    while true do
        Wait(Config.Alcohol.DecreaseInterval)
        for _, player in ipairs(FDBCore.Functions.GetPlayers()) do
            local Player = FDBCore.Functions.GetPlayer(player)
            if Player then
                local currentAlcohol = Player.PlayerData.metadata['alcohol'] or 0
                if currentAlcohol > 0 then
                    exports['fdb-survival']:AddAlcohol(player, -Config.Alcohol.DecreaseAmount)
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.Metabolism.DrainInterval)
        for _, player in ipairs(FDBCore.Functions.GetPlayers()) do
            local Player = FDBCore.Functions.GetPlayer(player)
            if Player then
                local currentHunger = Player.PlayerData.metadata['hunger'] or 100
                local currentThirst = Player.PlayerData.metadata['thirst'] or 100
                local illness = Player.PlayerData.metadata['illness'] or 0
                local currentPoison = Player.PlayerData.metadata['poison'] or 0
                
                local illnessMultiplier = (illness > 0) and 2.0 or 1.0
                
                if currentHunger > 0 or currentThirst > 0 then
                    exports['fdb-survival']:AddHunger(player, -(Config.Metabolism.HungerDrain * illnessMultiplier))
                    exports['fdb-survival']:AddThirst(player, -(Config.Metabolism.ThirstDrain * illnessMultiplier))
                end
                
                if currentPoison > 0 then
                    exports['fdb-survival']:AddPoison(player, -2)
                end
            end
        end
    end
end)

-- -------------------------------------------------------
-- COMANDOS DE ADMIN
-- -------------------------------------------------------
FDBCore.Commands.Add('cleardrunk', 'Remove toda a embriaguez', {}, false, function(source, args)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        exports['fdb-survival']:AddAlcohol(src, -100)
        TriggerClientEvent('ox_lib:notify', src, {title = 'Curado', description = 'Seu álcool foi zerado pelo admin.', type = 'success'})
    end
end, 'admin')

FDBCore.Commands.Add('dirtyme', 'Debug de Sujeira', {{name = 'nivel', help = '0 a 100'}}, false, function(source, args)
    local src = source
    local val = tonumber(args[1]) or 5
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData("cleanliness", val)
        TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'cleanliness', value = val })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Teste de Sujeira', description = 'Higiene forçada para '..val, type = 'inform'})
    end
end, 'admin')

FDBCore.Commands.Add('sickme', 'Debug de Doença', {{name = 'nivel', help = '0 a 100'}}, false, function(source, args)
    local src = source
    local val = tonumber(args[1]) or 80
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData("illness", val)
        TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'illness', value = val })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Teste de Doença', description = 'Doença forçada para '..val, type = 'error'})
    end
end, 'admin')

FDBCore.Commands.Add('poisonme', 'Debug de Veneno', {{name = 'nivel', help = '0 a 100'}}, false, function(source, args)
    local src = source
    local val = tonumber(args[1]) or 60
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData("poison", val)
        TriggerClientEvent('fdb-survival:client:stateChanged', src, { field = 'poison', value = val })
        TriggerClientEvent('ox_lib:notify', src, {title = 'Teste de Veneno', description = 'Envenenamento forçado para '..val, type = 'warning'})
    end
end, 'admin')

FDBCore.Commands.Add('sethunger', 'Define o nivel de fome de um jogador (Admin)', {{name = 'id', help = 'ID do Jogador'}, {name = 'nivel', help = '0 a 100'}}, false, function(source, args)
    local target = tonumber(args[1])
    local val = tonumber(args[2])
    if not target or not val then return end
    local Player = FDBCore.Functions.GetPlayer(target)
    if Player then
        Player.Functions.SetMetaData("hunger", val)
        TriggerClientEvent('fdb-survival:client:stateChanged', target, { field = 'food', value = val })
        TriggerClientEvent('ox_lib:notify', source, {title = 'Admin', description = 'Fome de ' .. target .. ' definida para ' .. val, type = 'success'})
    end
end, 'admin')

FDBCore.Commands.Add('setthirst', 'Define o nivel de sede de um jogador (Admin)', {{name = 'id', help = 'ID do Jogador'}, {name = 'nivel', help = '0 a 100'}}, false, function(source, args)
    local target = tonumber(args[1])
    local val = tonumber(args[2])
    if not target or not val then return end
    local Player = FDBCore.Functions.GetPlayer(target)
    if Player then
        Player.Functions.SetMetaData("thirst", val)
        TriggerClientEvent('fdb-survival:client:stateChanged', target, { field = 'water', value = val })
        TriggerClientEvent('ox_lib:notify', source, {title = 'Admin', description = 'Sede de ' .. target .. ' definida para ' .. val, type = 'success'})
    end
end, 'admin')

-- Routeador de Dano Ambiental/Biológico para o fdb-medical-core
RegisterNetEvent('fdb-survival:server:reportHazardDamage', function(damageType, amount)
    local src = source
    if not amount or amount <= 0 then return end
    -- Cap de segurança de dano ambiental por tick
    local cappedAmount = math.min(math.abs(amount), 5.0)
    -- Invoca a fonte única de dano no fdb-medical-core
    exports['fdb-medical-core']:ApplyDamage(src, damageType or 'Generic', nil, cappedAmount)
end)
