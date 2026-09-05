-- ============================================================
-- FDB System | fdb-creator | client/NUI/NUICallbacks.lua
-- NUI callback handlers for creator
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
local camOnHead = false
local processingcam = false
local teethanim = false
local eyesanim = false
local changingGender = false
-- Callback for showing the edition menu
RegisterNUICallback("showEditionMenu", function(data, cb)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    local pinId = data.pinId
    local pinName = data.pinName
    local elemId = data.elemId
    local subElemName = data.subElemName
    DisplayPins = false

    if elemId == "barber" then
        OpenBarberMenu()
    elseif elemId == "clothes" then
        CreatorLight = false
        OpenClothesMenu()
    else
        local arrayData = {}
        if EditionElem[elemId] then
            -- Convertir la table en tableau indexÃ© numÃ©riquement
            for _, i in pairs(EditionElem[elemId].division) do
                for j, elem in pairs(i.elements) do
                    if elem.type == "slider" then
                        if CachePedData.expressions[elem.id] == nil then
                            elem.startValue = 50
                        else
                            elem.startValue = scale(CachePedData.expressions[elem.id], ExpressionsMaxValues[elem.id].min,
                                ExpressionsMaxValues[elem.id].max, 0, 100)
                        end
                    end
                    if elem.type == "matrice" then
                        if CachePedData.expressions[elem.XHashes] == nil then
                            elem.startPositionX = 0.5
                        else
                            elem.startPositionX = scale(CachePedData.expressions[elem.XHashes],
                                ExpressionsMaxValues[elem.XHashes].min,
                                ExpressionsMaxValues[elem.XHashes].max, 0, 1)
                        end
                        if CachePedData.expressions[elem.YHashes] == nil then
                            elem.startPositionY = 0.5
                        else
                            elem.startPositionY = scale(CachePedData.expressions[elem.YHashes],
                                ExpressionsMaxValues[elem.YHashes].min,
                                ExpressionsMaxValues[elem.YHashes].max, 0, 1)
                        end
                    end
                    -- Mise Ã  jour des valeurs pour les slider_legacy depuis CachePedData
                    if elem.type == "slider_legacy" then
                        if elem.id == "head" and CachePedData.head then
                            elem.value = CachePedData.head
                        elseif elem.id == "tooth" and CachePedData.teeth then
                            elem.value = CachePedData.teeth
                        end
                    end
                end
            end
            local elem = deepcopy(EditionElem[elemId])
            if elemId == "headshape" then
                if CachePedData.pedmodel.model ~= "mp_male" and CachePedData.pedmodel.model ~= "mp_female" then
                    table.remove(elem.division, 1)
                end
            end
            table.insert(arrayData, elem)
            ------------------
            --- Renvoyer les startpositions
        end
        EditionMenu(true, arrayData)

        -- Add your logic here
    end
    SendNUIMessage(
        {
            type = "hideEditApparenceMenu",

        }
    )
    if elemId == "eyes" then
        SendNUIMessage(
            {
                type = "openEyesPersoMenu",
                eyesColours = EyeColours
            }
        )
    end
    MoveCam(pinId)
    Wait(1001)
end)

-- Callback for canceling character edition
RegisterNUICallback("cancelCharEdition", function(data, cb)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    MoveCam("edit")
    EditionMenu(false)
    local ped = CachePed
    local x, y, z = table.unpack(GetEntityCoords(ped))
    if not baseHeading then
        baseHeading = GetEntityHeading(ped)
        -- Stocker l'offset initial pour que 180 corresponde Ã  baseHeading
        angleOffset = 180 - baseHeading
    end
    local targetHeading = (180 - angleOffset) % 360
    local rad = math.rad(targetHeading)
    local distance = 1.0
    local targetX = x + (math.sin(-rad) * distance)
    local targetY = y + (math.cos(-rad) * distance)
    TaskTurnPedToFaceCoord(ped, targetX, targetY, z, 0)
    DisplayPins = true

    Wait(1000)

    LoadApparenceMenu()

    OpenApperanceMenu()

    -- Add your logic here

    cb("ok")
end)

