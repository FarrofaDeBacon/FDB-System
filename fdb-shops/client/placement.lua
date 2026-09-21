-- ============================================================
-- FDB System | fdb-shops | client/placement.lua
-- Visual Placer for Shops (Ghost Entity)
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local fdbLibs = exports['fdb-libs']

local isPlacing = false
local ghostEntity = nil
local placementShopId = nil
local placementType = nil
local placementIsPed = false
local currentHeading = 0.0

-- Raycast from player camera
local function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function GetRaycastResult()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local direction = RotationToDirection(camRot)
    local destination = vec3(camCoords.x + direction.x * 10.0, camCoords.y + direction.y * 10.0, camCoords.z + direction.z * 10.0)

    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0)
    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    return hit, endCoords
end

local function EndPlacement()
    isPlacing = false
    if ghostEntity and DoesEntityExist(ghostEntity) then
        DeleteEntity(ghostEntity)
    end
    ghostEntity = nil
    placementShopId = nil
    placementType = nil
end

RegisterNetEvent('fdb-shops:client:startPlacement', function(shopId, type, model)
    if isPlacing then EndPlacement() end
    
    placementShopId = shopId
    placementType = type
    placementIsPed = (type == 'npc')
    
    local hash = joaat(model)
    
    print('[fdb-shops] PLACER: Loading model ' .. tostring(model))
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    
    local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
    
    if placementIsPed then
        ghostEntity = CreatePed(hash, px, py, pz, 0.0, false, false, false, false)
        Citizen.InvokeNative(0x283978A15512B2FE, ghostEntity, true) -- Set ped ready
    else
        ghostEntity = CreateObjectNoOffset(hash, px, py, pz, false, false, false)
    end
    
    SetEntityAlpha(ghostEntity, 150, false)
    SetEntityCollision(ghostEntity, false, false)
    SetEntityInvincible(ghostEntity, true)
    FreezeEntityPosition(ghostEntity, true)
    
    if placementIsPed then
        SetBlockingOfNonTemporaryEvents(ghostEntity, true)
    end
    
    isPlacing = true
    currentHeading = 0.0
    
    fdbLibs:Notify('Modo Construcao: MOUSE SCROLL rotaciona, ENTER salva, BACKSPACE cancela.', 'info', 8000)
    
    CreateThread(function()
        while isPlacing do
            Wait(0)
            
            -- Disable attack/aim controls
            DisableControlAction(0, 0x07CE1E61, true) -- Attack
            DisableControlAction(0, 0xF84FA74F, true) -- Aim
            DisableControlAction(0, 0x8FFC75D6, true) -- Sprint
            
            local hit, endCoords = GetRaycastResult()
            if hit == 1 then
                if placementIsPed then
                    SetEntityCoords(ghostEntity, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
                else
                    SetEntityCoords(ghostEntity, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
                    PlaceObjectOnGroundProperly(ghostEntity)
                end
                
                SetEntityHeading(ghostEntity, currentHeading)
            end
            
            -- Mouse Scroll to rotate
            if IsControlPressed(0, 0x6319DB71) then -- Scroll up
                currentHeading = currentHeading + 2.0
                if currentHeading > 360.0 then currentHeading = currentHeading - 360.0 end
            elseif IsControlPressed(0, 0x05CA7C52) then -- Scroll down
                currentHeading = currentHeading - 2.0
                if currentHeading < 0.0 then currentHeading = currentHeading + 360.0 end
            end
            
            -- ENTER (Confirm)
            if IsControlJustPressed(0, 0xC7B5340A) then
                local saveCoords = GetEntityCoords(ghostEntity)
                
                -- Compensate for Ped Z offset natively if it's a ped
                -- In RedM, peds spawned might sink if not placed properly, but we save exact coords.
                TriggerServerEvent('fdb-shops:server:savePlacement', placementShopId, placementType, saveCoords, currentHeading)
                EndPlacement()
            end
            
            -- BACKSPACE (Cancel)
            if IsControlJustPressed(0, 0x156F7119) then
                fdbLibs:Notify('Posicionamento cancelado.', 'error')
                EndPlacement()
            end
        end
    end)
end)
