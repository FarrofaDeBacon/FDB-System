local isEditorOpen = false

RegisterNUICallback("closeEditor", function(data, cb)
    isEditorOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeEditor" })
    cb('ok')
end)

RegisterNUICallback("startPlacement", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "hideUI" })
    exports['fdb-propeditor']:StartPlacementCamera(GetCurrentResourceName(), data.type, data.model, data.shopId)
    cb('ok')
end)

AddEventHandler(GetCurrentResourceName() .. ":placementFinished", function(ok, resultData, spawnType, model, callbackData)
    if ok and resultData then
        local shopId = callbackData
        local coords = vector3(resultData.x, resultData.y, resultData.z)
        local heading = resultData.h
        
        TriggerServerEvent('fdb-shops:server:savePlacement', shopId, spawnType, coords, heading)
        
        -- Atualiza a NUI
        SendNUIMessage({
            action = "placementResult",
            shopId = shopId,
            spawnType = spawnType,
            result = resultData
        })
    else
        -- Bridge.Notify não está no escopo, então usar lib (ou print, ou NUI)
        print("Posicionamento cancelado ou sem permissão.")
    end
    
    SendNUIMessage({ action = "showUI" })
    SetNuiFocus(true, true)
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
