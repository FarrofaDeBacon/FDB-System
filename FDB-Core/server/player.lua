FDBCore.Players = {}
FDBCore.Player = {}

-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

local resourceName = GetCurrentResourceName()
function FDBCore.Player.Login(source, citizenid, newData)
    if source and source ~= '' then
        if citizenid then
            local license = FDBCore.Functions.GetIdentifier(source, 'license')
            local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
            if PlayerData and license == PlayerData.license then
                PlayerData.money = json.decode(PlayerData.money)
                PlayerData.job = json.decode(PlayerData.job)
                PlayerData.gang = json.decode(PlayerData.gang)
                PlayerData.position = json.decode(PlayerData.position)
                PlayerData.metadata = json.decode(PlayerData.metadata)
                PlayerData.charinfo = json.decode(PlayerData.charinfo)
                FDBCore.Player.CheckPlayerData(source, PlayerData)
            else
                DropPlayer(source, Lang:t('info.exploit_dropped'))
                TriggerEvent('fdb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Joining Exploit', false)
            end
        else
            FDBCore.Player.CheckPlayerData(source, newData)
        end
        return true
    else
        FDBCore.ShowError(resourceName, 'ERROR FDBCore.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end
end

function FDBCore.Player.GetOfflinePlayer(citizenid)
    if citizenid then
        local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            return FDBCore.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

function FDBCore.Player.GetPlayerByLicense(license)
    if license then
        local source = FDBCore.Functions.GetSource(license)
        if source > 0 then
            return FDBCore.Players[source]
        else
            return FDBCore.Player.GetOfflinePlayerByLicense(license)
        end
    end
    return nil
end

function FDBCore.Player.GetOfflinePlayerByLicense(license)
    if license then
        local PlayerData = MySQL.prepare.await('SELECT * FROM players where license = ?', { license })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            return FDBCore.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

local function applyDefaults(playerData, defaults)
    for key, value in pairs(defaults) do
        if type(value) == 'function' then
            playerData[key] = playerData[key] or value()
        elseif type(value) == 'table' then
            playerData[key] = playerData[key] or {}
            applyDefaults(playerData[key], value)
        else
            playerData[key] = playerData[key] or value
        end
    end
end

function FDBCore.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = not source

    if source then
        PlayerData.source = source
        PlayerData.license = PlayerData.license or FDBCore.Functions.GetIdentifier(source, 'license')
        PlayerData.name = GetPlayerName(source)
    end

    local validatedJob = false
    if PlayerData.job and PlayerData.job.name ~= nil and PlayerData.job.grade and PlayerData.job.grade.level ~= nil then
        local jobInfo = FDBCore.Shared.Jobs[PlayerData.job.name]

        if jobInfo then
            local jobGradeInfo = jobInfo.grades[tostring(PlayerData.job.grade.level)]
            if jobGradeInfo then
                PlayerData.job.label = jobInfo.label
                PlayerData.job.grade.name = jobGradeInfo.name
                PlayerData.job.payment = jobGradeInfo.payment
                PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
                PlayerData.job.isboss = jobGradeInfo.isboss or false
                validatedJob = true
            end
        end
    end

    if validatedJob == false then
        -- set to nil, as the default job (unemployed) will be added by `applyDefaults`
        PlayerData.job = nil
    end

    local validatedGang = false
    if PlayerData.gang and PlayerData.gang.name ~= nil and PlayerData.gang.grade and PlayerData.gang.grade.level ~= nil then
        local gangInfo = FDBCore.Shared.Gangs[PlayerData.gang.name]

        if gangInfo then
            local gangGradeInfo = gangInfo.grades[tostring(PlayerData.gang.grade.level)]
            if gangGradeInfo then
                PlayerData.gang.label = gangInfo.label
                PlayerData.gang.grade.name = gangGradeInfo.name
                PlayerData.gang.payment = gangGradeInfo.payment
                PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
                PlayerData.gang.isboss = gangGradeInfo.isboss or false
                validatedGang = true
            end
        end
    end

    if validatedGang == false then
        -- set to nil, as the default gang (unemployed) will be added by `applyDefaults`
        PlayerData.gang = nil
    end

    applyDefaults(PlayerData, FDBCore.Config.Player.PlayerDefaults)

    if GetResourceState('fdb-inventory') ~= 'missing' then
        PlayerData.items = exports['fdb-inventory']:LoadInventory(PlayerData.source, PlayerData.citizenid)
    end

    return FDBCore.Player.CreatePlayer(PlayerData, Offline)
end

-- On player logout

function FDBCore.Player.Logout(source)
    TriggerClientEvent('FDBCore:Client:OnPlayerUnload', source)
    TriggerEvent('FDBCore:Server:OnPlayerUnload', source)
    TriggerClientEvent('FDBCore:Player:UpdatePlayerData', source)
    Wait(200)
    FDBCore.Players[source] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function FDBCore.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline
    self.saveInProgress = false
    self.savePending = false

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end

        if FDBCore.Config.Money.EnableMoneyItems or FDBCore.Config.Gold.EnableGoldItems then
            self.PlayerData = SynchronizeMoneyItems(self.PlayerData)
        end

        TriggerEvent('FDBCore:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('FDBCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = grade or '0'
        if not FDBCore.Shared.Jobs[job] then return false end
        self.PlayerData.job = {
            name = job,
            label = FDBCore.Shared.Jobs[job].label,
            onduty = FDBCore.Shared.Jobs[job].defaultDuty,
            type = FDBCore.Shared.Jobs[job].type or 'none',
            grade = {
                name = 'No Grades',
                level = 0,
                payment = 30,
                isboss = false
            }
        }
        local gradeKey = tostring(grade)
        local jobGradeInfo = FDBCore.Shared.Jobs[job].grades[gradeKey]
        if jobGradeInfo then
            self.PlayerData.job.grade.name = jobGradeInfo.name
            self.PlayerData.job.grade.level = tonumber(gradeKey)
            self.PlayerData.job.grade.payment = jobGradeInfo.payment
            self.PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
            self.PlayerData.job.isboss = jobGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('FDBCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
            TriggerClientEvent('FDBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        end

        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = grade or '0'
        if not FDBCore.Shared.Gangs[gang] then return false end
        self.PlayerData.gang = {
            name = gang,
            label = FDBCore.Shared.Gangs[gang].label,
            grade = {
                name = 'No Grades',
                level = 0,
                isboss = false
            }
        }
        local gradeKey = tostring(grade)
        local gangGradeInfo = FDBCore.Shared.Gangs[gang].grades[gradeKey]
        if gangGradeInfo then
            self.PlayerData.gang.grade.name = gangGradeInfo.name
            self.PlayerData.gang.grade.level = tonumber(gradeKey)
            self.PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
            self.PlayerData.gang.isboss = gangGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('FDBCore:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
            TriggerClientEvent('FDBCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        end

        return true
    end

    function self.Functions.HasItem(items, amount)
        return FDBCore.Functions.HasItem(self.PlayerData.source, items, amount)
    end

    function self.Functions.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = not not onDuty
        TriggerEvent('FDBCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        TriggerClientEvent('FDBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetMetaData(meta, val)
        local function validateData(key, value)
            if key == 'hunger' or key == 'thirst' or key == 'cleanliness' then
                value = lib.math.clamp(value, 0, 100)
            end

            return value
        end

        if type(meta) == 'table' then
            for key, value in pairs(meta) do
                self.PlayerData.metadata[key] = validateData(key, value)
            end
            self.Functions.UpdatePlayerData()
            return
        end
    
        if type(meta) ~= 'string' then return end
        self.PlayerData.metadata[meta] = validateData(meta, val)
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.AddRep(rep, amount)
        if not rep or not amount then return end
        local addAmount = tonumber(amount)
        if not addAmount or addAmount ~= addAmount or addAmount == math.huge or addAmount == -math.huge or addAmount < 0 then return end
        local currentRep = self.PlayerData.metadata['rep'][rep] or 0
        self.PlayerData.metadata['rep'][rep] = math.max(0, currentRep + addAmount)
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.RemoveRep(rep, amount)
        if not rep or not amount then return end
        local removeAmount = tonumber(amount)
        if not removeAmount or removeAmount ~= removeAmount or removeAmount == math.huge or removeAmount == -math.huge or removeAmount < 0 then return end
        local currentRep = self.PlayerData.metadata['rep'][rep] or 0
        if currentRep - removeAmount < 0 then
            self.PlayerData.metadata['rep'][rep] = 0
        else
            self.PlayerData.metadata['rep'][rep] = currentRep - removeAmount
        end
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetRep(rep)
        if not rep then return end
        return self.PlayerData.metadata['rep'][rep] or 0
    end

    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if not amount or amount ~= amount or amount == math.huge or amount == -math.huge or amount < 0 then return false end
        if moneytype == 'gold' and amount % 1 ~= 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('fdb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('fdb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end

            if not IsMoneyItemEnabled(moneytype) then
                TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            end
            TriggerClientEvent('FDBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
            TriggerEvent('FDBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        end

        return true
    end

    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if not amount or amount ~= amount or amount == math.huge or amount == -math.huge or amount < 0 then return false end
        if moneytype == 'gold' and amount % 1 ~= 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(FDBCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        if self.PlayerData.money[moneytype] - amount < FDBCore.Config.Money.MinusLimit then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('fdb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('fdb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            if not IsMoneyItemEnabled(moneytype) then
                TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            end
            TriggerClientEvent('FDBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
            TriggerEvent('FDBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if not amount or amount ~= amount or amount == math.huge or amount == -math.huge or amount < 0 then return false end
        if moneytype == 'gold' and amount % 1 ~= 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('fdb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            if not IsMoneyItemEnabled(moneytype) then
                TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
            end
            TriggerClientEvent('FDBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
            TriggerEvent('FDBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        if not moneytype then return false end
        moneytype = moneytype:lower()
        return self.PlayerData.money[moneytype]
    end

    function self.Functions.Save()
        if self.Offline then
            FDBCore.Player.SaveOffline(self.PlayerData)
        else
            self.Functions.PersistStateBags()
            FDBCore.Player.Save(self.PlayerData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then return end
        FDBCore.Player.Logout(self.PlayerData.source)
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    function self.Functions.PersistStateBags()
        local metadata = {}
        local keys = { "hunger", "thirst", "cleanliness", "stress", "health" }
    
        local state = Player(self.PlayerData.source).state
        for _, key in ipairs(keys) do
            if state[key] ~= nil then
                metadata[key] = state[key]
            end
        end
    
        if next(metadata) then
            self.Functions.SetMetaData(metadata)
        end
    end

    function self.Functions.InitializeStateBags()
        local metadata = self.PlayerData.metadata
        local keys = { "hunger", "thirst", "cleanliness", "stress", "health" }
    
        local state = Player(self.PlayerData.source).state
        for _, key in ipairs(keys) do
            if metadata[key] ~= nil then
                state[key] = metadata[key]
            end
        end
    end

    if self.Offline then
        return self
    else
        self.Functions.InitializeStateBags()
        FDBCore.Players[self.PlayerData.source] = self
        FDBCore.Player.Save(self.PlayerData.source)
        TriggerEvent('FDBCore:Server:PlayerLoaded', self)
        self.Functions.UpdatePlayerData()
    end
end

-- Add a new function to the Functions table of the player class
-- Use-case:
--[[
    AddEventHandler('FDBCore:Server:PlayerLoaded', function(Player)
        FDBCore.Functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
            -- do something here
        end)
    end)
]]

function FDBCore.Functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(FDBCore.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not FDBCore.Players[ids] then return end

            FDBCore.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            FDBCore.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

-- Add a new field table of the player class
-- Use-case:
--[[
    AddEventHandler('FDBCore:Server:PlayerLoaded', function(Player)
        FDBCore.Functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]

function FDBCore.Functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(FDBCore.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not FDBCore.Players[ids] then return end

            FDBCore.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            FDBCore.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function FDBCore.Player.Save(source)
    local Player = FDBCore.Players[source]
    if not Player or not Player.PlayerData then
        FDBCore.ShowError(GetCurrentResourceName(), 'ERROR FDBCore.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
        return
    end

    if Player.saveInProgress then
        Player.savePending = true
        return
    end

    Player.saveInProgress = true
    Player.savePending = false

    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped)
    local PlayerData = Player.PlayerData

    MySQL.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata, weight, slots) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata, :weight, :slots) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata, weight = :weight, slots = :slots', {
        citizenid = PlayerData.citizenid,
        cid = tonumber(PlayerData.cid),
        license = PlayerData.license,
        name = PlayerData.name,
        money = json.encode(PlayerData.money),
        charinfo = json.encode(PlayerData.charinfo),
        job = json.encode(PlayerData.job),
        gang = json.encode(PlayerData.gang),
        position = json.encode(pcoords),
        metadata = json.encode(PlayerData.metadata),
        weight = PlayerData.weight,
        slots = PlayerData.slots,
    }, function(result)
        local CurrentPlayer = FDBCore.Players[source]
        if not CurrentPlayer then
            return
        end

        CurrentPlayer.saveInProgress = false
        FDBCore.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. ' PLAYER SAVED!')
        if GetResourceState('fdb-inventory') ~= 'missing' then exports['fdb-inventory']:SaveInventory(source) end

        if CurrentPlayer.savePending then
            CurrentPlayer.savePending = false
            FDBCore.Player.Save(source)
        end
    end)
end

function FDBCore.Player.SaveOffline(PlayerData)
    if PlayerData then
        MySQL.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata, weight, slots) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata, :weight, :slots) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata, weight = :weight, slots = :slots', {
            citizenid = PlayerData.citizenid,
            cid = tonumber(PlayerData.cid),
            license = PlayerData.license,
            name = PlayerData.name,
            money = json.encode(PlayerData.money),
            charinfo = json.encode(PlayerData.charinfo),
            job = json.encode(PlayerData.job),
            gang = json.encode(PlayerData.gang),
            position = json.encode(PlayerData.position),
            metadata = json.encode(PlayerData.metadata),
            weight = PlayerData.weight,
            slots = PlayerData.slots,
        })
        if GetResourceState('fdb-inventory') ~= 'missing' then exports['fdb-inventory']:SaveInventory(PlayerData, true) end
        FDBCore.ShowSuccess(resourceName, PlayerData.name .. ' OFFLINE PLAYER SAVED!')
    else
        FDBCore.ShowError(resourceName, 'ERROR FDBCore.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
    end
end


-- Delete character

local playertables = { -- Add tables as needed
    { table = 'players'},
    { table = 'playeroutfit'},
    { table = 'playerskins'},
    { table = 'player_horses'},
    { table = 'player_weapons'},
    { table = 'address_book'},
    { table = 'telegrams'},
}

function FDBCore.Player.DeleteCharacter(source, citizenid)
    local license = FDBCore.Functions.GetIdentifier(source, 'license')
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if license == result then
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)

        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('fdb-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**..')
            end
        end)
    else
        DropPlayer(source, Lang:t('info.exploit_dropped'))
        TriggerEvent('fdb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
    end
end

function FDBCore.Player.ForceDeleteCharacter(citizenid)
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if result then
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)
        local Player = FDBCore.Functions.GetPlayerByCitizenId(citizenid)

        if Player then
            DropPlayer(Player.PlayerData.source, 'An admin deleted the character which you are currently using')
        end
        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('fdb-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** got deleted')
            end
        end)
    end
end

-- Inventory Backwards Compatibility

function FDBCore.Player.SaveInventory(source)
    if GetResourceState('fdb-inventory') == 'missing' then return end
    exports['fdb-inventory']:SaveInventory(source, false)
end

function FDBCore.Player.SaveOfflineInventory(PlayerData)
    if GetResourceState('fdb-inventory') == 'missing' then return end
    exports['fdb-inventory']:SaveInventory(PlayerData, true)
end

function FDBCore.Player.GetTotalWeight(items)
    if GetResourceState('fdb-inventory') == 'missing' then return end
    return exports['fdb-inventory']:GetTotalWeight(items)
end

function FDBCore.Player.GetSlotsByItem(items, itemName)
    if GetResourceState('fdb-inventory') == 'missing' then return end
    return exports['fdb-inventory']:GetSlotsByItem(items, itemName)
end

function FDBCore.Player.GetFirstSlotByItem(items, itemName)
    if GetResourceState('fdb-inventory') == 'missing' then return end
    return exports['fdb-inventory']:GetFirstSlotByItem(items, itemName)
end

-- Util Functions

function FDBCore.Player.CreateCitizenId()
    local CitizenId = tostring(FDBCore.Shared.RandomStr(3) .. FDBCore.Shared.RandomInt(5)):upper()
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE citizenid = ?) AS uniqueCheck', { CitizenId })
    if result == 0 then return CitizenId end
    return FDBCore.Player.CreateCitizenId()
end

function FDBCore.Functions.CreateAccountNumber()
    local AccountNumber = 'US0' .. math.random(1, 9) .. 'FDBCore' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.account")) = ?) AS uniqueCheck', { AccountNumber })
    if result == 0 then return AccountNumber end
    return FDBCore.Functions.CreateAccountNumber()
end

function FDBCore.Player.CreateFingerId()
    local FingerId = tostring(FDBCore.Shared.RandomStr(2) .. FDBCore.Shared.RandomInt(3) .. FDBCore.Shared.RandomStr(1) .. FDBCore.Shared.RandomInt(2) .. FDBCore.Shared.RandomStr(3) .. FDBCore.Shared.RandomInt(4))
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.fingerprint")) = ?) AS uniqueCheck', { FingerId })
    if result == 0 then return FingerId end
    return FDBCore.Player.CreateFingerId()
end

function FDBCore.Player.CreateWalletId()
    local WalletId = 'FDB-' .. math.random(11111111, 99999999)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.walletid")) = ?) AS uniqueCheck', { WalletId })
    if result == 0 then return WalletId end
    return FDBCore.Player.CreateWalletId()
end

function FDBCore.Player.CreateSerialNumber()
    local SerialNumber = math.random(11111111, 99999999)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.phonedata.SerialNumber")) = ?) AS uniqueCheck', { SerialNumber })
    if result == 0 then return SerialNumber end
    return FDBCore.Player.CreateSerialNumber()
end

PaycheckInterval() -- This starts the paycheck system
