local isRobbingStore = false
local robbedPeds = {}
local currentRobbedPed = 0

-- Injeta atributos no lojista assim que o fdb-shops spawna ele
AddEventHandler('fdb-shops:client:npcCreated', function(npc, shopData)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedFleeAttributes(npc, 0, false)
end)

-- Bloqueia a IA nativa retroativamente nos NPCs que já existem
CreateThread(function()
    Wait(2000) -- Espera o fdb-shops iniciar caso reiniciem juntos
    for _, store in ipairs(Config.Stores) do
        local handle, ped = FindFirstPed()
        local success
        repeat
            if #(GetEntityCoords(ped) - store.coords) <= store.radius then
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, false)
            end
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end
end)
local function GetStoreZone(pedCoords)
    for _, store in ipairs(Config.Stores) do
        local dist = #(pedCoords - store.coords)
        if dist <= store.radius then
            return store
        end
    end
    return nil
end

RegisterNetEvent('illegal-system:client:startStoreRobbery', function(storeName, sessionToken, reaction)
    local ped = currentRobbedPed -- o NPC que foi mirado, salvo no passo 2

    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, false) -- Descongela o NPC (o fdb-shops spawna eles congelados)

    if reaction == 'comply' then
        TaskHandsUp(ped, 8000, PlayerPedId(), -1, true)
        Bridge.Notify("Calma, calma! Leve tudo!", "success")

        if lib.progressBar({
            duration = 8000, label = "Levando o dinheiro...",
            disable = { car = true, move = true, combat = false }, canCancel = true
        }) then
            TriggerServerEvent('illegal-system:server:finishStoreRobbery', storeName, sessionToken)
        else
            TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)
        end
        isRobbingStore = false

    elseif reaction == 'fight' then
        Bridge.Notify("Você não vai levar nada meu!", "error")
        -- Se ele vai atirar no jogador, ele precisa ser mortal (fdb-shops spawna invencivel)
        SetEntityCanBeDamaged(ped, true)
        SetEntityInvincible(ped, false)
        
        GiveWeaponToPed_2(ped, 0x1D073A89, 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        SetPedCombatMovement(ped, 0) -- 0 = Stationary (Fica parado atirando)
        TaskCombatPed(ped, PlayerPedId(), 0, 16)
        isRobbingStore = false
        TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)

    elseif reaction == 'flee' then
        Bridge.Notify("Por favor, não me machuque!", "error")
        -- Se ele vai se acovardar, ele precisa ser mortal (fdb-shops spawna invencivel)
        SetEntityCanBeDamaged(ped, true)
        SetEntityInvincible(ped, false)
        
        -- Como lojistas ficam presos atrás de um balcão apertado, qualquer corrida (Flee)
        -- faz eles bugarem empurrando a madeira. A melhor reação para isso é TaskCower
        -- (se encolher de medo no chão do balcão).
        TaskCower(ped, -1)
        isRobbingStore = false
        TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)
    end

    SetTimeout(30000, function()
        if DoesEntityExist(ped) then
            SetBlockingOfNonTemporaryEvents(ped, false)
            ClearPedTasks(ped)
        end
        robbedPeds[ped] = nil
    end)
end)

RegisterNetEvent('illegal-system:client:storeRobberyFailed', function(reason)
    if reason == 'cooldown' then
        Bridge.Notify("Sistema", "Esta área já foi roubada recentemente.", "error")
    end
    isRobbingStore = false
    currentRobbedPed = 0
end)

CreateThread(function()

    
    -- 2. Método Noturno: Burglary
    for _, store in ipairs(Config.Stores) do
        -- Caixa Registradora
        exports.ox_target:addBoxZone({
            coords = store.registerCoords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 0,
            debug = true,
            options = {
                {
                    name = 'burglary_register_'..store.name,
                    icon = 'fa-solid fa-cash-register',
                    label = 'Arrombar Registradora',
                    canInteract = function()
                        local hour = GetClockHours()
                        if hour < store.openHour or hour >= store.closeHour then
                            return true
                        end
                        return false
                    end,
                    onSelect = function()
                        -- Verifica se o fdb-lockpick está rodando
                        if GetResourceState('fdb-lockpick') ~= 'started' then
                            Bridge.Notify("Você precisa de ferramentas para isso.", "error")
                            return
                        end
                        -- Inicia o processo no servidor (que vai rolar os riscos e retornar allowRegisterMinigame)
                        TriggerServerEvent('illegal-system:server:startRegisterBurglary', store.name)
                    end
                }
            }
        })
    end
end)

