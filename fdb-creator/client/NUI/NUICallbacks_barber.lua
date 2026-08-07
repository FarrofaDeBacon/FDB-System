
RegisterNUICallback("backToOutfitList", function(data, cb)
    print ("backToOutfitList triggered")
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
    SendNUIMessage(
        {
            type = "closeOutfitMenu",
        }
    )
    MoveCam("edit")
    EditionMenu(false)
    local ped = CachePed
    local x, y, z = table.unpack(GetEntityCoords(ped))
    if not baseHeading then
        baseHeading = GetEntityHeading(ped)
        -- Stocker l'offset initial pour que 180 corresponde à baseHeading
        angleOffset = 180 - baseHeading
    end
    local targetHeading = (180 - angleOffset) % 360
    local rad = math.rad(targetHeading)
    local distance = 1.0
    local targetX = x + (math.sin(-rad) * distance)
    local targetY = y + (math.cos(-rad) * distance)
    TaskTurnPedToFaceCoord(ped, targetX, targetY, z, 0)

    Wait(1000)
    LoadApparenceMenu()
    DisplayPins = true
    OpenApperanceMenu()
end)



RegisterNUICallback("itemValue", function(body, resultCallback)
    local value = tonumber(body.item)
    local category = body.category
    local menu = body.menu
    if value then
        if overlays_info[category] then
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
            local name = category
            local visibility = 1
            if value == 0 then
                visibility = 0
            end
            local tx_id = value
            if value == 0 then
                tx_id = 1
            end
            local var = 0
            local tx_color_type = 0
            if name == "scars" or name == "scars2" or name == "scars3" or name == "spots" or name == "disc" or name == "complex" or name == "acne" or name == "ageing" or name == "moles" or name == "freckles" then
                tx_color_type = 1
            end
            local opacity = 1.0
            local palette_id = 1
            local palette_color_primary = 0
            local palette_color_secondary = 0
            local palette_color_tertiary = 0
            OverlayChange(name,visibility,tx_id,0,0,tx_color_type,1.0,0,palette_id,palette_color_primary,palette_color_secondary,palette_color_tertiary,var,opacity)
        else
            Change(value, category, "model")
            if hairstyleCache[category].model > value then
                PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
            else
                PlaySound("Amount_Increase", "HUD_Donate_Sounds")
            end
        end
        UpdateContextualDatas(value, category)
    else
        if not overlays_info[category] then
            if hairstyleCache[category].model == 0 then
                if ContextualDataOn then
                    ContextualDataOn = false
                    PlaySound("SELECT", "HUD_PLAYER_MENU")
                    SendNUIMessage(
                        {
                            type = "hidecontextualDatas",

                        }
                    )
                end
            elseif hairstyleCache[category].model > 0 then
                -- if ContextualDataOn == false then
                UpdateContextualDatas(hairstyleCache[category].model, category)
                -- end
            end
            if currentcategory ~= category then
                PlaySound("Amount_Increase", "HUD_Donate_Sounds")
            end
        end
    end
    currentcategory = category
end)

RegisterNUICallback("varValue", function(body, resultCallback)
    local value = tonumber(body.item)
    local category = body.category
    local reference
    if overlays_info[category] then
        local name = category
        local advancedValue = body.advancedValue
        local itemValue = body.itemValue
        for k,v in pairs(overlay_all_layers) do
            if v.name==name then
                if advancedValue == "Opacity" then
                    itemValue = scale(itemValue, 0, 100, 0.0, 1.0)
                    if v.opacity > itemValue then
                        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
                    else
                        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
                    end
                    v.opacity = itemValue
                end
                if advancedValue == "Palette" then
                    if v.palette_id > tonumber(itemValue) then
                        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
                    else
                        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
                    end
                    v.palette_id = tonumber(itemValue)
                end
                local visibility = v.visibility
                local tx_id = v.tx_id_index
                local var = v.var
                if value then
                    if var > value then
                        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
                    else
                        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
                    end
                    var = value
                end
                local tx_color_type = v.tx_color_type
                local opacity = v.opacity
                local palette_id = v.palette_id
                local palette_color_primary = v.palette_color_primary
                local palette_color_secondary = v.palette_color_secondary
                local palette_color_tertiary = v.palette_color_tertiary
                OverlayChange(name,visibility,tx_id,0,0,tx_color_type,1.0,0,palette_id,palette_color_primary,palette_color_secondary,palette_color_tertiary,var,opacity)
            end 
        end
    else
        if type(hairstyleCache[category].texture) == "table" then
            reference = hairstyleCache[category].texture.palette or hairstyleCache[category].texture.model
        else
            reference = hairstyleCache[category].texture
        end
        if reference > value then
            PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
        else
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        end
        if category == "bodies_upper" or category == "bodies_lower" then
            if value then
                ChangeSkin(category, hairstyleCache[category].model, "variants", value)
            end
        else
            Change(hairstyleCache[category].model, category, "variants", value)
        end
    end
end)

RegisterNUICallback("tintValue", function(body, resultCallback)
    local value = tonumber(body.value)
    local tintId = tonumber(body.tintId)
    local category = body.category
    local reference
    if overlays_info[category] then
        local name = category
        for k,v in pairs(overlay_all_layers) do
            if v.name==name then
                local visibility = v.visibility
                local tx_id = v.tx_id_index
                local var = v.var
                -- if value then
                --     var = value
                -- end
                local tx_color_type = v.tx_color_type
                local opacity = v.opacity
                local palette_id = v.palette_id
                if tintId == 1 then
                    v.palette_color_primary = value
                end
                local palette_color_primary = v.palette_color_primary
                if tintId == 2 then
                    v.palette_color_secondary = value
                end
                local palette_color_secondary = v.palette_color_secondary
                if tintId == 2 then
                    v.palette_color_tertiary = value
                end
                local palette_color_tertiary = v.palette_color_tertiary
                OverlayChange(name,visibility,tx_id,0,0,tx_color_type,1.0,0,palette_id,palette_color_primary,palette_color_secondary,palette_color_tertiary,var,opacity)
            end 
        end
    else
        if type(hairstyleCache[category].texture) == "table" then
            reference = hairstyleCache[category].texture["tint" .. tostring(tintId - 1)]
        else
            reference = 0
        end
        if reference > value then
            PlaySound("Amount_Decrease",
                "HUD_Donate_Sounds")
        else
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        end
        Change(hairstyleCache[category].model, category, tintId, value)
    end
end)