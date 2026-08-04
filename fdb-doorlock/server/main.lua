local FDBCore = exports['fdb-core']:GetCoreObject()
local DoorInfo	= {}
lib.locale()

local function IsAuthorized(jobName, doorID)
    for _,job in pairs(doorID.authorizedJobs) do
        if job == jobName then
            return true
        end
    end
    return false
end

RegisterServerEvent('fdb-doorlock:updatedoorsv')
AddEventHandler('fdb-doorlock:updatedoorsv', function(doorID, state, cb)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not IsAuthorized(Player.PlayerData.job.name, Config.DoorList[doorID]) then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_nokey'), type = 'error', duration = 5000 })
        return
    else
        TriggerClientEvent('fdb-doorlock:changedoor', src, doorID, state)
    end
end)

RegisterServerEvent('fdb-doorlock:updateState')
AddEventHandler('fdb-doorlock:updateState', function(doorID, state, cb)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if type(doorID) ~= 'number' then return end
    if not IsAuthorized(Player.PlayerData.job.name, Config.DoorList[doorID]) then return end

    DoorInfo[doorID] = {}
    TriggerClientEvent('fdb-doorlock:setState', -1, doorID, state)
end)