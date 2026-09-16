-- ============================================================
-- FDB System | fdb-medical-core | client/fracture_effects.lua
-- ============================================================

-- Manages visual/mechanical fracture effects on the player.
-- Exposes exports so other resources (fdb-survival, fdb-weapons) can
-- query the fracture state without relying on shared global variables.

local HasArmFracture = false
local HasTorsoFracture = false
local swayIntensity = 0.8

-- ============================================================
-- EXPORTS (cross-resource reading)
-- ============================================================
exports('HasArmFracture', function()
    return HasArmFracture
end)

exports('HasTorsoFracture', function()
    return HasTorsoFracture
end)

-- ============================================================
-- EVENTS (listen to both local TriggerEvent and TriggerClientEvent)
-- ============================================================

-- Old pattern: RegisterNetEvent (declare) + AddEventHandler (register)
-- Ensures it works with local TriggerEvent (between resources on same client)
-- And also with TriggerClientEvent from the server.

RegisterNetEvent('fdb-medical-core:client:SetStaminaPenalty')
AddEventHandler('fdb-medical-core:client:SetStaminaPenalty', function(active)
    HasTorsoFracture = active
    print('[fdb-medical-core] HasTorsoFracture = ' .. tostring(active))
    -- Vote in fdb-survival Maestro to block sprint
    TriggerEvent('fdb-survival:client:SetSprintDisable', 'fracture_torso', active)
end)

RegisterNetEvent('fdb-medical-core:client:SetAimPenalty')
AddEventHandler('fdb-medical-core:client:SetAimPenalty', function(active)
    HasArmFracture = active
    print('[fdb-medical-core] HasArmFracture = ' .. tostring(active))
end)

RegisterNetEvent('fdb-medical-core:client:SetSwayIntensity')
AddEventHandler('fdb-medical-core:client:SetSwayIntensity', function(val)
    swayIntensity = val
    print('[fdb-medical-core] swayIntensity = ' .. tostring(val))
end)

-- ============================================================
-- WALKSTYLE PENALTY (mancada persistente até a fratura sarar)
-- ============================================================
local activeFractureParts = {}

local walkstyleAnims = {
    RLEG = 'injured_right_leg',
    LLEG = 'injured_left_leg',
    RARM = 'injured_right_arm',
    LARM = 'injured_left_arm',
}

RegisterNetEvent('fdb-medical-core:client:SetWalkstylePenalty')
AddEventHandler('fdb-medical-core:client:SetWalkstylePenalty', function(active, bodyPart)
    if active then
        activeFractureParts[bodyPart] = true
    else
        activeFractureParts[bodyPart] = nil
    end
end)

CreateThread(function()
    local wasActive = false
    while true do
        Wait(3000)
        local ped = PlayerPedId()
        local anyActive = false
        local chosenAnim = nil

        for part, _ in pairs(activeFractureParts) do
            anyActive = true
            chosenAnim = walkstyleAnims[part] or 'injured_general'
            if walkstyleAnims[part] then
                break -- prioriza mancada de perna/braço específica sobre a genérica
            end
        end

        if anyActive then
            Citizen.InvokeNative(0x923583741DC87BCE, ped, 'default')
            Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, chosenAnim)
            wasActive = true
        elseif wasActive then
            Citizen.InvokeNative(0x923583741DC87BCE, ped, 'arthur_healthy')
            Citizen.InvokeNative(0xAA74EC0CB0AAEA2C, ped, 'default')
            wasActive = false
        end
    end
end)

-- ============================================================
-- AIM SWAY (fractured arm)
-- Applies smooth sinusoidal offset to camera heading/pitch
-- while the player is aiming. It's not a shake - it's a "sway".
-- ============================================================
CreateThread(function()
    local timer = 0.0
    while true do
        Wait(0)
        if HasArmFracture then
            -- IsPlayerFreeAiming (confirmed RDR3 native)
            local isAiming = Citizen.InvokeNative(0x2E623EBE, PlayerId())
            if isAiming then
                timer = timer + 0.016

                local swayH = math.sin(timer * 1.7) * swayIntensity
                    + math.sin(timer * 3.1) * (swayIntensity * 0.4)
                local swayV = math.cos(timer * 1.3) * (swayIntensity * 0.6)
                    + math.cos(timer * 2.7) * (swayIntensity * 0.3)

                -- GET_GAMEPLAY_CAM_RELATIVE_HEADING / PITCH
                local currentH = Citizen.InvokeNative(0xC4ABF536048998AA)
                local currentV = Citizen.InvokeNative(0x99AADEBBA803F827)

                -- SET_GAMEPLAY_CAM_RELATIVE_HEADING / PITCH
                Citizen.InvokeNative(0x5D1EB123EAC5D071, currentH + swayH)
                Citizen.InvokeNative(0xFB760AF4F537B8BF, currentV + swayV, 1.0)
            else
                timer = 0.0
            end
        else
            Wait(1000)
        end
    end
end)

-- ============================================================
-- SAFETY RESET
-- ============================================================
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        HasArmFracture = false
        HasTorsoFracture = false
        activeFractureParts = {}
    end
end)
