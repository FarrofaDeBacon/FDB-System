-- fracture_effects.lua (fdb-medical-core, client-side)
-- Gerencia os efeitos visuais/mecânicos de fraturas no jogador.
-- Expõe exports para que outros resources (fdb-survival, fdb-weapons) possam
-- consultar o estado de fratura sem depender de variáveis globais compartilhadas.

local HasArmFracture = false
local HasTorsoFracture = false
local swayIntensity = 0.8

-- ============================================================
-- EXPORTS (leitura cross-resource)
-- ============================================================
exports('HasArmFracture', function()
    return HasArmFracture
end)

exports('HasTorsoFracture', function()
    return HasTorsoFracture
end)

-- ============================================================
-- EVENTOS (escutam tanto TriggerEvent local quanto TriggerClientEvent)
-- ============================================================

-- Padrão antigo: RegisterNetEvent (declara) + AddEventHandler (registra)
-- Garante que funciona com TriggerEvent local (entre resources no mesmo client)
-- E também com TriggerClientEvent vindo do servidor.

RegisterNetEvent('fdb-medical-core:client:SetStaminaPenalty')
AddEventHandler('fdb-medical-core:client:SetStaminaPenalty', function(active)
    HasTorsoFracture = active
    print('[fdb-medical-core] HasTorsoFracture = ' .. tostring(active))
    -- Votar no Maestro do fdb-survival para bloquear sprint
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
-- SWAY DE MIRA (braço fraturado)
-- Aplica offset sinusoidal suave no heading/pitch da câmera
-- enquanto o jogador está mirando. Não é shake — é "escorregamento".
-- ============================================================
CreateThread(function()
    local timer = 0.0
    while true do
        Wait(0)
        if HasArmFracture then
            -- IsPlayerFreeAiming (RDR3 native confirmada)
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
-- RESET DE SEGURANÇA
-- ============================================================
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        HasArmFracture = false
        HasTorsoFracture = false
    end
end)
