-- illegal-system/client/freecam.lua

local NATIVE_IS_RAW_KEY_DOWN = 0xD95A7387

local Config = {
    Placement = {
        surfaceProbeUp = 1.25,
        surfaceProbeDown = 8.0,
        surfaceMaxAbovePlayer = 3.0,
        cameraLookAtHeightPoint = 0.4,
        cameraFollowDistancePoint = 3.5,
        cameraFollowPitchPoint = 20.0,
        cameraFollowHeight = 0.35,
        cameraFrameShiftPoint = -0.42,
        cameraLookSensitivity = 3.5,
        cameraInvertLookX = false,
        cameraInvertLookY = false,
        startDistance = 2.5,
        groundOffset = 0.05,
        markerScale = 0.35,
        fastMultiplier = 3.0,
        moveSpeed = 2.5,
        heightStep = 1.2
    },
    PlacementControls = {
        fast = { key = 0x8FFC75D6 }, -- Shift
        moveForward = { key = 0x8FD015D8 }, -- W
        moveBack = { key = 0xD27782E3 }, -- S
        moveRight = { key = 0xB4E465B4 }, -- D
        moveLeft = { key = 0x7065027D }, -- A
        heightUp = { key = 0xDE794E3E }, -- Q (INPUT_COVER)
        heightDown = { key = 0xCEFD9220 }, -- E (INPUT_INTERACT_ANIMAL)
        snapGround = { key = 0xCF8A4ECA }, -- LAlt
        place = { key = 0xC7B5340A }, -- Enter (INPUT_FRONTEND_ACCEPT)
        cancel = { key = 0x156F7119 }, -- ESC
    }
}

local isPlacing = false
local placementPosX, placementPosY, placementPosZ = 0.0, 0.0, 0.0
local placementType = nil
local placementModel = nil
local ghostEntity = nil
local ghostHeading = 0.0

local placementFrozenPed = nil
local placementFrozenMount = nil
local placementFreezeX, placementFreezeY, placementFreezeZ = nil, nil, nil
local rawKeyState = {}
local placementCam = nil
local placementCamActive = false
local placementCamPitch, placementCamRoll, placementCamYaw = 0.0, 0.0, 0.0
local placementCamOrbitYaw = 0.0
local placementCamOrbitPitch = 18.0
local placementCamWorldYaw = 0.0
local placementCamDistance = 3.5
local placementStartMs = 0
local PLACEMENT_INPUT_GRACE_MS = 350

local LOOK_CONTROLS = {
    "INPUT_LOOK_LR",
    "INPUT_LOOK_UD",
    "INPUT_LOOK_UP_ONLY",
    "INPUT_LOOK_DOWN_ONLY",
    "INPUT_LOOK_LEFT_ONLY",
    "INPUT_LOOK_RIGHT_ONLY",
}

local function unpackVec3(a, b, c)
    if type(a) == "vector3" then return a.x, a.y, a.z end
    if type(a) == "table" and a.x ~= nil then return a.x, a.y, a.z end
    return tonumber(a) or 0.0, tonumber(b) or 0.0, tonumber(c) or 0.0
end

local function round2(n)
    return math.floor((tonumber(n) or 0) * 100 + 0.5) / 100
end

local function frameScale()
    return GetFrameTime() * 1.0
end

local function normalizeHeading(h)
    h = (tonumber(h) or 0.0) % 360.0
    if h < 0 then h = h + 360.0 end
    return h
end

local function placementInputReady()
    return (GetGameTimer() - placementStartMs) >= PLACEMENT_INPUT_GRACE_MS
end

local function ctrlPressed(hash)
    if type(hash) ~= "number" then return false end
    return IsControlPressed(0, hash) or IsDisabledControlPressed(0, hash)
end

local function ctrlJustPressed(hash)
    if type(hash) ~= "number" then return false end
    return IsControlJustPressed(0, hash) or IsDisabledControlJustPressed(0, hash)
end

local function bindHeld(bind)
    if type(bind) ~= "table" then return false end
    if bind.key and ctrlPressed(bind.key) then return true end
    return false
