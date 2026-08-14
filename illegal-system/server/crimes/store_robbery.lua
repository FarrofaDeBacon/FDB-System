local crimeId = 'store_robbery'
local storeRespawnTimes = {} -- Controle de cooldown global persistente das registradoras
local storeRobberyLocks = {} -- Armazena os lockIds para cada store
local lastLockedDay = {} -- Para garantir que não tranque várias vezes no mesmo dia
local lastUnlockedDay = {} -- Para garantir que não destranque várias vezes no mesmo dia

-- Inicializa os locks buscando no wasvendel_doorlock
CreateThread(function()
    Wait(2000) -- Espera recursos iniciarem
    local locks = exports.wasvendel_doorlock:GetLocks()
    if locks then
        for _, store in ipairs(Config.Stores) do
            local bestLockId = nil
            local minStoreDist = 5.0 -- Tolerância de 5 metros
            for id, lock in pairs(locks) do
                if lock.prompt and lock.prompt.x then
                    local lockCoords = vec3(lock.prompt.x, lock.prompt.y, lock.prompt.z)
                    local dist = #(store.doorCoords - lockCoords)
                    if dist < minStoreDist then
                        minStoreDist = dist
                        bestLockId = id
                    end
                end
            end
            if bestLockId then
                storeRobberyLocks[store.name] = bestLockId
            end
        end
    end
end)

-- Recebe o aviso do cliente para trancar a porta no fim do expediente
RegisterNetEvent("illegal-system:server:autoLockDoor", function(storeName)
    local day = os.date("%d") -- Usamos o dia real no servidor para evitar re-lock spam
    local store = nil
    for _, s in ipairs(Config.Stores) do
        if s.name == storeName then store = s break end
    end
    
    if store then
        if lastLockedDay[store.name] ~= day then
            local lockId = storeRobberyLocks[store.name]
            if lockId then
                exports.wasvendel_doorlock:SetLockState(lockId, true)
                lastLockedDay[store.name] = day
            end
        end
    end
end)

-- Recebe o aviso do cliente para destrancar a porta no início do expediente
RegisterNetEvent("illegal-system:server:autoUnlockDoor", function(storeName)
    local day = os.date("%d")
    local store = nil
    for _, s in ipairs(Config.Stores) do
        if s.name == storeName then store = s break end
    end
    
    if store then
        if lastUnlockedDay[store.name] ~= day then
            local lockId = storeRobberyLocks[store.name]
            if lockId then
                exports.wasvendel_doorlock:SetLockState(lockId, false)
                lastUnlockedDay[store.name] = day
            end
        end
    end
end)

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
local activeBurglaries = {} -- Controle dos tokens de assalto noturno (registradora)

RegisterNetEvent('illegal-system:server:startRegisterBurglary', function(storeName)
    local source = source
    local crimeConfig = Config.Crimes['store_robbery']
    local burglaryConfig = crimeConfig.burglary
    
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

    -- Permite que o minigame inicie no client
    local sessionToken = GenerateToken()
    activeBurglaries[source] = {
        token = sessionToken,
        storeName = storeName
    }
    TriggerClientEvent('illegal-system:client:allowRegisterMinigame', source, storeName, sessionToken)
    
    -- Rolagens de risco (Cachorro)
    if burglaryConfig.enabled and burglaryConfig.dog.enabled then
        if math.random(1, 100) <= burglaryConfig.dog.chance then
            -- Avisa o client para spawnar o cachorro e tocar o som
            TriggerClientEvent('illegal-system:client:spawnDogRisk', source, storeName, burglaryConfig.dog.barkDuration)
            
            -- Se latiu, rola testemunha (LEO)
            if burglaryConfig.witness.enabled and math.random(1, 100) <= burglaryConfig.witness.chanceAfterDog then
                local storeConfig = nil
                for _, s in ipairs(Config.Stores) do
                    if s.name == storeName then storeConfig = s break end
                end
                
                if storeConfig then
                    local jitter = burglaryConfig.witness.coordsJitter
                    local alertCoords = storeConfig.coords + vec3(math.random(-jitter, jitter), math.random(-jitter, jitter), 0)
                    
                    local players = GetPlayers()
                    for _, pid in ipairs(players) do
                        local pSrc = tonumber(pid)
                        -- No fdb-bridge as funções seriam HasJobType / IsOnDuty, ou usar a Bridge local
                        -- O CrimeCore já mapeia jobs e duty? A interface diz GetPlayer(source).job.type
                        -- Usaremos a abstração Bridge da Etapa 1
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
            end
            
            -- NPC Armado (se não tem LEO onduty)
            if burglaryConfig.armedNpc.enabled then
                local hasLeo = false
                local players = GetPlayers()
                for _, pid in ipairs(players) do
                    local pData = Bridge.GetPlayer(tonumber(pid))
                    if pData and pData.job and pData.job.type == 'leo' and pData.job.onduty then
                        hasLeo = true
                        break
                    end
                end
                
                if (not burglaryConfig.armedNpc.onlyIfNoCopsOnline) or (not hasLeo) then
                    local delay = math.random(burglaryConfig.armedNpc.delayAfterDog.min, burglaryConfig.armedNpc.delayAfterDog.max)
                    SetTimeout(delay * 1000, function()
                        -- Rola a chance do NPC pegar o jogador
                        if math.random(1, 100) <= burglaryConfig.armedNpc.catchChance then
                            local outcome = 'knockout'
                            if burglaryConfig.caughtOutcome.jail.enabled and math.random(1, 100) <= (100 - burglaryConfig.caughtOutcome.knockoutChance) then
                                outcome = 'jail'
                            end
                            TriggerClientEvent('illegal-system:client:armedNpcRisk', source, storeName, outcome)
                        end
                    end)
                end
            end
        end
    end
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
    if storeRespawnTimes[storeName] and os.time() < storeRespawnTimes[storeName] then
        Bridge.Notify(source, "A registradora já foi esvaziada recentemente.", "error")
        return
    end

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
        
        -- Sem chamadas ao CrimeCore para arrombamento, cooldown agora é 100% independente por loja
    end
end)

RegisterNetEvent('illegal-system:server:startDoorBurglary', function(storeName)
    local source = source
    local crimeConfig = Config.Crimes['door_lockpick']
    
    if not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        Bridge.Notify(source, "Você precisa de um " .. crimeConfig.requiredItem .. " para isso.", "error")
        return
    end

    TriggerClientEvent('illegal-system:client:allowDoorMinigame', source, storeName)
end)

RegisterNetEvent('illegal-system:server:attemptDoorBurglary', function(storeName)
    local source = source
    local crimeConfig = Config.Crimes['door_lockpick']
    
    if not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        return
    end

    local lockId = storeRobberyLocks[storeName]
    if lockId then
        exports.wasvendel_doorlock:SetLockState(lockId, false)
        Bridge.Notify(source, "Porta destrancada!", "success")
        
        -- Aplica Heat/XP do arrombamento de porta
        if crimeConfig.heat > 0 or crimeConfig.xp > 0 then
            TriggerEvent('illegal-system:server:addHeatAndXP', source, crimeConfig.heat, crimeConfig.xp)
        end
    end
end)
