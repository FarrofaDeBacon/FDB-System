fdb = fdb or {}
fdb.callback = {}

local serverCallbacks = {}

-- Registra um callback no servidor
function fdb.callback.RegisterServerCallback(name, cb)
    serverCallbacks[name] = cb
end

-- Evento recebido do cliente pedindo para disparar o callback
RegisterNetEvent('fdb-libs:server:triggerCallback', function(name, requestId, ...)
    local source = source
    if serverCallbacks[name] then
        -- O callback do servidor recebe o source e uma função de callback "responseCb" para devolver os dados
        serverCallbacks[name](source, function(...)
            TriggerClientEvent('fdb-libs:client:serverCallback', source, requestId, ...)
        end, ...)
    else
        print(("[fdb-libs] Server Callback '%s' não está registrado!"):format(name))
        TriggerClientEvent('fdb-libs:client:serverCallback', source, requestId)
    end
end)

-- Exportações para outros resources
exports('RegisterServerCallback', fdb.callback.RegisterServerCallback)

-- REGISTRO DE CALLBACK DE TESTE
if Config.Debug then
    fdb.callback.RegisterServerCallback('fdb-libs:server:test', function(source, cb, data)
        print(("[fdb-libs] Server Callback recebido de [%s] com dados: %s"):format(source, data))
        cb("Resposta do servidor para: " .. tostring(data))
    end)
end
