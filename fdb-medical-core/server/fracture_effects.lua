-- ============================================================
-- FDB System | fdb-medical-core | server/fracture_effects.lua
-- ============================================================

function ApplyFracturePenalty(src, bodyPart)
    TriggerClientEvent('fdb-medical-core:client:SetWalkstylePenalty', src, true, bodyPart)
    if Config.Fractures.MoveRatePenalty[bodyPart] then
        TriggerClientEvent('fdb-survival:client:SetMoveRateModifier', src, 'fracture_'..bodyPart, Config.Fractures.MoveRatePenalty[bodyPart])
    end
    if bodyPart == 'TORSO' then
        TriggerClientEvent('fdb-medical-core:client:SetStaminaPenalty', src, true)
    end
    if bodyPart == 'LARM' or bodyPart == 'RARM' then
        TriggerClientEvent('fdb-medical-core:client:SetAimPenalty', src, true)
    end
end

function RemoveFracturePenalty(src, bodyPart)
    TriggerClientEvent('fdb-medical-core:client:SetWalkstylePenalty', src, false, bodyPart)
    if Config.Fractures.MoveRatePenalty[bodyPart] then
        TriggerClientEvent('fdb-survival:client:SetMoveRateModifier', src, 'fracture_'..bodyPart, nil)
    end
    if bodyPart == 'TORSO' then
        TriggerClientEvent('fdb-medical-core:client:SetStaminaPenalty', src, false)
    end
    if bodyPart == 'LARM' or bodyPart == 'RARM' then
        TriggerClientEvent('fdb-medical-core:client:SetAimPenalty', src, false)
    end
end