RegisterNetEvent("fdb_creator:BackFromClothing", function()
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    ActiveCam = 0
    MoveCam("edit")

    EditionMenu(false)
    local ped = CachePed
    local x, y, z = table.unpack(GetEntityCoords(ped))
    if not baseHeading then
        baseHeading = GetEntityHeading(ped)
        -- Stocker l'offset initial pour que 180 corresponde Ã  baseHeading
        angleOffset = 180 - baseHeading
    end
    local targetHeading = (180 - angleOffset) % 360
    local rad = math.rad(targetHeading)
    local distance = 1.0
    local targetX = x + (math.sin(-rad) * distance)
    local targetY = y + (math.cos(-rad) * distance)
    TaskTurnPedToFaceCoord(ped, targetX, targetY, z, 0)
    DisplayPins = true
    Light()
    Wait(1000)
    SendNUIMessage({ type = "showGlobalCharacterMenu" })
    LoadApparenceMenu()
    OpenApperanceMenu()
end)

-- Callback for handling camera changes
local currentCamH = 25
local currentCamR = 180
local lastDest = ""

RegisterNUICallback("cameraChange", function(data, cb)
    local cameraName = data.cameraName
    local value = data.value
    
    if cameraName == "Z" then
        local outputvalue = scale(value, 1, 360, 15.0, 50.0)
        if ActiveCam == 1 then
            SetCamFov(Cam1, outputvalue)
        else
            SetCamFov(Cam2, outputvalue)
        end
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        return
    end

    local dest = currentCamDestionation
    if lastDest ~= dest then
        currentCamH = 25
        currentCamR = 180
        lastDest = dest
    end

    if cameraName == "H" then
        currentCamH = tonumber(value) or 25
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
    elseif cameraName == "R" then
        currentCamR = tonumber(value) or 180
        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
    end

    local currentCam = (ActiveCam == 1) and Cam1 or Cam2
    local ped = CachePed
    if DoesCamExist(currentCam) and camCoords[ped] and camCoords[ped][dest] then
        local baseCoords = camCoords[ped][dest].coords
        local baseTarget = camCoords[ped][dest].target
        local pedCoords = GetEntityCoords(ped)

        local hOffset = 0.0
        if currentCamH >= 25 then
            hOffset = scale(currentCamH, 25, 360, 0.0, 0.60)
        else
            hOffset = scale(currentCamH, 1, 25, -0.8, 0.0)
        end
        
        local rAngle = currentCamR - 180.0
        local rad = math.rad(rAngle)
        local s = math.sin(rad)
        local c = math.cos(rad)
        
        local dx = baseCoords.x - pedCoords.x
        local dy = baseCoords.y - pedCoords.y
        local rotatedCamX = pedCoords.x + (dx * c - dy * s)
        local rotatedCamY = pedCoords.y + (dx * s + dy * c)
        
        local tx = baseTarget.x - pedCoords.x
        local ty = baseTarget.y - pedCoords.y
        local rotatedTargetX = pedCoords.x + (tx * c - ty * s)
        local rotatedTargetY = pedCoords.y + (tx * s + ty * c)
        
        local finalCamCoords = vector3(rotatedCamX, rotatedCamY, baseCoords.z + hOffset)
        local finalTarget = vector3(rotatedTargetX, rotatedTargetY, baseTarget.z + hOffset)
        
        SetCamCoord(currentCam, finalCamCoords)
        PointCamAtCoord(currentCam, finalTarget)
    end
end)

-- Callback for handling matrix element updates
RegisterNUICallback("matriceElem", function(data, cb)
    local item = data.item
    local matriceId = data.matriceId
    local x = data.X
    local y = data.Y

    local XHashes = data.XHashes
    local YHashes = data.YHashes
    local Xoutputvalue = scale(x, 0, 1, ExpressionsMaxValues[XHashes].min, ExpressionsMaxValues[XHashes].max)
    local Youtputvalue = scale(y, 0, 1, ExpressionsMaxValues[YHashes].min, ExpressionsMaxValues[YHashes].max)

    local ped = CachePed

    PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
    IsPedReadyToRender(ped)
    SetCharExpression(ped, ExpressionsHashes[XHashes], Xoutputvalue)
    SetCharExpression(ped, ExpressionsHashes[YHashes], Youtputvalue)
    CachePedData.expressions[XHashes] = Xoutputvalue
    CachePedData.expressions[YHashes] = Youtputvalue
    UpdatePedVariation(ped)
end)

