fdb = fdb or {}
fdb.progress = {}

local activeProgressId = nil
local progressStatus = nil -- nil, "success", "cancelled"

RegisterNUICallback('progressComplete', function(data, cb)
    progressStatus = "success"
    cb('ok')
end)

--- Inicia uma barra de progresso rústica
---@param data table Configurações da barra (duration, label, icon, canCancel, anim, controlDisables)
---@param cb function? Callback opcional de retorno (caso não queira usar await)
---@return boolean success Retorna true se concluiu com sucesso, false se cancelado
function fdb.progress.Start(data, cb)
    print("[fdb-libs client] progress.lua: fdb.progress.Start chamada com dados:", json.encode(data))
    -- ID único para evitar conflito entre múltiplas chamadas rápidas
    local progressId = GetGameTimer() + math.random(1000, 9999)
    activeProgressId = progressId
    progressStatus = nil

    SendNUIMessage({
        action = "START_PROGRESS",
        duration = data.duration or 3000,
        label = data.label or "PROGREDINDO...",
        icon = data.icon or ""
    })

    local hasAnim = false
    local playerPed = PlayerPedId()
    if data.anim then
        hasAnim = true
        if data.anim.dict and data.anim.name then
            RequestAnimDict(data.anim.dict)
            while not HasAnimDictLoaded(data.anim.dict) do
                Wait(0)
            end
            TaskPlayAnim(playerPed, data.anim.dict, data.anim.name, 8.0, -8.0, data.duration or 3000, data.anim.flag or 1, 0, false, false, false)
        elseif data.anim.scenario then
            TaskStartScenarioInPlace(playerPed, GetHashKey(data.anim.scenario), data.duration or 3000, true, false, false, false)
        end
    end

    local duration = data.duration or 3000
    local startTime = GetGameTimer()
    local canCancel = data.canCancel ~= false
    local disables = data.controlDisables or {}

    -- Thread de controle de input e expiração secundária
    Citizen.CreateThread(function()
        while activeProgressId == progressId and progressStatus == nil do
            Wait(0)
            local now = GetGameTimer()

            -- Bloqueio de controles básicos de movimento
            if disables.disableMovement then
                DisableControlAction(0, 0x30777F5C, true) -- MOVE_LEFT_ONLY
                DisableControlAction(0, 0x30777F5D, true) -- MOVE_RIGHT_ONLY
                DisableControlAction(0, 0x8FD7B45B, true) -- MOVE_UP_ONLY
                DisableControlAction(0, 0xD27782E3, true) -- MOVE_DOWN_ONLY
            end
            if disables.disableCombat then
                DisableControlAction(0, 0x07CE1E61, true) -- ATTACK
                DisableControlAction(0, 0xF84FA74F, true) -- AIM
            end

            -- Cancelamento por tecla (Backspace ou ESC)
            if canCancel then
                if IsControlJustPressed(0, 0x156F7119) or IsControlJustPressed(0, 0x308588E6) then
                    fdb.progress.Cancel()
                    break
                end
            end

            -- Proteção caso o NUI falhe em responder após o tempo acabar
            if now - startTime >= duration + 1000 then
                progressStatus = "success"
                break
            end
        end

        if hasAnim then
            ClearPedTasks(playerPed)
        end
    end)

    -- Aguarda na thread atual até mudar o status
    while activeProgressId == progressId and progressStatus == nil do
        Wait(50)
    end

    local success = (progressStatus == "success")
    if cb then
        cb(not success)
    end
    return success
end

function fdb.progress.Cancel()
    if activeProgressId then
        SendNUIMessage({
            action = "CANCEL_PROGRESS"
        })
        progressStatus = "cancelled"
        activeProgressId = nil
    end
end

exports('Progress', fdb.progress.Start)
exports('CancelProgress', fdb.progress.Cancel)
