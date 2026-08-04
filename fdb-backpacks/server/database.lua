CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `backpacks` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `uid` VARCHAR(50) NOT NULL UNIQUE,
            `stash` VARCHAR(100) NOT NULL,
            `owner` VARCHAR(50) NOT NULL,
            `model` VARCHAR(50) NOT NULL,
            `coords` TEXT DEFAULT NULL,
            `rotation` FLOAT DEFAULT 0.0,
            `durability` INT DEFAULT 100,
            `state` VARCHAR(20) DEFAULT 'item',
            `metadata` TEXT DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function(result)
        print("[fdb-backpacks] Database check completed. Table 'backpacks' verified.")
    end)
end)

--- Insere uma nova mochila no banco de dados
function InsertBackpack(data)
    local coordsStr = data.coords and json.encode(data.coords) or nil
    local metadataStr = data.metadata and json.encode(data.metadata) or nil
    local insertId = MySQL.insert.await([[
        INSERT INTO backpacks (uid, stash, owner, model, coords, rotation, durability, state, metadata) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        data.uid, data.stash, data.owner, data.model, coordsStr, data.rotation or 0.0, data.durability or 100, data.state or 'item', metadataStr
    })
    return insertId
end

--- Atualiza dados de uma mochila existente
function UpdateBackpack(uid, data)
    local query = "UPDATE backpacks SET "
    local sets = {}
    local params = {}

    if data.owner ~= nil then table.insert(sets, "owner = ?"); table.insert(params, data.owner) end
    if data.model ~= nil then table.insert(sets, "model = ?"); table.insert(params, data.model) end
    if data.coords ~= nil then table.insert(sets, "coords = ?"); table.insert(params, json.encode(data.coords)) end
    if data.rotation ~= nil then table.insert(sets, "rotation = ?"); table.insert(params, data.rotation) end
    if data.durability ~= nil then table.insert(sets, "durability = ?"); table.insert(params, data.durability) end
    if data.state ~= nil then table.insert(sets, "state = ?"); table.insert(params, data.state) end
    if data.metadata ~= nil then table.insert(sets, "metadata = ?"); table.insert(params, json.encode(data.metadata)) end

    if #sets == 0 then return false end

    query = query .. table.concat(sets, ", ") .. " WHERE uid = ?"
    table.insert(params, uid)

    local rowsAffected = MySQL.update.await(query, params)
    -- print(("[fdb-backpacks Debug] UpdateBackpack uid=%s -> rowsAffected: %s"):format(uid, tostring(rowsAffected)))
    return rowsAffected and rowsAffected > 0
end

--- Obtém uma mochila pelo seu UID
function GetBackpackByUid(uid)
    local result = MySQL.single.await("SELECT * FROM backpacks WHERE uid = ?", { uid })
    if result then
        if result.coords and result.coords ~= "" then
            result.coords = json.decode(result.coords)
        end
        if result.metadata and result.metadata ~= "" then
            result.metadata = json.decode(result.metadata)
        end
    end
    return result
end

--- Deleta uma mochila pelo seu UID
function DeleteBackpack(uid)
    local rowsAffected = MySQL.update.await("DELETE FROM backpacks WHERE uid = ?", { uid })
    return rowsAffected and rowsAffected > 0
end
