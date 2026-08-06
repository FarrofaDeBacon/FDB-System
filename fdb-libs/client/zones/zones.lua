fdb = fdb or {}
fdb.zones = {}

local activeZones = {}
local insideZones = {}

-- Cria/Adiciona uma nova zona circular
function fdb.zones.Create(name, coords, radius, options)
    options = options or {}
    activeZones[name] = {
        name = name,
        coords = coords,
        radius = radius,
        onEnter = options.onEnter,
        onExit = options.onExit,
        inside = options.inside
    }
    return name
end

-- Remove uma zona
function fdb.zones.Remove(name)
    if activeZones[name] then
        if insideZones[name] then
            if activeZones[name].onExit then
                activeZones[name].onExit()
            end
            insideZones[name] = nil
        end
        activeZones[name] = nil
    end
end

-- Thread de checagem de distância
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        for name, zone in pairs(activeZones) do
            local zoneCoords = vector3(zone.coords.x, zone.coords.y, zone.coords.z)
            local dist = #(playerCoords - zoneCoords)

            -- Se estiver perto de alguma zona, diminui o tempo do loop
            if dist < zone.radius + 15.0 then
                sleep = 200
            end

            if dist <= zone.radius then
                if not insideZones[name] then
                    insideZones[name] = true
                    if zone.onEnter then
                        zone.onEnter()
                    end
                    TriggerEvent('fdb-libs:zones:onEnter', name)
                end
                if zone.inside then
                    zone.inside()
                end
            else
                if insideZones[name] then
                    insideZones[name] = nil
                    if zone.onExit then
                        zone.onExit()
                    end
                    TriggerEvent('fdb-libs:zones:onExit', name)
                end
            end
        end

        Wait(sleep)
    end
end)

-- Limpar zonas ao parar o resource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for name, zone in pairs(activeZones) do
            if insideZones[name] then
                if zone.onExit then
                    zone.onExit()
                end
            end
        end
        activeZones = {}
        insideZones = {}
    end
end)

-- Exportações para outros resources
exports('CreateZone', fdb.zones.Create)
exports('RemoveZone', fdb.zones.Remove)
