local init = false
DisplayPins = true
function OpenApperanceMenu()
    while true do
        Wait(45)
        if DisplayPins then
            local player = CachePed
            local pelvisCoords = GetPedBoneCoords(player, 34606, 0.0, 0.0, 0.0)
            local retval, x, y = GetScreenCoordFromWorldCoord(pelvisCoords.x, pelvisCoords.y, pelvisCoords.z)

            local headCoords = GetPedBoneCoords(player, 21030, 0.0, 0.0, 0.0)
            local retval, headx, heady = GetScreenCoordFromWorldCoord(headCoords.x + 0.07, headCoords.y,
                headCoords.z + 0.1)
            local retval, eyesx, eyesy = GetScreenCoordFromWorldCoord(headCoords.x - 0.07, headCoords.y,
                headCoords.z + 0.05)
            local retval, facialx, facialy = GetScreenCoordFromWorldCoord(headCoords.x - 0.07, headCoords.y,
                headCoords.z - 0.07)
            local retval, mouthx, mouthy = GetScreenCoordFromWorldCoord(headCoords.x + 0.07, headCoords.y,
                headCoords.z - 0.03)

            local chestCoords = GetPedBoneCoords(player, 37873, 0.0, 0.0, 0.0)
            local retval, chestx, chesty = GetScreenCoordFromWorldCoord(chestCoords.x, chestCoords.y, chestCoords.z - 0.2)

            local thighCoords = GetPedBoneCoords(player, 6884, 0.0, 0.0, 0.0)
            local retval, footx, footy = GetScreenCoordFromWorldCoord(thighCoords.x, thighCoords.y, thighCoords.z - 0.5)
            local pins = {
                {
                    id = "head",
                    name = "Head",
                    startPosition = {
                        x = headx,
                        y = heady
                    },
                    direction = "left",
                    subElem = {
                        {
                            id = "headshape",
                            name = "Head shape"
                        },
                        {
                            id = "neck",
                            name = "Neck"
                        },
                        {
                            id = "barber",
                            name = "Hairdresser"
                        },
                    }
                },
                {
                    id = "eyesandbrows",
                    name = "Eyes",
                    direction = "right",
                    startPosition = {
                        x = eyesx,
                        y = eyesy
                    },
                    subElem = {
                        {
                            id = "brows",
                            name = "Brows"
                        },
                        {
                            id = "eyes",
                            name = "Eyes"
                        },
                        {
                            id = "eyelid",
                            name = "Eyelid"
                        }
                    }
                },
                {
                    id = "facial",
                    name = "Face",
                    direction = "right",
                    startPosition = {
                        x = facialx,
                        y = facialy
                    },
                    subElem = {
                        {
                            id = "ears",
                            name = "Ears"
                        },
                        {
                            id = "cheekbone",
                            name = "CheekBone"
                        },
                        {
                            id = "jaw",
                            name = "Jaw"
                        },
                        {
                            id = "chin",
                            name = "Chin"
                        },
                        {
                            id = "nose",
                            name = "Nose"
                        },
                    }
                },
                {
                    id = "mouth",
                    name = "Mouth",
                    direction = "left",
                    startPosition = {
                        x = mouthx,
                        y = mouthy
                    },
                    subElem = {
                        {
                            id = "mouth",
                            name = "Mouth"
                        },
                        {
                            id = "lipupper",
                            name = "Lip Upper"
                        },
                        {
                            id = "liplower",
                            name = "Lip Lower"
                        },
                        {
                            id = "mouthcornerleft",
                            name = "Mouth Corner Left"
                        },
                        {
                            id = "mouthcornerright",
                            name = "Mouth Corner Right"
                        },
                    }
                },
                {
                    id = "upperbody",
                    name = "Upper Body",
                    direction = "right",
                    startPosition = {
                        x = chestx,
                        y = chesty
                    },
                    subElem = {
                        {
                            id = "arms",
                            name = "Arms"
                        },
                        {
                            id = "shoulders",
                            name = "Shoulders"
                        },
                        {
                            id = "chest",
                            name = "Chest"
                        },

                    }
                },
                {
                    id = "lowerbody",
                    name = "Lower Body",
                    direction = "left",
                    startPosition = {
                        x = footx,
                        y = footy
                    },
                    subElem = {
                        {
                            id = "legs",
                            name = "Legs"
                        },
                        {
                            id = "waist",
                            name = "Waist"
                        },
                    }
                },

            }
            if Config.fdb_clothing == true then
                local clothesCoords = GetPedBoneCoords(player, 37873, 0.0, 0.0, 0.0)
                local retval, clothesx, clothesy = GetScreenCoordFromWorldCoord(clothesCoords.x+0.4, clothesCoords.y,
                    clothesCoords.z - 0.4)
                table.insert(pins, {
                    id = "clothes",
                    name = "Clothes",
                    startPosition = {
                        x = clothesx,
                        y = clothesy
                    },
                    direction = "left",
                    subElem = {
                        {
                            id = "clothes",
                            name = "Clothes Shop"
                        }
                    }
                })
            end
            if not init then
                SetNuiFocus(true, true)
                init = true
                PlaceElem(true, pins, false)
            else
                PlaceElem(true, pins, true)
            end
        else
            if init then
                PlaceElem(false)
                init = false
            end
            break
        end
    end
