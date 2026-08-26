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

RegisterNetEvent('node_engine:client:PlayAnimation', function(data)
    CreateThread(function()
        local ped = PlayerPedId()
        local propObj = nil
        
        if data.animDict and data.animName and data.animDict ~= "" then
            RequestAnimDict(data.animDict)
            local timeout = 50
            while not HasAnimDictLoaded(data.animDict) and timeout > 0 do 
                Wait(100)
                timeout = timeout - 1
            end
            
            if timeout <= 0 then
                print("[NodeEngine] AVISO: Dicionario de animacao nao pode ser carregado: " .. tostring(data.animDict))
                return
            end

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
            
            -- Toca a animação (flag 1 = loop)
            TaskPlayAnim(ped, data.animDict, data.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            
            local duration = tonumber(data.durationMs) or 1000
            Wait(duration)
            
            ClearPedTasks(ped)
            if propObj and DoesEntityExist(propObj) then
                DeleteEntity(propObj)
            end
        end
    end)
end)

RegisterNetEvent('node_engine:client:SpawnProp', function(propData, defaultCoords)
    CreateThread(function()
        if not propData.props or type(propData.props) ~= "table" then
            -- Fallback para nó legado
            propData.props = {
                {
                    model = propData.model,
                    offsetX = propData.offsetX,
                    offsetY = propData.offsetY,
                    offsetZ = propData.offsetZ,
                    heading = propData.heading
                }
            }
        end

        for _, prop in ipairs(propData.props) do
            local modelName = prop.model
            if modelName and modelName ~= "" then
                local hash = GetHashKey(modelName)
                RequestModel(hash)
                
                local timeout = 50
                while not HasModelLoaded(hash) and timeout > 0 do 
                    Wait(100)
                    timeout = timeout - 1
                end
                
                if HasModelLoaded(hash) then
                    local spawnCoords
                    local propHeading
                    
                    if prop.coords and type(prop.coords) == 'table' and prop.coords.x then
                        -- Coordenadas absolutas da ferramenta 3D
                        spawnCoords = vector3(prop.coords.x, prop.coords.y, prop.coords.z)
                        propHeading = tonumber(prop.heading) or 0.0
                    else
                        -- Offsets legados relativos ao jogador
                        local ped = PlayerPedId()
                        local pedHeading = GetEntityHeading(ped)
                        spawnCoords = GetOffsetFromEntityInWorldCoords(ped, prop.offsetX or 0.0, prop.offsetY or 0.0, prop.offsetZ or 0.0)
                        propHeading = pedHeading + (prop.heading or 0.0)
                    end
                    
                    local obj = CreateObject(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
                    PlaceObjectOnGroundProperly(obj)
                    SetEntityHeading(obj, propHeading)
                    SetModelAsNoLongerNeeded(hash)
                    print("[NodeEngine DEBUG] Prop spawnado com sucesso: " .. tostring(modelName))
                else
                    print("[NodeEngine ERRO] spawn_prop: Nao foi possivel carregar o modelo: " .. tostring(modelName))
                end
            end
        end
    end)
end)

RegisterNetEvent('node_engine:client:SpawnPed', function(pedData)
    CreateThread(function()
        local modelName = pedData.pedModel
        if not modelName or modelName == "" then return end
        
        local hash = GetHashKey(modelName)
        RequestModel(hash)
        
        local timeout = 50
        while not HasModelLoaded(hash) and timeout > 0 do 
            Wait(100)
            timeout = timeout - 1
        end
        
        if not HasModelLoaded(hash) then 
            print("[NodeEngine ERRO] spawn_ped: Nao foi possivel carregar o modelo: " .. tostring(modelName))
            return 
        end
        
        local spawnCoords
        local pedHeading
        
        if pedData.coords and type(pedData.coords) == 'table' and pedData.coords.x then
            spawnCoords = vector3(pedData.coords.x, pedData.coords.y, pedData.coords.z)
            pedHeading = tonumber(pedData.heading) or 0.0
        else
            local ped = PlayerPedId()
            spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, 0.0)
            pedHeading = GetEntityHeading(ped)
        end
        
        -- CreatePed signature para RedM/FiveM comum. 
        -- Em RedM às vezes é CreatePed(hash, x, y, z, h, isNet, bScriptHostPed)
        -- Em FiveM é CreatePed(pedType, hash, x, y, z, h, isNet, bScriptHostPed)
        -- Como GetGameName() == 'redm' não temos pedType.
        local spawnedPed
        if GetGameName() == 'redm' then
            spawnedPed = CreatePed(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, pedHeading, true, false)
        else
            spawnedPed = CreatePed(4, hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, pedHeading, true, false)
        end
        
        PlaceObjectOnGroundProperly(spawnedPed)
        
        if pedData.animDict and pedData.animName and pedData.animDict ~= "" then
            RequestAnimDict(pedData.animDict)
            local aTimeout = 50
            while not HasAnimDictLoaded(pedData.animDict) and aTimeout > 0 do
                Wait(100)
                aTimeout = aTimeout - 1
            end
            if HasAnimDictLoaded(pedData.animDict) then
                TaskPlayAnim(spawnedPed, pedData.animDict, pedData.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end
        
        -- Lógica base de reação do ped (Attack, etc) baseada na taskType
        if pedData.taskType == "guard" or pedData.taskType == "Atacar" then
            GiveWeaponToPed(spawnedPed, GetHashKey("WEAPON_REVOLVER"), 100, false, true)
            TaskCombatPed(spawnedPed, PlayerPedId(), 0, 16)
        end
        
        SetModelAsNoLongerNeeded(hash)
        print("[NodeEngine DEBUG] Ped spawnado com sucesso: " .. tostring(modelName))
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

RegisterNetEvent('node_engine:client:ManageRiskBar', function(action, data)
    if action == "show" then
        if exports['fdb-libs'] and exports['fdb-libs'].ShowRiskBar then
            exports['fdb-libs']:ShowRiskBar(data)
        else
            print("[NodeEngine] fdb-libs export 'ShowRiskBar' not found!")
        end
    elseif action == "update" then
        if exports['fdb-libs'] and exports['fdb-libs'].UpdateRiskBar then
            exports['fdb-libs']:UpdateRiskBar(data.percent)
        end
    elseif action == "hide" then
        if exports['fdb-libs'] and exports['fdb-libs'].HideRiskBar then
            exports['fdb-libs']:HideRiskBar()
        end
    end
end)
