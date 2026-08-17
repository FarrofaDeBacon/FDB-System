WVDL = WVDL or {}

local fw = nil
local vorpCore = nil
local rsgCore = nil
local rsgResName = nil
local ready = false

local function waitReady()
    while not ready do Wait(50) end
end

function WVDL.IsReady()
    return ready
end

function WVDL.Framework()
    return fw
end

local function norm(v)
    if v == nil then return nil end
    v = tostring(v):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if v == "" then return nil end
    return v
end

local function normSteam(v)
    if not v then return nil end
    v = string.lower(tostring(v))
    v = string.gsub(v, "^steam:", "")
    return v ~= "" and v or nil
end

local function groupInList(value, list)
    local g = norm(value)
    if not g then return false end
    for _, entry in ipairs(list or {}) do
        if g == norm(entry) then return true end
    end
    return false
end

local function getRsgCore()
    for _, resName in ipairs({ "rsg-core", "rsg_core", "fdb-core", "fdb_core" }) do
        if GetResourceState(resName) == "started" then
            local ok, obj = pcall(function() return exports[resName]:GetCoreObject() end)
            if not ok or type(obj) ~= "table" then
                ok, obj = pcall(function() return exports[resName]:GetCore() end)
            end
            if ok and type(obj) == "table" then
                rsgResName = resName
                return obj
            end
        end
    end
    return nil
end

local function getVorpCore()
    if GetResourceState("vorp_core") ~= "started" then return nil end
    local ok, c = pcall(function() return exports.vorp_core:GetCore() end)
    if ok and type(c) == "table" then return c end
    return nil
end

local function applyDetect()
    if ready then return true end
    local vorp = getVorpCore()
    if vorp then
        fw = "VORP"
        vorpCore = vorp
        ready = true
        print("[wasvendel_doorlock] Framework detected: VORP")
        return true
    end
    local rsg = getRsgCore()
    if rsg then
        fw = "RSG"
        rsgCore = rsg
        ready = true
        print(("[wasvendel_doorlock] Framework detected: RSG (%s)"):format(tostring(rsgResName or "rsg-core")))
        return true
    end
    return false
end

CreateThread(function()
    local attempts = 0
    while not ready and attempts < 800 do
        if applyDetect() then return end
        attempts = attempts + 1
        Wait(250)
    end
    if not ready then
        print("^1[wasvendel_doorlock]^0 Framework not detected (need vorp_core or rsg-core).")
    end
end)
applyDetect()

AddEventHandler("onResourceStart", function(res)
    if ready then return end
    if res ~= GetCurrentResourceName()
        and res ~= "rsg-core" and res ~= "rsg_core"
        and res ~= "fdb-core" and res ~= "fdb_core"
        and res ~= "vorp_core"
        and res ~= "rsg-inventory" and res ~= "vorp_inventory" then
        return
    end
    CreateThread(function()
        for _ = 1, 40 do
            if applyDetect() then return end
            Wait(250)
        end
    end)
end)

function WVDL.GetSteamId(src)
    src = tonumber(src)
    if not src then return nil end
    if GetPlayerIdentifierByType then
        return normSteam(GetPlayerIdentifierByType(src, "steam"))
    end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(id, 1, 6) == "steam:" then
            return normSteam(id)
        end
    end
    return nil
end

local function vorpChar(src)
    if fw ~= "VORP" or not vorpCore then return nil end
    src = tonumber(src)
    if not src then return nil end
    local user = vorpCore.getUser(src)
    if not user then return nil end
    local ch = user.getUsedCharacter
    if type(ch) ~= "table" then return nil end
    if ch.job == nil and ch.Job == nil and ch.charIdentifier == nil and ch.CharIdentifier == nil then
        return nil
    end
    return ch
end

local function charJobGrade(ch, src)
    local g = nil
    if ch then
        g = ch.jobGrade
        if g == nil then g = ch.JobGrade end
        if g == nil then g = ch.jobgrade end
        if g == nil then g = ch.Grade end
        if type(g) == "function" then
            local ok, v = pcall(g, ch)
            if ok then g = v end
        end
        if type(ch.Jobgrade) == "function" then
            local ok, v = pcall(ch.Jobgrade)
            if ok and v ~= nil then g = v end
        end
        g = tonumber(g)
        if g ~= nil then return g end
    end

    
    src = tonumber(src)
    if src then
        local st = Player(src) and Player(src).state and Player(src).state.Character
        if st then
            local sg = tonumber(st.Grade or st.jobGrade or st.JobGrade)
            if sg ~= nil then return sg end
        end
    end
    return 0
end

