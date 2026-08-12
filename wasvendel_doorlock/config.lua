Config = {}

Config.Command = "doorlock"
Config.ToggleCommand = "togglelock"

Config.MenuAccess = {
    mode = "rsg_ace",
    vorpGroups = { "admin", "superadmin", "acontroller", "manager" },
    rsgAce = { "admin", "god", "superadmin" },
    steamIds = {},
}

Config.VorpGroupSource = "user"

Config.Prompt = {
    key = 0x760A9C6F, -- G (Lock / Unlock)
    holdMs = 1200,
    radius = 2.0,
}

Config.Anim = {
    enabled = true,
    dict = "script_common@jail_cell@unlock@key",
    clip = "action",
    duration = 2500,
    prop = "p_key02x",
    propDelay = 750,
}

Config.Status3D = {
    enabled = true,
    distance = 3.0,
    lockedSprite = { dict = "generic_textures", name = "lock", r = 220, g = 60, b = 60 },
    unlockedSprite = { dict = "generic_textures", name = "lock", r = 80, g = 200, b = 90 },
}

-- Lockpick is item-only (no prompt). Use near a canLockpick door.
-- Minigame resource is optional: if resource is not started, lockpick succeeds without UI.
-- If vorp_doorlocks also registers this item, stop that resource or it will steal the use.
Config.Lockpick = {
    resource = "lockpick",
    export = "startLockpick",
    difficulty = 2,
    item = "lockpick",
    removeOnSuccess = true, -- take lockpick when minigame succeeds
    removeOnFail = true,    -- take lockpick when minigame fails
}

Config.Defaults = {
    lockedOnStart = true,
    showPrompt = true,
    show3d = false,
    canLockpick = false,
    closedRatio = 0.0,
    promptRadius = 2.0,
    doorSearchRadius = 3.0,
    category = "",
}

-- Optional door categories shown in the editor / list filter.
-- Existing locks without a category stay uncategorized (fully compatible).
Config.Categories = {
    "Bank",
    "Jail",
    "Sheriff",
    "Saloon",
    "Store",
    "House",
    "Other",
}

-- Quick-add job presets for the editor (name = job name, grade = minimum rank).
-- Use either a string job name, or { name = "...", grade = 0 }, or a group:
-- { label = "Law", jobs = { { name = "sheriff", grade = 0 }, { name = "deputy", grade = 0 } } }
Config.JobPresets = {
    { name = "sheriff", grade = 0 },
    { name = "deputy", grade = 0 },
    { name = "police", grade = 0 },
    { name = "doctor", grade = 0 },
    { name = "medic", grade = 0 },
    { name = "gunsmith", grade = 0 },
    { name = "valet", grade = 0 },
    {
        label = "Law (all)",
        jobs = {
            { name = "sheriff", grade = 0 },
            { name = "deputy", grade = 0 },
            { name = "police", grade = 0 },
        },
    },
}

Config.DoorSearch = {
    radius = 3.0,
}

Config.Placement = {
    startDistance = 2.5,
    moveSpeed = 2.5,
    heightStep = 1.2,
    fastMultiplier = 3.0,
    markerScale = 0.35,
    groundOffset = 0.05,
    surfaceProbeUp = 1.25,
    surfaceProbeDown = 8.0,
    surfaceMaxAbovePlayer = 3.0,
    followCamera = true,
    cameraLookSensitivity = 3.5,
    -- Natural look (non-inverted). Set true only if you want classic inverted mouse.
    cameraInvertLookX = false,
    cameraInvertLookY = false,
    cameraFollowHeight = 0.35,
    cameraFollowDistancePoint = 3.5,
    cameraFollowPitchPoint = 20.0,
    cameraLookAtHeightPoint = 0.4,
    cameraFrameShiftPoint = -0.42,
}

Config.PlacementControls = {
    moveForward = { rawKey = 0x57, key = 0x6319DB71 },
    moveBack    = { rawKey = 0x53, key = 0x05CA7C52 },
    moveLeft    = { rawKey = 0x41, key = 0xA65EBAB4 },
    moveRight   = { rawKey = 0x44, key = 0xDEB34313 },
    heightUp    = { rawKey = 0x51, key = 0xDE794E3E },
    heightDown  = { rawKey = 0x45, key = 0xCEFD9220 },
    snapGround  = { rawKey = 0x12, altKey = `INPUT_PC_FREE_LOOK` },
    fast        = { rawKey = 0xA0, key = `INPUT_SPRINT` },
    place       = { rawKey = 0x0D, key = 0xC7B5340A },
    cancel      = { rawKey = 0x08 },
}

Config.Notify = function(source, message, ntype)
    if not message or message == "" then return end
    ntype = ntype or "info"
    if IsDuplicityVersion() then
        if WVDL and WVDL.Notify then
            WVDL.Notify(source, message, ntype, 3500)
        else
            TriggerClientEvent("wasvendel_doorlock:notify", source, message, ntype)
        end
    else
        if Config.FrameworkKey == "VORP" and Config.Core then
            Config.Core.NotifyRightTip(message, 3500)
        elseif Config.FrameworkKey == "RSG" then
            TriggerEvent("RSGCore:Notify", message, ntype, 3500)
        end
    end
end
