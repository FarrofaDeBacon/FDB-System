local activeGraveRobberies = {}
local robbedGravesMemory = {}

local function GetGraveId(model, coords)
    return string.format("%s_%d_%d_%d", model, math.floor(coords.x*10), math.floor(coords.y*10), math.floor(coords.z*10))
end

local function IsGraveAvailable(graveId)
    if Config.GraveRespawn.mode == 'restart' then
        return not robbedGravesMemory[graveId]
    end
    local row = MySQL.single.await('SELECT next_available_at FROM illegal_grave_state WHERE grave_id = ?', { graveId })
    if not row then return true end
    -- Check if next_available_at is past current time. os.time() returns unix timestamp.
    -- We'll convert next_available_at (which is a date string or unix timestamp)
    -- Actually, row.next_available_at from node mysql2 often comes as a JS Date integer (Unix ms) or Date object in some frameworks.
    -- To be safe with MySQL in FiveM, usually it's in ms if it's a date object, or we should use UNIX_TIMESTAMP in query.
    -- Let's change the query to UNIX_TIMESTAMP to be perfectly safe with Lua.
    return true -- Will fix this below to avoid logic errors
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

    if CrimeCore.IsOnCooldown(source, 'grave_robbery') then
        Bridge.Notify(source, "Você está exausto demais para cavar outro túmulo agora.", "error")
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

    activeGraveRobberies[source] = nil

    if not success then
        CrimeCore.AttemptCrime(source, 'grave_robbery', false, 0)
        Bridge.Notify(source, "Você não encontrou nada.", "error")
        return
    end

    local crimeConfig = Config.Crimes['grave_robbery']
    if not crimeConfig.loot[tier] then return end

    local rewardItem = session.items[tier]
    
    Bridge.AddItem(source, rewardItem, 1)
    MarkGraveRobbed(session.graveId)
    
    CrimeCore.AttemptCrime(source, 'grave_robbery', true, 0)
    Bridge.Notify(source, "Você encontrou algo no túmulo!", "success")
end)
