local FDBCore = exports['fdb-core']:GetCoreObject()

-- Gera um UID único de 8 caracteres alfanuméricos com verificação de colisão
local function GenerateUID()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local length = 8
    local uid
    local isUnique = false
    
    while not isUnique do
        uid = ''
        for i = 1, length do
            local rand = math.random(1, #chars)
            uid = uid .. string.sub(chars, rand, rand)
        end
        local check = GetBackpackByUid(uid)
        if not check then
            isUnique = true
        end
    end
    return uid
end

-- Register usable items for the 4 backpack types
for itemName, _ in pairs(Config.Backpacks) do
    FDBCore.Functions.CreateUseableItem(itemName, function(source, item)
        local src = source
        local Player = FDBCore.Functions.GetPlayer(src)
        if not Player then return end

        local usedItemName = itemName  -- usa a variável do closure que é garantidamente correta
        local bpConfig = Config.Backpacks[usedItemName]

        -- print(("[fdb-backpacks] USAR ITEM: itemName=%s | item.name=%s | isClothing=%s | bpConfig=%s"):format(
        --     tostring(usedItemName),
        --     tostring(item and item.name or "nil"),
        --     tostring(bpConfig and bpConfig.isClothing or "nil"),
        --     tostring(bpConfig ~= nil)
        -- ))

        local isSatchel = bpConfig and (bpConfig.isClothing or usedItemName == "doctor_bag" or usedItemName:sub(1, 8) == "satchel_")
        local isWallet = usedItemName:sub(1, 7) == "wallet_"
        local isHolster = usedItemName:sub(1, 8) == "holster_"

        -- Validação: Impede de vestir se já tiver outra do mesmo tipo equipada
        if isSatchel then
            if Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Bolsa',
                    description = 'Você já está usando uma bolsa lateral! Retire a atual primeiro.',
                    type = 'error',
                    duration = 5000
                })
                return
            end
        elseif isWallet then
            if Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.wallet then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Carteira',
                    description = 'Você já está usando uma carteira! Retire a atual primeiro.',
                    type = 'error',
                    duration = 5000
                })
                return
            end
        elseif isHolster then
            if Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.holster then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Cinto',
                    description = 'Você já está usando um coldre/cinto! Retire o atual primeiro.',
                    type = 'error',
                    duration = 5000
                })
                return
            end
        else
            if Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Mochila',
                    description = 'Você já está vestindo uma mochila nas costas! Coloque a atual no chão primeiro.',
                    type = 'error',
                    duration = 5000
                })
                return
            end
        end

        -- Seta metadados únicos e persiste no banco se for a primeira vez
        if not item.info or not item.info.uid then
            local uid = GenerateUID()
            local stashId = Utils.GetStashName(uid)
            
            -- Salva metadados da mochila física no banco de dados
            InsertBackpack({
                uid = uid,
                stash = stashId,
                owner = Player.PlayerData.citizenid,
                model = bpConfig.model,
                coords = nil,
                rotation = 0.0,
                durability = 100,
                state = 'item',
                metadata = {}
            })

            item.info = item.info or {}
            item.info.uid = uid
            item.info.stashId = stashId
            
            Player.PlayerData.items[item.slot].info = item.info
            Player.Functions.SetInventory(Player.PlayerData.items)
        end

        local stashId = item.info.stashId

        -- ========================================================
        -- FLUXO: Se for bolsa nativa/roupa, carteira, cinto ou maleta de mão, veste
        -- diretamente do inventário sem precisar jogar no chão.
        -- ========================================================
        if isSatchel or isWallet or isHolster then
            -- Inicializa o stash no inventário
            exports['fdb-inventory']:CreateInventory(stashId, {
                label = FDBCore.Shared.Items[usedItemName].label or "Mochila",
                maxweight = bpConfig.weight,
                slots = bpConfig.slots
            })

            -- Grava metadados e atualiza estado para equipado
            local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
            local lookup = FDBCore.Shared.Items[usedItemName]
            local targetSlot = isSatchel and 'satchel' or (isWallet and 'wallet' or 'holster')
            
            eq[targetSlot] = {
                name = usedItemName,
                label = lookup and lookup.label or targetSlot,
                amount = 1,
                image = lookup and lookup.image or (targetSlot .. ".png"),
                weight = lookup and lookup.weight or 1000,
                info = { quality = 100, stashId = stashId, uid = item.info and item.info.uid or nil },
                slot = targetSlot,
                stashId = stashId,
                itemName = usedItemName
            }
            Player.Functions.SetMetaData('equipmentSlots', eq)
            UpdateBackpack(item.info.uid, { state = 'equipped', coords = nil, rotation = 0.0 })

            -- Remove dos bolsos (pockets) pois agora está equipada
            Player.Functions.RemoveItem(usedItemName, 1, item.slot)
            TriggerClientEvent("inventory:client:ItemBox", src, FDBCore.Shared.Items[usedItemName], "remove")

            -- Anexa diretamente no corpo do jogador com animação (apenas para roupas físicas, carteira/cinto não precisam de bone attach)
            if isSatchel then
                TriggerClientEvent('fdb-backpacks:client:attachDirectly', src, stashId, usedItemName)
            end
            
            -- Atualiza a UI do inventário para refletir o slot
            TriggerClientEvent('fdb-inventory:client:updateInventory', src)
        else
            -- Para mochilas de lona grandes, mantém o fluxo físico de colocar no chão primeiro
            TriggerClientEvent("fdb-backpacks:client:placeBackpack", src, usedItemName, item.info.uid, item.slot)
        end
    end)
