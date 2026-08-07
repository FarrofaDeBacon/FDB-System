if Config.framework == "REDEMRP2k23" then
    Inventory = {}
    local RedEM = exports["redem_roleplay"]:RedEM()
    local identifierUsed = 'steam'
    local creatingCharacters = {} -- Track character creation by source to prevent duplicates
    TriggerEvent("redemrp_inventory:getData", function(data)
        Inventory = data
    end)

    function GetCharIdentifier(targetID)
        return RedEM.GetPlayer(targetID).citizenid
    end

    function GetCharFirstname(targetID)
        return RedEM.GetPlayer(targetID).firstname
    end

    function GetCharLastname(targetID)
        return RedEM.GetPlayer(targetID).lastname
    end

    RegisterServerEvent("fdb-creator:getCharacters", function()
        local _source = source
        local id
        print("^2[DB]^0 Getting characters for ^2" .. _source .. "^0")
        for k, v in ipairs(GetPlayerIdentifiers(_source)) do
            if string.sub(v, 1, string.len(identifierUsed .. ":")) == (identifierUsed .. ":") then
                id = v
                break
            end
        end
        PutPlayerinInstance(_source)

        MySQL.query('SELECT * FROM characters WHERE `identifier`=@identifier;', { identifier = id }, function(result)
            local totalQueries = 0
            for k, v in pairs(result) do
                totalQueries = totalQueries + 1
                local charData = v -- Create local reference to avoid closure issues
                local citizenid = v.citizenid -- Store citizenid locally
                local resultIndex = k -- Store the index locally
                
                MySQL.query('SELECT * FROM fdb_creator WHERE `charid`=@charid;', { charid = citizenid },
                    function(data)
                        if data[1] ~= nil then
                            charData.informations = json.decode(data[1].informations)
                            charData.peddata = json.decode(data[1].peddata)
                        else
                            charData.peddata = {}
                            charData.informations = { lore = "", birthday = "", birthmonth = "", birthyear = "" }
                        end
                        result[resultIndex] = charData -- Update the result with the modified charData
                        totalQueries = totalQueries - 1
                    end)
            end
            repeat
                Wait(100)
            until totalQueries == 0
            MySQL.query('SELECT * FROM skins WHERE `identifier`=@identifier;', { identifier = id }, function(result2)
                MySQL.query('SELECT * FROM clothes WHERE `identifier`=@identifier;', { identifier = id },
                    function(result3)
                        local result4 = MySQL.query.await('SELECT * FROM permissions WHERE identifier = ?', { id })
                        if result4[1] ~= nil then
                            perm = result4[1].permissiongroup
                        else
                            perm = nil
                        end
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

                        TriggerClientEvent('fdb-creator:LaunchCharSelect', _source, result, result2, result3, pedperm,
                            slots)
                    end)
            end)
        end)
    end)

    RegisterServerEvent("fdb-creator:deleteCharacter", function(_charid)
        local _source = source
        
        -- Check if player has permission to delete characters
        if not CanPlayerDeleteCharacter(_source) then
            TriggerClientEvent('chat:addMessage', _source, { args = { "^1[fdb-creator]", "You don't have permission to delete characters." } })
            TriggerClientEvent('fdb-creator:OpenCharSelect', _source)
            return
        end
        
        local id
        for k, v in ipairs(GetPlayerIdentifiers(_source)) do
            if string.sub(v, 1, string.len(identifierUsed .. ":")) == (identifierUsed .. ":") then
                id = v
                break
            end
        end
        local timeout = 0
        while id == nil and timeout < 10 do
            Wait(100); timeout = timeout + 1
        end
        MySQL.query('SELECT citizenid FROM characters WHERE identifier = @identifier AND characterid = @characterid;', {
            ['@identifier'] = id,
            ['@characterid'] = _charid
        }, function(result)
            if result[1] then
                local citizenid = result[1].citizenid

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
                deleteIfTableExists('fdb_creator', citizenid)
                deleteIfTableExists('fdb_barber', citizenid)
                deleteIfTableExists('fdb_barber_preset', citizenid)
                deleteIfTableExists('fdb_clothes', citizenid)
                deleteIfTableExists('fdb_outfits', citizenid)
                deleteIfTableExists('fdb_wearable', citizenid)
            end
        end)

        MySQL.query('DELETE FROM skins WHERE `identifier` = @identifier AND `charid`=@characterid;',
            { identifier = id, characterid = _charid })
        MySQL.query('DELETE FROM clothes WHERE `identifier` = @identifier AND `charid`=@characterid;',
            { identifier = id, characterid = _charid })
        -- MySQL.query('DELETE FROM horses WHERE `identifier` = @identifier AND `charid`=@characterid;', {identifier = id, characterid=_charid})
        MySQL.query('DELETE FROM user_inventory WHERE `identifier` = @identifier AND `charid`=@characterid;',
            { identifier = id, characterid = _charid })
        -- MySQL.query('DELETE FROM user_bills WHERE `owner` = @identifier AND `ownerCharId` = @characterid;', {identifier = id, characterid=_charid})
        MySQL.query('DELETE FROM outfits WHERE `identifier` = @identifier AND `charid` = @characterid;',
            { identifier = id, characterid = _charid })
        MySQL.query('DELETE FROM stashes WHERE `stashid` = @stashid;', { stashid = "bankstash_" .. id .. "_" .. _charid })
        MySQL.query('DELETE FROM stashes WHERE `stashid` = @stashid;',
            { stashid = "campstorage_" .. id .. "_" .. _charid })
        MySQL.query('DELETE FROM stashes WHERE `stashid` = @stashid;',
            { stashid = "campstorage_" .. id .. "_" .. _charid })
        MySQL.query('DELETE FROM characters WHERE `identifier` = @identifier AND `characterid`=@characterid;',
            { identifier = id, characterid = _charid }, function(result)
                if result then
                    TriggerClientEvent('fdb-creator:OpenCharSelect', _source)
                end
            end)
    end)


    function CreateNewCharacter(src, data)
        local _source = src
        
        -- Prevent duplicate character creation
        if creatingCharacters[_source] then
            print("^3[FDB-CREATOR WARNING]^7 Character creation already in progress for source " .. _source)
            return
        end
        
        creatingCharacters[_source] = true
        
        local firstname = data.firstname
        local lastname = data.lastname
        local id = RedEM.Functions.GetIdentifier(_source, "steam")
        print("^2[DB]^0 Creating character for ^2" .. id .. "^0 with name: ^2" .. firstname .. " " .. lastname .. "^0")
        if firstname and lastname and id then
            local function CharacterExist(id)
                local test = false
                for k, v in pairs(DBData) do
                    if v.characterid == id then
                        test = true
                    end
                end
                return (test)
            end
            local identifier = id
            MySQL.query('SELECT * FROM characters WHERE `identifier`= @identifier', { identifier = identifier },
                function(users)
                    DBData = users
                    
                    -- Check if player has reached their slot limit
                    local result4 = MySQL.query.await('SELECT * FROM permissions WHERE identifier = ?', { identifier })
                    local perm = nil
                    if result4[1] ~= nil then
                        perm = result4[1].permissiongroup
                    end
                    
                    local slots = Slots.default
                    if Slots.role[perm] ~= nil then
                        slots = Slots.role[perm]
                    end
                    if Slots.identifier[identifier] ~= nil then
                        slots = Slots.identifier[identifier]
                    end
                    if slots == nil then
                        slots = Slots.default
                    end
                    
                    -- Prevent character creation if at or over slot limit
                    if #users >= slots then
                        print("^3[FDB-CREATOR]^7 Player " .. _source .. " cannot create character - slot limit reached (" .. #users .. "/" .. slots .. ")")
                        creatingCharacters[_source] = nil
                        TriggerClientEvent('redem_roleplay:Tip', _source, 'You have reached your maximum character slots!', 5000)
                        return
                    end
                    
                    local charID = 1
                    while CharacterExist(charID) do
                        charID = charID + 1
                    end

                    local randomPOBoxNum = RedEM.Functions.CreatePOBox()
                    local citizenId = RedEM.Functions.CreateCitizenId()

                    MySQL.update(
                        'INSERT INTO characters (`identifier`, `firstname`, `lastname`, `money`, `bank`, `characterid`, `citizenid`, `pobox`, `coords`) VALUES (@identifier, @firstname, @lastname, @money, @bank, @characterid, @citizenid, @pobox, @coords);',
                        {
                            identifier = identifier,
                            firstname = firstname,
                            lastname = lastname,
                            money = RedEM.Config.StartingCash,
                            bank = RedEM.Config.StartingBank,
                            characterid = charID,
                            citizenid = citizenId,
                            pobox = randomPOBoxNum,
                            coords = json.encode({ x = data.coords.x, y = data.coords.y, z = data.coords.z })
                        }, function(rowsChanged)
                            MySQL.insert("INSERT INTO skins VALUES (NULL, ?,?,?)",
                                { identifier, charID, json.encode({ sex = 1, skin_tone = 1 }) }, function(result)
                                    RedEM.DB.LoadCharacter(_source, identifier, charID, true)
                                    
                                    -- Reset the flag after successful creation
                                    SetTimeout(2000, function()
                                        creatingCharacters[_source] = nil
                                    end)
                                end)
                        end)
                end)
        end
        RemovePlayerFromInstance(_source)
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
            end
        end)
        repeat
            Wait(0)
        until albedo ~= nil
        print("ALBEDO: " .. albedo)
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
        
        -- Check identifier first (highest priority)
        local identifiers = GetPlayerIdentifiers(source)
        for _, id in pairs(identifiers) do
            if Config.CharacterDeletion.identifier[id] then
                return true
            end
        end
        
        -- For REDEMRP2k23, we need to check user permissions differently
        -- You may need to adjust this based on your permission system
        local id
        for k, v in ipairs(identifiers) do
            if string.sub(v, 1, string.len(identifierUsed .. ":")) == (identifierUsed .. ":") then
                id = v
                break
            end
        end
        
        if id then
            local result = MySQL.query.await('SELECT admin FROM users WHERE identifier = @identifier;', {
                ['@identifier'] = id
            })
            if result and result[1] then
                local adminLevel = result[1].admin or 0
                -- Assume admin level 1+ can delete if role check is enabled
                if adminLevel >= 1 and (Config.CharacterDeletion.role["admin"] or Config.CharacterDeletion.role["superadmin"]) then
                    return true
                end
            end
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
            
            -- Check identifier permissions
            local identifiers = GetPlayerIdentifiers(_source)
            for _, id in pairs(identifiers) do
                for _, allowedId in pairs(Config.Commands.deleteCharacter.allowedIdentifiers) do
                    if id == allowedId then
                        hasPermission = true
                        break
                    end
                end
            end
            
            -- Check admin level in database
            if not hasPermission then
                local id
                for k, v in ipairs(identifiers) do
                    if string.sub(v, 1, string.len(identifierUsed .. ":")) == (identifierUsed .. ":") then
                        id = v
                        break
                    end
                end
                
                if id then
                    local result = MySQL.query.await('SELECT admin FROM users WHERE identifier = @identifier;', {
                        ['@identifier'] = id
                    })
                    if result and result[1] and result[1].admin and result[1].admin >= 1 then
                        hasPermission = true
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
            MySQL.query('SELECT firstname, lastname FROM characters WHERE citizenid = @citizenid;',
                { ['@citizenid'] = citizenid }, function(result)
                    if result and result[1] then
                        local charName = result[1].firstname .. " " .. result[1].lastname
                        
                        -- Delete from murphy tables
                        deleteIfTableExists('fdb_creator', citizenid)
                        deleteIfTableExists('fdb_barber', citizenid)
                        deleteIfTableExists('fdb_barber_preset', citizenid)
                        deleteIfTableExists('fdb_clothes', citizenid)
                        deleteIfTableExists('fdb_outfits', citizenid)
                        deleteIfTableExists('fdb_wearable', citizenid)
                        
                        -- Delete from characters table
                        MySQL.update('DELETE FROM characters WHERE citizenid = ?', { citizenid })
                        
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
            
            -- Check identifier permissions
            local identifiers = GetPlayerIdentifiers(_source)
            for _, id in pairs(identifiers) do
                for _, allowedId in pairs(Config.Commands.secondChance.allowedIdentifiers) do
                    if id == allowedId then
                        hasPermission = true
                        break
                    end
                end
            end
            
            -- Check admin level in database
            if not hasPermission then
                local id
                for k, v in ipairs(identifiers) do
                    if string.sub(v, 1, string.len(identifierUsed .. ":")) == (identifierUsed .. ":") then
                        id = v
                        break
                    end
                end
                
                if id then
                    local result = MySQL.query.await('SELECT admin FROM users WHERE identifier = @identifier;', {
                        ['@identifier'] = id
                    })
                    if result and result[1] and result[1].admin and result[1].admin >= 1 then
                        hasPermission = true
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