end

local function bindJustPressed(bind)
    if type(bind) ~= "table" then return false end
    if bind.key and ctrlJustPressed(bind.key) then return true end
    return false
end

local function bindJustPressedAfterGrace(bind)
    return bindJustPressed(bind) and placementInputReady()
end

local function enableCameraLook()
    for _, name in ipairs(LOOK_CONTROLS) do
        EnableControlAction(0, GetHashKey(name), true)
    end
    EnableControlAction(0, GetHashKey("INPUT_PC_FREE_LOOK"), true)
end

local function disablePlayerControlsForPlacement()
    DisableAllControlActions(0)
    DisableAllControlActions(1)
    DisableAllControlActions(2)
    enableCameraLook()
end

local function freezePlacementPlayer()
    local ped = PlayerPedId()
    placementFrozenPed = ped
    placementFreezeX, placementFreezeY, placementFreezeZ = unpackVec3(GetEntityCoords(ped))
    FreezeEntityPosition(ped, true)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    SetPedCanRagdoll(ped, false)
    pcall(function() ClearPedTasksImmediately(ped) end)
    if IsPedOnMount and IsPedOnMount(ped) then
        local mount = GetMount(ped)
        if mount and mount ~= 0 and DoesEntityExist(mount) then
            placementFrozenMount = mount
            FreezeEntityPosition(mount, true)
            SetEntityVelocity(mount, 0.0, 0.0, 0.0)
        end
    end
end

local function maintainPlacementPlayerLock()
    local ped = placementFrozenPed
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        ped = PlayerPedId()
        placementFrozenPed = ped
    end
    FreezeEntityPosition(ped, true)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
    if placementFreezeX then
        local cx, cy, cz = unpackVec3(GetEntityCoords(ped))
        local dx = cx - placementFreezeX
        local dy = cy - placementFreezeY
        local dz = cz - placementFreezeZ
        if (dx * dx + dy * dy + dz * dz) > 0.0025 then
            if SetEntityCoordsNoOffset then
                SetEntityCoordsNoOffset(ped, placementFreezeX, placementFreezeY, placementFreezeZ, false, false, false)
            else
                SetEntityCoords(ped, placementFreezeX, placementFreezeY, placementFreezeZ, false, false, false, false)
            end
        end
    end
    if placementFrozenMount and DoesEntityExist(placementFrozenMount) then
        FreezeEntityPosition(placementFrozenMount, true)
        SetEntityVelocity(placementFrozenMount, 0.0, 0.0, 0.0)
    end
end

local function unfreezePlacementPlayer()
    if placementFrozenMount and DoesEntityExist(placementFrozenMount) then
        FreezeEntityPosition(placementFrozenMount, false)
    end
    placementFrozenMount = nil
    if placementFrozenPed and placementFrozenPed ~= 0 and DoesEntityExist(placementFrozenPed) then
        FreezeEntityPosition(placementFrozenPed, false)
        pcall(function() SetPedCanRagdoll(placementFrozenPed, true) end)
    end
    placementFrozenPed = nil
    placementFreezeX, placementFreezeY, placementFreezeZ = nil, nil, nil
end

local function shapeTestSurfaceZ(x, y, topZ, botZ, ignoreEntity)
    ignoreEntity = ignoreEntity or PlayerPedId()
    for _ = 1, 4 do
        RequestCollisionAtCoord(x, y, (topZ + botZ) * 0.5)
        Wait(0)
    end
    local handle = StartShapeTestRay(x, y, topZ, x, y, botZ, 1 + 16 + 256, ignoreEntity, 0)
    local status, hit, endCoords = GetShapeTestResult(handle)
    local tries = 0
    while status == 1 and tries < 15 do
        Wait(0)
        status, hit, endCoords = GetShapeTestResult(handle)
        tries = tries + 1
    end
    if hit and endCoords then
        local _, _, ez = unpackVec3(endCoords)
        return ez
    end
    return nil
end