end

-- Server event to process removing item and preparing stash
RegisterNetEvent('fdb-backpacks:server:spawnBackpackOnGround', function(itemName, stashId, slot)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local item = Player.Functions.GetItemBySlot(slot)
    if not item or item.name ~= itemName or not item.info or item.info.uid ~= stashId then
        return
    end

    -- Remove item from player pockets
    Player.Functions.RemoveItem(itemName, 1, slot)
    TriggerClientEvent("inventory:client:ItemBox", src, FDBCore.Shared.Items[itemName], "remove")

    -- Initialize stash inside inventory global table
    local bpConfig = Config.Backpacks[itemName]
    exports['fdb-inventory']:CreateInventory(stashId, {
        label = FDBCore.Shared.Items[itemName].label or "Mochila",
        maxweight = bpConfig.weight,
        slots = bpConfig.slots
    })
end)
-- Helper robusto para calcular o peso total de um stash (com fallback do banco de dados e FDBCore.Shared.Items)
local function CalculateStashWeight(stashId)
    if not stashId then return 0 end
    local weight = 0
    local items = nil
    
    local inv = exports['fdb-inventory']:GetInventory(stashId)
    if inv and inv.items then
        items = inv.items
    else
        local dbResult = MySQL.query.await('SELECT items FROM inventories WHERE identifier = ?', { stashId })
        if dbResult and dbResult[1] and dbResult[1].items then
            items = json.decode(dbResult[1].items)
        end
    end
    
    if items then
        for _, item in pairs(items) do
            if item and item.amount then
                local itemWeight = item.weight
                if not itemWeight and FDBCore.Shared.Items[item.name] then
                    itemWeight = FDBCore.Shared.Items[item.name].weight
                end
                if itemWeight then
                    weight = weight + (itemWeight * item.amount)
                end
            end
        end
    end
    
    return weight
end

