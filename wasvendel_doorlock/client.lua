local Locks = {}
local menuOpen = false
local menuLocked = true
local nuiFocused = false
local nativeSetNuiFocus = SetNuiFocus

local promptGroup = GetRandomIntInRange(0, 0xffffff)
local togglePrompt = nil
local accessOk = {}
local accessInfo = {}
local activeAccessId = nil
local lastAccessAt = 0
local animBusy = false

CreateThread(function()
    local function tryRsg()
        for _, resName in ipairs({ "rsg-core", "rsg_core" }) do
            if GetResourceState(resName) == "started" then
                local ok, obj = pcall(function() return exports[resName]:GetCoreObject() end)
                if not ok or type(obj) ~= "table" then
                    ok, obj = pcall(function() return exports[resName]:GetCore() end)
                end
                if ok and type(obj) == "table" then
                    Config.FrameworkKey = "RSG"
                    Config.Core = obj
                    return true
                end
            end
        end
        return false
    end

    local function tryVorp()
        if GetResourceState("vorp_core") ~= "started" then return false end
        local ok, core = pcall(function() return exports.vorp_core:GetCore() end)
        if ok and type(core) == "table" then
            Config.FrameworkKey = "VORP"
            Config.Core = core
            return true
        end
        return false
    end

    local function detect()
        if Config.FrameworkKey ~= nil then return true end
        return tryVorp() or tryRsg()
    end

    while not detect() do
        Wait(100)
    end
end)

AddEventHandler("onResourceStart", function(res)
    if Config.FrameworkKey ~= nil then return end
    if res ~= "rsg-core" and res ~= "rsg_core" and res ~= "vorp_core" then return end
    CreateThread(function()
        for _ = 1, 40 do
            if Config.FrameworkKey ~= nil then return end
            if GetResourceState("vorp_core") == "started" then
                local ok, core = pcall(function() return exports.vorp_core:GetCore() end)
                if ok and type(core) == "table" then
                    Config.FrameworkKey = "VORP"
                    Config.Core = core
                    return
                end
            end
            for _, resName in ipairs({ "rsg-core", "rsg_core" }) do
                if GetResourceState(resName) == "started" then
                    local ok, obj = pcall(function() return exports[resName]:GetCoreObject() end)
                    if not ok or type(obj) ~= "table" then
                        ok, obj = pcall(function() return exports[resName]:GetCore() end)
                    end
                    if ok and type(obj) == "table" then
                        Config.FrameworkKey = "RSG"
                        Config.Core = obj
                        return
                    end
                end
            end
            Wait(250)
        end
    end)
end)

local function loadAnimDict(dict)
    if not dict or dict == "" or HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local t = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < t do
        Wait(10)
    end
    return HasAnimDictLoaded(dict)
end

