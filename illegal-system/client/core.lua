--[[
    Client Etapa 2. Fica deliberadamente fino: toda regra de negócio está
    no servidor. Aqui só existe apresentação (target, animação, notificação).
]]

CreateThread(function()
    Bridge.RegisterGlobalPedTarget({
        {
            name = 'illegal_rob_npc',
            icon = 'fa-solid fa-mask',
            label = 'Roubar',
            distance = 2.0,
            onSelect = function(data)
                local ped = data.entity
                if not ped or IsPedAPlayer(ped) then return end
                
                local playerPed = PlayerPedId()
                
                -- animação/minigame local só como feedback visual — não decide nada
                TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
                Wait(1500)
                ClearPedTasks(playerPed)

                TriggerServerEvent('illegal-system:server:attemptNpcRobbery')
            end
        }
    })
end)

RegisterNetEvent('illegal-system:client:startNpcRobberyMinigame', function(data)
    local crimeConfig = Config.Crimes['npc_robbery']
    
    local images = {
        common = Bridge.GetInventoryImageURL(data.items.common),
        uncommon = Bridge.GetInventoryImageURL(data.items.uncommon),
        rare = Bridge.GetInventoryImageURL(data.items.rare)
    }
    
    local result = exports['fdb-libs']:StartMinigame(crimeConfig.minigame.type, {
        duration = crimeConfig.minigame.duration,
        images = images,
        zones = crimeConfig.minigame.zones
    })
    
    TriggerServerEvent('illegal-system:server:finishNpcRobbery', result.success, result.tier, data.sessionToken)
end)
