fdb = fdb or {}
fdb.menu = {}

local isMenuOpen = false
local currentMenuId = nil

-- Failsafe: Sempre limpa o NUI focus quando o script (re)iniciar
Citizen.CreateThread(function()
    Wait(1000)
    SetNuiFocus(false, false)
end)

-- Failsafe 2: Comando salvador para quando o dev bugar a UI
RegisterCommand('fixui', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hideContextMenu"
    })
    print("[fdb-libs] NUI Focus destravado a força!")
end, false)

-- Failsafe 3: Libera o NUI Focus sempre que o resource parar ou restartar
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

--- Abre um menu no NUI
---@param data table Configuração do menu (id, title, items, theme)
function fdb.menu.open(data)
    if not data or not data.id then
        print("[fdb-libs] Erro: fdb.menu.open requer um 'id' no data.")
        return
    end
    
    currentMenuId = data.id
    isMenuOpen = true
    
    -- Aplica tema customizado caso tenha vindo na chamada, senão manda o global
    if data.theme then
        fdb.theme.applyOverride(data.theme)
    else
        fdb.theme.sync()
    end
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "OPEN_MENU",
        menuData = data
    })
end

function fdb.menu.close()
    isMenuOpen = false
    currentMenuId = nil
    
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = "CLOSE_MENU"
    })
end

-- Callback genérico de fechar recebido do NUI (quando o jogador aperta ESC/Backspace)
RegisterNUICallback('closeMenu', function(data, cb)
    fdb.menu.close()
    cb('ok')
end)

-- Callback para mudança de valores em sliders/listas
RegisterNUICallback('onMenuChange', function(data, cb)
    if Config.Debug then
        print(string.format("[fdb-libs:menu] NUI Callback 'onMenuChange' recebido: menuId=%s, itemId=%s, value=%s", tostring(data.menuId), tostring(data.itemId), tostring(data.value)))
    end
    TriggerEvent('fdb-libs:menu:onChange', data)
    cb('ok')
end)

-- Listener de teste para confirmar o disparo do evento Lua
AddEventHandler('fdb-libs:menu:onChange', function(data)
    if Config.Debug then
        print(string.format("[fdb-libs:menu] Evento 'fdb-libs:menu:onChange' disparado no Lua: itemId=%s, value=%s", tostring(data.itemId), tostring(data.value)))
    end
end)

-- COMANDO DE TESTE TEMPORÁRIO PARA O DESENVOLVEDOR
RegisterCommand('testlibs', function()
    fdb.menu.open({
        id = "test_menu",
        title = "FDB LIBS",
        subtitle = "TEMA 100% CONFIGURÁVEL",
        items = {
            { type = "separator", label = "Testes Svelte" },
            { type = "slider", id = "test_slider", label = "Opacidade", min = 0, max = 100, step = 1, value = 50 },
            { type = "list", id = "test_list", label = "Cores", values = {"Vermelho", "Verde", "Azul"}, current = 1 },
            { type = "separator" },
            { type = "color", id = "test_color", label = "Batom", min = 1, max = 15, value = 1 },
            { type = "checkbox", id = "test_check", label = "Sardas", checked = true },
            { type = "button", id = "test_btn", label = "Botão Genérico" }
        }
    })
end, false)

-- COMANDO DE TESTE PARA NOTIFICAÇÕES SIMULTÂNEAS
RegisterCommand('testnotify', function()
    fdb.notify("Ação concluída com sucesso!", "success", 5000)
    fdb.notify("Ocorreu um erro crítico!", "error", 7000)
    fdb.notify("Isto é um aviso de atenção.", "warning", 6000)
    fdb.notify("Seu cavalo criou um laço mais forte com você!", "info", 5000, "toast_horse_bond", "Laço de Cavalo")
    fdb.notify("Você recebeu $100 dólares de recompensa.", "success", 6000, "dollar", "Dinheiro Recebido")
    fdb.notify("Cor de fundo e borda roxa customizada via Lua!", "info", 8000, "star", "Estilo Custom", "rgba(30, 10, 50, 0.95)", "#aa00ff")
end, false)

-- COMANDO DE TESTE PARA BARRA DE PROGRESSO
RegisterCommand('testprogress', function(source, args)
    Citizen.CreateThread(function()
        local duration = tonumber(args[1]) or 5000
        
        fdb.notify("Iniciando ação...", "info", 2000)
        
        local success = exports['fdb-libs']:Progress({
            duration = duration,
            label = "Minerando Ouro...",
            icon = "gold",
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCombat = true
            }
        })
        
        if success then
            fdb.notify("Ação concluída com sucesso!", "success", 3000)
        else
            fdb.notify("Ação cancelada pelo jogador!", "error", 3000)
        end
    end)
end, false)

-- COMANDO DE TESTE PARA DIÁLOGO DE INPUTS
RegisterCommand('testinput', function()
    Citizen.CreateThread(function()
        local data = exports['fdb-libs']:InputDialog("Registro de Cidadão", {
            { type = "text", label = "Nome Completo", placeholder = "Arthur Morgan" },
            { type = "password", label = "Senha do Cofre", placeholder = "Digite a senha..." },
            { type = "number", label = "Quantidade de Ouro", default = 5, min = 1, max = 100 },
            { type = "select", label = "Cavalo Principal", options = { "Mustang", "Turcomano", "Árabe" }, default = "Mustang" },
            { type = "checkbox", label = "Aceita os Termos do Bando", default = true }
        })

        if data then
            print("[fdb-libs] TestInput dados recebidos:", json.encode(data))
            fdb.notify("Nome: " .. tostring(data[1]) .. " | Cavalo: " .. tostring(data[4]), "success", 8000)
        else
            fdb.notify("Diálogo cancelado!", "error", 4000)
        end
    end)
end, false)

