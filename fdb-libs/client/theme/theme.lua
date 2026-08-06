fdb = fdb or {}
fdb.theme = {}

-- Inicializa o tema global assim que o NUI sinaliza que está pronto
RegisterNUICallback('nuiReady', function(data, cb)
    fdb.theme.sync()
    cb('ok')
end)

function fdb.theme.sync()
    if not Config then return end
    
    local theme = nil
    if Config.ThemePresets and Config.ActiveTheme then
        theme = Config.ThemePresets[Config.ActiveTheme]
    end
    
    -- Fallback se o preset selecionado for inválido
    if not theme then
        theme = Config.ThemePresets and Config.ThemePresets.western_gold or Config.Theme
    end
    
    if not theme then return end
    
    SendNUIMessage({
        action = "SET_THEME",
        theme = theme
    })
end

-- Permite sobrescrever variaveis temporariamente via chamada (ex: para um menu específico)
function fdb.theme.applyOverride(customTheme)
    if not customTheme then return end
    SendNUIMessage({
        action = "SET_THEME_OVERRIDE",
        theme = customTheme
    })
end