-- Register the ground entity on server memory
RegisterNetEvent('fdb-backpacks:server:registerGroundBackpack', function(stashId, itemName, coords, rotation, netId, slot)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    -- 1. Rate Limiting (Evita spam de requisições de registro de solo)
    local ok, err = Validation.RateLimit(src, "register_" .. uid, 1)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- 2. Validação de Distância
    local ok, err = Validation.Distance(src, coords, 5.0)
    if not ok then
        print(("[fdb-backpacks Security] Jogador %s falhou na distancia de registro: %s"):format(Player.PlayerData.citizenid, err))
        return
    end

    -- 3. Validação de Duplicidade (Anti-Duplication exploit)
    local ok, err = Validation.NoDuplication(src, uid)
    if not ok then
        print(("[fdb-backpacks Security] Jogador %s falhou na duplicidade: %s"):format(Player.PlayerData.citizenid, err))
        TriggerClientEvent('ox_lib:notify', src, { title = 'Erro', description = err, type = 'error' })
        return
    end

    -- 4. Validação de Posse (Ownership)
    local actualStashId = Utils.GetStashName(uid)
    local ownsBackpack = false
    local eqBackpack = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack
    local eqSatchel = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel
    if (eqBackpack and eqBackpack.stashId == actualStashId) or (eqSatchel and eqSatchel.stashId == actualStashId) then
        ownsBackpack = true
    else
        if slot then
            local item = Player.Functions.GetItemBySlot(slot)
            if item and item.info and item.info.uid == uid then
                ownsBackpack = true
            end
        else
            for _, item in pairs(Player.PlayerData.items) do
                if item and item.info and item.info.uid == uid then
                    ownsBackpack = true
                    slot = item.slot
                    break
                end
            end
        end
    end

    if not ownsBackpack then
        print(("[fdb-backpacks Security] Jogador %s tentou registrar mochila não autorizada %s"):format(Player.PlayerData.citizenid, uid))
        return
    end

    -- Resolve a entidade local do servidor a partir do netId
    local entity = 0
    pcall(function()
        entity = NetworkGetEntityFromNetworkId(netId)
    end)

    -- Grava/atualiza no banco de dados e define state = 'ground'
    UpdateBackpack(uid, {
        coords = coords,
        rotation = rotation,
        state = 'ground'
    })

    -- Remove o item dos bolsos ou o attach das costas/lateral
    if slot then
        Player.Functions.RemoveItem(itemName, 1, slot)
        TriggerClientEvent("inventory:client:ItemBox", src, FDBCore.Shared.Items[itemName], "remove")
    else
        local bpConfig = Config.Backpacks[itemName]
        local isSatchel = bpConfig and (bpConfig.isClothing or itemName == "doctor_bag")
        if isSatchel then
            local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.satchel = nil
        Player.Functions.SetMetaData('equipmentSlots', eq)
            TriggerClientEvent('fdb-backpacks:client:detachSatchel', src)
        else
            local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.backpack = nil
        Player.Functions.SetMetaData('equipmentSlots', eq)
            TriggerClientEvent('fdb-backpacks:client:detachFromBack', src)
        end
    end

    -- Registra em memória para consulta rápida
    activeGroundBackpacks[uid] = {
        netId = netId,
        entityId = entity,
        stashId = actualStashId,
        itemName = itemName,
        coords = coords,
        rotation = rotation,
        owner = Player.PlayerData.citizenid,
        state = 'ground'
    }

    -- Sincroniza com todos os clientes
    TriggerClientEvent('fdb-backpacks:client:syncGroundBackpacks', -1, activeGroundBackpacks)
end)

