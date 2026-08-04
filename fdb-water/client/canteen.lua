local FDBCore = exports['fdb-core']:GetCoreObject()
local isBusy = false
local entity = nil
lib.locale()

------------------------
-- function load model
------------------------
local function LoadModel(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
end

------------------------
-- drink water from flask
------------------------
RegisterNetEvent('fdb-water:client:drink', function(amount, item)
    if isBusy then return end
    isBusy = true

    local coords = GetEntityCoords(cache.ped)
    local water = GetWaterMapZoneAtCoords(coords.x + 3, coords.y + 3, coords.z)
    local isValidWater = false
    local refillable = item == 'canteen0' or item == 'canteen25' or item == 'canteen50' or item == 'canteen75' or item == 'empty_bottle'

    for _, v in pairs(Config.WaterTypes) do
        if water == v.waterhash then
            isValidWater = true
            break
        end
    end

    -- Early block: prevent drinking from empty canteen/bottle in invalid water
    if (item == 'canteen0' or item == 'empty_bottle') and (not isValidWater or not IsEntityInWater(cache.ped)) then
        lib.notify({
            title = locale('cl_lang_1'),
            description = locale('cl_lang_2'),
            type = 'error',
            duration = 7000
        })
        isBusy = false
        return
    end

    -- Animation setup
    SetCurrentPedWeapon(cache.ped, joaat('weapon_unarmed'))
    Wait(100)

    if not IsPedOnMount(cache.ped) and not IsPedInAnyVehicle(cache.ped) then
        local dict = 'amb_rest_drunk@world_human_drinking@female_a@idle_a'
        local anim = 'idle_a'
        local boneIndex = GetEntityBoneIndexByName(cache.ped, 'SKEL_R_HAND')
        
        local modelStr = 'p_cs_canteen_hercule'
        if item == 'empty_bottle' then
            modelStr = 'p_bottle01x'
        end
        local modelHash = GetHashKey(modelStr)

        LoadModel(modelHash)
        entity = CreateObject(modelHash, coords.x + 0.3, coords.y, coords.z, true, false, false)
        SetEntityVisible(entity, true)
        SetEntityAlpha(entity, 255, false)
        Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
        SetModelAsNoLongerNeeded(modelHash)
        AttachEntityToEntity(entity, cache.ped, boneIndex, 0.10, 0.09, -0.05, 306.0, 18.0, 0.0, true, true, false, true, 2, true)

        local inWater = IsEntityInWater(cache.ped)
        local shouldRefill = isValidWater and refillable and inWater

        if shouldRefill and IsPedOnFoot(cache.ped) then
            -- Se for para encher, o personagem se abaixa com o prop na mão e não bebe
            TaskStartScenarioInPlace(cache.ped, joaat('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
            Wait(4000) -- Tempo abaixado enchendo
            ClearPedTasks(cache.ped)
        else
            -- Se for para beber (fora d'água ou cantil cheio), toca a animação de beber
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end
            TaskPlayAnim(cache.ped, dict, anim, 1.0, 1.0, -1, 31, 1.0, false, false, false)
            Wait(5000)
        end
    end

    -- Decision logic: refill, degrade, or block
    local inWater = IsEntityInWater(cache.ped)
    local shouldRefill = isValidWater and refillable and inWater
    local shouldDegrade = not refillable or not inWater

    if shouldRefill then
        -- Encheu na água. Nenhuma sede é restaurada, só o item é dado.
        if item == 'canteen0' then
            TriggerServerEvent('fdb-water:server:givefullcanteen')
        elseif item == 'canteen25' then
            TriggerServerEvent('fdb-water:server:givefullcanteen25')
        elseif item == 'canteen50' then
            TriggerServerEvent('fdb-water:server:givefullcanteen50')
        elseif item == 'canteen75' then
            TriggerServerEvent('fdb-water:server:givefullcanteen75')
        elseif item == 'empty_bottle' then
            TriggerServerEvent('fdb-water:server:refillbottle')
        end

    elseif shouldDegrade then
        TriggerServerEvent('fdb-water:server:degradecanteen', item)
        TriggerServerEvent('fdb-survival:server:AddThirst', amount)

    else
        -- This case: refillable canteen, not in water, no degrade
        if item == 'canteen0' or item == 'empty_bottle' then
            lib.notify({
                title = locale('cl_lang_1'),
                description = locale('cl_lang_2'),
                type = 'error',
                duration = 7000
            })
        end
    end

    -- Cleanup
    ClearPedTasks(cache.ped)
    if entity then
        DeleteObject(entity)
        entity = nil
    end
    isBusy = false
end)
