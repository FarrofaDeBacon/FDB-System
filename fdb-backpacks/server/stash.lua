local FDBCore = exports['fdb-core']:GetCoreObject()

-- Solicitação para abrir o stash de uma mochila no chão
lib.callback.register('fdb-backpacks:server:requestOpenStash', function(source, stashId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return false, "Jogador não encontrado." end

    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId
    local actualStashId = Utils.GetStashName(uid)

    -- 1. Rate Limit (Evita spam de cliques de vasculhar)
    local ok, err = Validation.RateLimit(src, "open_" .. uid, 1)
    if not ok then return false, err end

    -- 2. Validação de Existência
    local ok, err = Validation.Exists(uid)
    if not ok then return false, err end

    local bpData = activeGroundBackpacks[uid]

    -- 3. Validação de Estado
    -- Trata liberação de lock caso o jogador anterior tenha caído
    if bpData.state == 'open' or bpData.lockedBy then
        if bpData.lockedBy and GetPlayerPing(bpData.lockedBy) > 0 then
            return false, "Mochila já está sendo vasculhada por outro jogador."
        else
            -- Destrava se offline
            bpData.state = 'ground'
            bpData.lockedBy = nil
            bpData.lockedAt = nil
            UpdateBackpack(uid, { state = 'ground' })
        end
    end

    local ok, err = Validation.State(uid, 'ground')
    if not ok then return false, err end

    -- 4. Validação de Distância (Máx 3.0 metros)
    local entityCoords = bpData.coords
    if bpData.entityId and DoesEntityExist(bpData.entityId) then
        entityCoords = GetEntityCoords(bpData.entityId)
    end
    local ok, err = Validation.Distance(src, entityCoords, 3.0)
    if not ok then return false, err end

    -- Seta lock na memória e banco
    bpData.state = 'open'
    bpData.lockedBy = src
    bpData.lockedAt = os.time()
    UpdateBackpack(uid, { state = 'open' })

    -- Garante que o stash foi inicializado no inventário antes de abrir
    local bpConfig = Config.Backpacks[bpData.itemName]
    if bpConfig then
        local bp = GetBackpackByUid(uid)
        local durability = bp and bp.durability or 100
        local maxWeight = bpConfig.weight
        if durability < 50 then
            maxWeight = math.floor(maxWeight * (durability / 100))
        end
        exports['fdb-inventory']:CreateInventory(actualStashId, {
            label = FDBCore.Shared.Items[bpData.itemName].label or "Mochila",
            maxweight = maxWeight,
            slots = bpConfig.slots
        })
    end

    -- Abre o inventário de stash nativo
    exports['fdb-inventory']:OpenInventory(src, actualStashId)
    
    print(("[fdb-backpacks] Backpack %s locked and opened by player source %s"):format(uid, src))
    return true
end)

-- Intercepta o fechamento de inventário para liberar o lock
RegisterNetEvent('fdb-inventory:server:closeInventory', function(inventory)
    local src = source
    if inventory and inventory:sub(1, 3) == "bp_" then
        local uid = inventory:sub(4)
        local bpData = activeGroundBackpacks[uid]
        if bpData and bpData.lockedBy == src then
            bpData.state = 'ground'
            bpData.lockedBy = nil
            bpData.lockedAt = nil
            UpdateBackpack(uid, { state = 'ground' })
            print(("[fdb-backpacks] Backpack %s unlocked on close by player source %s"):format(uid, src))
        end
    end
end)

-- Libera o lock se o jogador desconectar
AddEventHandler('playerDropped', function(reason)
    local src = source
    for uid, bpData in pairs(activeGroundBackpacks) do
        if bpData.lockedBy == src then
            bpData.state = 'ground'
            bpData.lockedBy = nil
            bpData.lockedAt = nil
            UpdateBackpack(uid, { state = 'ground' })
            print(("[fdb-backpacks] Backpack %s unlocked due to player disconnect (source: %s)"):format(uid, src))
        end
    end
end)

-- Timeout de segurança de 5 minutos (limpa locks órfãos)
CreateThread(function()
    while true do
        Wait(60000) -- Executa a cada 1 minuto
        local now = os.time()
        for uid, bpData in pairs(activeGroundBackpacks) do
            if bpData.lockedBy and bpData.lockedAt then
                local elapsed = now - bpData.lockedAt
                if elapsed >= 300 then -- 5 minutos
                    bpData.state = 'ground'
                    bpData.lockedBy = nil
                    bpData.lockedAt = nil
                    UpdateBackpack(uid, { state = 'ground' })
                    print(("[fdb-backpacks] Safety lock timeout reached. Backpack %s unlocked."):format(uid))
                end
            end
        end
    end
end)
