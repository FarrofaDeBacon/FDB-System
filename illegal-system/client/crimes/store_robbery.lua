local isRobbingStore = false
local robbedPeds = {}
local currentRobbedPed = 0

-- Debug: recebe mensagens do servidor e mostra no F8
RegisterNetEvent("illegal-system:client:debugMsg", function(msg)
    print("[illegal-system] SERVER -> " .. msg)
end)

-- Injeta atributos no lojista assim que o fdb-shops spawna ele
AddEventHandler('fdb-shops:client:npcCreated', function(npc, shopData)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedFleeAttributes(npc, 0, false)

    -- Adiciona o Target para Assaltar o NPC (Apenas de dia!)
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'rob_store_npc_' .. shopData.name,
            icon = 'fa-solid fa-gun',
            label = 'Assaltar Lojista',
            distance = 3.0,
            canInteract = function()
                -- Só aparece de dia, o que faz sentido já que à noite o NPC nem existe!
                return true
            end,
            onSelect = function()
                currentRobbedPed = npc
                -- Usa o 'label' do shopData pois o illegal-system usa o nome completo (ex: "Valentine General Store")
                TriggerServerEvent('illegal-system:server:attemptStoreRobbery', shopData.label, 'threaten')
            end
        }
    })
end)
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

-- [REMOVIDO] allowDoorMinigame — código morto.
-- O gancho de entrada agora é via AddEventHandler("wasvendel_doorlock:lockpick") no server.


local function CleanupOrphanDogs()
    local dogModel = GetHashKey("A_C_DogCollie_01")
    if GetGamePool then
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) and GetEntityModel(ped) == dogModel and not IsPedAPlayer(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                DeleteEntity(ped)
            end
        end
    end
end

RegisterNetEvent('illegal-system:client:spawnDogRisk', function(storeName, barkDuration)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Spawna um cachorro perto do jogador (apenas visual e sonoro para assustar)
    local dogModel = GetHashKey("A_C_DogCollie_01")
    RequestModel(dogModel)
    
    local modelTimeout = GetGameTimer() + 5000
    while not HasModelLoaded(dogModel) do 
        Wait(10) 
        if GetGameTimer() > modelTimeout then
            print("[illegal-system] ERRO: modelo do cachorro nao carregou em 5s: " .. tostring(dogModel))
            return
        end
    end
    print("[illegal-system] Modelo do cachorro carregado com sucesso, criando ped...")
    
    -- Spawna o cachorro bem perto do jogador
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.5, 0.0)
    local dogPed = CreatePed(dogModel, offset.x, offset.y, coords.z, 0.0, true, false, false, false)
    SetEntityAsMissionEntity(dogPed, true, true)
    
    -- Registra a limpeza antecipadamente para evitar peds órfãos caso ocorra qualquer falha
    local duration = (barkDuration or 10) * 1000
    SetTimeout(duration, function()
        if DoesEntityExist(dogPed) then
            TaskWanderStandard(dogPed, 10.0, 10)
            Wait(5000)
            if DoesEntityExist(dogPed) then
                DeleteEntity(dogPed)
            end
        end
    end)

    -- Cachorro agora apenas late para alertar/assustar, não ataca
    TaskTurnPedToFaceEntity(dogPed, playerPed, -1)
    CreateThread(function()
        local endBark = GetGameTimer() + duration
        while GetGameTimer() < endBark and DoesEntityExist(dogPed) do
            pcall(function()
                PlayAmbientSpeech1(dogPed, "BARK", "SPEECH_PARAMS_FORCE_SHOUTED", 1)
            end)
            Wait(math.random(1500, 2500)) -- Late repetidamente a cada ~2 segundos
        end
    end)
end)

