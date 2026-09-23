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

RegisterNetEvent('fdb-shops:server:saveStoreConfig', function(storeData)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    local shopId = storeData.id
    local label = storeData.label
    local npcModel = storeData.npc_model
    
    if label then
        MySQL.update.await('UPDATE shops SET label = ? WHERE shop_id = ?', {label, shopId})
    end
    
    if npcModel then
        MySQL.update.await('UPDATE shop_stations SET npc_model = ? WHERE shop_id = ? AND type = "npc"', {npcModel, shopId})
    end
    
    exports['fdb-libs']:Notify(src, 'Loja ' .. shopId .. ' salva com sucesso!', 'success')
    
    -- Recarrega lojas globalmente
    -- Como a recarga pode ser complexa e envolver N coisas, o ideal é só reiniciar o script ou chamar a função se existir
    -- Mas como não temos LoadShops público definido na task atual, apenas alertamos.
    print("^2[fdb-shops] Loja " .. shopId .. " teve suas propriedades alteradas no BD.^7")
end)
