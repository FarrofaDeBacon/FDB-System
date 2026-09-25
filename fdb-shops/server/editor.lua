-- fdb-shops/server/editor.lua
local FDBCore = exports['fdb-core']:GetCoreObject()

local function OpenEditor(src)
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    local shopsList = {}
    local rows = MySQL.query.await('SELECT * FROM shops')
    if rows then
        for _, row in ipairs(rows) do
            local stations = MySQL.query.await('SELECT * FROM shop_stations WHERE shop_id = ?', {row.shop_id})
            local parsedStations = {}
            for _, s in ipairs(stations) do
                local isMarker = false
                if s.position ~= nil and s.prop_model == nil and s.npc_model == nil then
                    isMarker = true
                end
                if s.type == 'admin_panel' then isMarker = true end
                
                table.insert(parsedStations, {
                    id = s.id,
                    type = s.type,
                    prop_model = s.prop_model,
                    npc_model = s.npc_model,
                    position = s.position and json.decode(s.position) or nil,
                    is_marker = isMarker,
                    metadata = s.metadata and json.decode(s.metadata) or nil
                })
            end
            
            table.insert(shopsList, {
                id = row.shop_id,
                label = row.label,
                owner_id = row.owner_id,
                template = row.template_id,
                stations = parsedStations
            })
        end
    end

    TriggerClientEvent('fdb-shops:client:openEditor', src, shopsList)
end

RegisterCommand('editshops', function(source, args)
    OpenEditor(source)
end, true)

RegisterNetEvent('fdb-shops:server:saveStoreConfig', function(storeData)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    local shopId = storeData.id
    
    if storeData.label then
        local ownerId = storeData.owner_id
        if ownerId == "" then ownerId = nil end
        MySQL.update.await('UPDATE shops SET label = ?, owner_id = ? WHERE shop_id = ?', {storeData.label, ownerId, shopId})
        
        if ShopManager.Shops[shopId] then
            ShopManager.Shops[shopId].label = storeData.label
            ShopManager.Shops[shopId].ownerId = ownerId
        end
    end
    
    for _, st in ipairs(storeData.stations) do
        if type(st.id) == "number" then
            local targetProp = (st.is_marker or st.type == 'admin_panel') and nil or st.prop_model
            local targetNpc = (st.is_marker) and nil or st.npc_model
            if st.type == 'npc' then targetProp = nil end
            
            MySQL.update.await('UPDATE shop_stations SET prop_model = ?, npc_model = ? WHERE id = ?', {targetProp, targetNpc, st.id})
        end
    end
    
    exports['fdb-libs']:Notify(src, 'Loja ' .. shopId .. ' salva com sucesso!', 'success')
    print("^2[fdb-shops] Loja " .. shopId .. " teve suas propriedades alteradas no BD.^7")
end)

RegisterNetEvent('fdb-shops:server:savePlacement', function(shopId, stationId, spawnType, coords, heading, model)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    local posTable = { x = coords.x, y = coords.y, z = coords.z }
    local posStr = json.encode(posTable)
    
    local targetProp = spawnType == 'npc' and nil or model
    local targetNpc = spawnType == 'npc' and model or nil

    if type(stationId) == "number" then
        if spawnType == 'npc' then
            MySQL.update.await('UPDATE shop_stations SET position = ?, npc_heading = ?, npc_model = ? WHERE id = ?', {posStr, heading, targetNpc, stationId})
        else
            MySQL.update.await('UPDATE shop_stations SET position = ?, prop_model = ? WHERE id = ?', {posStr, targetProp, stationId})
        end
    else
        -- Insert new
        local newId
        if spawnType == 'npc' then
            newId = MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, position, npc_heading, npc_model) VALUES (?, ?, ?, ?, ?)', {shopId, spawnType, posStr, heading, targetNpc})
        else
            newId = MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, position, prop_model) VALUES (?, ?, ?, ?)', {shopId, spawnType, posStr, targetProp})
        end
        
        TriggerClientEvent('fdb-shops:client:updateStationId', src, stationId, newId)
    end

    exports['fdb-libs']:Notify(src, 'Posição salva com sucesso!', 'success')
    print("^2[fdb-shops] Loja " .. shopId .. " teve sua posição salva.^7")
    exports['fdb-libs']:Notify(src, 'Use /shopreload para aplicar as novas posições no mundo.', 'primary')
end)

RegisterNetEvent('fdb-shops:server:removePlacement', function(shopId, stationId)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    if type(stationId) == "number" then
        MySQL.update.await('DELETE FROM shop_stations WHERE id = ?', {stationId})
        exports['fdb-libs']:Notify(src, 'Componente removido do banco com sucesso!', 'success')
    end
end)

RegisterNetEvent('fdb-shops:server:deleteStore', function(shopId)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    -- Remove todas as estações e configurações da loja
    MySQL.update.await('DELETE FROM shop_stations WHERE shop_id = ?', {shopId})
    MySQL.update.await('DELETE FROM shops WHERE shop_id = ?', {shopId})
    
    exports['fdb-libs']:Notify(src, 'Loja excluída permanentemente!', 'success')
end)

RegisterNetEvent('fdb-shops:server:createShopFromUI', function(shopId, label, template, ownerId)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    -- Verifica se já existe
    local exists = MySQL.scalar.await('SELECT 1 FROM shops WHERE shop_id = ?', {shopId})
    if exists then
        exports['fdb-libs']:Notify(src, 'Já existe uma loja com esse ID!', 'error')
        OpenEditor(src)
        return
    end

    MySQL.insert.await('INSERT INTO shops (shop_id, template_id, label, owner_id) VALUES (?, ?, ?, ?)', {shopId, template, label, ownerId})
    exports['fdb-libs']:Notify(src, 'Loja criada com sucesso! Você já pode configurá-la.', 'success')
    
    -- Força a reabertura do painel para carregar a lista nova
    OpenEditor(src)
end)
