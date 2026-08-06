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
end, false)

