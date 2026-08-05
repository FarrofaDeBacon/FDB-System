fdb = fdb or {}
fdb.theme = {}

-- Inicializa o tema global e envia para o NUI assim que ele estiver pronto
Citizen.CreateThread(function()
    -- Em um cenário ideal, o NUI manda uma mensagem de "ready", 
    -- mas vamos enviar o tema inicial no boot.
    Wait(1000)
    fdb.theme.sync()
end)

function fdb.theme.sync()
    if not Config or not Config.Theme then return end
    
    SendNUIMessage({
        action = "SET_THEME",
        theme = Config.Theme
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
