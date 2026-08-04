local FDBCore = exports['fdb-core']:GetCoreObject()
lib.locale()

FDBCore.Commands.Add('bandana', locale('sv_bandana'), {}, false, function(source)
    local src = source
    TriggerClientEvent('fdb-bandana:client:ToggleBandana', src)
end)