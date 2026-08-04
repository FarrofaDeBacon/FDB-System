local FDBCore = exports['fdb-core']:GetCoreObject()
currentBackpackObject = nil
currentSatchelObject = nil
currentBackpackStashId = nil
currentBackpackModel = nil
currentBackpackWeightLimit = 0
currentBackpackWeight = 0
speedBlendRatio = 3.0
registeredEntities = {}
groundBackpacks = {}

-- Clean up attachment on resource stop
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if currentBackpackObject and DoesEntityExist(currentBackpackObject) then
            DeleteEntity(currentBackpackObject)
        end
        if currentSatchelObject and DoesEntityExist(currentSatchelObject) then
            DeleteEntity(currentSatchelObject)
        end
        -- Clear clothing satchels category when resource stops
        local ped = PlayerPedId()
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchels"), 0)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchel_straps"), 0)
        Citizen.InvokeNative(0x704C908E9C405136, ped)
        Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
        Citizen.InvokeNative(0xAAB86462966168CE, ped, true)

        for entity, _ in pairs(registeredEntities) do
            if type(entity) == "number" and DoesEntityExist(entity) then
                exports['ox_target']:removeLocalEntity(entity)
            end
        end
    end
end)

-- Wearing backpack logic

-- Wear / Attach backpack to player's back
local isAttaching = false
RegisterNetEvent('fdb-backpacks:client:attachToBack', function(stashId, itemName)
    if isAttaching then return end
    local bpConfig = Config.Backpacks[itemName]
    if not bpConfig then return end

    isAttaching = true

    local ped = PlayerPedId()

    if bpConfig.isClothing or itemName == "doctor_bag" then
        -- VESTE BOLSA LATERAL / TRANSVERSAL
        if currentSatchelObject and DoesEntityExist(currentSatchelObject) then
            DeleteEntity(currentSatchelObject)
            currentSatchelObject = nil
        end
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchels"), 0)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchel_straps"), 0)
        Citizen.InvokeNative(0x704C908E9C405136, ped)
        Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
        Citizen.InvokeNative(0xAAB86462966168CE, ped, true)

        if bpConfig.isClothing then
            local hash = IsPedMale(ped) and bpConfig.hashMale or bpConfig.hashFemale
            if hash then
                Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, hash, false, true, true)
            elseif bpConfig.customClothing then
                local data = IsPedMale(ped) and bpConfig.customClothing.male or bpConfig.customClothing.female
                if data then
                    Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0 or 0, data.tint1 or 0, data.tint2 or 0)
                end
            end
            Citizen.InvokeNative(0x704C908E9C405136, ped)
            Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
            Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
        else
            -- doctor_bag (prop na mão)
            local modelHash = GetHashKey(bpConfig.model)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Wait(0) end

            local bag = CreateObject(modelHash, 0, 0, 0, false, false, false)
            SetEntityRotation(bag, bpConfig.rot.x, bpConfig.rot.y, bpConfig.rot.z, 2)
            SetEntityAsMissionEntity(bag, true, true)
            
            local boneIndex = GetEntityBoneIndexByName(ped, bpConfig.bone or 'SKEL_L_Hand')
            AttachEntityToEntity(bag, ped, boneIndex, 
                bpConfig.pos.x, bpConfig.pos.y, bpConfig.pos.z, 
                bpConfig.rot.x, bpConfig.rot.y, bpConfig.rot.z, 
                false, true, true, false, 2, true, false, false)

            currentSatchelObject = bag
        end
        isAttaching = false
        return
    end

    -- VESTE MOCHILA DE COSTAS
    if currentBackpackObject and DoesEntityExist(currentBackpackObject) then
        DeleteEntity(currentBackpackObject)
        currentBackpackObject = nil
    end

    local modelHash = GetHashKey(bpConfig.model)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    local bag = CreateObject(modelHash, 0, 0, 0, false, false, false)
    SetEntityRotation(bag, bpConfig.rot.x, bpConfig.rot.y, bpConfig.rot.z, 2)
    SetEntityAsMissionEntity(bag, true, true)
    
    local boneIndex = GetEntityBoneIndexByName(ped, bpConfig.bone or 'CP_Back')
    AttachEntityToEntity(bag, ped, boneIndex, 
        bpConfig.pos.x, bpConfig.pos.y, bpConfig.pos.z, 
        bpConfig.rot.x, bpConfig.rot.y, bpConfig.rot.z, 
        false, true, true, false, 2, true, false, false)

    currentBackpackObject = bag
    currentBackpackStashId = stashId
    LocalPlayer.state:set("currentBackpackStashId", stashId, false)
    currentBackpackModel = bpConfig.model
    currentBackpackWeightLimit = bpConfig.weight
    isAttaching = false
