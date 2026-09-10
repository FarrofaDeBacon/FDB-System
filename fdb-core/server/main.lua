FDBCore = {}
FDBCore.Config = FDBConfig
FDBCore.Shared = FDBShared
FDBCore.ClientCallbacks = {}
FDBCore.ServerCallbacks = {}

exports('GetCoreObject', function()
    return FDBCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local FDBCore = exports['fdb-core']:GetCoreObject()
