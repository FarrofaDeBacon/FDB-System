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
    
    local entityToHide = nil
    if data.mode == "adjust" then
        -- Procurar na lista local de entidades spawnadas
        local spawnKey = data.type .. '_' .. data.shopId
        if spawnedEntities and spawnedEntities[spawnKey] then
            entityToHide = spawnedEntities[spawnKey]
        end
    end
    
    exports['fdb-propeditor']:StartPlacementCamera(GetCurrentResourceName(), data.type, data.model, data.shopId, data.mode, entityToHide)
    cb('ok')
end)

RegisterNUICallback("saveStoreConfig", function(data, cb)
    TriggerServerEvent('fdb-shops:server:saveStoreConfig', data.store)
    cb('ok')
end)

RegisterNUICallback("notify", function(data, cb)
    exports['fdb-libs']:Notify(data.message, data.type or 'primary')
    cb('ok')
end)

RegisterNUICallback("requestRemoval", function(data, cb)
    local typeName = data.type
    local shopId = data.shopId

    SendNUIMessage({ action = "hideUI" })
    SetNuiFocus(false, false)

    local alert = exports['fdb-libs']:alertDialog({
        header = 'Remover Componente',
        content = ('Deseja realmente remover %s desta loja?'):format(data.label or typeName),
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        TriggerServerEvent('fdb-shops:server:removePlacement', shopId, typeName)
        
        local spawnKey = typeName .. '_' .. shopId
        if spawnedEntities and spawnedEntities[spawnKey] then
            DeleteEntity(spawnedEntities[spawnKey])
            spawnedEntities[spawnKey] = nil
        end
        
        SendNUIMessage({ action = "showUI" })
        SetNuiFocus(true, true)
        cb(true)
    else
        SendNUIMessage({ action = "showUI" })
        SetNuiFocus(true, true)
        cb(false)
    end
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