-- Callback for handling matrix element updates
RegisterNUICallback("sliderCharChange", function(data, cb)
    local value = data.value
    local ElementID = data.ElementID
    local ped = CachePed
    local outputvalue = scale(value, 0, 100, ExpressionsMaxValues[ElementID].min, ExpressionsMaxValues[ElementID].max)
    PlaySound("Amount_Increase", "HUD_Donate_Sounds")

    IsPedReadyToRender(ped)
    SetCharExpression(ped, ExpressionsHashes[ElementID], outputvalue)
    CachePedData.expressions[ElementID] = outputvalue
    UpdatePedVariation(ped)
end)

RegisterNUICallback("cancelCharCreation", function(data, cb)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    
    -- Normal cancel behavior for character creation
    CachePedData = deepcopy(DefaultCachePedData)
    ApplyCachePedDataToPedPlayer()
    SendNUIMessage(
        {
            type = "hideCharGlobalMenu",
        }
    )
    MoveCam("charselect",
        {
            coords = DecorSettings.charselectcam.coords,
            target = DecorSettings.charselectcam.target,
            fov = DecorSettings
                .charselectcam.fov
        }, false)
    Wait(1500)
    SendNUIMessage(
        {
            type = "openSelectCharMenu",
            pinsSelectChar = headsonscreen,
        }
    )
end)

RegisterNUICallback("CreateChar", function(data, cb)
    -- Normal character creation flow
    CharacterName = nil
    SendNUIMessage({ type = "getAllCharDatas", })
    repeat
        Wait(100)
    until CharacterName ~= nil
    if tostring(CharacterName) == "" or tostring(CharacterSurname) == "" or tostring(CharacterBirthDay) == "" or tostring(CharacterBirthMonth) == "" or tostring(CharacterBirthYear) == "" then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        print("Missing informations, please fill all fields")
    else
        -- if CachePed ~= PlayerPedId() then
        -- DeleteEntity(CachePed)
        -- end
        PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
        SendNUIMessage(
            {
                type = "hideCharGlobalMenu",
            }
        )
        Wait(1000)
        SendNUIMessage(
            {
                type = "openSpawnMenu",
                spawnLocation = SpawnLocation,
            }
        )
    end
end)

local canspawn = true
RegisterNUICallback("spawnPreview", function(data, cb)
    local spawnLocationId = data.SpawnLocationId
    local spawnLocationName = data.SpawnLocationName
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    canspawn = false
    SetEntityCoords(PlayerPedId(), SpawnLocation[spawnLocationId].pedspawn)
    SetEntityHeading(PlayerPedId(), SpawnLocation[spawnLocationId].pedspawnheading)
    FreezeEntityPosition(PlayerPedId(), true)
    DoScreenFadeOut(1000)
    for k, v in pairs(charselectpeds) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    Wait(1000)
    Citizen.InvokeNative("0x387AD749E3B69B70", SpawnLocation[spawnLocationId].coords, 0.0, 0.0, 0.0, 5.0, 0) --- Load the scene
    while not IsLoadSceneLoaded() do
        Wait(100)
    end
    Citizen.InvokeNative("0x5A8B01199C3E79C3") -- Stop the loading
    MoveCam(spawnLocationName,
        {
            coords = SpawnLocation[spawnLocationId].coords,
            target = SpawnLocation[spawnLocationId].target,
            fov =
                SpawnLocation[spawnLocationId].fov
        }, true)
    Wait(1000)
    DoScreenFadeIn(1000)
    Wait(1000)
    canspawn = true
end)


