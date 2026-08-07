
if Config.DevMode then
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if IsRawKeyPressed(0x72) then -- F2
            print ("F2 Pressed")
                -- TriggerEvent("murphy_creator:LaunchCharSelect")
                -- TriggerEvent("murphy_creator:LaunchCreator")
                TriggerServerEvent("murphy_creator:getCharacters")
            end
        end
    end)
end

local charselectpeds = {}
-- RegisterNetEvent("murphy_creator:LaunchCharSelect", function()
--     local headsonscreen = {}
--     local id = 0
    
-- end)

RegisterNetEvent("murphy_creator:OpenCharSelect", function()
    TriggerServerEvent("murphy_creator:getCharacters")
end)

RegisterNetEvent("murphy_creator:LaunchCreator", function()
    FreezeEntityPosition(PlayerPedId(), false)
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


    local model = "mp_male"
    local coords = Config.CharSelect.playerSpawn.coords
    local heading = Config.CharSelect.playerSpawn.heading
    -- RequestModel(GetHashKey(model))
    -- while not HasModelLoaded(GetHashKey(model)) do
    --     Wait(1)
    -- end
    -- SetPlayerModel(PlayerId(), GetHashKey(model))
    -- local entity = CreatePed_2(GetHashKey(model), 0.0,0.0,0.0, 0.0, false, true)
    -- repeat
    --     Wait(1)
    -- until DoesEntityExist(entity)
    Wait(10) 
    -- EquipMetaPedOutfitPreset(CachePed, 3, false)
    
    -- Safety check before applying ped data
    if not CachePedData or not CachePedData.pedmodel then
        print("[murphy_creator] Error: CachePedData not initialized properly")
        return
    end
    
    SetEntityCoords(CachePed, coords)
    SetEntityHeading(CachePed, heading)

    DisplayRadar(false)
    Wait(200)
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

RegisterNetEvent("murphy_creator:SecondChance", function()
    SecondChanceMode = true
    
    -- Load existing skin data from database
    Callback.triggerServer("murphy_creator:GetPedData", function(peddata)
        if peddata and next(peddata) ~= nil then
            -- Load existing data into CachePedData
            CachePedData = peddata
            print("[murphy_creator] SecondChance: Loaded existing skin data")
        else
            print("[murphy_creator] SecondChance: No existing data, using current ped data")
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
        Callback.triggerServer("murphy_barber_creator:GetCurrentHairs", function(hairData, outfitId, overlays, permanentoverlay)
            if hairData and next(hairData) ~= nil then
                hairstyleCache = hairData
                print("[murphy_creator] SecondChance: Loaded existing hairstyle data")
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
                print("[murphy_creator] SecondChance: Loaded existing overlay data")
            end
            
            -- Use current ped
            CachePed = PlayerPedId()
            
            Wait(10)
            
            -- Safety check
            if not CachePedData or not CachePedData.pedmodel then
                print("[murphy_creator] Error: CachePedData not initialized properly")
                SecondChanceMode = false
                return
            end
            
            DisplayRadar(false)
            Wait(200)
            Light()
            MoveCam("default")
            SetNuiFocus(true, true)
            
            -- Open directly the apparence menu (not the character info menu)
            print("[murphy_creator] SecondChance: Sending showSecondChanceMenu to NUI")
            SendNUIMessage({
                type = "showSecondChanceMenu"
            })
            
            -- Small delay to ensure the flag is set before the menu loads
            Wait(50)
            
            -- Load the apparence menu with current data
            print("[murphy_creator] SecondChance: Calling LoadApparenceMenu")
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
    TriggerEvent("murphy_creator:loadskin")
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