local function loadModel(model)
    local hash = type(model) == "number" and model or joaat(model)
    if HasModelLoaded(hash) then return hash end
    RequestModel(hash, false)
    local t = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < t do
        Wait(10)
    end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function playDoorKeyAnim(cb)
    if animBusy then
        if cb then cb(false) end
        return
    end

    local cfg = Config.Anim or {}
    if cfg.enabled == false then
        if cb then cb(true) end
        return
    end

    animBusy = true
    CreateThread(function()
        local ped = PlayerPedId()
        local dict = cfg.dict or "script_common@jail_cell@unlock@key"
        local clip = cfg.clip or "action"
        local duration = tonumber(cfg.duration) or 2500
        local propModel = cfg.prop or "p_key02x"
        local propDelay = tonumber(cfg.propDelay) or 750
        local prop

        local ok = loadAnimDict(dict)
        if ok then
            local coords = GetEntityCoords(ped)
            local modelHash = loadModel(propModel)
            if modelHash then
                prop = CreateObject(modelHash, coords.x, coords.y, coords.z + 0.2, false, false, false, false, false)
                local waitProp = GetGameTimer() + 1500
                while prop and prop ~= 0 and not DoesEntityExist(prop) and GetGameTimer() < waitProp do
                    Wait(0)
                end
                SetModelAsNoLongerNeeded(modelHash)
                if prop and prop ~= 0 and DoesEntityExist(prop) then
                    SetEntityVisible(prop, false)
                else
                    prop = nil
                end
            end

            pcall(function()
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, duration, 8, 0.0, true, false, false)
            end)
            if not IsEntityPlayingAnim(ped, dict, clip, 3) then
                pcall(function()
                    TaskPlayAnim(ped, dict, clip, 8.0, -8.0, duration, 8, 0.0, false, false, false, "", false)
                end)
            end
            Wait(propDelay)
            if prop and DoesEntityExist(prop) then
                SetEntityVisible(prop, true)
                local bone = -1
                pcall(function()
                    bone = GetEntityBoneIndexByName(ped, "SKEL_R_Finger12")
                end)
                if bone and bone ~= -1 then
                    pcall(function()
                        AttachEntityToEntity(
                            prop, ped, bone,
                            0.02, 0.012, -0.0085,
                            0.024, -160.0, 200.0,
                            true, true, false, true, 1, true, false, false
                        )
                    end)
                end
            end
            Wait(math.max(0, duration - propDelay))
        end

        if prop and DoesEntityExist(prop) then
            pcall(function() DetachEntity(prop, true, true) end)
            SetEntityAsNoLongerNeeded(prop)
            DeleteEntity(prop)
        end
        if HasAnimDictLoaded(dict) then
            RemoveAnimDict(dict)
        end
        pcall(function() ClearPedTasks(ped) end)
        animBusy = false
        if cb then cb(true) end
    end)
end

local function requestToggle(lockId)
    if not lockId or animBusy then return end
    playDoorKeyAnim(function()
        TriggerServerEvent("wasvendel_doorlock:toggle", lockId)
    end)
end

local function registerHash(hash)
    if not hash or hash == 0 then return end
    if IsDoorRegisteredWithSystem and IsDoorRegisteredWithSystem(hash) then return end
    Citizen.InvokeNative(0xD99229FE93B46286, hash, 1, 1, 0, 0, 0, 0)
end

local function setDoorLocked(hash, locked, closedRatio)
    if not hash or hash == 0 then return end
    registerHash(hash)
    if locked then
        local ratio = tonumber(closedRatio) or 0.0
        if DoorSystemSetOpenRatio then
            DoorSystemSetOpenRatio(hash, ratio, false, false)
        else
            Citizen.InvokeNative(0xB6E6FBA95C7324AC, hash, ratio, true)
        end
        if DoorSystemSetDoorState then
            DoorSystemSetDoorState(hash, 1, false, false)
        else
            Citizen.InvokeNative(0x6BAB9442830C7F53, hash, 1)
        end
    else
        if DoorSystemSetDoorState then
            DoorSystemSetDoorState(hash, 0, false, false)
        else
            Citizen.InvokeNative(0x6BAB9442830C7F53, hash, 0)
        end
    end
end

local function applyLockVisual(lock)
    if not lock or not lock.panels then return end
    for _, panel in ipairs(lock.panels) do
        setDoorLocked(panel.hash, lock.locked == true, lock.closedRatio)
    end
end

local function applyAllVisuals()
    for _, lock in pairs(Locks) do
        applyLockVisual(lock)
    end
end

local function applyKeepInput()
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(nuiFocused and not menuLocked)
    end
end