RegisterNetEvent('illegal-system:client:allowRegisterMinigame', function(storeName, sessionToken)
    local ped = PlayerPedId()

    local storeConfig = nil
    for _, s in ipairs(Config.Stores) do
        if s.name == storeName then storeConfig = s break end
    end

    if storeConfig and storeConfig.registerHeading then
        SetEntityHeading(ped, storeConfig.registerHeading)
    end

    TaskStartScenarioInPlace(ped, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, false, false, false)
    TriggerEvent('fdb-lockpick:client:openLockpick', function(success)
        ClearPedTasks(ped)
        if success then
            TriggerServerEvent('illegal-system:server:attemptBurglary', storeName, 'register', sessionToken)
        else
            Bridge.Notify("Você falhou no arrombamento!", "error")
        end
    end)
end)

RegisterNetEvent('illegal-system:client:allowDoorMinigame', function(storeName)
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, false, false, false)
    
    TriggerEvent('fdb-lockpick:client:openLockpick', function(success)
        ClearPedTasks(ped)
        if success then
            TriggerServerEvent('illegal-system:server:attemptDoorBurglary', storeName)
        else
            Bridge.Notify("Você falhou no arrombamento!", "error")
        end
    end)
end)

RegisterNetEvent('illegal-system:client:spawnDogRisk', function(storeName, barkDuration)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Spawna um cachorro perto do jogador (apenas visual e sonoro para assustar)
    local dogModel = GetHashKey("A_C_DogCollie_01")
    RequestModel(dogModel)
    while not HasModelLoaded(dogModel) do Wait(10) end
    
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, math.random(-5.0, 5.0), math.random(-5.0, 5.0), 0.0)
    local dogPed = CreatePed(dogModel, offset.x, offset.y, coords.z, 0.0, true, false, false, false)
    SetEntityAsMissionEntity(dogPed, true, true)
    
    -- Faz o cachorro latir
    PlayAmbientSpeech1(dogPed, "BARK", "SPEECH_PARAMS_FORCE_SHOUTED")
    TaskTurnPedToFaceEntity(dogPed, playerPed, -1)
    
    -- Depois do barkDuration, o cachorro foge e é deletado
    SetTimeout(barkDuration * 1000, function()
        if DoesEntityExist(dogPed) then
            TaskWanderStandard(dogPed, 10.0, 10)
            Wait(5000)
            DeleteEntity(dogPed)
        end
    end)
end)

RegisterNetEvent('illegal-system:client:armedNpcRisk', function(storeName, outcome)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Spawna NPC Armado agressivo
    local npcModel = GetHashKey("A_M_M_BynRoughTravellers_01")
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do Wait(10) end
    
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -10.0, 0.0)
    local armedPed = CreatePed(npcModel, offset.x, offset.y, coords.z, 0.0, true, false, false, false)
    SetEntityAsMissionEntity(armedPed, true, true)
    
    GiveWeaponToPed_2(armedPed, GetHashKey("WEAPON_REVOLVER_CATTLEMAN"), 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
    TaskCombatPed(armedPed, playerPed, 0, 16)
    
    Bridge.Notify("Um morador te flagrou! Cuidado!", "error")
    
    -- Lógica simples: Se o jogador não matar o NPC em X segundos, o 'outcome' acontece
    SetTimeout(10000, function()
        if DoesEntityExist(armedPed) and not IsEntityDead(armedPed) and not IsEntityDead(playerPed) then
            -- O NPC pegou o jogador!
            if outcome == 'knockout' then
                Bridge.Notify("Você foi nocauteado pelo morador!", "error")
                SetPedToRagdoll(playerPed, 10000, 10000, 0, false, false, false)
            elseif outcome == 'jail' then
                -- Hook preparado para futura integração com polícia
                Bridge.Notify("Você foi pego e seria mandado para a prisão (futuro).", "error")
            end
            
            -- NPC foge após nocautear
            TaskWanderStandard(armedPed, 10.0, 10)
            Wait(10000)
            if DoesEntityExist(armedPed) then DeleteEntity(armedPed) end
        end
    end)
end)

-- Loop para verificar a hora de fechar a loja e avisar o servidor
CreateThread(function()
    local lastLockedDay = {}
    while true do
        Wait(5000)
        local hour = GetClockHours()
        local day = GetClockDayOfMonth()
        
        for _, store in ipairs(Config.Stores) do
            if hour == store.closeHour then
                if lastLockedDay[store.name] ~= day then
                    lastLockedDay[store.name] = day
                    TriggerServerEvent("illegal-system:server:autoLockDoor", store.name)
                end
            end
        end
    end
end)
