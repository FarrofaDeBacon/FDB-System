FDBCore = exports['fdb-core']:GetCoreObject()
local clothing = require 'data.clothing'
local isLoggedIn = false
BucketId = GetRandomIntInRange(0, 0xffffff)
ComponentsMale = {}
ComponentsFemale = {}
LoadedComponents = {}
CreatorCache = {}

MenuData = {}

TriggerEvent("fdb-menubase:getData", function(call)
    MenuData = call
end)

Firstname = nil
Lastname = nil
Nationality = nil
Selectedsex = nil
Birthdate = nil
Cid = nil

local Data = require 'data.features'
local Overlays = require 'data.overlays'
local clotheslist = require 'data.clothes_list'
local hairs_list = require 'data.hairs_list'

AddEventHandler('FDBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = FDBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('FDBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
end)

local MainMenus = {
    ["body"] = function()
        OpenBodyMenu()
    end,
    ["face"] = function()
        OpenFaceMenu()
    end,
    ["hair"] = function()
        OpenHairMenu()
    end,
    ["makeup"] = function()
        OpenMakeupMenu()
    end
}

local BodyFunctions = {
    ["head"] = function(target, data)
        LoadBoody(target, data)
    end,
    ["face_width"] = function(target, data)
        LoadFeatures(target, data)
    end,
    ["skin_tone"] = function(target, data)
        LoadBoody(target, data)
        LoadOverlays(target, data)
    end,
    ["body_size"] = function(target, data)
        LoadBodyFeature(target, data.body_size, Data.Appearance.body_size)
        LoadBoody(target, data)
    end,
    ["body_waist"] = function(target, data)
        LoadBodyFeature(target, data.body_waist, Data.Appearance.body_waist)
    end,
    ["chest_size"] = function(target, data)
        LoadBodyFeature(target, data.chest_size, Data.Appearance.chest_size)
    end,
    ["height"] = function(target, data)
        LoadHeight(target, data)
    end
}

local FaceFunctions = {
    ["eyes"] = function()
        OpenEyesMenu()
    end,
    ["eyelids"] = function()
        OpenEyelidsMenu()
    end,
    ["eyebrows"] = function()
        OpenEyebrowsMenu()
    end,
    ["nose"] = function()
        OpenNoseMenu()
    end,
    ["mouth"] = function()
        OpenMouthMenu()
    end,
    ["cheekbones"] = function()
        OpenCheekbonesMenu()
    end,
    ["jaw"] = function()
        OpenJawMenu()
    end,
    ["ears"] = function()
        OpenEarsMenu()
    end,
    ["chin"] = function()
        OpenChinMenu()
    end,
    ["defects"] = function()
        OpenDefectsMenu()
    end
}

local HairFunctions = {
    ["hair"] = function(target, data)
        LoadHair(target, data)
    end,
    ["beard"] = function(target, data)
        LoadBeard(target, data)
    end
}

local EyesFunctions = {
    ["eyes_color"] = function(target, data)
        LoadEyes(target, data)
    end,
    ["eyes_depth"] = function(target, data)
        LoadFeatures(target, data)
    end,
    ["eyes_angle"] = function(target, data)
        LoadFeatures(target, data)
    end,
    ["eyes_distance"] = function(target, data)
        LoadFeatures(target, data)
    end
}

local EyelidsFunctions = {
    ["eyelid_height"] = function(target, data)
        LoadFeatures(target, data)
    end,
    ["eyelid_width"] = function(target, data)
        LoadFeatures(target, data)
    end
}

local EyebrowsFunctions = {
    ["eyebrows_t"] = function(target, data)
        LoadOverlays(target, data)
    end,
    ["eyebrows_op"] = function(target, data)
        LoadOverlays(target, data)
    end,
    ["eyebrows_id"] = function(target, data)
        LoadOverlays(target, data)
    end,
    ["eyebrows_c1"] = function(target, data)
        LoadOverlays(target, data)
    end,
    ["eyebrow_height"] = function(target, data)
        LoadFeatures(target, data)
    end,
    ["eyebrow_width"] = function(target, data)
        LoadFeatures(target, data)
    end,
    ["eyebrow_depth"] = function(target, data)
        LoadFeatures(target, data)
    end
}

