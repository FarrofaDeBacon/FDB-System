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

local function GetEntityInFrontOfPlayer(distance)
    local ped = PlayerPedId()
    
    -- Tenta pegar pela câmera primeiro (onde o jogador está olhando)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    local dirX = -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x)))
    local dirY = math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x)))
    local dirZ = math.sin(math.rad(camRot.x))
    local forwardCam = vector3(dirX, dirY, dirZ)
    local endCam = camPos + (forwardCam * distance * 2)
    
    local rayCam = StartShapeTestLosProbe(camPos.x, camPos.y, camPos.z, endCam.x, endCam.y, endCam.z, 511, ped, 4)
    local hitCam, entityHitCam = 0, 0
    while true do
        Wait(0)
        local retval, h, _, _, e = GetShapeTestResult(rayCam)
        if retval ~= 1 then
            hitCam, entityHitCam = h, e
            break
        end
    end
    
    if hitCam == 1 and entityHitCam ~= 0 then
        return entityHitCam
    end

    -- Fallback: Tenta pegar pela frente do personagem
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local endCoords = coords + (forward * distance)

    local ray = StartShapeTestLosProbe(coords.x, coords.y, coords.z, endCoords.x, endCoords.y, endCoords.z, 511, ped, 4)
    local hit, entityHit = 0, 0
    while true do
        Wait(0)
        local retval, h, _, _, e = GetShapeTestResult(ray)
        if retval ~= 1 then
            hit, entityHit = h, e
            break
        end
    end
    
    if hit == 1 and entityHit ~= 0 then
        return entityHit
    end

    return nil
end

Citizen.CreateThread(function()
    local lastValidEntity = nil
    local lastMenuItems = {}

    while true do
        local sleep = 500
        -- Verifica se o jogador ESTÁ SEGURANDO o ALT Esquerdo (INPUT_FRONTEND_ALT / 0x8AAA0AD4)
        if IsControlPressed(0, 0x8AAA0AD4) then
            sleep = 0
            
            local entity = GetEntityInFrontOfPlayer(4.0)
            
            -- Limpa os dados se não tiver entidade
            lastValidEntity = nil
            lastMenuItems = {}
            
            if entity and targetEntities[entity] then
                local options = targetEntities[entity]
                local playerCoords = GetEntityCoords(PlayerPedId())
                local entityCoords = GetEntityCoords(entity)
                local dist = #(playerCoords - entityCoords)
                
                for i, opt in ipairs(options) do
                    if dist <= (opt.distance or 2.5) then
                        table.insert(lastMenuItems, {
                            type = "button",
                            id = opt.name,
                            label = opt.label,
                            icon = opt.icon or "fa-solid fa-circle-dot"
                        })
                    end
                end
                
                if #lastMenuItems > 0 then
                    lastValidEntity = entity
                    -- Aqui poderia ter um DrawText na tela indicando que achou o alvo, 
                    -- mas o RedM nativamente já mostra um ponto (dot) ao segurar ALT.
                end
            end
        end

        -- Se o jogador SOLTOU o ALT Esquerdo
        if IsControlJustReleased(0, 0x8AAA0AD4) then
            if lastValidEntity and #lastMenuItems > 0 then
                currentTargetEntity = lastValidEntity
                -- Abre a interface gráfica global da lib
                fdb.menu.open({
                    id = targetMenuId,
                    title = "Interagir",
                    items = lastMenuItems
                })
            end
            
            -- Reseta o estado
            lastValidEntity = nil
            lastMenuItems = {}
        end

        Wait(sleep)
    end
end)

-- ============================================================
-- Callback do Context Menu
-- ============================================================

AddEventHandler('fdb-libs:menu:onChange', function(data)
    if data.menuId == targetMenuId and data.itemId then
        if currentTargetEntity and targetEntities[currentTargetEntity] then
            for _, opt in ipairs(targetEntities[currentTargetEntity]) do
                if opt.name == data.itemId then
                    fdb.menu.close()
                    if type(opt.onSelect) == "function" then
                        opt.onSelect(currentTargetEntity)
                    end
                    currentTargetEntity = nil
                    break
                end
            end
        end
    end
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