RegisterNetEvent('illegal-system:client:armedNpcRisk', function(storeName, outcome)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local npcModel = GetHashKey("A_M_M_BynRoughTravellers_01")
    RequestModel(npcModel)
    
    local npcTimeout = GetGameTimer() + 5000
    while not HasModelLoaded(npcModel) do 
        Wait(10) 
        if GetGameTimer() > npcTimeout then
            print("[illegal-system] ERRO: modelo do NPC armado nao carregou em 5s: " .. tostring(npcModel))
            return
        end
    end
    print("[illegal-system] Modelo do NPC carregado com sucesso, criando ped...")

    -- Tenta 5 metros atrás do jogador
    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -5.0, 0.0)
    
    -- Checa se tem alguma parede no caminho até esse ponto (Raio 0.5m)
    local rayHandle = StartShapeTestCapsule(coords.x, coords.y, coords.z + 1.0, spawnCoords.x, spawnCoords.y, spawnCoords.z + 1.0, 0.5, 511, playerPed, 7)
    local _, hit = GetShapeTestResult(rayHandle)
    
    if hit == 1 then
        -- Se bateu em algo, o espaço de trás é apertado. Joga 3 metros pra FRENTE do jogador (perto da porta)
        spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 3.0, 0.0)
    end

    -- Pega a altura correta do chão (Z) no ponto, se não achar usa a altura do jogador (coords.z)
    local foundGround, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 2.0, false)
    local finalZ = foundGround and groundZ or coords.z
    
    local armedPed = CreatePed(npcModel, spawnCoords.x, spawnCoords.y, finalZ, 0.0, true, false, false, false)
    SetEntityAsMissionEntity(armedPed, true, true)

    GiveWeaponToPed_2(armedPed, GetHashKey("WEAPON_REVOLVER_CATTLEMAN"), 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
    TaskCombatPed(armedPed, playerPed, 0, 16)

    Bridge.Notify("Um morador te flagrou! Cuidado!", "error")

    -- Limpeza: depois de um tempo, se o NPC ainda existir (você fugiu ou ele
    -- desistiu), ele volta a vagar normalmente, sem punir o jogador por isso.
    SetTimeout(30000, function()
        if DoesEntityExist(armedPed) and not IsEntityDead(armedPed) then
            TaskWanderStandard(armedPed, 10.0, 10)
        end
    end)
end)
local lastStoreState = {} -- Armazena "open" ou "closed"

-- Sincroniza estado se o wasvendel_doorlock for reiniciado e limpa entidades órfãs
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupOrphanDogs()
    elseif resourceName == 'wasvendel_doorlock' then
        Wait(1000) -- Aguarda o wasvendel terminar de carregar os locks
        for _, store in ipairs(Config.Stores) do
            lastStoreState[store.name] = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupOrphanDogs()
    end
end)

-- Loop para verificar a hora de fechar/abrir a loja e avisar o servidor
CreateThread(function()
    print("[illegal-system] CLIENT: Loop de horário iniciado! Stores: " .. #Config.Stores)
    
    while true do
        Wait(5000)
        local hour = GetClockHours()
        print("[illegal-system] CLIENT: Hora atual = " .. tostring(hour) .. " | Stores = " .. #Config.Stores)
        
        for _, store in ipairs(Config.Stores) do
            -- Verifica se estamos no horário de funcionamento
            local isBusinessHour = false
            if store.openHour < store.closeHour then
                isBusinessHour = (hour >= store.openHour and hour < store.closeHour)
            else
                -- Caso a loja abra de noite e feche de dia (ex: 22h às 6h)
                isBusinessHour = (hour >= store.openHour or hour < store.closeHour)
            end
            
            print("[illegal-system] CLIENT: " .. store.name .. " | open=" .. store.openHour .. " close=" .. store.closeHour .. " | isBusinessHour=" .. tostring(isBusinessHour) .. " | lastState=" .. tostring(lastStoreState[store.name]))
            
            if isBusinessHour then
                if lastStoreState[store.name] ~= "open" then
                    lastStoreState[store.name] = "open"
                    print("[illegal-system] CLIENT: Enviando autoUnlockDoor para " .. store.name)
                    TriggerServerEvent("illegal-system:server:autoUnlockDoor", store.name)
                end
            else
                if lastStoreState[store.name] ~= "closed" then
                    lastStoreState[store.name] = "closed"
                    print("[illegal-system] CLIENT: Enviando autoLockDoor para " .. store.name)
                    TriggerServerEvent("illegal-system:server:autoLockDoor", store.name)
                end
            end
        end
    end
end)