local function setNuiFocus(state, cursor)
    if state == nuiFocused then
        applyKeepInput()
        return
    end
    nuiFocused = state
    nativeSetNuiFocus(state, cursor == true)
    applyKeepInput()
    if state then
        CreateThread(function()
            while nuiFocused do
                Wait(0)
                DisableControlAction(0, GetHashKey("INPUT_FRONTEND_PAUSE"), true)
                DisableControlAction(0, GetHashKey("INPUT_FRONTEND_PAUSE_ALTERNATE"), true)
                DisableControlAction(0, GetHashKey("INPUT_MP_TEXT_CHAT_ALL"), true)
                DisableControlAction(0, GetHashKey("INPUT_PUSH_TO_TALK"), true)
                DisableControlAction(0, GetHashKey("INPUT_SELECT_NEXT_WEAPON"), true)
                DisableControlAction(0, GetHashKey("INPUT_SELECT_PREV_WEAPON"), true)
                DisableControlAction(0, GetHashKey("INPUT_CURSOR_SCROLL_UP"), true)
                DisableControlAction(0, GetHashKey("INPUT_CURSOR_SCROLL_DOWN"), true)
                DisableControlAction(0, GetHashKey("INPUT_OPEN_WHEEL_MENU"), true)
                DisableControlAction(0, GetHashKey("INPUT_PREV_WEAPON"), true)
                DisableControlAction(0, GetHashKey("INPUT_NEXT_WEAPON"), true)
                if menuLocked then
                    DisableControlAction(0, GetHashKey("INPUT_LOOK_LR"), true)
                    DisableControlAction(0, GetHashKey("INPUT_LOOK_UD"), true)
                    DisableControlAction(0, GetHashKey("INPUT_MOVE_LR"), true)
                    DisableControlAction(0, GetHashKey("INPUT_MOVE_UD"), true)
                    DisableControlAction(0, GetHashKey("INPUT_SPRINT"), true)
                    DisableControlAction(0, GetHashKey("INPUT_JUMP"), true)
                    DisableControlAction(0, GetHashKey("INPUT_ATTACK"), true)
                    DisableControlAction(0, GetHashKey("INPUT_AIM"), true)
                end
            end
        end)
    end
end

local function ensurePrompts()
    if togglePrompt then return end
    local cfg = Config.Prompt or {}
    togglePrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(togglePrompt, cfg.key or 0x760A9C6F)
    UiPromptSetText(togglePrompt, CreateVarString(10, "LITERAL_STRING", L("promptUnlock")))
    UiPromptSetEnabled(togglePrompt, true)
    UiPromptSetVisible(togglePrompt, true)
    UiPromptSetHoldMode(togglePrompt, cfg.holdMs or 1200)
    UiPromptSetGroup(togglePrompt, promptGroup, 0)
    UiPromptRegisterEnd(togglePrompt)
end

local lockpicking = false

local function runLockpick(cb)
    local cfg = Config.Lockpick or {}
    local res = cfg.resource or "lockpick"
    local exportName = cfg.export or "startLockpick"

    if not res or res == "" or res == false or GetResourceState(res) ~= "started" then
        cb(true)
        return
    end

    CreateThread(function()
        local tries = tonumber(cfg.difficulty) or 2
        local result
        if exportName == "startLockpick" then
            result = exports[res]:startLockpick(tries)
        else
            result = exports[res][exportName](tries)
        end
        cb(result == true)
    end)
end

local function nearestLockpickable(itemName)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local best, bestDist
    local item = itemName and tostring(itemName) or nil
    for _, lock in pairs(Locks) do
        if lock.locked and lock.canLockpick == true and lock.prompt then
            local required = lock.lockpickItem
            if required == false or required == "" or required == nil then
                required = nil
            else
                required = tostring(required)
            end
            if (not required) or (item and required == item) then
                local p = lock.prompt
                local dist = #(coords - vector3(p.x, p.y, p.z))
                local rad = tonumber(lock.promptRadius) or Config.Prompt.radius or 2.0
                if dist <= rad and (not bestDist or dist < bestDist) then
                    best = lock
                    bestDist = dist
                end
            end
        end
    end
    return best, bestDist
end

