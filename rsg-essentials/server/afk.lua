local FDBCore = exports['fdb-core']:GetCoreObject()
lib.locale()

RegisterNetEvent('KickForAFK', function()
    DropPlayer(source, locale('sv_kick'))
end)

FDBCore.Functions.CreateCallback('fdb-afkkick:server:GetPermissions', function(source, cb)
    cb(FDBCore.Functions.GetPermission(source))
end)
