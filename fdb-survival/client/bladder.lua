local isHoldingPee = false
local peeAccidentTimer = 0

CreateThread(function()
    if not Config.BladderSystem or not Config.BladderSystem.Enabled then return end
    while true do
        Wait(1000)
        if FDB.IsLoggedIn then
            if FDB.Survival.bladder >= 100 then
                -- Bladder is full, start counting the accident timer
                if isHoldingPee then
                    peeAccidentTimer = peeAccidentTimer + 1
                    local limit = Config.DrainRates.BladderAccidentTime or 60
                    
                    if peeAccidentTimer >= limit then
                        -- Player peed their pants
                        peeAccidentTimer = 0
                        isHoldingPee = false
                        
                        -- Force pee accident
                        local ped = PlayerPedId()
                        exports['ox_lib']:notify({
                            title = locale('notify_bladder_full_title') or 'Bexiga Cheia',
                            description = 'Você não conseguiu segurar e urinou nas calças!',
                            type = 'error',
                            duration = 7000
                        })
                        
                        -- Drop cleanliness to 0 immediately
                        FDB.Survival.cleanliness = 0
                        FDB.BroadcastState('cleanliness', 0)
                        
                        -- Clear bladder
                        FDB.Survival.bladder = 0
                        FDB.BroadcastState('bladder', 0)
                        
                        TriggerServerEvent('fdb-survival:server:PeeAccident')
                        
                        -- Play a small embarrassment animation if not in vehicle
                        if not IsPedInAnyVehicle(ped, false) and not IsPedOnMount(ped) then
                            ClearPedTasks(ped)
                            local useScenario = Config.BladderSystem.AccidentUseScenario
                            local accidentAnim = Config.BladderSystem.AccidentAnimation or 'WORLD_HUMAN_VOMIT'
                            
                            if useScenario == false then
                                local dict = Config.BladderSystem.AccidentAnimDict or "amb_misc@world_human_vomit@male_a@idle_b"
                                RequestAnimDict(dict)
                                while not HasAnimDictLoaded(dict) do Wait(10) end
                                TaskPlayAnim(ped, dict, accidentAnim, 1.0, -1.0, -1, 1, 0, false, false, false)
                            else
                                TaskStartScenarioInPlace(ped, joaat(accidentAnim), -1, true, false, false, false)
                            end
                            
                            Wait(Config.BladderSystem.AccidentAnimDuration or 4000)
                            ClearPedTasks(ped)
                        end
                    end
                else
                    isHoldingPee = true
                    peeAccidentTimer = 0
                    exports['ox_lib']:notify({
                        title = locale('notify_bladder_full_title') or 'Bexiga Cheia',
                        description = locale('notify_bladder_full_desc') or 'Você precisa urinar com urgência!',
                        type = 'warning',
                        duration = 5000
                    })
                end
            elseif FDB.Survival.bladder >= 80 and FDB.Survival.bladder < 100 then
                -- Warning state
                if not isHoldingPee then
                    isHoldingPee = true
                    peeAccidentTimer = 0
                    exports['ox_lib']:notify({
                        title = locale('notify_bladder_full_title') or 'Bexiga Cheia',
                        description = locale('notify_bladder_full_desc') or 'Você precisa encontrar um lugar para urinar logo!',
                        type = 'warning',
                        duration = 5000
                    })
                end
            elseif FDB.Survival.bladder < 80 and isHoldingPee then
                isHoldingPee = false
                peeAccidentTimer = 0
            end
        end
    end
end)

-- Thread de bloqueio de corrida movida para movement.lua (Maestro)

