CachePed = PlayerPedId()
CachePedData = {}
CachePedData.expressions = {}
CachePedData.gender = "Male"
CachePedData.pedmodel = { model = "mp_male", outfit = 0 }
CachePedData.skintone = 1
CachePedData.head = 1
CachePedData.teeth = 1
CachePedData.eyes = 1
CachePedData.body = 1
CachePedData.waist = 1
CachePedData.upperbody = 1
CachePedData.lowerbody = 1
CachePedData.height = 1.0
Citizen.CreateThread(function()
    DefaultCachePedData = deepcopy(CachePedData)
end)

hairstyleCache = {}

function scale(value, oldMin, oldMax, newMin, newMax)
    return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
end

function CreatePed_2(modelHash, x, y, z, heading, isNetwork, thisScriptCheck, p7, p8)
    return Citizen.InvokeNative(0xD49F9B0955C367DE, modelHash, x, y, z, heading, isNetwork, thisScriptCheck, p7, p8)
end

function PlaySound(action, soundset)
    PlaySoundFrontend(action, soundset, true, 0)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function NPCAssetsToPed(model, outfit, target)
    local ped = target or CachePed
    local data = {}
    local gender
    local attempt = 0
    if model then
        repeat
            RequestModel(GetHashKey(model))
            while not HasModelLoaded(GetHashKey(model)) do
                Wait(1)
            end
            local pos = GetEntityCoords(ped)
            local entity = CreatePed_2(GetHashKey(model), pos.x, pos.y, pos.z - 10.0, 0.0, false, true)
            repeat
                Wait(1)
            until DoesEntityExist(entity)
            if IsPedMale(entity) then gender = "male" else gender = "female" end
            Wait(10)
            EquipMetaPedOutfitPreset(entity, tonumber(outfit), false)
            Wait(10)
            for index = 0, 100 do
                local drawable, albedo, normal, material = GetMetaPedAssetGuids(entity, index)

                repeat
                    drawable, albedo, normal, material = GetMetaPedAssetGuids(entity, index)
                until drawable ~= nil and albedo ~= nil and normal ~= nil and material ~= nil
                if drawable and drawable ~= 0 then
                    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(entity, index)
                    repeat
                        palette, tint0, tint1, tint2 = GetMetaPedAssetTint(entity, index)
                    until palette ~= nil and tint0 ~= nil and tint1 ~= nil and tint2 ~= nil
                    data[index] = {
                        drawable = drawable,
                        albedo = albedo,
                        normal = normal,
                        material = material,
                        palette =
                            palette,
                        tint0 = tint0,
                        tint1 = tint1,
                        tint2 = tint2
                    }
                end
            end
            DeletePed(entity)
            attempt = attempt + 1
        until
            #data > 0 or attempt > 15
        local playermodel = GetHashKey("mp_" .. gender)
        RequestModel(playermodel)
        while not HasModelLoaded(playermodel) do Wait(100) end
        SetPlayerModel(PlayerId(), playermodel)
        
        -- Safe wait for player model switch to complete
        local tempTimer = 0
        while GetEntityModel(PlayerPedId()) ~= playermodel and tempTimer < 500 do
            Wait(10)
            tempTimer = tempTimer + 1
        end
        
        ped = PlayerPedId()
        CachePed = ped
        Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
        NativeUpdatePedVariation(ped)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, joaat("ammo_pistols"), 0)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, joaat("pants"), 0)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, joaat("bodies_upper"), 0)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, joaat("bodies_lower"), 0)
        NativeUpdatePedVariation(ped)
        SetModelAsNoLongerNeeded(playermodel)
        for k, v in pairs(data) do
            UpdateCustomClothes(ped, v.drawable, v.albedo, v.normal, v.material, v.palette, v.tint0, v.tint1, v.tint2)
        end
        local toremove = { "hats", "eyewear" }
        local catgender = "Female"
        if gender == "male" then catgender = "Male" end
        for _, tagName in pairs(catlist[catgender]) do
            local hash = joaat(tagName)
            if IsMetaPedUsingComponentCategory(ped, hash) then
                for _, essential in ipairs(toremove) do
                    if hash == GetHashFromString(essential) then
                        Citizen.InvokeNative(0xD710A5007C2AC539, ped, hash, 0)
                        break
                    end
                end
            end
        end
        UpdatePedVariation(ped)
        RemoveHairsAndBeards(ped)
    end
    return true