RegisterNUICallback("spawnCharacter", function(data, cb)
    if canspawn then
        canspawn = false -- Prevent multiple clicks
        local spawnLocationId = data.SpawnLocationId
        local spawnLocationName = data.SpawnLocationName
        PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
        SetNuiFocus(false, false)
        DoScreenFadeOut(500)
        -- TriggerServerEvent("redemrp:createCharacter", "test", "test")
        data.firstname = CharacterName
        data.lastname = CharacterSurname
        data.coords = SpawnLocation[spawnLocationId].pedspawn
        data.lore = CharacterLore
        data.birthday = CharacterBirthDay
        data.birthmonth = CharacterBirthMonth
        data.birthyear = CharacterBirthYear
        data.gender = CachePedData.gender
        data.pedspawn = SpawnLocation[spawnLocationId].pedspawn
        data.pedspawnheading = SpawnLocation[spawnLocationId].pedspawnheading
        data.skintone = CachePedData.skintone
        data.body = tonumber("0x" .. DefaultChar[CachePedData.gender][CachePedData.skintone].Body
            [CachePedData.upperbody])
        data.legs = tonumber("0x" .. DefaultChar[CachePedData.gender][CachePedData.skintone].Legs
            [CachePedData.lowerbody])
        DeleteObject(lamp)
        DeleteObject(lamp2)
        SwitchOffCam(true)
        CreatorLight = false
        SendNUIMessage(
            {
                type = "hideSpawnMenu",
            }
        )
        SetEntityCoords(PlayerPedId(), SpawnLocation[spawnLocationId].pedspawn)
        SetEntityHeading(PlayerPedId(), SpawnLocation[spawnLocationId].pedspawnheading)
        FreezeEntityPosition(PlayerPedId(), true)
        Callback.triggerServer('fdb-creator:CreateNewCharacter', function(result)
            if result then
                print("Character created successfully")
                Callback.triggerServer('fdb-creator:SavePreset', function(result, outfitid)
                    print("Saving preset with outfit ID:", outfitid)
                    if result then
                        print("Preset saved successfully")
                        
                        -- Save clothes data from fdb-clothing
                        local clothesData = exports['fdb-clothing']:GetClothesCache()
                        if clothesData then
                            local nonZero = 0
                            for k, v in pairs(clothesData) do
                                if v.model and v.model ~= 0 then
                                    nonZero = nonZero + 1
                                end
                            end
                            print("[fdb-creator] Saving clothes on character creation - items with clothes: " .. tostring(nonZero))
                            TriggerServerEvent('fdb_clothing:SaveCurrentClothes', clothesData, 0)
                        else
                            print("[fdb-creator] WARNING: No clothes data from fdb-clothing export!")
                        end
                        
                        SetEntityCoords(PlayerPedId(), SpawnLocation[spawnLocationId].pedspawn)
                        SetEntityHeading(PlayerPedId(), SpawnLocation[spawnLocationId].pedspawnheading)
                        Wait(2000)
                        DoScreenFadeIn(500)
                        DisplayRadar(true)
                        DisplayHud(true)
                        TriggerEvent('fdb-hudpremium:client:toggleHud', true)
                        FreezeEntityPosition(PlayerPedId(), false)
                        canspawn = true -- Reset after successful creation
                        -- TriggerEvent("fdb-creator:loadskin")
                    else
                        canspawn = true -- Reset on failure
                    end
                end, hairstyleCache, overlay_all_layers, "Base", 0, IsPedMale(PlayerPedId()))
            else
                canspawn = true -- Reset on failure
            end
        end, data, CachePedData)
    else
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        print("You cannot spawn yet, please wait")
    end
end)


RegisterNUICallback("EditChart", function(data, cb)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    if changingGender == true then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        return
    end

    SendNUIMessage(
        {
            type = "hideCharGlobalMenu",
        }
    )
    MoveCam("edit")
    Wait(1200)
    LoadApparenceMenu()
    DisplayPins = true
    OpenApperanceMenu()
end)

RegisterNUICallback("CharValues", function(data, cb)
    CharacterName = data.CharacterName
    CharacterSurname = data.CharacterSurname
    CharacterLore = data.CharacterLore
    CharacterBirthDay = data.CharacterBirthDay
    CharacterBirthMonth = data.CharacterBirthMonth
    CharacterBirthYear = data.CharacterBirthYear
    CharacterIsAPed = data.CharacterIsAPed
    CharacterSexe = data.CharacterSexe
end)


