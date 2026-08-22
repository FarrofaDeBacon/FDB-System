local currentNodeType = nil
local currentNodeData = nil
local currentNodeToken = nil
local currentZoneId = nil
local registeredTriggers = {}

CreateThread(function()
    Wait(2000) -- Wait for Bridge/Server to be ready
    local triggers = lib.callback.await('node_engine:server:GetGlobalTriggers', 100)
    if triggers and triggers.models then
        for _, trigger in ipairs(triggers.models) do
            local options = {
                {
                    name = 'node_trigger_' .. trigger.heistId .. '_' .. trigger.nodeId,
                    icon = trigger.icon,
                    label = trigger.label,
                    distance = trigger.distance,
                    onSelect = function(data)
                        local entity = data.entity
                        if not DoesEntityExist(entity) then return end
                        
                        local model = GetEntityModel(entity)
                        local coords = GetEntityCoords(entity)
                        
                        TriggerServerEvent('node_engine:server:TriggerModelInteracted', trigger.heistId, trigger.nodeId, model, coords)
                    end
                }
            }
            Bridge.RegisterTargetModel(trigger.models, options)
            table.insert(registeredTriggers, trigger)
        end
        print(("[NodeEngine] Registrados %d gatilhos globais de modelo."):format(#triggers.models))
    end
end)

RegisterNetEvent('node_engine:client:StartNodeAction', function(type, data, token)
    print("[NodeEngine Debug] Recebido StartNodeAction. Tipo: " .. tostring(type))
    currentNodeType = type
    currentNodeData = data
    currentNodeToken = token

    if currentZoneId then
        exports.ox_target:removeZone(currentZoneId)
        currentZoneId = nil
    end

    if type == "open_door" or type == "crack_register" then
        print("[NodeEngine Debug] Criando ox_target zone para: " .. type)
        currentZoneId = exports.ox_target:addSphereZone({
            coords = data.coords,
            radius = 1.5,
            debug = true, -- Exibe a zona visível para facilitar o teste da Fase 1
            options = {
                {
                    name = 'node_action',
                    label = data.prompt or "Interagir",
                    icon = "fas fa-hand",
                    onSelect = function()
                        -- Removemos o target instantaneamente para evitar spam
                        exports.ox_target:removeZone(currentZoneId)
                        currentZoneId = nil
                        
                        local minTime = (data.minTime or 1) * 1000
                        lib.showTextUI("Executando...")
                        Wait(minTime + 500)
                        lib.hideTextUI()
                        
                        TriggerServerEvent('node_engine:server:ReportNodeCompletion', currentNodeToken, { success = true })
                    end
                }
            }
        })
    elseif type == "minigame_action" then
        CreateThread(function()
            local ped = PlayerPedId()
            local minTime = (data.minTime or 1) * 1000
            local propObj = nil
            
            -- Animação opcional
            if data.animDict and data.animName and data.animDict ~= "" then
                RequestAnimDict(data.animDict)
                while not HasAnimDictLoaded(data.animDict) do Wait(10) end
                
                if data.propModel and data.propModel ~= "" then
                    local propHash = GetHashKey(data.propModel)
                    RequestModel(propHash)
                    while not HasModelLoaded(propHash) do Wait(10) end
                    
                    propObj = CreateObject(propHash, 0, 0, 0, true, true, false)
                    local boneIndex = GetEntityBoneIndexByName(ped, data.boneName or "SKEL_R_Hand")
                    -- Valores default ou customizados (ideal seria expor no UI se for flexível demais)
                    AttachEntityToEntity(propObj, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                end
                
                TaskPlayAnim(ped, data.animDict, data.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
            
            local result = { success = true, tier = "common" }
            -- Minigame (tierbar por padrão, se houver)
            if data.minigameType and data.minigameType ~= "" and data.minigameType ~= "none" then
                -- Duração em ms
                local duration = data.minigameDuration or 5000
                result = exports['fdb-libs']:StartMinigame(data.minigameType, {
                    duration = duration,
                    -- Passa imagens genéricas se for tierbar
                    images = {
                        common = "nui://fdb-libs/ui/public/img/items/unknown.png",
                        uncommon = "nui://fdb-libs/ui/public/img/items/unknown.png",
                        rare = "nui://fdb-libs/ui/public/img/items/unknown.png"
                    },
                    zones = { 30, 20, 10 } -- Default zones
                })
            else
                Wait(minTime)
            end
            
            ClearPedTasks(ped)
            if propObj and DoesEntityExist(propObj) then
                DeleteEntity(propObj)
            end
            
            TriggerServerEvent('node_engine:server:ReportNodeCompletion', currentNodeToken, result)
        end)
    end
end)

RegisterNetEvent('node_engine:client:SpawnProp', function(modelName, entityCoords, offsetZ, offsetForward)
    CreateThread(function()
        local hash = GetHashKey(modelName)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(10) end
        
        local ped = PlayerPedId()
        local pedHeading = GetEntityHeading(ped)
        local rad = math.rad(pedHeading)
        
        -- Spawn na coordenada fornecida + offset
        local spawnX = entityCoords.x + (math.sin(-rad) * (offsetForward or 0.0))
        local spawnY = entityCoords.y + (math.cos(-rad) * (offsetForward or 0.0))
        local spawnZ = entityCoords.z + (offsetZ or 0.0)
        
        local obj = CreateObject(hash, spawnX, spawnY, spawnZ, true, true, false)
        PlaceObjectOnGroundProperly(obj)
        SetEntityHeading(obj, pedHeading)
        SetModelAsNoLongerNeeded(hash)
    end)
end)

RegisterNetEvent('node_engine:client:EndSession', function()
    currentNodeType = nil
    currentNodeData = nil
    currentNodeToken = nil
    if currentZoneId then
        exports.ox_target:removeZone(currentZoneId)
        currentZoneId = nil
    end
    print("[NodeEngine] Sessão concluída com sucesso.")
end)

RegisterCommand('heistdebugc', function()
    print("=== HEIST DEBUG CLIENT ===")
    print("currentNodeType: " .. tostring(currentNodeType))
    print("currentNodeToken: " .. tostring(currentNodeToken))
end, false)

RegisterCommand('startheist', function(source, args)
    local heistId = args[1] or 'test_heist_isolated'
    print("[NodeEngine Debug] Enviando pedido de StartHeist para o servidor. ID: " .. tostring(heistId))
    TriggerServerEvent("node_engine:server:ForceStartHeist", heistId)
end, false)
