local activeGraveRobberies = {}
local robbedGravesMemory = {}

local function GetGraveId(model, coords)
    return string.format("%s_%d_%d_%d", model, math.floor(coords.x*10), math.floor(coords.y*10), math.floor(coords.z*10))
end



local function MarkGraveRobbed(graveId)
    if Config.GraveRespawn.mode == 'restart' then
        robbedGravesMemory[graveId] = true
        return
    end
    local days = math.random(Config.GraveRespawn.minDays, Config.GraveRespawn.maxDays)
    local seconds = days * Config.GraveRespawn.minutesPerIngameDay * 60
    local nextAvailable = os.time() + seconds
    MySQL.insert.await([[
        INSERT INTO illegal_grave_state (grave_id, last_robbed_at, next_available_at)
        VALUES (?, NOW(), FROM_UNIXTIME(?))
        ON DUPLICATE KEY UPDATE last_robbed_at = NOW(), next_available_at = FROM_UNIXTIME(?)
    ]], { graveId, nextAvailable, nextAvailable })
end

RegisterNetEvent('illegal-system:server:startGraveRobbery', function(graveData)
    local source = source
    local crimeConfig = Config.Crimes['grave_robbery']

    if crimeConfig.requiredItem and not Bridge.HasItem(source, crimeConfig.requiredItem, 1) then
        Bridge.Notify(source, "Você precisa de uma pá.", "error")
        return
    end

    local graveId = GetGraveId(graveData.model, graveData.coords)
    
    -- Correct IsGraveAvailable query check
    if Config.GraveRespawn.mode == 'restart' then
        if robbedGravesMemory[graveId] then
            Bridge.Notify(source, "Este túmulo já foi revirado recentemente.", "error")
            return
        end
    else
        local row = MySQL.single.await('SELECT UNIX_TIMESTAMP(next_available_at) as next_time FROM illegal_grave_state WHERE grave_id = ?', { graveId })
        if row and os.time() < row.next_time then
            Bridge.Notify(source, "Este túmulo já foi revirado recentemente.", "error")
            return
        end
    end

    local attempt = CrimeCore.AttemptCrime(source, 'grave_robbery')
    if not attempt.ok then
        if attempt.reason == 'cooldown' then
            Bridge.Notify(source, "Você está exausto demais para cavar outro túmulo agora.", "error")
        end
        return
    end

    local items = {
        common = crimeConfig.loot.common[math.random(#crimeConfig.loot.common)],
        uncommon = crimeConfig.loot.uncommon[math.random(#crimeConfig.loot.uncommon)],
        rare = crimeConfig.loot.rare[math.random(#crimeConfig.loot.rare)]
    }

    local sessionToken = "grave_" .. tostring(math.random(100000, 999999))
    activeGraveRobberies[source] = {
        token = sessionToken,
        startTime = os.time(),
        items = items,
        graveId = graveId
    }

    TriggerClientEvent('illegal-system:client:startGraveRobberyMinigame', source, {
        items = items,
        sessionToken = sessionToken,
        coords = graveData.coords
    })
end)

RegisterNetEvent('illegal-system:server:finishGraveRobbery', function(success, tier, token)
    local source = source
    local session = activeGraveRobberies[source]

    if not session or session.token ~= token then
        print(("[illegal-system] EXPLOIT DETECTADO: %s tentou forçar roubo de túmulo sem token ou com token inválido"):format(GetPlayerName(source)))
        return
    end

    local elapsed = os.time() - session.startTime
    local crimeConfig = Config.Crimes['grave_robbery']
    local minExpected = 0.5 -- O minigame tierbar pode ser concluído muito rápido dependendo da zona.
    if elapsed < minExpected then
        print(("[illegal-system] EXPLOIT DETECTADO: %s respondeu rápido demais (%ds) pro grave_robbery"):format(GetPlayerName(source), elapsed))
        return
    end

    activeGraveRobberies[source] = nil

    if not success then
        CrimeCore.FinishCrime(source, 'grave_robbery', false, nil)
        Bridge.Notify(source, "Você não encontrou nada.", "error")
        return
    end

    if not crimeConfig.loot[tier] then return end

    local rewardItem = session.items[tier]
    
    -- O FinishCrime já dá o item, não precisamos chamar Bridge.AddItem manualmente aqui
    -- se passarmos o rewardItem pra ele (veja o core.lua linha 148).
    CrimeCore.FinishCrime(source, 'grave_robbery', true, rewardItem)
    MarkGraveRobbed(session.graveId)
    
    Bridge.Notify(source, "Você encontrou algo no túmulo!", "success")
end)
