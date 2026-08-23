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
        print("[NodeEngine DEBUG] *** ENTRANDO no branch minigame_action ***")
        CreateThread(function()
            print("[NodeEngine DEBUG] *** DENTRO do CreateThread ***")
            local ped = PlayerPedId()
            local minTime = (data.minTime or 1) * 1000
            local propObj = nil
            
            -- Animacao opcional
            if data.animDict and data.animName and data.animDict ~= "" then
                RequestAnimDict(data.animDict)
                local timeout = 50
                while not HasAnimDictLoaded(data.animDict) and timeout > 0 do 
                    Wait(100)
                    timeout = timeout - 1
                end
                
                if timeout <= 0 then
                    print("[NodeEngine] AVISO: Dicionario de animacao nao pode ser carregado: " .. tostring(data.animDict))
                else
                    if data.propModel and data.propModel ~= "" then
                        local propHash = GetHashKey(data.propModel)
                        RequestModel(propHash)
                        local pTimeout = 50
                        while not HasModelLoaded(propHash) and pTimeout > 0 do 
                            Wait(100)
                            pTimeout = pTimeout - 1
                        end
                        if HasModelLoaded(propHash) then
                            propObj = CreateObject(propHash, 0, 0, 0, true, true, false)
                            local boneIndex = GetEntityBoneIndexByName(ped, data.boneName or "SKEL_R_Hand")
                            local ox = tonumber(data.attachOffsetX) or 0.0
                            local oy = tonumber(data.attachOffsetY) or 0.0
                            local oz = tonumber(data.attachOffsetZ) or 0.0
                            local rx = tonumber(data.attachRotX) or 0.0
                            local ry = tonumber(data.attachRotY) or 0.0
                            local rz = tonumber(data.attachRotZ) or 0.0
                            AttachEntityToEntity(propObj, ped, boneIndex, ox, oy, oz, rx, ry, rz, true, true, false, true, 1, true)
                        end
                    end
                    TaskPlayAnim(ped, data.animDict, data.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
                end
            end
            
            local result = { success = true, tier = "common" }
            print("[NodeEngine DEBUG] minigameType=" .. tostring(data.minigameType) .. " minigameDuration=" .. tostring(data.minigameDuration))
            if data.minigameType and data.minigameType ~= "" and data.minigameType ~= "none" then
                local duration = data.minigameDuration or 5000
                if data.minigameType == "tierbar" then
                    duration = duration / 1000.0
                end
                
                print("[NodeEngine DEBUG] Chamando StartMinigame tipo=" .. tostring(data.minigameType) .. " duration=" .. tostring(duration))
                local mgOk, mgResult = pcall(function()
                    return exports['fdb-libs']:StartMinigame(data.minigameType, {
                        duration = duration,
                        images = {
                            common = "nui://fdb-libs/ui/public/img/items/unknown.png",
                            uncommon = "nui://fdb-libs/ui/public/img/items/unknown.png",
                            rare = "nui://fdb-libs/ui/public/img/items/unknown.png"
                        }
                    })
                end)
                if mgOk then
                    print("[NodeEngine DEBUG] StartMinigame retornou: success=" .. tostring(mgResult and mgResult.success) .. " tier=" .. tostring(mgResult and mgResult.tier))
                    result = mgResult or result
                else
                    print("[NodeEngine ERRO] StartMinigame falhou: " .. tostring(mgResult))
                end
            else
                print("[NodeEngine DEBUG] Sem minigame, esperando " .. tostring(minTime) .. "ms")
                Wait(minTime)
            end
            
            ClearPedTasks(ped)
            if propObj and DoesEntityExist(propObj) then
                DeleteEntity(propObj)
            end
            
            print("[NodeEngine DEBUG] Enviando ReportNodeCompletion. success=" .. tostring(result.success))
            TriggerServerEvent('node_engine:server:ReportNodeCompletion', currentNodeToken, result)
        end)
    end
end)

RegisterNetEvent('node_engine:client:SpawnAdminCrate', function()
    local hash = GetHashKey("p_crate01x")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnCoords = coords + (forward * 1.5)
    
    local obj = CreateObject(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
    PlaceObjectOnGroundProperly(obj)
    SetModelAsNoLongerNeeded(hash)
    
    exports['fdb-libs']:Notify("Caixote spawnado na sua frente!", "success")
end)

RegisterNetEvent('node_engine:client:SpawnProp', function(modelName, entityCoords, offsetZ, offsetForward)
    CreateThread(function()
        if not modelName or modelName == "" then
            print("[NodeEngine ERRO] spawn_prop ignorado: nome do modelo nulo ou vazio.")
            return
        end
        
        local hash = GetHashKey(modelName)
        RequestModel(hash)
        
        local timeout = 50
        while not HasModelLoaded(hash) and timeout > 0 do 
            Wait(100)
            timeout = timeout - 1
        end
        
        if not HasModelLoaded(hash) then
            print("[NodeEngine ERRO] spawn_prop: Nao foi possivel carregar o modelo: " .. tostring(modelName))
            return
        end
        
        local ped = PlayerPedId()
        local pedHeading = GetEntityHeading(ped)
        local rad = math.rad(pedHeading)
        
        -- Spawn na coordenada fornecida + offset, baseado na coordenada do jogador
        local pedCoords = GetEntityCoords(ped)
        local spawnX = pedCoords.x + (math.sin(-rad) * (offsetForward or 0.0))
        local spawnY = pedCoords.y + (math.cos(-rad) * (offsetForward or 0.0))
        local spawnZ = pedCoords.z + (offsetZ or 0.0)
        
        local obj = CreateObject(hash, spawnX, spawnY, spawnZ, true, true, false)
        PlaceObjectOnGroundProperly(obj)
        SetEntityHeading(obj, pedHeading)
        SetModelAsNoLongerNeeded(hash)
        print("[NodeEngine DEBUG] Prop spawnado com sucesso: " .. tostring(modelName))
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
