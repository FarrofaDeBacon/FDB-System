local FDBCore = exports['fdb-core']:GetCoreObject()
local isOpen = false

RegisterNetEvent('fdb-configui:client:openPanel', function(resource, config, supportedScripts)
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openConfigPanel',
        resource = resource,
        config = config,
        supportedScripts = supportedScripts
    })
end)

RegisterNUICallback('closePanel', function(data, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb(1)
end)

RegisterNUICallback('saveConfig', function(data, cb)
    -- data = { resource = "fdb-medical-core", path = "Wounds.Bleeding.DrainRate", value = 0.05 }
    local result = lib.callback.await('fdb-configui:server:saveConfig', false, data.resource, data.path, data.value)
    cb(result)
end)
RegisterNUICallback('fetchConfig', function(data, cb)
    local config = lib.callback.await('fdb-configui:server:fetchConfig', false, data.resource)
    cb({config = config})
end)
RegisterNUICallback('resetConfig', function(data, cb)
    local result = lib.callback.await('fdb-configui:server:resetConfig', false, data.resource)
    cb(result)
end)
