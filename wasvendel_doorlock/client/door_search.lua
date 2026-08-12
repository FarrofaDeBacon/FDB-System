DLDoorSearch = DLDoorSearch or {}

local function round2(n)
    return math.floor((tonumber(n) or 0) * 100 + 0.5) / 100
end

local function doorTable()
    return RB_DoorHashes or doorhashes
end

local function resolveModelName(hash, modelHash, modelName)
    if type(modelName) == "string" and modelName ~= "" then
        return modelName
    end
    local list = doorTable()
    if not list then return modelName end
    hash = tonumber(hash)
    modelHash = tonumber(modelHash)
    if hash and list[hash] and type(list[hash][3]) == "string" and list[hash][3] ~= "" then
        return list[hash][3]
    end
    if modelHash then
        for _, info in pairs(list) do
            if tonumber(info[2]) == modelHash and type(info[3]) == "string" and info[3] ~= "" then
                return info[3]
            end
        end
    end
    return modelName
end

local function pushHit(hits, seen, hash, modelHash, modelName, x, y, z, dist)
    hash = tonumber(hash)
    if not hash or hash == 0 or seen[hash] then return end
    seen[hash] = true
    modelName = resolveModelName(hash, modelHash, modelName)
    hits[#hits + 1] = {
        hash = math.floor(hash),
        model = modelHash or modelName,
        modelName = modelName,
        x = round2(x),
        y = round2(y),
        z = round2(z),
        dist = round2(dist),
    }
end

function DLDoorSearch.SearchAtCoords(coords, radius)
    local hits, seen = {}, {}
    if not coords then return hits end

    local cx = coords.x + 0.0
    local cy = coords.y + 0.0
    local cz = coords.z + 0.0
    radius = tonumber(radius) or ((Config.DoorSearch and Config.DoorSearch.radius) or 3.0)
    local r2 = radius * radius

    local list = doorTable()
    if list then
        local i = 0
        for _, info in pairs(list) do
            local dx = cx - (info[4] or 0.0)
            local dy = cy - (info[5] or 0.0)
            local dz = cz - (info[6] or 0.0)
            local d2 = dx * dx + dy * dy + dz * dz
            if d2 <= r2 then
                pushHit(hits, seen, info[1], info[2], info[3], info[4], info[5], info[6], math.sqrt(d2))
            end
            i = i + 1
            if i % 120 == 0 then Wait(0) end
        end
    end

    if DoorSystemGetActive then
        local active = DoorSystemGetActive()
        if type(active) == "table" then
            for i = 1, #active do
                local row = active[i]
                if row then
                    local hash = tonumber(row[1])
                    local entity = row[2]
                    if hash and entity and entity ~= 0 and DoesEntityExist(entity) then
                        local ec = GetEntityCoords(entity)
                        local dx = cx - ec.x
                        local dy = cy - ec.y
                        local dz = cz - ec.z
                        local d2 = dx * dx + dy * dy + dz * dz
                        if d2 <= r2 then
                            pushHit(hits, seen, hash, GetEntityModel(entity), nil, ec.x, ec.y, ec.z, math.sqrt(d2))
                        end
                    end
                end
            end
        end
    end

    table.sort(hits, function(a, b) return (a.dist or 999) < (b.dist or 999) end)
    return hits
end

function DLDoorSearch.ToPanel(hit)
    if not hit or not hit.hash then return nil end
    local heading = 0.0
    local modelHash = hit.model
    if type(modelHash) == "string" then
        modelHash = GetHashKey(modelHash)
    end
    if hit.model then
        local obj = GetClosestObjectOfType(
            (hit.x or 0.0) + 0.0,
            (hit.y or 0.0) + 0.0,
            (hit.z or 0.0) + 0.0,
            2.0,
            type(hit.model) == "number" and hit.model or GetHashKey(hit.model),
            false, false, false
        )
        if obj and obj ~= 0 and DoesEntityExist(obj) then
            heading = GetEntityHeading(obj)
        end
    end
    local modelName = resolveModelName(hit.hash, modelHash, hit.modelName)
    return {
        hash = hit.hash,
        model = modelHash or hit.model,
        modelName = modelName,
        x = hit.x,
        y = hit.y,
        z = hit.z,
        heading = heading,
    }
end