local function charJobName(ch, src)
    if ch then
        local n = ch.job or ch.Job
        if n and tostring(n) ~= "" then return n end
    end
    src = tonumber(src)
    if src then
        local st = Player(src) and Player(src).state and Player(src).state.Character
        if st then return st.Job or st.job end
    end
    return nil
end

local function rsgPlayer(src)
    waitReady()
    if fw ~= "RSG" or not rsgCore or not rsgCore.Functions then return nil end
    src = tonumber(src)
    if not src then return nil end
    local ok, player = pcall(function()
        return rsgCore.Functions.GetPlayer(src)
    end)
    if ok then return player end
    return nil
end

local function rsgJobGrade(job)
    if type(job) ~= "table" then return 0 end
    local grade = job.grade
    if type(grade) == "table" then
        return tonumber(grade.level or grade.grade or grade.rank) or 0
    end
    return tonumber(grade) or 0
end

local function playerJobs(src)
    waitReady()
    local list = {}

    local function push(name, grade)
        local n = norm(name)
        if not n then return end
        list[#list + 1] = { name = n, grade = tonumber(grade) or 0 }
    end

    if fw == "VORP" then
        local ch = vorpChar(src)
        local jobName = charJobName(ch, src)
        local jobGrade = charJobGrade(ch, src)
        
        if ch then
            if ch.job ~= nil then jobName = ch.job end
            if ch.jobGrade ~= nil then jobGrade = tonumber(ch.jobGrade) or jobGrade end
        end
        push(jobName, jobGrade)
    elseif fw == "RSG" then
        local Player = rsgPlayer(src)
        local pd = Player and Player.PlayerData
        if pd and type(pd.job) == "table" then
            push(pd.job.name, rsgJobGrade(pd.job))
        end
    end

    return list
end

local function normalizeJobAccess(raw)
    local out = {}
    if type(raw) ~= "table" then return out end

    local function setJob(name, grade)
        name = norm(name)
        if not name then return end
        local g = tonumber(grade)
        if g == nil then g = 0 end
        if out[name] == nil or g > out[name] then
            out[name] = g
        end
    end

    
    local arrayLen = #raw
    if arrayLen > 0 then
        for i = 1, arrayLen do
            local entry = raw[i]
            if type(entry) == "table" then
                setJob(entry.name or entry.job or entry[1], entry.grade or entry.minGrade or entry.rank or entry[2] or 0)
            elseif type(entry) == "string" then
                setJob(entry, 0)
            end
        end
        return out
    end

    
    for k, v in pairs(raw) do
        if type(v) == "table" then
            if v.name or v.job then
                setJob(v.name or v.job, v.grade or v.minGrade or v.rank or 0)
            elseif type(k) == "string" then
                setJob(k, v.grade or v.minGrade or v.rank or v.level or 0)
            end
        elseif type(k) == "string" then
            setJob(k, v)
        end
    end

    return out
end

function WVDL.NormalizeJobAccess(raw)
    return normalizeJobAccess(raw)
end

function WVDL.JobAccessToList(raw)
    local map = normalizeJobAccess(raw)
    local list = {}
    for name, grade in pairs(map) do
        list[#list + 1] = { name = name, grade = tonumber(grade) or 0 }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

local function evaluateJobAccess(src, jobs)
    if type(jobs) ~= "table" or not next(jobs) then
        return false, "none", nil
    end
    local playerList = playerJobs(src)
    local matchedJob = false
    local best = nil
    for i = 1, #playerList do
        local pj = playerList[i]
        local minGrade = jobs[pj.name]
        if minGrade ~= nil then
            matchedJob = true
            local need = tonumber(minGrade) or 0
            local have = tonumber(pj.grade) or 0
            best = { job = pj.name, have = have, need = need }
            if have >= need then
                return true, "ok", best
            end
        end
    end
    if matchedJob and best then
        return false, "low_grade", best
    end
    return false, "no_job", best
end

local function matchesJobAccess(src, jobs)
    local ok = evaluateJobAccess(src, jobs)
    return ok == true
end

function WVDL.EvaluateDoorJobAccess(src, lock)
    local jobs = normalizeJobAccess(lock and lock.jobAccess)
    return evaluateJobAccess(src, jobs)
end

local function vorpGroup(src)
    if fw ~= "VORP" or not vorpCore then return nil end
    local user = vorpCore.getUser(src)
    if not user then return nil end
    local mode = Config.VorpGroupSource or "user"
    if mode == "character" then
        local ch = user.getUsedCharacter
        return ch and (ch.group or ch.Group)
    end
    return user.getGroup or user.group
end

local function rsgHasPermission(src, list)
    waitReady()
    src = tonumber(src)
    if not src or src <= 0 or type(list) ~= "table" or #list < 1 then return false end
    if fw ~= "RSG" or not rsgCore or not rsgCore.Functions then return false end

    local Fn = rsgCore.Functions
    if Fn.HasPermission then
        local ok, allowed = pcall(function() return Fn.HasPermission(src, list) end)
        if ok and allowed then return true end
        for _, ag in ipairs(list) do
            ok, allowed = pcall(function() return Fn.HasPermission(src, ag) end)
            if ok and allowed then return true end
        end
    end

    for _, ag in ipairs(list) do
        local p = norm(ag)
        if p then
            if IsPlayerAceAllowed(src, p) then return true end
            if IsPlayerAceAllowed(src, "rsgcore." .. p) then return true end
            if IsPlayerAceAllowed(src, "group." .. p) then return true end
        end
    end

    if Fn.GetPermission then
        local ok, perms = pcall(function() return Fn.GetPermission(src) end)
        if ok and type(perms) == "table" then
            for key, allowed in pairs(perms) do
                if allowed == true and groupInList(key, list) then return true end
            end
        end
    end

    local Player = rsgPlayer(src)
    local pd = Player and Player.PlayerData
    if pd then
        if groupInList(pd.group, list) then return true end
        if groupInList(pd.permission, list) then return true end
        if type(pd.permissions) == "table" then
            for key, allowed in pairs(pd.permissions) do
                if allowed == true and groupInList(key, list) then return true end
                if type(key) == "number" and groupInList(allowed, list) then return true end
            end
        end
    end

    return false
end

function WVDL.HasMenuAccess(src)
    waitReady()
    src = tonumber(src)
    if not src or src <= 0 then return false end
    local cfg = Config.MenuAccess or {}
    local mode = cfg.mode or "vorp_group"

    
    if fw == "RSG" and mode == "vorp_group" then
        mode = "rsg_ace"
    end

    if mode == "steam" then
        local steam = WVDL.GetSteamId(src)
        if not steam then return false end
        for _, entry in ipairs(cfg.steamIds or {}) do
            if steam == normSteam(entry) then return true end
        end
        return false
    end

    if mode == "rsg_ace" or fw == "RSG" then
        local list = cfg.rsgAce
        if type(list) ~= "table" or #list < 1 then
            list = cfg.vorpGroups or {}
        end
        return rsgHasPermission(src, list)
    end

    if fw == "VORP" then
        local groups = cfg.vorpGroups or {}
        if groupInList(vorpGroup(src), groups) then return true end
        local ch = vorpChar(src)
        if ch and groupInList(ch.group or ch.Group, groups) then return true end
    end
    return false
end

function WVDL.JobOf(src)
    local jobs = playerJobs(src)
    return jobs[1] and jobs[1].name or nil
end

function WVDL.JobGrade(src)
    local jobs = playerJobs(src)
    return jobs[1] and jobs[1].grade or 0
end

function WVDL.CharId(src)
    waitReady()
    src = tonumber(src)
    if fw == "VORP" then
        local ch = vorpChar(src)
        return ch and tonumber(ch.charIdentifier or ch.CharIdentifier)
    end
    if fw == "RSG" then
        local Player = rsgPlayer(src)
        local pd = Player and Player.PlayerData
        return pd and pd.citizenid or nil
    end
    return nil
end

function WVDL.InvCount(src, item)
    waitReady()
    src = tonumber(src)
    if not src or not item or item == "" then return 0 end

    local Player = rsgPlayer(src)
    if Player and Player.Functions and Player.Functions.GetItemByName then
        local ok, it = pcall(function() return Player.Functions.GetItemByName(item) end)
        if ok and type(it) == "table" then
            local count = tonumber(it.amount or it.count or it.quantity) or 0
            if count > 0 then return count end
        end
    end

    if GetResourceState("fdb-inventory") == "started" then
        local ok, n = pcall(function() return exports["fdb-inventory"]:GetItemCount(src, item) end)
        if ok and n ~= nil then return tonumber(n) or 0 end
    end
    if GetResourceState("rsg-inventory") == "started" then
        local ok, n = pcall(function() return exports["rsg-inventory"]:GetItemCount(src, item) end)
        if ok and n ~= nil then return tonumber(n) or 0 end
    end
    
    if Player and Player.Functions and Player.Functions.HasItem then
        local ok, has = pcall(function() return Player.Functions.HasItem(item, 1) end)
        if ok and has then return 1 end
    end
    
    return 0
end

RegisterCommand("testinv", function(source, args)
    local src = args[1] and tonumber(args[1]) or source
    if src == 0 then src = 1 end
    local item = args[2] or "lockpick"
    print("TestInvCount for src " .. tostring(src) .. " item " .. tostring(item) .. " = " .. tostring(WVDL.InvCount(src, item)))
end, true)

    if GetResourceState("vorp_inventory") ~= "started" then return 0 end
    local done, count = false, 0
    pcall(function()
        exports.vorp_inventory:getItemCount(src, function(c) count = tonumber(c) or 0; done = true end, item)
    end)
    local t = GetGameTimer() + 2500
    while not done and GetGameTimer() < t do Wait(0) end
    return count
end

function WVDL.InvRemove(src, item, amount)
    waitReady()
    src = tonumber(src)
    amount = tonumber(amount) or 1
    if not src or not item or item == "" then return false end

    if GetResourceState("fdb-inventory") == "started" then
        local ok, res = pcall(function()
            return exports["fdb-inventory"]:RemoveItem(src, item, amount)
        end)
        if ok and res ~= false then return true end
    end
    if GetResourceState("rsg-inventory") == "started" then
        local ok, res = pcall(function()
            return exports["rsg-inventory"]:RemoveItem(src, item, amount, nil, "wasvendel_doorlock")
        end)
        if ok and res ~= false then return true end
    end
    local Player = rsgPlayer(src)
    if Player and Player.Functions and Player.Functions.RemoveItem then
        local ok, res = pcall(function() return Player.Functions.RemoveItem(item, amount) end)
        return ok and res ~= false
    end

    if GetResourceState("vorp_inventory") ~= "started" then return false end
    local done, ok2 = false, false
    pcall(function()
        exports.vorp_inventory:subItem(src, item, amount, nil, function(s) ok2 = s == true; done = true end)
    end)
    local t = GetGameTimer() + 2500
    while not done and GetGameTimer() < t do Wait(0) end
    return ok2
end

function WVDL.HasDoorAccess(src, lock)
    waitReady()
    src = tonumber(src)
    if not src or not lock then return false end

    local jobs = normalizeJobAccess(lock.jobAccess)
    local chars = lock.charAccess or {}
    if type(chars) ~= "table" then chars = {} end

    local item = lock.accessItem
    if item == "false" or item == "" then item = false end

    local hasJobRestriction = next(jobs) ~= nil
    local hasCharRestriction = false
    if type(chars) == "table" then
        if #chars > 0 then
            hasCharRestriction = true
        else
            for _ in pairs(chars) do
                hasCharRestriction = true
                break
            end
        end
    end
    local hasItemRestriction = item and item ~= false and item ~= ""

    if not hasJobRestriction and not hasCharRestriction and not hasItemRestriction then
        return true
    end

    if hasJobRestriction and matchesJobAccess(src, jobs) then
        return true
    end

    if hasCharRestriction then
        local cid = WVDL.CharId(src)
        if cid ~= nil then
            for _, entry in pairs(chars) do
                if tostring(entry) == tostring(cid) then return true end
            end
        end
    end

    if hasItemRestriction and WVDL.InvCount(src, item) > 0 then
        return true
    end

    return false
end

function WVDL.Notify(src, message, ntype, ms)
    if not message or message == "" then return end
    src = tonumber(src)
    ntype = ntype or "info"
    ms = tonumber(ms) or 3500
    if not src then return end

    if GetResourceState("fdb-libs") == "started" then
        pcall(function() exports['fdb-libs']:Notify(src, message, ntype) end)
        return
    end

    if fw == "RSG" then
        TriggerClientEvent("RSGCore:Notify", src, message, ntype, ms)
        return
    end

    TriggerClientEvent("wasvendel_doorlock:notify", src, message, ntype)
end

function WVDL.CloseInventory(src)
    waitReady()
    src = tonumber(src)
    if not src then return end
    if fw == "VORP" and GetResourceState("vorp_inventory") == "started" then
        pcall(function() exports.vorp_inventory:closeInventory(src) end)
    elseif fw == "RSG" and GetResourceState("rsg-inventory") == "started" then
        pcall(function() exports["rsg-inventory"]:CloseInventory(src) end)
    end
end

function WVDL.RegisterUsableItem(item, cb)
    waitReady()
    if not item or item == "" or item == false or type(cb) ~= "function" then return false end
    item = tostring(item)

    if fw == "VORP" and GetResourceState("vorp_inventory") == "started" then
        local ok = pcall(function()
            exports.vorp_inventory:registerUsableItem(item, function(data)
                cb(data and data.source or data, item, data)
            end, GetCurrentResourceName())
        end)
        return ok
    end

    if fw == "RSG" and rsgCore and rsgCore.Functions and rsgCore.Functions.CreateUseableItem then
        local ok = pcall(function()
            rsgCore.Functions.CreateUseableItem(item, function(source, usedItem)
                cb(source, item, usedItem)
            end)
        end)
        return ok
    end

    return false
end
