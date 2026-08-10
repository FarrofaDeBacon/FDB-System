-- ============================================================
-- FDB System | fdb-libs | client/target/target.lua
-- Sistema de Target Simplificado e Seguro (Substituto do ox_target)
-- ============================================================

local targetEntities = {}
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

        if not targetEntities[entity] then
            targetEntities[entity] = {}
        end

        for _, opt in ipairs(options) do
            table.insert(targetEntities[entity], opt)
        end
    end)

    if not success then
        print(string.format("[fdb-libs] ^3WARN^7 fdb.target: falha ao registrar target - %s", tostring(err)))
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
-- Lógica de Raycast
-- ============================================================

-- Espera até 3 frames pela engine terminar o cálculo do shape test,
-- em vez de ler o resultado na hora (que vinha "pendente" e falhava).
local function ResolveShapeTest(rayHandle)
    local retval, hit, endCoords, surfaceNormal, entityHit

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

    -- Raycast 1: câmera (o que o jogador está olhando)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    local dirX = -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x)))
    local dirY = math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x)))
    local dirZ = math.sin(math.rad(camRot.x))
    local forwardCam = vector3(dirX, dirY, dirZ)
    local endCam = camPos + (forwardCam * distance * 2)

    local rayCam = StartShapeTestLosProbe(camPos.x, camPos.y, camPos.z, endCam.x, endCam.y, endCam.z, 511, ped, 4)
    local hitCam, entityHitCam = ResolveShapeTest(rayCam)

    if hitCam == 1 and entityHitCam ~= 0 then
        return entityHitCam
    end

    -- Raycast 2 (fallback): direto da frente do personagem, ignora a câmera
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local endCoords = coords + (forward * distance)

    local ray = StartShapeTestLosProbe(coords.x, coords.y, coords.z, endCoords.x, endCoords.y, endCoords.z, 511, ped, 4)
    local hit, entityHit = ResolveShapeTest(ray)

    if hit == 1 and entityHit ~= 0 then
        return entityHit
    end

    return nil
end

-- ============================================================
-- Loop Principal
-- ============================================================

Citizen.CreateThread(function()
    local lastValidEntity = nil
    local debugLastEntity = nil
    local contextOptions = {}

    while true do
        local sleep = 500

        if IsControlPressed(0, 0x8AAA0AD4) then -- INPUT_FRONTEND_ALT (ALT esquerdo)
            sleep = 0

            local entity = GetEntityInFrontOfPlayer(4.0)
            lastValidEntity = nil
            contextOptions = {}

            if entity and targetEntities[entity] then
                if debugLastEntity ~= entity then
                    debugLastEntity = entity
                    print("[fdb-libs] [DEBUG] Alvo valido detectado na mira (" .. tostring(entity) .. ")")
                end

                local options = targetEntities[entity]
                local playerCoords = GetEntityCoords(PlayerPedId())
                local entityCoords = GetEntityCoords(entity)
                local dist = #(playerCoords - entityCoords)

                for _, opt in ipairs(options) do
                    if dist <= (opt.distance or 2.5) then
                        table.insert(contextOptions, {
                            label = opt.label,
                            icon = opt.icon or "fa-solid fa-circle-dot",
                            action = function()
                                if type(opt.onSelect) == "function" then
                                    opt.onSelect(entity)
                                end
                            end
                        })
                    end
                end

                if #contextOptions > 0 then
                    lastValidEntity = entity
                end
            else
                if debugLastEntity ~= nil then
                    debugLastEntity = nil
                    print("[fdb-libs] [DEBUG] Alvo perdido da mira.")
                end
            end
        end

        -- Se o jogador SOLTOU o ALT esquerdo
        if IsControlJustReleased(0, 0x8AAA0AD4) then
            if lastValidEntity and #contextOptions > 0 then
                fdb.context.OpenContextMenu({
                    title = "Interagir",
                    options = contextOptions
                })
            end

            lastValidEntity = nil
            debugLastEntity = nil
            contextOptions = {}
        end

        Wait(sleep)
    end
end)

-- Exports compatíveis com ox_target
exports('addLocalEntity', addLocalEntity)
exports('removeEntity', removeEntity)

-- ============================================================
-- COMANDO DE TESTE TEMPORÁRIO — remover antes de ir pra produção
-- ============================================================
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
        print('[fdb-libs] Target registrado! Olhe para o charuto no chao a sua frente e segure ALT.')
    end)
end, false)