-- Wear the backpack from the ground
RegisterNetEvent('fdb-backpacks:server:wearBackpack', function(stashId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    -- Rate Limit
    local ok, err = Validation.RateLimit(src, "wear_" .. uid, 1)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- Validação de Existência
    local ok, err = Validation.Exists(uid)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    local bpData = activeGroundBackpacks[uid]
    if not bpData then return end

    local bpConfig = Config.Backpacks[bpData.itemName]
    local isSatchel = bpConfig and (bpConfig.isClothing or bpData.itemName == "doctor_bag")

    if isSatchel then
        if Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Mochila',
                description = 'Você já está usando uma bolsa lateral! Retire a atual primeiro antes de vestir outra.',
                type = 'error',
                duration = 5000
            })
            return
        end
    else
        if Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Mochila',
                description = 'Você já está vestindo uma mochila nas costas! Coloque a atual no chão primeiro.',
                type = 'error',
                duration = 5000
            })
            return
        end
    end

    -- Validação de Distância (Máx 3.0 metros)
    local entityCoords = bpData.coords
    if bpData.entityId and DoesEntityExist(bpData.entityId) then
        entityCoords = GetEntityCoords(bpData.entityId)
    end
    local ok, err = Validation.Distance(src, entityCoords, 3.0)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- Validação de Estado (Deve ser 'ground', não pode ser 'open')
    local ok, err = Validation.State(uid, 'ground')
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- Validação de Durabilidade (Mochilas rasgadas/ruídas <10% não podem ser vestidas)
    local bp = GetBackpackByUid(uid)
    if bp and bp.durability and bp.durability < 10 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mochila Danificada',
            description = 'Esta mochila está rasgada e não pode ser vestida!',
            type = 'error'
        })
        return
    end

    -- Validação de Peso (Não pode pesar mais que 35.000g / 35 Kg)
    local weight = CalculateStashWeight(stashId)
    if weight > 35000 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Muito Pesada',
            description = ('Esta mochila pesa %0.2f Kg e excede o limite máximo permitido para carregar nas costas (Max: 35.00 Kg)!'):format(weight / 1000),
            type = 'error',
            duration = 5000
        })
        return
    end

    local bpConfig = Config.Backpacks[bpData.itemName]
    local isSatchel = bpConfig and (bpConfig.isClothing or bpData.itemName == "doctor_bag")

    local lookup = FDBCore.Shared.Items[bpData.itemName]
    if isSatchel then
        local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.satchel = {
            name = bpData.itemName,
            label = lookup and lookup.label or nil,
            amount = 1,
            image = lookup and lookup.image or "satchel.png",
            weight = lookup and lookup.weight or 1000,
            info = { quality = 100, stashId = bpData.stashId, uid = uid },
            slot = 'satchel',
            stashId = bpData.stashId,
            itemName = bpData.itemName
        }
        Player.Functions.SetMetaData('equipmentSlots', eq)
    else
        local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.backpack = {
            name = bpData.itemName,
            label = lookup and lookup.label or "Mochila",
            amount = 1,
            image = lookup and lookup.image or "backpack.png",
            weight = lookup and lookup.weight or 1000,
            info = { quality = 100, stashId = bpData.stashId, uid = uid },
            slot = 'backpack',
            stashId = bpData.stashId,
            itemName = bpData.itemName
        }
        Player.Functions.SetMetaData('equipmentSlots', eq)
    end

    -- Remove a mochila do solo na memória e no banco de dados
    activeGroundBackpacks[uid] = nil
    UpdateBackpack(uid, { state = 'equipped', coords = nil, rotation = 0.0 })

    -- Deleta a entidade física no servidor (OneSync)
    local entity = 0
    pcall(function()
        entity = NetworkGetEntityFromNetworkId(bpData.netId)
    end)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end

    -- Remove a entidade física do solo para todos os clientes
    TriggerClientEvent('fdb-backpacks:client:removeGroundBackpack', -1, stashId, bpData.netId)

    -- Acopla o objeto local no corpo/mão do jogador
    TriggerClientEvent('fdb-backpacks:client:attachToBack', src, stashId, bpData.itemName)

    -- Atualiza a UI do inventário para refletir o slot
    TriggerClientEvent('fdb-inventory:client:updateInventory', src)
end)

