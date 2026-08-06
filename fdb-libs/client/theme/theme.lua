fdb = fdb or {}
fdb.theme = {}

-- Inicializa o tema global assim que o NUI sinaliza que está pronto
RegisterNUICallback('nuiReady', function(data, cb)
    fdb.theme.sync()
    cb('ok')
end)

fdb.themeStore = {}

-- Obtém valor persistido de forma segura do KVP
function fdb.themeStore.Get(key, default)
    local prefix = "fdb_theme_"
    local val = GetResourceKvpString(prefix .. key)
    if not val then return default end
    
    local success, decoded = pcall(json.decode, val)
    if success then
        return decoded
    else
        return val
    end
end

-- Persiste ou remove valor no KVP de forma segura
function fdb.themeStore.Set(key, value)
    local prefix = "fdb_theme_"
    if value == nil then
        DeleteResourceKvp(prefix .. key)
    else
        SetResourceKvp(prefix .. key, json.encode(value))
    end
end

function fdb.theme.sync()
    if not Config then return end
    
    -- Tenta obter o tema persistido do KVP primeiro
    local theme = fdb.themeStore.Get('active_override')
    
    -- Se não houver override salvo, usa as predefinições estáticas
    if not theme then
        if Config.ThemePresets and Config.ActiveTheme then
            theme = Config.ThemePresets[Config.ActiveTheme]
        end
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
