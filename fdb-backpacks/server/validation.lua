local FDBCore = exports['fdb-core']:GetCoreObject()
Validation = {}

local rateLimits = {}

-- 1. ValidateDistance: Rejeita se o jogador estiver fisicamente longe demais
function Validation.Distance(source, coords, maxDistance)
    if not coords then return false, "Coordenadas invalidas." end
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    local dist = #(playerCoords - coords)
    if dist > maxDistance then
        return false, ("Distancia muito longa: %0.2fm (Max: %0.2fm)"):format(dist, maxDistance)
    end
    return true
end

-- 2. ValidateOwnership: Valida se o jogador eh dono da mochila
function Validation.Ownership(source, uid)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return false, "Jogador nao encontrado." end

    local citizenId = Player.PlayerData.citizenid
    local bp = GetBackpackByUid(uid) -- Busca do banco de dados (funcao de database.lua)
    if not bp then
        -- Se nao esta no banco, confere a memoria temporaria do solo
        bp = activeGroundBackpacks[uid]
    end

    if not bp then return false, "Mochila nao encontrada." end

    -- Se a mochila nao possui dono registrado, qualquer um pode interagir
    if not bp.owner or bp.owner == "" then return true end

    if bp.owner ~= citizenId then
        return false, "Voce nao eh o proprietario desta mochila."
    end

    return true
end

-- 3. ValidateExists: Rejeita se o UID nao existir no banco ou memoria
function Validation.Exists(uid)
    local bp = GetBackpackByUid(uid)
    if not bp and activeGroundBackpacks then
        bp = activeGroundBackpacks[uid]
    end
    if not bp then
        return false, "Esta mochila nao existe."
    end
    return true
end

-- 4. ValidateState: Impede transicoes de estado invalidas
function Validation.State(uid, expectedStates)
    local bp = GetBackpackByUid(uid)
    if not bp and activeGroundBackpacks then
        bp = activeGroundBackpacks[uid]
    end
    if not bp then return false, "Mochila nao encontrada para validar estado." end

    local currentState = bp.state
    local isValid = false

    if type(expectedStates) == "table" then
        for _, state in ipairs(expectedStates) do
            if currentState == state then
                isValid = true
                break
            end
        end
    else
        isValid = (currentState == expectedStates)
    end

    if not isValid then
        return false, ("Estado invalido. Atual: %s"):format(currentState)
    end

    -- Se estiver lockada por outro jogador, tratar como ocupada (ex: open)
    if bp.lockedBy and bp.lockedBy ~= 0 then
        return false, "Esta mochila esta sendo usada por outro jogador."
    end

    return true
end

-- 5. ValidateNoDuplication: Previne duplicidade de registros
function Validation.NoDuplication(source, uid)
    -- Confere se ja existe no solo
    if activeGroundBackpacks and activeGroundBackpacks[uid] then
        return false, "Mochila ja esta colocada no solo."
    end

    -- Confere se algum jogador a tem equipada nas costas (ignorando o proprio autor do envio)
    local players = FDBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        if tonumber(playerId) ~= tonumber(source) then
            local targetPlayer = FDBCore.Functions.GetPlayer(playerId)
            if targetPlayer then
                local eq = targetPlayer.PlayerData.metadata.equipmentSlots and targetPlayer.PlayerData.metadata.equipmentSlots.backpack
                if eq and eq.stashId then
                    local eqUid = eq.stashId:sub(1, 3) == "bp_" and eq.stashId:sub(4) or eq.stashId
                    if eqUid == uid then
                        return false, "Mochila ja esta equipada por outro jogador."
                    end
                end
            end
        end
    end

    return true
end

-- 6. Rate Limiting (Debounce de requisicoes por jogador)
function Validation.RateLimit(source, key, timeWindow)
    local now = os.time()
    local userKey = ("%s_%s"):format(source, key)
    if rateLimits[userKey] and (now - rateLimits[userKey]) < timeWindow then
        return false, "Aguarde um momento antes de realizar esta acao novamente."
    end
    rateLimits[userKey] = now
    return true
end