local function surfaceZAt(x, y, hintZ, ignoreEntity)
    hintZ = tonumber(hintZ) or 0.0
    ignoreEntity = ignoreEntity or PlayerPedId()
    local cfg = Config.Placement
    local probeUp = tonumber(cfg.surfaceProbeUp) or 1.25
    local probeDown = tonumber(cfg.surfaceProbeDown) or 8.0
    local maxAbovePlayer = tonumber(cfg.surfaceMaxAbovePlayer) or 3.0
    local _, _, playerZ = unpackVec3(GetEntityCoords(PlayerPedId()))

    RequestCollisionAtCoord(x, y, hintZ)
    local topZ = hintZ + probeUp
    local botZ = hintZ - probeDown
    local capTop = math.max(hintZ, playerZ) + maxAbovePlayer
    if topZ > capTop then topZ = capTop end
    if topZ <= botZ then topZ = botZ + 0.5 end

    local candidates = {}
    local function addCandidate(z)
        z = tonumber(z)
        if z then candidates[#candidates + 1] = z end
    end

    addCandidate(shapeTestSurfaceZ(x, y, topZ, botZ, ignoreEntity))
    local probeHigh = math.max(hintZ + probeUp, playerZ + 0.35)
    local probeLow = math.min(hintZ - probeDown, playerZ - probeDown)
    for z = probeHigh, probeLow, -0.45 do
        local found, gz = GetGroundZFor_3dCoord(x, y, z, false)
        if found and gz then addCandidate(gz) end
    end

    if #candidates == 0 then return hintZ end

    local best, bestScore = nil, 1e9
    for _, z in ipairs(candidates) do
        local refCap = math.max(hintZ, playerZ) + maxAbovePlayer
        if z <= hintZ + 0.45 and z <= refCap then
            local score = math.abs(z - hintZ) + math.max(0.0, z - playerZ) * 0.4
            if z <= hintZ then score = score - 0.05 end
            if score < bestScore then
                bestScore = score
                best = z
            end
        end
    end
    return best or candidates[1] or hintZ
end

local function getPlacementCamYaw()
    if placementCamActive and placementCam then
        return placementCamYaw
    end
    local _, _, rz = unpackVec3(GetGameplayCamRot(2))
    return rz
end

local function camForwardFlat()
    local z = math.rad(getPlacementCamYaw())
    return -math.sin(z), math.cos(z)
end

local function camRightFlat()
    local z = math.rad(getPlacementCamYaw())
    return math.cos(z), math.sin(z)
end

local function readPlacementLookInput()
    local axisX = GetDisabledControlNormal(0, 0xA987235F)
    local axisY = GetDisabledControlNormal(0, 0xD2047988)
    if math.abs(axisX) < 0.001 and math.abs(axisY) < 0.001 then
        axisX = GetControlNormal(0, 0xA987235F) or 0.0
        axisY = GetControlNormal(0, 0xD2047988) or 0.0
    end
    return axisX, axisY
end

local function getCameraProfile()
    local cfg = Config.Placement
    return {
        lookAtHeight = tonumber(cfg.cameraLookAtHeightPoint) or 0.4,
        followDistance = tonumber(cfg.cameraFollowDistancePoint) or 3.5,
        followPitch = tonumber(cfg.cameraFollowPitchPoint) or 20.0,
        followHeight = tonumber(cfg.cameraFollowHeight) or 0.35,
        frameShift = tonumber(cfg.cameraFrameShiftPoint) or -0.42,
    }
end

local function applyCameraFrameShift(tx, ty, tz)
    local profile = getCameraProfile()
    local shift = tonumber(profile.frameShift) or 0.0
    if math.abs(shift) < 0.001 then return tx, ty, tz end
    local yaw = math.rad(normalizeHeading(placementCamWorldYaw + placementCamOrbitYaw))
    local rx, ry = math.cos(yaw), math.sin(yaw)
    return tx + rx * shift, ty + ry * shift, tz
end

local function getPlacementFocusPos()
    local profile = getCameraProfile()
    return applyCameraFrameShift(placementPosX, placementPosY, placementPosZ + profile.lookAtHeight)
end

local function initPlacementCameraOrbit()
    local profile = getCameraProfile()
    placementCamDistance = profile.followDistance
    placementCamOrbitPitch = profile.followPitch
    placementCamOrbitYaw = 0.0

    local tx, ty, tz = getPlacementFocusPos()
    local cx, cy, cz = unpackVec3(GetGameplayCamCoord())
    local dx, dy, dz = cx - tx, cy - ty, cz - tz
    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
    if dist >= 1.0 then
        placementCamDistance = dist
        local worldYaw = math.deg(math.atan2(-dx, dy))
        if worldYaw < 0.0 then worldYaw = worldYaw + 360.0 end
        placementCamWorldYaw = worldYaw
        local horizDist = math.sqrt(dx * dx + dy * dy)
        if horizDist > 0.05 then
            placementCamOrbitPitch = math.max(-10.0, math.min(75.0, math.deg(math.atan2(dz, horizDist))))
        end
    else
        local _, _, rz = unpackVec3(GetGameplayCamRot(2))
        placementCamWorldYaw = normalizeHeading(rz + 180.0)
    end
end

local function computeFollowCamPos(tx, ty, tz)
    local profile = getCameraProfile()
    local dist = placementCamDistance
    local pitch = math.rad(placementCamOrbitPitch)
    local baseYaw = math.rad(normalizeHeading(placementCamWorldYaw + placementCamOrbitYaw))
    local horiz = dist * math.cos(pitch)
    local cx = tx + horiz * (-math.sin(baseYaw))
    local cy = ty + horiz * (math.cos(baseYaw))
    local cz = tz + dist * math.sin(pitch) + profile.followHeight
    return cx, cy, cz
end

local function startPlacementCamera()
    initPlacementCameraOrbit()
    local tx, ty, tz = getPlacementFocusPos()
    local cx, cy, cz = computeFollowCamPos(tx, ty, tz)
    local fov = GetGameplayCamFov()

    placementCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(placementCam, cx, cy, cz)
    SetCamFov(placementCam, fov)
    if PointCamAtCoord then
        PointCamAtCoord(placementCam, tx, ty, tz)
    end
    placementCamPitch, placementCamRoll, placementCamYaw = unpackVec3(GetCamRot(placementCam, 2))
    SetCamActive(placementCam, true)
    RenderScriptCams(true, true, 300, true, true, 0)
    placementCamActive = true
end

local function destroyPlacementCamera()
    if not placementCam then
        placementCamActive = false
        return
    end
    if StopCamPointing then
        pcall(function() StopCamPointing(placementCam) end)
    end
    RenderScriptCams(false, true, 300, true, true, 0)
    SetCamActive(placementCam, false)
    DestroyCam(placementCam, false)
    placementCam = nil
    placementCamActive = false
end

local function followPlacementCamera()
    if not placementCamActive or not placementCam then return end

    local cfg = Config.Placement
    local sens = tonumber(cfg.cameraLookSensitivity) or 3.5
    local axisX, axisY = readPlacementLookInput()
    if math.abs(axisX) >= 0.001 or math.abs(axisY) >= 0.001 then
        local yawSign = cfg.cameraInvertLookX == true and 1.0 or -1.0
        local pitchSign = cfg.cameraInvertLookY == true and -1.0 or 1.0
        placementCamOrbitYaw = placementCamOrbitYaw + axisX * sens * yawSign
        placementCamOrbitPitch = math.max(-10.0, math.min(75.0, placementCamOrbitPitch + axisY * sens * pitchSign))
    end

    local tx, ty, tz = getPlacementFocusPos()
    local cx, cy, cz = computeFollowCamPos(tx, ty, tz)
    SetCamCoord(placementCam, cx, cy, cz)
    if PointCamAtCoord then
        PointCamAtCoord(placementCam, tx, ty, tz)
    end
    placementCamPitch, placementCamRoll, placementCamYaw = unpackVec3(GetCamRot(placementCam, 2))
    if DisableFirstPersonCamThisFrame then
        DisableFirstPersonCamThisFrame()
    end
end

local function getPlacementStartPos()
    local ped = PlayerPedId()
    local px, py, pz = unpackVec3(GetEntityCoords(ped))
    local fx, fy = unpackVec3(GetEntityForwardVector(ped))
    local dist = Config.Placement.startDistance or 2.5
    px, py = px + fx * dist, py + fy * dist
    pz = surfaceZAt(px, py, pz) + (Config.Placement.groundOffset or 0.05)
    return px, py, pz
end

local function SpawnGhost(modelHash, isPed)
    if not IsModelInCdimage(modelHash) then
        print("[illegal-system] EDITOR ERRO: modelo " .. tostring(modelHash) .. " não existe no CD image. Fantasma não pode ser criado.")
        Bridge.Notify("Modelo inválido para preview. Veja o console (F8).", "error")
        return
    end
    RequestModel(modelHash)

    -- Antes eram só 100 tentativas de 10ms (1 segundo) -- curto demais pra
    -- modelos que ainda não foram cacheados nesta sessão. Alinhado ao mesmo
    -- timeout de 5s usado no spawn real (spawnDogRisk / armedNpcRisk).
    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        Wait(10)
        if GetGameTimer() > deadline then
            print("[illegal-system] EDITOR ERRO: modelo " .. tostring(modelHash) .. " não carregou em 5s. Fantasma não pode ser criado.")
            Bridge.Notify("Falha ao carregar o modelo do preview (timeout).", "error")
            return
        end
    end

    local pos = GetEntityCoords(PlayerPedId())
    if isPed then
        ghostEntity = CreatePed(modelHash, pos.x, pos.y, pos.z, 0.0, false, false, 0, 0)
        Citizen.InvokeNative(0x283978A15512B2FE, ghostEntity, true)
    else
        ghostEntity = CreateObject(modelHash, pos.x, pos.y, pos.z, false, false, false)
    end

    if ghostEntity and ghostEntity ~= 0 then
        SetEntityAlpha(ghostEntity, 150, false)
        SetEntityCollision(ghostEntity, false, false)
        if isPed then
            SetBlockingOfNonTemporaryEvents(ghostEntity, true)
        end
        SetEntityInvincible(ghostEntity, true)
    else
        print("[illegal-system] EDITOR ERRO: CreatePed/CreateObject retornou handle inválido para " .. tostring(modelHash))
        Bridge.Notify("Falha ao criar o preview (handle inválido).", "error")
    end
end

local function drawPointMarker()
    local cfg = Config.Placement
    local scale = tonumber(cfg.markerScale) or 0.35
    local mx, my, mz = placementPosX, placementPosY, placementPosZ
    DrawMarker(0x94FDAE17,
        mx, my, mz + 0.05,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        scale, scale, scale,
        255, 225, 138, 210,
        false, false, 2, false, nil, nil, false)
    DrawMarker(0x2A32FAA57B937173,
        mx, my, mz - 0.02,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        scale * 0.55, scale * 0.55, 0.08,
        255, 225, 138, 120,
        false, false, 2, false, nil, nil, false)

    -- Rotacionar fantasma (Setas)
    if IsDisabledControlPressed(0, 0xA65EBAB4) then ghostHeading = ghostHeading + 2.0 end
    if IsDisabledControlPressed(0, 0xDEB34313) then ghostHeading = ghostHeading - 2.0 end
    if IsDisabledControlJustPressed(0, 0xA65EBAB4) then ghostHeading = ghostHeading + 2.0 end
    if IsDisabledControlJustPressed(0, 0xDEB34313) then ghostHeading = ghostHeading - 2.0 end

    if ghostEntity then
        local zOffset = 0.0
        if IsEntityAPed(ghostEntity) then
            zOffset = 1.0
        end
        SetEntityCoordsNoOffset(ghostEntity, mx, my, mz + zOffset, false, false, false)
        SetEntityHeading(ghostEntity, ghostHeading)
    end
end

local function snapToGround()
    RequestCollisionAtCoord(placementPosX, placementPosY, placementPosZ)
    local cfg = Config.Placement
    local gz = surfaceZAt(placementPosX, placementPosY, placementPosZ, PlayerPedId())
    placementPosZ = gz + (tonumber(cfg.groundOffset) or 0.05)
end

local function handlePointInput()
    local c = Config.PlacementControls
    local p = Config.Placement
    local mult = bindHeld(c.fast) and (p.fastMultiplier or 3.0) or 1.0
    local dt = frameScale()
    local moveStep = (tonumber(p.moveSpeed) or 2.5) * dt * mult
    local fx, fy = camForwardFlat()
    local rx, ry = camRightFlat()
    local mx, my = 0.0, 0.0
    if bindHeld(c.moveForward) then mx = mx + fx; my = my + fy end
    if bindHeld(c.moveBack) then mx = mx - fx; my = my - fy end
    if bindHeld(c.moveRight) then mx = mx + rx; my = my + ry end
    if bindHeld(c.moveLeft) then mx = mx - rx; my = my - ry end
    if mx ~= 0.0 or my ~= 0.0 then
        placementPosX = placementPosX + mx * moveStep
        placementPosY = placementPosY + my * moveStep
    end
    local hStep = (tonumber(p.heightStep) or 1.2) * dt * mult
    if bindHeld(c.heightUp) then placementPosZ = placementPosZ + hStep end
    if bindHeld(c.heightDown) then placementPosZ = placementPosZ - hStep end

    -- Zoom (Scroll)
    if IsDisabledControlJustPressed(0, 0xCC1075A7) or IsDisabledControlJustPressed(0, 0x07CE1E61) then
        placementCamDistance = math.max(1.0, placementCamDistance - 0.5)
    end
    if IsDisabledControlJustPressed(0, 0x28CEB6DC) or IsDisabledControlJustPressed(0, 0xFBD7B3E6) then
        placementCamDistance = math.min(15.0, placementCamDistance + 0.5)
    end
end

local function finish(ok)
    isPlacing = false
    rawKeyState = {}
    destroyPlacementCamera()
    unfreezePlacementPlayer()
    
    if ghostEntity then
        DeleteEntity(ghostEntity)
        ghostEntity = nil
    end

    if placementModel then
        SetModelAsNoLongerNeeded(GetHashKey(placementModel))
    end

    local resultData = nil
    if ok then
        resultData = {
            x = round2(placementPosX),
            y = round2(placementPosY),
            z = round2(placementPosZ),
            h = ghostHeading
        }
    end

    SendNUIMessage({
        action = "stopPlacement",
        result = resultData,
        spawnType = placementType,
        model = placementModel
    })
    
    SetNuiFocus(true, true)
end

function StartPlacementCamera(type, model)
    if isPlacing then return false end

    placementType = type
    placementModel = model
    ghostHeading = 0.0

    unfreezePlacementPlayer()
    placementStartMs = GetGameTimer()
    rawKeyState = {}

    placementPosX, placementPosY, placementPosZ = getPlacementStartPos()

    isPlacing = true
    freezePlacementPlayer()
    startPlacementCamera()

    SendNUIMessage({ action = "startPlacement" })

    local c = Config.PlacementControls

    CreateThread(function()
        if type == "guard" or type == "dog" then
            SpawnGhost(GetHashKey(model), true)
        else
            SpawnGhost(GetHashKey(model), false)
        end

        while isPlacing do
            Wait(0)
            maintainPlacementPlayerLock()
            disablePlayerControlsForPlacement()
            handlePointInput()
            
            if bindJustPressed(c.snapGround) then
                snapToGround()
            end
            
            followPlacementCamera()
            drawPointMarker()

            if bindJustPressedAfterGrace(c.cancel) then
                finish(false)
                return
            end
            if bindJustPressedAfterGrace(c.place) then
                snapToGround()
                finish(true)
                return
            end
        end
    end)

    return true
end

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    if isPlacing then finish(false) end
end)