CreateThread(function()
    for i, v in pairs(clotheslist) do
        if v.category_hashname == "BODIES_LOWER" or v.category_hashname == "BODIES_UPPER" or v.category_hashname ==
            "heads" or v.category_hashname == "hair" or v.category_hashname == "teeth" or v.category_hashname == "eyes" then
            if v.ped_type == "female" and v.is_multiplayer and v.hashname ~= "" then
                if ComponentsFemale[v.category_hashname] == nil then
                    ComponentsFemale[v.category_hashname] = {}
                end
                table.insert(ComponentsFemale[v.category_hashname], v.hash)
            elseif v.ped_type == "male" and v.is_multiplayer and v.hashname ~= "" then
                if ComponentsMale[v.category_hashname] == nil then
                    ComponentsMale[v.category_hashname] = {}
                end
                table.insert(ComponentsMale[v.category_hashname], v.hash)
            end
        end
        if v.category_hashname == "heads" and v.is_multiplayer and v.hashname ~= "" then
            if HeadHashTable == nil then
                HeadHashTable = {}
            end
            HeadHashTable[v.hashname] = v.hash
        end
    end
    if not IsImapActive(183712523) then
        RequestImap(183712523) -- CharacterCreator
    end
    if not IsImapActive(-1699673416) then
        RequestImap(-1699673416) -- CharacterCreator
    end
    if not IsImapActive(1679934574) then
        RequestImap(1679934574) -- CharacterCreator
    end
end)

function ApplySkin()
    local _Target = PlayerPedId()
    local citizenid = FDBCore.Functions.GetPlayerData().citizenid
    local currentHealth = LocalPlayer.state.health or GetEntityHealth(_Target)
    local dirtClothes = GetAttributeBaseRank(_Target, 16)
    local dirtHat = GetAttributeBaseRank(_Target, 17)
    local dirtSkin = GetAttributeBaseRank(_Target, 22)

    local promise = promise.new()
    FDBCore.Functions.TriggerCallback('fdb-multicharacter:server:getAppearance', function(data)
        local _SkinData = data.skin
        local _Clothes = data.clothes
        if _Target == PlayerPedId() then
            local model = GetPedModel(tonumber(_SkinData.sex))
            LoadModel(PlayerPedId(), model)
            _Target = PlayerPedId()
            SetEntityAlpha(_Target, 0)
            LoadedComponents = _SkinData
        end
        FixIssues(_Target)
        LoadHeight(_Target, _SkinData)
        LoadBoody(_Target, _SkinData)
        LoadHead(_Target, _SkinData)
        LoadHair(_Target, _SkinData)
        LoadBeard(_Target, _SkinData)
        LoadEyes(_Target, _SkinData)
        LoadFeatures(_Target, _SkinData)
        LoadBodyFeature(_Target, _SkinData.body_size, Data.Appearance.body_size)
        LoadBodyFeature(_Target, _SkinData.body_waist, Data.Appearance.body_waist)
        LoadBodyFeature(_Target, _SkinData.chest_size, Data.Appearance.chest_size)
        LoadOverlays(_Target, _SkinData)
        SetAttributeCoreValue(_Target, 0, 100)
        SetAttributeCoreValue(_Target, 1, 100)
        SetEntityHealth(_Target, currentHealth, 0)
        Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId(), 0.0)
        Citizen.InvokeNative(0xDE1B1907A83A1550, _Target, 0)
        if _Target == PlayerPedId() then
            TriggerEvent('fdb-appearance:client:ApplyClothes', _Clothes, _Target, _SkinData)
        else
            for i, m in pairs(Overlays.overlay_all_layers) do
                Overlays.overlay_all_layers[i] =
                { name = m.name, visibility = 0, tx_id = 1, tx_normal = 0, tx_material = 0, tx_color_type = 0, tx_opacity = 1.0, tx_unk = 0, palette = 0, palette_color_primary = 0, palette_color_secondary = 0, palette_color_tertiary = 0, var = 0, opacity = 0.0 }
            end
        end
        SetAttributeBaseRank(_Target, 16, dirtClothes)
        SetAttributeBaseRank(_Target, 17, dirtHat)
        SetAttributeBaseRank(_Target, 22, dirtSkin)
        promise:resolve()
    end, citizenid)
    Citizen.Await(promise)
