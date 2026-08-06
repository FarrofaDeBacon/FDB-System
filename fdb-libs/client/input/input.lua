fdb = fdb or {}
fdb.input = {}

local activeInputId = nil
local inputStatus = nil -- nil, "submitted", "cancelled"
local inputValues = nil

RegisterNUICallback('submitInput', function(data, cb)
    inputValues = data.values
    if data.values == false then
        inputStatus = "cancelled"
    else
        inputStatus = "submitted"
    end
    cb('ok')
end)

--- Exibe uma caixa de diálogo rústica de inputs que bloqueia a thread
---@param title string Título do diálogo
---@param fields table Lista de campos (type, label, placeholder, default, options, min, max)
---@return table|false values Retorna uma array ordenada com os valores ou false se cancelado
function fdb.input.Show(title, fields)
    if activeInputId then return false end

    local inputId = GetGameTimer() + math.random(1000, 9999)
    activeInputId = inputId
    inputStatus = nil
    inputValues = nil

    -- Ativa foco de mouse e teclado no CEF
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "OPEN_INPUT",
        title = title or "Diálogo",
        fields = fields or {}
    })

    -- Loop de yielding até que o jogador confirme ou cancele o diálogo
    while activeInputId == inputId and inputStatus == nil do
        Wait(50)
    end

    -- Desativa foco de mouse e teclado
    SetNuiFocus(false, false)

    local result = inputValues
    activeInputId = nil
    inputStatus = nil
    inputValues = nil

    return result
end

function fdb.input.Close()
    if activeInputId then
        SendNUIMessage({
            action = "CLOSE_INPUT"
        })
        inputValues = false
        inputStatus = "cancelled"
        activeInputId = nil
    end
end

exports('InputDialog', fdb.input.Show)
exports('CloseInput', fdb.input.Close)
