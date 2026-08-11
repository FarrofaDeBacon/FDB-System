local activeGraveData = nil

CreateThread(function()
    -- Espera o Bridge carregar e o Config também
    Wait(1000)

    local targetOptions = {
        {
            icon = 'fas fa-skull-crossbones',
            label = 'Saquear Túmulo',
            distance = 3.5,
            canInteract = function(entity)
                return true
            end,
            onSelect = function(data)
                local entity = data.entity
                if not DoesEntityExist(entity) then return end
                
                local model = GetEntityModel(entity)
                local coords = GetEntityCoords(entity)
                
                -- Envia pro server pra iniciar
                TriggerServerEvent('illegal-system:server:startGraveRobbery', {
                    model = model,
                    coords = coords
                })
            end
        }
    }

    Bridge.RegisterTargetModel(Config.GraveModels, targetOptions)
end)

RegisterCommand('gravetest', function()
    local testOptions = {
        {
            name = 'grave_robbery_test',
            icon = 'fas fa-skull-crossbones',
            label = 'Teste Saquear Túmulo',
            distance = 3.5,
            onSelect = function(data)
                print("Target funcionou no túmulo!")
            end
        }
    }
    exports.ox_target:addModel(Config.GraveModels, testOptions)
    print("Forçamos o registro de Target nos modelos de túmulo direto no ox_target!")
end, false)

RegisterCommand('getmodel', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local rayStart = coords + vector3(0.0, 0.0, 0.5)
    local rayEnd = rayStart + (forward * 5.0)
    
    local rayHandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, playerPed, 0)
    local _, hit, hitCoords, _, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and entityHit ~= 0 then
        local model = GetEntityModel(entityHit)
        print('Entity Model Hash:', model)
        TriggerEvent('chat:addMessage', { args = { '^2Model Hash', tostring(model) } })
    else
        TriggerEvent('chat:addMessage', { args = { '^1Erro', 'Não achou entidade na frente' } })
    end
end, false)

RegisterNetEvent('illegal-system:client:startGraveRobberyMinigame', function(data)
    local crimeConfig = Config.Crimes['grave_robbery']
    
    local images = {
        common = Bridge.GetInventoryImageURL(data.items.common),
        uncommon = Bridge.GetInventoryImageURL(data.items.uncommon),
        rare = Bridge.GetInventoryImageURL(data.items.rare)
    }

    local ped = PlayerPedId()
    
    -- Animação de Cavar
    local anim = Config.Digging
    RequestAnimDict(anim.AnimDict)
    while not HasAnimDictLoaded(anim.AnimDict) do Wait(10) end
    
    -- Criar pá na mão
    local shovelHash = GetHashKey(anim.ShovelModel)
    RequestModel(shovelHash)
    while not HasModelLoaded(shovelHash) do Wait(10) end
    
    local shovelObj = CreateObject(shovelHash, 0, 0, 0, true, true, false)
    local boneIndex = GetEntityBoneIndexByName(ped, anim.AttachBone)
    AttachEntityToEntity(shovelObj, ped, boneIndex, anim.AttachOffset.x, anim.AttachOffset.y, anim.AttachOffset.z, anim.AttachRotation.x, anim.AttachRotation.y, anim.AttachRotation.z, true, true, false, true, 1, true)
    
    TaskPlayAnim(ped, anim.AnimDict, anim.AnimName, 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Inicia minigame
    local result = exports['fdb-libs']:StartMinigame(crimeConfig.minigame.type, {
        duration = crimeConfig.minigame.duration,
        images = images,
        zones = crimeConfig.minigame.zones
    })
    
    -- Limpa a animação e o prop da pá
    ClearPedTasks(ped)
    if DoesEntityExist(shovelObj) then
        DeleteEntity(shovelObj)
    end
    SetModelAsNoLongerNeeded(shovelHash)
    
    if result.success then
        -- Spawna terra revirada (dirt pile)
        local dirt = Config.DirtPile
        local dirtHash = GetHashKey(dirt.Model)
        RequestModel(dirtHash)
        while not HasModelLoaded(dirtHash) do Wait(10) end
        
        local pedCoords = GetEntityCoords(ped)
        local pedHeading = GetEntityHeading(ped)
        local rad = math.rad(pedHeading)
        
        -- Spawn na frente do jogador (OffsetForward)
        local spawnX = pedCoords.x + (math.sin(-rad) * dirt.OffsetForward)
        local spawnY = pedCoords.y + (math.cos(-rad) * dirt.OffsetForward)
        local spawnZ = pedCoords.z + dirt.OffsetZ
        
        local dirtObj = CreateObject(dirtHash, spawnX, spawnY, spawnZ, true, true, false)
        PlaceObjectOnGroundProperly(dirtObj)
        SetEntityHeading(dirtObj, pedHeading)
        SetModelAsNoLongerNeeded(dirtHash)
    end
    
    TriggerServerEvent('illegal-system:server:finishGraveRobbery', result.success, result.tier, data.sessionToken)
end)
