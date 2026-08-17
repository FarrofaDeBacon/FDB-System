local crimeId = 'store_robbery'
local storeRespawnTimes = {} -- Controle de cooldown global das registradoras (Fase D vai persistir)
local storeRobberyLocks = {} -- Armazena os lockIds para cada store
local activeRiskSessions = {} -- [source] = { storeName, sessionId, barkCount, tickCount, active }

-- Helper: busca o Config.Stores entry pelo nome
local function GetStoreConfig(storeName)
    for _, s in ipairs(Config.Stores) do
        if s.name == storeName then return s end
    end
    return nil
end

-- Inicializa os locks buscando no wasvendel_doorlock
CreateThread(function()
    print("[illegal-system] SERVER: Aguardando inicialização do wasvendel_doorlock...")
    local locks = nil
    local retries = 0
    while not locks and retries < 20 do
        Wait(2000)
        locks = exports.wasvendel_doorlock:GetLocks()
        retries = retries + 1
    end

    if not locks then
        print("[illegal-system] SERVER: ERRO CRÍTICO! wasvendel_doorlock não carregou os locks a tempo.")
        return
    end
    
    local lockCount = 0
    for id, lock in pairs(locks) do
        lockCount = lockCount + 1
        if lock.prompt and lock.prompt.x then
            print("[illegal-system] SERVER: Lock ID=" .. tostring(id) .. " | name=" .. tostring(lock.name) .. " | prompt=" .. tostring(lock.prompt.x) .. ", " .. tostring(lock.prompt.y) .. ", " .. tostring(lock.prompt.z))
        else
            print("[illegal-system] SERVER: Lock ID=" .. tostring(id) .. " | name=" .. tostring(lock.name) .. " | SEM PROMPT!")
        end
    end
    print("[illegal-system] SERVER: Total de locks encontrados: " .. lockCount)
    
    for _, store in ipairs(Config.Stores) do
        local bestLockId = nil
        local minStoreDist = 5.0
        print("[illegal-system] SERVER: Procurando lock para loja '" .. store.name .. "' perto de doorCoords=" .. tostring(store.doorCoords))
        for id, lock in pairs(locks) do
            if lock.prompt and lock.prompt.x then
                local lockCoords = vec3(lock.prompt.x, lock.prompt.y, lock.prompt.z)
                local dist = #(store.doorCoords - lockCoords)
                print("[illegal-system] SERVER:   -> Lock ID=" .. tostring(id) .. " dist=" .. string.format("%.2f", dist) .. "m")
                if dist < minStoreDist then
                    minStoreDist = dist
                    bestLockId = id
                end
            end
        end
        if bestLockId then
            storeRobberyLocks[store.name] = bestLockId
            print("[illegal-system] SERVER: ✓ Loja '" .. store.name .. "' pareada com Lock ID=" .. tostring(bestLockId) .. " (dist=" .. string.format("%.2f", minStoreDist) .. "m)")
        else
            print("[illegal-system] SERVER: ✗ Loja '" .. store.name .. "' NAO encontrou nenhum lock dentro de 5m!")
        end
    end
    print("[illegal-system] SERVER: Inicialização completa!")
end)

-- Recebe o aviso do cliente para trancar a porta no fim do expediente
RegisterNetEvent("illegal-system:server:autoLockDoor", function(storeName)
    local src = source
    local store = GetStoreConfig(storeName)
    if not store then return end
    
    local lockId = storeRobberyLocks[store.name]
    if lockId then
        exports.wasvendel_doorlock:SetLockState(lockId, true)
        print("[illegal-system] Loja '" .. storeName .. "' trancada (lockId=" .. tostring(lockId) .. ")")
    end
end)

-- Recebe o aviso do cliente para destrancar a porta no início do expediente
RegisterNetEvent("illegal-system:server:autoUnlockDoor", function(storeName)
    local src = source
    local store = GetStoreConfig(storeName)
    if not store then return end
    
    local lockId = storeRobberyLocks[store.name]
    if lockId then
        exports.wasvendel_doorlock:SetLockState(lockId, false)
        print("[illegal-system] Loja '" .. storeName .. "' destrancada (lockId=" .. tostring(lockId) .. ")")
    end
end)

-- ==========================================
-- SISTEMA DE RISCO — Sessão tick-based
-- ==========================================

