-- ============================================================
-- fdb-medical | client/sync.lua
-- Listener de Statebags para sincronizar vitais no client
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()

-- Handler para ouvir atualizações de vitais na Statebag do ped do jogador
AddStateBagChangeHandler('medical', nil, function(bagName, key, value, _unused, replicated)
    if not value then return end

    local playerPed = PlayerPedId()
    local entity = GetEntityFromStateBagName(bagName)

    if entity == playerPed then
        -- Repassa o evento localmente para listeners como o HUD (fdb-hudpremium)
        TriggerEvent('fdb-medical-core:client:vitalsUpdated', value)
    end
end)
-- Limpeza e encerramento de threads ao parar o recurso
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("[fdb-medical-core] Recurso finalizado de forma limpa.")
    end
end)

RegisterNetEvent('fdb-medical-core:client:setHealth', function(newHp)
    local ped = PlayerPedId()
    SetEntityHealth(ped, math.floor(newHp))
end)

-- ============================================================
-- Monitoramento Híbrido de Vida (RedM Nível Cliente)
-- ============================================================
CreateThread(function()
    local ped = PlayerPedId()
    local lastHealth = GetEntityHealth(ped)

    while true do
        Wait(500)
        
        -- Garante ped atualizado (após morte/respawn)
        local currentPed = PlayerPedId()
        if currentPed ~= ped then
            ped = currentPed
            lastHealth = GetEntityHealth(ped)
        end
        
        local currentHealth = GetEntityHealth(ped)
        
        -- Queda de vida detectada nativamente! (Dano ambiental/físico não reportado pelo server)
        if currentHealth < lastHealth then
            local damageDelta = lastHealth - currentHealth
            
            -- Detecta a causa mais provável
            local damageType = 'Generic'
            if IsEntityOnFire(ped) then
                damageType = 'Burn'
            elseif IsPedRagdoll(ped) and GetEntityHeightAboveGround(ped) > 2.0 then
                damageType = 'Fall'
            end
            
            local bodyPart = 'Torso'
            local boneHit, boneIndex = GetPedLastDamageBone(ped)
            if boneHit then
                -- Salvaged from dodi_bonessystem
                local boneMapping = {
                    [27981] = 'Head', [57278] = 'Head', [54890] = 'Head', [21030] = 'Head',
                    [24015] = 'Torso', [52596] = 'Torso', [32630] = 'Torso', [14283] = 'Torso',
                    [14410] = 'Torso', [14411] = 'Torso', [30226] = 'Torso', [56200] = 'Torso',
                    [43700] = 'Left Arm', [24238] = 'Left Arm', [55540] = 'Left Arm', [53675] = 'Left Arm',
                    [34606] = 'Left Arm', -- Hand mapped to arm for simplicity
                    [40091] = 'Left Leg', [52390] = 'Left Leg', [65480] = 'Left Leg', [21174] = 'Left Leg',
                    [45454] = 'Left Leg', -- Foot
                    [54187] = 'Right Arm', [46065] = 'Right Arm', [46260] = 'Right Arm', [65198] = 'Right Arm',
                    [22798] = 'Right Arm', -- Hand
                    [64298] = 'Right Leg', [27814] = 'Right Leg', [65384] = 'Right Leg', [19638] = 'Right Leg',
                    [33646] = 'Right Leg', -- Foot
                    
                    -- TODO: FDB-System - Pending test for unknown bones falling back to Torso
                    [23553] = 'Torso', -- NEEDS TEST: Find out which body part this is in F8
                    [64729] = 'Torso', -- NEEDS TEST: Find out which body part this is in F8
                }
                bodyPart = boneMapping[boneIndex] or 'Torso'
                
                -- Se o dano for severo, aplica walkstyle (aproveitado de dodi_bonessystem)
                if damageDelta >= 20 then
                    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'default') -- Clipset
                    if bodyPart == 'Right Leg' then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_right_leg')
                    elseif bodyPart == 'Left Leg' then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_left_leg')
                    elseif bodyPart == 'Right Arm' then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_right_arm')
                    elseif bodyPart == 'Left Arm' then
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_left_arm')
                    else
                        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'injured_general')
                    end
                end
            end
            
            -- Reporta pro servidor processar e oficializar na Statebag
            TriggerServerEvent('fdb-medical-core:server:ReportDamage', bodyPart, damageType, damageDelta)
            
            -- Atualiza referência local imediatamente para evitar reports duplicados
            lastHealth = currentHealth
        elseif currentHealth > lastHealth then
            -- O servidor/jogo curou o player nativamente, atualizamos a âncora
            lastHealth = currentHealth
        end
    end
end)
