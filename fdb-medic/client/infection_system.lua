-- =========================================================
-- FDB-MEDIC - INFECTION SYSTEM (Phase C refactor)
-- =========================================================
-- This file handles visual/gameplay effects of infections.
-- Progression and curing are handled purely by the server.
-- Reads entirely from statebag.
-- =========================================================

local FDBCore = exports['fdb-core']:GetCoreObject()

-- Track last known stages to show notifications when it worsens
local LastKnownStages = {}

local function ApplyInfectionEffects(state)
    if not state or not state.wounds then return end
    
    local highestStage = 0
    
    for bodyPart, wound in pairs(state.wounds) do
        if wound.infected and wound.infectionStage > 0 then
            local currentStage = wound.infectionStage
            
            -- Detect progression for notification
            if not LastKnownStages[bodyPart] or LastKnownStages[bodyPart] < currentStage then
                LastKnownStages[bodyPart] = currentStage
                
                local stageConfig = Config.InfectionSystem and Config.InfectionSystem.stages and Config.InfectionSystem.stages[currentStage]
                if stageConfig and stageConfig.symptom then
                    lib.notify({
                        title = locale('cl_menu_medical_condition'),
                        description = stageConfig.symptom,
                        type = 'error',
                        duration = 6000
                    })
                end
            elseif LastKnownStages[bodyPart] > currentStage then
                -- Healed partially or fully
                LastKnownStages[bodyPart] = currentStage
            end
            
            if currentStage > highestStage then
                highestStage = currentStage
            end
        else
            LastKnownStages[bodyPart] = 0
        end
    end
    
    if highestStage > 0 then
        local stageConfig = Config.InfectionSystem and Config.InfectionSystem.stages and Config.InfectionSystem.stages[highestStage]
        if stageConfig and stageConfig.effects then
            local effects = stageConfig.effects
            
            -- Stamina drain
            if effects.staminaDrain and effects.staminaDrain > 0 then
                local multiplier = 1.0 + (effects.staminaDrain / 50.0)
                SetPlayerStaminaSprintDepletionMultiplier(PlayerId(), multiplier)
            else
                SetPlayerStaminaSprintDepletionMultiplier(PlayerId(), 1.0)
            end
            
            -- Movement penalty
            if effects.movementPenalty and effects.movementPenalty > 0 then
                local moveRate = math.max(1.0 - (effects.movementPenalty / 100), 0.2)
                TriggerEvent('fdb-survival:client:SetMoveRateModifier', 'infection', moveRate)
            else
                TriggerEvent('fdb-survival:client:SetMoveRateModifier', 'infection', nil)
            end
        end
    else
        SetPlayerStaminaSprintDepletionMultiplier(PlayerId(), 1.0)
        TriggerEvent('fdb-survival:client:SetMoveRateModifier', 'infection', nil)
    end
end

CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds for visual effects
        if LocalPlayer.state['isLoggedIn'] then
            local ped = PlayerPedId()
            local state = Entity(ped).state.medical
            ApplyInfectionEffects(state)
        end
    end
end)