end

function GetHead(ped)
    local numComponents = GetNumComponentsInPed(ped)
    for i = 0, numComponents - 1, 1 do
        local componentCategory = GetCategoryOfComponentAtIndex(ped, i)
        if componentCategory == `heads` then
            local shopitem = GetShopItemComponentAtIndex(ped, i, true)
            return shopitem
        end
    end
end

function GetMetaPedData(category, ped)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then
        return nil
    end
    local drawable, albedo, normal, material = GetMetaPedAssetGuids(playerPed, componentIndex)
    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)

    return {
        drawable = drawable,
        albedo = albedo,
        normal = normal,
        material = material,
        palette = palette,
        tint0 = tint0,
        tint1 =
            tint1,
        tint2 = tint2
    }
end

function GetHashFromString(value)
    if type(value) == "string" then
        local number = tonumber(value)
        if number then return number end
        return joaat(value)
    end
    return value
end

function GetCategoriesEquiped(ped)
    local equiped = {}
    local numComponent = GetNumComponentsInPed(ped) or 0
    for index = 0, numComponent - 1 do
        --Get current component
        local category = GetCategoryOfComponentAtIndex(ped, index)
        equiped[category] = {
            index = index,
        }
        if category == `neckwear` then
            equiped[`neckerchiefs`] = equiped[category]
            equiped[`neckerchiefs`].category = "neckerchiefs"
        elseif category == `neckerchiefs` then
            equiped[`neckwear`] = equiped[category]
            equiped[`neckwear`].category = "neckwear"
        end
    end
    --clear cached value
    local component = equiped
    return component
end

function ApplyCachePedDataToPedPlayer()
    -- Prevent crash when clicking too fast before data is loaded
    if not CachePedData or not CachePedData.pedmodel or not CachePedData.pedmodel.model then
        print("[fdb-creator] Warning: CachePedData not loaded yet, retrying...")
        Wait(500)
        if not CachePedData or not CachePedData.pedmodel or not CachePedData.pedmodel.model then
            print("[fdb-creator] Error: CachePedData still not loaded, aborting")
            return
        end
    end
    
    local model = CachePedData.pedmodel.model
    local outfit = CachePedData.pedmodel.outfit
    local ped = CachePed
    if model == "mp_male" or model == "mp_female" then
        RequestModel(GetHashKey(model))
        while not HasModelLoaded(GetHashKey(model)) do
            Wait(1)
        end
        SetPlayerModel(PlayerId(), GetHashKey(model))
        local timeout = 0
        while GetEntityModel(PlayerPedId()) ~= GetHashKey(model) and timeout < 200 do
            Wait(10)
            timeout = timeout + 1
        end
        CachePed = PlayerPedId()
        
        SetEntityVisible(CachePed, true, 0)
        SetEntityAlpha(CachePed, 255, false)
        ResetEntityAlpha(CachePed)
        
        -- Garante posicionamento correto após troca de modelo do ped
        local spawnCoords = Config.CharSelect.playerSpawn.coords
        local spawnHeading = Config.CharSelect.playerSpawn.heading
        SetEntityCoords(CachePed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, false)
        SetEntityHeading(CachePed, spawnHeading)
        FreezeEntityPosition(CachePed, true)

        SetModelAsNoLongerNeeded(GetHashKey(model))
        EquipMetaPedOutfitPreset(CachePed, 0, false)
        local SkinColor   = DefaultChar[CachePedData.gender][CachePedData.skintone]
        local legs        = tonumber("0x" .. SkinColor.Legs[CachePedData.lowerbody])
        local bodyType    = tonumber("0x" .. SkinColor.Body[CachePedData.upperbody])
        local heads       = tonumber("0x" .. SkinColor.Heads[CachePedData.head])
        local headtexture = joaat(SkinColor.HeadTexture[1])
        local albedo      = texture_types[CachePedData.gender].albedo
        IsPedReadyToRender(CachePed)
        ApplyShopItemToPed(heads, CachePed)
        ApplyShopItemToPed(bodyType, CachePed)
        ApplyShopItemToPed(legs, CachePed)
        Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)
        UpdatePedVariation(CachePed)
        if CachePedData.head > 0 then
            local head = tonumber("0x" ..
                DefaultChar[CachePedData.gender][CachePedData.skintone].Heads[CachePedData.head])
            ApplyShopItemToPed(head, CachePed)
        end
        if CachePedData.lowerbody > 0 then
            local comp = DefaultChar[CachePedData.gender][CachePedData.skintone].Legs[CachePedData.lowerbody]
            ApplyShopItemToPed(tonumber("0x" .. comp), CachePed)
        end
        if CachePedData.upperbody > 0 then
            local comp = DefaultChar[CachePedData.gender][CachePedData.skintone].Body[CachePedData.upperbody]
            ApplyShopItemToPed(tonumber("0x" .. comp), CachePed)
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
        NPCAssetsToPed(model, outfit)
        IsPedReadyToRender(CachePed)
    end


    if CachePedData.teeth > 0 then
        ApplyShopItemToPed(Teeth[CachePedData.gender][CachePedData.teeth].hash, CachePed)
    end

    if CachePedData.eyes > 0 then
        ApplyShopItemToPed(Eyes[CachePedData.gender][CachePedData.eyes], CachePed)
    end

    for k, v in pairs(CachePedData.expressions) do
        SetCharExpression(CachePed, ExpressionsHashes[k], v)
    end
    UpdatePedVariation(CachePed)
