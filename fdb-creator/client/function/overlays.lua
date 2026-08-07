-------- OVERLAYS --------
local textureId = -1

function RemoveOverlays(ped)
    Callback.triggerServer("murphy_barber:GetCurrentOverlays", function(makeup, permanent)
        overlay_all_layers = deepcopy(baseoverlay)
        for k, v in pairs(overlay_all_layers) do
            for key, value in pairs(permanent) do
                if v.name == value.name then
                    -- Replace direct assignment with field updates
                    for field, val in pairs(value) do
                        overlay_all_layers[k][field] = val
                    end
                end
            end
        end
        Wait(200)
        UpdateOverlay(ped)
    end)
end

function UpdateOverlay(ped, table, targetalbedo)
    if table then
        overlay_all_layers = deepcopy(table)
    end
    if IsPedMale(ped) then
        current_texture_settings = texture_types["Male"]
    else
        current_texture_settings = texture_types["Female"]
    end
     local albedo
    if targetalbedo then
        albedo = targetalbedo
    else
        albedo = joaat(DefaultChar[CachePedData.gender][CachePedData.skintone].HeadTexture[1])
    end

    current_texture_settings.albedo = albedo

    if textureId ~= -1 then
        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId) -- reset texture
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId) -- remove texture
    end
    textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, current_texture_settings.albedo, current_texture_settings
        .normal, current_texture_settings.material); -- create texture
    local attempts = 0
    repeat
        attempts = attempts + 1
        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)                      -- reset texture
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId)                      -- remove texture
        textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, current_texture_settings.albedo,
            current_texture_settings.normal, current_texture_settings.material); -- create texture
        Citizen.Wait(10)
    until textureId ~= -1 or attempts > 20
    for k, v in pairs(overlay_all_layers) do
        if v.visibility ~= 0 then
            local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal, v.tx_material,
                v.tx_color_type, v.tx_opacity, v.tx_unk);                                   -- create overlay
            if v.tx_color_type == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette); -- apply palette
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary,
                    v.palette_color_secondary, v.palette_color_tertiary)                    -- apply palette colours
            end
            Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var);         -- apply overlay variant
            Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity);     -- apply overlay opacity
        end
    end
    while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do -- wait till texture fully loaded
        Citizen.Wait(0)
    end
    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)               -- update texture
    Citizen.InvokeNative(0x0B46E25761519058, ped, joaat("heads"), textureId) -- apply texture to current component in category "heads"

    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, false); -- refresh ped components
    Citizen.InvokeNative(0x6BEFAA907B076859, textureId)               -- remove texture
end

function OverlayChange(name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk, palette_id,
                       palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity)
    for k, v in pairs(overlay_all_layers) do
        if v.name == name then
            v.visibility = visibility
            if visibility ~= 0 then
                v.tx_id_index = tx_id
                v.palette_id = palette_id

                v.tx_normal = tx_normal
                v.tx_material = tx_material
                v.tx_color_type = tx_color_type
                v.tx_opacity = tx_opacity
                v.tx_unk = tx_unk
                if tx_color_type == 0 then
                    if color_palettes[palette_id] then
                        v.palette = color_palettes[palette_id][1]
                    end
                    v.palette_color_primary = palette_color_primary
                    v.palette_color_secondary = palette_color_secondary
                    v.palette_color_tertiary = palette_color_tertiary
                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    v.tx_id = overlays_info[name][1].id
                else
                    v.var = 0
                    v.tx_id = overlays_info[name][tx_id].id
                end
                v.opacity = opacity
            end
        end
    end
    UpdateOverlay(CachePed)
end