-- =========================================================
-- FDB-MEDIC - WOUND HEALING SYSTEM (Phase C refactor)
-- =========================================================
-- This file handles wound healing to scars when properly cared for
-- Requirements: treated + no bleeding + maintained for full duration
-- Reads entirely from statebag.
-- =========================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local HealingTimers = {}

local function StartHealing(bodyPart)
    if HealingTimers[bodyPart] then return end
    
    HealingTimers[bodyPart] = {
        startTime = GetGameTimer(),
        healTime = 15 -- 15 minutes default to heal
    }
    
    lib.notify({
        title = locale('qc_health'),
        description = locale('cl_desc_fmt_wound_beginning_heal'),
        type = 'success',
        duration = 5000
    })
end

local function StopHealing(bodyPart)
    if HealingTimers[bodyPart] then
        HealingTimers[bodyPart] = nil
        lib.notify({
            title = locale('qc_health'),
            description = locale('cl_desc_fmt_wound_healing_interrupted'),
            type = 'error',
            duration = 5000
        })
    end
end

function ProcessWoundHealing()
    local ped = PlayerPedId()
    local state = Entity(ped).state.medical
    if not state or not state.wounds then return end
    
    local currentTime = GetGameTimer()
    
    for bodyPart, wound in pairs(state.wounds) do
        if wound.isScar then goto continue end
        
        -- Check if conditions are met
        local canHeal = wound.treated and (wound.bleeding == 0 or wound.bleeding == nil)
        local isCurrentlyHealing = HealingTimers[bodyPart] ~= nil
        
        if canHeal and not isCurrentlyHealing then
            StartHealing(bodyPart)
        elseif not canHeal and isCurrentlyHealing then
            StopHealing(bodyPart)
        elseif canHeal and isCurrentlyHealing then
            local healing = HealingTimers[bodyPart]
            local elapsedMinutes = (currentTime - healing.startTime) / 1000 / 60
            
            if elapsedMinutes >= healing.healTime then
                HealingTimers[bodyPart] = nil
                -- Intenção: servidor, converte em cicatriz
                TriggerServerEvent('fdb-medical-core:server:ConvertWoundToScar', bodyPart)
                
                lib.notify({
                    title = locale('qc_health'),
                    description = locale('cl_desc_fmt_wound_healed_scar'),
                    type = 'success',
                    duration = 5000
                })
            end
        end
        
        ::continue::
    end
end

CreateThread(function()
    while true do
        Wait(10000) -- Check every 10 seconds
        if LocalPlayer.state['isLoggedIn'] then
            ProcessWoundHealing()
        end
    end
end)
