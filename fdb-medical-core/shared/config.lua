-- ============================================================
-- FDB System | fdb-medical-core | shared/config.lua
-- Thresholds and physiological decay rates
-- ============================================================

Config = {}
lib.locale()

Config.Vitals = {
    MaxHealth = 600,            -- Base max health in RedM
    MinHealth = 0,
    DefaultPulse = 70,         -- Normal BPM
    MaxPulse = 180,
    MinPulse = 30,
    DefaultPain = 0,           -- 0 to 100
    DefaultBleeding = 0,       -- 0 to 100 (drain rate per tick)
    DefaultConsciousness = 100 -- 0 to 100
}

Config.Thresholds = {
    PainFaint = 85,            -- Pain level that causes fainting
    BleedingFatal = 75,        -- Critical bleeding
    PulseCritical = 40         -- Dangerously low pulse
}

Config.Decay = {
    BleedingDrainInterval = 3000, -- ms per bleeding tick
    PainDecayInterval = 10000,   -- ms for natural pain decay
    PainDecayAmount = 2
}