RegisterNetEvent('fdb-survival:client:PeeTarget', function(isOuthouse)
    if not Config.BladderSystem or not Config.BladderSystem.Enabled then return end
    
    local ped = PlayerPedId()
    if IsPedOnMount(ped) or IsPedInAnyVehicle(ped, false) then
        exports['ox_lib']:notify({ title = locale('notify_pee_error_title'), description = locale('notify_pee_mount_error'), type = 'error' })
        return
    end
    
    local coords = GetEntityCoords(ped)

    -- 1. Regra de Etiqueta (RP): Não mijar na frente de damas
    local privacyRadius = Config.BladderSystem.PrivacyRadius or 15.0
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= ped then
            local dist = #(coords - GetEntityCoords(targetPed))
            if dist < privacyRadius then
                if GetEntityModel(targetPed) == `mp_female` then
                    exports['ox_lib']:notify({ title = locale('notify_indecency_title'), description = locale('notify_indecency_desc'), type = 'error', duration = 5000 })
                    return
                end
            end
        end
    end
    
    -- 2. Regra de Cidades: Bloqueado em cidades se NÃO for uma fossa
    if not isOuthouse and Config.BladderSystem.BlockedTowns then
        local townHash = Citizen.InvokeNative(0x43AD8FC02B429D33, coords, 1)
        if townHash and townHash ~= 0 and Config.BladderSystem.BlockedTowns[townHash] then
            exports['ox_lib']:notify({ title = locale('notify_fine_avoided_title'), description = locale('notify_fine_avoided_desc'), type = 'error', duration = 5000 })
            return
        end
    end
    
    ClearPedTasks(ped)
    local useScenario = Config.BladderSystem.UseScenario
    local animName = Config.BladderSystem.AnimationName or "WORLD_HUMAN_PEE"
    
    if useScenario == false then
        local animDict = Config.BladderSystem.AnimationDict or "amb_misc@world_human_pee@male_a@idle_b"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Wait(10) end
        TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, -1, 1, 0, false, false, false)
    else
        TaskStartScenarioInPlace(ped, joaat(animName), -1, true, false, false, false)
    end
    
    Wait(Config.BladderSystem.AnimWaitBefore or 4000)

    local assetName = Config.BladderSystem.ParticleDict or "core"
    local ptfxName = Config.BladderSystem.ParticleName or "ent_anim_dog_peeing"
    
    RequestNamedPtfxAsset(assetName)
    while not HasNamedPtfxAssetLoaded(assetName) do
        Wait(10)
    end
    
    UseParticleFxAsset(assetName)
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_Pelvis")
    local peeParticle = StartNetworkedParticleFxLoopedOnEntityBone(
        ptfxName, ped,
        0.0, 0.15, -0.1,
        -90.0, 0.0, 0.0,
        boneIndex,
        5.0,
        false, false, false
    )
    SetParticleFxLoopedColour(peeParticle, 1.0, 1.0, 0.0, 0)

    Wait(Config.BladderSystem.AnimDuration or 6000)
    StopParticleFxLooped(peeParticle, false)
    RemoveNamedPtfxAsset(assetName)
    Wait(Config.BladderSystem.AnimWaitAfter or 3500)
    ClearPedTasks(ped)
    
    FDB.Survival.bladder = 0
    FDB.BroadcastState('bladder', 0)
    TriggerServerEvent('fdb-survival:server:EmptyBladder')
end)

CreateThread(function()
    if not Config.BladderSystem or not Config.BladderSystem.Enabled then return end

    Wait(2000)
    local ped = PlayerPedId()
    local isFemale = GetEntityModel(ped) == `mp_female`
    local targetLabel = isFemale and (Config.BladderSystem.LabelFemale or 'Fazer Xixi') or (Config.BladderSystem.LabelMale or 'Mijar')

    -- Modelos de Árvores e Fossas puxados do Config
    local treeModels = Config.BladderSystem.TreeModels or {}
    local outhouseModels = Config.BladderSystem.OuthouseModels or {}

    -- Target para Árvores (bloqueado em cidades)
    exports.ox_target:addModel(treeModels, {
        {
            name = 'pee_action_tree',
            label = targetLabel,
            icon = 'fa-solid fa-droplet',
            onSelect = function() TriggerEvent('fdb-survival:client:PeeTarget', false) end,
            distance = 2.5
        }
    })
    
    -- Target para Fossas (permitido em cidades)
    exports.ox_target:addModel(outhouseModels, {
        {
            name = 'pee_action_outhouse',
            label = targetLabel,
            icon = 'fa-solid fa-toilet',
            onSelect = function() TriggerEvent('fdb-survival:client:PeeTarget', true) end,
            distance = 2.5
        }
    })
end)

-- Comando temporário para debug de modelos
RegisterCommand('pee_debug', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local targetCoords = coords + (forward * 5.0)
    
    -- 16 = Testar contra objetos/cenário
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, targetCoords.x, targetCoords.y, targetCoords.z, 16, ped, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    if hit == 1 and entityHit ~= 0 then
        local model = GetEntityModel(entityHit)
        print("FDB-SURVIVAL: Looking at entity with model hash: " .. tostring(model))
        exports['ox_lib']:notify({ title = 'Debug de Modelo', description = 'Hash do Objeto: ' .. tostring(model), type = 'info', duration = 8000 })
    else
        exports['ox_lib']:notify({ title = 'Debug de Modelo', description = 'Nenhum objeto detectado na sua frente.', type = 'error' })
    end
end, false)
