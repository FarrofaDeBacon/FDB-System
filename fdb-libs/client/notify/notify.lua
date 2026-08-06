fdb = fdb or {}

--- Dispara uma notificação para o NUI
---@param message string A mensagem a ser exibida
---@param type string? O tipo da notificação (success, error, warning, info)
---@param duration number? A duração em milissegundos (default 5000)
---@param icon string? Ícone customizado opcional (ex: 'dollar', 'toast_horse_bond')
---@param title string? Título opcional
---@param customBg string? Cor de fundo customizada (ex: '#00ff00' ou 'rgba(0,0,0,0.5)')
---@param customBorder string? Cor de borda/progresso customizada
function fdb.notify(message, type, duration, icon, title, customBg, customBorder)
    if not message then return end
    
    SendNUIMessage({
        action = "SEND_NOTIFICATION",
        type = type or "info",
        message = message,
        duration = duration or 5000,
        icon = icon or "",
        title = title or "",
        customBg = customBg or "",
        customBorder = customBorder or ""
    })
end

-- Export público
exports('Notify', fdb.notify)

-- Evento de rede para receber disparos do server
RegisterNetEvent('fdb-libs:client:Notify', function(message, type, duration, icon, title, customBg, customBorder)
    fdb.notify(message, type, duration, icon, title, customBg, customBorder)
end)
