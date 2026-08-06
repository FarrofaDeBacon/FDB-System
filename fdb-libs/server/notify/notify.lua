fdb = fdb or {}

--- Dispara uma notificação para um jogador específico (client)
---@param source number ID do jogador no servidor
---@param message string A mensagem
---@param type string? Tipo (success, error, warning, info)
---@param duration number? Duração em ms (default 5000)
---@param icon string? Ícone customizado opcional (ex: 'dollar')
---@param title string? Título opcional
----@param customBg string? Cor de fundo customizada (ex: 'rgba(0,0,0,0.5)')
----@param customBorder string? Cor de borda/progresso customizada
function fdb.notify(source, message, type, duration, icon, title, customBg, customBorder)
    if not source or not message then return end
    TriggerClientEvent('fdb-libs:client:Notify', source, message, type, duration, icon, title, customBg, customBorder)
end

exports('Notify', fdb.notify)
