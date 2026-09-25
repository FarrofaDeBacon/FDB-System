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

    local alert = lib.alertDialog({
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
        
        if shopStations then
            for i, station in ipairs(shopStations) do
                if station.shop_id == shopId and station.type == typeName and station.targetZoneId then
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
        local types = {'registradora', 'bau', 'npc', 'admin_panel'}
        for _, t in ipairs(types) do
            local spawnKey = t .. '_' .. shopId
            if spawnedEntities and spawnedEntities[spawnKey] then
                DeleteEntity(spawnedEntities[spawnKey])
                spawnedEntities[spawnKey] = nil
            end
        end
        
        if shopStations then
            for i, station in ipairs(shopStations) do
                if station.shop_id == shopId and station.targetZoneId then
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
