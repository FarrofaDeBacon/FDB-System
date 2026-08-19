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

