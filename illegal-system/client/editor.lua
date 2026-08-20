-- illegal-system/client/editor.lua
local isEditorOpen = false


RegisterNUICallback("startPlacement", function(data, cb)
    SetNuiFocus(false, false)
    StartPlacementCamera(data.type, data.model)
    cb('ok')
end)

RegisterNUICallback("saveStore", function(data, cb)
    -- Saves core store data
    local success, msg = lib.callback.await('illegal-system:server:SaveStore', 500, data)
    
    -- Saves risk spawns data
    if success and data.spawns then
        local spawnsSuccess, spawnsMsg = lib.callback.await('illegal-system:server:SaveStoreSpawns', 500, data.name, data.spawns)
        if spawnsSuccess then
            Bridge.Notify("Loja e Spawns salvos com sucesso!", "success")
        else
            Bridge.Notify("Erro ao salvar spawns: " .. tostring(spawnsMsg), "error")
        end
    elseif success then
        Bridge.Notify("Loja salva com sucesso!", "success")
    else
        Bridge.Notify("Erro ao salvar loja: " .. tostring(msg), "error")
    end
    cb('ok')
end)

RegisterNUICallback("closeEditor", function(data, cb)
    isEditorOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeEditor" })
    cb('ok')
end)

RegisterNUICallback("toggleCursor", function(data, cb)
    if data.enabled then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(true, false)
        SetNuiFocusKeepInput(true)
    end
    cb('ok')
end)

RegisterNUICallback("refreshStores", function(data, cb)
    local stores = lib.callback.await('illegal-system:server:GetActiveStores', 500)
    SendNUIMessage({
        action = "openEditor",
        stores = stores or {}
    })
    cb('ok')
end)

RegisterCommand("editillegal", function()
    if isEditorOpen then return end
    isEditorOpen = true
    SetNuiFocus(true, true)
    
    local stores = lib.callback.await('illegal-system:server:GetActiveStores', 500)
    SendNUIMessage({
        action = "openEditor",
        stores = stores or {}
    })
end, false)


local editorGhosts = {}

local function ClearGhosts()
    for _, entity in ipairs(editorGhosts) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
    editorGhosts = {}
end

RegisterNUICallback("clearEditorGhosts", function(data, cb)
    ClearGhosts()
    cb('ok')
end)

RegisterNUICallback("updateEditorMarkers", function(data, cb)
    ClearGhosts()
    
    local function SpawnGhost(model, coords, heading)
        local hash = GetHashKey(model)
        if not IsModelInCdimage(hash) then return end
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(0) end
        
        local isPed = string.find(model, "Townfolk") or string.find(model, "Dog") or string.find(model, "Bounty") or string.find(model, "A_M_") or string.find(model, "A_C_") or string.find(model, "G_M_") or string.find(model, "U_M_")
        
        local entity
        if isPed then
            entity = CreatePed(hash, coords.x, coords.y, coords.z - 0.95, heading, false, false, false, false)
            Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
            SetEntityAlpha(entity, 150, false)
            SetEntityCollision(entity, false, false)
            FreezeEntityPosition(entity, true)
            SetBlockingOfNonTemporaryEvents(entity, true)
            TaskStandStill(entity, -1)
        else
            entity = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, false, false, false)
            SetEntityAlpha(entity, 150, false)
            SetEntityCollision(entity, false, false)
            SetEntityHeading(entity, heading)
            FreezeEntityPosition(entity, true)
        end
        
        SetModelAsNoLongerNeeded(hash)
        table.insert(editorGhosts, entity)
    end
    
    if data.store then SpawnGhost("A_M_M_ValTownfolk_01", data.store, 0.0) end
    if data.door then SpawnGhost("p_crate01x", data.door, 0.0) end
    if data.register then SpawnGhost("p_crate01x", data.register, data.registerHeading or 0.0) end
    
    if data.spawns then
        for _, sp in ipairs(data.spawns) do
            SpawnGhost(sp.model, sp.coords, sp.heading or 0.0)
        end
    end
    
    cb('ok')
end)