end

function PlaceElem(state, pins, update)
    if state then
        if not update then
            SendNUIMessage(
                {
                    type = "placeElem",
                    pins = pins
                }
            )
        elseif update then
            SendNUIMessage(
                {
                    type = "updateElem",
                    pins = pins
                }
            )
        end
    else
        SendNUIMessage(
            {
                type = "hideBodyPartsMenu",
            }
        )
    end
end

function EditionMenu(state, edition)
    if state then
        SendNUIMessage(
            {
                type = "showEditionMenu",
                edition = edition
            }
        )
    elseif not state then
        SendNUIMessage(
            {
                type = "hideEditionMenu",
            }
        )
        SendNUIMessage(
            {
                type = "hideEyesPersoMenu",
            }
        )
    end
end

function LoadApparenceMenu()
    if CachePedData.pedmodel.model ~= "mp_male" and CachePedData.pedmodel.model ~= "mp_female" then
        SendNUIMessage(
            {
                type = "openEditApparenceMenu",
                skinColours = {},
                apparenceMenu = {},
            }
        )
    else
        -- Créer une copie du menu avec les valeurs actuelles de CachePedData
        local updatedApparenceMenu = deepcopy(ApparenceMenu)
        for _, elem in pairs(updatedApparenceMenu) do
            if elem.id == "height" and CachePedData.height then
                elem.value = scale(CachePedData.height, HeightMin, HeightMax, 0, 100)
            elseif elem.id == "body" and CachePedData.body then
                elem.value = CachePedData.body
            elseif elem.id == "waist" and CachePedData.waist then
                elem.value = CachePedData.waist
            elseif elem.id == "legs" and CachePedData.lowerbody then
                elem.value = CachePedData.lowerbody
            elseif elem.id == "upper" and CachePedData.upperbody then
                elem.value = CachePedData.upperbody
            end
        end
        SendNUIMessage(
            {
                type = "openEditApparenceMenu",
                skinColours = SkinColours,
                apparenceMenu = updatedApparenceMenu,
            }
        )
    end
end

local menucategories = {
    male = {
        categories = { "barber", "lifestyle", "makeup" },
        barber = {
            "hairstabble", "hair", "hair_bonnet", "beardstabble", "beard", "beards_complete", "beards_chin",
            "beards_chops", "beards_mustache"
        },

        makeup = {
            "eyeliners", "lipsticks", "shadows", "paintedmasks", "blush", "blush2", "foundation",
        },

        lifestyle = {
            "eyebrows", "scars", "scars2", "scars3", "acne", "ageing", "complex", "disc", "freckles", "grime", "moles",
            "spots"
        },

    },
    female = {
        categories = { "barber", "lifestyle", "makeup" },
        barber = {
            "hair", "hair_bonnet", "beard", "beards_complete", "beards_chin", "beards_chops", "beards_mustache"
        },

        makeup = {
            "eyeliners", "lipsticks", "shadows", "paintedmasks", "blush", "blush2", "foundation",
        },

        lifestyle = {
            "eyebrows", "scars", "scars2", "scars3", "acne", "ageing", "complex", "disc", "freckles", "grime", "moles",
            "spots"
        },
    }
}
function OpenBarberMenu()
    local ped = CachePed
    local selectedgender = "female"
    if CachePedData.gender == "Male" then selectedgender = "male" end
    local showoverlay = false
    if GetHead(ped) ~= 0 then
        showoverlay = true
    end
    local categories = {}

    for _, k in ipairs(menucategories[selectedgender].categories) do
        if k == "makeup" or k == "lifestyle" then
            if showoverlay then
                table.insert(categories,
                    { id = k, name = k, image = "./img/categories/" .. k .. ".png" })
            end
        else
            table.insert(categories,
                { id = k, name = k, image = "./img/categories/" .. k .. ".png" })
        end
    end

    local items = {}
    for key, value in pairs(menucategories[selectedgender]) do
        for index, cat in pairs(value) do
            if MURPHY_ASSETS[selectedgender][cat] == nil then
                -- print("Category not found: " .. cat)
            else
                if next(MURPHY_ASSETS[selectedgender][cat]) ~= nil then
                    if tostring(key) ~= "categories" then
                        table.insert(items, {
                            id = cat,
                            name = Lang.Categories[cat] or cat,
                            category = key,
                            totalAmount = #MURPHY_ASSETS[selectedgender][cat],
                            selectorType = "slider",
                            contextual = "variation",
                            value = hairstyleCache[cat].model or 0,
                        })
                    end
                end
            end
            if showoverlay then
                for overlay, v in pairs(overlays_info) do
                    if overlay == cat then
                        table.insert(items, {
                            id = cat,
                            name = Lang.Categories[cat] or cat,
                            category = key,
                            totalAmount = #overlays_info[cat],
                            selectorType = "slider",
                            contextual = "variation",
                            value = 0,
                        })
                    end
                end
            end
        end
    end

    SendNUIMessage(
        {
            type = "openOutfitMenu",
            categories = categories,
            items = items
        }
    )
