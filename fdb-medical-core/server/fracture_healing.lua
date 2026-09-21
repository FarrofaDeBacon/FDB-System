-- ============================================================
-- FDB System | fdb-medical-core | server/fracture_healing.lua
-- ============================================================

local TICK_INTERVAL = 30000 -- 30s real-time

CreateThread(function()
    while true do
        Wait(TICK_INTERVAL)
        local nowTime = os.time()
        
        for src, vitals in pairs(PlayerVitals) do
            if vitals and vitals.wounds then
                local needsSync = false
                
                for bodyPart, wound in pairs(vitals.wounds) do
                    if wound.boneDamage and wound.healUntil and nowTime >= wound.healUntil then
                        wound.boneDamage = false
                        wound.healUntil = nil
                        RemoveFracturePenalty(src, bodyPart)
                        needsSync = true
                    end
                end
                
                if needsSync then
                    SyncVitalsToStatebag(src)
                end
            end
        end
    end
end)