end

EssentialsCategories = { -- Categories that will not be removed when changing clothes, and not be saved when creating an outfit
    "bodies_upper",
    "bodies_lower",
    "heads",
    "hair",
    "hair_bonnet",
    "beard",
    "teeth",
    "eyes",
    "beards_chin",
    "beards_chops",
    "beards_mustache",
    "beards_complete",
}


function RemoveHairsAndBeards(ped)
    local toremove = {
        "hair",
        "hair_bonnet",
        "beard",
        "beards_chin",
        "beards_chops",
        "beards_mustache",
        "beards_complete",
    }


    IsPedReadyToRender(ped)
    for _, value in ipairs(toremove) do
        local hash = GetHashFromString(value)
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, hash, 0)
    end

    UpdatePedVariation(ped)
end

function RemoveAllClothesExceptEssentials(ped, npc)
    local equipped = GetCategoriesEquiped(ped)
    local essentials = EssentialsCategories



    for _, tagName in pairs(catlist[CachePedData.gender]) do
        local isEssential = false
        local hash = joaat(tagName)
        if IsMetaPedUsingComponentCategory(ped, hash) then
            for _, essential in ipairs(essentials) do
                if hash == GetHashFromString(essential) then
                    isEssential = true
                    break
                end
            end

            if not isEssential then
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, hash, 0)
            end
        end
    end
    if not npc then
        local lower = DefaultChar[CachePedData.gender][CachePedData.skintone].Legs[CachePedData.lowerbody]
        local upper = DefaultChar[CachePedData.gender][CachePedData.skintone].Body[CachePedData.upperbody]
        IsPedReadyToRender(CachePed)
        ApplyShopItemToPed(tonumber("0x" .. lower), CachePed)
        ApplyShopItemToPed(tonumber("0x" .. upper), CachePed)
        UpdatePedVariation(CachePed)
    end
    -- for category, data in pairs(equipped) do

    --     local isEssential = false
    --     for _, essential in ipairs(essentials) do
    --         if category == GetHashFromString(essential) then
    --             isEssential = true
    --             break
    --         end
    --     end

    --     if not isEssential then
    --         print (category)
    --         Citizen.InvokeNative(0xD710A5007C2AC539, ped, category, 0)
    --     end
    -- end


    NativeUpdatePedVariation(ped)
end

function RemoveTagFromMetaPed(hash, ped)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped or PlayerPedId(), hash, 0)
end

