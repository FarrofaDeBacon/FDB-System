fdb = fdb or {}
fdb.minigame = {}

local registeredMinigames = {}
local activeMinigameId = nil
local minigameResult = nil -- nil | table { success, tier? }

--- Registra um novo tipo de minigame.
--- @param name string Identificador usado no config (ex: "lockpick", "tierbar")
--- @param handler function(config) -> nil. Só precisa mandar o SendNUIMessage de abertura;
---   o resultado chega via fdb.minigame.ReportResult (chamado pelo componente Svelte correspondente).
function fdb.minigame.Register(name, handler)
    registeredMinigames[name] = handler
end

--- Chamado pelo NUI (RegisterNUICallback central) quando qualquer minigame termina.
--- Não precisa ser chamado manualmente fora do fluxo NUI -> Lua.
function fdb.minigame.ReportResult(result)
    minigameResult = result
end

--- Dispara o minigame pelo nome. Bloqueia (yield) até o resultado chegar.
--- @param name string
--- @param config table Config específica do tipo (repassada direto pro handler)
--- @return table { success: boolean, tier: string|nil }
function fdb.minigame.Start(name, config)
    if activeMinigameId then
        return { success = false, tier = nil }
    end

    local handler = registeredMinigames[name]
    if not handler then
        print(('[fdb-libs] [ERROR] fdb.minigame: tipo "%s" nao foi registrado. Registrados: %s')
            :format(tostring(name), table.concat((function()
                local keys = {}
                for k in pairs(registeredMinigames) do table.insert(keys, k) end
                return keys
            end)(), ', ')))
        return { success = false, tier = nil }
    end

    config = config or {}
    local minigameId = GetGameTimer() + math.random(1000, 9999)
    activeMinigameId = minigameId
    minigameResult = nil

    SetNuiFocus(true, false)
    handler(config)

    while activeMinigameId == minigameId and minigameResult == nil do
        Wait(50)
    end

    SetNuiFocus(false, false)

    local result = minigameResult or { success = false, tier = nil }
    activeMinigameId = nil
    minigameResult = nil

    return result
end

function fdb.minigame.Cancel()
    if activeMinigameId then
        SendNUIMessage({ action = "CANCEL_MINIGAME" })
        minigameResult = { success = false, tier = nil }
        activeMinigameId = nil
    end
end

-- ============================================================
-- Callback único, central, pra qualquer tipo de minigame reportar resultado.
-- Substitui o antigo RegisterNUICallback('minigameResult', ...) que só
-- entendia boolean puro — agora aceita { success, tier } de qualquer tipo.
-- ============================================================
RegisterNUICallback('minigameResult', function(data, cb)
    fdb.minigame.ReportResult({
        success = data.success or false,
        tier = data.tier or nil
    })
    cb('ok')
end)

-- ============================================================
-- Tipo 1: "lockpick" — skillbar circular já existente, só adaptado
-- pro formato de registro (comportamento idêntico ao de antes).
-- ============================================================
fdb.minigame.Register('lockpick', function(config)
    SendNUIMessage({
        action = "START_MINIGAME",
        minigameType = "lockpick",
        duration = config.duration or 2000,
        targetWidth = config.targetWidth or 15,
        rounds = config.rounds or 3
    })
end)

-- ============================================================
-- Tipo 2: "tierbar" — barra horizontal com zonas (comum/incomum/raro),
-- cursor indo e voltando, Espaço pra parar. Baseado no minigame que
-- já existia dentro do illegal-system.
-- ============================================================
--- Config esperada:
---   duration (number, segundos, default 5.0)
---   images { common, uncommon, rare } (urls opcionais)
---   zones { common = {start,end}, uncommon = {start,end}, rare = {start,end} }
---     (em % de 0-100; se omitido, usa o padrão abaixo)
fdb.minigame.Register('tierbar', function(config)
    SendNUIMessage({
        action = "START_MINIGAME",
        minigameType = "tierbar",
        duration = config.duration or 5.0,
        images = config.images or {},
        zones = config.zones or {
            common   = { start = 10, ["end"] = 35 },
            uncommon = { start = 50, ["end"] = 65 },
            rare     = { start = 80, ["end"] = 88 },
        }
    })
end)

exports('StartMinigame', fdb.minigame.Start)
exports('CancelMinigame', fdb.minigame.Cancel)
exports('RegisterMinigame', fdb.minigame.Register)
