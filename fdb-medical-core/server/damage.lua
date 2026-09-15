-- ============================================================
-- FDB System | fdb-medical-core | server/damage.lua
-- SOLE entry point for damage and health on the server
-- ============================================================

local FDBCore = exports["fdb-core"]:GetCoreObject()

--- Applies server-side damage or health change to a player's ped
--- @param src number Player ID
--- @param damageType string Damage type (DamageType enum)
--- @param bodyPart string|nil Body part hit (BodyPart enum)
--- @param amount number Damage amount (positive for damage, negative for healing)
--- @param originResource string|nil Name of the resource that originated the damage
function ProcessDamage(src, damageType, bodyPart, amount, originResource)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local vitals = GetPlayerVitals(src)
    originResource = originResource or GetInvokingResource() or 'unknown'
    bodyPart = bodyPart or BodyPart.TORSO

    -- Server-side audit log (Disabled to prevent console flooding)
    -- print(string.format(
    --     locale('log_damage_applied'),
    --     tostring(src), tostring(originResource), tostring(damageType), tostring(bodyPart), tostring(amount)
    -- ))

    -- Health Adjustment
    -- Uses vitals.health as base to avoid duplicating damage (since currentHp might already be lower from the game engine)
    local maxHp = Config.Vitals.MaxHealth or 600
    local newHp = math.max(0, math.min(maxHp, math.floor(vitals.health - amount)))

    -- Applies natively via Server (Only place in the project!)
    TriggerClientEvent('fdb-medical-core:client:setHealth', src, newHp)

    -- Updates physiological vitals
    vitals.health = newHp
    if amount > 0 then
        -- Damage directly increases pulse (pulse is not purely wound-dependent)
        vitals.pulse = math.min(Config.Vitals.MaxPulse, vitals.pulse + math.floor(amount * 0.3))
        
        if damageType == DamageType.Gunshot or damageType == DamageType.Melee or damageType == DamageType.Animal then
            RegisterWound(src, bodyPart, damageType, amount)
            -- RegisterWound already calls RecalculateVitals() internally
        else
            -- For generic damage (burn, light fall), we only update aggregates
            -- If we need non-wound related base pain in the future,
            -- we will implement vitals.basePain. For now, the source of truth
            -- for pain/bleeding is always RecalculateVitals via wounds.
            RecalculateVitals(src)
        end
    else
        RecalculateVitals(src)
    end

    SyncVitalsToStatebag(src)
end

--- Applies a treatment to a player's wound
--- @param src number Player ID
--- @param woundId string|nil Wound ID or type (in practice, the bodyPart)
--- @param treatmentType string Treatment type (bandage, antidote, surgery)
--- @param itemUsed string Name of the item used
function ProcessTreatment(src, woundId, treatmentType, itemUsed)
    local vitals = GetPlayerVitals(src)
    print(string.format(
        locale('log_treatment_applied'),
        tostring(src), tostring(itemUsed or 'none'), tostring(treatmentType)
    ))

    local bodyPart = woundId
    if bodyPart and vitals.wounds and vitals.wounds[bodyPart] then
        local wound = vitals.wounds[bodyPart]
        
        if treatmentType == 'bandage' or treatmentType == 'heal' then
            wound.treated = true
            wound.bleeding = 0
            
            if treatmentType == 'heal' then
                wound.severity = 0
                wound.pain = 0
                wound.infectionStage = 0
                wound.infected = false
            end
        elseif treatmentType == 'antidote' then
            wound.infectionStage = 0
            wound.infected = false
        elseif treatmentType == 'splint' and wound.boneDamage then
            local range = Config.Fractures.HealDaysGame[bodyPart] or {min=15, max=22}
            local days = math.random(range.min, range.max)
            wound.healUntil = GetGameMinutes() + (days * 1440)
        end
    end

    RecalculateVitals(src)
    SyncVitalsToStatebag(src)
end
