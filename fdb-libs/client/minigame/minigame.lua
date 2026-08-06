fdb = fdb or {}
fdb.minigame = {}

local activeMinigameId = nil
local minigameStatus = nil -- nil, "success", "failed"

RegisterNUICallback('minigameResult', function(data, cb)
    if data.success then
        minigameStatus = "success"
    else
        minigameStatus = "failed"
    end
    cb('ok')
end)

--- Inicia o minijogo da barra de habilidade circular (skillbar)
---@param config table Configurações do minijogo:
---  - duration (number): tempo em ms para agulha dar uma volta completa (default: 2000)
---  - targetWidth (number): largura da área de acerto em % de 0 a 100 (default: 15)
---  - rounds (number): total de rodadas seguidas para vencer (default: 3)
---@return boolean success Retorna true se jogador venceu todas as rodadas, false se falhou ou cancelou
function fdb.minigame.Start(config)
    if activeMinigameId then return false end

    config = config or {}
    local minigameId = GetGameTimer() + math.random(1000, 9999)
    activeMinigameId = minigameId
    minigameStatus = nil

    -- Ativa foco apenas no teclado (sem mouse)
    SetNuiFocus(true, false)

    SendNUIMessage({
        action = "START_MINIGAME",
        duration = config.duration or 2000,
        targetWidth = config.targetWidth or 15,
        rounds = config.rounds or 3
    })

    -- Loop síncrono de yielding
    while activeMinigameId == minigameId and minigameStatus == nil do
        Wait(50)
    end

    -- Desativa foco de input
    SetNuiFocus(false, false)

    local success = (minigameStatus == "success")
    activeMinigameId = nil
    minigameStatus = nil

    return success
end

function fdb.minigame.Cancel()
    if activeMinigameId then
        SendNUIMessage({
            action = "CANCEL_MINIGAME"
        })
        minigameStatus = "failed"
        activeMinigameId = nil
    end
end

exports('StartMinigame', fdb.minigame.Start)
exports('CancelMinigame', fdb.minigame.Cancel)
