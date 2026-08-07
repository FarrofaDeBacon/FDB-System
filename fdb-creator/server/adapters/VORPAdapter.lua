if Config.framework == 'vorp' then
    VorpInv = exports.vorp_inventory:vorp_inventoryApi()

    local VorpCore = {}
    local creatingCharacters = {} -- Track character creation by source to prevent duplicates

    TriggerEvent("getCore", function(core)
        VorpCore = core
    end)


    function GetCharIdentifier(targetID)
        local user = VorpCore.getUser(targetID)
        if user then
            charid = VorpCore.getUser(targetID).getUsedCharacter.charIdentifier
        else
            charid = nil
        end
        return charid
    end

    function GetCharFirstname(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.firstname
    end

    function GetCharLastname(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.lastname
    end

    function GetCharGroup(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.group
    end

    -- Event handler to send health data from VORP Core database
    RegisterNetEvent("fdb_creator:GetHealthValues", function()
        local _source = source
        local healthData = { hOuter = 600, hInner = 600, sOuter = 100, sInner = 600 }
        
        local User = VorpCore.getUser(_source)
        if User then
            local Character = User.getUsedCharacter
            if Character then
                -- Get health values from VORP Core character
                healthData.hOuter = Character.health or 600
                healthData.hInner = Character.healthInner or 600
                healthData.sOuter = Character.stamina or 100
                healthData.sInner = Character.staminaInner or 600
            end
        end
        
        -- Send health data back to client
        TriggerClientEvent("fdb_creator:HealthFromCore", _source, healthData)
    end)

    function CreateNewCharacter(src, data)
        local _source = src
        
        -- Prevent duplicate character creation
        if creatingCharacters[_source] then
            print("^3[FDB-CREATOR WARNING]^7 Character creation already in progress for source " .. _source)
            return
        end
        
        creatingCharacters[_source] = true
        
        -- Check if player has reached their slot limit
        local User = VorpCore.getUser(_source)
        if not User then
            creatingCharacters[_source] = nil
            return
        end
        
        local id = User.getIdentifier()
        local characters = User.getUserCharacters
        local numChars = 0
        for _ in pairs(characters) do
            numChars = numChars + 1
        end
        
        -- Get player's slot limit
        local permissions = User.getGroup
        local slots = Slots.default
        if Slots.role[permissions] ~= nil then
            slots = Slots.role[permissions]
        end
        if Slots.identifier[id] ~= nil then
            slots = Slots.identifier[id]
        end
        if slots == nil then
            slots = Slots.default
        end
        
        -- Prevent character creation if at or over slot limit
        if numChars >= slots then
            print("^3[FDB-CREATOR]^7 Player " .. _source .. " cannot create character - slot limit reached (" .. numChars .. "/" .. slots .. ")")
            creatingCharacters[_source] = nil
            TriggerClientEvent('vorp:TipRight', _source, 'You have reached your maximum character slots!', 5000)
            return
        end
        
        local Playerdata = {}
        local function GetNewCompOldStructure(comps)
            local NewComps = {}
            for key, value in pairs(comps) do
                NewComps[key] = value.comp
            end
            return NewComps
        end


        local PlayerTrackingData = {}
        PlayerTrackingData.Gunbelt = {}
        if data.gender == "Male" then
            PlayerSkin.sex = "mp_male"
            PlayerClothing.Gunbelt = { comp = 795591403, tint0 = 0, tint1 = 0, tint2 = 0, palette = 0 }
            PlayerTrackingData.Gunbelt[795591403] = { tint0 = 0, tint1 = 0, tint2 = 0, palette = 0 }
        else
            PlayerSkin.sex = "mp_female"
            PlayerClothing.Gunbelt = { comp = 1511461630, tint0 = 0, tint1 = 0, tint2 = 0, palette = 0 }
            PlayerTrackingData.Gunbelt[1511461630] = { tint0 = 0, tint1 = 0, tint2 = 0, palette = 0 }
        end
        local NewTable = GetNewCompOldStructure(PlayerClothing)
        PlayerSkin.albedo = GetHashKey(DefaultChar[data.gender][data.skintone].HeadTexture[1])
        PlayerSkin.BodyType = data.body
        PlayerSkin.LegsType = data.legs

        Playerdata.skin = json.encode(PlayerSkin)
        Playerdata.comps = json.encode(NewTable)
        Playerdata.compTints = json.encode(PlayerTrackingData)
        Playerdata.gender = data.gender
        Playerdata.age = 30
        Playerdata.nickname = "none"
        Playerdata.charDescription = data.lore
        Playerdata.desc = data.lore
        Playerdata.firstname = data.firstname
        Playerdata.lastname = data.lastname
        -- TriggerServerEvent("vorpcharacter:saveCharacter", Playerdata)
        VorpCore.getUser(_source).addCharacter(Playerdata)
        RemovePlayerFromInstance(_source)
        TriggerClientEvent("vorp:initCharacter", _source, data.pedspawn, data.pedspawnheading, false)
        Citizen.SetTimeout(3000, function()
            TriggerEvent("vorp_NewCharacter", _source)
            Wait(3000)
            TriggerClientEvent("vorpcharacter:updateCache", _source, PlayerSkin, NewTable)
            
            -- Reset the flag after completion
            SetTimeout(2000, function()
                creatingCharacters[_source] = nil
            end)
        end)
    end

    RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
        local src = source
        Wait(1500)
        TriggerClientEvent("fdb-creator:loadskinvorp", src)
    end)

    RegisterServerEvent("fdb-creator:deleteCharacter", function(_charid)
        local _source = source
        
        -- Check if player has permission to delete characters
        if not CanPlayerDeleteCharacter(_source) then
            TriggerClientEvent('vorp:TipRight', _source, "You don't have permission to delete characters.", 4000)
            TriggerClientEvent('fdb-creator:OpenCharSelect', _source)
            return
        end
        
        local function deleteIfTableExists(tableName, charid)
            MySQL.query('SELECT COUNT(*) as count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tableName;',
                {
                    ['@tableName'] = tableName
                }, function(result)
                    if result[1] and result[1].count > 0 then
                        MySQL.query('DELETE FROM ' .. tableName .. ' WHERE charid = @charid;',
                            { ['@charid'] = charid })
                    else
                    end
                end)
        end
        deleteIfTableExists('fdb_creator', _charid)
        deleteIfTableExists('fdb_barber', _charid)
        deleteIfTableExists('fdb_barber_preset', _charid)
        deleteIfTableExists('fdb_clothes', _charid)
        deleteIfTableExists('fdb_outfits', _charid)
        deleteIfTableExists('fdb_wearable', _charid)
        TriggerClientEvent("fdb-creator:deleteCharacterClient", _source, _charid)
        Wait(2000)
        TriggerClientEvent('fdb-creator:OpenCharSelect', _source)
    end)

    RegisterServerEvent("fdb_creator:vorpcharacter:deleteCharacter")
    AddEventHandler("fdb_creator:vorpcharacter:deleteCharacter", function(charid)
        local User = VorpCore.getUser(source)
        if User then
            User.removeCharacter(charid)
        end
    end)

    RegisterServerEvent("fdb-creator:getCharacters")
    AddEventHandler("fdb-creator:getCharacters", function()
        local _source = source
        if _source == nil then
            return
        end
        PutPlayerinInstance(_source)
        local User = VorpCore.getUser(_source)
        local perm = User.getGroup
        local id
        local identifierUsed = 'steam'
        for k, v in ipairs(GetPlayerIdentifiers(_source)) do
            if string.sub(v, 1, string.len(identifierUsed .. ":")) == (identifierUsed .. ":") then
                id = v
                break
            end
        end
        local UserCharacters = GetPlayerData(_source)
        MySQL.query('SELECT * FROM characters WHERE `identifier`=@identifier;', { identifier = id }, function(result)
            local totalQueries = 0
            for k, v in pairs(result) do
                totalQueries = totalQueries + 1
                MySQL.query('SELECT * FROM fdb_creator WHERE `charid`=@charid;', { charid = v.charidentifier },
                    function(data)
                        if UserCharacters then
                            if data[1] ~= nil then
                                UserCharacters[v.charidentifier].informations = json.decode(data[1].informations)
                                UserCharacters[v.charidentifier].peddata = json.decode(data[1].peddata)
                            else
                                UserCharacters[v.charidentifier].peddata = {}
                                UserCharacters[v.charidentifier].informations = {
                                    lore = "",
                                    birthday = "",
                                    birthmonth =
                                    "",
                                    birthyear = ""
                                }
                            end
                        end
                        totalQueries = totalQueries - 1
                    end)
            end
            repeat
                Wait(100)
            until totalQueries == 0
            local slots = nil
            local pedperm = nil
            if Slots.role[perm] ~= nil then
                slots = Slots.role[perm]
            end
            if Slots.identifier[id] ~= nil then
                slots = Slots.identifier[id]
            end
            if slots == nil then
                slots = Slots.default
            end

            if PedPermission.role[perm] ~= nil then
                pedperm = PedPermission.role[perm]
            end
            if PedPermission.identifier[id] ~= nil then
                pedperm = PedPermission.identifier[id]
            end
            if pedperm == nil then
                pedperm = PedPermission.default
            end

            TriggerClientEvent('fdb-creator:LaunchCharSelect', _source, UserCharacters, pedperm,
                slots)
        end)
    end)



    function Checkmissingkeys(data, key)
        local switch = false
        if key == "skin" then
            for k, v in pairs(PlayerSkin) do
                if data[k] == nil then
                    switch = true
                    data[k] = v
                end
                if data.Eyes == 0 then
                    switch = true
                    if data.sex == "mp_male" then
                        data.Eyes = 612262189
                    else
                        data.Eyes = 928002221
                    end
                end
            end
            return data, switch
        end
        if key == "comps" then
            for k, v in pairs(PlayerClothing) do
                if data[k] == nil then
                    data[k] = v.comp
                end
            end
            return data, switch
        end
    end

    function ConvertTable(comps, compTints)
        local NewComps = {}

        for k, comp in pairs(comps) do
            NewComps[k] = { comp = comp, tint0 = 0, tint1 = 0, tint2 = 0, palette = 0 }

            if compTints and compTints[k] and compTints[k][tostring(comp)] then
                local compTint = compTints[k][tostring(comp)]
                NewComps[k].tint0 = compTint.tint0 or 0
                NewComps[k].tint1 = compTint.tint1 or 0
                NewComps[k].tint2 = compTint.tint2 or 0
                NewComps[k].palette = compTint.palette or 0
            end
        end

        return NewComps
    end

    function UpdateDatabase(character)
        local json_skin = json.decode(character.skin)
        local json_comps = json.decode(character.comps)
        local compTints = json.decode(character.compTints)
        local skin, updateSkin = Checkmissingkeys(json_skin, "skin")
        local comps, updateComp = Checkmissingkeys(json_comps, "comps")

        if updateSkin then
            character.updateSkin((json.encode(skin)))
        end

        if updateComp then
            character.updateComps(json.encode(comps))
        end

        local NewComps = ConvertTable(comps, compTints)

        return skin, NewComps
    end

    function GetPlayerData(source)
        local User = VorpCore.getUser(source)

        if not User then
            return false
        end
        local Characters = User.getUserCharacters


        local userCharacters = {}
        for _, characters in pairs(Characters) do
            local skin, comps = UpdateDatabase(characters)
            local userChars = {
                charIdentifier = characters.charIdentifier,
                money = characters.money,
                gold = characters.gold,
                firstname = characters.firstname,
                lastname = characters.lastname,
                skin = skin,
                components = comps,
                coords = json.decode(characters.coords),
                isDead = characters.isdead,
                job = characters.jobLabel or "Unemployed",
                grade = characters.jobGrade or "",
                group = characters.group or "",
                age = characters.age or "",
                nickname = characters.nickname or "",
                gender = characters.gender or "",
                charDesc = characters.charDescription or "",
            }
            userCharacters[characters.charIdentifier] = userChars
        end
        return userCharacters
    end

    PlayerSkin = {
        ShouldersS                           = 0.0,
        ShouldersT                           = 0.0,
        ShouldersM                           = 0.0,
        ArmsS                                = 0.0,
        LegsS                                = 0.0,
        CalvesS                              = 0.0,
        ChestS                               = 0.0,
        WaistW                               = 0.0,
        HipsS                                = 0.0,
        FaceW                                = 0.0,
        FaceD                                = 0.0,
        FaceS                                = 0.0,
        NeckW                                = 0.0,
        NeckD                                = 0.0,
        MouthCLW                             = 0.0,
        MouthCRW                             = 0.0,
        MouthCLD                             = 0.0,
        MouthCRD                             = 0.0,
        MouthCLH                             = 0.0,
        MouthCRH                             = 0.0,
        MouthCLLD                            = 0.0,
        MouthCRLD                            = 0.0,
        EyeLidL                              = 0.0,
        EyeLidR                              = 0.0,
        sex                                  = "mp_male",
        albedo                               = 0,
        HeadType                             = 0,
        BodyType                             = 0,
        LegsType                             = 0,
        Torso                                = 0,
        HeadSize                             = 0.0,
        EyeBrowH                             = 0.0,
        EyeBrowW                             = 0.0,
        EyeBrowD                             = 0.0,
        EarsH                                = 0.0,
        EarsW                                = 0.0,
        EarsD                                = 0.0,
        EarsA                                = 0.0,
        EyeLidH                              = 0.0,
        EyeLidW                              = 0.0,
        EyeD                                 = 0.0,
        EyeAng                               = 0.0,
        EyeDis                               = 0.0,
        EyeH                                 = 0.0,
        NoseW                                = 0.0,
        NoseS                                = 0.0,
        NoseH                                = 0.0,
        NoseAng                              = 0.0,
        NoseC                                = 0.0,
        NoseDis                              = 0.0,
        CheekBonesH                          = 0.0,
        CheekBonesW                          = 0.0,
        CheekBonesD                          = 0.0,
        MouthW                               = 0.0,
        MouthD                               = 0.0,
        MouthX                               = 0.0,
        MouthY                               = 0.0,
        ULiphH                               = 0.0,
        ULiphW                               = 0.0,
        ULiphD                               = 0.0,
        LLiphH                               = 0.0,
        LLiphW                               = 0.0,
        LLiphD                               = 0.0,
        JawH                                 = 0.0,
        JawW                                 = 0.0,
        JawD                                 = 0.0,
        ChinH                                = 0.0,
        ChinW                                = 0.0,
        ChinD                                = 0.0,
        Beard                                = 0,
        Hair                                 = 0,
        Body                                 = 0,
        Waist                                = 0,
        Eyes                                 = 0,
        Scale                                = 0.0,
        eyebrows_visibility                  = 0,
        eyebrows_tx_id                       = 0,
        eyebrows_opacity                     = 0.0,
        eyebrows_color                       = 0,
        scars_visibility                     = 0,
        scars_tx_id                          = 0,
        scars_opacity                        = 0,
        spots_visibility                     = 0,
        spots_tx_id                          = 0,
        spots_opacity                        = 0,
        disc_visibility                      = 0,
        disc_tx_id                           = 0,
        disc_opacity                         = 0,
        complex_visibility                   = 0,
        complex_tx_id                        = 0,
        complex_opacity                      = 0,
        acne_visibility                      = 0,
        acne_tx_id                           = 0,
        acne_opacity                         = 0,
        ageing_visibility                    = 0,
        ageing_tx_id                         = 0,
        ageing_opacity                       = 0,
        freckles_visibility                  = 0,
        freckles_tx_id                       = 0,
        freckles_opacity                     = 0,
        moles_visibility                     = 0,
        moles_tx_id                          = 0,
        moles_opacity                        = 0,
        grime_visibility                     = 0,
        grime_tx_id                          = 0,
        grime_opacity                        = 0,
        lipsticks_visibility                 = 0,
        lipsticks_tx_id                      = 0,
        lipsticks_palette_id                 = 0,
        lipsticks_palette_color_primary      = 0,
        lipsticks_palette_color_secondary    = 0,
        lipsticks_palette_color_tertiary     = 0,
        lipsticks_opacity                    = 0,
        shadows_visibility                   = 0,
        shadows_tx_id                        = 0,
        shadows_palette_id                   = 0,
        shadows_palette_color_primary        = 0,
        shadows_palette_color_secondary      = 0,
        shadows_palette_color_tertiary       = 0,
        shadows_opacity                      = 0,
        beardstabble_tx_id                   = 0,
        beardstabble_visibility              = 0,
        beardstabble_color_primary           = 0,
        beardstabble_opacity                 = 0,
        eyeliner_tx_id                       = 0,
        eyeliner_visibility                  = 0,
        eyeliner_color_primary               = 0,
        eyeliner_opacity                     = 0,
        eyeliner_palette_id                  = 0,
        blush_visibility                     = 0,
        blush_tx_id                          = 0,
        blush_palette_id                     = 0,
        blush_palette_color_primary          = 0,
        blush_opacity                        = 0,
        hair_tx_id                           = 0,
        hair_visibility                      = 0,
        hair_color_primary                   = 0,
        hair_opacity                         = 0,
        foundation_tx_id                     = 0,
        foundation_visibility                = 0,
        foundation_palette_id                = 0,
        foundation_palette_color_primary     = 0,
        foundation_palette_color_secondary   = 0,
        foundation_palette_color_tertiary    = 0,
        foundation_opacity                   = 0,
        paintedmasks_tx_id                   = 0,
        paintedmasks_visibility              = 0,
        paintedmasks_palette_id              = 0,
        paintedmasks_palette_color_primary   = 0,
        paintedmasks_palette_color_secondary = 0,
        paintedmasks_palette_color_tertiary  = 0,
        paintedmasks_opacity                 = 0,

    }

    PlayerClothing = {
        Poncho      = { comp = -1 },
        Glove       = { comp = -1 },
        RingRh      = { comp = -1 },
        Gauntlets   = { comp = -1 },
        Spats       = { comp = -1 },
        GunbeltAccs = { comp = -1 },
        NeckTies    = { comp = -1 },
        bow         = { comp = -1 },
        RingLh      = { comp = -1 },
        Loadouts    = { comp = -1 },
        Boots       = { comp = -1 },
        Suspender   = { comp = -1 },
        NeckWear    = { comp = -1 },
        Holster     = { comp = -1 },
        CoatClosed  = { comp = -1 },
        EyeWear     = { comp = -1 },
        Shirt       = { comp = -1 },
        Gunbelt     = { comp = -1 },
        Hat         = { comp = -1 },
        Spurs       = { comp = -1 },
        Cloak       = { comp = -1 },
        Vest        = { comp = -1 },
        Belt        = { comp = -1 },
        Pant        = { comp = -1 },
        Skirt       = { comp = -1 },
        Coat        = { comp = -1 },
        Mask        = { comp = -1 },
        Accessories = { comp = -1 },
        Buckle      = { comp = -1 },
        Bracelet    = { comp = -1 },
        Satchels    = { comp = -1 },
        Dress       = { comp = -1 },
        Badge       = { comp = -1 },
        Armor       = { comp = -1 },
        Teeth       = { comp = -1 },
        Chap        = { comp = -1 },
    }

    Callback.register('fdb-barber:GetCharSkinTone', function(source, male, characterid)
        local _source = source
        local albedo = nil
        local charid = characterid or GetCharIdentifier(_source)
        MySQL.query("SELECT * FROM fdb_creator WHERE `charid`=@charid;", { charid = charid }, function(skins)
            if skins[1] then
                local pedata = skins[1].peddata
                local decoded = json.decode(pedata)
                local albedoindex = decoded.skintone
                local gender = "Female"
                if male then gender = "Male" end
                albedo = GetHashKey(DefaultChar[gender][albedoindex].HeadTexture[1])
            else
                MySQL.query("SELECT * FROM characters WHERE `charidentifier`=@charidentifier;",
                    { charidentifier = charid },
                    function(skins)
                        if skins[1] then
                            local skin = skins[1].skinPlayer
                            local decoded = json.decode(skin)
                            local data = {
                                albedo = decoded.albedo,
                                bodies_upper = decoded.BodyType,
                                bodies_lower = decoded
                                    .LegsType
                            }
                            albedo = data.albedo
                        end
                    end)
            end
        end)
        repeat
            Wait(0)
        until albedo ~= nil
        if albedo == 0 then
            if male then
                albedo = GetHashKey("mp_head_mr1_sc08_c0_000_ab")
            else
                albedo = GetHashKey("mp_head_fr1_sc08_c0_000_ab")
            end
        end
        return albedo
    end)
    
    -- Cleanup on player disconnect
    AddEventHandler('playerDropped', function()
        local source = source
        if creatingCharacters[source] then
            creatingCharacters[source] = nil
        end
    end)

    -- ═══════════════════════════════════════════════════════════════════════════
    -- Helper function to check if player can delete characters
    -- ═══════════════════════════════════════════════════════════════════════════
    function CanPlayerDeleteCharacter(source)
        if not Config.CharacterDeletion.enabled then
            return false
        end
        
        if not Config.CharacterDeletion.restrictToRoles then
            return true -- Everyone can delete
        end
        
        local User = VorpCore.getUser(source)
        if not User then return false end
        
        -- Check identifier first (highest priority)
        local identifiers = GetPlayerIdentifiers(source)
        for _, id in pairs(identifiers) do
            if Config.CharacterDeletion.identifier[id] then
                return true
            end
        end
        
        -- Check role
        local group = User.getGroup
        if Config.CharacterDeletion.role[group] then
            return true
        end
        
        return false
    end

    -- ═══════════════════════════════════════════════════════════════════════════
    -- Admin command to delete a character by charidentifier
    -- Usage: /deletechar [charidentifier]
    -- ═══════════════════════════════════════════════════════════════════════════
    if Config.Commands and Config.Commands.deleteCharacter and Config.Commands.deleteCharacter.enabled then
        RegisterCommand(Config.Commands.deleteCharacter.command, function(source, args, rawCommand)
            local _source = source
            
            -- Check permissions
            local hasPermission = false
            local User = VorpCore.getUser(_source)
            
            if User then
                local group = User.getGroup
                for _, role in pairs(Config.Commands.deleteCharacter.allowedRoles) do
                    if group == role then
                        hasPermission = true
                        break
                    end
                end
            end
            
            -- Check identifier permissions
            if not hasPermission then
                local identifiers = GetPlayerIdentifiers(_source)
                for _, id in pairs(identifiers) do
                    for _, allowedId in pairs(Config.Commands.deleteCharacter.allowedIdentifiers) do
                        if id == allowedId then
                            hasPermission = true
                            break
                        end
                    end
                end
            end
            
            if not hasPermission then
                TriggerClientEvent('vorp:TipRight', _source, "You don't have permission to use this command.", 4000)
                return
            end
            
            -- Check if charidentifier was provided
            if not args[1] then
                TriggerClientEvent('vorp:TipRight', _source, "Usage: /" .. Config.Commands.deleteCharacter.command .. " [charidentifier]", 4000)
                return
            end
            
            local charidentifier = tonumber(args[1])
            if not charidentifier then
                TriggerClientEvent('vorp:TipRight', _source, "Invalid charidentifier. Must be a number.", 4000)
                return
            end
            
            -- Delete character data from murphy tables
            local function deleteIfTableExists(tableName, charid)
                MySQL.query('SELECT COUNT(*) as count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tableName;',
                    {
                        ['@tableName'] = tableName
                    }, function(result)
                        if result[1] and result[1].count > 0 then
                            MySQL.query('DELETE FROM ' .. tableName .. ' WHERE charid = @charid;',
                                { ['@charid'] = charid })
                        end
                    end)
            end
            
            -- Get character info before deletion for logging
            MySQL.query('SELECT firstname, lastname FROM characters WHERE charidentifier = @charid;',
                { ['@charid'] = charidentifier }, function(result)
                    if result and result[1] then
                        local charName = result[1].firstname .. " " .. result[1].lastname
                        
                        -- Delete from murphy tables
                        deleteIfTableExists('fdb_creator', charidentifier)
                        deleteIfTableExists('fdb_barber', charidentifier)
                        deleteIfTableExists('fdb_barber_preset', charidentifier)
                        deleteIfTableExists('fdb_clothes', charidentifier)
                        deleteIfTableExists('fdb_outfits', charidentifier)
                        deleteIfTableExists('fdb_wearable', charidentifier)
                        
                        -- Delete from VORP characters table
                        MySQL.query('DELETE FROM characters WHERE charidentifier = @charid;',
                            { ['@charid'] = charidentifier }, function()
                                TriggerClientEvent('vorp:TipRight', _source, "Character '" .. charName .. "' (ID: " .. charidentifier .. ") has been deleted.", 5000)
                                print("[fdb-creator] Admin " .. GetPlayerName(_source) .. " deleted character: " .. charName .. " (ID: " .. charidentifier .. ")")
                            end)
                    else
                        TriggerClientEvent('vorp:TipRight', _source, "Character with ID " .. charidentifier .. " not found.", 4000)
                    end
                end)
        end, false)
    end

    -- ═══════════════════════════════════════════════════════════════════════════
    -- "Second Chance" command - Reopen character customization menu for a player
    -- Usage: /secondchance [playerid]
    -- ═══════════════════════════════════════════════════════════════════════════
    if Config.Commands and Config.Commands.secondChance and Config.Commands.secondChance.enabled then
        RegisterCommand(Config.Commands.secondChance.command, function(source, args, rawCommand)
            local _source = source
            
            -- Check permissions
            local hasPermission = false
            local User = VorpCore.getUser(_source)
            
            if User then
                local group = User.getGroup
                for _, role in pairs(Config.Commands.secondChance.allowedRoles) do
                    if group == role then
                        hasPermission = true
                        break
                    end
                end
            end
            
            -- Check identifier permissions
            if not hasPermission then
                local identifiers = GetPlayerIdentifiers(_source)
                for _, id in pairs(identifiers) do
                    for _, allowedId in pairs(Config.Commands.secondChance.allowedIdentifiers) do
                        if id == allowedId then
                            hasPermission = true
                            break
                        end
                    end
                end
            end
            
            if not hasPermission then
                TriggerClientEvent('vorp:TipRight', _source, "You don't have permission to use this command.", 4000)
                return
            end
            
            -- Check if player ID was provided
            if not args[1] then
                TriggerClientEvent('vorp:TipRight', _source, "Usage: /" .. Config.Commands.secondChance.command .. " [playerid]", 4000)
                return
            end
            
            local targetId = tonumber(args[1])
            if not targetId then
                TriggerClientEvent('vorp:TipRight', _source, "Invalid player ID. Must be a number.", 4000)
                return
            end
            
            -- Check if target player exists
            local targetPlayer = GetPlayerName(targetId)
            if not targetPlayer then
                TriggerClientEvent('vorp:TipRight', _source, "Player with ID " .. targetId .. " not found.", 4000)
                return
            end
            
            -- Trigger the character customization menu for the target player
            TriggerClientEvent('fdb-creator:SecondChance', targetId)
            TriggerClientEvent('vorp:TipRight', _source, "Opened character customization menu for " .. targetPlayer .. " (ID: " .. targetId .. ")", 5000)
            TriggerClientEvent('vorp:TipRight', targetId, "An admin has opened the character customization menu for you.", 5000)
            print("[fdb-creator] Admin " .. GetPlayerName(_source) .. " opened second chance menu for: " .. targetPlayer .. " (ID: " .. targetId .. ")")
        end, false)
    end
end
