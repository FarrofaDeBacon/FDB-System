local RSGCore = exports['fdb-core']:GetCoreObject()

-- Callback GetPedData: Returns the character features (CachePedData)
Callback.register('fdb-creator:GetPedData', function(source, charid)
    local citizenid = charid or GetCharIdentifier(source)
    if not citizenid then return {} end
    
    local result = MySQL.Sync.fetchAll('SELECT peddata FROM fdb_creator WHERE charid = ?', { citizenid })
    if result[1] and result[1].peddata then
        return json.decode(result[1].peddata)
    end
    return {}
end)

-- Callback UpdatePedData: Updates character features (CachePedData)
Callback.register('fdb-creator:UpdatePedData', function(source, CachePedData)
    local citizenid = GetCharIdentifier(source)
    if not citizenid then return false end
    
    local result = MySQL.Sync.fetchAll('SELECT id FROM fdb_creator WHERE charid = ?', { citizenid })
    if result[1] then
        MySQL.Async.execute('UPDATE fdb_creator SET peddata = ? WHERE charid = ?', { json.encode(CachePedData), citizenid })
    else
        local info = { lore = "", birthday = "", birthmonth = "", birthyear = "" }
        MySQL.Async.execute('INSERT INTO fdb_creator (charid, peddata, informations) VALUES (?, ?, ?)', { citizenid, json.encode(CachePedData), json.encode(info) })
    end
    return true
end)

-- Callback CreateNewCharacter: Handles character creation and links features
Callback.register('fdb-creator:CreateNewCharacter', function(source, data, CachePedData)
    local src = source
    CreateNewCharacter(src, data)
    
    local citizenid = nil
    for i = 1, 50 do
        Wait(100)
        local Player = RSGCore.Functions.GetPlayer(src)
        if Player then
            citizenid = Player.PlayerData.citizenid
            break
        end
    end
    
    if citizenid then
        local info = {
            lore = data.lore or "",
            birthday = data.birthday or "",
            birthmonth = data.birthmonth or "",
            birthyear = data.birthyear or ""
        }
        local result = MySQL.Sync.fetchAll('SELECT id FROM fdb_creator WHERE charid = ?', { citizenid })
        if result[1] then
            MySQL.Async.execute('UPDATE fdb_creator SET peddata = ?, informations = ? WHERE charid = ?', { json.encode(CachePedData), json.encode(info), citizenid })
        else
            MySQL.Async.execute('INSERT INTO fdb_creator (charid, peddata, informations) VALUES (?, ?, ?)', { citizenid, json.encode(CachePedData), json.encode(info) })
        end
        return true
    end
    return false
end)

-- Callback SavePreset: Saves hairstyle and overlays/makeup presets
Callback.register('fdb-creator:SavePreset', function(source, hairstyleCache, overlay_all_layers, name, outfitId, isMale)
    local citizenid = GetCharIdentifier(source)
    if not citizenid then return false, 0 end
    
    local makeup = {}
    local permanent = {}
    for k, v in pairs(overlay_all_layers) do
        if v.name == "eyebrows" or v.name == "eyeliners" or v.name == "lipsticks" or v.name == "shadows" or v.name == "blush" then
            table.insert(makeup, v)
        else
            table.insert(permanent, v)
        end
    end
    
    local result = MySQL.Sync.fetchAll('SELECT charid FROM fdb_barber WHERE charid = ?', { citizenid })
    if result[1] then
        MySQL.Async.execute('UPDATE fdb_barber SET hairstyle = ?, overlays = ?, permanentoverlay = ?, outfit_id = ? WHERE charid = ?', 
            { json.encode(hairstyleCache), json.encode(makeup), json.encode(permanent), outfitId or 0, citizenid })
    else
        MySQL.Async.execute('INSERT INTO fdb_barber (charid, hairstyle, overlays, permanentoverlay, outfit_id) VALUES (?, ?, ?, ?, ?)', 
            { citizenid, json.encode(hairstyleCache), json.encode(makeup), json.encode(permanent), outfitId or 0 })
    end
    
    local price = 0.0
    local gender = isMale and "Male" or "Female"
    MySQL.Async.execute('INSERT INTO fdb_barber_preset (charid, outfit_id, price, name, hairstyle, overlays, gender) VALUES (?, ?, ?, ?, ?, ?, ?)',
        { citizenid, outfitId or 0, price, name or "Base", json.encode(hairstyleCache), json.encode(makeup), gender })
        
    return true, outfitId or 0
end)

