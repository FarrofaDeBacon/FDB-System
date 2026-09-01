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
            
            -- Reporta pro servidor processar e oficializar na Statebag
            TriggerServerEvent('fdb-medical-core:server:ReportDamage', 'Torso', damageType, damageDelta)
            
            -- Atualiza referência local imediatamente para evitar reports duplicados
            lastHealth = currentHealth
        elseif currentHealth > lastHealth then
            -- O servidor/jogo curou o player nativamente, atualizamos a âncora
            lastHealth = currentHealth
        end
    end
end)
