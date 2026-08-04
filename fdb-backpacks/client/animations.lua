local FDBCore = exports['fdb-core']:GetCoreObject()
isBusy = false

-- Helper to freeze player input during animations
local function TogglePlayerInput(ped, freeze)
    FreezeEntityPosition(ped, freeze)
    -- Prevent combat/shooting
    DisableControlAction(0, 0x07CE1E61, freeze) -- Attack
    DisableControlAction(0, 0xF84FA74F, freeze) -- Aim
end

local function PlayCrouchScenario(ped, duration)
    local scenarioHash = GetHashKey("WORLD_HUMAN_CROUCH_INSPECT")
    TaskStartScenarioInPlace(ped, scenarioHash, duration, true)
    TogglePlayerInput(ped, true)
    
    local timer = duration
    while timer > 0 do
        if IsEntityDead(ped) then
            TogglePlayerInput(ped, false)
            ClearPedTasks(ped)
            return false
        end
        Wait(100)
        timer = timer - 100
    end
    
    ClearPedTasks(ped)
    TogglePlayerInput(ped, false)
    return true
end

-- Play Strap Adjusting Animation (used when putting backpack on back)
local function PlayAdjustStrapsAnim(ped, duration)
    local animDict = "mech_inspection@clothing@satchel"
    local animName = "action"
    
    RequestAnimDict(animDict)
    local timeout = 50
    while not HasAnimDictLoaded(animDict) and timeout > 0 do
        Wait(10)
        timeout = timeout - 1
    end
    
    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration, 31, 0, true, 0, false, 0, false)
        TogglePlayerInput(ped, true)
        
        local timer = duration
        while timer > 0 do
            if IsEntityDead(ped) then
                TogglePlayerInput(ped, false)
                ClearPedTasks(ped)
                return false
            end
            Wait(100)
            timer = timer - 100
        end
        ClearPedTasks(ped)
    else
        -- Fallback if anim dict failed to load
        Wait(duration)
    end
    
    TogglePlayerInput(ped, false)
    return true
end

-- ANIMATION FLOWS:

-- 1. Equipar (Colocar mochila do inventário nas costas)
-- O fluxo é: pegar mochila -> colocar nas costas -> ajustar alças
function PlayEquipAnimation(callback)
    if isBusy then 
        callback()
        return 
    end
    isBusy = true
    
    local ped = PlayerPedId()
    CreateThread(function()
        PlayAdjustStrapsAnim(ped, 2500)
        isBusy = false
        callback()
    end)
end

-- 2. Retirar / Colocar no chão (Mochila das costas -> agachar -> chão -> levantar)
function PlayDoffAndPlaceAnimation(callback)
    if isBusy then 
        callback()
        return 
    end
    isBusy = true
    
    local ped = PlayerPedId()
    CreateThread(function()
        PlayCrouchScenario(ped, 3000)
        isBusy = false
        callback()
    end)
end

-- 3. Vestir do chão (Agachar -> pegar mochila -> costas -> ajustar)
function PlayWearFromGroundAnimation(callback)
    if isBusy then return end
    isBusy = true
    
    local ped = PlayerPedId()
    CreateThread(function()
        -- Agacha para pegar
        local success = PlayCrouchScenario(ped, 2000)
        if success then
            -- Levanta e ajusta alças
            success = PlayAdjustStrapsAnim(ped, 2000)
        end
        isBusy = false
        if success then
            callback()
        end
    end)
end
