-- ============================================================
-- FDB System | fdb-medical-core | client/sync.lua
-- Statebag listeners for client vitals synchronization
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()

-- Handler to listen for vital updates in the player ped's Statebag
AddStateBagChangeHandler('medical', nil, function(bagName, key, value, _unused, replicated)
    if not value then return end

    local playerPed = PlayerPedId()
    local entity = GetEntityFromStateBagName(bagName)

    if entity == playerPed then
        -- Forwards the event locally for listeners such as the HUD (fdb-hudpremium)
        TriggerEvent('fdb-medical-core:client:vitalsUpdated', value)
    end
end)
-- Cleanup and thread termination upon resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("[fdb-medical-core] Resource terminated cleanly.")
    end
end)

RegisterNetEvent('fdb-medical-core:client:setHealth', function(newHp)
    local ped = PlayerPedId()
    SetEntityHealth(ped, math.floor(newHp))
end)

-- ============================================================
-- Hybrid Health Monitoring (RedM Client Level)
-- ============================================================
CreateThread(function()
    local ped = PlayerPedId()
    local lastHealth = GetEntityHealth(ped)

    while true do
        Wait(500)
        
        -- Ensure updated ped (after death/respawn)
        local currentPed = PlayerPedId()
        if currentPed ~= ped then
            ped = currentPed
            lastHealth = GetEntityHealth(ped)
        end
        
        local currentHealth = GetEntityHealth(ped)
        
        -- Native health drop detected! (Environmental/physical damage not reported by the server)
        if currentHealth < lastHealth then
            local damageDelta = lastHealth - currentHealth
            
            -- Detect the most likely cause
            local damageType = 'Generic'
            if IsEntityOnFire(ped) then
                damageType = 'Burn'
            elseif IsPedRagdoll(ped) and GetEntityHeightAboveGround(ped) > 2.0 then
                damageType = 'Fall'
            end
            
            local bodyPart = BodyPart.TORSO
            local boneHit, boneIndex = GetPedLastDamageBone(ped)
            if boneHit then
                bodyPart = exports['fdb-medical-core']:GetBodyPartFromBone(boneIndex)

                -- If damage is severe, apply walkstyle
                if damageDelta >= 20 then
                    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'default') -- Clipset
                    if bodyPart == BodyPart.RLEG then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_right_leg')
                    elseif bodyPart == BodyPart.LLEG then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_left_leg')
                    elseif bodyPart == BodyPart.RARM then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_right_arm')
                    elseif bodyPart == BodyPart.LARM then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_left_arm')
                    else
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_general')
                    end
                end
            end
            
            -- Report to the server to process and officialize in the Statebag
            TriggerServerEvent('fdb-medical-core:server:ReportDamage', bodyPart, damageType, damageDelta)
            
            -- Update local reference immediately to avoid duplicate reports
            lastHealth = currentHealth
        elseif currentHealth > lastHealth then
            -- The server/game healed the player natively, update the anchor
            lastHealth = currentHealth
        end
    end
end)

