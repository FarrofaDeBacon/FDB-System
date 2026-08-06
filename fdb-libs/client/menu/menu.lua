fdb = fdb or {}
fdb.menu = {}

local isMenuOpen = false
local currentMenuId = nil

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
    -- Trigger evento interno para o resource que chamou escutar
    -- data contém: menuId, itemId, value
    TriggerEvent('fdb-libs:menu:onChange', data)
    cb('ok')
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

