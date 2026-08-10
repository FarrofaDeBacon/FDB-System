-- ============================================================
-- FDB System | fdb-clothing | server/main.lua
-- Server-side clothing persistence and logic
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
local CORE = exports['fdb-core']:GetCoreObject()

-- Helper to get charid
local function GetCharId(src)
    local Player = CORE.Functions.GetPlayer(src)
    if Player ~= nil then
        return Player.PlayerData.citizenid
    end
    return nil
end

-- fdb_clothing:GetCurrentClothes
Callback.registerServer('fdb_clothing:GetCurrentClothes', function(source, cb)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb(nil, nil) end

    -- Fetch current clothes from fdb_clothes
    MySQL.Async.fetchAll('SELECT * FROM fdb_clothes WHERE charid = @charid', {
        ['@charid'] = charid
    }, function(result)
        if result and #result > 0 then
            local datatable = json.decode(result[1].clothes)
            cb(datatable, result[1].outfit_id)
        else
            MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = @charid', {
                ['@charid'] = charid
            }, function(rsgResult)
                if rsgResult and #rsgResult > 0 then
                    local datatable = json.decode(rsgResult[1].clothes)
                    if datatable then
                        MySQL.Async.execute('INSERT INTO fdb_clothes (charid, clothes) VALUES (@charid, @clothes)', {
                            ['@charid'] = charid,
                            ['@clothes'] = rsgResult[1].clothes
                        })
                    end
                    cb(datatable, nil)
                else
                    cb(nil, nil)
                end
            end)
        end
    end)
end)

AddEventHandler("fdb_clothes:retrieveClothes", function(charid, cb)
    MySQL.Async.fetchAll('SELECT * FROM fdb_clothes WHERE charid = @charid', {
        ['@charid'] = charid
    }, function(result)
        if result and #result > 0 then
            cb(result[1])
        else
            MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = @charid', {
                ['@charid'] = charid
            }, function(rsgResult)
                if rsgResult and #rsgResult > 0 then
                    cb({
                        clothes = rsgResult[1].clothes,
                        hairs = "{}",
                        skin = rsgResult[1].skin
                    })
                else
                    cb(nil)
                end
            end)
        end
    end)
end)

-- fdb_clothing:GetOutfit
Callback.registerServer('fdb_clothing:GetOutfit', function(source, cb, outfitid)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb(nil) end

    MySQL.Async.fetchAll('SELECT clothes FROM FDB_outfits WHERE charid = @charid AND outfit_id = @outfitid', {
        ['@charid'] = charid,
        ['@outfitid'] = outfitid
    }, function(result)
        if result and #result > 0 then
            local datatable = json.decode(result[1].clothes)
            cb(datatable)
        else
            cb(nil)
        end
    end)
end)

-- fdb_clothing:SaveOutfit
Callback.registerServer('fdb_clothing:SaveOutfit', function(source, cb, data, price)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb(false, nil) end

    -- Find the next available outfit_id for this charid
    MySQL.Async.fetchAll('SELECT IFNULL(MAX(outfit_id), 0) + 1 AS next_id FROM FDB_outfits WHERE charid = @charid', {
        ['@charid'] = charid
    }, function(idResult)
        local next_id = 1
        if idResult and #idResult > 0 then
            next_id = idResult[1].next_id
        end

        local outfitName = data.name or ("Outfit " .. next_id)
        local clothesData = json.encode(data.clothes or {})
        local gender = "male" -- default, should be passed but we can default

        MySQL.Async.execute('INSERT INTO FDB_outfits (charid, outfit_id, price, name, clothes, singleitems, gender) VALUES (@charid, @outfit_id, @price, @name, @clothes, @singleitems, @gender)', {
            ['@charid'] = charid,
            ['@outfit_id'] = next_id,
            ['@price'] = price or 0,
            ['@name'] = outfitName,
            ['@clothes'] = clothesData,
            ['@singleitems'] = "{}",
            ['@gender'] = gender
        }, function(rowsChanged)
            if rowsChanged > 0 then
                -- Set as current clothes
                MySQL.Async.execute('INSERT INTO fdb_clothes (charid, clothes, outfit_id) VALUES (@charid, @clothes, @outfit_id) ON DUPLICATE KEY UPDATE clothes = @clothes, outfit_id = @outfit_id', {
                    ['@charid'] = charid,
                    ['@clothes'] = clothesData,
                    ['@outfit_id'] = next_id
                })
                cb(true, next_id)
            else
                cb(false, nil)
            end
        end)
    end)
end)

-- fdb_clothing:ModifyOutfit
Callback.registerServer('fdb_clothing:ModifyOutfit', function(source, cb, outfitid, data)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb(false) end

    local clothesData = json.encode(data.clothes or {})
    local outfitName = data.name

    local query = 'UPDATE FDB_outfits SET clothes = @clothes'
    local params = {
        ['@charid'] = charid,
        ['@outfit_id'] = outfitid,
        ['@clothes'] = clothesData
    }

    if outfitName then
        query = query .. ', name = @name'
        params['@name'] = outfitName
    end

    query = query .. ' WHERE charid = @charid AND outfit_id = @outfit_id'

    MySQL.Async.execute(query, params, function(rowsChanged)
        if rowsChanged > 0 then
            -- Update current clothes if wearing this outfit
            MySQL.Async.execute('UPDATE fdb_clothes SET clothes = @clothes WHERE charid = @charid AND outfit_id = @outfit_id', {
                ['@charid'] = charid,
                ['@clothes'] = clothesData,
                ['@outfit_id'] = outfitid
            })
            cb(true)
        else
            cb(false)
        end
    end)
end)

