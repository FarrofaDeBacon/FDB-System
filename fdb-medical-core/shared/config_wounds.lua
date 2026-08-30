-- ============================================================
-- fdb-medical-core | shared/config_wounds.lua
-- Configurações padrão de severidade, sangramento, infecção e tratamentos
-- ============================================================

Config = Config or {}

Config.Wounds = {
    Severity = {
        { id = 1, name = 'Scratch',  min = 1,  max = 24,  bleeding = 0,  requiresMedic = false },
        { id = 2, name = 'Light',    min = 25, max = 49,  bleeding = 10, requiresMedic = false },
        { id = 3, name = 'Moderate', min = 50, max = 74,  bleeding = 30, requiresMedic = true  },
        { id = 4, name = 'Severe',   min = 75, max = 100, bleeding = 60, requiresMedic = true  },
    },
    RequiresMedicSeverity = 3,

    -- Quais DamageType geram/agravam ferimento físico rastreado
    WoundCausingTypes = {
        [DamageType.Gunshot] = true,
        [DamageType.Melee]   = true,
        [DamageType.Animal]  = true,
    },

    Bleeding = {
        TickInterval = 5000,
        DrainRate = 0.014,
        ClotChancePerTick = 0,
    },

    Infection = {
        Eligible = { [3] = true, [4] = true },
        TickInterval = 60000,
        BaseRatePerMinute = 4,
        CleanlinessModifier = {
            { min = 80, max = 100, multiplier = 0.5 },
            { min = 50, max = 79,  multiplier = 1.0 },
            { min = 20, max = 49,  multiplier = 1.6 },
            { min = 0,  max = 19,  multiplier = 2.5 },
        },
        Stages = {
            { id = 0, name = 'None',     min = 0,  max = 24 },
            { id = 1, name = 'Local',    min = 25, max = 49 },
            { id = 2, name = 'Systemic', min = 50, max = 74 },
            { id = 3, name = 'Severe',   min = 75, max = 100 },
        },
        CureReducesStagePerUse = 30,
    },

    Treatment = {
        Scratch  = { items = { 'cloth_bandage' },                       healBleed = true, reduceSeverity = 15 },
        Light    = { items = { 'cloth_bandage', 'alcohol' },             healBleed = true, reduceSeverity = 20 },
        Moderate = { items = { 'tourniquet', 'suture_kit' },             healBleed = true, reduceSeverity = 30, requiresMedic = true },
        Severe   = { items = { 'tourniquet', 'suture_kit', 'laudanum' }, healBleed = true, reduceSeverity = 40, requiresMedic = true },
    },
}

Config.Fractures = {
    CausingTypes = { ['melee'] = true, ['fall'] = true },
    ChancePercent = 30,
    EligibleParts = { LARM=true, RARM=true, LLEG=true, RLEG=true, TORSO=true },
    HealDaysGame = {
        LARM={min=20,max=28}, RARM={min=20,max=28},
        LLEG={min=30,max=40}, RLEG={min=30,max=40},
        TORSO={min=15,max=22},
    },
    Treatment = { items = {'splint'}, requiresMedic = true },
    MoveRatePenalty = { LLEG=0.5, RLEG=0.5 },
}
