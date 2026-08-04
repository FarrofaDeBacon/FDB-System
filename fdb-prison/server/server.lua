local FDBCore = exports['fdb-core']:GetCoreObject()

--------------------------
-- update jail sentance
--------------------------
RegisterNetEvent('fdb-prison:server:updateSentance', function(updatedTime)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData('injail', updatedTime)
end)

--------------------------
-- remove player job
--------------------------
RegisterNetEvent('fdb-prison:server:RemovePlayerJob', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'unemployed' and Config.RemoveJob == true then
        Player.Functions.SetJob('unemployed')
    end
end)

--------------------------
-- auto free player
--------------------------
RegisterNetEvent('fdb-prison:server:FreePlayer', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData('injail', 0)
end)

--------------------------
-- save inventory items
--------------------------
RegisterNetEvent('fdb-prison:server:SaveJailItems', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Player.PlayerData.metadata['jailitems'] or not next(Player.PlayerData.metadata['jailitems']) then
        Player.Functions.SetMetaData('jailitems', Player.PlayerData.items)
        Player.Functions.AddMoney('cash', 10)
        Wait(2000)
        Player.Functions.ClearInventory()
    end
end)

--------------------------
-- give back inventory items
--------------------------
RegisterNetEvent('fdb-prison:server:GiveJailItems', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    Wait(1000)
    Player.Functions.ClearInventory()
    for _, v in pairs(Player.PlayerData.metadata['jailitems']) do
        Player.Functions.AddItem(v.name, v.amount, false, v.info)
    end
    Wait(1000)
    Player.Functions.SetMetaData('jailitems', {})
end)

--------------------------
-- set criminal record
--------------------------
RegisterNetEvent('fdb-prison:server:CheckRecordStatus', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local CriminalRecord = Player.PlayerData.metadata['criminalrecord']
    local currentDate = os.date('*t')
    if (CriminalRecord['date'].month + 1) == 13 then
        CriminalRecord['date'].month = 0
    end
    if CriminalRecord['hasRecord'] then
        if currentDate.month == (CriminalRecord['date'].month + 1) or currentDate.day == (CriminalRecord['date'].day - 1) then
            CriminalRecord['hasRecord'] = false
            CriminalRecord['date'] = nil
        end
    end
end)

RegisterNetEvent('fdb-prison:server:resetoutlawstatus', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    local citizenid = Player.PlayerData.citizenid
    MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { 0, citizenid })
end)