-- fdb_clothing:DeleteOutfit
Callback.registerServer('fdb_clothing:DeleteOutfit', function(source, cb, outfitid)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb(false) end

    MySQL.Async.execute('DELETE FROM FDB_outfits WHERE charid = @charid AND outfit_id = @outfit_id', {
        ['@charid'] = charid,
        ['@outfit_id'] = outfitid
    }, function(rowsChanged)
        if rowsChanged > 0 then
            -- Also delete from wearable
            MySQL.Async.execute('DELETE FROM FDB_wearable WHERE charid = @charid AND outfit_id = @outfit_id', {
                ['@charid'] = charid,
                ['@outfit_id'] = outfitid
            })
            -- If wearing this outfit, remove it from fdb_clothes outfit_id tracker
            MySQL.Async.execute('UPDATE fdb_clothes SET outfit_id = 0 WHERE charid = @charid AND outfit_id = @outfit_id', {
                ['@charid'] = charid,
                ['@outfit_id'] = outfitid
            })
            cb(true)
        else
            cb(false)
        end
    end)
end)

-- fdb_clothing:SaveWearable
Callback.registerServer('fdb_clothing:SaveWearable', function(source, cb, outfitid, wearableCache)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb(false) end

    local skinData = json.encode(wearableCache or {})
    outfitid = outfitid or 0

    -- Check if wearable for this outfit exists
    MySQL.Async.fetchAll('SELECT * FROM FDB_wearable WHERE charid = @charid AND outfit_id = @outfit_id', {
        ['@charid'] = charid,
        ['@outfit_id'] = outfitid
    }, function(result)
        if result and #result > 0 then
            -- Update
            MySQL.Async.execute('UPDATE FDB_wearable SET skin = @skin WHERE charid = @charid AND outfit_id = @outfit_id', {
                ['@charid'] = charid,
                ['@outfit_id'] = outfitid,
                ['@skin'] = skinData
            }, function(rowsChanged)
                cb(rowsChanged > 0)
            end)
        else
            -- Insert
            MySQL.Async.execute('INSERT INTO FDB_wearable (charid, outfit_id, skin) VALUES (@charid, @outfit_id, @skin)', {
                ['@charid'] = charid,
                ['@outfit_id'] = outfitid,
                ['@skin'] = skinData
            }, function(rowsChanged)
                cb(rowsChanged > 0)
            end)
        end
    end)
end)

-- Event to give outfit
RegisterServerEvent('fdb_clothing:GiveOutfit')
AddEventHandler('fdb_clothing:GiveOutfit', function(targetId, outfitid)
    -- Normally this gives the outfit as an item if you have an inventory system
    -- But if the client triggers Callback for GiveOutfit, let's just make it a callback
end)

Callback.registerServer('fdb_clothing:GiveOutfit', function(source, cb, outfitid)
    -- Stub for GiveOutfit via callback, usually requires inventory implementation
    cb(true)
end)

-- Event to just apply/save clothes directly without outfit
RegisterServerEvent('fdb_clothing:SaveCurrentClothes')
AddEventHandler('fdb_clothing:SaveCurrentClothes', function(clothesData, outfitid)
    local src = source
    local charid = GetCharId(src)
    if not charid then return end

    local encoded = json.encode(clothesData or {})
    outfitid = outfitid or 0

    -- Try to insert or update (requires a UNIQUE constraint on charid, which might not exist in original schema, so we do manual check)
    MySQL.Async.fetchAll('SELECT * FROM fdb_clothes WHERE charid = @charid', {
        ['@charid'] = charid
    }, function(result)
        if result and #result > 0 then
            MySQL.Async.execute('UPDATE fdb_clothes SET clothes = @clothes, outfit_id = @outfit_id WHERE charid = @charid', {
                ['@charid'] = charid,
                ['@clothes'] = encoded,
                ['@outfit_id'] = outfitid
            })
        else
            MySQL.Async.execute('INSERT INTO fdb_clothes (charid, clothes, outfit_id) VALUES (@charid, @clothes, @outfit_id)', {
                ['@charid'] = charid,
                ['@clothes'] = encoded,
                ['@outfit_id'] = outfitid
            })
        end
    end)
end)
-- fdb_clothing:GetCurrentOutfitList
Callback.registerServer('fdb_clothing:GetCurrentOutfitList', function(source, cb)
    local src = source
    local charid = GetCharId(src)
    if not charid then return cb({}) end

    MySQL.Async.fetchAll('SELECT * FROM FDB_outfits WHERE charid = @charid', {
        ['@charid'] = charid
    }, function(result)
        if result then
            local outfits = {}
            for i=1, #result do
                table.insert(outfits, {
                    name = result[i].name,
                    id = result[i].outfit_id,
                    price = result[i].price,
                    gender = result[i].gender
                })
            end
            cb(outfits)
        else
            cb({})
        end
    end)
end)

-- fdb_clothing:GetCharJob
Callback.registerServer('fdb_clothing:GetCharJob', function(source, cb)
    local src = source
    local Player = CORE.Functions.GetPlayer(src)
    if Player ~= nil then
        cb(Player.PlayerData.job.name, Player.PlayerData.job.grade.level)
    else
        cb("none", 0)
    end
end)