end

local function ApplySkinMultiChar(SkinData, Target, ClothesData)
    FixIssues(Target)
    LoadHeight(Target, SkinData)
    LoadBoody(Target, SkinData)
    LoadHead(Target, SkinData)
    LoadHair(Target, SkinData)
    LoadBeard(Target, SkinData)
    LoadEyes(Target, SkinData)
    LoadFeatures(Target, SkinData)
    LoadBodyFeature(Target, SkinData.body_size, Data.Appearance.body_size)
    LoadBodyFeature(Target, SkinData.body_waist, Data.Appearance.body_waist)
    LoadBodyFeature(Target, SkinData.chest_size, Data.Appearance.chest_size)
    LoadOverlays(Target, SkinData)
    TriggerEvent('fdb-appearance:client:ApplyClothes', ClothesData, Target, SkinData)
end

exports('ApplySkinMultiChar', ApplySkinMultiChar)

RegisterNetEvent('fdb-appearance:client:OpenCreator', function(data, empty)
    if data then
        Cid = data.cid
    elseif empty then
        Skinkosong = true
    end

    StartCreator()

end)

RegisterCommand('creator', function(source, args, raw)
    TriggerEvent('fdb-appearance:client:OpenCreator', nil, true)
end, false)

RegisterCommand('loadskin', function(source, args, raw)
    if LocalPlayer.state.invincible then return end
    LocalPlayer.state.invincible = true

    local ped = PlayerPedId()
    local isdead = IsEntityDead(ped)
    local cuffed = IsPedCuffed(ped)
    local hogtied = Citizen.InvokeNative(0x3AA24CCC0D451379, ped)
    local lassoed = Citizen.InvokeNative(0x9682F850056C9ADE, ped)
    local dragged = Citizen.InvokeNative(0xEF3A8772F085B4AA, ped)
    local ragdoll = IsPedRagdoll(ped)
    local falling = IsPedFalling(ped)
    local isJailed = 0

    FDBCore.Functions.GetPlayerData(function(player)
        isJailed = player.metadata["injail"]
    end)

    if isdead or cuffed or hogtied or lassoed or dragged or ragdoll or falling or isJailed > 0 then
        LocalPlayer.state.invincible = false
        return
    end

    ApplySkin()
    
    LocalPlayer.state.invincible = false
end, false)

local function checkStrings(input)
    if RSG.ProfanityWords[input:lower()] then return false end
    if not string.match(input, '^%u%l+$') then
        lib.notify({ title = locale('invalid_character_name.title'), description = locale('invalid_character_name.description'), type = 'error', duration = 7000 })
        return false
    end
    return true
end

function StartCreator()
    TriggerServerEvent('fdb-appearance:server:SetPlayerBucket' , BucketId)
    Wait(1)
    for i, m in pairs(Overlays.overlay_all_layers) do
        Overlays.overlay_all_layers[i] =
        {name = m.name, visibility = 0, tx_id = 1, tx_normal = 0, tx_material = 0, tx_color_type = 0, tx_opacity = 1.0, tx_unk = 0, palette = 0, palette_color_primary = 0, palette_color_secondary = 0, palette_color_tertiary = 0, var = 0, opacity = 0.0}
    end
    MenuData.CloseAll()
    SpawnPeds()
end

