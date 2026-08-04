local FDBCore = exports['fdb-core']:GetCoreObject()

FDBCore.Commands.Add("testnotify", "test rsg notify system", {}, false, function(source)
    local src = source
    TriggerClientEvent('rNotify:NotifyLeft', src, "first text", "second text", "generic_textures", "tick", 4000)
end)