local function EndRiskSession(src, reason)
    local session = activeRiskSessions[src]
    if not session then return end
    
    session.active = false
    activeRiskSessions[src] = nil
    print("[illegal-system] RISCO: Sessão encerrada para jogador " .. tostring(src) .. " | Loja: " .. session.storeName .. " | Motivo: " .. reason)
end

local function AlertPolice(storeName, storeConfig, burglaryConfig)
    if not burglaryConfig.witness.alertsPolice then return end
    
    local jitter = burglaryConfig.witness.coordsJitter
    local alertCoords = storeConfig.coords + vec3(math.random(-jitter, jitter), math.random(-jitter, jitter), 0)
    
    local players = GetPlayers()
    for _, pid in ipairs(players) do
        local pSrc = tonumber(pid)
        local pData = Bridge.GetPlayer(pSrc)
        if pData and pData.job and pData.job.type == 'leo' and pData.job.onduty then
            local pCoords = GetEntityCoords(GetPlayerPed(pSrc))
            if #(pCoords - storeConfig.coords) <= burglaryConfig.witness.alertRadius then
                if burglaryConfig.witness.showMapBlip then
                    TriggerClientEvent('fdb-lawman:client:lawmanAlert', pSrc, alertCoords, burglaryConfig.witness.alertText)
                else
                    Bridge.Notify(pSrc, burglaryConfig.witness.alertText, "error")
                end
            end
        end
    end
end

