FDBCore = exports['fdb-core']:GetCoreObject()

RegisterServerEvent('fdb-appearance:server:SaveSkin')
AddEventHandler('fdb-appearance:server:SaveSkin', function(skin, clothes, oldplayer)
    local encode = json.encode(skin)
    local encode2 = json.encode(clothes)
    local Player = FDBCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid

    if oldplayer then
        local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ?', {citizenid})

        if result and #result > 0 then
            local existingSkin = json.decode(result[1].skin)
            local existingClothes = json.decode(result[1].clothes)

            for k, v in pairs(skin) do
                existingSkin[k] = v
            end

            for k, v in pairs(clothes) do
                existingClothes[k] = v
            end

            local encodedSkin = json.encode(existingSkin)
            local encodedclothes = json.encode(existingClothes)
            MySQL.Async.execute('UPDATE playerskins SET skin = @skin, clothes = @clothes WHERE citizenid = @citizenid',
            {
                ['citizenid'] = citizenid,
                ['skin'] = encodedSkin,
                ['clothes'] = encodedclothes,
            })
        end
    else
        MySQL.Async.insert('INSERT INTO playerskins (citizenid, skin, clothes) VALUES (?, ?, ?);', { citizenid, encode, encode2 })
        TriggerClientEvent('fdb-spawn:client:setupSpawnUI', source, encode, true)
    end
end)

RegisterServerEvent('fdb-appearance:server:SetPlayerBucket')
AddEventHandler('fdb-appearance:server:SetPlayerBucket', function(b, random)
    if random then
        local BucketID = FDBCore.Shared.RandomInt(1000, 9999)
        SetRoutingBucketPopulationEnabled(BucketID, false)
        SetPlayerRoutingBucket(source, BucketID)
    else
        SetPlayerRoutingBucket(source, b)
    end
end)

RegisterServerEvent('fdb-appearance:server:LoadSkin')
AddEventHandler('fdb-appearance:server:LoadSkin', function()
    local _source = source
    local User = FDBCore.Functions.GetPlayer(source)
    local citizenid = User.PlayerData.citizenid
    local skins = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ?', {citizenid})
    if skins[1] then
        local skin = skins[1].skin
        local clothes = skins[1].clothes  -- Assuming you have a 'clothes' column in your table
        local decodedSkin = json.decode(skin)
        local decodedClothes = json.decode(clothes)
        TriggerClientEvent('fdb-appearance:client:ApplySkin', _source, decodedSkin, decodedClothes)
    else
        TriggerClientEvent('fdb-appearance:client:OpenCreator', _source)
    end
end)


RegisterServerEvent('fdb-appearance:server:deleteSkin')
AddEventHandler('fdb-appearance:server:deleteSkin', function(license)
    local _source = source
    local Player = FDBCore.Functions.GetPlayer(_source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    MySQL.Async.execute('DELETE FROM playerskins WHERE citizenid = ? AND license = ?', {citizenid, license})
end)

RegisterServerEvent('fdb-appearance:server:updategender', function(gender)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    local license = FDBCore.Functions.GetIdentifier(source, 'license')

    local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? AND license = ?', {citizenid, license})
    if not result or not result[1] then return end
    local Charinfo = json.decode(result[1].charinfo)
    Charinfo.gender = gender
    MySQL.Async.execute('UPDATE players SET `charinfo` = ? WHERE `citizenid`= ? AND `license`= ?', {json.encode(Charinfo), citizenid, license})
    Player.Functions.Save()
end)
