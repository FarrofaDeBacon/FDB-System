local FDBCore = exports['fdb-core']:GetCoreObject()

-- Coloca a mochila no chão a partir de um item do inventário
RegisterNetEvent('fdb-backpacks:client:placeBackpack', function(itemName, stashId, slot)
    PlayDoffAndPlaceAnimation(function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        local bpConfig = Config.Backpacks[itemName]
        local model = bpConfig.model or 'p_cs_satchel01x' -- Se for roupa, usa um prop de satchel padrão para o chão
        local modelHash = GetHashKey(model)
        
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Wait(0) end

        local forwardVector = GetEntityForwardVector(ped)
        local spawnPos = coords + (forwardVector * 0.8)
        local backpackEntity = CreateObject(modelHash, spawnPos.x, spawnPos.y, spawnPos.z, true, true, true)
        
        PlaceObjectOnGroundProperly(backpackEntity)
        if bpConfig.groundZOffset then
            local currentCoords = GetEntityCoords(backpackEntity)
            SetEntityCoords(backpackEntity, currentCoords.x, currentCoords.y, currentCoords.z + bpConfig.groundZOffset, false, false, false, false)
        end
        SetEntityHeading(backpackEntity, heading)
        FreezeEntityPosition(backpackEntity, true)
        SetEntityCollision(backpackEntity, true, true)
        SetEntityAsMissionEntity(backpackEntity, true, true)

        local netId = NetworkGetNetworkIdFromEntity(backpackEntity)
        SetNetworkIdExistsOnAllMachines(netId, true)
        
        -- Registra no banco de dados e no servidor
        TriggerServerEvent('fdb-backpacks:server:registerGroundBackpack', stashId, itemName, GetEntityCoords(backpackEntity), heading, netId, slot)
    end)
end)

-- Coloca a mochila vestida no chão
RegisterNetEvent('fdb-backpacks:client:doffAndPlaceOnGround', function(stashId, itemName)
    PlayDoffAndPlaceAnimation(function()
        local ped = PlayerPedId()
        if currentBackpackObject and DoesEntityExist(currentBackpackObject) then
            DeleteEntity(currentBackpackObject)
            currentBackpackObject = nil
        end
        if currentSatchelObject and DoesEntityExist(currentSatchelObject) then
            DeleteEntity(currentSatchelObject)
            currentSatchelObject = nil
        end
        
        -- Garante que se for roupa, ela é limpa do corpo
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

        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local bpConfig = Config.Backpacks[itemName]
        local model = bpConfig.model or 'p_cs_satchel01x' -- Fallback para o chão
        local modelHash = GetHashKey(model)

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Wait(0) end

        local forwardVector = GetEntityForwardVector(ped)
        local spawnPos = coords + (forwardVector * 0.8)
        local backpackEntity = CreateObject(modelHash, spawnPos.x, spawnPos.y, spawnPos.z, true, true, true)
        
        PlaceObjectOnGroundProperly(backpackEntity)
        if bpConfig.groundZOffset then
            local currentCoords = GetEntityCoords(backpackEntity)
            SetEntityCoords(backpackEntity, currentCoords.x, currentCoords.y, currentCoords.z + bpConfig.groundZOffset, false, false, false, false)
        end
        SetEntityHeading(backpackEntity, heading)
        FreezeEntityPosition(backpackEntity, true)
        SetEntityCollision(backpackEntity, true, true)
        SetEntityAsMissionEntity(backpackEntity, true, true)

        local netId = NetworkGetNetworkIdFromEntity(backpackEntity)
        SetNetworkIdExistsOnAllMachines(netId, true)

        -- Registra no banco de dados e no servidor
        TriggerServerEvent('fdb-backpacks:server:registerGroundBackpack', stashId, itemName, GetEntityCoords(backpackEntity), heading, netId, nil)
    end)
end)
