-- ============================================================
-- FDB System | fdb-creator | server/function.lua
-- Core server functions for creator
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
-- Helper functions for instances (routing buckets)
function PutPlayerinInstance(src)
    SetPlayerRoutingBucket(src, src + 100)
    SetRoutingBucketPopulationEnabled(src + 100, false)
end

function RemovePlayerFromInstance(src)
    SetPlayerRoutingBucket(src, 0)
end

