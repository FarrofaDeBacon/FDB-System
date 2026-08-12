local crimeId = 'store_robbery'
local activeBurglaries = {} -- Controle dos tokens de arrombamento (noite)
local activeRobberies = {} -- Controle dos tokens de roubo (dia)

local function GenerateToken()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local token = ""
    for i = 1, 16 do
        local rand = math.random(1, #charset)
        token = token .. charset:sub(rand, rand)
    end
    return token
end

-- ==========================================
-- 1. MÉTODOS DIURNOS (Assalto Estático)
-- ==========================================
RegisterNetEvent('illegal-system:server:attemptStoreRobbery', function(storeName)
    local source = source
    local attempt = CrimeCore.AttemptCrime(source, crimeId)

    if not attempt.ok then
        Bridge.Notify(source, "A poeira ainda não baixou nessa área.", "error")
        return
    end

    local sessionToken = GenerateToken()
    activeRobberies[source] = {
        token = sessionToken,
        startTime = os.time(),
        storeName = storeName
    }

    TriggerClientEvent('illegal-system:client:startStoreRobbery', source, storeName, sessionToken)
end)

RegisterNetEvent('illegal-system:server:finishStoreRobbery', function(storeName, sessionToken)
    local source = source
    local session = activeRobberies[source]
    
    if not session or session.token ~= sessionToken then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s tentou forçar o evento de store_robbery.", source))
        return
    end
    
    local elapsed = os.time() - session.startTime
    -- O client demora 8 segundos no progressBar
    if elapsed < 7 then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s burlou o tempo do assalto a loja.", source))
        activeRobberies[source] = nil
        return
    end

    activeRobberies[source] = nil

    local crimeConfig = Config.Crimes[crimeId]
    local pool = Utils.GetRandomLootPool()
    local items = crimeConfig.loot[pool]
    local reward = items[math.random(#items)]
    
    CrimeCore.FinishCrime(source, crimeId, true, reward)
end)

RegisterNetEvent('illegal-system:server:cancelStoreRobbery', function(storeName, sessionToken)
    local source = source
    activeRobberies[source] = nil
end)

-- ==========================================
-- 2. MÉTODOS NOTURNOS (Burglary)
-- ==========================================
RegisterNetEvent('illegal-system:server:attemptBurglary', function(storeName, targetType)
    local source = source
    local crimeConfig = Config.Crimes[crimeId]
    
    -- Checa item (lockpick)
    if not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        Bridge.Notify(source, "Você precisa de um " .. crimeConfig.requiredItem .. " para isso.", "error")
        return
    end
    
    local attempt = CrimeCore.AttemptCrime(source, crimeId)
    if not attempt.ok then
        Bridge.Notify(source, "A poeira ainda não baixou nessa área.", "error")
        return
    end

    local sessionToken = GenerateToken()
    activeBurglaries[source] = {
        token = sessionToken,
        startTime = os.time(),
        storeName = storeName,
        targetType = targetType -- 'door' ou 'register'
    }

    TriggerClientEvent('illegal-system:client:startBurglaryMinigame', source, storeName, targetType, sessionToken)
end)

RegisterNetEvent('illegal-system:server:finishBurglary', function(storeName, targetType, sessionToken, tier, timeElapsed)
    local source = source
    local session = activeBurglaries[source]
    
    if not session or session.token ~= sessionToken then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s tentou forçar o evento de burglary.", source))
        return
    end
    
    local crimeConfig = Config.Crimes[crimeId]
    local minExpected = 0.5 -- Minigame rápido

    if (timeElapsed/1000) < minExpected then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s burlou o tempo do minigame de burglary.", source))
        activeBurglaries[source] = nil
        return
    end

    activeBurglaries[source] = nil

    if targetType == 'door' then
        Bridge.Notify(source, "Porta destrancada!", "success")
    else
        local pool = Utils.GetRandomLootPool()
        local items = crimeConfig.burglaryLoot[pool]
        local reward = items[math.random(#items)]
        CrimeCore.FinishCrime(source, crimeId, true, reward)
    end
end)
