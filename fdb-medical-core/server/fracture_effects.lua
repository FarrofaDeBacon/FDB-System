function ApplyFracturePenalty(src, bodyPart)
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
