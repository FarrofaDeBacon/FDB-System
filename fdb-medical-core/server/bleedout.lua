-- ============================================================
-- FDB System | fdb-medical-core | server/bleedout.lua
-- Server-owned bleeding drain loop
-- ============================================================

CreateThread(function()
    while true do
        Wait(Config.Wounds.Bleeding.TickInterval)
        for src, _ in pairs(PlayerVitals) do
            local totalBleed = GetTotalBleeding(src)
            if totalBleed > 0 then
                local drainAmount = totalBleed * Config.Wounds.Bleeding.DrainRate
                -- Invokes ProcessDamage internally without passing through the client
                ProcessDamage(src, DamageType.Generic, nil, drainAmount, 'fdb-medical-core:bleedout')
            end
        end
    end
end)
