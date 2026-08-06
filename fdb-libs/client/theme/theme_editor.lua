fdb = fdb or {}
fdb.themeEditor = {}

-- Comando para abrir o editor de temas in-game
RegisterCommand('libseditor', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_THEME_EDITOR"
    })
end, false)

-- Salvar tema e aplicar persistentemente
RegisterNUICallback('saveThemeEditor', function(data, cb)
    SetNuiFocus(false, false)
    if data and data.theme then
        -- Salva no KVP local do recurso
        SetResourceKvp("fdb-theme", json.encode(data.theme))
        
        -- Atualiza dinamicamente as variáveis CSS na NUI
        SendNUIMessage({
            action = "SET_THEME_OVERRIDE",
            theme = data.theme
        })
        fdb.notify("Tema customizado salvo com sucesso!", "success", 4000)
    end
    cb('ok')
end)

-- Fechar o editor
RegisterNUICallback('closeThemeEditor', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Resetar tema para o padrão do config.lua
RegisterNUICallback('resetThemeEditor', function(data, cb)
    SetNuiFocus(false, false)
    DeleteResourceKvp("fdb-theme")
    fdb.notify("Tema resetado para as definições do config.lua!", "info", 5000)
    cb('ok')
end)

-- Aplicar o tema salvo no KVP ao carregar
CreateThread(function()
    Wait(1500)
    local savedTheme = GetResourceKvpString("fdb-theme")
    if savedTheme then
        local themeData = json.decode(savedTheme)
        SendNUIMessage({
            action = "SET_THEME_OVERRIDE",
            theme = themeData
        })
    end
end)
