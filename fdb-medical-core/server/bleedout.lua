-- ============================================================
-- fdb-medical-core | server/bleedout.lua
-- Loop de dreno por sangramento server-owned
-- ============================================================

CreateThread(function()
    while true do
        Wait(Config.Wounds.Bleeding.TickInterval)
        for src, _ in pairs(PlayerVitals) do
            local totalBleed = GetTotalBleeding(src)
            if totalBleed > 0 then
                local drainAmount = totalBleed * Config.Wounds.Bleeding.DrainRate
                -- Invoca o ProcessDamage internamente sem passar pelo client
                ProcessDamage(src, DamageType.Generic, nil, drainAmount, 'fdb-medical-core:bleedout')
            end
        end
    end
end)
