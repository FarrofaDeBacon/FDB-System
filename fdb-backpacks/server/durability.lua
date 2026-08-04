local FDBCore = exports['fdb-core']:GetCoreObject()

local ConfigDurability = {
    damageAmounts = {
        gunshot = 10,
        fire = 15,
        fall = 8
    },
    rateLimit = 5 -- segundos
}
local lastDamageTime = {}

-- Função DropRandomItem: Remove um item aleatório da mochila e joga no chão
local function DropRandomItem(source, stashId)
    local inv = exports['fdb-inventory']:GetInventory(stashId)
    if not inv or not inv.items then return end

    local itemsList = {}
    for slot, item in pairs(inv.items) do
        if item then
            table.insert(itemsList, item)
        end
    end

    if #itemsList == 0 then return end

    local randomItem = itemsList[math.random(#itemsList)]
    local removed = exports['fdb-inventory']:RemoveItem(stashId, randomItem.name, randomItem.amount, randomItem.slot)
    
    if removed then
        exports['fdb-inventory']:ForceDropItem(source, randomItem.name, randomItem.amount, randomItem.info or {}, 'Mochila rasgada/danificada')
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Item Perdido',
            description = ('Um(a) %s caiu da sua mochila danificada!'):format(randomItem.label or randomItem.name),
            type = 'error'
        })
    end
end

-- Função RuinBackpack: Notifica e força o desequipamento da mochila destruída
local function RuinBackpack(source, stashId, itemName)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Mochila Ruída',
        description = 'Sua mochila rasgou completamente devido aos danos sofridos!',
        type = 'error',
        duration = 8000
    })
    TriggerClientEvent('fdb-backpacks:client:forceRuinDoff', source, stashId, itemName)
end

-- Evento de dano disparado de forma segura pelo cliente
RegisterNetEvent('fdb-backpacks:server:damageBackpack', function(damageType)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- 1. Verifica se está vestindo uma mochila
    local eqBackpack = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack
    if not eqBackpack or not eqBackpack.stashId then return end

    local stashId = eqBackpack.stashId
    local itemName = eqBackpack.itemName
    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    print(("[fdb-backpacks Debug] server damageBackpack event received. Player: %s, Stash: %s, DamageType: %s"):format(src, stashId, damageType))

    -- 2. Controle de Rate Limit por jogador
    local now = os.time()
    if lastDamageTime[src] and (now - lastDamageTime[src] < ConfigDurability.rateLimit) then
        print("[fdb-backpacks Debug] server damageBackpack rate-limited.")
        return
    end
    lastDamageTime[src] = now

    -- 3. Busca a mochila no banco
    local bp = GetBackpackByUid(uid)
    if not bp then return end

    local currentDurability = bp.durability or 100
    if currentDurability <= 0 then return end

    -- 4. Calcula e atualiza a nova durabilidade
    local amount = ConfigDurability.damageAmounts[damageType] or 5
    local newDurability = math.max(0, currentDurability - amount)
    UpdateBackpack(uid, { durability = newDurability })

    -- Notificação de dano
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Mochila Danificada',
        description = ('Sua mochila sofreu danos (%s). Durabilidade: %s%%'):format(damageType, newDurability),
        type = 'warning'
    })

    -- Threshold < 20%: Chance de perder item
    if newDurability < 20 and newDurability > 0 then
        if math.random(100) <= 10 then
            DropRandomItem(src, stashId)
        end
    end

    -- Threshold < 10%: Mochila inutilizada
    if newDurability < 10 then
        RuinBackpack(src, stashId, itemName)
    end
end)

-- Evento de dano à mochila no solo
RegisterNetEvent('fdb-backpacks:server:damageGroundBackpack', function(stashId, damageType)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    print(("[fdb-backpacks Debug] server damageGroundBackpack received. Player: %s, Stash: %s, UID: %s, DamageType: %s"):format(src, stashId, uid, damageType))

    -- 1. Controle de Rate Limit por jogador/mochila
    local now = os.time()
    local limitKey = src .. "_" .. uid
    if lastDamageTime[limitKey] and (now - lastDamageTime[limitKey] < ConfigDurability.rateLimit) then
        print("[fdb-backpacks Debug] server damageGroundBackpack rate-limited.")
        return
    end
    lastDamageTime[limitKey] = now

    -- 2. Busca a mochila no banco
    local bp = GetBackpackByUid(uid)
    if not bp then
        print(("[fdb-backpacks Debug] server damageGroundBackpack - Backpack not found in DB for UID: %s"):format(uid))
        return
    end

    local currentDurability = bp.durability or 100
    print(("[fdb-backpacks Debug] server damageGroundBackpack - Current Durability: %s"):format(currentDurability))
    if currentDurability <= 0 then return end

    -- 3. Calcula e atualiza a nova durabilidade
    local amount = ConfigDurability.damageAmounts[damageType] or 5
    local newDurability = math.max(0, currentDurability - amount)
    UpdateBackpack(uid, { durability = newDurability })

    -- Notifica o jogador que causou o dano
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Mochila Alvejada',
        description = ('Você danificou a mochila no chão (%s). Integridade: %s%%'):format(damageType, newDurability),
        type = 'warning'
    })

    -- Threshold < 20%: Chance de derrubar item no solo
    if newDurability < 20 and newDurability > 0 then
        if math.random(100) <= 10 then
            DropRandomItem(src, stashId)
        end
    end
end)
