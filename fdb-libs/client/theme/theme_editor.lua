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
        -- Salva no themeStore (KVP persistente)
        fdb.themeStore.Set("active_override", data.theme)
        
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
    fdb.themeStore.Set("active_override", nil)
    fdb.notify("Tema resetado para as definições do config.lua!", "info", 5000)
    cb('ok')
end)
