-- ============================================================
-- fdb-medical | shared/enums.lua
-- Enums para Tipos de Dano, Partes do Corpo e Infecção
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
