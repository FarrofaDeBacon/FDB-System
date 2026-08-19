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
                    spawnHeading = spawn.heading or 0.0
                }
            elseif spawn.type == 'guard' then
                table.insert(store.riskSpawns.guards, {
                    spawnCoords = vec3(spawn.x, spawn.y, spawn.z),
                    spawnHeading = spawn.heading or 0.0
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
    LoadStoresFromDB()
end)

lib.callback.register('illegal-system:server:GetActiveStores', function(source)
    return ActiveStores
end)