RegisterNUICallback("sexeStatusChanged", function(data, cb)
    if changingGender == false then
        changingGender = true
        CachePedData = deepcopy(DefaultCachePedData)
        SendNUIMessage(
            {
                type = "changeuserSexe",
                userSexe = data.currentSexe,
            }
        )
        local currentSexe = data.currentSexe
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        CreatorLight = false
        Wait(1000)

        local model = "mp_male"
        if currentSexe == "Female" then model = "mp_female" end
        CachePedData.gender = currentSexe
        CachePedData.pedmodel = { model = model, outfit = 0 }
        local coords = Config.CharSelect.playerSpawn.coords
        local heading = Config.CharSelect.playerSpawn.heading
        RequestModel(GetHashKey(model))
        while not HasModelLoaded(GetHashKey(model)) do
            Wait(1)
        end
        if CachePed ~= PlayerPedId() then
            DeleteEntity(CachePed)
        end
        SetPlayerModel(PlayerId(), GetHashKey(model))
        
        -- Safe wait for player model switch to complete
        local tempTimer = 0
        while GetEntityModel(PlayerPedId()) ~= GetHashKey(model) and tempTimer < 500 do
            Wait(10)
            tempTimer = tempTimer + 1
        end
        
        CachePed = PlayerPedId()
        Wait(10)
        EquipMetaPedOutfitPreset(CachePed, 0, false)

        ApplyCachePedDataToPedPlayer()
        RemoveAllClothesExceptEssentials(CachePed)
        TriggerEvent("fdb_clothing:ResetClothesMenuCreator")
        Light()
        SetEntityCoords(CachePed, coords)
        SetEntityHeading(CachePed, heading)
        hairstyleCache = {}
        local selectedgender = "female"
        if CachePedData.gender == "Male" then selectedgender = "male" end
        for k, v in pairs(FDB_ASSETS[selectedgender]) do
            if hairstyleCache[k] == nil then
                hairstyleCache[k] = {}
                hairstyleCache[k].model = 0
                hairstyleCache[k].texture = 0
            end
        end
        Wait(1500)
        changingGender = false
    else
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    end
end)

