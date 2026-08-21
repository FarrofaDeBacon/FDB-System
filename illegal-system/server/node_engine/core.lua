NodeEngine = {}
NodeEngine.Types = {}
NodeEngine.RegisteredHeists = {}
local activeSessions = {}

-- Carrega os assaltos do banco de dados na inicialização
CreateThread(function()
    -- Dá um tempinho para o oxmysql estar 100% pronto
    Wait(1000)
    MySQL.Async.fetchAll('SELECT * FROM illegal_heists WHERE active = 1', {}, function(results)
        if not results then return end
        
        local count = 0
        for _, row in ipairs(results) do
            local success, parsedGraph = pcall(json.decode, row.graph)
            if success and parsedGraph then
                -- Opcional: Se for vetor no JSON, precisamos garantir que as funções vector3 funcionem, mas o ox_target aceita table com x,y,z
                NodeEngine.RegisteredHeists[row.id] = parsedGraph
                count = count + 1
            else
                print("[NodeEngine] ERRO: Falha ao decodificar JSON do assalto ID: " .. tostring(row.id))
            end
        end
        print("[NodeEngine] " .. count .. " assaltos carregados do banco de dados.")
    end)
end)

-- Utility to generate unique tokens
local function GenerateToken()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local token = ''
    for i = 1, 16 do
        local rand = math.random(1, #chars)
        token = token .. string.sub(chars, rand, rand)
    end
    return token
end

function NodeEngine.RegisterNodeType(name, handlers)
    NodeEngine.Types[name] = handlers
end

local function AdvanceNode(playerId, session, nextNodeId)
    local node = session.graph.nodes[nextNodeId]
    if not node then
        print(("[NodeEngine] Sessão %s de %s encerrada (não há próximo nó)."):format(session.heistName, playerId))
        activeSessions[playerId] = nil
        TriggerClientEvent('node_engine:client:EndSession', playerId)
        return
    end

    local token = GenerateToken()
    session.currentNodeId = nextNodeId
    session.currentNodeType = node.type
    session.nodeStartTime = os.time()
    session.nodeToken = token

    local nodeHandler = NodeEngine.Types[node.type]
    if nodeHandler and nodeHandler.OnEnter then
        nodeHandler.OnEnter(playerId, session, node.data, token)
    else
        print(("[NodeEngine] Tipo de nó não registrado: %s"):format(node.type))
    end
end

function NodeEngine.StartHeist(playerId, heistName, graph)
    print("[NodeEngine Debug] StartHeist invocado para jogador: " .. tostring(playerId))
    -- Find start node
    local startNodeId = nil
    for id, node in pairs(graph.nodes) do
        if node.type == "start" then
            startNodeId = id
            break
        end
    end

    if not startNodeId then
        print("[NodeEngine] Grafo não possui nó 'start'.")
        return
    end

    print("[NodeEngine Debug] Nó 'start' encontrado: " .. startNodeId)
    activeSessions[playerId] = {
        heistName = heistName,
        graph = graph,
        currentNodeId = nil,
        currentNodeType = nil,
        nodeStartTime = nil,
        nodeToken = nil
    }

    AdvanceNode(playerId, activeSessions[playerId], startNodeId)
end

RegisterNetEvent('node_engine:server:ReportNodeCompletion', function(token, reportData)
    local src = source
    local session = activeSessions[src]
    if not session then return end

    if session.nodeToken ~= token then
        print(("[NodeEngine] Token inválido (Esperado: %s, Recebido: %s) do jogador %s"):format(session.nodeToken, token, src))
        -- Ban or warn logic here
        return
    end

    local nodeHandler = NodeEngine.Types[session.currentNodeType]
    if nodeHandler and nodeHandler.OnClientReport then
        local nodeData = session.graph.nodes[session.currentNodeId].data
        local success, msg = nodeHandler.OnClientReport(src, session, nodeData, reportData)
        if success then
            -- Encontrar próximo nó usando as arestas (edges)
            local nextNodeId = nil
            for _, edge in ipairs(session.graph.edges) do
                if edge.source == session.currentNodeId then
                    nextNodeId = edge.target
                    break
                end
            end
            AdvanceNode(src, session, nextNodeId)
        else
            print(("[NodeEngine] Falha na validação do nó para o jogador %s: %s"):format(src, msg or "Motivo desconhecido"))
        end
    end
end)

RegisterCommand('heistdebug', function(source)
    if source == 0 then return end
    local session = activeSessions[source]
    if session then
        local timeSpent = os.time() - session.nodeStartTime
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"HEIST DEBUG", string.format("Heist: %s | Nó: %s (%s) | Tempo no nó: %ds", session.heistName, session.currentNodeId, session.currentNodeType, timeSpent)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"HEIST DEBUG", "Nenhuma sessão ativa."}
        })
    end
end, false)

