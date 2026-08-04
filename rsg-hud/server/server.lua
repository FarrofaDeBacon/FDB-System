local FDBCore = exports['fdb-core']:GetCoreObject()
local ResetStress = false
lib.locale()

FDBCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source, args)
    local Player = FDBCore.Functions.GetPlayer(source)
    local cashamount = Player.PlayerData.money.cash
    if cashamount ~= nil then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', cashamount)
    else
        return
    end
end)

FDBCore.Commands.Add('gold', 'Check Gold Balance', {}, false, function(source, args)
    local Player = FDBCore.Functions.GetPlayer(source)
    local goldamount = Player.PlayerData.money.gold
    if goldamount ~= nil then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'gold', goldamount)
    else
        return
    end
end)

FDBCore.Commands.Add('bloodmoney', 'Check Bloodmoney Balance', {}, false, function(source, args)
    local Player = FDBCore.Functions.GetPlayer(source)
    local bloodmoneyamount = Player.PlayerData.money.bloodmoney
    if bloodmoneyamount ~= nil then
        TriggerClientEvent('hud:client:ShowAccounts', source, 'bloodmoney', bloodmoneyamount)
    else
        return
    end
end)

---------------------------------
-- get outlaw status
---------------------------------
FDBCore.Functions.CreateCallback('hud:server:getoutlawstatus', function(source, cb)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player ~= nil then
        MySQL.query('SELECT outlawstatus FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid}, function(result)
            if result[1] then
                cb(result[1].outlawstatus)
            else
                cb(0)
            end
        end)
    end
end)
