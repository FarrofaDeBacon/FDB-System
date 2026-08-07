RegisterNetEvent('murphy_barber_creator:loadbarberoverlay', function()
    -- Wait for player ped to be ready
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then
        print("[murphy_barber_creator] Error: Player ped does not exist")
        return
    end
    IsPedReadyToRender(ped)
    
    Callback.triggerServer('murphy_barber_creator:GetCurrentHairs', function(datatable, outfitid, makeup, permanent)
        if datatable and next(datatable) ~= nil then
            barber_overlay_all_layers = deepcopy(baseoverlay)
            for k, v in pairs(barber_overlay_all_layers) do
                for key, value in pairs(makeup) do
                    if v.name == value.name then
                        -- Replace direct assignment with field updates
                        for field, val in pairs(value) do
                            barber_overlay_all_layers[k][field] = val
                        end
                    end
                end
                for key, value in pairs(permanent) do
                    if v.name == value.name then
                        -- Replace direct assignment with field updates
                        for field, val in pairs(value) do
                            barber_overlay_all_layers[k][field] = val
                        end
                    end
                end
            end
            -- Small wait to ensure ped is ready for component changes
            Wait(100)
            TriggerEvent("murphy_barber_creator:clotheitem", datatable, outfitid, true)
        else
            print("[murphy_barber_creator] No hairstyle data found for current character (empty datatable)")
        end
    end)
end)

RegisterNetEvent('murphy_barber_creator:loadbarberoverlayOnCharacter', function(charid, ped)
    -- Wait for ped to be valid and fully loaded
    local attempts = 0
    while not DoesEntityExist(ped) do
        Wait(100)
        attempts = attempts + 1
        if attempts > 50 then
            print("[murphy_barber_creator] Error: Ped not loaded after 5 seconds for character " .. tostring(charid))
            return
        end
    end
    
    -- Wait for ped to be ready to render
    IsPedReadyToRender(ped)
    
    Callback.triggerServer('murphy_barber_creator:GetCurrentHairsOnCharacter',
        function(datatable, outfitid, makeup, permanent)
            if datatable and next(datatable) ~= nil then
                barber_overlay_all_layers = deepcopy(baseoverlay)
                for k, v in pairs(barber_overlay_all_layers) do
                    for key, value in pairs(makeup) do
                        if v.name == value.name then
                            -- Replace direct assignment with field updates
                            for field, val in pairs(value) do
                                barber_overlay_all_layers[k][field] = val
                            end
                        end
                    end
                    for key, value in pairs(permanent) do
                        if v.name == value.name then
                            -- Replace direct assignment with field updates
                            for field, val in pairs(value) do
                                barber_overlay_all_layers[k][field] = val
                            end
                        end
                    end
                end
                -- Small wait to ensure ped is ready for component changes
                Wait(100)
                TriggerEvent("murphy_barber_creator:clotheitem", datatable, outfitid, true, ped, charid)
            else
                print("[murphy_barber_creator] No hairstyle data found for character " .. tostring(charid) .. " (empty datatable)")
            end
        end, charid)
end)

RegisterNetEvent('murphy_barber_creator:clotheitem')
AddEventHandler('murphy_barber_creator:clotheitem', function(hairstyleComponents, outfitid, overlay, target, charid)
    Citizen.CreateThread(function()
        local _Target = target or PlayerPedId()
        local gender
        if IsPedMale(_Target) then gender = "male" else gender = "female" end
        IsPedReadyToRender(_Target)
        barberCache = hairstyleComponents
        for k, v in pairs(MURPHY_ASSETS[gender]) do
            if barberCache[k] == nil then
                barberCache[k] = {}
                barberCache[k].model = 0
                barberCache[k].texture = 0
            end
        end
        OldbarberCache = deepcopy(barberCache)
        Callback.triggerServer("murphy_barber_creator:GetCurrentOverlays", function(makeup, permanent)
            Actualalbedo = nil
            Callback.triggerServer("murphy_barber_creator:GetCharSkinTone", function(result)
                Actualalbedo = result
            end, IsPedMale(_Target), charid)
            repeat
                Wait(100)
                print("Waiting for albedo")
            until Actualalbedo ~= nil
            local albedo = Actualalbedo
            if GetHead(_Target) ~= 0 then
                if overlay == false then
                    RemoveOverlays(_Target)
                    barber_overlay_all_layers = deepcopy(baseoverlay)
                    for k, v in pairs(barber_overlay_all_layers) do
                        for key, value in pairs(makeup) do
                            if v.name == value.name then
                                -- Replace direct assignment with field updates
                                for field, val in pairs(value) do
                                    barber_overlay_all_layers[k][field] = val
                                end
                            end
                        end
                        for key, value in pairs(permanent) do
                            if v.name == value.name then
                                -- Replace direct assignment with field updates
                                for field, val in pairs(value) do
                                    barber_overlay_all_layers[k][field] = val
                                end
                            end
                        end
                    end
                end
                for k, v in pairs(barber_overlay_all_layers) do
                    if v.visibility > 0 then
                        UpdateOverlay(_Target, barber_overlay_all_layers, albedo)
                        break
                    end
                end
            end
            local canloadhair = false
            for k, v in pairs(barberCache) do
                if v.model > 0 then
                    canloadhair = true
                    break
                end
            end
            print("[murphy_barber_creator] Hairstyle data - canloadhair:", canloadhair, "charid:", charid, "target:", _Target)
            if canloadhair then
                -- Wait a bit to ensure ped is fully ready for component changes
                Wait(100)
                RemoveAllBarber(_Target)
                Wait(100)
                ReequipAllhairstyle(_Target)
                if charid == nil then
                    TriggerServerEvent("murphy_barber_creator:updatehairstyle", barberCache, barber_overlay_all_layers,
                        outfitid)
                end
            else
                print("[murphy_barber_creator] No hairstyle data to load for character")
            end
        end, charid)
    end)
end)

