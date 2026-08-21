ActiveStores = {}

local function LoadStoresFromDB()
    local storesRows = MySQL.query.await('SELECT * FROM illegal_stores')
    local spawnsRows = MySQL.query.await('SELECT * FROM illegal_store_risk_spawns')

    local newStores = {}
    
    for _, row in ipairs(storesRows) do
        local storeConfig = nil
        for _, cfgStore in ipairs(Config.Stores) do
            if cfgStore.name == row.name then
                storeConfig = cfgStore
                break
            end
        end
        
        -- Carrega apenas se houver regras base no config
        if storeConfig then
            local storeData = {
                id = row.id,
                name = row.name,
                coords = vec3(row.coords_x, row.coords_y, row.coords_z),
                doorCoords = (row.door_x and row.door_y and row.door_z) and vec3(row.door_x, row.door_y, row.door_z) or nil,
                registerCoords = (row.register_x and row.register_y and row.register_z) and vec3(row.register_x, row.register_y, row.register_z) or nil,
                registerHeading = row.register_heading or 0.0,
                
                -- Mescla com dados do Config (Horários, loot, radius, etc)
                radius = storeConfig.radius,
                openHour = storeConfig.openHour,
                closeHour = storeConfig.closeHour,
                registerCash = storeConfig.registerCash,
                
                riskSpawns = { guards = {} }
            }
            
            newStores[row.id] = storeData
        end
    end
    
    -- Preenche os risk spawns
    for _, spawn in ipairs(spawnsRows) do
        local store = newStores[spawn.store_id]
        if store then
            if spawn.type == 'dog' then
                store.riskSpawns.dog = {
                    spawnCoords = vec3(spawn.x, spawn.y, spawn.z),
                    spawnHeading = spawn.heading or 0.0,
                    reaction = spawn.reaction or 'combat'
                }
            elseif spawn.type == 'guard' then
                table.insert(store.riskSpawns.guards, {
                    spawnCoords = vec3(spawn.x, spawn.y, spawn.z),
                    spawnHeading = spawn.heading or 0.0,
                    reaction = spawn.reaction or 'combat'
                })
            end
        end
    end
    
    -- Converte o formato para o Client (Array ao invés de hash por id)
    local finalArray = {}
    for _, store in pairs(newStores) do
        table.insert(finalArray, store)
    end
    
    ActiveStores = finalArray
    print(("[illegal-system] Carregadas %d lojas do banco de dados na inicializacao."):format(#ActiveStores))
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    -- Migração automática de DB para suportar a coluna reaction
    pcall(function()
        MySQL.query.await("ALTER TABLE illegal_store_risk_spawns ADD COLUMN IF NOT EXISTS reaction VARCHAR(50) DEFAULT 'combat'")
    end)
    
    LoadStoresFromDB()
end)

lib.callback.register('illegal-system:server:GetActiveStores', function(source)
    return ActiveStores
end)

lib.callback.register('illegal-system:server:SaveStore', function(source, data)
    if not IsPlayerAceAllowed(source, 'illegal.admin') then
        return false, "Sem permissão."
    end
    
    local query = [[
        INSERT INTO illegal_stores (name, coords_x, coords_y, coords_z, door_x, door_y, door_z, register_x, register_y, register_z, register_heading)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            coords_x=VALUES(coords_x), coords_y=VALUES(coords_y), coords_z=VALUES(coords_z),
            door_x=VALUES(door_x), door_y=VALUES(door_y), door_z=VALUES(door_z),
            register_x=VALUES(register_x), register_y=VALUES(register_y), register_z=VALUES(register_z), register_heading=VALUES(register_heading)
    ]]
    
    MySQL.query.await(query, {
        data.name,
        data.coords.x, data.coords.y, data.coords.z,
        data.doorCoords and data.doorCoords.x or nil, data.doorCoords and data.doorCoords.y or nil, data.doorCoords and data.doorCoords.z or nil,
        data.registerCoords and data.registerCoords.x or nil, data.registerCoords and data.registerCoords.y or nil, data.registerCoords and data.registerCoords.z or nil,
        data.registerHeading or 0.0
    })
    
    LoadStoresFromDB()
    TriggerClientEvent('illegal-system:client:UpdateActiveStores', -1, ActiveStores)
    
    return true, "Loja salva com sucesso."
end)

lib.callback.register('illegal-system:server:SaveStoreSpawns', function(source, storeName, spawns)
    if not IsPlayerAceAllowed(source, 'illegal.admin') then
        return false, "Sem permissão."
    end
    
    local storeId = MySQL.scalar.await('SELECT id FROM illegal_stores WHERE name = ?', {storeName})
    if not storeId then
        return false, "Loja não encontrada no banco."
    end
    
    MySQL.query.await('DELETE FROM illegal_store_risk_spawns WHERE store_id = ?', {storeId})
    
    if spawns and #spawns > 0 then
        local insertParams = {}
        for _, sp in ipairs(spawns) do
            table.insert(insertParams, {storeId, sp.type, sp.coords.x, sp.coords.y, sp.coords.z, sp.heading or 0.0, sp.reaction or 'combat'})
        end
        -- oxmysql permite bulk insert enviando uma tabela de tabelas para o placeholer ?
        MySQL.insert.await('INSERT INTO illegal_store_risk_spawns (store_id, type, x, y, z, heading, reaction) VALUES ?', {insertParams})
    end
    
    LoadStoresFromDB()
    TriggerClientEvent('illegal-system:client:UpdateActiveStores', -1, ActiveStores)
    
    return true, "Spawns salvos com sucesso."
end)
