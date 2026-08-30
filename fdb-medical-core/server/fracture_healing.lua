local TICK_INTERVAL = 30000 -- 30s real

CreateThread(function()
    while true do
        Wait(TICK_INTERVAL)
        local nowMinutes = GetGameMinutes()
        
        for src, vitals in pairs(PlayerVitals) do
            if vitals and vitals.wounds then
                local needsSync = false
                
                for bodyPart, wound in pairs(vitals.wounds) do
                    if wound.boneDamage and wound.healUntil and nowMinutes >= wound.healUntil then
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
