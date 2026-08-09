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
    
    local rayCam = StartShapeTestCapsule(camPos.x, camPos.y, camPos.z, endCam.x, endCam.y, endCam.z, 1.0, 10, ped, 7)
    local _, hitCam, _, _, entityHitCam = GetShapeTestResult(rayCam)
    
    if hitCam == 1 and entityHitCam ~= 0 then
        return entityHitCam
    end

    -- Fallback: Tenta pegar pela frente do personagem
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local endCoords = coords + (forward * distance)

    local ray = StartShapeTestCapsule(coords.x, coords.y, coords.z, endCoords.x, endCoords.y, endCoords.z, 1.0, 10, ped, 7)
    local _, hit, _, _, entityHit = GetShapeTestResult(ray)
    
    if hit == 1 and entityHit ~= 0 then
        return entityHit
    end

    return nil
end

RegisterCommand('+fdb_target', function()
    local entity = GetEntityInFrontOfPlayer(4.0)
    if entity and targetEntities[entity] then
        local options = targetEntities[entity]
        local menuItems = {}
        local playerCoords = GetEntityCoords(PlayerPedId())
        local entityCoords = GetEntityCoords(entity)
        local dist = #(playerCoords - entityCoords)
        
        for i, opt in ipairs(options) do
            if dist <= (opt.distance or 2.5) then
                table.insert(menuItems, {
                    type = "button",
                    id = opt.name,
                    label = opt.label,
                    icon = opt.icon or "fa-solid fa-circle-dot"
                })
            end
        end

        if #menuItems > 0 then
            currentTargetEntity = entity
            -- Usa a interface gráfica global da lib
            exports['fdb-libs']:openMenu({
                id = targetMenuId,
                title = "Interagir",
                items = menuItems
            })
        end
    end
end, false)

-- Limpa a variável quando a tecla é solta
RegisterCommand('-fdb_target', function()
end, false)

-- Tecla padrão: ALT Esquerdo
RegisterKeyMapping('+fdb_target', 'Target Interagir (FDB)', 'keyboard', 'LMENU')

-- ============================================================
-- Callback do Context Menu
-- ============================================================

AddEventHandler('fdb-libs:menu:onChange', function(data)
    if data.menuId == targetMenuId and data.itemId then
        if currentTargetEntity and targetEntities[currentTargetEntity] then
            for _, opt in ipairs(targetEntities[currentTargetEntity]) do
                if opt.name == data.itemId then
                    exports['fdb-libs']:closeMenu()
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