local function StartRiskSession(src, storeName)
    -- Não permite sessão duplicada
    if activeRiskSessions[src] then
        EndRiskSession(src, "nova sessão substituindo anterior")
    end
    
    local storeConfig = GetStoreConfig(storeName)
    if not storeConfig then return end
    
    local crimeConfig = Config.Crimes['store_robbery']
    local burglaryConfig = crimeConfig.burglary
    if not burglaryConfig or not burglaryConfig.enabled then return end
    
    local sessionId = tostring(src) .. "_" .. tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
    
    activeRiskSessions[src] = {
        storeName = storeName,
        sessionId = sessionId,
        barkCount = 0,
        tickCount = 0,
        active = true,
    }
    
    print("[illegal-system] RISCO: Sessão iniciada para jogador " .. tostring(src) .. " | Loja: " .. storeName .. " | Session: " .. sessionId)
    
    -- Aviso de entrada
    if burglaryConfig.warning and burglaryConfig.warning.enabled then
        Bridge.Notify(src, burglaryConfig.warning.message, "info")
    end
    
    -- Testemunha (separada e independente do loop de cachorro/NPC)
    if burglaryConfig.enabled and Utils.RollChance(crimeConfig.witnessChance) then
        Bridge.Notify(src, "Alguém percebeu o barulho e vai avisar a polícia!", "error")
        -- Hook preparado pra futura integração real de polícia (Etapa 7) — por
        -- enquanto é só aviso, sem dispatch de verdade ainda.
    end
    
    -- Loop de risco em thread própria
    if burglaryConfig.dog and burglaryConfig.dog.enabled then
        CreateThread(function()
            local mySessionId = sessionId
            
            while true do
                Wait(burglaryConfig.dog.checkInterval)
                
                -- Verifica se a sessão ainda está ativa e é a mesma
                local session = activeRiskSessions[src]
                if not session or not session.active or session.sessionId ~= mySessionId then
                    print("[illegal-system] RISCO: Thread de risco encerrada (sessão inativa) | Session: " .. mySessionId)
                    return
                end
                
                -- Verifica se o jogador ainda está na área da loja
                local ped = GetPlayerPed(src)
                if ped == 0 then
                    EndRiskSession(src, "jogador sem ped (desconectado?)")
                    return
                end
                
                local playerCoords = GetEntityCoords(ped)
                local dist = #(playerCoords - storeConfig.coords)
                if dist > storeConfig.radius then
                    EndRiskSession(src, "jogador saiu da área (" .. string.format("%.1f", dist) .. "m)")
                    return
                end
                
                session.tickCount = session.tickCount + 1
                
                -- Calcula chance crescente
                local chance = math.min(
                    burglaryConfig.dog.baseChance + (burglaryConfig.dog.chanceIncreasePerTick * (session.tickCount - 1)),
                    burglaryConfig.dog.maxChance
                )
                
                local roll = math.random(1, 100)
                print("[illegal-system] RISCO: Tick #" .. session.tickCount .. " | Chance: " .. chance .. "% | Roll: " .. roll .. " | Session: " .. mySessionId)
                
                if roll <= chance then
                    -- Cachorro latiu!
                    session.barkCount = session.barkCount + 1
                    print("[illegal-system] RISCO: LATIDO #" .. session.barkCount .. " | Session: " .. mySessionId)
                    
                    if burglaryConfig.dog.notifyOnBark then
                        Bridge.Notify(src, burglaryConfig.dog.barkMessage, "warning")
                    end
                    
                    -- Spawna cachorro no client
                    TriggerClientEvent('illegal-system:client:spawnDogRisk', src, storeName, burglaryConfig.dog.barkDuration)
                    
                    -- Witness: rola se requiresDogBark
                    if burglaryConfig.witness and burglaryConfig.witness.enabled and burglaryConfig.witness.requiresDogBark then
                        if math.random(1, 100) <= burglaryConfig.witness.chance then
                            print("[illegal-system] RISCO: TESTEMUNHA gerada! Alertando polícia... | Session: " .. mySessionId)
                            AlertPolice(storeName, storeConfig, burglaryConfig)
                        end
                    end
                    
                    -- ArmedNpc: checa se bateu o threshold de latidos
                    if burglaryConfig.armedNpc and burglaryConfig.armedNpc.enabled and burglaryConfig.armedNpc.requiresDogBark then
                        if session.barkCount >= burglaryConfig.armedNpc.barksToTrigger then
                            print("[illegal-system] RISCO: NPC ARMADO disparado (latidos >= " .. burglaryConfig.armedNpc.barksToTrigger .. ") | Session: " .. mySessionId)
                            local outcome = 'knockout'
                            if burglaryConfig.caughtOutcome and burglaryConfig.caughtOutcome.jail and burglaryConfig.caughtOutcome.jail.enabled then
                                if math.random(1, 100) > burglaryConfig.caughtOutcome.knockoutChance then
                                    outcome = 'jail'
                                end
                            end
                            TriggerClientEvent('illegal-system:client:armedNpcRisk', src, storeName, outcome)
                            EndRiskSession(src, "NPC armado disparado")
                            return
                        end
                    end
                end
                
                -- Witness: rola independente do cachorro se requiresDogBark = false
                if burglaryConfig.witness and burglaryConfig.witness.enabled and not burglaryConfig.witness.requiresDogBark then
                    if math.random(1, 100) <= burglaryConfig.witness.chance then
                        print("[illegal-system] RISCO: TESTEMUNHA (independente) gerada! | Session: " .. mySessionId)
                        AlertPolice(storeName, storeConfig, burglaryConfig)
                    end
                end
                
                -- ArmedNpc: rola independente do cachorro se requiresDogBark = false
                if burglaryConfig.armedNpc and burglaryConfig.armedNpc.enabled and not burglaryConfig.armedNpc.requiresDogBark then
                    if math.random(1, 100) <= burglaryConfig.armedNpc.standaloneChance then
                        print("[illegal-system] RISCO: NPC ARMADO (independente) disparado! | Session: " .. mySessionId)
                        local outcome = 'knockout'
                        if burglaryConfig.caughtOutcome and burglaryConfig.caughtOutcome.jail and burglaryConfig.caughtOutcome.jail.enabled then
                            if math.random(1, 100) > burglaryConfig.caughtOutcome.knockoutChance then
                                outcome = 'jail'
                            end
                        end
                        TriggerClientEvent('illegal-system:client:armedNpcRisk', src, storeName, outcome)
                        EndRiskSession(src, "NPC armado independente disparado")
                        return
                    end
                end
            end
        end)
    end
end

-- Limpeza de sessão quando jogador desconecta
AddEventHandler('playerDropped', function()
    local src = source
    if activeRiskSessions[src] then
        EndRiskSession(src, "playerDropped")
    end
end)

-- ==========================================
-- Gancho: wasvendel_doorlock:lockpick → início de sessão de risco
-- ==========================================

