local crimeId = 'store_robbery'
local activeBurglaries = {} -- Controle dos tokens de arrombamento (noite)

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
RegisterNetEvent('illegal-system:server:attemptStoreRobbery', function(storeName, method)
    local source = source
    local attempt = CrimeCore.AttemptCrime(source, crimeId)

    if not attempt.ok then
        TriggerClientEvent('illegal-system:client:storeRobberyFailed', source, attempt.reason)
        return
    end

    local crimeConfig = Config.Crimes[crimeId]
    local reactionRoll = math.random(1, 100)
    local reaction = 'comply'

    local complyChance = crimeConfig.reactions.comply
    local fightChance = complyChance + crimeConfig.reactions.fight

    if reactionRoll <= complyChance then
        reaction = 'comply'
    elseif reactionRoll <= fightChance then
        reaction = 'fight'
    else
        reaction = 'flee'
    end

    TriggerClientEvent('illegal-system:client:storeRobberyReaction', source, reaction, storeName)

    if reaction == 'comply' then
        SetTimeout(9000, function()
            local pool = Utils.GetRandomLootPool()
            local items = crimeConfig.loot[pool]
            local reward = items[math.random(#items)]
            
            CrimeCore.FinishCrime(source, crimeId, true, reward)
        end)
    else
        -- Fugiu ou lutou, crime finalizado sem loot (mas com heat se quisermos no futuro)
        -- Para evitar travar o jogador no cooldown sem loot, podemos não chamar FinishCrime ou chamar com success = false
        CrimeCore.FinishCrime(source, crimeId, false, nil)
    end
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
    local minDuration = (crimeConfig.minigame.duration * 1000) - 1000

    if timeElapsed < minDuration then
        print(string.format("[illegal-system] EXPLOIT DETECTADO: Jogador ID %s burlou o tempo do minigame de burglary.", source))
        activeBurglaries[source] = nil
        return
    end

    activeBurglaries[source] = nil

    if targetType == 'door' then
        Bridge.Notify(source, "Porta destrancada!", "success")
        -- Se houvesse um script de portas (doorlock), abriríamos a porta aqui.
        -- Como é um interior aberto, o minigame apenas serve de barreira de entrada RP.
        -- (Futuramente pode teleportar para dentro se for um interior fechado)
        
    elseif targetType == 'register' then
        local items = crimeConfig.burglaryLoot[tier]
        if not items then return end
        
        local reward = items[math.random(#items)]
        CrimeCore.FinishCrime(source, crimeId, true, reward)
    end
end)
