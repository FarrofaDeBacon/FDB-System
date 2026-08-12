local crimeId = 'store_robbery'
local burglaryCrimeId = 'store_burglary'
local storeRespawnTimes = {} -- Controle de cooldown global persistente das registradoras

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
-- 1. MÉTODOS DIURNOS (Assalto ao Lojista)
-- ==========================================
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
RegisterNetEvent('illegal-system:server:attemptBurglary', function(storeName, targetType)
    local source = source
    local crimeConfig = Config.Crimes[burglaryCrimeId]
    
    -- Só registradora agora (porta é pelo wasvendel_doorlock)
    if targetType ~= 'register' then return end

    -- Checa cooldown global da registradora
    if storeRespawnTimes[storeName] and os.time() < storeRespawnTimes[storeName] then
        Bridge.Notify(source, "A registradora já foi esvaziada recentemente.", "error")
        return
    end
    
    -- Checa item (lockpick)
    if not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        Bridge.Notify(source, "Você precisa de um " .. crimeConfig.requiredItem .. " para isso.", "error")
        return
    end
    
    local attempt = CrimeCore.AttemptCrime(source, burglaryCrimeId)
    if not attempt.ok then
        Bridge.Notify(source, "A poeira ainda não baixou nessa área.", "error")
        return
    end

    -- O jogador já passou no minigame do fdb-lockpick no client, então dá a recompensa
    local storeConfig = nil
    for _, s in ipairs(Config.Stores) do
        if s.name == storeName then storeConfig = s break end
    end
    
    if storeConfig and storeConfig.registerCash then
        local amount = math.random(storeConfig.registerCash.min, storeConfig.registerCash.max)
        Bridge.AddMoney(source, amount, 'store_robbery')
        
        -- Aplica cooldown global na registradora dessa loja específica
        local respawnConfig = Config.StoreRobberyRespawn
        local daysToRespawn = math.random(respawnConfig.minDays, respawnConfig.maxDays)
        local secondsToRespawn = daysToRespawn * (respawnConfig.minutesPerIngameDay * 60)
        storeRespawnTimes[storeName] = os.time() + secondsToRespawn
        
        CrimeCore.FinishCrime(source, burglaryCrimeId, true, "$" .. amount)
    end
end)
