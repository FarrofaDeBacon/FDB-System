NodeEngine = {}
NodeEngine.Types = {}
NodeEngine.RegisteredHeists = {}
local activeSessions = {}

NodeEngine.GlobalTriggers = { models = {} }

-- Carrega os assaltos do banco de dados na inicialização
CreateThread(function()
    -- Dá um tempinho para o oxmysql estar 100% pronto
    Wait(1000)
    local results = MySQL.query.await('SELECT * FROM illegal_heists WHERE active = 1')
    if not results then return end
    
    local count = 0
    for _, row in ipairs(results) do
        local success, parsedGraph = pcall(json.decode, row.graph)
        if success and parsedGraph then
            NodeEngine.RegisteredHeists[row.id] = parsedGraph
            count = count + 1
            
            -- Extrai nós do tipo trigger_model para enviar ao client
            for nodeId, nodeData in pairs(parsedGraph.nodes) do
                if nodeData.type == 'trigger_model' then
                    local models = {}
                    -- Suporta string separada por vírgula no editor
                    if nodeData.data.models then
                        for model in string.gmatch(nodeData.data.models, '([^,]+)') do
                            local cleanModel = string.match(model, "^%s*(.-)%s*$")
                            if cleanModel ~= "" then
                                -- Tenta converter para hash numérico se for número
                                local num = tonumber(cleanModel)
                                table.insert(models, num or cleanModel)
                            end
                        end
                    end
                    
                    if #models > 0 then
                        table.insert(NodeEngine.GlobalTriggers.models, {
                            heistId = row.id,
                            nodeId = nodeId,
                            models = models,
                            label = nodeData.data.prompt or "Interagir",
                            icon = nodeData.data.icon or "fas fa-hand",
                            distance = tonumber(nodeData.data.distance) or 3.5
                        })
                    end
                end
            end
        else
            print("[NodeEngine] ERRO: Falha ao decodificar JSON do assalto ID: " .. tostring(row.id))
        end
    end
    print("[NodeEngine] " .. count .. " assaltos carregados. Gatilhos de modelo: " .. #NodeEngine.GlobalTriggers.models)
end)

lib.callback.register('node_engine:server:GetGlobalTriggers', function(source)
    return NodeEngine.GlobalTriggers
end)

RegisterNetEvent('node_engine:server:TriggerModelInteracted', function(heistId, nodeId, entityModel, entityCoords)
    local source = source
    local graph = NodeEngine.RegisteredHeists[heistId]
    if not graph then return end
    
    -- Inicia a sessão injetando o contexto do trigger
    print("[NodeEngine] Iniciando assalto dinâmico via trigger_model: " .. heistId)
    NodeEngine.StartHeist(source, heistId, graph, {
        entityModel = entityModel,
        entityCoords = entityCoords
    })
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

function NodeEngine.StartHeist(playerId, heistName, graph, context)
    print("[NodeEngine Debug] StartHeist invocado para jogador: " .. tostring(playerId))
    -- Find start node OR trigger_model node
    local startNodeId = nil
    for id, node in pairs(graph.nodes) do
        if node.type == "start" or node.type == "trigger_model" then
            startNodeId = id
            break
        end
    end

    if not startNodeId then
        print("[NodeEngine] Grafo não possui nó 'start' ou 'trigger_model'.")
        return
    end

    print("[NodeEngine Debug] Nó inicial encontrado: " .. startNodeId)
    activeSessions[playerId] = {
        heistName = heistName,
        graph = graph,
        currentNodeId = nil,
        currentNodeType = nil,
        nodeStartTime = nil,
        nodeToken = nil,
        context = context or {}
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
    if not Bridge.HasPermission(source, 'illegal.admin') then
        print("[NodeEngine] Permissão negada para source " .. tostring(source))
        return false, "Sem permissão."
    end
    
    local graphJson = json.encode(graphData)
    local query = "INSERT INTO illegal_heists (id, name, graph) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name=VALUES(name), graph=VALUES(graph)"
    
    local success, err = pcall(function()
        MySQL.query.await(query, {id, name, graphJson})
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

-- Listar Grafos Salvos
lib.callback.register('illegal-system:server:GetHeistGraphs', function(source)
    if not Bridge.HasPermission(source, 'illegal.admin') then
        return false, "Sem permissão."
    end
    
    local results = MySQL.query.await('SELECT id, name, graph FROM illegal_heists')
    local heists = {}
    if results and #results > 0 then
        for _, row in ipairs(results) do
            table.insert(heists, {
                id = row.id,
                name = row.name,
                graph = json.decode(row.graph)
            })
        end
    end
    return true, heists
end)

-- Deletar Grafo
lib.callback.register('illegal-system:server:DeleteHeistGraph', function(source, id)
    if not Bridge.HasPermission(source, 'illegal.admin') then
        return false, "Sem permissão."
    end
    
    local success = pcall(function()
        MySQL.query.await('DELETE FROM illegal_heists WHERE id = ?', {id})
    end)
    
    if success then
        NodeEngine.RegisteredHeists[id] = nil
        print("[NodeEngine] Grafo deletado: " .. id)
        return true, "Deletado com sucesso."
    else
        return false, "Erro ao deletar no banco."
    end
end)

-- Comando de Teste
RegisterCommand('testheist', function(source, args)
    if source == 0 then return end
    if not Bridge.HasPermission(source, 'illegal.admin') then
        Bridge.Notify(source, "Sem permissão.", "error")
        return
    end

    local heistId = args[1]
    if not heistId then
        Bridge.Notify(source, "Uso: /testheist [id_do_assalto]", "error")
        return
    end

    local graph = NodeEngine.RegisteredHeists[heistId]
    if not graph then
        Bridge.Notify(source, "Assalto não encontrado na memória.", "error")
        return
    end

    Bridge.Notify(source, "Iniciando teste do assalto: " .. heistId, "success")
    NodeEngine.StartHeist(source, heistId, graph)
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
