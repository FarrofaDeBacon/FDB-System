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

function RemoveStationZone(station)
    if station and station.targetZoneId then
        exports.ox_target:removeZone(station.targetZoneId)
        for idx, zid in ipairs(spawnedZones) do
            if zid == station.targetZoneId then
                table.remove(spawnedZones, idx)
                break
            end
        end
        station.targetZoneId = nil
    end
end

function CreateStationZone(station)
    if not station or not station.position then return end
    RemoveStationZone(station)

    local zoneId = exports.ox_target:addSphereZone({
        coords = vec3(station.position.x, station.position.y, station.position.z),
        radius = 1.5,
        debug = false,
        options = {
            {
                name = 'shop_station_' .. tostring(station.id),
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
    return zoneId
end

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
            CreateStationZone(station)

            if station.type == 'npc' and station.npc_model and station.npc_model ~= '' then
                SpawnStationNPC(station)
            elseif station.prop_model and station.prop_model ~= '' then
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
    if not model or model == '' then return end
    local coords = station.position
    if not coords then return end
    
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

    local heading = tonumber(station.npc_heading) or 0.0
    local npc = CreatePed(hash, coords.x, coords.y, coords.z, heading, false, false, false, false)
    if npc and npc ~= 0 then
        SetEntityHeading(npc, heading)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityNoCollisionEntity(npc, PlayerPedId(), false)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)

        if station.animation_name and station.animation_name ~= '' then
            TaskStartScenarioInPlace(npc, joaat(station.animation_name), -1, false, false, false, false)
        end

        FreezeEntityPosition(npc, true)
        spawnedEntities[station.id] = npc

        if exports.ox_target then
            pcall(function()
                exports.ox_target:addLocalEntity(npc, {
                    {
                        name = 'shop_npc_' .. tostring(station.id),
                        icon = 'fas fa-store',
                        label = GetStationPrompt(station.type),
                        onSelect = function()
                            InteractWithStation(station)
                        end
                    }
                })
            end)
        end
        print('[fdb-shops] Successfully spawned NPC ' .. tostring(station.id) .. ' heading: ' .. tostring(heading))
    end
end

function SpawnStationProp(station)
    local model = station.prop_model
    if not model or model == '' then return end
    local coords = station.position
    if not coords then return end
    
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

    local heading = tonumber(station.npc_heading) or 0.0
    local prop = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    if prop and prop ~= 0 then
        SetEntityHeading(prop, heading)
        FreezeEntityPosition(prop, true)
        spawnedEntities[station.id] = prop

        if exports.ox_target then
            pcall(function()
                exports.ox_target:addLocalEntity(prop, {
                    {
                        name = 'shop_prop_' .. tostring(station.id),
                        icon = 'fas fa-store',
                        label = GetStationPrompt(station.type),
                        onSelect = function()
                            InteractWithStation(station)
                        end
                    }
                })
            end)
        end
    end
end

RegisterNetEvent('fdb-shops:client:setHeading', function(stationId, heading)
    if spawnedEntities and spawnedEntities[stationId] then
        SetEntityHeading(spawnedEntities[stationId], heading)
    end
    if shopStations then
        for _, s in ipairs(shopStations) do
            if s.id == stationId then
                s.npc_heading = heading
                break
            end
        end
    end
end)

local function NotifyPlayer(msg, nType, duration)
    if not msg then return end
    if exports['fdb-libs'] then
        pcall(function()
            exports['fdb-libs']:Notify(tostring(msg), nType or 'info', tonumber(duration) or 4000)
        end)
    end
    if FDBCore and FDBCore.Functions and FDBCore.Functions.Notify then
        pcall(function()
            FDBCore.Functions.Notify(tostring(msg), nType or 'info', tonumber(duration) or 4000)
        end)
    end
end

RegisterNetEvent('fdb-shops:client:openStoreFront', function(shopData)
    SetNuiFocus(true, true)
    local theme = exports['fdb-libs']:GetActiveTheme()
    SendNUIMessage({
        action = 'openCustomerShop',
        shopData = shopData,
        theme = theme
    })
end)

function OpenCraftMenu(station)
    fdbLibs:TriggerServerCallback('fdb-shops:server:getCraftMenu', function(success, recipesData, inventoryData)
        if success then
            SetNuiFocus(true, true)
            local theme = exports['fdb-libs']:GetActiveTheme()
            SendNUIMessage({
                action = 'openCraftMenu',
                craftData = {
                    shopId = station.shop_id,
                    stationId = station.id,
                    stationLabel = (station.metadata and station.metadata.label) or "Bancada de Fabricação",
                    recipes = recipesData,
                    inventory = inventoryData or {}
                },
                theme = theme
            })
        else
            NotifyPlayer(recipesData or "Nenhuma receita disponível nesta bancada.", "error", 4000)
        end
    end, station.shop_id, station.id)
end

function InteractWithStation(station)
    if not station then return end
    print(('[fdb-shops] Interacting with station %s (type: %s, shop: %s)'):format(tostring(station.id), tostring(station.type), tostring(station.shop_id)))

    if station.type == 'npc' or station.type == 'venda' or station.type == 'registradora' then
        -- Open Shop Buy Menu (StoreFront)
        TriggerServerEvent('fdb-shops:server:openstore', station.shop_id)

    elseif station.type == 'admin_panel' then
        -- Open Owner Menu (NUI)
        fdbLibs:TriggerServerCallback('fdb-shops:server:requestOwnerMenu', function(response)
            if response and response.success then
                SetNuiFocus(true, true)
                local theme = exports['fdb-libs']:GetActiveTheme()
                SendNUIMessage({
                    action = 'openOwnerMenu',
                    shopId = station.shop_id,
                    stationId = station.id,
                    shopData = response.shopData,
                    permissions = response.permissions,
                    stationModules = (station.metadata and station.metadata.modules) or {"dashboard", "finances", "prices", "employees"},
                    theme = theme
                })
            else
                NotifyPlayer((response and response.message) or 'Acesso Negado', 'error', 4000)
            end
        end, station.shop_id)

    elseif station.type == 'bau' then
        -- Open Physical Stash
        fdbLibs:TriggerServerCallback('fdb-shops:server:requestOwnerMenu', function(response)
            if response and response.success and response.permissions.repor_estoque then
                TriggerServerEvent('fdb-shops:server:openStash', station.shop_id)
            else
                NotifyPlayer('Você não tem acesso a este estoque', 'error', 4000)
            end
        end, station.shop_id)

    elseif station.type == 'craft' then
        -- Open Crafting Menu
        OpenCraftMenu(station)
    
    elseif station.type == 'supply_board' then
        -- Open Supply Board
        NotifyPlayer('Nenhuma entrega disponível no momento', 'info', 4000)
    end
end

-- ==========================================
-- NUI Callbacks
-- ==========================================

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- StoreFront Callbacks
RegisterNUICallback('closeCustomerShop', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('checkoutCustomerShop', function(data, cb)
    fdbLibs:TriggerServerCallback('fdb-shops:server:checkoutCart', function(response)
        cb(response or { success = false, message = "Erro ao processar compra." })
    end, data)
end)

-- Crafting Bench Callbacks
RegisterNUICallback('closeCraftMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startCraft', function(data, cb)
    fdbLibs:TriggerServerCallback('fdb-shops:server:requestCraft', function(success, targetRecipe, station)
        if success then
            cb({ success = true, recipe = targetRecipe })
        else
            cb({ success = false, message = targetRecipe or "Não foi possível iniciar fabricação." })
        end
    end, data.shopId, data.recipeId, data.stationId, data.multiplier)
end)

RegisterNUICallback('completeCraft', function(data, cb)
    TriggerServerEvent('fdb-shops:server:completeCraft', data.shopId, data.recipeId, data.stationId, data.multiplier)
    cb({ success = true })
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('fdb-shops:server:withdrawCash', data.shopId, data.stationId, data.amount)
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('fdb-shops:server:depositCash', data.shopId, data.stationId, data.amount)
    cb('ok')
end)

RegisterNUICallback('updateVariation', function(data, cb)
    TriggerServerEvent('fdb-shops:server:updatePriceVariation', data.shopId, data.stationId, data.variation)
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