-- Quando o wasvendel_doorlock confirma um lockpick bem-sucedido,
-- verificamos se a porta pertence a uma loja monitorada e iniciamos a sessão de risco.
-- Não precisa checar horário: se a porta estava trancada, é porque o autoLockDoor
-- já determinou que era noite. O gate de horário está implícito.
RegisterNetEvent("wasvendel_doorlock:lockpick", function(lockId)
    local src = source
    lockId = tonumber(lockId)
    if not lockId then return end

    -- Reverse-lookup: lockId -> storeName
    local matchedStore = nil
    for storeName, storedLockId in pairs(storeRobberyLocks) do
        if storedLockId == lockId then
            matchedStore = storeName
            break
        end
    end

    if not matchedStore then return end -- Não é porta de loja monitorada

    -- Anti-exploit: checagem de distância contra a coordenada REAL do lock no wasvendel.
    -- Usa GetLocks()[lockId].prompt como fonte de verdade, store.doorCoords é fallback.
    local storeConfig = GetStoreConfig(matchedStore)
    local checkCoords = nil
    local locks = exports.wasvendel_doorlock:GetLocks()
    if locks and locks[lockId] and locks[lockId].prompt and locks[lockId].prompt.x then
        checkCoords = vec3(locks[lockId].prompt.x, locks[lockId].prompt.y, locks[lockId].prompt.z)
    elseif storeConfig then
        -- Fallback: store.doorCoords (premissa: pode não ser a coordenada exata, verificar se necessário)
        checkCoords = storeConfig.doorCoords
    end

    if checkCoords then
        local ped = GetPlayerPed(src)
        if ped ~= 0 then
            local playerCoords = GetEntityCoords(ped)
            local dist = #(playerCoords - checkCoords)
            if dist > 10.0 then
                print("[illegal-system] ANTI-EXPLOIT: Jogador " .. tostring(src) .. " disparou lockpick para '" .. matchedStore .. "' mas está a " .. string.format("%.1f", dist) .. "m da porta. Ignorando.")
                return
            end
        end
    end

    print("[illegal-system] Porta de loja arrombada via lockpick! Loja: " .. matchedStore .. " | Jogador: " .. tostring(src))
    StartRiskSession(src, matchedStore)
end)

-- ==========================================
-- 1. MÉTODOS DIURNOS (Assalto ao Lojista)
-- ==========================================