RegisterNetEvent("wasvendel_doorlock:useLockpickItem", function(itemName)
    if animBusy or menuOpen or lockpicking then return end
    local lock = nearestLockpickable(itemName)
    if not lock then
        Config.Notify(nil, L("lockpickNotNear"), "error")
        TriggerServerEvent("wasvendel_doorlock:lockpickAbort")
        return
    end

    lockpicking = true
    runLockpick(function(success)
        lockpicking = false
        if success then
            TriggerServerEvent("wasvendel_doorlock:lockpick", lock.id)
        else
            Config.Notify(nil, L("lockpickFailed"), "error")
            TriggerServerEvent("wasvendel_doorlock:lockpickFailed", itemName)
        end
    end)
end)

local function promptCompleted(prompt)
    if not prompt then return false end
    if UiPromptHasHoldModeCompleted(prompt) then return true end
    local r = Citizen.InvokeNative(0xE0F65F0640EF0617, prompt)
    return r == true or r == 1
end

local function nearestLock()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local best, bestDist
    for id, lock in pairs(Locks) do
        if lock.showPrompt ~= false and lock.prompt then
            local p = lock.prompt
            local dist = #(coords - vector3(p.x, p.y, p.z))
            local rad = tonumber(lock.promptRadius) or Config.Prompt.radius or 2.0
            if dist <= rad and (not bestDist or dist < bestDist) then
                best = lock
                bestDist = dist
            end
        end
    end
    return best, bestDist
end

local function requestAccessRefresh(lock)
    if not lock or not lock.id then return end
    local now = GetGameTimer()
    if activeAccessId == lock.id and now - lastAccessAt < 800 then return end
    activeAccessId = lock.id
    lastAccessAt = now
    TriggerServerEvent("wasvendel_doorlock:checkAccess", lock.id)
end

RegisterNetEvent("wasvendel_doorlock:accessResult", function(lockId, ok, reason, detail)
    local id = tonumber(lockId) or lockId
    accessOk[id] = ok == true
    accessInfo[id] = { reason = reason, detail = detail }
end)

local function drawStatus(lock)
    if lock.show3d ~= true then return end
    local cfg = Config.Status3D or {}
    if cfg.enabled == false then return end
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local maxDist = tonumber(cfg.distance) or 12.0
    for _, panel in ipairs(lock.panels or {}) do
        local pos = vector3(panel.x, panel.y, panel.z + 1.0)
        if #(pcoords - pos) <= maxDist then
            local onScreen, sx, sy = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
            if onScreen then
                local spr = lock.locked and cfg.lockedSprite or cfg.unlockedSprite
                if spr and spr.dict and spr.name then
                    DrawSprite(spr.dict, spr.name, sx, sy, 0.028, 0.045, 0.0, spr.r or 255, spr.g or 255, spr.b or 255, 220)
                end
            end
        end
    end
end

RegisterNetEvent("wasvendel_doorlock:syncAll", function(data)
    Locks = data or {}
    accessOk = {}
    accessInfo = {}
    applyAllVisuals()
end)

RegisterNetEvent("wasvendel_doorlock:syncOne", function(lockId, locked)
    lockId = tonumber(lockId)
    if Locks[lockId] then
        Locks[lockId].locked = locked == true
        applyLockVisual(Locks[lockId])
    end
end)

RegisterNetEvent("wasvendel_doorlock:notify", function(message, ntype)
    Config.Notify(nil, message, ntype)
end)

RegisterNetEvent("wasvendel_doorlock:openMenu", function(payload)
    menuOpen = true
    menuLocked = true
    setNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        locks = payload.locks or Locks,
        lang = payload.lang or Lang,
        defaults = payload.defaults or Config.Defaults,
        categories = payload.categories or Config.Categories or {},
        jobPresets = payload.jobPresets or Config.JobPresets or {},
    })
end)

RegisterNetEvent("wasvendel_doorlock:menuSaved", function(data)
    Locks = data or Locks
    accessOk = {}
    accessInfo = {}
    applyAllVisuals()
    SendNUIMessage({ action = "refresh", locks = Locks })
end)

