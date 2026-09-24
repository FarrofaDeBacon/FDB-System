-- ============================================================
-- FDB System | fdb-shops | client/client.lua
-- Core Client Logic (Spawning stations, handling interactions)
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local fdbLibs = exports['fdb-libs']
local resourceName = GetCurrentResourceName()
lib.locale()

spawnedEntities = {}
shopStations = {}
local spawnedZones = {}

-- Load Stations from server on player load
RegisterNetEvent('FDBCore:Client:OnPlayerLoaded', function()
    fdbLibs:TriggerServerCallback('fdb-shops:server:getStations', function(stations)
        shopStations = stations
        InitializeStations()
    end)
end)

-- Temporary fallback for restart script
CreateThread(function()
    Wait(2000)
    print('[fdb-shops] Requesting stations from server on resource start...')
    fdbLibs:TriggerServerCallback('fdb-shops:server:getStations', function(stations)
        shopStations = stations
        print(('[fdb-shops] Loaded %s stations from server.'):format(#shopStations))
        InitializeStations()
    end)
end)

-- Manual fallback command for testing
RegisterCommand('shopreload', function()
    print('[fdb-shops] Manually requesting stations...')
    fdbLibs:TriggerServerCallback('fdb-shops:server:getStations', function(stations)
        shopStations = stations
        print(('[fdb-shops] Loaded %s stations from server.'):format(#shopStations))
        InitializeStations()
    end)
end, false)

function InitializeStations()
    -- Cleanup previous
    for _, entity in pairs(spawnedEntities) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
    spawnedEntities = {}
    
    for _, zoneId in ipairs(spawnedZones) do
        exports.ox_target:removeZone(zoneId)
    end
    spawnedZones = {}

    print('[fdb-shops] Initializing stations...')

    for _, station in ipairs(shopStations) do
        if station.position then
            -- 1. Create Target Zone using ox_target
            local zoneId = exports.ox_target:addSphereZone({
                coords = vec3(station.position.x, station.position.y, station.position.z),
                radius = 1.5,
                debug = false,
                options = {
                    {
                        name = 'shop_station_' .. station.id,
                        icon = 'fas fa-store',
                        label = GetStationPrompt(station.type),
                        onSelect = function()
                            InteractWithStation(station)
                        end
                    }
                }
            })
            table.insert(spawnedZones, zoneId)
            station.targetZoneId = zoneId

            -- 2. Spawn Visuals (NPCs or Props)
            if station.type == 'npc' and station.npc_model then
                SpawnStationNPC(station)
            elseif station.prop_model then
                SpawnStationProp(station)
            end
        end
    end
    print(('[fdb-shops] Successfully created %s interaction zones.'):format(#shopStations))
end

function GetStationPrompt(stationType)
    local prompts = {
        ['registradora'] = 'Abrir Registradora',
        ['bau'] = 'Abrir Estoque',
        ['craft'] = 'Produzir Itens',
        ['venda'] = 'Abrir Catálogo',
        ['npc'] = 'Falar',
        ['supply_board'] = 'Quadro de Entregas',
        ['admin_panel'] = 'Painel de Administração'
    }
    return prompts[stationType] or 'Interagir'
end

function SpawnStationNPC(station)
    local model = station.npc_model
    local coords = station.position
    
    print('[fdb-shops] Attempting to spawn NPC model: ' .. tostring(model))
    local hash = joaat(model)
    if not IsModelValid(hash) then
        print('[fdb-shops] ERROR: Model ' .. tostring(model) .. ' is invalid (does not exist in CD image).')
        return
    end
    
    RequestModel(hash)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            print('[fdb-shops] ERROR: Failed to load model ' .. tostring(model) .. ' (timeout)')
            return
        end
    end

    local npc = CreatePed(hash, coords.x, coords.y, coords.z, station.npc_heading or 0.0, false, false, false, false)
    if npc and npc ~= 0 then
        print('[fdb-shops] Successfully spawned NPC. Entity ID: ' .. tostring(npc))
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityNoCollisionEntity(npc, PlayerPedId(), false)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)

        if station.animation_name then
            TaskStartScenarioInPlace(npc, joaat(station.animation_name), -1, true, false, false, false)
        end

        spawnedEntities[station.type .. '_' .. station.shop_id] = npc
    end
end

function SpawnStationProp(station)
    local model = station.prop_model
    local coords = station.position
    
    local hash = joaat(model)
    if not IsModelValid(hash) then
        print('[fdb-shops] ERROR: Prop Model ' .. tostring(model) .. ' is invalid (does not exist in CD image).')
        return
    end

    RequestModel(hash)
    
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then return end
    end

    local prop = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    if prop and prop ~= 0 then
        SetEntityRotation(prop, 0.0, 0.0, station.npc_heading or 0.0, 2, true)
        FreezeEntityPosition(prop, true)
        spawnedEntities[station.type .. '_' .. station.shop_id] = prop
    end
end

function InteractWithStation(station)
    if station.type == 'npc' or station.type == 'venda' then
        -- Open Shop Buy Menu
        TriggerServerEvent('fdb-shops:server:openstore', station.shop_id)

    elseif station.type == 'registradora' then
        -- Open Owner Menu (NUI)
        fdbLibs:TriggerServerCallback('fdb-shops:server:requestOwnerMenu', function(response)
            if response and response.success then
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'openOwnerMenu',
                    shopId = station.shop_id,
                    shopData = response.shopData,
                    permissions = response.permissions
                })
            else
                fdbLibs:Notify('Acesso Negado', 'error', 3000)
            end
        end, station.shop_id)

    elseif station.type == 'bau' then
        -- Open Physical Stash
        -- Verify permissions first
        fdbLibs:TriggerServerCallback('fdb-shops:server:requestOwnerMenu', function(response)
            if response and response.success and response.permissions.repor_estoque then
                TriggerServerEvent('fdb-shops:server:openStash', station.shop_id)
            else
                fdbLibs:Notify('Você não tem acesso a este estoque', 'error', 3000)
            end
        end, station.shop_id)

    elseif station.type == 'craft' then
        -- Open Crafting Menu (Phase 2)
        OpenCraftMenu(station)
    
    elseif station.type == 'supply_board' then
        -- Open Supply Board (Future Phase 3)
        fdbLibs:Notify('Nenhuma entrega disponível no momento', 'info', 3000)
    end
end

-- ==========================================
-- NUI Callbacks
-- ==========================================

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('fdb-shops:server:withdrawCash', data.shopId, data.amount)
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('fdb-shops:server:depositCash', data.shopId, data.amount)
    cb('ok')
end)

RegisterNUICallback('updateVariation', function(data, cb)
    TriggerServerEvent('fdb-shops:server:updatePriceVariation', data.shopId, data.variation)
    cb('ok')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resName)
    if resName == resourceName then
        for _, entity in pairs(spawnedEntities) do
            if DoesEntityExist(entity) then DeleteEntity(entity) end
        end
    end
end)