local cachePedSelection, cachePedVariation = 0, 0
local pedwarning = false
RegisterNUICallback("pedValue", function(data, cb)
    local model = data.id
    local outfit = tonumber(data.item)
    if outfit == nil then outfit = 0 end
    outfit = outfit - 1
    if outfit < 0 then outfit = 0 end
    if cachePedSelection == model and cachePedVariation == outfit then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        return
    end
    local cachegender = CachePedData.gender
    CachePedData = deepcopy(DefaultCachePedData)
    CachePedData.gender = cachegender
    if model ~= cachePedSelection then
        PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
        cachePedSelection = model
        cachePedVariation = outfit
    else
        if cachePedVariation > outfit then
            PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
        else
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        end
        cachePedVariation = outfit
    end
    CachePedData.pedmodel = { model = model, outfit = outfit }

    NPCAssetsToPed(model, outfit)
    
    -- Reposicionar o ped no saloon e forÃ§ar visibilidade apÃ³s troca de modelo
    local coords = Config.CharSelect.playerSpawn.coords
    local heading = Config.CharSelect.playerSpawn.heading
    CachePed = PlayerPedId()
    SetEntityVisible(CachePed, true, 0)
    SetEntityAlpha(CachePed, 255, false)
    ResetEntityAlpha(CachePed)
    SetEntityCoords(CachePed, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(CachePed, heading)
    FreezeEntityPosition(CachePed, true)
    
    DisplayHud(true)
    if pedwarning == false then
        pedwarning = true
        local notifyDuration = 2 * 60 * 1000
        ShowAdvancedRightNotification(Lang.Creator["Ped Warning"], "menu_textures", "menu_icon_alert", "COLOR_RED", notifyDuration)
        Citizen.SetTimeout(notifyDuration, function()
            DisplayHud(false)
        end)
        Citizen.SetTimeout(60 * 5 * 1000, function()
            pedwarning = false
        end)
    end
end)

RegisterNUICallback("PedSelection", function(data, cb)
    if PedAccess == false then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        return
    end
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    SendNUIMessage({ type = "getAllCharDatas", })
    Wait(100)
    SendNUIMessage({ type = "hideCharGlobalMenu", })
    local count = 0
    local modelcount = 0
    local pedtoshow = {}
    for k, v in pairs(PedList[CharacterSexe]) do
        if not string.find(v.name, "cs_") then
            count = count + v.totalAmount
            table.insert(pedtoshow, v)
            modelcount = modelcount + 1
        end
    end
    SendNUIMessage(
        {
            type = "showPedsList",
            pedsList = pedtoshow,
        }
    )
end)

RegisterNUICallback("PedTrueFalse", function(data, cb)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    local userPed = data.userPed
    if userPed == "false" and CachePedData.pedmodel.model ~= "mp_male" and CachePedData.pedmodel.model ~= "mp_female" then
        CreatorLight = false
        Wait(1000)
        local model = "mp_male"
        local gender = CachePedData.gender
        CachePedData = deepcopy(DefaultCachePedData)
        CachePedData.gender = gender
        if CachePedData.gender == "Female" then model = "mp_female" end

        CachePedData.pedmodel = { model = model, outfit = 0 }
        local coords = Config.CharSelect.playerSpawn.coords
        local heading = Config.CharSelect.playerSpawn.heading
        RequestModel(GetHashKey(model))
        while not HasModelLoaded(GetHashKey(model)) do
            Wait(1)
        end
        if CachePed ~= PlayerPedId() then
            DeleteEntity(CachePed)
        end
        SetPlayerModel(PlayerId(), GetHashKey(model))
        CachePed = PlayerPedId()
        Wait(10)
        EquipMetaPedOutfitPreset(CachePed, 0, false)
        ApplyCachePedDataToPedPlayer()
        RemoveAllClothesExceptEssentials(CachePed)
        Light()
        SetEntityCoords(CachePed, coords)
        SetEntityHeading(CachePed, heading)
    end
end)


RegisterNUICallback("cancelPedSelection", function(data, cb)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    SendNUIMessage(
        {
            type = "showCharGlobalMenu",
        }
    )
    -- DisplayHud(false)
end)

RegisterNUICallback("globalApparence", function(data, cb)
    local item = tonumber(data.item)
    local elem = data.elem
    if eyesanim then
        eyesanim = false
        ClearPedTasks(CachePed)
    end
    if processingcam == true then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    else
        if elem == "head" or elem == "tooth" then
            -- if camOnHead == false then
            --     camOnHead = true
            --     processingcam = true
            --     MoveCam("head")
            --     DisplayPins = false
            --     Wait(1000)
            --     processingcam = false
            -- end
            if elem == "tooth" then
                teethanim = true
                if not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") then
                    RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE")
                    repeat Wait(0) until HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE")
                end

                if not IsEntityPlayingAnim(CachePed, "FACE_HUMAN@GEN_MALE@BASE", "Face_Dentistry_Loop", 1) then
                    TaskPlayAnim(CachePed, "FACE_HUMAN@GEN_MALE@BASE", "Face_Dentistry_Loop", 1.0, -1.0, -1, 16, 0.0,
                        false, 0, false, "", false)
                end
                IsPedReadyToRender(CachePed)
                ApplyShopItemToPed(Teeth[CachePedData.gender][item].hash, CachePed)
                UpdatePedVariation(CachePed)
                CachePedData.teeth = item
            else
                if teethanim then
                    teethanim = false
                    ClearPedTasks(CachePed)
                end
            end
            if elem == "head" then
                local heads = tonumber("0x" .. DefaultChar[CachePedData.gender][CachePedData.skintone].Heads[item])
                IsPedReadyToRender(CachePed)
                ApplyShopItemToPed(heads, CachePed)
                UpdatePedVariation(CachePed)
                CachePedData.head = item
                UpdateOverlay(CachePed)
            end
        else
            if elem == "body" then
                local comp = tonumber(Body[item])
                IsPedReadyToRender(CachePed)
                EquipMetaPedOutfit(comp, CachePed)
                UpdatePedVariation(CachePed)
                CachePedData.body = item
            end
            if elem == "waist" then
                local comp = tonumber(Waist[item])
                IsPedReadyToRender(CachePed)
                EquipMetaPedOutfit(comp, CachePed)
                UpdatePedVariation(CachePed)
                CachePedData.waist = item
            end

            if elem == "legs" then
                local comp = DefaultChar[CachePedData.gender][CachePedData.skintone].Legs[item]
                IsPedReadyToRender(CachePed)
                ApplyShopItemToPed(tonumber("0x" .. comp), CachePed)
                UpdatePedVariation(CachePed)
                CachePedData.lowerbody = item
            end

            if elem == "upper" then
                local comp = DefaultChar[CachePedData.gender][CachePedData.skintone].Body[item]
                IsPedReadyToRender(CachePed)
                ApplyShopItemToPed(tonumber("0x" .. comp), CachePed)
                UpdatePedVariation(CachePed)
                CachePedData.upperbody = item
            end
            if elem == "height" then
                local outputvalue = scale(item, 0, 100, HeightMin, HeightMax)
                IsPedReadyToRender(CachePed)
                SetPedScale(CachePed, outputvalue)
                UpdatePedVariation(CachePed)
                CachePedData.height = outputvalue
            end
            for k, v in pairs(CachePedData.expressions) do
                SetCharExpression(CachePed, ExpressionsHashes[k], v)
            end
            UpdatePedVariation(CachePed)
        end
    end
end)

RegisterNUICallback("SkinColourValue", function(data, cb)
    local item = tonumber(data.item)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    CachePedData.skintone  = item
    CachePedData.lowerbody = 1
    CachePedData.upperbody = 1
    CachePedData.head      = 1
    local SkinColor        = DefaultChar[CachePedData.gender][item]
    local legs             = tonumber("0x" .. SkinColor.Legs[CachePedData.lowerbody])
    local bodyType         = tonumber("0x" .. SkinColor.Body[CachePedData.upperbody])
    local heads            = tonumber("0x" .. SkinColor.Heads[CachePedData.head])
    local headtexture      = joaat(SkinColor.HeadTexture[1])
    local albedo           = texture_types[CachePedData.gender].albedo
    IsPedReadyToRender(CachePed)
    ApplyShopItemToPed(heads, CachePed)
    ApplyShopItemToPed(bodyType, CachePed)
    ApplyShopItemToPed(legs, CachePed)
    Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)
    UpdateOverlay(CachePed)
    UpdatePedVariation(CachePed)
end)


