-- =========================================================
-- FDB-MEDIC - TREATMENT SYSTEM (Phase C refactor)
-- =========================================================
-- This file previously handled all medical treatments.
-- In Phase C, all treatment logic was moved to fdb-medical-core server.
-- These handlers just proxy requests to the server.
-- =========================================================

local function SendTreatment(woundId, treatmentType, itemUsed)
    -- As per Phase B/C, we send this to the core server
    TriggerServerEvent('fdb-medical-core:server:ProcessTreatment', woundId, treatmentType, itemUsed)
end

--=========================================================
-- EXPORTS FOR OTHER MODULES (Legacy support)
--=========================================================
exports('ApplyBandage', function(bodyPart, bandageType)
    SendTreatment(bodyPart, 'bandage', bandageType)
    return true
end)

exports('ApplyTourniquet', function(bodyPart, tourniquetType)
    SendTreatment(bodyPart, 'bandage', tourniquetType) -- Mapped to bandage logic on server for now
    return true
end)

exports('AdministreMedicine', function(medicineType)
    SendTreatment(nil, 'medicine', medicineType)
    return true
end)

exports('GiveInjection', function(injectionType)
    SendTreatment(nil, 'medicine', injectionType)
    return true
end)

--=========================================================
-- NETWORK EVENTS
--=========================================================
RegisterNetEvent('fdb-medic:client:ApplyBandage')
AddEventHandler('fdb-medic:client:ApplyBandage', function(bodyPart, bandageType)
    SendTreatment(bodyPart, 'bandage', bandageType)
end)

RegisterNetEvent('fdb-medic:client:ApplyTourniquet')
AddEventHandler('fdb-medic:client:ApplyTourniquet', function(bodyPart, tourniquetType)
    SendTreatment(bodyPart, 'bandage', tourniquetType)
end)

RegisterNetEvent('fdb-medic:client:AdministreMedicine')
AddEventHandler('fdb-medic:client:AdministreMedicine', function(medicineType)
    SendTreatment(nil, 'medicine', medicineType)
end)

RegisterNetEvent('fdb-medic:client:ApplyMedicine')
AddEventHandler('fdb-medic:client:ApplyMedicine', function(medicineType)
    SendTreatment(nil, 'medicine', medicineType)
end)

RegisterNetEvent('fdb-medic:client:GiveInjection')
AddEventHandler('fdb-medic:client:GiveInjection', function(injectionType)
    SendTreatment(nil, 'medicine', injectionType)
end)

RegisterNetEvent('fdb-medic:client:usetourniquet')
AddEventHandler('fdb-medic:client:usetourniquet', function(tourniquetType)
    -- In Phase C, the server figures out which body part to heal if nil? 
    -- Or UI always sends body part.
    -- If no body part is sent, we can't reliably heal. 
    -- UI should always use the specific body part endpoint.
end)