end)

-- Veste diretamente (usado para satchels/bolsas de roupa que equipam sem ir pro chão)
RegisterNetEvent('fdb-backpacks:client:attachDirectly', function(stashId, itemName)
    PlayEquipAnimation(function()
        TriggerEvent('fdb-backpacks:client:attachToBack', stashId, itemName)
    end)
end)

-- Detach backpack from player's back (apenas mochila de lona)
RegisterNetEvent('fdb-backpacks:client:detachFromBack', function()
    if currentBackpackObject and DoesEntityExist(currentBackpackObject) then
        DeleteEntity(currentBackpackObject)
        currentBackpackObject = nil
    end

    currentBackpackStashId = nil
    LocalPlayer.state:set("currentBackpackStashId", nil, false)
    currentBackpackModel = nil
    currentBackpackWeightLimit = 0
    currentBackpackWeight = 0
    speedBlendRatio = 3.0
end)

-- Detach satchel (retira a bolsa lateral/transversal)
RegisterNetEvent('fdb-backpacks:client:detachSatchel', function()
    if currentSatchelObject and DoesEntityExist(currentSatchelObject) then
        DeleteEntity(currentSatchelObject)
        currentSatchelObject = nil
    end

    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchels"), 0)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchel_straps"), 0)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
end)

-- Detach backpack without dropping (remove a mochila das costas para o bolso)
RegisterNetEvent('fdb-backpacks:client:detachBackpack', function()
    if currentBackpackObject and DoesEntityExist(currentBackpackObject) then
        DeleteEntity(currentBackpackObject)
        currentBackpackObject = nil
    end

    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchels"), 0)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchel_straps"), 0)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
    
    currentBackpackStashId = nil
    LocalPlayer.state:set("currentBackpackStashId", nil, false)
    currentBackpackModel = nil
    currentBackpackWeightLimit = 0
    currentBackpackWeight = 0
    speedBlendRatio = 3.0
end)

-- Target interactions hookup imported from client/target.lua

-- Synchronize ground entities
RegisterNetEvent('fdb-backpacks:client:syncGroundBackpacks', function(syncList)
    print("[Backpack Debug] syncGroundBackpacks event received. List: " .. json.encode(syncList))
    groundBackpacks = syncList
    for uid, data in pairs(syncList) do
        CreateThread(function()
            local entity = 0
            local timeout = 100
            print(("[Backpack Debug] Resolving NetID %s for UID %s (Stash: %s)"):format(data.netId, uid, data.stashId))
            while entity == 0 and timeout > 0 do
                if NetworkDoesNetworkIdExist(data.netId) then
                    entity = NetworkGetEntityFromNetworkId(data.netId)
                end
                Wait(10)
                timeout = timeout - 1
            end
            if entity ~= 0 and DoesEntityExist(entity) then
                print(("[Backpack Debug] NetID resolved successfully to Entity: %s"):format(entity))
                SetupTarget(entity, data.stashId, data.itemName)
            else
                print(("[Backpack Debug] Failed to resolve NetID %s to a client entity within timeout."):format(data.netId))
            end
        end)
    end
end)

