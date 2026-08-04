CreateThread(function()
    while true do
        Wait(1000)
        if FDB.IsLoggedIn then
            if FDB.Survival.coldResistance > 0 then
                FDB.Survival.coldResistance = FDB.Survival.coldResistance - 1
                FDB.BroadcastState('coldResistance', FDB.Survival.coldResistance)
            end
            
            if FDB.Survival.heatResistance > 0 then
                FDB.Survival.heatResistance = FDB.Survival.heatResistance - 1
                FDB.BroadcastState('heatResistance', FDB.Survival.heatResistance)
            end
        end
    end
end)

RegisterNetEvent('fdb-survival:client:EatThermalItem', function(buffType, duration)
    if buffType == 'cold' then
        FDB.Survival.coldResistance = duration
        FDB.BroadcastState('coldResistance', duration)
    elseif buffType == 'heat' then
        FDB.Survival.heatResistance = duration
        FDB.BroadcastState('heatResistance', duration)
    end
end)