function ApplyCachePedDataToPed(ped, data, charid)
    local model = data.pedmodel.model
    local outfit = data.pedmodel.outfit
    if model == "mp_male" or model == "mp_female" then
        EquipMetaPedOutfitPreset(ped, 0, false)
        local SkinColor   = DefaultChar[data.gender][data.skintone]
        local legs        = tonumber("0x" .. SkinColor.Legs[data.lowerbody])
        local bodyType    = tonumber("0x" .. SkinColor.Body[data.upperbody])
        local heads       = tonumber("0x" .. SkinColor.Heads[data.head])
        local headtexture = joaat(SkinColor.HeadTexture[1])
        local albedo      = texture_types[data.gender].albedo
        IsPedReadyToRender(ped)
        ApplyShopItemToPed(heads, ped)
        ApplyShopItemToPed(bodyType, ped)
        ApplyShopItemToPed(legs, ped)
        Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)
        UpdatePedVariation(ped)
        if data.head > 0 then
            local head = tonumber("0x" ..
                DefaultChar[data.gender][data.skintone].Heads[data.head])
            ApplyShopItemToPed(head, ped)
        end
        if data.lowerbody > 0 then
            local comp = DefaultChar[data.gender][data.skintone].Legs
                [data.lowerbody]
            ApplyShopItemToPed(tonumber("0x" .. comp), ped)
        end
        if data.upperbody > 0 then
            local comp = DefaultChar[data.gender][data.skintone].Body
                [data.upperbody]
            ApplyShopItemToPed(tonumber("0x" .. comp), ped)
        end
        if data.body > 0 then
            local comp = tonumber(Body[data.body])
            EquipMetaPedOutfit(comp, ped)
        end
        if data.waist > 0 then
            local comp = tonumber(Waist[data.waist])
            EquipMetaPedOutfit(comp, ped)
        end
    end


    if data.teeth > 0 then
        ApplyShopItemToPed(Teeth[data.gender][data.teeth].hash, ped)
    end

    if data.eyes > 0 then
        ApplyShopItemToPed(Eyes[data.gender][data.eyes], ped)
    end
    IsPedReadyToRender(ped)
    for k, v in pairs(data.expressions) do
        SetCharExpression(ped, ExpressionsHashes[k], v)
    end
    TriggerEvent("fdb-barber:loadbarberoverlayOnCharacter", charid, ped)
    TriggerEvent("fdb_clothes:ApplyClothesToCharid", charid, ped)
    UpdatePedVariation(ped)
end

function OpenClothesMenu()
    if not baseHeading then
        baseHeading = GetEntityHeading(PlayerPedId())
        -- Stocker l'offset initial pour que 180 corresponde à baseHeading
        angleOffset = 180 - baseHeading
    end
    TriggerEvent("fdb_clothing:OpenClothesMenuCreator")
end

-- fixing scale network issue
CreateThread(function()
    repeat Wait(2000) until LocalPlayer.state
    while true do
        local dead = IsEntityDead(PlayerPedId())
        if CachePedData.height ~= 1.0 then
            if not dead then
                SetPedScale(PlayerPedId(), CachePedData.height)
            end
        end
        Wait(1000)
    end
end)

function bigInt(text)
    local string1 = DataView.ArrayBuffer(16)
    string1:SetInt64(0, text)
    return string1:GetInt64(0)
end

ShowAdvancedRightNotification = function(_text, _dict, icon, text_color, duration, quality)
    local text = CreateVarString(10, "LITERAL_STRING", _text)
    local dict = CreateVarString(10, "LITERAL_STRING", _dict)
    local sdict = CreateVarString(10, "LITERAL_STRING", "Transaction_Feed_Sounds")
    local sound = CreateVarString(10, "LITERAL_STRING", "Transaction_Positive")

    local struct1 = DataView.ArrayBuffer(8 * 7)
    struct1:SetInt32(8 * 0, duration)
    struct1:SetInt64(8 * 1, bigInt(sdict))
    struct1:SetInt64(8 * 2, bigInt(sound))

    local struct2 = DataView.ArrayBuffer(8 * 10)
    struct2:SetInt64(8 * 1, bigInt(text))
    struct2:SetInt64(8 * 2, bigInt(dict))
    struct2:SetInt64(8 * 3, bigInt(GetHashKey(icon)))
    struct2:SetInt64(8 * 5, bigInt(GetHashKey(text_color or "COLOR_WHITE")))
    Citizen.InvokeNative(0xB249EBCB30DD88E0, struct1:Buffer(), struct2:Buffer(), 1)
end
