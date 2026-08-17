local db = exports.oxmysql
local Locks = {}
local LockIndex = {}

local function decode(data)
    if type(data) == "table" then return data end
    if not data or data == "" then return nil end
    local ok, parsed = pcall(json.decode, data)
    if ok and type(parsed) == "table" then return parsed end
    return nil
end

local function encode(tbl)
    return json.encode(tbl or {})
end

local function normalizeCharAccess(raw)
    local out = {}
    local seen = {}
    if type(raw) ~= "table" then return out end

    local function push(v)
        if v == nil then return end
        local s = tostring(v):gsub("^%s+", ""):gsub("%s+$", "")
        if s == "" then return end
        local n = tonumber(s)
        local key = n and tostring(n) or s
        if seen[key] then return end
        seen[key] = true
        out[#out + 1] = n or s
    end

    for _, v in ipairs(raw) do
        push(v)
    end
    if #out < 1 then
        for _, v in pairs(raw) do
            push(v)
        end
    end
    return out
end

local function normalizePanel(panel)
    if type(panel) ~= "table" then return nil end
    local hash = tonumber(panel.hash)
    if not hash or hash == 0 then return nil end
    local modelName = panel.modelName or panel.model_name
    if type(modelName) == "string" then
        modelName = modelName:gsub("^%s+", ""):gsub("%s+$", "")
        if modelName == "" then modelName = nil end
    else
        modelName = nil
    end
    local out = {
        hash = math.floor(hash),
        model = tonumber(panel.model) or 0,
        x = tonumber(panel.x) or 0.0,
        y = tonumber(panel.y) or 0.0,
        z = tonumber(panel.z) or 0.0,
        heading = tonumber(panel.heading) or 0.0,
    }
    if modelName then out.modelName = modelName end
    return out
end

local function normalizeCategory(raw)
    if raw == nil then return "" end
    local s = tostring(raw):gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" or s == "false" or s == "nil" then return "" end
    return s
end

local function normalizeLock(row)
    local data = decode(row.data) or {}
    local panels = {}
    for _, p in ipairs(data.panels or {}) do
        local np = normalizePanel(p)
        if np then panels[#panels + 1] = np end
    end
    if #panels < 1 then return nil end

    if not data.double and #panels > 1 then
        panels = { panels[1] }
    end

    local prompt = data.prompt or {}
    local px = tonumber(prompt.x)
    local py = tonumber(prompt.y)
    local pz = tonumber(prompt.z)
    if not px then
        px, py, pz = panels[1].x, panels[1].y, panels[1].z
    end

    local jobAccess = WVDL.JobAccessToList(data.jobAccess)
    local charAccess = normalizeCharAccess(data.charAccess)

    local accessItem = data.accessItem
    if accessItem == "false" or accessItem == "" then accessItem = false end

    local lockpickItem = data.lockpickItem
    if lockpickItem == "false" or lockpickItem == "" then lockpickItem = false end

    return {
        id = tonumber(row.id),
        name = tostring(data.name or row.name or ("Lock " .. tostring(row.id))),
        category = normalizeCategory(data.category),
        locked = data.locked == true,
        lockedOnStart = data.lockedOnStart ~= false,
        showPrompt = data.showPrompt ~= false,
        show3d = data.show3d == true,
        canLockpick = data.canLockpick == true,
        lockpickItem = lockpickItem,
        accessItem = accessItem,
        jobAccess = jobAccess,
        charAccess = charAccess,
        closedRatio = tonumber(data.closedRatio) or 0.0,
        promptRadius = tonumber(data.promptRadius) or Config.Defaults.promptRadius or 2.0,
        prompt = { x = px, y = py, z = pz },
        panels = panels,
        double = data.double == true or #panels > 1,
    }
end

local function storeLock(lock)
    if not lock or not lock.id then return end
    Locks[lock.id] = lock
    LockIndex[lock.id] = true
end

local function removeLock(id)
    id = tonumber(id)
    Locks[id] = nil
    LockIndex[id] = nil
end

local function broadcast()
    TriggerClientEvent("wasvendel_doorlock:syncAll", -1, Locks)
end

local function loadLocks(cb)
    db:query("SELECT id, name, data FROM wasvendel_doorlocks ORDER BY id ASC", {}, function(rows)
        Locks = {}
        LockIndex = {}
        for _, row in ipairs(rows or {}) do
            local lock = normalizeLock(row)
            if lock then
                local desired = lock.lockedOnStart == true
                if lock.locked ~= desired then
                    local data = decode(row.data) or {}
                    data.locked = desired
                    db:query("UPDATE wasvendel_doorlocks SET data = ? WHERE id = ?", { encode(data), lock.id })
                end
                lock.locked = desired
                storeLock(lock)
            end
        end
        if cb then cb() end
        broadcast()
    end)
end

local function rowFromPayload(payload, id)
    local panels = {}
    for _, p in ipairs(payload.panels or {}) do
        local np = normalizePanel(p)
        if np then panels[#panels + 1] = np end
    end
    if #panels < 1 then return nil, "panels" end

    if not payload.double and #panels > 1 then
        panels = { panels[1] }
    end

    local prompt = payload.prompt or {}
    if not tonumber(prompt.x) then
        prompt = { x = panels[1].x, y = panels[1].y, z = panels[1].z }
    end

    local jobAccess = WVDL.JobAccessToList(payload.jobAccess)
    local charAccess = normalizeCharAccess(payload.charAccess)

    local data = {
        name = tostring(payload.name or "Door"),
        category = normalizeCategory(payload.category),
        locked = payload.locked == true,
        lockedOnStart = payload.lockedOnStart ~= false,
        showPrompt = payload.showPrompt ~= false,
        show3d = payload.show3d == true,
        canLockpick = payload.canLockpick == true,
        lockpickItem = payload.lockpickItem,
        accessItem = payload.accessItem,
        jobAccess = jobAccess,
        charAccess = charAccess,
        closedRatio = tonumber(payload.closedRatio) or 0.0,
        promptRadius = tonumber(payload.promptRadius) or Config.Defaults.promptRadius or 2.0,
        prompt = prompt,
        panels = panels,
        double = payload.double == true or #panels > 1,
    }

    if id then
        local existing = Locks[id]
        if existing and payload.locked == nil then
            data.locked = existing.locked
        end
    else
        data.locked = data.lockedOnStart
    end

    return {
        id = id,
        name = data.name,
        data = encode(data),
        payload = data,
    }
end

CreateThread(function()
    while not WVDL_SchemaReady() do Wait(100) end
    while not WVDL.IsReady() do Wait(100) end
    Wait(300)
    loadLocks()
end)

RegisterNetEvent("wasvendel_doorlock:requestSync", function()
    local src = source
    TriggerClientEvent("wasvendel_doorlock:syncAll", src, Locks)
end)

RegisterNetEvent("wasvendel_doorlock:checkAccess", function(lockId)
    local src = source
    lockId = tonumber(lockId)
    local lock = Locks[lockId]
    local ok = false
    local reason, detail = "none", nil
    if lock then
        ok = WVDL.HasDoorAccess(src, lock)
        if not ok then
            local _, r, d = WVDL.EvaluateDoorJobAccess(src, lock)
            reason, detail = r, d
        else
            reason = "ok"
        end
    end
    TriggerClientEvent("wasvendel_doorlock:accessResult", src, lockId, ok == true, reason, detail)
end)

RegisterNetEvent("wasvendel_doorlock:requestMenu", function()
    local src = source
    if not WVDL.HasMenuAccess(src) then
        Config.Notify(src, L("noPermission"), "error")
        return
    end
    TriggerClientEvent("wasvendel_doorlock:openMenu", src, {
        locks = Locks,
        lang = Lang,
        defaults = Config.Defaults,
        categories = Config.Categories or {},
        jobPresets = Config.JobPresets or {},
    })
end)

RegisterNetEvent("wasvendel_doorlock:saveLock", function(payload)
    local src = source
    if not WVDL.HasMenuAccess(src) then
        Config.Notify(src, L("noPermission"), "error")
        return
    end
    if type(payload) ~= "table" then return end

    local id = tonumber(payload.id)
    local row, err = rowFromPayload(payload, id)
    if not row then return end

    if id then
        db:query("UPDATE wasvendel_doorlocks SET name = ?, data = ? WHERE id = ?", {
            row.name, row.data, id
        }, function()
            local lock = normalizeLock({ id = id, name = row.name, data = row.data })
            if lock then
                storeLock(lock)
                broadcast()
                Config.Notify(src, L("saved"), "success")
                TriggerClientEvent("wasvendel_doorlock:menuSaved", src, Locks)
            end
        end)
    else
        db:insert("INSERT INTO wasvendel_doorlocks (name, data) VALUES (?, ?)", {
            row.name, row.data
        }, function(insertId)
            insertId = tonumber(insertId)
            if not insertId then return end
            local lock = normalizeLock({ id = insertId, name = row.name, data = row.data })
            if lock then
                storeLock(lock)
                broadcast()
                Config.Notify(src, L("saved"), "success")
                TriggerClientEvent("wasvendel_doorlock:menuSaved", src, Locks)
            end
        end)
    end
end)

RegisterNetEvent("wasvendel_doorlock:deleteLock", function(lockId)
    local src = source
    if not WVDL.HasMenuAccess(src) then
        Config.Notify(src, L("noPermission"), "error")
        return
    end
    lockId = tonumber(lockId)
    if not lockId or not Locks[lockId] then return end
    db:query("DELETE FROM wasvendel_doorlocks WHERE id = ?", { lockId }, function()
        removeLock(lockId)
        broadcast()
        Config.Notify(src, L("deleted"), "success")
        TriggerClientEvent("wasvendel_doorlock:menuSaved", src, Locks)
    end)
end)

local function setLockState(lockId, locked)
    local lock = Locks[lockId]
    if not lock then return false end
    lock.locked = locked == true
    local data = {
        name = lock.name,
        category = lock.category or "",
        locked = lock.locked,
        lockedOnStart = lock.lockedOnStart,
        showPrompt = lock.showPrompt,
        show3d = lock.show3d,
        canLockpick = lock.canLockpick,
        lockpickItem = lock.lockpickItem,
        accessItem = lock.accessItem,
        jobAccess = lock.jobAccess,
        charAccess = lock.charAccess,
        closedRatio = lock.closedRatio,
        promptRadius = lock.promptRadius,
        prompt = lock.prompt,
        panels = lock.panels,
        double = lock.double,
    }
    db:query("UPDATE wasvendel_doorlocks SET name = ?, data = ? WHERE id = ?", {
        lock.name, encode(data), lockId
    })
    TriggerClientEvent("wasvendel_doorlock:syncOne", -1, lockId, lock.locked)
    return true
end

local function notifyDoorDenied(src, lock)
    local allowed, reason, detail = WVDL.EvaluateDoorJobAccess(src, lock)
    if reason == "low_grade" and detail then
        local msg = L("gradeTooLow")
        if type(msg) == "string" and msg:find("%%s") then
            Config.Notify(src, msg:format(tostring(detail.have), tostring(detail.need)), "error")
        else
            Config.Notify(src, (L("gradeTooLow") or "Grade too low.") .. (" (%s/%s)"):format(tostring(detail.have), tostring(detail.need)), "error")
        end
        return
    end
    Config.Notify(src, L("noAccess"), "error")
end

RegisterNetEvent("wasvendel_doorlock:toggle", function(lockId)
    local src = source
    lockId = tonumber(lockId)
    local lock = Locks[lockId]
    if not lock then return end
    if not WVDL.HasDoorAccess(src, lock) then
        notifyDoorDenied(src, lock)
        return
    end
    setLockState(lockId, not lock.locked)
end)

local lockpickSession = {}

local function clearLockpickSession(src)
    lockpickSession[src] = nil
end

RegisterNetEvent("wasvendel_doorlock:lockpickAbort", function()
    clearLockpickSession(source)
end)

local function removeLockpickItem(src, itemName, session)
    local cfg = Config.Lockpick or {}
    local item = itemName or (session and session.item) or cfg.item
    if not item or item == "" or item == false then return end
    WVDL.InvRemove(src, item, 1)
end

RegisterNetEvent("wasvendel_doorlock:lockpickFailed", function(itemName)
    local src = source
    local session = lockpickSession[src]
    clearLockpickSession(src)
    local cfg = Config.Lockpick or {}
    if cfg.removeOnFail == true then
        removeLockpickItem(src, itemName, session)
    end
end)

RegisterNetEvent("wasvendel_doorlock:lockpick", function(lockId)
    local src = source
    local session = lockpickSession[src]

    lockId = tonumber(lockId)
    local lock = Locks[lockId]
    if not lock or not lock.canLockpick then
        clearLockpickSession(src)
        return
    end
    if not lock.locked then
        clearLockpickSession(src)
        return
    end

    local required = lock.lockpickItem
    if required == false or required == "" then required = nil end
    local used = (session and session.item) or (Config.Lockpick and Config.Lockpick.item) or "lockpick"
    if required then
        if (session and session.item and tostring(required) ~= tostring(session.item)) or WVDL.InvCount(src, required) < 1 then
            Config.Notify(src, L("missingItem"), "error")
            clearLockpickSession(src)
            return
        end
    elseif used and WVDL.InvCount(src, used) < 1 then
        Config.Notify(src, L("missingItem"), "error")
        clearLockpickSession(src)
        return
    end

    local cfg = Config.Lockpick or {}
    if cfg.removeOnSuccess == true then
        removeLockpickItem(src, used, session)
    end

    setLockState(lockId, false)
    Config.Notify(src, L("lockpicked"), "success")
    clearLockpickSession(src)
end)

RegisterNetEvent("wasvendel_doorlock:startLockpickSession", function(item)
    local src = source
    if lockpickSession[src] then return end
    
    -- Verifica o inventário ANTES de iniciar o minigame
    local used = item or (Config.Lockpick and Config.Lockpick.item) or "lockpick"
    if WVDL.InvCount(src, used) < 1 then
        Config.Notify(src, L("missingItem"), "error")
        return
    end
    
    lockpickSession[src] = { item = used, at = GetGameTimer() }
    TriggerClientEvent("wasvendel_doorlock:useLockpickItem", src, used)
end)

CreateThread(function()
    while not WVDL.IsReady() do Wait(200) end
    local cfg = Config.Lockpick or {}
    local item = cfg.item
    if not item or item == false or item == "" then return end
    item = tostring(item)

    local ok = WVDL.RegisterUsableItem(item, function(src)
        src = tonumber(src)
        if not src then return end
        if lockpickSession[src] then return end
        WVDL.CloseInventory(src)
        lockpickSession[src] = { item = item, at = GetGameTimer() }
        TriggerClientEvent("wasvendel_doorlock:useLockpickItem", src, item)
    end)

    if ok then
        print(("[wasvendel_doorlock] Lockpick usable registered: %s"):format(item))
    else
        print("^3[wasvendel_doorlock]^0 Could not register lockpick usable item.")
    end
end)

AddEventHandler("playerDropped", function()
    clearLockpickSession(source)
end)

RegisterCommand(Config.Command or "doorlock", function(src)
    if src <= 0 then return end
    if not WVDL.HasMenuAccess(src) then
        Config.Notify(src, L("noPermission"), "error")
        return
    end
    TriggerClientEvent("wasvendel_doorlock:openMenu", src, {
        locks = Locks,
        lang = Lang,
        defaults = Config.Defaults,
        categories = Config.Categories or {},
        jobPresets = Config.JobPresets or {},
    })
end, false)

RegisterCommand(Config.ToggleCommand or "togglelock", function(src)
    if src <= 0 then return end
    TriggerClientEvent("wasvendel_doorlock:toggleNearest", src)
end, false)

exports("GetLocks", function() return Locks end)
exports("SetLockState", function(lockId, locked)
    return setLockState(tonumber(lockId), locked == true)
end)
