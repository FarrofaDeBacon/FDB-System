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
            local npcModel, regModel, bauModel = nil, nil, nil
            local regCoords, bauCoords, adminCoords = nil, nil, nil
            
            for _, s in ipairs(stations) do
                if s.type == 'npc' then
                    npcModel = s.npc_model
                elseif s.type == 'registradora' then
                    regModel = s.prop_model
                    regCoords = s.position
                elseif s.type == 'bau' then
                    bauModel = s.prop_model
                    bauCoords = s.position
                elseif s.type == 'admin_panel' then
                    adminCoords = s.position
                end
            end
            
            table.insert(shopsList, {
                id = row.shop_id,
                label = row.label,
                template = row.template_id,
                npc_model = npcModel,
                registradora_model = regModel,
                registradora_coords = regCoords,
                registradora_is_marker = (regCoords ~= nil and regModel == nil),
                bau_model = bauModel,
                bau_coords = bauCoords,
                bau_is_marker = (bauCoords ~= nil and bauModel == nil),
                admin_panel_coords = adminCoords
            })
        end
    end

    TriggerClientEvent('fdb-shops:client:openEditor', src, shopsList)
end, true)

RegisterNetEvent('fdb-shops:server:saveStoreConfig', function(storeData)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    local shopId = storeData.id
    
    if storeData.label then
        MySQL.update.await('UPDATE shops SET label = ? WHERE shop_id = ?', {storeData.label, shopId})
    end
    
    local function upsertStationModel(sType, modelVal, isProp, isMarker)
        local existing = MySQL.scalar.await('SELECT id FROM shop_stations WHERE shop_id = ? AND type = ?', {shopId, sType})
        
        -- Se isMarker for verdadeiro, forçamos o model a null para que o cliente pule o spawn do prop
        local targetModel = isMarker and nil or modelVal

        if existing then
            if isProp then
                MySQL.update.await('UPDATE shop_stations SET prop_model = ? WHERE id = ?', {targetModel, existing})
            else
                MySQL.update.await('UPDATE shop_stations SET npc_model = ? WHERE id = ?', {targetModel, existing})
            end
        else
            if not targetModel then return end -- Não vamos criar uma linha fantasma sem coordenadas nem modelo
            -- Create a dummy entry so we can save the model before having coords, or just insert it.
            if isProp then
                MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, prop_model) VALUES (?, ?, ?)', {shopId, sType, targetModel})
            else
                MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, npc_model) VALUES (?, ?, ?)', {shopId, sType, targetModel})
            end
        end
    end

    upsertStationModel('npc', storeData.npc_model, false, false)
    upsertStationModel('registradora', storeData.registradora_model, true, storeData.registradora_is_marker)
    upsertStationModel('bau', storeData.bau_model, true, storeData.bau_is_marker)
    
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

RegisterNetEvent('fdb-shops:server:removePlacement', function(shopId, spawnType)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    -- Remove completamento a estação do banco (isso anula modelo, coords e limpa o registro)
    MySQL.update.await('DELETE FROM shop_stations WHERE shop_id = ? AND type = ?', {shopId, spawnType})
    
    exports['fdb-libs']:Notify(src, 'Componente removido do banco com sucesso!', 'success')
end)

RegisterNetEvent('fdb-shops:server:deleteStore', function(shopId)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    -- Remove todas as estações e configurações da loja
    MySQL.update.await('DELETE FROM shop_stations WHERE shop_id = ?', {shopId})
    MySQL.update.await('DELETE FROM shops WHERE shop_id = ?', {shopId})
    
    exports['fdb-libs']:Notify(src, 'Loja excluída permanentemente!', 'success')
end)

RegisterNetEvent('fdb-shops:server:createShopFromUI', function(shopId, label, template)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    -- Verifica se já existe
    local exists = MySQL.scalar.await('SELECT 1 FROM shops WHERE shop_id = ?', {shopId})
    if exists then
        exports['fdb-libs']:Notify(src, 'Já existe uma loja com esse ID!', 'error')
        ExecuteCommand('editshops') -- Reabre o painel
        return
    end

    MySQL.insert.await('INSERT INTO shops (shop_id, template_id, label) VALUES (?, ?, ?)', {shopId, template, label})
    exports['fdb-libs']:Notify(src, 'Loja criada com sucesso! Você já pode configurá-la.', 'success')
    
    -- Força a reabertura do painel para carregar a lista nova
    ExecuteCommand('editshops')
end)
