-- ============================================================
-- FDB System | fdb-libs | client/target/target.lua
-- Sistema de Target Simplificado e Seguro (Substituto do ox_target)
-- ============================================================

local targetEntities = {}
local targetMenuId = "fdb_target_menu"
local currentTargetEntity = nil

--- Registra uma entidade local para ter opções de Target
--- @param entity number O handle da entidade
--- @param options table Array de opções contendo name, label, icon, distance, onSelect
local function addLocalEntity(entity, options)
    local success, err = pcall(function()
        if not entity or entity == 0 then
            error("Entidade invalida (0 ou nula)")
        end
        if type(options) ~= "table" then
            error("Opcoes invalidas (esperado table)")
        end
        
        -- Inicializa a tabela da entidade se não existir
        if not targetEntities[entity] then
            targetEntities[entity] = {}
        end
        
        -- Adiciona as novas opções
        for _, opt in ipairs(options) do
            table.insert(targetEntities[entity], opt)
        end
    end)
    
    if not success then
        print(string.format("[fdb-libs] ^3WARN^7 ox_target_setup_failed (fdb.target): falha ao registrar target - %s", tostring(err)))
        return false
    end
    return true
end

--- Remove as opções de target de uma entidade local
--- @param entity number
--- @param optionNames string|table|nil Nome ou lista de nomes das opções a remover. Se nil, remove tudo.
local function removeEntity(entity, optionNames)
    local success, err = pcall(function()
        if not entity or entity == 0 then return end
        if not targetEntities[entity] then return end
        
        if optionNames == nil then
            -- Remove todas as opções dessa entidade
            targetEntities[entity] = nil
        elseif type(optionNames) == "string" then
            for i = #targetEntities[entity], 1, -1 do
                if targetEntities[entity][i].name == optionNames then
                    table.remove(targetEntities[entity], i)
                end
            end
            if #targetEntities[entity] == 0 then targetEntities[entity] = nil end
        elseif type(optionNames) == "table" then
            for i = #targetEntities[entity], 1, -1 do
                for _, nameToRemove in ipairs(optionNames) do
                    if targetEntities[entity][i].name == nameToRemove then
                        table.remove(targetEntities[entity], i)
                    end
                end
            end
            if #targetEntities[entity] == 0 then targetEntities[entity] = nil end
        end
    end)
    
    if not success then
        print(string.format("[fdb-libs] ^3WARN^7 fdb.target: falha ao remover target - %s", tostring(err)))
    end
end

-- ============================================================
-- Lógica de Raycast e KeyMapping
-- ============================================================

local function ResolveShapeTest(rayHandle)
    local retval, hit, endCoords, surfaceNormal, entityHit

    -- Espera ate 3 frames pela engine terminar o calculo do raycast.
    -- Na pratica resolve em 0-1 frame, o limite e so seguranca contra loop infinito.
    for _ = 1, 3 do
        retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
        if retval ~= 1 then
            break
        end
        Wait(0)
    end

    return hit, entityHit
end

local function GetEntityInFrontOfPlayer(distance)
    local ped = PlayerPedId()

    -- Raycast 1: camera (o que o jogador esta olhando)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    local dirX = -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x)))
    local dirY = math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x)))
    local dirZ = math.sin(math.rad(camRot.x))
    local forwardCam = vector3(dirX, dirY, dirZ)
    local endCam = camPos + (forwardCam * distance * 2)

    local rayCam = StartShapeTestLosProbe(camPos.x, camPos.y, camPos.z, endCam.x, endCam.y, endCam.z, 511, ped, 4)
    local hitCam, entityHitCam = ResolveShapeTest(rayCam)
    print("hitCam:", hitCam, "entityHitCam:", entityHitCam)

    if hitCam == 1 and entityHitCam ~= 0 then
        return entityHitCam
    end

    -- Raycast 2 (fallback): direto da frente do personagem, ignora a camera
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local endCoords = coords + (forward * distance)

    local ray = StartShapeTestLosProbe(coords.x, coords.y, coords.z, endCoords.x, endCoords.y, endCoords.z, 511, ped, 4)
    local hit, entityHit = ResolveShapeTest(ray)
    print("hitFallback:", hit, "entityHitFallback:", entityHit)

    if hit == 1 and entityHit ~= 0 then
        return entityHit
    end

    return nil
end

local activeCallbacks = {}