end

ContextualDataOn = false
function UpdateContextualDatas(value, category)
    local selectedgender = "female"
    if CachePedData.gender == "Male" then selectedgender = "male" end
    if value then
        if value > 0 then
            if overlays_info[category] then
                local tints = {
                    { tintId = 1, value = 1 },
                    { tintId = 2, value = 1 },
                    { tintId = 3, value = 1 }
                }
                local variationAmount = 1
                if category == "eyeliners" then variationAmount = 15 end
                if category == "shadows" then variationAmount = 5 end
                if category == "lipsticks" then variationAmount = 7 end
                local data = {
                    variationAmount = variationAmount,
                    variationValue = 1,
                    tints = tints,
                    contextual = "variation",
                    advanced = true,
                    advancedValues = {
                        {
                            valueName = "Opacity",
                            valueId = 1,
                            valueValue = 100,
                            maxValue = 100,
                            minValue = 0
                        },
                        {
                            valueName = "Palette",
                            valueId = 2,
                            valueValue = 1,
                            maxValue = 25,
                            minValue = 1
                        }
                    },
                    category = category,
                }

                SendNUIMessage(
                    {
                        type = "contextualDatas",
                        data = data

                    }
                )
            else
                local variationValue = 1
                if type(hairstyleCache[category].texture) == "table" then
                    variationValue = hairstyleCache[category].texture.palette or hairstyleCache[category].texture.model
                else
                    variationValue = hairstyleCache[category].texture
                end
                local variationAmount = 1
                local tints = {}
                if MURPHY_ASSETS[selectedgender][category][value].variants then
                    variationAmount = #MURPHY_ASSETS[selectedgender][category][value].variants
                    tint0value = hairstyleCache[category].texture.tint0 or
                        MURPHY_ASSETS[selectedgender][category][value].variants[1].tint[1] or 1
                    tint1value = hairstyleCache[category].texture.tint1 or
                        MURPHY_ASSETS[selectedgender][category][value].variants[1].tint[2] or 1
                    tint2value = hairstyleCache[category].texture.tint2 or
                        MURPHY_ASSETS[selectedgender][category][value].variants[1].tint[3] or 1
                    tints = {
                        { tintId = 1, value = tint0value },
                        { tintId = 2, value = tint1value },
                        { tintId = 3, value = tint2value }
                    }
                else
                    variationAmount = #MURPHY_ASSETS[selectedgender][category][value]
                    if type(hairstyleCache[category].texture) == "table" then
                        tint0value = hairstyleCache[category].texture.tint0 or 1
                        tint1value = hairstyleCache[category].texture.tint1 or 1
                        tint2value = hairstyleCache[category].texture.tint2 or 1
                    else
                        tint0value = 1
                        tint1value = 1
                        tint2value = 1
                    end
                    tints = {
                        { tintId = 1, value = tint0value },
                        { tintId = 2, value = tint1value },
                        { tintId = 3, value = tint2value }
                    }
                end
                local data = {
                    variationAmount = variationAmount,
                    variationValue = variationValue or 1,
                    tints = tints,
                    contextual = "variation",
                    category = category,
                }

                SendNUIMessage(
                    {
                        type = "contextualDatas",
                        data = data

                    }
                )
            end
            if ContextualDataOn == false then
                ContextualDataOn = true
                PlaySound("SELECT", "HUD_PLAYER_MENU")
            end
        else
            PlaySound("BACK", "HUD_PLAYER_MENU")
            ContextualDataOn = false
            SendNUIMessage(
                {
                    type = "hidecontextualDatas",

                }
            )
        end
    end
end