RegisterNUICallback("EyeColourValue", function(data, cb)
    local item = tonumber(data.item)

    if processingcam == true then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    else
        PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
        if camOnHead == false then
            camOnHead = true
            processingcam = true
            MoveCam("head")
            DisplayPins = false
            Wait(1000)
            processingcam = false
        end
        eyesanim = true
        if not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") then
            RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE")
            repeat Wait(0) until HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE")
        end

        if not IsEntityPlayingAnim(CachePed, "FACE_HUMAN@GEN_MALE@BASE", "mood_normal_eyes_wide", 1) then
            TaskPlayAnim(CachePed, "FACE_HUMAN@GEN_MALE@BASE", "mood_normal_eyes_wide", 1.0, -1.0, -1, 16, 0.0, false, 0,
                false, "", false)
        end
        IsPedReadyToRender(CachePed)
        ApplyShopItemToPed(Eyes[CachePedData.gender][item], CachePed)
        UpdatePedVariation(CachePed)
        CachePedData.eyes = item
    end
end)

RegisterNUICallback("CancelApparenceEdition", function(data, cb)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    processingcam = false
    camOnHead = false
    teethanim = false
    eyesanim = false
    ClearPedTasks(CachePed)
    DisplayPins = false
    
    -- Check if we're in Second Chance mode (cancel without saving)
    if SecondChanceMode or (data and data.secondChanceMode) then
        SendNUIMessage({ type = "hideGlobalCharacterMenu" })
        SetNuiFocus(false, false)
        DisplayRadar(true)
        
        -- Clean up lights and camera
        SwitchOffCam(true)
        CreatorLight = false
        DeleteObject(lamp)
        DeleteObject(lamp2)
        
        -- Reset second chance mode
        SecondChanceMode = false
        
        -- Reload the original skin
        Wait(500)
        TriggerEvent("fdb-creator:loadskin")
        return
    end
    
    -- Normal mode: go back to character menu
    SendNUIMessage(
        {
            type = "hideEditApparenceMenu",
        }
    )
    MoveCam("base")
    Wait(1200)
    SendNUIMessage(
        {
            type = "showCharGlobalMenu",
        }
    )
end)

RegisterNUICallback("resetApparenceEdition", function(data, cb)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    CachePedData = deepcopy(DefaultCachePedData)
    ApplyCachePedDataToPedPlayer()
end)