RegisterNetEvent("wasvendel_doorlock:toggleNearest", function()
    local lock = nearestLock()
    if not lock then return end
    local lockKey = tonumber(lock.id) or lock.id
    if accessOk[lockKey] ~= true then
        local info = accessInfo[lockKey]
        if info and info.reason == "low_grade" and info.detail then
            local d = info.detail
            Config.Notify(nil, (L("gradeTooLow") or ""):format(tostring(d.have), tostring(d.need)), "error")
        else
            Config.Notify(nil, L("noAccess"), "error")
        end
        return
    end
    requestToggle(lockKey)
end)

RegisterNUICallback("close", function(_, cb)
    menuOpen = false
    if DLPlacement and DLPlacement.Cancel then DLPlacement.Cancel() end
    SendNUIMessage({ action = "previewMode", on = false })
    SendNUIMessage({ action = "placementHud", show = false })
    setNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("toggleLock", function(data, cb)
    menuLocked = data.locked ~= false
    applyKeepInput()
    cb("ok")
end)

RegisterNUICallback("saveLock", function(data, cb)
    local payload = data or {}
    
    if type(payload.jobAccess) == "table" then
        local jobs = {}
        for k, v in pairs(payload.jobAccess) do
            if type(v) == "table" and (v.name or v.job) then
                jobs[#jobs + 1] = {
                    name = tostring(v.name or v.job),
                    grade = tonumber(v.grade or v.minGrade or 0) or 0,
                }
            elseif type(k) == "string" and k ~= "" and type(v) ~= "table" then
                jobs[#jobs + 1] = {
                    name = k,
                    grade = tonumber(v) or 0,
                }
            elseif type(k) == "number" and type(v) == "string" then
                jobs[#jobs + 1] = { name = v, grade = 0 }
            end
        end
        payload.jobAccess = jobs
    end
    TriggerServerEvent("wasvendel_doorlock:saveLock", payload)
    cb("ok")
end)

RegisterNUICallback("deleteLock", function(data, cb)
    TriggerServerEvent("wasvendel_doorlock:deleteLock", data.id)
    cb("ok")
end)

RegisterNUICallback("getPosition", function(data, cb)
    cb("ok")
    if DLPlacement and DLPlacement.IsActive and DLPlacement.IsActive() then
        return
    end

    SendNUIMessage({ action = "previewMode", on = true })
    local restoreFocus = nuiFocused
    setNuiFocus(false, false)

    local payload = { startAtPlayer = true }
    if data and data.x ~= nil and data.y ~= nil and data.z ~= nil then
        payload.x = data.x
        payload.y = data.y
        payload.z = data.z
        payload.startAtPlayer = false
    end

    CreateThread(function()
        local ok = DLPlacement.Start(payload, function(result)
            SendNUIMessage({ action = "previewMode", on = false })
            if menuOpen and restoreFocus then
                setNuiFocus(true, true)
            end
            if result and result.ok and result.position then
                SendNUIMessage({
                    action = "position",
                    x = result.position.x,
                    y = result.position.y,
                    z = result.position.z,
                })
            end
        end)
        if not ok then
            SendNUIMessage({ action = "previewMode", on = false })
            if menuOpen and restoreFocus then
                setNuiFocus(true, true)
            end
            Config.Notify(nil, L("placementFailed"), "error")
        end
    end)
end)

RegisterNUICallback("searchDoorAtPrompt", function(data, cb)
    cb("ok")
    if DLPlacement and DLPlacement.IsActive and DLPlacement.IsActive() then
        return
    end

    local x = data and tonumber(data.x)
    local y = data and tonumber(data.y)
    local z = data and tonumber(data.z)
    if not x or not y or not z then
        Config.Notify(nil, L("doorSearchNeedPrompt"), "error")
        SendNUIMessage({ action = "doorSearch", doors = {} })
        return
    end

    local radius = tonumber(data.radius) or ((Config.DoorSearch and Config.DoorSearch.radius) or 3.0)
    local doors = DLDoorSearch.SearchAtCoords(vector3(x, y, z), radius)
    SendNUIMessage({
        action = "doorSearch",
        doors = doors or {},
        radius = radius,
    })
end)

RegisterNUICallback("captureClosed", function(data, cb)
    local ratio = 0.0
    if data.hash then
        local hash = tonumber(data.hash)
        if hash and DoorSystemGetOpenRatio then
            ratio = DoorSystemGetOpenRatio(hash) or 0.0
        end
    end
    SendNUIMessage({ action = "closedCaptured", ratio = ratio })
    Config.Notify(nil, L("captureDone"), "success")
    cb("ok")
end)

CreateThread(function()
    local dict = Config.Status3D and Config.Status3D.lockedSprite and Config.Status3D.lockedSprite.dict
    if dict then
        RequestStreamedTextureDict(dict, false)
        while not HasStreamedTextureDictLoaded(dict) do Wait(50) end
    end
end)

CreateThread(function()
    Wait(1500)
    TriggerServerEvent("wasvendel_doorlock:requestSync")
end)

CreateThread(function()
    local lastDeniedAt = 0
    local function notifyNoAccess(lockKey)
        local now = GetGameTimer()
        if now - lastDeniedAt < 2000 then return end
        lastDeniedAt = now
        local info = accessInfo[lockKey]
        if info and info.reason == "low_grade" and info.detail then
            local d = info.detail
            local msg = L("gradeTooLow")
            if type(msg) == "string" then
                Config.Notify(nil, msg:format(tostring(d.have), tostring(d.need)), "error")
                return
            end
        end
        Config.Notify(nil, L("noAccess"), "error")
    end

    while true do
        if menuOpen or animBusy or (DLPlacement and DLPlacement.IsActive and DLPlacement.IsActive()) then
            Wait(500)
        else
            local waitMs = 800
            local lock = nearestLock()
            if lock then
                ensurePrompts()
                waitMs = 0
                requestAccessRefresh(lock)
                local label = lock.locked and L("doorLocked") or L("doorUnlocked")
                UiPromptSetActiveGroupThisFrame(promptGroup, CreateVarString(10, "LITERAL_STRING", lock.name or label), 0, 0, 0, 0)

                local lockKey = tonumber(lock.id) or lock.id
                local canUse = accessOk[lockKey] == true
                local accessKnown = accessOk[lockKey] ~= nil
                UiPromptSetText(togglePrompt, CreateVarString(10, "LITERAL_STRING", lock.locked and L("promptUnlock") or L("promptLock")))
                UiPromptSetEnabled(togglePrompt, true)
                UiPromptSetVisible(togglePrompt, true)

                if promptCompleted(togglePrompt) then
                    if canUse then
                        requestToggle(lockKey)
                        Wait(600)
                    elseif accessKnown then
                        notifyNoAccess(lockKey)
                        Wait(400)
                    end
                end
            else
                activeAccessId = nil
                for id in pairs(accessOk) do
                    if not Locks[id] then
                        accessOk[id] = nil
                        accessInfo[id] = nil
                    end
                end
            end
            Wait(waitMs)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1200
        local placing = DLPlacement and DLPlacement.IsActive and DLPlacement.IsActive()
        if not menuOpen and not placing and Config.Status3D and Config.Status3D.enabled ~= false then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local maxDist = tonumber(Config.Status3D.distance) or 12.0
            for _, lock in pairs(Locks) do
                if lock.show3d and lock.panels and lock.panels[1] then
                    local p = lock.panels[1]
                    if #(coords - vector3(p.x, p.y, p.z)) <= maxDist then
                        drawStatus(lock)
                        sleep = 0
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    if togglePrompt then UiPromptDelete(togglePrompt) end
    if DLPlacement and DLPlacement.Cancel then DLPlacement.Cancel() end
    setNuiFocus(false, false)
end)

RegisterCommand(Config.Command or "doorlock", function()
    TriggerServerEvent("wasvendel_doorlock:requestMenu")
end, false)

RegisterCommand(Config.ToggleCommand or "togglelock", function()
    TriggerEvent("wasvendel_doorlock:toggleNearest")
end, false)