function FirstMenu()
    print("^2[fdb-appearance] FirstMenu called! Sending openCreator to NUI...^0")
    CreatorCache = CreatorCache or {}
    ClothesCache = ClothesCache or {}

    local ped = PlayerPedId()
    local sex = IsPedMale(ped) and 'male' or 'female'

    -- Calcular limites máximos dinamicamente
    local maxValues = {
        hair = hairs_list[sex] and hairs_list[sex]["hair"] and #hairs_list[sex]["hair"] or 50,
        beard = hairs_list[sex] and hairs_list[sex]["beard"] and #hairs_list[sex]["beard"] or 0,
        shirt = clothing[sex] and clothing[sex]["shirts_full"] and #clothing[sex]["shirts_full"] or 100,
        vest = clothing[sex] and clothing[sex]["vests"] and #clothing[sex]["vests"] or 50,
        pants = clothing[sex] and clothing[sex]["pants"] and #clothing[sex]["pants"] or 100,
        boots = clothing[sex] and clothing[sex]["boots"] and #clothing[sex]["boots"] or 100,
        hat = clothing[sex] and clothing[sex]["hats"] and #clothing[sex]["hats"] or 50,
    }

    -- Enviar mensagem para abrir NUI do Criador em Svelte
    SendNUIMessage({
        action = 'openCreator',
        sex = sex,
        cache = CreatorCache,
        maxValues = maxValues
    })
    SetNuiFocus(true, true)
    print("^2[fdb-appearance] SetNuiFocus(true, true) executed^0")
end

-- Helper local para puxar hash do vestuário cacheado
local function GetClothingHash(category, model, texture)
    if not model or model == 0 then return nil end
    texture = texture or 0
    local sex = IsPedMale(PlayerPedId()) and 'male' or 'female'
    local list = clothing[sex][category]
    if list and list[model] and list[model][texture] then
        return list[model][texture].hash
    end
    return nil
end

-- NUI Callbacks

RegisterNUICallback('nuiReady', function(data, cb)
    print("^2[fdb-appearance] NUI Ready Handshake received successfully from Svelte App!^0")
    cb('ok')
end)

RegisterNUICallback('rotatePed', function(data, cb)
    local rotation = tonumber(data.rotation)
    if rotation then
        SetEntityHeading(PlayerPedId(), pedloc.w + rotation)
    end
    cb('ok')
end)

RegisterNUICallback('changeCamera', function(data, cb)
    local cameraType = data.camera
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    
    local targetZ = pedCoords.z
    local fov = 60.0
    
    if cameraType == 'face' then
        targetZ = pedCoords.z + 0.65
        fov = 32.0
    elseif cameraType == 'torso' then
        targetZ = pedCoords.z + 0.2
        fov = 45.0
    elseif cameraType == 'legs' then
        targetZ = pedCoords.z - 0.5
        fov = 38.0
    elseif cameraType == 'full' then
        targetZ = pedCoords.z + 0.15
        fov = 60.0
    end
    
    if CharacterCreatorCamera then
        SetCamFov(CharacterCreatorCamera, fov)
        PointCamAtCoord(CharacterCreatorCamera, pedCoords.x, pedCoords.y, targetZ)
    end
    cb('ok')
end)

RegisterNUICallback('onChange', function(data, cb)
    local category = data.type
    local key = data.key
    local value = data.value
    
    CreatorCache[key] = value
    local playerPed = PlayerPedId()
    
    if category == 'feature' then
        local hash = Data.features[key]
        if hash then
            local floatVal = (value / 100) * 1.0
            NativeSetPedFaceFeature(playerPed, hash, floatVal)
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerPed, false, true, true, true, false)
        end
    elseif category == 'overlay' then
        LoadOverlays(playerPed, CreatorCache)
        if key == 'hair' then
            LoadHair(playerPed, CreatorCache)
        elseif key == 'beard' then
            LoadBeard(playerPed, CreatorCache)
        end
    elseif category == 'clothing' then
        ClothesCache[key] = { model = value, texture = 0 }
        
        -- Mapeia a key simplificada da UI para as categorias do clothing.lua
        local componentName
        if key == 'shirt' then
            componentName = "shirts_full"
        elseif key == 'pants' then
            componentName = "pants"
        elseif key == 'boots' then
            componentName = "boots"
        elseif key == 'vest' then
            componentName = "vests"
        elseif key == 'hat' then
            componentName = "hats"
        end
        
        if componentName then
            local hashVal = GetClothingHash(componentName, value, 1)
            if hashVal and hashVal ~= 0 then
                exports['fdb-libs']:ApplyComponent(playerPed, componentName, hashVal, true)
            else
                exports['fdb-libs']:RemoveComponent(playerPed, componentName)
            end
        end
    elseif category == 'genetics' then
        if key == 'head' or key == 'skin_tone' then
            LoadBoody(playerPed, CreatorCache)
        end
    end
    
    cb('ok')
