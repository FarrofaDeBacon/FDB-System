fdb = fdb or {}
fdb.callback = {}

local serverCallbacks = {}
local nextRequestId = 0

-- Registra e envia uma requisição de callback para o servidor (Assíncrono via cb)
function fdb.callback.TriggerServerCallback(name, cb, ...)
    local requestId = nextRequestId
    nextRequestId = nextRequestId + 1

    serverCallbacks[requestId] = cb

    TriggerServerEvent('fdb-libs:server:triggerCallback', name, requestId, ...)
end

-- Versão síncrona/awaitable usando yielding
function fdb.callback.TriggerServerCallbackAsync(name, ...)
    local p = promise.new()

    fdb.callback.TriggerServerCallback(name, function(...)
        p:resolve({...})
    end, ...)

    local result = Citizen.Await(p)
    return table.unpack(result)
end

-- Evento de resposta do servidor
RegisterNetEvent('fdb-libs:client:serverCallback', function(requestId, ...)
    if serverCallbacks[requestId] then
        serverCallbacks[requestId](...)
        serverCallbacks[requestId] = nil
    end
end)

-- Exportações para outros resources
exports('TriggerServerCallback', fdb.callback.TriggerServerCallback)
exports('TriggerServerCallbackAsync', fdb.callback.TriggerServerCallbackAsync)