RegisterNUICallback("UndressApparenceEdition", function(data, cb)
    if CachePedData.pedmodel.model == "mp_male" or CachePedData.pedmodel.model == "mp_female" then
        RemoveAllClothesExceptEssentials(CachePed)
        PlaySound("Select", "HUD_SHOP_SOUNDSET")
    else
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Second Chance - Save skin and close
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
RegisterNUICallback("SaveSecondChance", function(data, cb)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    
    -- Hide pins immediately
    DisplayPins = false
    
    -- Save the current CachePedData to database
    Callback.triggerServer("fdb-creator:UpdatePedData", function(success)
        if success then
            print("[fdb-creator] SecondChance: Skin data saved successfully")
            
            -- Also save barber data (hairstyles, overlays/makeup)
            Callback.triggerServer('fdb-creator:SavePreset', function(barberResult, outfitid)
                if barberResult then
                    print("[fdb-creator] SecondChance: Barber data saved successfully")
                else
                    print("[fdb-creator] SecondChance: Failed to save barber data (may not exist)")
                end
                
                -- Close the menu
                SendNUIMessage({ type = "hideGlobalCharacterMenu" })
                SetNuiFocus(false, false)
                DisplayRadar(true)
                
                -- Clean up lights and camera
                SwitchOffCam(true)
                CreatorLight = false
                DeleteObject(lamp)
                DeleteObject(lamp2)
                
                -- Reset second chance mode
                SecondChanceMode = false
                
                -- Reload the skin
                Wait(500)
                TriggerEvent("fdb-creator:loadskin")
            end, hairstyleCache, overlay_all_layers, nil, 0, IsPedMale(PlayerPedId()))
        else
            print("[fdb-creator] SecondChance: Failed to save skin data")
            PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        end
    end, CachePedData)
    
    cb("ok")
end)


--- Callback for char selection
local SelectedChar = nil
local isSelectingChar = false
RegisterNUICallback("selectedChar", function(data, cb)
    -- Prevent rapid clicking
    if isSelectingChar then
        print("[fdb-creator] Character selection in progress, please wait...")
        cb("busy")
        return
    end
    isSelectingChar = true
    
    SendNUIMessage(
        {
            type = "hideSelectCharMenu",
        }
    )
    PlaySound("Select", "HUD_SHOP_SOUNDSET")
    local pinId = data.pinId
    local pinName = data.pinName
    SelectedChar = pinId
    MoveCam("selected", nil, nil, charselectpeds[pinId])
    -- MoveCam("selectedped",  {
    --         coords = GetCamCoord(ActualCamera),
    --         target = GetOffsetFromEntityInWorldCoords(charselectpeds[pinId], 0.2, 0.0, 0.2),
    --         fov = 10.0
    --     }, false, charselectpeds[pinId])
    local charinfo = PlayerInfo[SelectedChar]
    local charsex = "Female"
    if PlayerSex[SelectedChar] == 1 then charsex = "Male" end
    local charadata = {
        name = charinfo.firstname .. " " .. charinfo.lastname,
        CharacterSex = charsex,
        lore = charinfo.informations.lore or "No lore",
        DayBirth = charinfo.informations.birthday or 1,
        MonthBirth = charinfo.informations.birthmonth or 1,
        YearBirth = charinfo.informations.birthyear or 2000,
    }
    SendNUIMessage(
        {
            type = "openSelectedCharMenu",
            selectedDataChar = charadata,

        }
    )
    
    -- Reset flag after a delay
    SetTimeout(800, function()
        isSelectingChar = false
    end)
    
    cb("ok")
end)

RegisterNUICallback("PlaySelectedChar", function(data, cb)
    -- Prevent double-clicking  
    if isSelectingChar then
        print("[fdb-creator] Action in progress, please wait...")
        cb("busy")
        return
    end
    isSelectingChar = true
    
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    TriggerEvent("fdb_creator:PlaySelectedChar", SelectedChar)
    for k, v in pairs(charselectpeds) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    
    SendNUIMessage(
        {
            type = "hideSelectedCharMenu",
        }
    )
    SendNUIMessage(
        {
            type = "hideSelectCharMenu",
        }
    )
    SetNuiFocus(false, false)
end)

RegisterNUICallback("DeleteSelectedChar", function(data, cb)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    DoScreenFadeOut(500)
    Wait(500)
    for k, v in pairs(charselectpeds) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    SendNUIMessage(
        {
            type = "hideSelectedCharMenu",
        }
    )
    TriggerServerEvent("fdb-creator:deleteCharacter", SelectedChar)
end)

RegisterNUICallback("CancelSelectedChar", function(data, cb)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    MoveCam("charselect",
        {
            coords = DecorSettings.charselectcam.coords,
            target = DecorSettings.charselectcam.target,
            fov = DecorSettings
                .charselectcam.fov
        }, false)
    SendNUIMessage(
        {
            type = "hideSelectedCharMenu",
        }
    )
    Wait(1000)
    SendNUIMessage(
        {
            type = "openSelectCharMenu",
            pinsSelectChar = headsonscreen,
        }
    )
end)

RegisterNUICallback("createNewChar", function(data, cb)
    SendNUIMessage(
        {
            type = "hideSelectCharMenu",
        }
    )
    TriggerEvent("fdb_creator:LaunchCreator")
    TriggerEvent("fdb_clothing:ResetClothesMenuCreator")
    PlaySound("Select", "HUD_SHOP_SOUNDSET")
end)

