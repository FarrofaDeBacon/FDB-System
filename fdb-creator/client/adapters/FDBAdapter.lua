-- ============================================================
-- FDB System | fdb-creator | client/adapters/FDBAdapter.lua
-- FDB Framework adapter for creator
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
if Config.framework == 'fdb-core' then
    local myChars          = {}
    charselectpeds         = {}
    headsonscreen          = {}
    PedAccess              = false
    PlayerInfo             = {}
    PlayerSex              = {}
    local RSGCore          = exports['fdb-core']:GetCoreObject()
    local currentCharacter = nil
    local creatingCharacter = false -- Prevent duplicate character creation

    RegisterNetEvent('fdb-creator:LaunchCharSelect', function(characters, pedperm, slots)
        currentCharacter = nil
        creatingCharacter = false -- Reset character creation flag
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        -- Protection: empÃªcher la boucle mort de rsg-medic pendant le menu
        if LocalPlayer and LocalPlayer.state then
            LocalPlayer.state:set('invincible', true, true)
        end
        headsonscreen          = {}
        charselectpeds         = {}
        myChars                = {}
        PlayerInfo             = {}
        PlayerSex              = {}
        ActiveCam              = 0
        currentCamDestionation = ""
        camCoords              = {}
        baseHeading            = false
        rotatePedIndex         = 0
        PedAccess              = pedperm
        DoScreenFadeOut(500)
        Wait(500)
        DisplayRadar(false)
        DisplayHud(false)
        TriggerEvent('fdb-hudpremium:client:toggleHud', false)
        SetEntityCoords(PlayerPedId(), Config.CharSelect.playerSpawn.coords)
        FreezeEntityPosition(PlayerPedId(), true)
        SetEntityInvincible(PlayerPedId(), true)
        SetEntityCanBeDamaged(PlayerPedId(), false)
        RequestCollisionAtCoord(Config.CharSelect.playerSpawn.coords)
        local interiorId = GetInteriorAtCoords(Config.CharSelect.playerSpawn.coords)
        if interiorId ~= 0 then
            PinInteriorInMemory(interiorId)
            for k, v in pairs(Config.CharSelect.interior_sets) do
                if not IsInteriorEntitySetActive(interiorId, v) then
                    ActivateInteriorEntitySet(interiorId, v)
                end
            end
        end
        MoveCam("charselect",
            {
                coords = DecorSettings.charselectcam.coords,
                target = DecorSettings.charselectcam.target,
                fov =
                    DecorSettings.charselectcam.fov
            }, true)
        local remainingslots = slots

        for key, value in pairs(characters) do
            myChars[#myChars + 1] = value
        end
        print("Remaining slots: " .. remainingslots)
        print("myChars: " .. #myChars)
        
        -- Calculate actual available slots (can be negative if player has more chars than allowed slots)
        local availableNewSlots = remainingslots - #myChars
        
        -- Only add empty character slots if player has slots available
        if availableNewSlots > 0 then
            for i = 1, availableNewSlots do
                table.insert(myChars, { charIdentifier = 0 })
            end
        end
        
        -- Always display ALL existing characters, regardless of slot count
        local totalSlotsToDisplay = math.max(#myChars, remainingslots)
        local slotCounter = totalSlotsToDisplay
        
        for key, value in pairs(myChars) do
            local data = DecorSettings.pedslots[slotCounter]
            if slotCounter > 0 then
                slotCounter = slotCounter - 1
            else
                break
            end
            if value.citizenid ~= nil then
                PlayerInfo[key] = {
                    firstname = value.charinfo.firstname,
                    lastname = value.charinfo.lastname,
                    characterid = value.citizenid,
                    informations = value.informations,
                    charid = value.citizenid,
                }
                if value.charinfo.gender == 0 then
                    PlayerSex[key] = 1
                else
                    PlayerSex[key] = 0
                end
                if value.peddata and next(value.peddata) ~= nil then
                    local peddata = value.peddata
                    local model = GetHashKey(peddata.pedmodel.model)
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(100)
                    end

                    SetPlayerModel(PlayerId(), model)
                    -- EquipMetaPedOutfitPreset(PlayerPedId(), 0, false)
                    -- local PedHandler = PlayerPedId()
                    IsPedReadyToRender(PlayerPedId())
                    -- while not DoesEntityExist(PlayerPedId()) do
                    --     Wait(100)
                    -- end
                    if peddata.pedmodel.model ~= "mp_female" and peddata.pedmodel.model ~= "mp_male" then
                        EquipMetaPedOutfitPreset(PlayerPedId(), peddata.pedmodel.outfit, false)
                    end

                    RemoveHairsAndBeards(PlayerPedId())
                    ApplyCachePedDataToPed(PlayerPedId(), peddata, value.citizenid)
                    Wait(3000)
                    data.PedHandler = ClonePed(PlayerPedId(), false, true, true)
                    charselectpeds[key] = data.PedHandler
                    SetEntityCoords(data.PedHandler, data.coords)
                    SetEntityHeading(data.PedHandler, data.heading)
                    NetworkSetEntityInvisibleToNetwork(data.PedHandler, true)
                    SetEntityAsMissionEntity(data.PedHandler, true, true)
                    -- Citizen.InvokeNative(0x283978A15512B2FE, data.PedHandler, true) -- random outfit
                    SetEntityInvincible(data.PedHandler, true)
                    SetEntityCanBeDamagedByRelationshipGroup(data.PedHandler, false, GetHashKey("PLAYER"))
                else
                    print("Loading existing character: " .. tostring(value.citizenid))
                    RSGCore.Functions.TriggerCallback('fdb-multicharacter:server:getAppearance', function(appearance)
                        if appearance == nil or next(appearance) == nil then
                            print("No appearance data found for character: " .. tostring(value.citizenid))
                        else
                            local skinTable = appearance.skin or {}
                            DataSkin = appearance.skin
                            local clothesTable = appearance.clothes or {}
                            local sex = tonumber(skinTable.sex) == 1 and `mp_male` or `mp_female`
                            print("Loading skin for character: " .. tostring(value.citizenid))
                            if sex ~= nil then
                                RequestModel(sex)
                                while not HasModelLoaded(sex) do
                                    Wait(0)
                                end
                                data.PedHandler = CreatePed(sex, data.coords, 0.0, false, false, false, false)
                                repeat Wait(0) until DoesEntityExist(data.PedHandler)
                                charselectpeds[key] = data.PedHandler
                                -- EquipMetaPedOutfitPreset(data.PedHandler, 0, false)
                                SetEntityCoords(data.PedHandler, data.coords)
                                SetEntityHeading(data.PedHandler, data.heading)
                                FreezeEntityPosition(data.PedHandler, false)
                                SetEntityInvincible(data.PedHandler, true)
                                SetBlockingOfNonTemporaryEvents(data.PedHandler, true)
                                NetworkSetEntityInvisibleToNetwork(data.PedHandler, true)
                                SetEntityAsMissionEntity(data.PedHandler, true, true)
                                print(data.PedHandler, Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, data.PedHandler),
                                    GetEntityCoords(data.PedHandler))
                                while Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, data.PedHandler) ~= 1 do
                                    Wait(1)
                                end
                                exports['fdb-appearance']:ApplySkinMultiChar(skinTable, data.PedHandler, clothesTable)
                                print("Character skin applied: " .. tostring(value.citizenid))
                                TriggerEvent("fdb_clothes:ApplyClothesToCharid", value.citizenid, data.PedHandler)
                                TriggerEvent("fdb-barber:loadbarberoverlayOnCharacter", value.citizenid,
                                    data.PedHandler)
                            end
                        end
                    end, value.citizenid)
                end
            else
                print("Loading new character: " .. tostring(value.citizenid))
                local NPCGender = "Female"
                local genderrole = math.random(1, 2)
                if genderrole == 1 then NPCGender = "Male" end
                local model = GetHashKey("mp_female")
                if NPCGender == "Male" then
                    model = GetHashKey("mp_male")
                end
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(100)
                end
                data.PedHandler = CreatePed_2(model, 0.0, 0.0, 0.0, 0.0, false, true)
                while not DoesEntityExist(data.PedHandler) do
                    Wait(100)
                end

                SetEntityCoords(data.PedHandler, data.coords)
                SetEntityHeading(data.PedHandler, data.heading)
                charselectpeds[key] = data.PedHandler
                NetworkSetEntityInvisibleToNetwork(data.PedHandler, true)
                SetEntityAsMissionEntity(data.PedHandler, true, true)
                Citizen.InvokeNative(0x283978A15512B2FE, data.PedHandler, true)
                SetEntityInvincible(data.PedHandler, true)
                SetEntityCanBeDamagedByRelationshipGroup(data.PedHandler, false, GetHashKey("PLAYER"))
                EquipMetaPedOutfitPreset(data.PedHandler, 3, false)
                -- FreezeEntityPosition(ped, true)
                SetEntityAlpha(data.PedHandler, 150, false)
            end
            if data.scenario then
                TaskStartScenarioInPlace(data.PedHandler, data.scenario, -1, false)
            end
            if data.scenariopoint then
                local DataStruct = DataView.ArrayBuffer(256 * 4)
                local is_data_exists = Citizen.InvokeNative(0x345EC3B7EBDE1CB5, GetEntityCoords(data.PedHandler), 1.5,
                    DataStruct:Buffer(), 10)
                if is_data_exists ~= false then
                    for i = 1, is_data_exists, 1 do
                        local scenario = DataStruct:GetInt32(8 * i)
                        local hash = GetScenarioPointType(scenario)
                        print("Scenario Hash: " .. hash)
                        if data.scenariopoint == hash then
                            TaskUseScenarioPoint(data.PedHandler, scenario, 0, 0, false);
                        end
                    end
                end
            end
            Wait(1000)
            local headCoords = GetPedBoneCoords(data.PedHandler, 21030, 0.0, 0.0, 0.0)
            local retval, headx, heady = GetScreenCoordFromWorldCoord(headCoords.x, headCoords.y,
                headCoords.z + 0.2)
            local ExistingChar = false
            local name = "none"
            if value.citizenid ~= nil then
                ExistingChar = true
                name = value.charinfo.firstname .. " " .. value.charinfo.lastname
            end

            table.insert(headsonscreen, {
                id = key,
                name = name,
                ExistingChar = ExistingChar,
                startPosition = {
                    x = headx,
                    y = heady
                }
            })
        end

        print("headsonscreen: " .. #headsonscreen)
        print(json.encode(headsonscreen))
        SendNUIMessage(
            {
                type = "updateElemSelectCharMenu",
                pinsSelectChar = {},
            }
        )
        DoScreenFadeIn(500)
        Wait(500)

        SetNuiFocus(true, true)
        SendNUIMessage(
            {
                type = "openSelectCharMenu",
                pinsSelectChar = headsonscreen,
            }
        )
    end)

    RegisterNetEvent("fdb_creator:PlaySelectedChar", function(id)
        TriggerServerEvent("fdb-creator:RemovePlayerFromInstance")
        DoScreenFadeOut(0)
        repeat Wait(0) until IsScreenFadedOut()
        Wait(1000)
        SwitchOffCam(false)
        DisplayRadar(true)
        DisplayHud(true)
        TriggerEvent('fdb-hudpremium:client:toggleHud', true)
        TriggerServerEvent('fdb-multicharacter:server:loadUserData', myChars[id])
        currentCharacter = myChars[id].citizenid
        Wait(5000)
        TriggerServerEvent('fdb-appearance:server:LoadSkin')
        Wait(500)
        TriggerServerEvent('fdb-appearance:server:LoadClothes', 1)
        local PlayerData = RSGCore.Functions.GetPlayerData()
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        SetEntityCoords(ped, PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
        SetEntityHeading(ped, PlayerData.position.w)
        TriggerServerEvent('FDBCore:Server:OnPlayerLoaded')
        TriggerEvent('FDBCore:Client:OnPlayerLoaded')

        if PlayerData.metadata["injail"] > 0 then
            Wait(2000)
            TriggerEvent('fdb-prison:client:prisonclothes')
        end
        Wait(1000)
        DoScreenFadeIn(1000)
    end)

    AddEventHandler("FDBCore:Client:OnPlayerLoaded", function()
        Wait(1000)
        -- Ne retire pas lâ€™invincibilitÃ© avant le chargement du skin
        if LocalPlayer and LocalPlayer.state then
            LocalPlayer.state:set('invincible', true, true)
        end
        SetEntityInvincible(PlayerPedId(), true)
        SetEntityCanBeDamaged(PlayerPedId(), false)
        TriggerEvent("fdb-creator:loadskin")
    end)
    local healthinit = false
    RegisterNetEvent("fdb-creator:loadskin", function()
        -- SÃ©curiser toute la phase de swap model/skin
        if LocalPlayer and LocalPlayer.state then
            LocalPlayer.state:set('invincible', true, true)
        end
        SetEntityInvincible(PlayerPedId(), true)
        SetEntityCanBeDamaged(PlayerPedId(), false)

        Callback.triggerServer("fdb-creator:GetPedData", function(peddata)
            print("Loading skin")
            CachePedData = peddata
            local PlayerData = RSGCore.Functions.GetPlayerData()
            repeat
                Wait(100)
                print("Waiting for PlayerData to match currentCharacter: " ..
                    tostring(PlayerData.citizenid) .. " vs " .. tostring(currentCharacter))
                PlayerData = RSGCore.Functions.GetPlayerData()
            until PlayerData.citizenid == currentCharacter
            local isDead = PlayerData.metadata["isdead"]
            if isDead == nil then isDead = false end
            print("Player is dead: " .. tostring(isDead))
            if isDead == true then return end -- Si mort, on ne charge pas le skin (Ã©vite les bugs)
            
            -- VÃ©rifier si le model doit Ãªtre changÃ©
            local currentModel = GetEntityModel(PlayerPedId())
            local targetModel = nil
            if CachePedData and CachePedData.pedmodel and CachePedData.pedmodel.model then
                targetModel = GetHashKey(CachePedData.pedmodel.model)
            end
            local needsModelChange = (targetModel == nil) or (currentModel ~= targetModel)
            
            local ped
            local healthCore, stamCore, health, stam
            
            -- Sauvegarder les valeurs de vie/stamina AVANT le changement de modèle si nécessaire
            -- if needsModelChange then
            --     healthCore = GetAttributeCoreValue(PlayerPedId(), 0) -- Get health core value
            --     stamCore = GetAttributeCoreValue(PlayerPedId(), 1)   -- Get stamina core value
            --     health = GetEntityHealth(PlayerPedId())              -- Get health value
            --     stam = Citizen.ResultAsFloat(Citizen.InvokeNative(0x22F2A386D43048A9, PlayerPedId()))
            --     print("[FDB-CREATOR] Model needs change, saving health/stamina - HealthCore: " .. tostring(healthCore) .. ", StamCore: " .. tostring(stamCore) .. ", Health: " .. tostring(health) .. ", Stam: " .. tostring(stam))
            -- else
            --     print("[FDB-CREATOR] Model already correct, skipping health/stamina save/restore")
            -- end

            if next(CachePedData) == nil then
                --- If no data in fdb_creator, load default skin for framework
                print("No skin data in fdb_creator")
                TriggerServerEvent('fdb-appearance:server:LoadSkin')
            else
                local model = CachePedData.pedmodel.model
                local outfit = CachePedData.pedmodel.outfit
                print("Loading skin: " .. model .. " : " .. outfit)
                ped = PlayerPedId()
                if model == "mp_male" or model == "mp_female" then
                    RequestModel(GetHashKey(model))
                    while not HasModelLoaded(GetHashKey(model)) do
                        Wait(1)
                    end
                    SetPlayerModel(PlayerId(), GetHashKey(model))
                    Wait(1000)
                    ped = PlayerPedId()
                    CachePed = PlayerPedId()
                    SetModelAsNoLongerNeeded(GetHashKey(model))


                    if model == "mp_female" then
                        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, CachePed, 2, false)    -- EquipMetaPedOutfitPreset avec preset 2

                        while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, CachePed) do -- IsPedReadyToRender
                            Wait(0)
                        end

                        Citizen.InvokeNative(0x0BFA1BD465CDFEFD, CachePed)                                 -- ResetPedComponents

                        Citizen.InvokeNative(0xAAB86462966168CE, CachePed, true)                           -- Fixes outfit
                        Citizen.InvokeNative(0xCC8CA3E88256E58F, CachePed, false, true, true, true, false) -- UpdatePedVariation
                    else
                        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, CachePed, 0, false)                       -- EquipMetaPedOutfitPreset avec preset 0

                        while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, CachePed) do                    -- IsPedReadyToRender
                            Wait(0)
                        end
                    end

                    local SkinColor   = DefaultChar[CachePedData.gender][CachePedData.skintone]
                    local legs        = tonumber("0x" .. SkinColor.Legs[CachePedData.lowerbody])
                    local bodyType    = tonumber("0x" .. SkinColor.Body[CachePedData.upperbody])
                    local heads       = tonumber("0x" .. SkinColor.Heads[CachePedData.head])
                    local headtexture = joaat(SkinColor.HeadTexture[1])
                    local albedo      = texture_types[CachePedData.gender].albedo
                    print(CachePed, "Heads:", heads, "BodyType:", bodyType, "Legs:", legs, "HeadTexture:", headtexture,
                        "Albedo:", albedo)
                    IsPedReadyToRender(CachePed)
                    RemoveAllClothesExceptEssentials(CachePed)
                    ApplyShopItemToPed(heads, CachePed)
                    ApplyShopItemToPed(bodyType, CachePed)
                    ApplyShopItemToPed(legs, CachePed)
                    Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)
                    UpdatePedVariation(CachePed)
                    if CachePedData.head > 0 then
                        print("Loading head: " .. CachePedData.head)
                        local head = tonumber("0x" ..
                            DefaultChar[CachePedData.gender][CachePedData.skintone].Heads[CachePedData.head])
                        ApplyShopItemToPed(head, CachePed)
                    end
                    if CachePedData.lowerbody > 0 then
                        local comp = DefaultChar[CachePedData.gender][CachePedData.skintone].Legs
                            [CachePedData.lowerbody]
                        ApplyShopItemToPed(tonumber("0x" .. comp), CachePed)
                        TriggerEvent("fdb_clothes:Loadlowerbody", tonumber("0x" .. comp))
                    end
                    if CachePedData.upperbody > 0 then
                        local comp = DefaultChar[CachePedData.gender][CachePedData.skintone].Body
                            [CachePedData.upperbody]
                        ApplyShopItemToPed(tonumber("0x" .. comp), CachePed)
                        TriggerEvent("fdb_clothes:Loadupperbody", tonumber("0x" .. comp))
                    end
                    if CachePedData.body > 0 then
                        local comp = tonumber(Body[CachePedData.body])
                        EquipMetaPedOutfit(comp, CachePed)
                    end
                    if CachePedData.waist > 0 then
                        local comp = tonumber(Waist[CachePedData.waist])
                        EquipMetaPedOutfit(comp, CachePed)
                    end
                else
                    NPCAssetsToPed(model, outfit, PlayerPedId())
                    CachePed = PlayerPedId()
                end


                if CachePedData.teeth > 0 then
                    ApplyShopItemToPed(Teeth[CachePedData.gender][CachePedData.teeth].hash, CachePed)
                end

                if CachePedData.eyes > 0 then
                    ApplyShopItemToPed(Eyes[CachePedData.gender][CachePedData.eyes], CachePed)
                end
                IsPedReadyToRender(CachePed)
                for k, v in pairs(CachePedData.expressions) do
                    print("Expression: " .. k .. " : " .. v)
                    SetCharExpression(CachePed, ExpressionsHashes[k], v)
                end
                UpdatePedVariation(CachePed)
            end
            TriggerEvent("fdb_clothing:loadclothes")
            TriggerEvent("fdb-barber:loadbarberoverlay")

            Wait(1000)
            
            local currentHealth
            print("Is Dead: " .. tostring(isDead), isDead)
            print("DEBUG FASE 2: healthinit status before check = " .. tostring(healthinit))
            if isDead == true then
                currentHealth = 0
            else
                if healthinit == true then
                    currentHealth = 600
                    TriggerServerEvent('fdb-medic:server:SetHealth', currentHealth)
                    healthinit = false
                else
                    currentHealth = PlayerData.metadata["health"]
                    -- SÃ©curitÃ©: Ã©viter 0 HP avec isDead=false
                    if (not currentHealth or currentHealth <= 0) then
                        currentHealth = 100
                        TriggerServerEvent('fdb-medic:server:SetHealth', currentHealth)
                    end
                end
            end
            print("Current Health: " .. tostring(currentHealth))
            SetEntityHealth(PlayerPedId(), currentHealth)

            -- Restaurer vie/stamina SEULEMENT si le modèle a été changé
            -- if needsModelChange then
            --     Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 0, healthCore) -- Set Health Core back to what it was
            --     Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 1, stamCore)   -- Set Stamina Core back to what it was
            --     Citizen.InvokeNative(0x675680D089BFA21F, PlayerPedId(), stam or 100.0) -- RestorePedStamina
            --     print("[FDB-CREATOR] Restored health/stamina after model change")
            -- end

            SetEntityInvincible(PlayerPedId(), false)
            SetEntityCanBeDamaged(PlayerPedId(), true)
            if LocalPlayer and LocalPlayer.state then
                LocalPlayer.state:set('invincible', false, true)
            end
        end)
    end)

    RegisterNetEvent("fdb-creator:createnewchar", function(data)
        print("DEBUG FASE 2: Event fdb-creator:createnewchar FIRED!")
        if creatingCharacter then
            print("Character creation already in progress, ignoring duplicate call")
            return
        end
        creatingCharacter = true
        currentCharacter = nil
        TriggerServerEvent('fdb-multicharacter:server:createCharacter', data)
        Wait(2000)
        exports.weathersync:setSyncEnabled(true)
        TriggerServerEvent('FDBCore:Server:OnPlayerLoaded')
        TriggerEvent('FDBCore:Client:OnPlayerLoaded')
        TriggerServerEvent("fdb-creator:RemovePlayerFromInstance")
        Wait(2000)
        healthinit = true
        creatingCharacter = false
        -- TriggerEvent("fdb-creator:loadskin")
    end)
    RegisterNetEvent("fdb-creator:rsg:getcitizenid", function(charid)
        print("Received citizenid for new char: " .. tostring(charid))
        currentCharacter = charid
    end)
end

