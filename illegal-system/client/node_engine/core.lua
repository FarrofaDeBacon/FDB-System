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
                        local heading = GetEntityHeading(entity)
                        
                        TriggerServerEvent('node_engine:server:TriggerModelInteracted', trigger.heistId, trigger.nodeId, model, coords, heading)
                    end
                }
            }
            local modelsTable = {}
            if type(trigger.models) == "string" then
                for model in string.gmatch(trigger.models, '([^,]+)') do
                    table.insert(modelsTable, model:match("^%s*(.-)%s*$")) -- Trim whitespace
                end
            elseif type(trigger.models) == "table" then
                modelsTable = trigger.models
            else
                modelsTable = { trigger.models }
            end
            
            Bridge.RegisterTargetModel(modelsTable, options)
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

RegisterNetEvent('node_engine:client:SpawnProp', function(propData, defaultCoords, defaultHeading)
    CreateThread(function()
        if not propData.props or type(propData.props) ~= "table" then
            -- Fallback para nó legado
            propData.props = {
                {
                    model = propData.model,
                    offsetX = propData.offsetX,
                    offsetY = propData.offsetY,
                    offsetZ = propData.offsetZ,
                    offsetForward = propData.offsetForward,
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
                        print("[NodeEngine DEBUG] Usando coordenadas absolutas: " .. json.encode(prop.coords))
                        -- Coordenadas absolutas da ferramenta 3D
                        spawnCoords = vector3(prop.coords.x, prop.coords.y, prop.coords.z)
                        propHeading = tonumber(prop.heading) or 0.0
                    else
                        print("[NodeEngine DEBUG] Usando fallback relacional. Prop dump: " .. json.encode(prop))
                        -- Offsets legados relativos à entidade que trigou o assalto (ou jogador como fallback final)
                        local entityHeading = defaultHeading or 0.0
                        local rad = math.rad(entityHeading)
                        
                        -- Vetor Forward (-sin, cos) e Vetor Right (cos, sin)
                        local fx, fy = -math.sin(rad), math.cos(rad)
                        local rx, ry = math.cos(rad), math.sin(rad)
                        
                        local baseX, baseY = defaultCoords.x, defaultCoords.y
                        
                        local found, groundZ = GetGroundZFor_3dCoord(baseX, baseY, defaultCoords.z + 2.0, false)
                        local finalZ = found and groundZ or defaultCoords.z
                        
                        local forwardOffset = prop.offsetForward or prop.offsetY or 0.0
                        local rightOffset = prop.offsetX or 0.0
                        
                        spawnCoords = vector3(
                            baseX + (fx * forwardOffset) + (rx * rightOffset),
                            baseY + (fy * forwardOffset) + (ry * rightOffset),
                            finalZ + (prop.offsetZ or 0.0)
                        )
                        propHeading = entityHeading + (prop.heading or 0.0)
                    end
                    
                    local obj = CreateObject(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
                    if prop.coords and type(prop.coords) == 'table' and prop.coords.x then
                        PlaceObjectOnGroundProperly(obj)
                    end
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
        
        -- Garantir colisão carregada no local do spawn
        RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
        Wait(100)
        
        -- Buscar o Z correto do chão para não spawnar enterrado
        local groundZ = spawnCoords.z
        local found, z = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 5.0, false)
        if found then
            groundZ = z
        end
        
        -- Criar o ped — local (não networked) para não sumir
        local spawnedPed
        if GetGameName() == 'redm' then
            spawnedPed = CreatePed(hash, spawnCoords.x, spawnCoords.y, groundZ, pedHeading, false, false)
        else
            spawnedPed = CreatePed(4, hash, spawnCoords.x, spawnCoords.y, groundZ, pedHeading, false, false)
        end
        
        if not spawnedPed or spawnedPed == 0 or not DoesEntityExist(spawnedPed) then
            print("[NodeEngine ERRO] spawn_ped: CreatePed retornou entidade inválida para modelo: " .. tostring(modelName))
            return
        end
        
        -- RedM: Carregar o outfit do ped (sem isso ele fica invisível, só arma aparece)
        if GetGameName() == 'redm' then
            Citizen.InvokeNative(0x77FF8D35EEC6BBC4, spawnedPed, 0, false) -- SetPedOutfitPreset(ped, preset, p2)
            Wait(500) -- Dar tempo pro outfit carregar
        end
        
        -- Configurações base
        SetBlockingOfNonTemporaryEvents(spawnedPed, true)
        
        local taskType = pedData.taskType or "idle"
        print("[NodeEngine DEBUG] Ped taskType: " .. tostring(taskType))
        
        if taskType == "frozen" then
            -- Congelado: estátua, não se mexe
            FreezeEntityPosition(spawnedPed, true)
            SetEntityInvincible(spawnedPed, true)
            
        elseif taskType == "idle" then
            -- Idle natural: fica parado mas com animação de respirar
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, true)
            TaskStandStill(spawnedPed, -1)
            
        elseif taskType == "guard" then
            -- Guarda: fica parado, ataca se jogador chegar perto
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, false)
            local weaponName = pedData.weapon or "WEAPON_REVOLVER_CATTLEMAN"
            if weaponName ~= "WEAPON_UNARMED" then
                GiveWeaponToPed(spawnedPed, GetHashKey(weaponName), 100, false, true)
            end
            local detectDist = tonumber(pedData.detectDistance) or 15.0
            -- Guardar posição e reagir a ameaças
            TaskGuardCurrentPosition(spawnedPed, detectDist, detectDist, true)
            
        elseif taskType == "attack" then
            -- Atacar imediatamente o jogador
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, false)
            SetBlockingOfNonTemporaryEvents(spawnedPed, false)
            local weaponName = pedData.weapon or "WEAPON_REVOLVER_CATTLEMAN"
            if weaponName ~= "WEAPON_UNARMED" then
                GiveWeaponToPed(spawnedPed, GetHashKey(weaponName), 100, false, true)
            end
            TaskCombatPed(spawnedPed, PlayerPedId(), 0, 16)
            
        elseif taskType == "flee" then
            -- Fugir do jogador
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, true)
            SetBlockingOfNonTemporaryEvents(spawnedPed, false)
            TaskReactAndFleePed(spawnedPed, PlayerPedId())
            
        elseif taskType == "wander" then
            -- Vagar pela área num raio
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, true)
            SetBlockingOfNonTemporaryEvents(spawnedPed, false)
            local radius = tonumber(pedData.wanderRadius) or 10.0
            TaskWanderInArea(spawnedPed, spawnCoords.x, spawnCoords.y, groundZ, radius, 0, 0)
            
        elseif taskType == "scenario" then
            -- Cenário ambiental (fumando, bebendo, etc)
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, true)
            local scenarioName = pedData.scenario or "WORLD_HUMAN_SMOKING"
            TaskStartScenarioInPlace(spawnedPed, GetHashKey(scenarioName), -1, true)
            
        elseif taskType == "animation" then
            -- Animação personalizada
            FreezeEntityPosition(spawnedPed, false)
            SetEntityInvincible(spawnedPed, true)
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
            
        else
            -- Fallback: idle
            TaskStandStill(spawnedPed, -1)
        end
        
        SetModelAsNoLongerNeeded(hash)
        print("[NodeEngine DEBUG] Ped spawnado com sucesso: " .. tostring(modelName) .. " | Task: " .. tostring(taskType) .. " | Handle: " .. tostring(spawnedPed) .. " | Pos: " .. tostring(GetEntityCoords(spawnedPed)))
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

RegisterNetEvent('node_engine:client:ManageNoiseBar', function(action, data)
    if action == "show" then
        if exports['fdb-libs'] and exports['fdb-libs'].ShowNoiseBar then
            exports['fdb-libs']:ShowNoiseBar(data)
        else
            print("[NodeEngine] fdb-libs export 'ShowNoiseBar' not found!")
        end
    elseif action == "update" then
        if exports['fdb-libs'] and exports['fdb-libs'].UpdateNoiseBar then
            exports['fdb-libs']:UpdateNoiseBar(data.percent)
        end
    elseif action == "hide" then
        if exports['fdb-libs'] and exports['fdb-libs'].HideNoiseBar then
            exports['fdb-libs']:HideNoiseBar()
        end
    end
end)
