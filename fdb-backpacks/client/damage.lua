-- Monitoramento de dano ao jogador local usando diferença de vida (100% garantido para NPCs/Quedas/Fogo)
CreateThread(function()
    local lastHealth = GetEntityHealth(PlayerPedId())
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local currentHealth = GetEntityHealth(ped)
        
        if currentHealth ~= lastHealth then
            -- print(("[fdb-backpacks Debug] Player HP changed: %s -> %s (Wearing: %s)"):format(lastHealth, currentHealth, tostring(LocalPlayer.state.currentBackpackStashId)))
        end
        
        if currentHealth < lastHealth then
            if LocalPlayer.state.currentBackpackStashId then
                local damageType = 'gunshot' -- Tipo padrão (tiro/dano geral)

                if IsEntityOnFire(ped) then
                    damageType = 'fire'
                elseif IsPedRagdoll(ped) and GetEntityHeightAboveGround(ped) > 2.5 then
                    damageType = 'fall'
                end

                -- print(("[fdb-backpacks Debug] Reporting player damage: %s"):format(damageType))
                TriggerServerEvent('fdb-backpacks:server:damageBackpack', damageType)
            end
        end
        lastHealth = currentHealth
    end
end)

-- Monitoramento de dano às mochilas no chão usando alteração de HP do objeto (100% garantido para tiros/fogo no chão)
local initialHealths = {}
CreateThread(function()
    while true do
        Wait(500)
        if groundBackpacks then
            for uid, bpData in pairs(groundBackpacks) do
                if NetworkDoesNetworkIdExist(bpData.netId) then
                    local entity = NetworkGetEntityFromNetworkId(bpData.netId)
                    if entity and DoesEntityExist(entity) then
                        local currentHealth = GetEntityHealth(entity)
                        
                        if not initialHealths[entity] then
                            initialHealths[entity] = currentHealth
                            print(("[fdb-backpacks Debug] Tracking ground backpack %s | Initial HP: %s"):format(entity, currentHealth))
                        elseif currentHealth < initialHealths[entity] then
                            print(("[fdb-backpacks Debug] Ground backpack %s took damage! HP: %s -> %s"):format(entity, initialHealths[entity], currentHealth))
                            -- Reseta o HP da entidade no cliente para permitir detecções futuras
                            SetEntityHealth(entity, initialHealths[entity])
                            ClearEntityLastDamageEntity(entity)
                            
                            local damageType = 'gunshot'
                            if IsEntityOnFire(entity) then
                                damageType = 'fire'
                            end
                            
                            TriggerServerEvent('fdb-backpacks:server:damageGroundBackpack', bpData.stashId, damageType)
                        end
                    end
                end
            end
        end
    end
end)
