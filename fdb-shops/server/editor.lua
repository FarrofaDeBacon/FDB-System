-- fdb-shops/server/editor.lua
local FDBCore = exports['fdb-core']:GetCoreObject()

RegisterCommand('editshops', function(source, args)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    -- Load all shops to display in the UI
    local shopsList = {}
    local rows = MySQL.query.await('SELECT * FROM shops')
    if rows then
        for _, row in ipairs(rows) do
            local stations = MySQL.query.await('SELECT * FROM shop_stations WHERE shop_id = ?', {row.shop_id})
            local npcModel = nil
            for _, s in ipairs(stations) do
                if s.type == 'npc' then
                    npcModel = s.npc_model
                end
            end
            
            table.insert(shopsList, {
                id = row.shop_id,
                label = row.label,
                template = row.template_id,
                npc_model = npcModel
            })
        end
    end

    TriggerClientEvent('fdb-shops:client:openEditor', src, shopsList)
end, true)

-- Add suggestion for connected players
CreateThread(function()
    Wait(1000)
    for _, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent('chat:addSuggestion', playerId, '/editshops', 'Abre o painel visual Svelte para gerenciar lojas', {})
    end
end)
