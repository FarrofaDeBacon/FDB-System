-- ============================================================
-- FDB System | fdb-medical-core | server/wounds.lua
-- Wound tracking by body part
-- ============================================================

local function GetSeverityTier(value)
    local tiers = Config.Wounds.Severity
    for _, tier in ipairs(tiers) do
        if value >= tier.min and value <= tier.max then
            return tier
        end
    end
    return nil
end

local function RollBallisticsFlavor(damageType)
    if damageType ~= 'gunshot' then
        return nil -- Flavor only applies to gunshots
    end
    
    local roll = math.random(1, 100)
    if roll <= 40 then
        return { result = 'through', bleedModifier = 1.0, text = locale('wound_through') }
    elseif roll <= 75 then
        return { result = 'stuck', bleedModifier = 0.6, text = locale('wound_stuck') }
    else
        return { result = 'fragmented', bleedModifier = 1.3, text = locale('wound_fragmented') }
    end
end

--- Applies physical damage to a specific body part, updating severity/bleeding
--- Called by damage.lua AFTER health has already been processed - never writes health.
--- @param src number
--- @param bodyPart string Enum BodyPart
--- @param damageType string Enum DamageType
--- @param amount number Hit intensity
function RegisterWound(src, bodyPart, damageType, amount)
    local causesWound = Config.Wounds.WoundCausingTypes[damageType]
    if not causesWound or amount <= 0 then return end

    local vitals = GetPlayerVitals(src)
    vitals.wounds = vitals.wounds or {}
    vitals.wounds[bodyPart] = vitals.wounds[bodyPart] or { severity = 0, bleeding = 0, infected = false, infectionStage = 0, treated = false }

    local wound = vitals.wounds[bodyPart]

    -- Accumulates severity (0-100), repeated hits on the same part worsen the wound
    wound.severity = math.max(0, math.min(100, wound.severity + amount))
    wound.treated = false -- new hit reopens a previously treated wound

    local tier = GetSeverityTier(wound.severity)
    local baseBleeding = tier and tier.bleeding or 0
    wound.pain = math.floor(wound.severity * 0.5)
    
    local flavor = RollBallisticsFlavor(damageType)
    if flavor then
        wound.bulletResult = flavor.result
        wound.text = flavor.text
        wound.bleeding = math.floor(baseBleeding * flavor.bleedModifier)
    else
        wound.bleeding = baseBleeding
        wound.bulletResult = nil
        if damageType == 'animal' then
            wound.text = locale('wound_bite')
        elseif damageType == 'melee' then
            wound.text = locale('wound_melee')
        else
            wound.text = nil
        end
    end

    -- Fracture Generation Logic
    if tier and tier.name == 'Severe' and Config.Fractures.CausingTypes[damageType] and Config.Fractures.EligibleParts[bodyPart] then
        print(string.format('[DEBUG fdb-medical-core] Evaluating fracture: Severe Damage on %s (Type: %s)', bodyPart, damageType))
        if math.random(1, 100) <= Config.Fractures.ChancePercent then
            wound.boneDamage = true
            wound.healUntil = nil
            print(string.format('^1[DEBUG fdb-medical-core] BINGO! Broken bone in zone: %s^7', bodyPart))
            if ApplyFracturePenalty then
                ApplyFracturePenalty(src, bodyPart)
            end
        else
            print(string.format('[DEBUG fdb-medical-core] Lucky: %s resisted and did not break (outside of %s%%).', bodyPart, Config.Fractures.ChancePercent))
        end
    end

    print(string.format(
        '[fdb-medical-core] WOUND: src %s | %s | severity=%d (%s) | bleeding=%d',
        tostring(src), tostring(bodyPart), wound.severity, tier and tier.name or 'none', wound.bleeding
    ))
    
    RecalculateVitals(src)

    SyncVitalsToStatebag(src)
    
    if SavePlayerVitalsToDB then
        SavePlayerVitalsToDB(src)
    end
end

--- Returns the sum of bleeding from all active wounds on the player
--- Used by bleedout.lua and the pulse formula
function GetTotalBleeding(src)
    local vitals = GetPlayerVitals(src)
    local total = 0
    if not vitals.wounds then return 0 end
    for _, wound in pairs(vitals.wounds) do
        total = total + (wound.bleeding or 0)
    end
    return total
end

--- Recalculates pain and bleeding aggregates based on individual wounds
function RecalculateVitals(src)
    local vitals = GetPlayerVitals(src)
    local totalBleeding = 0
    local totalPain = 0
    
    if vitals.wounds then
        for _, wound in pairs(vitals.wounds) do
            if not wound.treated then
                totalBleeding = totalBleeding + (wound.bleeding or 0)
                totalPain = totalPain + (wound.pain or 0)
            else
                totalPain = totalPain + (wound.pain and math.floor(wound.pain * 0.3) or 0) -- treated wounds still have some pain
            end
        end
    end
    
    vitals.bleeding = math.min(100, math.floor(totalBleeding))
    vitals.pain = math.min(100, math.floor(totalPain))
end

--- Returns the tier table (name, requiresMedic, etc) for a specific wound
function GetWoundTier(src, bodyPart)
    local vitals = GetPlayerVitals(src)
    local wound = vitals.wounds and vitals.wounds[bodyPart]
    if not wound or wound.severity <= 0 then return nil end
    return GetSeverityTier(wound.severity)
end

exports('RegisterWound', RegisterWound)
exports('GetTotalBleeding', GetTotalBleeding)
exports('GetWoundTier', GetWoundTier)
exports('RecalculateVitals', RecalculateVitals)


-- TEMP DEBUG COMMAND FOR TESTING HEAL TIME
RegisterCommand('setgametime', function(source, args)
    -- Allows execution via rcon or ingame
    local d = tonumber(args[1]) or 0
    local h = tonumber(args[2]) or 12
    exports.weathersync:setTime(d, h, 0, 0, 0, false)
    print('Game time set to Day ' .. d .. ' Hour ' .. h)
end, true) -- restricted to admins
