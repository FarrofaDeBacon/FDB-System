local FDBCore = exports['fdb-core']:GetCoreObject()
lib.locale()

RegisterNetEvent('fdb-spawn:client:setupSpawnUI', function(cData, new)
    if new == false then
        TriggerEvent('fdb-spawn:client:existingplayer')
        exports.weathersync:setSyncEnabled(true)
    else
        TriggerEvent('fdb-spawn:client:newplayer')
    end
end)

RegisterNetEvent('fdb-spawn:client:existingplayer', function()
    local PlayerData = FDBCore.Functions.GetPlayerData()
    local isJailed = PlayerData.metadata["injail"]
    local firstname = PlayerData.charinfo.firstname
    local lastname = PlayerData.charinfo.lastname
    local citizenid = PlayerData.citizenid
    local randomIndex = math.random(1, #Config.RandomTips)
    local randomTip = Config.RandomTips[randomIndex]
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 1122662550, 347053089, 0, firstname .. ' ' .. lastname,
        locale('cl_lang_1') .. citizenid, locale('cl_lang_2') .. ' ' .. randomTip)
    Wait(10000)

    DoScreenFadeOut(1000)
    -- FDB-TODO: rsg-appearance integration pending audit (line 26)
    exports['rsg-appearance']:ApplySkin()

    -- set player health
    local currentHealth = PlayerData.metadata["health"]
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, currentHealth)
    SetEntityCoords(playerPed, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
    SetEntityHeading(playerPed, PlayerData.position.w)
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true)

    -- [fdb-weapons] AutoDualWield: chamada removida.
    -- O evento 'rsg-weapons:client:AutoDualWield' nunca teve handler no rsg-weapons
    -- original nem no fdb-weapons. Feature não implementada — decisão pendente.

    ShutdownLoadingScreen()
    DoScreenFadeIn(1000)
    TriggerServerEvent('FDBCore:Server:OnPlayerLoaded')
    TriggerEvent('FDBCore:Client:OnPlayerLoaded')
end)

local function OpenNUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "OPEN_SPAWN_MENU",
        locations = Config.SpawnLocations
    })
end

local function SpawnChar(coords)
    local PlayerData = FDBCore.Functions.GetPlayerData()
    local firstname = PlayerData.charinfo.firstname
    local lastname = PlayerData.charinfo.lastname
    local citizenid = PlayerData.citizenid
    local randomIndex = math.random(1, #Config.RandomTips)
    local randomTip = Config.RandomTips[randomIndex]
    Citizen.InvokeNative(0x1E5B70E53DB661E5, 1122662550, 347053089, 0, firstname .. ' ' .. lastname,
        locale('cl_lang_1') .. citizenid, locale('cl_lang_2') .. ' ' .. randomTip)
    Wait(10000)
    DoScreenFadeOut(1000)

    -- FDB-TODO: rsg-appearance integration pending audit (line 68)
    exports['rsg-appearance']:ApplySkin()
    local ped = PlayerPedId()

    SetEntityCoordsNoOffset(ped, coords, true, true, true)
    SetEntityHeading(ped, coords.w)
    FreezeEntityPosition(ped, false)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
    -- [fdb-weapons] AutoDualWield: chamada removida.
    -- O evento 'rsg-weapons:client:AutoDualWield' nunca teve handler no rsg-weapons
    -- original nem no fdb-weapons. Feature não implementada — decisão pendente.
    ShutdownLoadingScreen()
    ExecuteCommand('revive')
    DoScreenFadeIn(1000)
    TriggerServerEvent('FDBCore:Server:OnPlayerLoaded')
    TriggerEvent('FDBCore:Client:OnPlayerLoaded')
end

RegisterNUICallback('spawnSelected', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "CLOSE_MENU" })

    local chosenId = data.locationId

    for _, loc in pairs(Config.SpawnLocations) do
        if loc.id == chosenId then
            SpawnChar(loc.coords)
            break
        end
    end

    cb('ok')
end)


RegisterNetEvent('fdb-spawn:client:newplayer', function()
    if not Config.SelectLocations then
        SpawnChar(Config.SpawnLocation.coords)
    else
        OpenNUI()
    end
end)