Citizen.CreateThread(function()
    local isEyeOpen = false
    local isMouseFree = false
    local lastValidEntity = nil
    local lostFrames = 0
    local LOST_THRESHOLD = 10 -- Quantos frames sem achar a entidade antes de limpar
    
    while true do
        local sleep = 500
        
        -- Verifica se o jogador ESTA SEGURANDO o ALT Esquerdo
        if IsControlPressed(0, 0x8AAA0AD4) then
            sleep = 0
            
            if not isEyeOpen then
                isEyeOpen = true
                SendNUIMessage({ action = "SET_TARGET_EYE", data = { visible = true } })
            end
            
            local entity = GetEntityInFrontOfPlayer(4.0)
            
            if entity and targetEntities[entity] then
                lostFrames = 0 -- Resetou, encontrou alvo
                
                if entity ~= lastValidEntity then
                    lastValidEntity = entity
                    local options = targetEntities[entity]
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local entityCoords = GetEntityCoords(entity)
                    local dist = #(playerCoords - entityCoords)
                    
                    local contextOptions = {}
                    activeCallbacks = {}
                    
                    for i, opt in ipairs(options) do
                        if dist <= (opt.distance or 2.5) then
                            table.insert(contextOptions, {
                                label = opt.label,
                                icon = opt.icon
                            })
                            activeCallbacks[#contextOptions] = opt.onSelect
                        end
                    end
                    
                    if #contextOptions > 0 then
                        SendNUIMessage({ action = "SET_TARGET_OPTIONS", data = { options = contextOptions } })
                        if not isMouseFree then
                            isMouseFree = true
                            SetNuiFocus(true, true)
                            SendNUIMessage({ action = "SET_TARGET_MOUSE", data = { free = true } })
                        end
                    end
                end
            else
                -- Nao achou entidade NESTE frame, mas espera alguns frames antes de desistir
                lostFrames = lostFrames + 1
                if lostFrames >= LOST_THRESHOLD and lastValidEntity ~= nil then
                    lastValidEntity = nil
                    activeCallbacks = {}
                    SendNUIMessage({ action = "SET_TARGET_OPTIONS", data = { options = {} } })
                    if isMouseFree then
                        isMouseFree = false
                        SetNuiFocus(false, false)
                        SendNUIMessage({ action = "SET_TARGET_MOUSE", data = { free = false } })
                    end
                end
            end
            
        else
            -- Soltou o ALT
            if isEyeOpen then
                isEyeOpen = false
                isMouseFree = false
                lastValidEntity = nil
                lostFrames = 0
                activeCallbacks = {}
                SetNuiFocus(false, false)
                SendNUIMessage({ action = "SET_TARGET_EYE", data = { visible = false } })
            end
        end

        Wait(sleep)
    end
end)

-- Callback do clique do NUI
RegisterNUICallback('targetSelectOption', function(data, cb)
    local index = tonumber(data.index)
    
    -- Fecha tudo apos o clique
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "SET_TARGET_EYE", data = { visible = false } })
    
    -- Dispara a acao do Lua
    if index and activeCallbacks[index] then
        if type(activeCallbacks[index]) == "function" then
            -- OBS: lastValidEntity aqui ja e uma upvalue do escopo local
            -- Porem, ele pode ter sido resetado pelo if (nao esta segurando alt).
            -- Para evitar bugs, e bom passar a entidade que estava ativa.
            activeCallbacks[index]() 
        end
    end
    
    if cb then cb('ok') end
end)

-- Exports compatíveis com ox_target
exports('addLocalEntity', addLocalEntity)
exports('removeEntity', removeEntity)

-- COMANDO DE TESTE TEMPORARIO
RegisterCommand('testtarget', function()
    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local spawnCoords = coords + (forward * 1.5)
        
        exports['fdb-libs']:LoadModel('p_cigar01x')
        local prop = CreateObject(joaat('p_cigar01x'), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
        PlaceObjectOnGroundProperly(prop)
        
        exports['fdb-libs']:addLocalEntity(prop, {{
            name = 'teste_prop',
            label = 'Inspecionar Charuto',
            icon = 'fa-solid fa-magnifying-glass',
            distance = 3.0,
            onSelect = function()
                print('[fdb-libs] SUCESSO! O CALLBACK DO TARGET FUNCIONOU! (Charuto Inspecionado)')
                DeleteEntity(prop)
            end
        }})
        print('[fdb-libs] Target Registrado! Olhe para o charuto no chao a sua frente e segure ALT.')
    end)
end, false)