RegisterNetEvent('node_engine:server:ForceStartHeist', function(heistId)
    local source = source
    print("[NodeEngine Debug] Evento ForceStartHeist invocado por: " .. tostring(source) .. " para o assalto: " .. tostring(heistId))
    
    if not heistId then 
        print("[NodeEngine Debug] ID de assalto não fornecido.")
        return 
    end
    
    local graph = NodeEngine.RegisteredHeists[heistId]
    if not graph then
        print("[NodeEngine Debug] Assalto ID '" .. tostring(heistId) .. "' não encontrado em NodeEngine.RegisteredHeists.")
        return
    end

    NodeEngine.StartHeist(source, heistId, graph)
end)

-- Salvar Grafo no Banco
lib.callback.register('illegal-system:server:SaveHeistGraph', function(source, id, name, graphData)
    if not Bridge.HasPermission(source) then 
        return false, "Sem permissão."
    end
    
    local graphJson = json.encode(graphData)
    local query = "INSERT INTO illegal_heists (id, name, graph) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name=VALUES(name), graph=VALUES(graph)"
    
    local success, err = pcall(function()
        MySQL.Sync.execute(query, {id, name, graphJson})
    end)
    
    if success then
        NodeEngine.RegisteredHeists[id] = graphData
        print("[NodeEngine] Grafo salvo e atualizado na memória: " .. id)
        return true, "Salvo com sucesso."
    else
        print("[NodeEngine] Erro ao salvar grafo no banco: " .. tostring(err))
        return false, "Erro ao salvar no banco."
    end
end)

-- Tipos de Nó
local function AutoAdvance(playerId, session)
    local nextNodeId = nil
    for _, edge in ipairs(session.graph.edges) do
        if edge.source == session.currentNodeId then
            nextNodeId = edge.target
            break
        end
    end
    AdvanceNode(playerId, session, nextNodeId)
end
NodeEngine.RegisterNodeType("start", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        -- Nó silencioso, avança automaticamente sem precisar de client report
        AutoAdvance(playerId, session)
    end
})

NodeEngine.RegisterNodeType("wait", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        local duration = nodeData.durationMs or 1000
        CreateThread(function()
            Wait(duration)
            AutoAdvance(playerId, session)
        end)
    end
})

NodeEngine.RegisterNodeType("end", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        print(("[NodeEngine] Sessão %s de %s encerrada pelo nó 'end'."):format(session.heistName, playerId))
        activeSessions[playerId] = nil
        TriggerClientEvent('node_engine:client:EndSession', playerId)
    end
})

NodeEngine.RegisterNodeType("open_door", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:StartNodeAction', playerId, "open_door", nodeData, nodeToken)
        print("[NodeEngine Debug] Enviou StartNodeAction para client: open_door")
    end,
    OnClientReport = function(playerId, session, nodeData, reportData)
        local timeElapsed = os.time() - session.nodeStartTime
        if timeElapsed < (nodeData.minTime or 5) then
            return false, "Tempo mínimo não atingido (Speedhack?)"
        end
        return true
    end
})

NodeEngine.RegisterNodeType("crack_register", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:StartNodeAction', playerId, "crack_register", nodeData, nodeToken)
    end,
    OnClientReport = function(playerId, session, nodeData, reportData)
        local timeElapsed = os.time() - session.nodeStartTime
        if timeElapsed < (nodeData.minTime or 3) then
            return false, "Tempo mínimo não atingido (Speedhack?)"
        end
        print(("[NodeEngine] Jogador %s roubou a registradora!"):format(playerId))
        return true
    end
})

NodeEngine.RegisterNodeType("lockpick_door", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:StartNodeAction', playerId, "lockpick_door", nodeData, nodeToken)
    end,
    OnClientReport = function(playerId, session, nodeData, reportData)
        local timeElapsed = os.time() - session.nodeStartTime
        if timeElapsed < (nodeData.minTime or 5) then
            return false, "Tempo mínimo não atingido (Speedhack?)"
        end
        return true
    end
})

NodeEngine.RegisterNodeType("minigame", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:StartNodeAction', playerId, "minigame", nodeData, nodeToken)
    end,
    OnClientReport = function(playerId, session, nodeData, reportData)
        local timeElapsed = os.time() - session.nodeStartTime
        if timeElapsed < (nodeData.minTime or 5) then
            return false, "Tempo mínimo não atingido (Speedhack?)"
        end
        return true
    end
})

NodeEngine.RegisterNodeType("spawn_ped", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:SyncAction', playerId, "spawn_ped", nodeData)
        AutoAdvance(playerId, session)
    end
})

NodeEngine.RegisterNodeType("player_notification", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:SyncAction', playerId, "player_notification", nodeData)
        AutoAdvance(playerId, session)
    end
})

NodeEngine.RegisterNodeType("dispatch", {
    OnEnter = function(playerId, session, nodeData, nodeToken)
        TriggerClientEvent('node_engine:client:SyncAction', playerId, "dispatch", nodeData)
        AutoAdvance(playerId, session)
    end
})
