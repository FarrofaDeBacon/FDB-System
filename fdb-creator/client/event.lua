
if Config.DevMode then
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if IsRawKeyPressed(0x72) then -- F2
            print ("F2 Pressed")
                -- TriggerEvent("fdb-creator:LaunchCharSelect")
                -- TriggerEvent("fdb_creator:LaunchCreator")
                TriggerServerEvent("fdb-creator:getCharacters")
            end
        end
    end)
end

local charselectpeds = {}
-- RegisterNetEvent("fdb-creator:LaunchCharSelect", function()
--     local headsonscreen = {}
--     local id = 0
    
-- end)

RegisterNetEvent("fdb-creator:OpenCharSelect", function()
    TriggerServerEvent("fdb-creator:getCharacters")
end)

Firstname = nil
Lastname = nil
Nationality = nil
Selectedsex = nil
Birthdate = nil
Cid = nil
Skinkosong = false

RegisterNetEvent('fdb-creator:client:OpenCreator', function(data, empty)
    PedAccess = (Config.PedPermission and Config.PedPermission.default ~= nil) and Config.PedPermission.default or true
    TriggerServerEvent("fdb-creator:PutPlayerInInstance")
    
    if data then
        Cid = data.cid
        Firstname = data.firstname
        Lastname = data.lastname
        Nationality = data.nationality
        Selectedsex = data.gender
        Birthdate = data.birthdate
        
        CharacterName = data.firstname
        CharacterSurname = data.lastname
        CharacterBirthDay = 1
        CharacterBirthMonth = 1
        CharacterBirthYear = 1900
        
        local genderStr = (data.gender == 1) and "Male" or "Female"
        local modelStr = (data.gender == 1) and "mp_male" or "mp_female"
        
        CachePedData = deepcopy(DefaultCachePedData)
        CachePedData.gender = genderStr
        CachePedData.pedmodel = { model = modelStr, outfit = 0 }
    elseif empty then
        Skinkosong = true
        CachePedData = deepcopy(DefaultCachePedData)
    else
        CachePedData = deepcopy(DefaultCachePedData)
    end
    
    TriggerEvent("fdb_creator:LaunchCreator")
end)

RegisterNetEvent("fdb_creator:LaunchCreator", function()
    local coords = Config.CharSelect.playerSpawn.coords
    local heading = Config.CharSelect.playerSpawn.heading

    -- Congelar e teleportar jogador antes para carregar colisão e evitar queda no limbo
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), heading)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    LoadSceneForAreaByRadius(coords.x, coords.y, coords.z, 20.0)
    Wait(1000)
    
    -- Initialize CachePedData with default values if not present
    if not CachePedData or not CachePedData.pedmodel then
        CachePedData = deepcopy(DefaultCachePedData)
        print("[fdb-creator] LaunchCreator: Initialized CachePedData with default values")
    end

    local model = CachePedData.pedmodel.model or "mp_male"
    local modelHash = GetHashKey(model)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    if GetEntityModel(PlayerPedId()) ~= modelHash then
        SetPlayerModel(PlayerId(), modelHash)
        local timeout = 0
        while GetEntityModel(PlayerPedId()) ~= modelHash and timeout < 200 do
            Wait(10)
            timeout = timeout + 1
        end
    end
    
    CachePed = PlayerPedId()
    
    SetEntityCoords(CachePed, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(CachePed, heading)
    FreezeEntityPosition(CachePed, true)

    local selectedgender = "female"
    if CachePedData.gender == "Male" then selectedgender = "male" end
    for k, v in pairs(MURPHY_ASSETS[selectedgender]) do
        if hairstyleCache[k] == nil then
            hairstyleCache[k] = {}
            hairstyleCache[k].model = 0
            hairstyleCache[k].texture = 0
        end
    end

    overlay_all_layers = deepcopy(baseoverlay)

    DisplayRadar(false)
    Wait(200)
    EquipMetaPedOutfitPreset(CachePed, 0, false)
    ApplyCachePedDataToPedPlayer()
    RemoveAllClothesExceptEssentials(CachePed)
    Light()
    MoveCam("default")
    SetNuiFocus(true, true)
    SendNUIMessage(
        {
            type = "showCharGlobalMenu",
        }
    )
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- "Second Chance" event - Reopen character customization menu
-- Triggered by admin command to allow player to re-customize their character
-- ═══════════════════════════════════════════════════════════════════════════
SecondChanceMode = false

RegisterNetEvent("fdb-creator:SecondChance", function()
    SecondChanceMode = true
    
    -- Load existing skin data from database
    Callback.triggerServer("fdb-creator:GetPedData", function(peddata)
        if peddata and next(peddata) ~= nil then
            -- Load existing data into CachePedData
            CachePedData = peddata
            print("[fdb-creator] SecondChance: Loaded existing skin data")
        else
            print("[fdb-creator] SecondChance: No existing data, using current ped data")
        end
        
        -- Initialize hair cache
        local selectedgender = "female"
        if CachePedData.gender == "Male" then selectedgender = "male" end
        for k, v in pairs(MURPHY_ASSETS[selectedgender]) do
            if hairstyleCache[k] == nil then
                hairstyleCache[k] = {}
                hairstyleCache[k].model = 0
                hairstyleCache[k].texture = 0
            end
        end
        
        -- Reset overlay layers
        overlay_all_layers = deepcopy(baseoverlay)
        
        -- Load existing barber data (hairstyles, overlays/makeup)
        Callback.triggerServer("fdb-barber:GetCurrentHairs", function(hairData, outfitId, overlays, permanentoverlay)
            if hairData and next(hairData) ~= nil then
                hairstyleCache = hairData
                print("[fdb-creator] SecondChance: Loaded existing hairstyle data")
            end
            
            -- Load overlay data into overlay_all_layers
            if permanentoverlay and next(permanentoverlay) ~= nil then
                for name, data in pairs(permanentoverlay) do
                    if overlay_all_layers[name] then
                        for field, val in pairs(data) do
                            overlay_all_layers[name][field] = val
                        end
                    end
                end
                print("[fdb-creator] SecondChance: Loaded existing overlay data")
            end
            
            -- Use current ped
            CachePed = PlayerPedId()
            
            Wait(10)
            
            -- Safety check
            if not CachePedData or not CachePedData.pedmodel then
                print("[fdb-creator] Error: CachePedData not initialized properly")
                SecondChanceMode = false
                return
            end
            
            DisplayRadar(false)
            Wait(200)
            Light()
            MoveCam("default")
            SetNuiFocus(true, true)
            
            -- Open directly the apparence menu (not the character info menu)
            print("[fdb-creator] SecondChance: Sending showSecondChanceMenu to NUI")
            SendNUIMessage({
                type = "showSecondChanceMenu"
            })
            
            -- Small delay to ensure the flag is set before the menu loads
            Wait(50)
            
            -- Load the apparence menu with current data
            print("[fdb-creator] SecondChance: Calling LoadApparenceMenu")
            LoadApparenceMenu()
            
            -- Wait for camera to move in front of character
            Wait(1500)
            
            -- Enable pins display and start the update loop
            DisplayPins = true
            OpenApperanceMenu()
        end)
    end)
end)

RegisterCommand(Config.LoadSkinCommand, function (source, args, raw)
    TriggerEvent("fdb-creator:loadskin")
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(charselectpeds) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
    end
end)