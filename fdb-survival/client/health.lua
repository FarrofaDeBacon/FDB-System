RegisterNetEvent('fdb-survival:client:CurePoison', function()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x9E9762207289BA64, ped, false)
    FDB.Survival.poison = 0
    FDB.BroadcastState('poison', 0)
end)

RegisterNetEvent('fdb-survival:client:CureIllness', function()
    FDB.Survival.illness = 0
    FDB.BroadcastState('illness', 0)
end)