local function GenerateToken()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local token = ""
    for i = 1, 16 do
        local rand = math.random(1, #charset)
        token = token .. charset:sub(rand, rand)
    end
    return token
end

local activeStoreRobberies = {} -- Controle dos tokens de assalto (dia)

RegisterNetEvent('illegal-system:server:attemptStoreRobbery', function(storeName, method)
    local source = source
    local attempt = CrimeCore.AttemptCrime(source, crimeId)

    if not attempt.ok then
        TriggerClientEvent('illegal-system:client:storeRobberyFailed', source, attempt.reason)
        return
    end

    local crimeConfig = Config.Crimes[crimeId]
    local reactionRoll = math.random(1, 100)
    local complyChance = crimeConfig.reactions.comply
    local fightChance = complyChance + crimeConfig.reactions.fight
    local reaction = reactionRoll <= complyChance and 'comply'
        or reactionRoll <= fightChance and 'fight'
        or 'flee'

    local sessionToken = GenerateToken()
    activeStoreRobberies[source] = {
        token = sessionToken,
        startTime = os.time(),
        storeName = storeName
    }

    TriggerClientEvent('illegal-system:client:startStoreRobbery', source, storeName, sessionToken, reaction)
end)

RegisterNetEvent('illegal-system:server:finishStoreRobbery', function(storeName, sessionToken)
    local source = source
    local session = activeStoreRobberies[source]

    if not session or session.token ~= sessionToken then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s tentou forçar o evento de assalto diurno.", source))
        return
    end

    activeStoreRobberies[source] = nil

    local crimeConfig = Config.Crimes[crimeId]
    local pool = Utils.GetRandomLootPool()
    local items = crimeConfig.loot[pool]
    local reward = items[math.random(#items)]
    
    CrimeCore.FinishCrime(source, crimeId, true, reward)
end)

RegisterNetEvent('illegal-system:server:cancelStoreRobbery', function(storeName, sessionToken)
    local source = source
    local session = activeStoreRobberies[source]

    if session and session.token == sessionToken then
        activeStoreRobberies[source] = nil
        CrimeCore.FinishCrime(source, crimeId, false, nil)
    end
end)

-- ==========================================
-- 2. MÉTODOS NOTURNOS (Burglary - Registradora)
-- O fdb-lockpick cuida do minigame no client.
-- A porta é gerenciada pelo wasvendel_doorlock.
-- ==========================================
local activeBurglaries = {} -- Controle dos tokens de assalto noturno (registradora)

RegisterNetEvent('illegal-system:server:startRegisterBurglary', function(storeName)
    local source = source
    local crimeConfig = Config.Crimes['store_robbery']
    
    -- Checa cooldown global da registradora (Persistente)
    if Config.StoreRobberyRespawn.mode == 'restart' then
        if storeRespawnTimes[storeName] then
            Bridge.Notify(source, "A registradora já foi esvaziada recentemente.", "error")
            return
        end
    else
        local row = MySQL.single.await('SELECT UNIX_TIMESTAMP(next_available_at) as next_time FROM robbed_stores WHERE store_name = ?', { storeName })
        if row and os.time() < row.next_time then
            Bridge.Notify(source, "A registradora já foi esvaziada recentemente.", "error")
            return
        end
    end
    
    -- Checa item (lockpick)
    if not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        Bridge.Notify(source, "Você precisa de um " .. crimeConfig.requiredItem .. " para isso.", "error")
        return
    end

    -- Permite que o minigame inicie no client
    local sessionToken = GenerateToken()
    activeBurglaries[source] = {
        token = sessionToken,
        storeName = storeName
    }
    TriggerClientEvent('illegal-system:client:allowRegisterMinigame', source, storeName, sessionToken)
end)

RegisterNetEvent('illegal-system:server:attemptBurglary', function(storeName, targetType, sessionToken)
    local source = source
    if targetType ~= 'register' then return end

    local session = activeBurglaries[source]

    -- Verifica token da sessão e se a loja bate
    if not session or session.token ~= sessionToken or session.storeName ~= storeName then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s tentou forçar o evento de arrombamento noturno ou manipular a loja.", source))
        return
    end
    
    -- Invalida o token
    activeBurglaries[source] = nil

    local crimeConfig = Config.Crimes['store_robbery']
    
    -- Re-checa o item para segurança extra
    if not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        Bridge.Notify(source, "Você precisa de um " .. crimeConfig.requiredItem .. " para isso.", "error")
        return
    end

    -- Re-checa cooldown global da registradora (para segurança)
    if Config.StoreRobberyRespawn.mode == 'restart' then
        if storeRespawnTimes[storeName] then
            Bridge.Notify(source, "A registradora já foi esvaziada recentemente.", "error")
            return
        end
    else
        local row = MySQL.single.await('SELECT UNIX_TIMESTAMP(next_available_at) as next_time FROM robbed_stores WHERE store_name = ?', { storeName })
        if row and os.time() < row.next_time then
            Bridge.Notify(source, "A registradora já foi esvaziada recentemente.", "error")
            return
        end
    end

    local storeConfig = GetStoreConfig(storeName)
    
    if storeConfig and storeConfig.registerCash then
        local amount = math.random(storeConfig.registerCash.min, storeConfig.registerCash.max)
        Bridge.AddMoney(source, amount, 'store_robbery')
        
        -- Loga o crime com recompensa em dinheiro
        exports['illegal-system']:LogCrimeEvent(source, 'store_robbery', true, 'cash', tostring(amount), false, false)
        
        -- Aplica cooldown global na registradora dessa loja específica
        if Config.StoreRobberyRespawn.mode == 'restart' then
            storeRespawnTimes[storeName] = true
        else
            local respawnConfig = Config.StoreRobberyRespawn
            local daysToRespawn = math.random(respawnConfig.minDays, respawnConfig.maxDays)
            local secondsToRespawn = daysToRespawn * (respawnConfig.minutesPerIngameDay * 60)
            local nextAvailable = os.time() + secondsToRespawn
            MySQL.insert.await([[
                INSERT INTO robbed_stores (store_name, last_robbed_at, next_available_at)
                VALUES (?, NOW(), FROM_UNIXTIME(?))
                ON DUPLICATE KEY UPDATE last_robbed_at = NOW(), next_available_at = FROM_UNIXTIME(?)
            ]], { storeName, nextAvailable, nextAvailable })
        end
    end
    
    -- Encerra a sessão de risco (jogador concluiu o roubo)
    EndRiskSession(source, "roubo concluído")
end)