-- COMANDO DE TESTE PARA MINIGAME (SKILLBAR)
RegisterCommand('testminigame', function(source, args)
    local diff = args[1] or "medium"
    local config = { duration = 1800, targetWidth = 12, rounds = 3 }

    if diff == "easy" then
        config = { duration = 2500, targetWidth = 20, rounds = 2 }
    elseif diff == "hard" then
        config = { duration = 1200, targetWidth = 8, rounds = 4 }
    end

    Citizen.CreateThread(function()
        fdb.notify("Iniciando minijogo (" .. diff .. ")... Pressione ESPAÇO!", "info", 3000)
        Wait(1500)

        local success = exports['fdb-libs']:StartMinigame(config)

        if success then
            fdb.notify("Você conseguiu destrancar!", "success", 4000)
        else
            fdb.notify("Você falhou!", "error", 4000)
        end
    end)
end, false)

-- COMANDO DE TESTE PARA CALLBACKS
RegisterCommand('testcallback', function(source, args)
    local testData = args[1] or "Dados padrão de teste"
    
    -- 1. Exemplo Assíncrono (com função de callback)
    exports['fdb-libs']:TriggerServerCallback('fdb-libs:server:test', function(response)
        fdb.notify("Callback assíncrono retornado: " .. tostring(response), "info", 5000)
    end, testData)

    -- 2. Exemplo Síncrono (usando await / yielding de thread)
    Citizen.CreateThread(function()
        fdb.notify("Disparando callback síncrono...", "info", 2000)
        Wait(1000)
        local response = exports['fdb-libs']:TriggerServerCallbackAsync('fdb-libs:server:test', testData .. " (SÍNCRONO)")
        fdb.notify("Callback síncrono retornado: " .. tostring(response), "success", 5000)
    end)
end, false)

-- COMANDO DE TESTE PARA BLIPS
RegisterCommand('testblip', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    fdb.notify("Criando Blip temporário de teste no mapa...", "info", 3000)
    
    -- Cria um blip de estrela (sprite blip_mp_star ou hash correspondente)
    local blip = exports['fdb-libs']:CreateBlip(coords, "Teste FDB Libs", "blip_ambient_bounty_hunter", nil, "COLOR_RED")

    if blip then
        Citizen.CreateThread(function()
            Wait(10000) -- espera 10 segundos
            fdb.notify("Removendo Blip de teste...", "warning", 3000)
            exports['fdb-libs']:RemoveBlip(blip)
        end)
    else
        fdb.notify("Falha ao criar o Blip!", "error", 4000)
    end
end, false)

-- COMANDO DE TESTE PARA ZONAS (GEOFENCE)
local activeTestZone = nil
RegisterCommand('testzone', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if activeTestZone then
        fdb.notify("Removendo zona de teste anterior...", "warning", 3000)
        exports['fdb-libs']:RemoveZone(activeTestZone)
        activeTestZone = nil
        return
    end

    fdb.notify("Criando zona de teste com Marcador 3D e Prompt (E)! Entre no círculo.", "info", 5000)
    
    activeTestZone = exports['fdb-libs']:CreateZone("zona_teste_fdb", coords, 3.0, {
        drawMarker = true,
        markerType = 1, -- Cilindro
        markerColor = { r = 201, g = 161, b = 90, a = 60 }, -- Dourado translúcido
        showPrompt = true,
        promptText = "Abrir Loja de Teste",
        promptKey = 0xE30CD707, -- Tecla Context (E por padrão)
        onEnter = function()
            fdb.notify("Você entrou no círculo dourado! Olhe o Prompt no canto inferior direito.", "success", 4000)
        end,
        onExit = function()
            fdb.notify("Você saiu do círculo!", "error", 4000)
        end,
        onKeyPress = function()
            fdb.notify("Você apertou [E]! Abrindo Diálogo de Registro...", "success", 3000)
            Wait(1000)
            -- Dispara o diálogo de inputs automaticamente como integração de teste!
            ExecuteCommand("testinput")
        end
    })
end, false)

-- COMANDO DE TESTE PARA MENU DE CONTEXTO
RegisterCommand('testcontext', function()
    exports['fdb-libs']:OpenContextMenu({
        title = "Menu do Cidadão",
        options = {
            { label = "Revistar Jogador", icon = "eye", description = "Verifica os pertences físicos", action = function() fdb.notify("Você revistou o jogador!", "success", 4000) end },
            { label = "Algemar / Soltar", icon = "lock", description = "Prende ou liberta as mãos", action = function() fdb.notify("Ação de algemar executada!", "warning", 4000) end },
            { label = "Opção Bloqueada", icon = "ban", disabled = true }
        }
    })
end, false)

-- COMANDO DE TESTE PARA AJUSTES COMPONENT
RegisterCommand('testcomp', function()
    local playerPed = PlayerPedId()
    
    -- 1. Ajusta o nariz do jogador para empinado (índice 0, valor 1.0)
    exports['fdb-libs']:SetFaceFeature(playerPed, 0, 1.0)
    
    -- 2. Ajusta a maquiagem/batom (overlay ID 9, textura 1, opacidade 1.0)
    exports['fdb-libs']:SetOverlay(playerPed, 9, 1, 1.0, 135, 0, 0)
    
    fdb.notify("Componentes faciais e batom ajustados com sucesso!", "success", 4000)
end, false)


