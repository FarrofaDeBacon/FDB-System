-- https://github.com/femga/rdr3_discoveries/blob/a4b4bcd5a3006b0c1434b03e4095d038164932f7/discoveredNatives/discovered_natives_by_community

local RSGCore = exports['rsg-core']:GetCoreObject()

-- normal walkstyle
RegisterNetEvent('walkstyles:client:normal')
AddEventHandler('walkstyles:client:normal', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'default')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'normal')
    TriggerServerEvent('walkstyles:server:sync', 'default', 'normal')
end)

-- angry walkstyle
RegisterNetEvent('walkstyles:client:angry')
AddEventHandler('walkstyles:client:angry', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'default')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'angry')
    TriggerServerEvent('walkstyles:server:sync', 'default', 'angry')
end)

-- war_veteran walkstyle
RegisterNetEvent('walkstyles:client:war_veteran')
AddEventHandler('walkstyles:client:war_veteran', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'war_veteran')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'normal')
    TriggerServerEvent('walkstyles:server:sync', 'war_veteran', 'normal')
end)

-- gold_panner walkstyle
RegisterNetEvent('walkstyles:client:gold_panner')
AddEventHandler('walkstyles:client:gold_panner', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'gold_panner')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'normal')
    TriggerServerEvent('walkstyles:server:sync', 'gold_panner', 'normal')
end)

-- lost_Man walkstyle
RegisterNetEvent('walkstyles:client:lost_Man')
AddEventHandler('walkstyles:client:lost_Man', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'lost_Man')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'normal')
    TriggerServerEvent('walkstyles:server:sync', 'lost_Man', 'normal')
end)

-- murfree walkstyle
RegisterNetEvent('walkstyles:client:murfree')
AddEventHandler('walkstyles:client:murfree', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'murfree')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'normal')
    TriggerServerEvent('walkstyles:server:sync', 'murfree', 'normal')
end)

-- primate walkstyle
RegisterNetEvent('walkstyles:client:primate')
AddEventHandler('walkstyles:client:primate', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x923583741DC87BCE, ped, 'primate')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, 'normal')
    TriggerServerEvent('walkstyles:server:sync', 'primate', 'normal')
end)

-- receive networked walkstyle from other players
RegisterNetEvent('walkstyles:client:syncRemote')
AddEventHandler('walkstyles:client:syncRemote', function(playerSrc, clipset, style)
    local ped = GetPlayerPed(GetPlayerFromServerId(playerSrc))
    if ped and ped ~= 0 then
        Citizen.InvokeNative(0x923583741DC87BCE, ped, clipset)
        Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, style)
    end
end)