function RemoveAllBarber(ped)
    local equipped = GetCategoriesEquiped(ped)
    local toremove = {
        "hair",
        "beard",
        "beards_chin",
        "beards_chops",
        "beards_mustache",
        "beards_complete",
        "hair_bonnet",
        "hats",
        "hat_accessories",
    }

    for category, data in pairs(equipped) do
        local isEssential = true
        for _, essential in ipairs(toremove) do
            if category == GetHashFromString(essential) then
                isEssential = false
                break
            end
        end

        if not isEssential then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, category, 0)
        end
    end


    NativeUpdatePedVariation(ped)
end

function ReequipAllhairstyle(ped)
    local gender
    if IsPedMale(ped) then gender = "male" else gender = "female" end
    
    print("[murphy_barber_creator] ReequipAllhairstyle - gender:", gender, "ped:", ped)

    for category, data in pairs(barberCache) do
        if data.model and data.model > 0 then
            print("[murphy_barber_creator] Processing category:", category, "model:", data.model)
            
            if not MURPHY_ASSETS[gender] then
                print("[murphy_barber_creator] ERROR: No MURPHY_ASSETS for gender:", gender)
                goto continue
            end
            
            if not MURPHY_ASSETS[gender][category] then
                print("[murphy_barber_creator] ERROR: No MURPHY_ASSETS for category:", category)
                goto continue
            end
            
            local drawable = MURPHY_ASSETS[gender][category] and MURPHY_ASSETS[gender][category][data.model] and
            MURPHY_ASSETS[gender][category][data.model].drawable
            if MURPHY_ASSETS[gender][category][data.model] == nil then
                print("Invalid hairstyle data for category:", category, "model:", data.model)
                print("If you updated MURPHY_ASSETS file recently, make sure to wipe your database before use.")
            else
                if drawable then
                    local albedo = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].albedo
                    local normal = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].normal
                    local material = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].material
                    local palette = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].palette
                    local tint0 = data.texture.tint0
                    local tint1 = data.texture.tint1
                    local tint2 = data.texture.tint2

                    UpdateCustomhairstyle(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    UpdatePedVariation(ped)
                else
                    if type(data.texture) == "table" then
                        NativeSetPedComponentEnabled(ped,
                            MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.model)].hash,
                            false,
                            true,
                            true)
                        local catHash
                        if category == "beard" then
                            catHash = -134124598
                        else
                            if type(category) ~= "number" then
                                catHash = joaat(category)
                            else
                                catHash = category
                            end
                        end
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, t0, t1, t2 = GetMetaPedAssetTint(ped, componentIndex)
                        RemoveShopItemFromPed(ped,
                            MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.model)].hash, 0,
                            0, 0)
                        -- RemoveShopItemFromPed(ped, FullDB[gender][k][tonumber(v.model)][1].hash, 0, 0, 0)
                        local tint0 = data.texture.tint0
                        local tint1 = data.texture.tint1
                        local tint2 = data.texture.tint2
                        palette = `metaped_tint_hair`
                        UpdateCustomhairstyle(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                        UpdatePedVariation(ped)
                    else
                        NativeSetPedComponentEnabled(ped, tonumber(
                                MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture)].hash),
                            false,
                            true, true)
                        UpdatePedVariation(ped)
                    end
                end
            end
            ::continue::
        end
    end
    print("[murphy_barber_creator] ReequipAllhairstyle completed")
end