-- Pick up / roll up backpack into pockets
RegisterNetEvent('fdb-backpacks:server:pickupBackpack', function(stashId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    -- Rate Limit
    local ok, err = Validation.RateLimit(src, "pickup_" .. uid, 1)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- Validação de Existência
    local ok, err = Validation.Exists(uid)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    local bpData = activeGroundBackpacks[uid]

    -- Validação de Distância (Máx 3.0 metros)
    local entityCoords = bpData.coords
    if bpData.entityId and DoesEntityExist(bpData.entityId) then
        entityCoords = GetEntityCoords(bpData.entityId)
    end
    local ok, err = Validation.Distance(src, entityCoords, 3.0)
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- Validação de Estado (Deve ser 'ground', não pode ser 'open')
    local ok, err = Validation.State(uid, 'ground')
    if not ok then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Mochila', description = err, type = 'error' })
        return
    end

    -- Allow picking up full stashes as requested by user

    local info = {
        uid = uid,
        stashId = stashId
    }

    if Player.Functions.AddItem(bpData.itemName, 1, nil, info) then
        TriggerClientEvent("inventory:client:ItemBox", src, FDBCore.Shared.Items[bpData.itemName], "add")
        
        -- Delete ground entity for everyone
        activeGroundBackpacks[uid] = nil
        UpdateBackpack(uid, { state = 'item', coords = nil, rotation = 0.0 })

        -- Deleta a entidade física no servidor (OneSync)
        local entity = 0
        pcall(function()
            entity = NetworkGetEntityFromNetworkId(bpData.netId)
        end)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        TriggerClientEvent('fdb-backpacks:client:removeGroundBackpack', -1, stashId, bpData.netId)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Sem Espaço',
            description = 'Você não tem espaço para recolher a mochila!',
            type = 'error',
            duration = 5000
        })
    end
end)

-- Helper to check if a backpack stash is empty
local function isBackpackEmpty(stashId)
    local inv = exports['fdb-inventory']:GetInventory(stashId)
    if not inv or not inv.items then return true end
    for _, item in pairs(inv.items) do
        if item then return false end
    end
    return true
end

-- Shared unequip backpack logic (mochila de costas)
local function unequipBackpack(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local eqBackpack = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack
    if not eqBackpack or not eqBackpack.stashId then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mochila',
            description = 'Você não está vestindo nenhuma mochila nas costas!',
            type = 'error',
            duration = 5000
        })
        return
    end

    local stashId = eqBackpack.stashId
    local itemName = eqBackpack.itemName

    -- Remove a mochila e anexa ao solo (o metadado é limpo no registro seguro)
    TriggerClientEvent('fdb-backpacks:client:doffAndPlaceOnGround', src, stashId, itemName)
    
    -- Fecha o inventário para que o alt-target funcione imediatamente
    TriggerClientEvent('fdb-inventory:client:closeInv', src)
    
    -- Atualiza a UI do inventário para refletir o slot vazio
    TriggerClientEvent('fdb-inventory:client:updateInventory', src)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Mochila',
        description = 'Mochila colocada no chão!',
        type = 'warning',
        duration = 5000
    })
end

local function unequipSatchelToGround(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local eqSatchel = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel
    if not eqSatchel or not eqSatchel.stashId then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Bolsa',
            description = 'Você não está usando nenhuma bolsa lateral ou de mão!',
            type = 'error',
            duration = 5000
        })
        return
    end

    local stashId = eqSatchel.stashId
    local itemName = eqSatchel.itemName

    -- Remove a bolsa e anexa ao solo (o metadado é limpo no registro seguro)
    TriggerClientEvent('fdb-backpacks:client:doffAndPlaceOnGround', src, stashId, itemName)
    
    -- Fecha o inventário para que o alt-target funcione imediatamente
    TriggerClientEvent('fdb-inventory:client:closeInv', src)
    
    -- Atualiza a UI do inventário para refletir o slot vazio
    TriggerClientEvent('fdb-inventory:client:updateInventory', src)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Bolsa',
        description = 'Bolsa colocada no chão!',
        type = 'warning',
        duration = 5000
    })
end

local function unequipBackpackToPocket(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local eqBackpack = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack
    if not eqBackpack or not eqBackpack.stashId then
        return
    end

    local stashId = eqBackpack.stashId
    local itemName = eqBackpack.itemName
    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    local stashWeight = CalculateStashWeight(stashId)
    if stashWeight > 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mochila Ocupada',
            description = 'Não é possível recolher a mochila com itens dentro!',
            type = 'error',
            duration = 5000
        })
        return
    end

    local info = {
        uid = uid,
        stashId = stashId
    }

    if Player.Functions.AddItem(itemName, 1, nil, info) then
        TriggerClientEvent("inventory:client:ItemBox", src, FDBCore.Shared.Items[itemName], "add")
        local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.backpack = nil
        Player.Functions.SetMetaData('equipmentSlots', eq)
        UpdateBackpack(uid, { state = 'item', coords = nil, rotation = 0.0 })
        
        TriggerClientEvent('fdb-backpacks:client:detachBackpack', src)
        
        -- Atualiza a UI do inventário para refletir o slot vazio
        TriggerClientEvent('fdb-inventory:client:updateInventory', src)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Mochila',
            description = 'Mochila guardada nos seus bolsos!',
            type = 'success',
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Sem Espaço',
            description = 'Você não tem espaço nos bolsos para guardar a mochila!',
            type = 'error',
            duration = 5000
        })
    end