-- Callback GetCurrentHairs: Returns active hairstyle and makeup data
Callback.register('fdb-barber:GetCurrentHairs', function(source)
    local citizenid = GetCharIdentifier(source)
    if not citizenid then return {}, 0, {}, {} end
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM fdb_barber WHERE charid = ?', { citizenid })
    if result[1] then
        local hairstyle = json.decode(result[1].hairstyle)
        local overlays = json.decode(result[1].overlays)
        local permanentoverlay = json.decode(result[1].permanentoverlay)
        return hairstyle, result[1].outfit_id, overlays, permanentoverlay
    end
    return {}, 0, {}, {}
end)

-- Callback GetCurrentHairsOnCharacter: Returns active hairstyle for specific character ID
Callback.register('fdb-barber:GetCurrentHairsOnCharacter', function(source, charid)
    local citizenid = charid or GetCharIdentifier(source)
    if not citizenid then return {}, 0, {}, {} end
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM fdb_barber WHERE charid = ?', { citizenid })
    if result[1] then
        local hairstyle = json.decode(result[1].hairstyle)
        local overlays = json.decode(result[1].overlays)
        local permanentoverlay = json.decode(result[1].permanentoverlay)
        return hairstyle, result[1].outfit_id, overlays, permanentoverlay
    end
    return {}, 0, {}, {}
end)

-- Callback GetCurrentOverlays: Returns active barber overlays/makeup
Callback.register('fdb-barber:GetCurrentOverlays', function(source)
    local citizenid = GetCharIdentifier(source)
    if not citizenid then return {}, {} end
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM fdb_barber WHERE charid = ?', { citizenid })
    if result[1] then
        local overlays = json.decode(result[1].overlays)
        local permanentoverlay = json.decode(result[1].permanentoverlay)
        return overlays, permanentoverlay
    end
    return {}, {}
end)

-- Server Event fdb-barber:updatehairstyle
RegisterServerEvent("fdb-barber:updatehairstyle")
AddEventHandler("fdb-barber:updatehairstyle", function(barberCache, barber_overlay_all_layers, outfitid)
    local src = source
    local citizenid = GetCharIdentifier(src)
    if not citizenid then return end
    
    local makeup = {}
    local permanent = {}
    for k, v in pairs(barber_overlay_all_layers) do
        if v.name == "eyebrows" or v.name == "eyeliners" or v.name == "lipsticks" or v.name == "shadows" or v.name == "blush" then
            table.insert(makeup, v)
        else
            table.insert(permanent, v)
        end
    end
    
    local result = MySQL.Sync.fetchAll('SELECT charid FROM fdb_barber WHERE charid = ?', { citizenid })
    if result[1] then
        MySQL.Async.execute('UPDATE fdb_barber SET hairstyle = ?, overlays = ?, permanentoverlay = ?, outfit_id = ? WHERE charid = ?', 
            { json.encode(barberCache), json.encode(makeup), json.encode(permanent), outfitid or 0, citizenid })
    else
        MySQL.Async.execute('INSERT INTO fdb_barber (charid, hairstyle, overlays, permanentoverlay, outfit_id) VALUES (?, ?, ?, ?, ?)', 
            { citizenid, json.encode(barberCache), json.encode(makeup), json.encode(permanent), outfitid or 0 })
    end
end)
