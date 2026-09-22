local isEditorOpen = false

RegisterNUICallback("closeEditor", function(data, cb)
    isEditorOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeEditor" })
    cb('ok')
end)

RegisterNUICallback("startPlacement", function(data, cb)
    SetNuiFocus(false, false)
    -- Using the freecam logic from illegal-system
    StartPlacementCamera(data.type, data.model, "stopPlacement", data.shopId)
    cb('ok')
end)

RegisterNUICallback("stopPlacement", function(data, cb)
    -- data.result = {x,y,z,h}, data.spawnType, data.model, data.extra (shopId)
    if data and data.result then
        local shopId = data.extra
        local type = data.spawnType
        local coords = vector3(data.result.x, data.result.y, data.result.z)
        local heading = data.result.h
        
        TriggerServerEvent('fdb-shops:server:savePlacement', shopId, type, coords, heading)
    else
        fdbLibs:Notify('Posicionamento cancelado.', 'error')
    end
    
    SetNuiFocus(true, true)
    cb('ok')
end)

RegisterNetEvent('fdb-shops:client:openEditor', function(storesData)
    if isEditorOpen then return end
    isEditorOpen = true
    SetNuiFocus(true, true)
    
    local theme = exports['fdb-libs']:GetActiveTheme()
    
    SendNUIMessage({
        action = "openEditor",
        stores = storesData or {},
        theme = theme
    })
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/editshops', 'Abre o painel visual Svelte para gerenciar lojas', {})
end)
