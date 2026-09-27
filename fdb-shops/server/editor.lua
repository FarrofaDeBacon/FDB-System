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
                    heading = s.npc_heading or 0.0,
                    is_marker = isMarker,
                    metadata = s.metadata and json.decode(s.metadata) or nil
                })
            end
            
            table.insert(shopsList, {
                id = row.shop_id,
                label = row.label,
                owner_id = row.owner_id,
                template = row.template_id,
                city = row.city or 'outros',
                config = row.config and json.decode(row.config) or {},
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
    
    local originalId = storeData.originalId or storeData.id
    local shopId = storeData.id
    
    -- Rename shop_id if changed
    if shopId and originalId and shopId ~= originalId then
        local exists = MySQL.scalar.await('SELECT 1 FROM shops WHERE shop_id = ?', {shopId})
        if exists then
            exports['fdb-libs']:Notify(src, 'Já existe uma loja com o ID ' .. shopId .. '!', 'error')
            return
        end
        
        -- Update foreign tables
        MySQL.update.await('UPDATE shop_stations SET shop_id = ? WHERE shop_id = ?', {shopId, originalId})
        pcall(function() MySQL.update.await('UPDATE shop_employees SET shop_id = ? WHERE shop_id = ?', {shopId, originalId}) end)
        MySQL.update.await('UPDATE shops SET shop_id = ? WHERE shop_id = ?', {shopId, originalId})
        
        if ShopManager.Shops[originalId] then
            ShopManager.Shops[shopId] = ShopManager.Shops[originalId]
            ShopManager.Shops[originalId] = nil
        end
        print(("^2[fdb-shops] Loja renomeada de '%s' para '%s'^7"):format(originalId, shopId))
    end
    
    if storeData.label then
        local ownerId = storeData.owner_id
        if ownerId == "" then ownerId = nil end
        local template = (storeData.template and storeData.template ~= '') and storeData.template or 'normal'
        local city = (storeData.city and storeData.city ~= '') and storeData.city or 'outros'
        local configStr = storeData.config and json.encode(storeData.config) or nil
        MySQL.update.await('UPDATE shops SET label = ?, owner_id = ?, template_id = ?, city = ?, config = ? WHERE shop_id = ?', {storeData.label, ownerId, template, city, configStr, shopId})
        
        if ShopManager.Shops[shopId] then
            ShopManager.Shops[shopId].label = storeData.label
            ShopManager.Shops[shopId].ownerId = ownerId
            ShopManager.Shops[shopId].templateId = template
            ShopManager.Shops[shopId].city = city
            ShopManager.Shops[shopId].config = storeData.config or {}
        end
    end
    
    for _, st in ipairs(storeData.stations or {}) do
        local stId = tonumber(st.id)
        if stId then
            local targetProp = (st.is_marker or st.type == 'admin_panel') and nil or st.prop_model
            local targetNpc = (st.is_marker) and nil or st.npc_model
            if st.type == 'npc' then targetProp = nil end
            local heading = tonumber(st.heading)
            
            if st.type == 'admin_panel' then
                local metadataStr = st.metadata and json.encode(st.metadata) or nil
                MySQL.update.await('UPDATE shop_stations SET prop_model = ?, npc_model = ?, metadata = ? WHERE id = ?', {targetProp, targetNpc, metadataStr, stId})
            else
                if heading ~= nil then
                    MySQL.update.await('UPDATE shop_stations SET prop_model = ?, npc_model = ?, npc_heading = ? WHERE id = ?', {targetProp, targetNpc, heading, stId})
                else
                    MySQL.update.await('UPDATE shop_stations SET prop_model = ?, npc_model = ? WHERE id = ?', {targetProp, targetNpc, stId})
                end
            end
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
    local numStationId = tonumber(stationId)

    if numStationId then
        if spawnType == 'npc' then
            MySQL.update.await('UPDATE shop_stations SET position = ?, npc_heading = ?, npc_model = ? WHERE id = ?', {posStr, heading, targetNpc, numStationId})
        else
            MySQL.update.await('UPDATE shop_stations SET position = ?, npc_heading = ?, prop_model = ? WHERE id = ?', {posStr, heading, targetProp, numStationId})
        end
        TriggerClientEvent('fdb-shops:client:refreshStation', -1, numStationId, shopId, spawnType, targetNpc or targetProp, posTable, heading)
    else
        -- Insert new
        local newId
        if spawnType == 'npc' then
            newId = MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, position, npc_heading, npc_model) VALUES (?, ?, ?, ?, ?)', {shopId, spawnType, posStr, heading, targetNpc})
        else
            newId = MySQL.insert.await('INSERT INTO shop_stations (shop_id, type, position, npc_heading, prop_model) VALUES (?, ?, ?, ?, ?)', {shopId, spawnType, posStr, heading, targetProp})
        end
        
        TriggerClientEvent('fdb-shops:client:updateStationId', src, stationId, newId)
        TriggerClientEvent('fdb-shops:client:refreshStation', -1, newId, shopId, spawnType, targetNpc or targetProp, posTable, heading)
    end

    exports['fdb-libs']:Notify(src, 'Posição salva com sucesso!', 'success')
    print("^2[fdb-shops] Loja " .. shopId .. " teve sua posição salva.^7")
end)