end

-- Shared unequip satchel logic (bolsa lateral/mão - guarda nos bolsos)
local function unequipSatchel(src)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local eqSatchel = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel
    if not eqSatchel or not eqSatchel.stashId then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Bolsa',
            description = 'Você não está usando nenhuma bolsa lateral ou de mão!',
            type = 'error',
            duration = 5000
        })
        return
    end

    local stashId = eqSatchel.stashId
    local itemName = eqSatchel.itemName
    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId

    -- Bloqueia desequipar bolsa com itens dentro
    -- Tenta os dois identificadores possiveis: stashId completo e uid sem prefixo
    print(('[fdb-backpacks] unequipSatchel - stashId=%s uid=%s'):format(tostring(stashId), tostring(uid)))
    local stashWeight = CalculateStashWeight(stashId)
    if stashWeight <= 0 and stashId ~= uid then
        stashWeight = CalculateStashWeight(uid)
    end
    print(('[fdb-backpacks] unequipSatchel - peso calculado: %s'):format(tostring(stashWeight)))
    if stashWeight > 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Bolsa com Itens',
            description = 'Nao e possivel guardar a bolsa com itens dentro!',
            type = 'error',
            duration = 5000
        })
        return
    end

    local info = {
        uid = uid,
        stashId = stashId
    }

    if Player.Functions.AddItem(itemName, 1, nil, info) then
        TriggerClientEvent("inventory:client:ItemBox", src, FDBCore.Shared.Items[itemName], "add")
        local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.satchel = nil
        Player.Functions.SetMetaData('equipmentSlots', eq)
        UpdateBackpack(uid, { state = 'item', coords = nil, rotation = 0.0 })
        
        -- Detacha a bolsa visualmente no cliente e fecha o inventário
        TriggerClientEvent('fdb-backpacks:client:detachSatchel', src)
        TriggerClientEvent('fdb-inventory:client:closeInv', src)
        
        -- Atualiza a UI do inventário para refletir o slot vazio
        TriggerClientEvent('fdb-inventory:client:updateInventory', src)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Bolsa',
            description = 'Bolsa guardada nos seus bolsos!',
            type = 'success',
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Bolsa',
            description = 'Você não tem espaço nos bolsos para guardar a bolsa!',
            type = 'error',
            duration = 5000
        })
    end
end

-- UI Doff Button for Backpack (mochila de costas) -> Para o chao
RegisterNetEvent('fdb-backpacks:server:unequipBackpack', function(playerSrc)
    local src = playerSrc or source
    unequipBackpack(src)
end)

RegisterNetEvent('fdb-backpacks:server:unequipSatchelToGround', function(playerSrc)
    local src = playerSrc or source
    unequipSatchelToGround(src)
end)

RegisterNetEvent('fdb-backpacks:server:unequipBackpackToPocket', function(playerSrc)
    local src = playerSrc or source
    unequipBackpackToPocket(src)
end)

-- UI Doff Button for Satchel (bolsa lateral/mão)
RegisterNetEvent('fdb-backpacks:server:unequipSatchel', function(playerSrc)
    local src = playerSrc or source
    unequipSatchel(src)
end)

-- Command to drop / unequip backpack (costas)
RegisterCommand("mochila", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        unequipBackpack(src)
    end
end)

