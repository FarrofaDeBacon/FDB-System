-- ============================================================
-- FDB System | fdb-medical-core | shared/enums.lua
-- Enums for Damage Types, Body Parts, and Infection
-- ============================================================

DamageType = {
    Gunshot = 'Gunshot',
    Melee = 'Melee',
    Fall = 'Fall',
    Poison = 'Poison',
    Illness = 'Illness',
    Cold = 'Cold',
    Heat = 'Heat',
    Burn = 'Burn',
    Animal = 'Animal',
    Generic = 'Generic'
}

BodyPart = {
    Head = 'Head',
    Torso = 'Torso',
    LeftArm = 'LeftArm',
    RightArm = 'RightArm',
    LeftLeg = 'LeftLeg',
    RightLeg = 'RightLeg'
}

InfectionStage = {
    None = 'None',
    Local = 'Local',
    Systemic = 'Systemic',
    Severe = 'Severe'
}