-- Remove ground entity target registration
RegisterNetEvent('fdb-backpacks:client:removeGroundBackpack', function(stashId, netId)
    local uid = stashId:sub(1, 3) == "bp_" and stashId:sub(4) or stashId
    if groundBackpacks then
        groundBackpacks[uid] = nil
    end

    -- Limpa a chave do stashId da tabela de registrados
    registeredEntities[stashId] = nil

    if NetworkDoesNetworkIdExist(netId) then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            exports['ox_target']:removeLocalEntity(entity)
            registeredEntities[entity] = nil
            
            -- Força a deleção do objeto no cliente para sincronizar na rede
            SetEntityAsMissionEntity(entity, true, true)
            DeleteEntity(entity)
        end
    end
end)

-- Auto-detect equipped backpack and satchel on player load or script start
local function checkEquippedBackpack()
    local PlayerData = FDBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        -- 1. Carrega Mochila de Costas
        local eq = PlayerData.metadata.equipmentSlots and PlayerData.metadata.equipmentSlots.backpack
        if eq and eq.stashId then
            currentBackpackStashId = eq.stashId
            LocalPlayer.state:set("currentBackpackStashId", eq.stashId, false)
            local bpConfig = Config.Backpacks[eq.itemName]
            if bpConfig then
                currentBackpackModel = bpConfig.model
                currentBackpackWeightLimit = bpConfig.weight
                if not currentBackpackObject or not DoesEntityExist(currentBackpackObject) then
                    TriggerEvent('fdb-backpacks:client:attachToBack', eq.stashId, eq.itemName)
                end
            end
            print(("[fdb-backpacks] Auto-detected equipped backpack: %s"):format(eq.stashId))
        else
            LocalPlayer.state:set("currentBackpackStashId", nil, false)
        end

        -- 2. Carrega Bolsa Lateral / Transversal
        local eqSatchel = PlayerData.metadata.equipmentSlots and PlayerData.metadata.equipmentSlots.satchel
        if eqSatchel and eqSatchel.stashId then
            if not currentSatchelObject or not DoesEntityExist(currentSatchelObject) then
                TriggerEvent('fdb-backpacks:client:attachToBack', eqSatchel.stashId, eqSatchel.itemName)
            end
            print(("[fdb-backpacks] Auto-detected equipped satchel: %s"):format(eqSatchel.stashId))
        end
    end
end

AddEventHandler('FDBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('fdb-backpacks:server:requestSync')
    Wait(1000)
    checkEquippedBackpack()
end)

CreateThread(function()
    Wait(2000)
    if LocalPlayer.state.isLoggedIn then
        TriggerServerEvent('fdb-backpacks:server:requestSync')
        checkEquippedBackpack()
    end
end)

RegisterNetEvent('fdb-backpacks:client:forceRuinDoff', function(stashId, itemName)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local rotation = GetEntityHeading(ped)
    TriggerServerEvent('fdb-backpacks:server:doffBackpack', stashId, itemName, coords, rotation)
end)

-- Função para limpar mochilas atachadas do corpo
local function cleanupAttachedObjects()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    if currentBackpackObject and DoesEntityExist(currentBackpackObject) then
        DeleteEntity(currentBackpackObject)
        currentBackpackObject = nil
    end

    if currentSatchelObject and DoesEntityExist(currentSatchelObject) then
        DeleteEntity(currentSatchelObject)
        currentSatchelObject = nil
    end

    -- Clear clothing satchels category when doing a cleanup
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchels"), 0)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey("satchel_straps"), 0)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)

    local models = {
        `p_ambpack04x`,
        `p_ambpack05x`,
        `p_ambpack02x`,
        `p_ambpack01x`,
        `p_bag01x`
    }
    
    for _, model in ipairs(models) do
        local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, model, false, false, false)
        if obj and DoesEntityExist(obj) and IsEntityAttachedToEntity(obj, ped) then
            DeleteEntity(obj)
        end
    end
end

RegisterNetEvent('fdb-backpacks:client:cleanupAllAttachedBackpacks', function()
    cleanupAttachedObjects()
end)

RegisterCommand('limparmochilacorpo', function()
    cleanupAttachedObjects()
    TriggerServerEvent('fdb-backpacks:server:clearBackpackMetadata')
    TriggerEvent('ox_lib:notify', { title = 'Mochila', description = 'Mochilas e bolsas limpas do seu corpo e perfil!', type = 'success' })
end)


