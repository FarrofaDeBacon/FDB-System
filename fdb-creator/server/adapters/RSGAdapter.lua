if Config.framework == 'rsg-core' then
    local RSGCore = exports['fdb-core']:GetCoreObject()
    local creatingCharacters = {} -- Track character creation by source to prevent duplicates


    function GetCharIdentifier(targetID)
        targetID = tonumber(targetID)
        return RSGCore.Functions.GetPlayer(targetID).PlayerData.citizenid
    end

    function GetCharFirstname(targetID)
        targetID = tonumber(targetID)
        return RSGCore.Functions.GetPlayer(targetID).PlayerData.charinfo.firstname
    end

    function GetCharLastname(targetID)
        targetID = tonumber(targetID)
        return RSGCore.Functions.GetPlayer(targetID).PlayerData.charinfo.lastname
    end

    local plyChars = {} -- Table to store characters per player
    RegisterServerEvent("fdb-creator:getCharacters", function()
        local _source = source
        local license = RSGCore.Functions.GetIdentifier(source, 'license')
        local permissions = RSGCore.Functions.GetPermission(source)
        for key, value in pairs(permissions) do
            if value == false then
                permissions[key] = nil
            end
        end
        PutPlayerinInstance(_source)
        plyChars[_source] = {} -- Initialize character table for this specific player
        local totalQueries = 0
        MySQL.Async.fetchAll('SELECT * FROM players WHERE license = @license', { ['@license'] = license },
            function(result)
                for i = 1, (#result), 1 do
                    totalQueries = totalQueries + 2
                    local charData = result[i] -- Create a local reference to avoid closure issues
                    charData.charinfo = json.decode(charData.charinfo)
                    charData.money = json.decode(charData.money)
                    charData.job = json.decode(charData.job)
                    local citizenid = charData.citizenid -- Store citizenid locally
                    local sourceId = _source -- Store source locally for this iteration
                    
                    MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', { citizenid },
                        function(data)
                            if data ~= nil and #data > 0 then
                                local skinData = json.decode(data[1].skin)
                                local clothesData = json.decode(data[1].clothes)
                                charData.skin = skinData
                                charData.clothes = clothesData
                            else
                                charData.skin = {}
                                charData.clothes = {}
                            end
                            totalQueries = totalQueries - 1
                            MySQL.Async.fetchAll('SELECT * FROM fdb_creator WHERE `charid`=@charid;',
                                { charid = citizenid },
                                function(data)
                                    if data[1] ~= nil then
                                        charData.informations = json.decode(data[1].informations)
                                        charData.peddata = json.decode(data[1].peddata)
                                    else
                                        charData.peddata = {}
                                        charData.informations = {
                                            lore = "",
                                            birthday = "",
                                            birthmonth =
                                            "",
                                            birthyear = ""
                                        }
                                    end
                                    -- Verify the player is still the same before adding the character
                                    if plyChars[sourceId] then
                                        plyChars[sourceId][#plyChars[sourceId] + 1] = charData
                                    end
                                    totalQueries = totalQueries - 1
                                end)
                        end)
                end
            end)
        repeat
            Wait(100)
        until totalQueries == 0
        Wait(1000) -- Wait for all queries to finish
        local slots = Slots.default
        local pedperm = PedPermission.default
        for i, v in pairs(permissions) do
            if Slots.role[i] ~= nil then
                if slots < Slots.role[i] then
                    slots = Slots.role[i]
                end
            end
            if PedPermission.role[i] ~= nil then
                if pedperm == false and PedPermission.role[i] == true then
                    pedperm = PedPermission.role[i]
                end
            end
        end

        if Slots.identifier[license] ~= nil then
            slots = Slots.identifier[license]
        end
        if slots == nil then
            slots = Slots.default
        end

        if PedPermission.identifier[license] ~= nil then
            pedperm = PedPermission.identifier[license]
        end
        if pedperm == nil then
            pedperm = PedPermission.default
        end

        TriggerClientEvent('fdb-creator:LaunchCharSelect', _source, plyChars[_source], pedperm, slots)
    end)

    RegisterServerEvent("fdb-creator:deleteCharacter", function(charid)
        local _source = source
        
        -- Check if player has permission to delete characters
        if not CanPlayerDeleteCharacter(_source) then
            TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "You don't have permission to delete characters." } })
            TriggerClientEvent('fdb-creator:OpenCharSelect', _source)
            return
        end
        
        -- Validate that plyChars exists for this player and the character exists
        if not plyChars[_source] then
            print("^1[fdb-creator] Error: No character data found for player " .. _source .. "^7")
            return
        end
        
        if not plyChars[_source][charid] then
            print("^1[fdb-creator] Error: Character index " .. charid .. " not found for player " .. _source .. "^7")
            return
        end
        
        local _charid = plyChars[_source][charid].citizenid
        
        if not _charid then
            print("^1[fdb-creator] Error: No citizenid found for character " .. charid .. "^7")
            return
        end
        
        RSGCore.Player.DeleteCharacter(source, _charid)
        MySQL.update('DELETE FROM playerskins WHERE citizenid = ?', { _charid })

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

        -- Remove the deleted character from the player's character list
        table.remove(plyChars[_source], charid)
        
        Wait(5000)
        TriggerClientEvent('fdb-creator:OpenCharSelect', _source)
    end)


    function CreateNewCharacter(src, data)
        local source = src
        
        -- Prevent duplicate character creation
        if creatingCharacters[source] then
            print("^3[FDB-CREATOR WARNING]^7 Character creation already in progress for source " .. source)
            return
        end
        
        creatingCharacters[source] = true
        
        local license = RSGCore.Functions.GetIdentifier(source, 'license')
        local characters = MySQL.Sync.fetchAll('SELECT * FROM players WHERE license = ?', { license })
        
        -- Check if player has reached their slot limit
        local permissions = RSGCore.Functions.GetPermission(source)
        for key, value in pairs(permissions) do
            if value == false then
                permissions[key] = nil
            end
        end
        
        local slots = Slots.default
        for i, v in pairs(permissions) do
            if Slots.role[i] ~= nil then
                if slots < Slots.role[i] then
                    slots = Slots.role[i]
                end
            end
        end
        
        if Slots.identifier[license] ~= nil then
            slots = Slots.identifier[license]
        end
        if slots == nil then
            slots = Slots.default
        end
        
        -- Prevent character creation if at or over slot limit
        if #characters >= slots then
            print("^3[FDB-CREATOR]^7 Player " .. source .. " cannot create character - slot limit reached (" .. #characters .. "/" .. slots .. ")")
            creatingCharacters[source] = nil
            TriggerClientEvent('fdb-creator:notify', source, 'You have reached your maximum character slots!', 'error')
            return
        end
        
        local cid = #characters + 1
        local gender = data.gender == 'Male' and 0 or 1
        local newData = {
            firstname = data.firstname,
            lastname = data.lastname,
            nationality = data.SpawnLocationName,
            gender = gender,
            birthdate = data.birthyear .. '-' .. data.birthmonth .. '-' .. data.birthday,
            cid = cid
        }
        TriggerClientEvent("fdb-creator:createnewchar", source, newData)
        RemovePlayerFromInstance(source)
        Wait(2000)
        local charid = GetCharIdentifier(source)
        MySQL.Async.insert('INSERT INTO playerskins (citizenid, skin, clothes) VALUES (?, ?, ?);',
            { charid, json.encode({ sex = gender }), json.encode({}) }, function(rowsChanged)

            end)
        TriggerClientEvent("fdb-creator:rsg:getcitizenid", source, charid)
        
        -- Reset the flag after a delay
        SetTimeout(5000, function()
            creatingCharacters[source] = nil
        end)
    end

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
                MySQL.query("SELECT * FROM playerskins WHERE `citizenid`=@citizenid;", { citizenid = charid },
                    function(skins)
                        if skins[1] then
                            local skin = skins[1].skin
                            local decoded = json.decode(skin)
                            local skin_tone = decoded.skin_tone
                            if male then
                                if tonumber(skin_tone) == 1 then
                                    albedo = GetHashKey("mp_head_mr1_sc08_c0_000_ab")
                                elseif tonumber(skin_tone) == 2 then
                                    albedo = GetHashKey("mp_head_mr1_sc03_c0_000_ab")
                                elseif tonumber(skin_tone) == 3 then
                                    albedo = GetHashKey("mp_head_mr1_sc02_c0_000_ab")
                                elseif tonumber(skin_tone) == 4 then
                                    albedo = GetHashKey("mp_head_mr1_sc04_c0_000_ab")
                                elseif tonumber(skin_tone) == 5 then
                                    albedo = GetHashKey("MP_head_mr1_sc01_c0_000_ab")
                                elseif tonumber(skin_tone) == 6 then
                                    albedo = GetHashKey("MP_head_mr1_sc05_c0_000_ab")
                                else
                                    albedo = GetHashKey("mp_head_mr1_sc08_c0_000_ab")
                                end
                            else
                                if tonumber(skin_tone) == 1 then
                                    albedo = GetHashKey("mp_head_fr1_sc08_c0_000_ab")
                                elseif tonumber(skin_tone) == 2 then
                                    albedo = GetHashKey("mp_head_fr1_sc03_c0_000_ab")
                                elseif tonumber(skin_tone) == 3 then
                                    albedo = GetHashKey("mp_head_fr1_sc02_c0_000_ab")
                                elseif tonumber(skin_tone) == 4 then
                                    albedo = GetHashKey("mp_head_fr1_sc04_c0_000_ab")
                                elseif tonumber(skin_tone) == 5 then
                                    albedo = GetHashKey("MP_head_fr1_sc01_c0_000_ab")
                                elseif tonumber(skin_tone) == 6 then
                                    albedo = GetHashKey("mp_head_fr1_sc05_c0_000_ab")
                                else
                                    albedo = GetHashKey("mp_head_fr1_sc08_c0_000_ab")
                                end
                            end
                        end
                    end)
            end
        end)
        repeat
            Wait(0)
        until albedo ~= nil
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
        
        local Player = RSGCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        -- Check identifier first (highest priority)
        local identifiers = GetPlayerIdentifiers(source)
        for _, id in pairs(identifiers) do
            if Config.CharacterDeletion.identifier[id] then
                return true
            end
        end
        
        -- Check role (using RSG permission system)
        local group = RSGCore.Functions.GetPermission(source)
        if Config.CharacterDeletion.role[group] then
            return true
        end
        
        return false
    end

    -- ═══════════════════════════════════════════════════════════════════════════
    -- Admin command to delete a character by citizenid
    -- Usage: /deletechar [citizenid]
    -- ═══════════════════════════════════════════════════════════════════════════
    if Config.Commands and Config.Commands.deleteCharacter and Config.Commands.deleteCharacter.enabled then
        RegisterCommand(Config.Commands.deleteCharacter.command, function(source, args, rawCommand)
            local _source = source
            
            -- Check permissions
            local hasPermission = false
            local group = RSGCore.Functions.GetPermission(_source)
            
            for _, role in pairs(Config.Commands.deleteCharacter.allowedRoles) do
                if group == role then
                    hasPermission = true
                    break
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
                TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "You don't have permission to use this command." } })
                return
            end
            
            -- Check if citizenid was provided
            if not args[1] then
                TriggerClientEvent('chat:addMessage', _source, { args = { "^3[fdb-creator]", "Usage: /" .. Config.Commands.deleteCharacter.command .. " [citizenid]" } })
                return
            end
            
            local citizenid = args[1]
            
            -- Delete character data
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
            MySQL.query('SELECT charinfo FROM players WHERE citizenid = @citizenid;',
                { ['@citizenid'] = citizenid }, function(result)
                    if result and result[1] then
                        local charinfo = json.decode(result[1].charinfo)
                        local charName = charinfo.firstname .. " " .. charinfo.lastname
                        
                        -- Delete from murphy tables
                        deleteIfTableExists('fdb_creator', citizenid)
                        deleteIfTableExists('fdb_barber', citizenid)
                        deleteIfTableExists('fdb_barber_preset', citizenid)
                        deleteIfTableExists('fdb_clothes', citizenid)
                        deleteIfTableExists('fdb_outfits', citizenid)
                        deleteIfTableExists('fdb_wearable', citizenid)
                        
                        -- Delete from RSG tables
                        MySQL.update('DELETE FROM playerskins WHERE citizenid = ?', { citizenid })
                        MySQL.update('DELETE FROM players WHERE citizenid = ?', { citizenid })
                        
                        TriggerClientEvent('chat:addMessage', _source, { args = { "^2[fdb-creator]", "Character '" .. charName .. "' (ID: " .. citizenid .. ") has been deleted." } })
                        print("[fdb-creator] Admin " .. GetPlayerName(_source) .. " deleted character: " .. charName .. " (ID: " .. citizenid .. ")")
                    else
                        TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "Character with ID " .. citizenid .. " not found." } })
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
            local group = RSGCore.Functions.GetPermission(_source)
            
            for _, role in pairs(Config.Commands.secondChance.allowedRoles) do
                if group == role then
                    hasPermission = true
                    break
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
                TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "You don't have permission to use this command." } })
                return
            end
            
            -- Check if player ID was provided
            if not args[1] then
                TriggerClientEvent('chat:addMessage', _source, { args = { "^3[fdb-creator]", "Usage: /" .. Config.Commands.secondChance.command .. " [playerid]" } })
                return
            end
            
            local targetId = tonumber(args[1])
            if not targetId then
                TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "Invalid player ID. Must be a number." } })
                return
            end
            
            -- Check if target player exists
            local targetPlayer = GetPlayerName(targetId)
            if not targetPlayer then
                TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "Player with ID " .. targetId .. " not found." } })
                return
            end
            
            -- Trigger the character customization menu for the target player
            TriggerClientEvent('fdb-creator:SecondChance', targetId)
            TriggerClientEvent('chat:addMessage', _source, { args = { "^2[fdb-creator]", "Opened character customization menu for " .. targetPlayer .. " (ID: " .. targetId .. ")" } })
            TriggerClientEvent('chat:addMessage', targetId, { args = { "^2[fdb-creator]", "An admin has opened the character customization menu for you." } })
            print("[fdb-creator] Admin " .. GetPlayerName(_source) .. " opened second chance menu for: " .. targetPlayer .. " (ID: " .. targetId .. ")")
        end, false)
    end
end
