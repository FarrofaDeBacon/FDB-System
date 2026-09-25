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
        if spawnedEntities and spawnedEntities[data.stationId] then
            entityToHide = spawnedEntities[data.stationId]
        end
    end
    
    local cbData = { shopId = data.shopId, stationId = data.stationId }
    exports['fdb-propeditor']:StartPlacementCamera(GetCurrentResourceName(), data.type, data.model, json.encode(cbData), data.mode, entityToHide)
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

    local alert = lib.alertDialog({
        header = 'Remover Componente',
        content = ('Deseja realmente remover %s desta loja?'):format(data.label or typeName),
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        TriggerServerEvent('fdb-shops:server:removePlacement', shopId, data.stationId)
        
        if spawnedEntities and spawnedEntities[data.stationId] then
            DeleteEntity(spawnedEntities[data.stationId])
            spawnedEntities[data.stationId] = nil
        end
        
        if shopStations then
            for i, station in ipairs(shopStations) do
                if station.id == data.stationId and station.targetZoneId then
                    exports.ox_target:removeZone(station.targetZoneId)
                end
            end
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

RegisterNUICallback("deleteStore", function(data, cb)
    local shopId = data.shopId

    SendNUIMessage({ action = "hideUI" })
    SetNuiFocus(false, false)

    local alert = lib.alertDialog({
        header = 'Excluir Loja',
        content = ('Deseja realmente EXCLUIR DEFINITIVAMENTE a loja %s?\nIsso apagará o registro e todas as posições associadas.'):format(data.label or shopId),
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        TriggerServerEvent('fdb-shops:server:deleteStore', shopId)
        
        -- Cleanup entities locally immediately
        if shopStations then
            for i, station in ipairs(shopStations) do
                if station.shop_id == shopId then
                    if spawnedEntities and spawnedEntities[station.id] then
                        DeleteEntity(spawnedEntities[station.id])
                        spawnedEntities[station.id] = nil
                    end
                    if station.targetZoneId then
                        exports.ox_target:removeZone(station.targetZoneId)
                    end
                end
            end
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

RegisterNUICallback("createNewStore", function(data, cb)
    isEditorOpen = false
    SendNUIMessage({ action = "closeEditor" })
    SetNuiFocus(false, false)
    
    local input = lib.inputDialog('Criar Nova Loja', {
        { type = 'input', label = 'ID da Loja (ex: loja_centro)', required = true },
        { type = 'input', label = 'Nome da Loja (ex: Loja do Centro)', required = true },
        { type = 'select', label = 'Template', required = true, options = {
            { value = 'general', label = 'General Store' },
            { value = 'saloon', label = 'Saloon' },
            { value = 'weapons', label = 'Gunsmith' }
        }},
        { type = 'input', label = 'Citizen ID do Dono (Opcional)', required = false }
    })

    if not input then
        ExecuteCommand('editshops')
        return cb('cancel')
    end

    local shopId = input[1]
    local label = input[2]
    local template = input[3]
    local ownerId = input[4]
    
    if ownerId == "" then ownerId = nil end

    -- Formatar o ID para remover espaços
    shopId = string.gsub(string.lower(shopId), "%s+", "_")

    TriggerServerEvent('fdb-shops:server:createShopFromUI', shopId, label, template, ownerId)
    cb('ok')
end)

AddEventHandler(GetCurrentResourceName() .. ":placementFinished", function(ok, resultData, spawnType, model, callbackDataStr)
    if ok and resultData then
        local cbData = json.decode(callbackDataStr)
        local shopId = cbData.shopId
        local stationId = cbData.stationId
        local coords = vector3(resultData.x, resultData.y, resultData.z)
        local heading = resultData.h
        
        TriggerServerEvent('fdb-shops:server:savePlacement', shopId, stationId, spawnType, coords, heading, model)
        
        -- Atualiza a NUI
        SendNUIMessage({
            action = "placementResult",
            shopId = shopId,
            stationId = stationId,
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

RegisterNetEvent('fdb-shops:client:updateStationId', function(oldTempId, newId)
    SendNUIMessage({
        action = "updateStationId",
        oldId = oldTempId,
        newId = newId
    })
    
    if spawnedEntities and spawnedEntities[oldTempId] then
        spawnedEntities[newId] = spawnedEntities[oldTempId]
        spawnedEntities[oldTempId] = nil
    end
    
    if shopStations then
        for i, station in ipairs(shopStations) do
            if station.id == oldTempId then
                station.id = newId
                break
            end
        end
    end
end)