RegisterNetEvent('fdb-shops:server:updateHeading', function(stationId, heading)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    local numId = tonumber(stationId)
    if numId then
        MySQL.update.await('UPDATE shop_stations SET npc_heading = ? WHERE id = ?', {heading, numId})
        TriggerClientEvent('fdb-shops:client:setHeading', -1, numId, heading)
    end
end)

RegisterNetEvent('fdb-shops:server:removePlacement', function(shopId, stationId)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    local numStationId = tonumber(stationId)
    if numStationId then
        MySQL.update.await('DELETE FROM shop_stations WHERE id = ?', {numStationId})
        exports['fdb-libs']:Notify(src, 'Componente removido do banco com sucesso!', 'success')
        TriggerClientEvent('fdb-shops:client:stationDeleted', -1, numStationId)
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

RegisterNetEvent('fdb-shops:server:createShopFromUI', function(shopId, label, template, ownerId, city)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end

    -- Verifica se já existe
    local exists = MySQL.scalar.await('SELECT 1 FROM shops WHERE shop_id = ?', {shopId})
    if exists then
        exports['fdb-libs']:Notify(src, 'Já existe uma loja com esse ID!', 'error')
        OpenEditor(src)
        return
    end

    local shopCity = (city and city ~= '') and city or 'valentine'
    MySQL.insert.await('INSERT INTO shops (shop_id, template_id, label, owner_id, city) VALUES (?, ?, ?, ?, ?)', {shopId, template, label, ownerId, shopCity})
    exports['fdb-libs']:Notify(src, 'Loja criada com sucesso! Você já pode configurá-la.', 'success')
    
    -- Força a reabertura do painel para carregar a lista nova
    OpenEditor(src)
end)

RegisterCommand('setshopcity', function(source, args)
    local src = source
    if src > 0 and not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    local shopId = args[1]
    local city = args[2]
    if not shopId or not city then
        if src > 0 then
            exports['fdb-libs']:Notify(src, 'Uso: /setshopcity <shop_id> <cidade>', 'error')
        else
            print('Uso: setshopcity <shop_id> <cidade>')
        end
        return
    end
    
    local updated = MySQL.update.await('UPDATE shops SET city = ? WHERE shop_id = ?', {city, shopId})
    if updated and updated > 0 then
        if ShopManager.Shops[shopId] then ShopManager.Shops[shopId].city = city end
        if src > 0 then
            exports['fdb-libs']:Notify(src, ('Cidade da loja %s definida como %s.'):format(shopId, city), 'success')
        else
            print(('Cidade da loja %s definida como %s.'):format(shopId, city))
        end
    else
        if src > 0 then
            exports['fdb-libs']:Notify(src, ('Loja %s não encontrada.'):format(shopId), 'error')
        else
            print(('Loja %s não encontrada.'):format(shopId))
        end
    end
end, true)

