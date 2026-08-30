-- ============================================================
-- fdb-medical | shared/config.lua
-- Thresholds e taxas de decaimento fisiológico
-- ============================================================

Config = {}
lib.locale()

Config.Vitals = {
    MaxHealth = 600,            -- Saúde máxima base no RedM
    MinHealth = 0,
    DefaultPulse = 70,         -- BPM normal
    MaxPulse = 180,
    MinPulse = 30,
    DefaultPain = 0,           -- 0 a 100
    DefaultBleeding = 0,       -- 0 a 100 (taxa de dreno por tick)
    DefaultConsciousness = 100 -- 0 a 100
}

Config.Thresholds = {
    PainFaint = 85,            -- Nível de dor que causa desmaio
    BleedingFatal = 75,        -- Sangramento crítico
    PulseCritical = 40         -- Pulso perigosamente baixo
}

Config.Decay = {
    BleedingDrainInterval = 3000, -- ms por tick de sangramento
    PainDecayInterval = 10000,   -- ms para decaimento natural de dor
    PainDecayAmount = 2
}
