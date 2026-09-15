-- ============================================================
-- FDB System | fdb-medical-core | server/infection.lua
-- Infection evolution loop based on hygiene (fdb-survival cleanliness)
-- ============================================================

local FDBCore = exports["fdb-core"]:GetCoreObject()

local function GetCleanlinessMultiplier(cleanliness)
    for _, range in ipairs(Config.Wounds.Infection.CleanlinessModifier) do
        if cleanliness >= range.min and cleanliness <= range.max then
            return range.multiplier
        end
    end
    return 1.0
end

CreateThread(function()
    while true do
        Wait(Config.Wounds.Infection.TickInterval)
        for src, vitals in pairs(PlayerVitals) do
            if vitals.wounds then
                local Player = FDBCore.Functions.GetPlayer(src)
                local cleanliness = Player and Player.PlayerData.metadata['cleanliness'] or 100
                local modifier = GetCleanlinessMultiplier(cleanliness)

                for bodyPart, wound in pairs(vitals.wounds) do
                    local tier = GetWoundTier(src, bodyPart)
                    if tier and Config.Wounds.Infection.Eligible[tier.id] and not wound.treated then
                        wound.infected = true
                        local growth = Config.Wounds.Infection.BaseRatePerMinute * modifier
                        wound.infectionStage = math.min(100, (wound.infectionStage or 0) + growth)

                        -- Systemic/severe infection generates fever damage
                        if wound.infectionStage >= 50 then
                            ProcessDamage(src, DamageType.Illness, bodyPart, 2.0, 'fdb-medical-core:infection')
                        end
                    end
                end
                SyncVitalsToStatebag(src)
            end
        end
    end
end)
