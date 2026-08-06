fdb = fdb or {}
fdb.context = {}

local activeCallbacks = {}

-- Abrir o menu de contexto
function fdb.context.OpenContextMenu(data)
    if not data or not data.options then return end

    activeCallbacks = {}
    local uiOptions = {}

    for i, opt in ipairs(data.options) do
        table.insert(uiOptions, {
            label = opt.label,
            icon = opt.icon or "cog",
            description = opt.description,
            disabled = opt.disabled or false
        })
        if opt.action then
            activeCallbacks[i] = opt.action
        end
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_CONTEXT_MENU",
        data = {
            title = data.title or "Opções",
            position = data.position or "mouse",
            options = uiOptions
        }
    })
end

-- Fechar o menu de contexto
function fdb.context.CloseContextMenu()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "CLOSE_CONTEXT_MENU"
    })
    activeCallbacks = {}
end

-- Callback de clique do NUI
RegisterNUICallback('contextClick', function(data, cb)
    local index = tonumber(data.index)
    fdb.context.CloseContextMenu()
    
    if index and activeCallbacks[index] then
        activeCallbacks[index]()
    end
    cb('ok')
end)

-- Callback de fechamento espontâneo do NUI
RegisterNUICallback('closeContext', function(data, cb)
    fdb.context.CloseContextMenu()
    cb('ok')
end)

-- Exportações para outros recursos
exports('OpenContextMenu', fdb.context.OpenContextMenu)
exports('CloseContextMenu', fdb.context.CloseContextMenu)
