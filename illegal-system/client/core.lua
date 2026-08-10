--[[
    Client Etapa 2. Fica deliberadamente fino: toda regra de negócio está
    no servidor. Aqui só existe apresentação (target, animação, notificação).
]]

local function TryRobNearbyPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPed, closestDist = nil, 5.0

    -- varredura simples de peds próximos; suficiente pra Etapa 2.
    -- Etapa 4+ (roubo de casa) não usa isso, é interação com o mundo estático.
    local peds = GetGamePool('CPed')
    for _, ped in ipairs(peds) do
        if ped ~= playerPed and not IsPedAPlayer(ped) then
            local dist = #(playerCoords - GetEntityCoords(ped))
            if dist < closestDist then
                closestPed, closestDist = ped, dist
            end
        end
    end

    if not closestPed then
        return
    end

    -- animação/minigame local só como feedback visual — não decide nada
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    Wait(1500)
    ClearPedTasks(playerPed)

    TriggerServerEvent('illegal-system:server:attemptNpcRobbery')
end

RegisterCommand('roubar', function()
    TryRobNearbyPed()
end, false)

RegisterNetEvent('illegal-system:client:npcRobberyResult', function(result)
    -- espaço reservado pra UI/animação de resultado (sucesso/falha)
end)
