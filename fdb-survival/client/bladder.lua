local isHoldingPee = false
local peeAccidentTimer = 0

CreateThread(function()
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
                            TaskStartScenarioInPlace(ped, joaat('WORLD_HUMAN_VOMIT'), -1, true, false, false, false)
                            Wait(4000)
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

RegisterCommand("mijar", function()
    local ped = PlayerPedId()
    if IsPedOnMount(ped) or IsPedInAnyVehicle(ped, false) then
        exports['ox_lib']:notify({ title = locale('notify_pee_error_title'), description = locale('notify_pee_mount_error'), type = 'error' })
        return
    end
    
    ClearPedTasks(ped)
    TaskStartScenarioInPlace(ped, joaat('WORLD_HUMAN_PEE'), -1, true, false, false, false)
    Wait(4000)

    local assetName = "core"
    local ptfxName = "ent_anim_dog_peeing"
    
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

    Wait(6000)
    StopParticleFxLooped(peeParticle, false)
    RemoveNamedPtfxAsset(assetName)
    Wait(3500)
    ClearPedTasks(ped)
    
    FDB.Survival.bladder = 0
    FDB.BroadcastState('bladder', 0)
    TriggerServerEvent('fdb-survival:server:EmptyBladder')
end, false)

CreateThread(function()
    exports.ox_target:addGlobalObject({
        {
            name = 'pee_action_object',
            label = 'Mijar',
            icon = 'fa-solid fa-droplet',
            onSelect = function() ExecuteCommand('mijar') end,
            distance = 2.0
        }
    })
    
    exports.ox_target:addGlobalVehicle({
        {
            name = 'pee_action_vehicle',
            label = 'Mijar',
            icon = 'fa-solid fa-droplet',
            onSelect = function() ExecuteCommand('mijar') end,
            distance = 2.0
        }
    })
end)