end)

RegisterNUICallback('saveCreator', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeCreator' })
    
    LoadedComponents = CreatorCache
    
    if Skinkosong then
        Skinkosong = false
        Firstname = FDBCore.Functions.GetPlayerData().charinfo.firstname
        Lastname = FDBCore.Functions.GetPlayerData().charinfo.lastname
        FotoMugshots()
    elseif Firstname and Lastname and Nationality and Selectedsex and Birthdate and Cid then
        local newData = {
            firstname = Firstname,
            lastname = Lastname,
            nationality = Nationality,
            gender = Selectedsex == 1 and 0 or 1,
            birthdate = Birthdate,
            cid = Cid
        }
        TriggerServerEvent('fdb-multicharacter:server:createCharacter', newData)
        Wait(500)
        FotoMugshots()
    else
        -- Fallback de teste ou salvamento direto
        FotoMugshots()
    end
    cb('ok')
end)

exports('GetComponentId', function(name)
    return LoadedComponents[name]
end)

exports('GetBodyComponents', function()
    return {ComponentsMale, ComponentsFemale}
end)

exports('GetBodyCurrentComponentHash', function(name)
    local hash
    if name == "hair" or name == "beard" then
        local info = LoadedComponents[name]

        if not info then return end

        local texture = info.texture
        local model = info.model
        if model == 0 or texture == 0 then
            return
        end
        if type(info) == "table" then
            if IsPedMale(PlayerPedId()) then
                if hairs_list["male"][name][model][texture] ~= nil then
                    hash = hairs_list["male"][name][model][texture].hash
                end
            else
                if hairs_list["female"][name][model][texture] ~= nil then
                    hash = hairs_list["female"][name][model][texture].hash
                end
            end
        end
    elseif name == "BODIES_UPPER" or name == "BODIES_LOWER" then
        local body_size = tonumber(LoadedComponents.body_size or 1)
        local skin_tone = tonumber(LoadedComponents.skin_tone or 1)
        local id = GetSkinColorFromBodySize(body_size, skin_tone) or 1
        if IsPedMale(PlayerPedId()) then
            if ComponentsMale[name] ~= nil then
                hash = ComponentsMale[name][id]
            end
        else
            if ComponentsFemale[name] ~= nil then
                hash = ComponentsFemale[name][id]
            end
        end
    else
        local id = LoadedComponents[name]
        if not id then
            id = 1
        end
        if IsPedMale(PlayerPedId()) then
            if ComponentsMale[name] ~= nil then
                hash = ComponentsMale[name][id]
            end
        else
            if ComponentsFemale[name] ~= nil then
                hash = ComponentsFemale[name][id]
            end
        end
    end
    return hash
end)

exports('SetFaceOverlays', function(target, data)
    LoadOverlays(target, data)
end)

exports('SetHair', function(target, data)
    LoadHair(target, data)
end)

exports('SetBeard', function(target, data)
    LoadBeard(target, data)
end)

exports('GetComponentsMax', function(name)
    if name == "hair" or name == "beard" then
        if IsPedMale(PlayerPedId()) then
            if hairs_list["male"][name] ~= nil then
                return #hairs_list["male"][name]
            end
        else
            if hairs_list["female"][name] ~= nil then
                return #hairs_list["female"][name]
            end
        end
    else
        if IsPedMale(PlayerPedId()) then
            if ComponentsMale[name] ~= nil then
                return #ComponentsMale[name]
            end
        else
            if ComponentsFemale[name] ~= nil then
                return #ComponentsFemale[name]
            end
        end
    end
end)

exports('GetMaxTexturesForModel', function(category , model)
    return GetMaxTexturesForModel(category,model)
end)

exports('ApplySkin', ApplySkin)