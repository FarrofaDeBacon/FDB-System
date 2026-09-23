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

RegisterNetEvent('fdb-shops:server:savePlacement', function(shopId, spawnType, coords, heading)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    local posTable = { x = coords.x, y = coords.y, z = coords.z }
    local posStr = json.encode(posTable)

    -- Verifica se a station já existe
    local existing = MySQL.scalar.await('SELECT id FROM shop_stations WHERE shop_id = ? AND type = ?', {shopId, spawnType})

    if existing then
        if spawnType == 'npc' then
            MySQL.update.await('UPDATE shop_stations SET position = ?, npc_heading = ? WHERE id = ?', {posStr, heading, existing})
        else
            MySQL.update.await('UPDATE shop_stations SET position = ? WHERE id = ?', {posStr, existing})
        end
    else
        if spawnType == 'npc' then
            -- Get default npc_model if possible, or leave null for now (UI defines it)
            local shop = ShopManager.GetShop(shopId)
            local npcModel = nil
            if shop then
                -- Try to find an existing npc_model in the list if the cache exists
            end
            MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, position, npc_heading) VALUES (?, ?, ?, ?)', {shopId, spawnType, posStr, heading})
        else
            MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, position) VALUES (?, ?, ?)', {shopId, spawnType, posStr})
        end
    end

    exports['fdb-libs']:Notify(src, 'Posição do ' .. spawnType .. ' salva com sucesso!', 'success')
    print("^2[fdb-shops] Loja " .. shopId .. " (station: " .. spawnType .. ") teve sua posição salva.^7")
    
    -- Notificar cliente para fazer refresh local ou só instruir a usar /shopreload
    exports['fdb-libs']:Notify(src, 'Use /shopreload para aplicar as novas posições no mundo.', 'primary')
end)