-- Command to drop / unequip satchel (lateral)
RegisterCommand("tirarbolsa", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        unequipSatchel(src)
    end
end)

-- Command to debug backpack state
RegisterCommand("debugmochila", function(source, args, rawCommand)
    local src = source
    if src == 0 or FDBCore.Functions.HasPermission(src, 'admin') or FDBCore.Functions.HasPermission(src, 'god') then
        print("[fdb-backpacks Debug] Active Ground Backpacks:")
        for uid, data in pairs(activeGroundBackpacks) do
            print(("- UID: %s | Item: %s | Owner: %s | State: %s"):format(uid, data.itemName, data.owner, data.state))
        end
        
        if src > 0 then
            local Player = FDBCore.Functions.GetPlayer(src)
            if Player then
                local msg = ("Backpack: %s\nSatchel: %s"):format(
                    json.encode(Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack),
                    json.encode(Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel)
                )
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Debug Mochila',
                    description = msg,
                    type = 'info',
                    duration = 10000
                })
                print("[fdb-backpacks Debug] Player Metadata:")
                print("equippedBackpack: " .. json.encode(Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack, {indent = true}))
                print("equippedSatchel: " .. json.encode(Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel, {indent = true}))
            end
        end
    end
end)

-- Spawn attachment on login if already wearing one
RegisterNetEvent('FDBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        local eqBackpack = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.backpack
        if eqBackpack and eqBackpack.stashId then
            TriggerClientEvent('fdb-backpacks:client:attachToBack', src, eqBackpack.stashId, eqBackpack.itemName)
        end
        local eqSatchel = Player.PlayerData.metadata.equipmentSlots and Player.PlayerData.metadata.equipmentSlots.satchel
        if eqSatchel and eqSatchel.stashId then
            TriggerClientEvent('fdb-backpacks:client:attachToBack', src, eqSatchel.stashId, eqSatchel.itemName)
        end
    end
end)

-- Command to query inventories table
RegisterCommand("testdb", function(source, args, rawCommand)
    local src = source
    if src == 0 or FDBCore.Functions.HasPermission(src, 'admin') or FDBCore.Functions.HasPermission(src, 'god') then
        local results = MySQL.query.await("SELECT identifier, SUBSTRING(items, 1, 100) as items_preview FROM inventories LIMIT 10")
        print("[fdb-backpacks Debug] Inventories Table Contents:")
        print(json.encode(results, {indent = true}))
    end
end)

lib.callback.register('fdb-backpacks:server:getStashWeight', function(source, stashId)
    local weight = CalculateStashWeight(stashId)
    return weight
end)

-- Evento para limpar metadados de mochila e bolsa do jogador do banco/memória
RegisterNetEvent('fdb-backpacks:server:clearBackpackMetadata', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.backpack = nil
        Player.Functions.SetMetaData('equipmentSlots', eq)
        local eq = Player.PlayerData.metadata.equipmentSlots or {backpack=nil,satchel=nil,wallet=nil,holster=nil}
        eq.satchel = nil
        Player.Functions.SetMetaData('equipmentSlots', eq)
        
        -- Deleta do banco de dados qualquer mochila física do jogador que estava no solo
        MySQL.query.await('DELETE FROM backpacks WHERE owner = ?', { Player.PlayerData.citizenid })
        
        -- Limpa em memória e deleta entidades ativas no jogo
        for uid, data in pairs(activeGroundBackpacks) do
            if data.owner == Player.PlayerData.citizenid then
                activeGroundBackpacks[uid] = nil
                local entity = 0
                pcall(function()
                    entity = NetworkGetEntityFromNetworkId(data.netId)
                end)
                if entity and entity ~= 0 and DoesEntityExist(entity) then
                    DeleteEntity(entity)
                end
                TriggerClientEvent('fdb-backpacks:client:removeGroundBackpack', -1, uid, data.netId)
            end
        end
        
        print(("[fdb-backpacks] Limpeza completa de metadados e solo executada por citizenid: %s"):format(Player.PlayerData.citizenid))
    end
end)

exports('GetBackpackByUid', GetBackpackByUid)
