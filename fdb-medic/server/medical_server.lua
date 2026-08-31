--=========================================================
-- FDB-MEDIC - SERVER MEDICAL SYSTEM
--=========================================================
-- This file handles server-side medical operations, data sync, and player events
-- Connects the new wound/treatment/infection systems with database persistence
--=========================================================

local FDBCore = exports['fdb-core']:GetCoreObject()

-- Helper function to check if player has any medic job
local function IsMedicJob(jobName)
    if not jobName then return false end

    -- Check against all jobs in MedicJobLocations
    for _, location in pairs(Config.MedicJobLocations) do
        if location.job == jobName then
            return true
        end
    end

    return false
end

-- Server-side player data cache
local PlayerMedicalData = {}

FDBCore.Commands.Add('testcache', 'Test cache sync', {}, false, function(source)
      local Player = FDBCore.Functions.GetPlayer(source)
      print("=== CACHE DATA ===")
      print(json.encode(PlayerMedicalData[source] or {}, {indent = true}))
end, 'admin')
--=========================================================
-- LOCAL FUNCTIONS
--=========================================================
local function InitializePlayerMedicalData(source)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Load all medical data from database
    local data = {} -- GetCompleteMedicalProfile not exported by fdb-medical-core; using fallback
    
    PlayerMedicalData[source] = {
        citizenid = citizenid,
        wounds = data.wounds or {},
        treatments = data.treatments or {},
        infections = data.infections or {},
        bandages = data.bandages or {},
        lastSync = os.time()
    }
    
    -- Send initial data to client
    TriggerClientEvent('fdb-medic:client:SyncWoundData', source, data.wounds)
    TriggerClientEvent('fdb-medic:client:SyncTreatmentData', source, data.treatments)
    TriggerClientEvent('fdb-medic:client:SyncInfectionData', source, data.infections)
    
    print(string.format("^2[fdb-medic] Loaded medical data for %s^7", citizenid))
end

--=========================================================
-- PLAYER CONNECTION EVENTS
--=========================================================
RegisterNetEvent('FDBCore:Server:PlayerLoaded')
AddEventHandler('FDBCore:Server:PlayerLoaded', function(Player)
    local source = Player.PlayerData.source
    Wait(2000) -- Wait for player to fully load
    InitializePlayerMedicalData(source)
    
    -- Send configs and translations once on player load
    local configData = {
        injuryStates = Config.InjuryStates,
        infectionStages = {stages = {{id=0, name="None"}, {id=1, name="Local"}}} -- InfectionSystem fallback,
        bodyParts = Config.BodyParts,
        uiColors = Config.UI.colors,
        locale = Config.Locale,
        translations = Config.Strings or {},
        bandageTypes = Config.BandageTypes or {},
        tourniquetTypes = Config.TourniquetTypes or {},
        medicineTypes = Config.MedicineTypes or {},
        injectionTypes = Config.InjectionTypes or {}
    }
    
    TriggerClientEvent('fdb-medic:client:ReceiveConfigs', source, configData)
    print(string.format('^2[fdb-medic] Sent config data to player %d^7', source))
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000) -- Wait for config to initialize
    
    local configData = {
        injuryStates = Config.InjuryStates,
        infectionStages = {stages = {{id=0, name="None"}, {id=1, name="Local"}}} -- InfectionSystem fallback,
        bodyParts = Config.BodyParts,
        uiColors = Config.UI.colors,
        locale = Config.Locale,
        translations = Config.Strings or {},
        bandageTypes = Config.BandageTypes or {},
        tourniquetTypes = Config.TourniquetTypes or {},
        medicineTypes = Config.MedicineTypes or {},
        injectionTypes = Config.InjectionTypes or {}
    }
    
    local players = FDBCore.Functions.GetPlayers()
    for _, src in ipairs(players) do
        InitializePlayerMedicalData(src)
        TriggerClientEvent('fdb-medic:client:ReceiveConfigs', src, configData)
    end
    print('^2[fdb-medic] Pushed config data and initialized medical data for all online players (Script Restart)^7')
end)

AddEventHandler('FDBCore:Server:OnPlayerUnload', function(source)
    if PlayerMedicalData[source] then
        -- Save all data before player leaves
        local data = PlayerMedicalData[source]
        
        if data.wounds and next(data.wounds) then
            exports['fdb-medic']:SaveWoundData(data.citizenid, data.wounds)
        end
        
        if data.treatments and next(data.treatments) then
            exports['fdb-medic']:SaveTreatmentData(data.citizenid, data.treatments)
        end
        
        if data.infections and next(data.infections) then
            exports['fdb-medic']:SaveInfectionData(data.citizenid, data.infections)
        end
        
        if data.bandages and next(data.bandages) then
            exports['fdb-medic']:SaveBandageData(data.citizenid, data.bandages)
        end

        TriggerClientEvent('fdb-medic:client:SaveMedicalDataOnDisconnect', source)

        PlayerMedicalData[source] = nil
        print(string.format("^3[fdb-medic] Saved and cleared medical data for %s^7", data.citizenid))
    end
end)

--=========================================================
-- CACHE UPDATE HANDLERS (Internal Events from medical_events.lua)
--=========================================================
-- These handlers update the server-side cache after medical_events.lua saves to database
-- This ensures /inspect always shows current data without duplicate DB saves

-- Wound cache update (triggered by medical_events.lua after DB save)
AddEventHandler('fdb-medic:internal:UpdateWoundCache', function(source, woundData)
    if PlayerMedicalData[source] then
        PlayerMedicalData[source].wounds = woundData or {}
        PlayerMedicalData[source].lastSync = os.time()

        if Config.WoundSystem and Config.WoundSystem.debugging and Config.WoundSystem.debugging.enabled then
            local woundCount = 0
            local scarCount = 0
            for bodyPart, wound in pairs(woundData or {}) do
                woundCount = woundCount + 1
                if wound.isScar then
                    scarCount = scarCount + 1
                    print(string.format("^5[CACHE UPDATE] %s is a SCAR (scarTime: %s)^7",
                        bodyPart, tostring(wound.scarTime)))
                end
            end
            print(string.format("^2[CACHE UPDATE] Player %d cache updated: %d total (%d wounds, %d scars)^7",
                source, woundCount, woundCount - scarCount, scarCount))
        end
    end
end)

-- Treatment cache update (triggered by medical_events.lua after DB save)
AddEventHandler('fdb-medic:internal:UpdateTreatmentCache', function(source, treatmentData)
    if PlayerMedicalData[source] then
        PlayerMedicalData[source].treatments = treatmentData or {}
        PlayerMedicalData[source].lastSync = os.time()

        if Config.WoundSystem and Config.WoundSystem.debugging and Config.WoundSystem.debugging.enabled then
            local treatmentCount = 0
            for _ in pairs(treatmentData or {}) do treatmentCount = treatmentCount + 1 end
            print(string.format("^2[CACHE UPDATE] Player %d cache updated: %d treatments^7", source, treatmentCount))
        end
    end
end)

-- Infection cache update (triggered by medical_events.lua after DB save)
AddEventHandler('fdb-medic:internal:UpdateInfectionCache', function(source, infectionData)
    if PlayerMedicalData[source] then
        PlayerMedicalData[source].infections = infectionData or {}
        PlayerMedicalData[source].lastSync = os.time()

        if Config.WoundSystem and Config.WoundSystem.debugging and Config.WoundSystem.debugging.enabled then
            local infectionCount = 0
            for _ in pairs(infectionData or {}) do infectionCount = infectionCount + 1 end
            print(string.format("^2[CACHE UPDATE] Player %d cache updated: %d infections^7", source, infectionCount))
        end
    end
end)

--=========================================================
-- BANDAGE TRACKING SYNCHRONIZATION
--=========================================================
RegisterNetEvent('fdb-medic:server:UpdateBandageData')
AddEventHandler('fdb-medic:server:UpdateBandageData', function(bandageData)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not PlayerMedicalData[src] then
        InitializePlayerMedicalData(src)
        Wait(500)
    end
    
    if PlayerMedicalData[src] then
        PlayerMedicalData[src].bandages = bandageData or {}
        PlayerMedicalData[src].lastSync = os.time()
        
        -- Save to database
        exports['fdb-medic']:SaveBandageData(Player.PlayerData.citizenid, bandageData)
    end
end)

--=========================================================
-- MEDIC TREATMENT COMMANDS
--=========================================================
RegisterNetEvent('fdb-medic:server:MedicApplyBandage')
AddEventHandler('fdb-medic:server:MedicApplyBandage', function(targetId, bodyPart, bandageType)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(targetId)
    
    if not Medic or not Patient then return end
    
    -- Check if source is a medic
    if not IsMedicJob(Medic.PlayerData.job.name) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_access_denied'),
            description = locale('sv_not_medical_professional'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Check if medic has the required item
    if not Medic.Functions.GetItemByName(bandageType) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_missing_supplies'),
            description = string.format(locale('sv_you_dont_have_item'), bandageType),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Remove item from medic
    if Medic.Functions.RemoveItem(bandageType, 1) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[bandageType], 'remove', 1)
        
        -- Apply treatment to patient
        TriggerClientEvent('fdb-medic:client:ApplyBandage', Patient.PlayerData.source, bodyPart, bandageType, src)
        
        -- Log medical action
        exports['fdb-medic']:LogMedicalEvent(
            Patient.PlayerData.citizenid,
            'medic_treatment',
            string.format("Medic applied %s to %s", bandageType, bodyPart),
            bodyPart,
            Medic.PlayerData.citizenid
        )
        
        -- Notify both players
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_treatment_applied'),
            description = string.format(locale('sv_applied_to_patient_bodypart'), bandageType, bodyPart),
            type = 'success',
            duration = 5000
        })
        
        TriggerClientEvent('ox_lib:notify', Patient.PlayerData.source, {
            title = locale('sv_medical_treatment'),
            description = string.format(locale('sv_medic_applied_to_your'), bandageType, bodyPart),
            type = 'inform',
            duration = 5000
        })
    end
end)

RegisterNetEvent('fdb-medic:server:MedicApplyTourniquet')
AddEventHandler('fdb-medic:server:MedicApplyTourniquet', function(targetId, bodyPart, tourniquetType)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(targetId)
    
    if not Medic or not Patient then return end
    
    -- Check if source is a medic
    if not IsMedicJob(Medic.PlayerData.job.name) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_access_denied'),
            description = locale('sv_not_medical_professional'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Check if medic has the required item  
    if not Medic.Functions.GetItemByName(tourniquetType) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_missing_supplies'),
            description = string.format(locale('sv_you_dont_have_item'), tourniquetType),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Remove item from medic
    if Medic.Functions.RemoveItem(tourniquetType, 1) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[tourniquetType], 'remove', 1)
        
        -- Apply emergency treatment to patient
        TriggerClientEvent('fdb-medic:client:ApplyTourniquet', Patient.PlayerData.source, bodyPart, tourniquetType, src)
        
        -- Log medical action
        exports['fdb-medic']:LogMedicalEvent(
            Patient.PlayerData.citizenid,
            'emergency_treatment',
            string.format("Medic applied emergency %s to %s", tourniquetType, bodyPart),
            bodyPart,
            Medic.PlayerData.citizenid
        )
        
        -- Notify both players
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_emergency_treatment'),
            description = string.format(locale('sv_applied_emergency_to_patient'), tourniquetType, bodyPart),
            type = 'warning',
            duration = 8000
        })
        
        TriggerClientEvent('ox_lib:notify', Patient.PlayerData.source, {
            title = locale('sv_emergency_medical_treatment'),
            description = string.format(locale('sv_medic_applied_emergency_to_your'), tourniquetType, bodyPart),
            type = 'warning',
            duration = 8000
        })
    end
end)

RegisterNetEvent('fdb-medic:server:MedicApplyMedicine')
AddEventHandler('fdb-medic:server:MedicApplyMedicine', function(targetId, medicineType)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(targetId)
    
    if not Medic or not Patient then return end
    
    -- Check if source is a medic (using MedicJobLocations)
    local isMedic = false
    for _, location in pairs(Config.MedicJobLocations) do
        if location.job == Medic.PlayerData.job.name then
            isMedic = true
            break
        end
    end
    
    if not isMedic then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_access_denied'),
            description = locale('sv_not_medical_professional'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Get medicine configuration
    local medicineConfig = Config.MedicineTypes[medicineType]
    if not medicineConfig then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_invalid_medicine'),
            description = string.format(locale('sv_unknown_medicine_type'), tostring(medicineType)),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    local itemName = medicineConfig.itemName
    
    -- Check if medic has the required item  
    if not Medic.Functions.GetItemByName(itemName) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_missing_medicine'),
            description = string.format(locale('sv_you_dont_have_item'), medicineConfig.label or itemName),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Remove item from medic
    if Medic.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[itemName], 'remove', 1)
        
        -- Apply medicine treatment to patient (mark as treated, don't clear wounds)
        TriggerClientEvent('fdb-medic:client:ApplyMedicine', Patient.PlayerData.source, medicineType, src)
        
        -- Log medical action
        exports['fdb-medic']:LogMedicalEvent(
            Patient.PlayerData.citizenid,
            'medicine_treatment',
            string.format("Medic administered %s for pain management", medicineConfig.label or medicineType),
            'patient', -- Medicine affects the whole patient, not specific body part
            Medic.PlayerData.citizenid
        )
        
        -- Notify both players
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_medicine_administered'),
            description = string.format(locale('sv_successfully_administered'), medicineConfig.label or medicineType),
            type = 'success',
            duration = 8000
        })
        
        TriggerClientEvent('ox_lib:notify', Patient.PlayerData.source, {
            title = locale('sv_medical_treatment'),
            description = string.format(locale('sv_medic_administered_pain_relief'), medicineConfig.label or medicineType),
            type = 'inform',
            duration = 8000
        })
    end
end)

--=========================================================
-- CLIENT DATA REFRESH (Compatibility Layer)
--=========================================================
RegisterNetEvent('fdb-medic:server:LoadMedicalData')
AddEventHandler('fdb-medic:server:LoadMedicalData', function()
    local source = source
    local data = PlayerMedicalData[source]
    
    if data then
        -- Fetch real-time wounds from the core state
        local coreVitals = exports['fdb-medical-core']:GetVitals(source)
        if coreVitals and coreVitals.wounds then
            data.wounds = coreVitals.wounds
        end

        TriggerClientEvent('fdb-medic:client:SyncWoundData', source, data.wounds or {})
        TriggerClientEvent('fdb-medic:client:SyncTreatmentData', source, data.treatments or {})
        TriggerClientEvent('fdb-medic:client:SyncInfectionData', source, data.infections or {})
    end
end)

--=========================================================
-- MEDICAL INSPECTION SYSTEM
--=========================================================
RegisterNetEvent('fdb-medic:server:RequestMedicalInspection')
AddEventHandler('fdb-medic:server:RequestMedicalInspection', function(targetId)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(targetId)
    
    if not Medic or not Patient then return end
    
    -- Check if source is a medic (using MedicJobLocations)
    local isMedic = false
    for _, location in pairs(Config.MedicJobLocations) do
        if location.job == Medic.PlayerData.job.name then
            isMedic = true
            break
        end
    end
    
    if not isMedic then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_access_denied'),
            description = locale('sv_not_medical_professional'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Get patient medical data from core
    local vitals = exports['fdb-medical-core']:GetVitals(Patient.PlayerData.source)
    local coreWounds = vitals and vitals.wounds or {}
    
    -- Prepare inspection data
    local inspectionData = {
        patientName = Patient.PlayerData.charinfo.firstname .. " " .. Patient.PlayerData.charinfo.lastname,
        patientId = Patient.PlayerData.citizenid,
        wounds = coreWounds,
        treatments = {},
        infections = {},
        inspectedBy = Medic.PlayerData.citizenid
    }
    
    -- Send inspection data to medic
    TriggerClientEvent('fdb-medic:client:ShowMedicalInspection', src, inspectionData)
    
    -- Log inspection
    exports['fdb-medic']:LogMedicalEvent(
        Patient.PlayerData.citizenid,
        'medical_inspection',
        nil, -- No specific body part for general inspection
        {
            description = string.format("Medical inspection performed by %s %s", 
                Medic.PlayerData.charinfo.firstname,
                Medic.PlayerData.charinfo.lastname
            ),
            medic_name = Medic.PlayerData.charinfo.firstname .. " " .. Medic.PlayerData.charinfo.lastname
        },
        Medic.PlayerData.citizenid
    )
    
    -- Notify patient
    TriggerClientEvent('ox_lib:notify', Patient.PlayerData.source, {
        title = locale('sv_medical_inspection'),
        description = locale('sv_medical_professional_examining'),
        type = 'inform',
        duration = 5000
    })
end)

--=========================================================
-- MEDICAL HISTORY CALLBACK
--=========================================================
FDBCore.Functions.CreateCallback('fdb-medic:server:GetMedicalHistory', function(source, cb, targetId, limit)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)
    
    if not Medic or not IsMedicJob(Medic.PlayerData.job.name) then
        cb({})
        return
    end
    
    local Patient = FDBCore.Functions.GetPlayer(targetId)
    if not Patient then
        cb({})
        return
    end
    
    exports['fdb-medic']:GetMedicalHistory(Patient.PlayerData.citizenid, limit or 25, function(history)
        cb(history)
    end)
end)

--=========================================================
-- PLAYER WOUND DATA CALLBACK
--=========================================================
FDBCore.Functions.CreateCallback('fdb-medic:server:GetPlayerWounds', function(source, cb, targetId)
    local targetSource = targetId or source
    
    if PlayerMedicalData[targetSource] then
        cb(PlayerMedicalData[targetSource].wounds or {})
    else
        cb({})
    end
end)

--=========================================================
-- REGULAR DATA PERSISTENCE (Every 5 minutes)
--=========================================================
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        
        for source, data in pairs(PlayerMedicalData) do
            if data.lastSync and (os.time() - data.lastSync) < 600 then -- Only sync if data changed in last 10 minutes
                -- Save wounds
                if data.wounds and next(data.wounds) then
                    exports['fdb-medic']:SaveWoundData(data.citizenid, data.wounds)
                end
                
                -- Save treatments
                if data.treatments and next(data.treatments) then
                    exports['fdb-medic']:SaveTreatmentData(data.citizenid, data.treatments)
                end
                
                -- Save infections
                if data.infections and next(data.infections) then
                    exports['fdb-medic']:SaveInfectionData(data.citizenid, data.infections)
                end
                
                -- Save bandage tracking
                if data.bandages and next(data.bandages) then
                    exports['fdb-medic']:SaveBandageData(data.citizenid, data.bandages)
                end
            end
        end
        
        print("^2[fdb-medic] Performed regular data sync for all players^7")
    end
end)

--=========================================================
-- MEDIC INSPECT COMMAND
--=========================================================
FDBCore.Commands.Add('inspect', 'Inspect another player\'s medical condition (Medic Only)', {{name = 'id', help = 'Player ID to inspect'}}, true, function(source, args)
    local src = source
    print('^3[fdb-medic] DEBUG: /inspect command triggered by player ' .. src .. '^7')
    local Medic = FDBCore.Functions.GetPlayer(src)
    
    if not Medic then return end
    
    -- Check if source is a medic
    if not IsMedicJob(Medic.PlayerData.job.name) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_access_denied'),
            description = locale('sv_not_medical_professional'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_invalid_usage'),
            description = locale('sv_usage_inspect'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    local Patient = FDBCore.Functions.GetPlayer(targetId)
    if not Patient then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_player_not_found'),
            description = string.format(locale('sv_player_id_not_online'), targetId),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Check distance between medic and patient
    local medicPed = GetPlayerPed(src)
    local patientPed = GetPlayerPed(Patient.PlayerData.source)
    local medicCoords = GetEntityCoords(medicPed)
    local patientCoords = GetEntityCoords(patientPed)
    local distance = #(medicCoords - patientCoords)
    
    if distance > 10.0 then -- 10 meter inspection range
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_too_far_away'),
            description = locale('sv_must_be_closer_inspection'),
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Get patient medical data from the new core (fdb-medical-core)
    local vitals = exports['fdb-medical-core']:GetVitals(Patient.PlayerData.source)
    local coreWounds = vitals and vitals.wounds or {}
    

    -- Check medic's inventory for doctor bag tools and medicines
    local medicInventory = {
        tools = {},
        medicines = {}
    }

    -- Check doctor bag tools
    for toolKey, toolConfig in pairs(Config.DoctorsBagTools or {}) do
        local itemName = toolConfig.itemName
        local hasItem = Medic.Functions.GetItemByName(itemName) ~= nil
        medicInventory.tools[toolKey] = {
            hasItem = hasItem,
            itemName = itemName,
            label = toolConfig.label,
            consumable = toolConfig.consumable
        }
    end

    -- Check medicines (laudanum, whiskey already in MedicineTypes)
    for medKey, medConfig in pairs(Config.MedicineTypes or {}) do
        local itemName = medConfig.itemName
        local hasItem = Medic.Functions.GetItemByName(itemName) ~= nil
        medicInventory.medicines[medKey] = {
            hasItem = hasItem,
            itemName = itemName,
            label = medConfig.label
        }
    end

    -- Prepare inspection data for the frontend (lightweight - no configs)
    local inspectionData = {
        playerName = Patient.PlayerData.charinfo.firstname .. " " .. Patient.PlayerData.charinfo.lastname,
        playerId = Patient.PlayerData.citizenid,
        playerSource = Patient.PlayerData.source,
        wounds = coreWounds,
        treatments = {}, -- Treatments will now be handled natively by fdb-medical-core state
        infections = {}, -- Infections handled natively

        bandages = PlayerMedicalData[Patient.PlayerData.source] and PlayerMedicalData[Patient.PlayerData.source].bandages or {},
        inspectedBy = Medic.PlayerData.citizenid,
        inspectionTime = os.time(),
        medicInventory = medicInventory  -- Add medic's inventory
    }
    
    -- Send inspection data to medic's NUI
    TriggerClientEvent('fdb-medic:client:ShowInspectionPanel', src, inspectionData)
    
    -- Log inspection (async to prevent blocking)
    CreateThread(function()
        exports['fdb-medic']:LogMedicalEvent(
            Patient.PlayerData.citizenid,
            'medical_inspection',
            nil, -- No specific body part for general inspection
            {
                description = string.format("Medical inspection performed by %s %s", 
                    Medic.PlayerData.charinfo.firstname,
                    Medic.PlayerData.charinfo.lastname
                ),
                medic_name = Medic.PlayerData.charinfo.firstname .. " " .. Medic.PlayerData.charinfo.lastname
            },
            Medic.PlayerData.citizenid
        )
    end)
    
    -- Notify both players
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('sv_medical_inspection'),
        description = string.format(locale('sv_examining_patient'),
            Patient.PlayerData.charinfo.firstname,
            Patient.PlayerData.charinfo.lastname
        ),
        type = 'inform',
        duration = 5000
    })
    
    TriggerClientEvent('ox_lib:notify', Patient.PlayerData.source, {
        title = locale('sv_medical_inspection'),
        description = string.format(locale('sv_doctor_examining_you'),
            Medic.PlayerData.charinfo.firstname,
            Medic.PlayerData.charinfo.lastname
        ),
        type = 'inform',
        duration = 5000
    })
end)

--=========================================================
-- Health/Vitals Check Request Handler
--=========================================================

RegisterServerEvent('fdb-medic:server:CheckVitals')
AddEventHandler('fdb-medic:server:CheckVitals', function(targetPlayerId)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)
    local Patient = FDBCore.Functions.GetPlayer(targetPlayerId)
    
    if not Medic or not Patient then
        print('Error: Invalid medic or patient for vitals check')
        return
    end
    
    print(string.format('^2[fdb-medic] Requesting vitals from target client: %d^7', Patient.PlayerData.source))
    
    -- Request health data from the target player's client
    TriggerClientEvent('fdb-medic:client:SendVitalsToMedic', Patient.PlayerData.source, src)
end)

-- New event to receive vitals data from target client
RegisterServerEvent('fdb-medic:server:ReceiveVitalsData')
AddEventHandler('fdb-medic:server:ReceiveVitalsData', function(medicSource, vitalsData)
    local src = source -- This is the patient who is sending their vitals
    local Patient = FDBCore.Functions.GetPlayer(src)
    
    if not Patient then
        print('Error: Invalid patient sending vitals data')
        return
    end
    
    print(string.format('^2[fdb-medic] Received vitals from %s: Health=%d%%, Dead=%s^7', 
        Patient.PlayerData.name, vitalsData.health, tostring(vitalsData.isDead)))
    
    -- Add player name to vitals data
    vitalsData.targetName = string.format('%s %s', 
        Patient.PlayerData.charinfo.firstname,
        Patient.PlayerData.charinfo.lastname
    )
    
    -- Send vitals data to the requesting medic
    TriggerClientEvent('fdb-medic:client:VitalsResponse', medicSource, vitalsData)
end)

--=========================================================
-- DOCTOR BAG TOOL USAGE HANDLER
--=========================================================
RegisterServerEvent('fdb-medic:server:UseDoctorBagTool')
AddEventHandler('fdb-medic:server:UseDoctorBagTool', function(toolAction, targetPlayerId)
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)

    if Config.Debug then
        print(string.format("^3[SERVER UseDoctorBagTool] Triggered by src=%s, toolAction=%s, targetPlayerId=%s^7", tostring(src), tostring(toolAction), tostring(targetPlayerId)))
    end

    if not Medic then
        print('[ERROR] Invalid medic player in UseDoctorBagTool')
        return
    end

    -- Handle medicines separately (they're in Config.MedicineTypes, not DoctorsBagTools)
    if toolAction == 'medicine_laudanum' or toolAction == 'medicine_whiskey' then
        local medicineType = toolAction:gsub('medicine_', '')  -- Extract medicine key (laudanum or whiskey)
        local medicineConfig = Config.MedicineTypes[medicineType]

        if Config.Debug then
            print(string.format("^3[SERVER UseDoctorBagTool] Medicine action detected: %s^7", medicineType))
        end

        if not medicineConfig then
            TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
                success = false,
                message = 'Invalid medicine type: ' .. tostring(medicineType)
            })
            return
        end

        local itemName = medicineConfig.itemName

        if Config.Debug then
            print(string.format("^3[SERVER UseDoctorBagTool] Checking for medicine: %s^7", itemName))
        end

        -- Try to remove medicine item
        local removed = Medic.Functions.RemoveItem(itemName, 1)

        if Config.Debug then
            print(string.format("^3[SERVER UseDoctorBagTool] Medicine check result: removed=%s^7", tostring(removed)))
        end

        if not removed then
            if Config.Debug then
                print(string.format("^1[SERVER UseDoctorBagTool] Player missing medicine: %s^7", medicineConfig.label))
            end
            TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
                success = false,
                message = string.format('Missing item: %s', medicineConfig.label),
                refreshInventory = true
            })
            return
        end

        -- Successfully removed medicine - continue to medicine administration below
        local Patient = FDBCore.Functions.GetPlayer(targetPlayerId)
        if not Patient then
            -- Refund medicine if patient not found
            Medic.Functions.AddItem(itemName, 1)
            TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
                success = false,
                message = 'Patient not found'
            })
            return
        end

        -- Trigger client to apply medicine using existing system
        TriggerClientEvent('fdb-medic:client:AdministreMedicine', Patient.PlayerData.source, medicineType, src)

        TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
            success = true,
            message = string.format('Administered %s', medicineConfig.label),
            refreshInventory = true
        })

        return
    end

    -- Find the tool config by action (for non-medicine tools)
    local toolConfig = nil
    local toolKey = nil
    for key, config in pairs(Config.DoctorsBagTools or {}) do
        if config.action == toolAction then
            toolConfig = config
            toolKey = key
            break
        end
    end

    if Config.Debug then
        print(string.format("^3[SERVER UseDoctorBagTool] Tool config found: %s (key=%s)^7", tostring(toolConfig ~= nil), tostring(toolKey)))
    end

    if not toolConfig then
        if Config.Debug then
            print(string.format("^1[SERVER UseDoctorBagTool] Invalid tool action: %s^7", tostring(toolAction)))
        end
        TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
            success = false,
            message = 'Invalid tool action: ' .. tostring(toolAction)
        })
        return
    end

    local itemName = toolConfig.itemName

    if Config.Debug then
        print(string.format("^3[SERVER UseDoctorBagTool] Checking for item: %s (consumable=%s)^7", itemName, tostring(toolConfig.consumable)))
    end

    -- Try to remove item (framework handles validation)
    local removed = false
    if toolConfig.consumable then
        removed = Medic.Functions.RemoveItem(itemName, 1)
    else
        -- Non-consumable: just check if they have it
        removed = Medic.Functions.GetItemByName(itemName) ~= nil
    end

    if Config.Debug then
        print(string.format("^3[SERVER UseDoctorBagTool] Item check result: removed=%s^7", tostring(removed)))
    end

    if not removed then
        -- Failed to remove = don't have item
        if Config.Debug then
            print(string.format("^1[SERVER UseDoctorBagTool] Player missing item: %s^7", toolConfig.label))
        end
        TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
            success = false,
            message = string.format('Missing item: %s', toolConfig.label),
            refreshInventory = true  -- Tell client to refresh inventory
        })
        return
    end

    -- Successfully removed/has item - perform action
    local Patient = FDBCore.Functions.GetPlayer(targetPlayerId)
    if not Patient then
        -- Refund consumable if patient not found
        if toolConfig.consumable then
            Medic.Functions.AddItem(itemName, 1)
        end
        TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
            success = false,
            message = 'Patient not found'
        })
        return
    end

    -- Perform the tool action
    if toolAction == 'revive_unconscious' then
        -- Smelling salts - revive unconscious player (check if dead/unconscious first)
        if Config.Debug then
            print(string.format("^2[SMELLING SALTS] Reviving player %s (source: %d)^7",
                Patient.PlayerData.charinfo.firstname, Patient.PlayerData.source))
        end

        TriggerClientEvent('fdb-medic:client:playerRevive', Patient.PlayerData.source)

        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_smelling_salts'),
            description = string.format(locale('sv_administered_smelling_salts'),
                Patient.PlayerData.charinfo.firstname,
                Patient.PlayerData.charinfo.lastname
            ),
            type = 'success',
            duration = 5000
        })

        TriggerClientEvent('ox_lib:notify', Patient.PlayerData.source, {
            title = locale('sv_revived'),
            description = locale('sv_revived_smelling_salts'),
            type = 'success',
            duration = 5000
        })

    elseif toolAction == 'check_heart_lungs' then
        -- Stethoscope - trigger vitals check
        TriggerEvent('fdb-medic:server:CheckVitals', targetPlayerId)

    elseif toolAction == 'check_temperature' then
        -- Thermometer - check for infections/fever
        local patientData = PlayerMedicalData[Patient.PlayerData.source]
        local infectionCount = 0
        if patientData and patientData.infections then
            for _ in pairs(patientData.infections) do
                infectionCount = infectionCount + 1
            end
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_temperature_check'),
            description = infectionCount > 0 and
                string.format(locale('sv_elevated_temperature'), infectionCount) or
                locale('sv_temperature_normal'),
            type = infectionCount > 0 and 'warning' or 'success',
            duration = 5000
        })

    elseif toolAction == 'emergency_surgery' then
        -- Field surgery kit - heal all wounds
        TriggerClientEvent('fdb-medic:client:ClearAllWounds', Patient.PlayerData.source)

        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_emergency_surgery'),
            description = locale('sv_field_surgery_completed'),
            type = 'success',
            duration = 5000
        })

    elseif toolAction == 'medicine_laudanum' or toolAction == 'medicine_whiskey' then
        -- Medicines from doctor bag - use existing medicine application logic
        local medicineType = toolAction:gsub('medicine_', '')  -- Extract medicine key

        -- Trigger client to apply medicine using existing system
        TriggerClientEvent('fdb-medic:client:AdministreMedicine', Patient.PlayerData.source, medicineType, src)

        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_medicine_administered'),
            description = string.format(locale('sv_administered_to_patient'),
                medicineType,
                Patient.PlayerData.charinfo.firstname,
                Patient.PlayerData.charinfo.lastname
            ),
            type = 'success',
            duration = 5000
        })
    end

    -- Success - return with updated inventory
    TriggerClientEvent('fdb-medic:client:ToolUsageResult', src, {
        success = true,
        message = string.format('Successfully used %s', toolConfig.label),
        refreshInventory = true
    })
end)

--=========================================================
-- REFRESH MEDIC INVENTORY (after item usage)
--=========================================================
RegisterServerEvent('fdb-medic:server:RefreshMedicInventory')
AddEventHandler('fdb-medic:server:RefreshMedicInventory', function()
    local src = source
    local Medic = FDBCore.Functions.GetPlayer(src)

    if not Medic then return end

    -- Re-check medic's inventory
    local medicInventory = {
        tools = {},
        medicines = {}
    }

    -- Check doctor bag tools
    for toolKey, toolConfig in pairs(Config.DoctorsBagTools or {}) do
        local itemName = toolConfig.itemName
        local hasItem = Medic.Functions.GetItemByName(itemName) ~= nil
        medicInventory.tools[toolKey] = {
            hasItem = hasItem,
            itemName = itemName,
            label = toolConfig.label,
            consumable = toolConfig.consumable
        }
    end

    -- Check medicines
    for medKey, medConfig in pairs(Config.MedicineTypes or {}) do
        local itemName = medConfig.itemName
        local hasItem = Medic.Functions.GetItemByName(itemName) ~= nil
        medicInventory.medicines[medKey] = {
            hasItem = hasItem,
            itemName = itemName,
            label = medConfig.label
        }
    end

    -- Send updated inventory to client
    TriggerClientEvent('fdb-medic:client:UpdateMedicInventory', src, medicInventory)
end)

--=========================================================
-- SERVER-SIDE WOUND PROGRESSION SYSTEM
--=========================================================
-- Realistic time-based wound progression without RNG
-- Only untreated bleeding wounds get worse over time
--=========================================================

CreateThread(function()
    while true do
        Wait(10 -- WoundProgression fallback (10 min) * 60 * 1000) -- Convert minutes to milliseconds
        
        -- Process wound progression for all online players
        for src, data in pairs(PlayerMedicalData) do
            if data.wounds and next(data.wounds) then
                local Player = FDBCore.Functions.GetPlayer(src)
                if Player then
                    local woundsChanged = false
                    local currentTime = os.time()
                    
                    -- Check which body parts have active vs expired bandages
                    local hasActiveBandages = {}
                    local hasExpiredBandages = {}
                    if data.treatments then
                        for bodyPart, treatment in pairs(data.treatments) do
                            if treatment.treatmentType == 'bandage' then
                                if treatment.isActive then
                                    hasActiveBandages[bodyPart] = true
                                else
                                    -- Bandage exists but is expired (not active)
                                    hasExpiredBandages[bodyPart] = true
                                end
                            end
                        end
                    end
                    
                    for bodyPart, wound in pairs(data.wounds) do
                        if wound and type(wound) == 'table' and not wound.isScar then
                            local hasActiveBandage = hasActiveBandages[bodyPart] or false
                            local hasExpiredBandage = hasExpiredBandages[bodyPart] or false
                            
                            -- UPDATED WOUND PROGRESSION RULES:
                            -- 1. BLEEDING PROGRESSION: Only bleeding wounds without ACTIVE bandages get worse (includes expired bandages)
                            -- 2. PAIN PROGRESSION: Only bleeding wounds without ACTIVE bandages get more painful (includes expired bandages)
                            -- 3. NATURAL HEALING: Only non-bleeding wounds without any bandages heal pain
                            
                            -- Allow progression if no active bandage (expired bandages allow bleeding through)
                            if not hasActiveBandage then
                                -- BLEEDING PROGRESSION (guaranteed every interval)
                                -- Convert to numbers to prevent type comparison errors
                                local bleedingLevel = tonumber(wound.bleedingLevel) or 0
                                local painLevel = tonumber(wound.painLevel) or 0
                                
                                if bleedingLevel > 0 and bleedingLevel < 10 then
                                    local oldBleeding = bleedingLevel
                                    wound.bleedingLevel = math.min(bleedingLevel + Config.WoundProgression.bleedingProgressAmount, 10)
                                    woundsChanged = true
                                    
                                    -- Notify player with context-appropriate message
                                    local notificationMsg
                                    if hasExpiredBandage then
                                        notificationMsg = string.format('Blood is seeping through your expired %s bandage!', 
                                            (Config.BodyParts[bodyPart] and Config.BodyParts[bodyPart].label or bodyPart):lower())
                                    else
                                        notificationMsg = string.format('Your %s wound is bleeding more - apply bandage!', 
                                            (Config.BodyParts[bodyPart] and Config.BodyParts[bodyPart].label or bodyPart):lower())
                                    end
                                    
                                    TriggerClientEvent('ox_lib:notify', src, {
                                        title = locale('sv_medical_alert'),
                                        description = notificationMsg,
                                        type = 'error',
                                        duration = 6000
                                    })
                                    
                                    if Config.WoundSystem and Config.WoundSystem.debugging and Config.WoundSystem.debugging.enabled then
                                        local bleedingReason = hasExpiredBandage and " (bleeding through expired bandage)" or " (no bandage)"
                                        print(string.format("^1[SERVER BLEEDING] %s bleeding progressed: %.1f->%.1f%s^7", 
                                            bodyPart, oldBleeding, wound.bleedingLevel, bleedingReason))
                                    end
                                end
                                
                                -- PAIN PROGRESSION (only if bleeding - realistic wound care)
                                if bleedingLevel > 0 and painLevel < 10 then
                                    local oldPain = painLevel
                                    wound.painLevel = math.min(painLevel + Config.WoundProgression.painProgressAmount, 10)
                                    woundsChanged = true
                                    
                                    if Config.WoundSystem and Config.WoundSystem.debugging and Config.WoundSystem.debugging.enabled then
                                        print(string.format("^3[SERVER PAIN] %s pain progressed due to bleeding: %.1f->%.1f^7", 
                                            bodyPart, oldPain, wound.painLevel))
                                    end
                                end
                                
                                -- NATURAL PAIN HEALING (only if no bleeding)
                                -- Note: Natural healing will be handled by a separate 5-minute timer
                                if bleedingLevel <= 0 and painLevel > 0 then
                                    -- This will be handled by a separate natural healing system
                                end
                            end
                        end
                    end
                    
                    -- Save changes to database and sync to client
                    if woundsChanged then
                        exports['fdb-medic']:SaveWoundData(Player.PlayerData.citizenid, data.wounds)
                        TriggerClientEvent('fdb-medic:client:SyncWoundData', src, data.wounds)
                        
                        -- Log progression event
                        exports['fdb-medic']:LogMedicalEvent(
                            Player.PlayerData.citizenid,
                            'wound_change',
                            nil,
                            {message = "Server-side wound progression applied"},
                            'system'
                        )
                    end
                end
            end
        end
    end
end)

--=========================================================
-- SERVER-SIDE NATURAL HEALING SYSTEM  
--=========================================================
-- Separate 5-minute timer for natural pain healing
--=========================================================

CreateThread(function()
    while true do
        Wait(Config.WoundProgression.painNaturalHealingInterval * 60 * 1000) -- 5 minutes
        
        -- Process natural healing for all online players
        for src, data in pairs(PlayerMedicalData) do
            if data.wounds and next(data.wounds) then
                local Player = FDBCore.Functions.GetPlayer(src)
                if Player then
                    local woundsChanged = false
                    
                    -- Check which body parts have active vs expired bandages (for natural healing)
                    local hasActiveBandages = {}
                    local hasAnyBandages = {}
                    if data.treatments then
                        for bodyPart, treatment in pairs(data.treatments) do
                            if treatment.treatmentType == 'bandage' then
                                hasAnyBandages[bodyPart] = true
                                if treatment.isActive then
                                    hasActiveBandages[bodyPart] = true
                                end
                            end
                        end
                    end
                    
                    for bodyPart, wound in pairs(data.wounds) do
                        if wound and type(wound) == 'table' and not wound.isScar then
                            local hasActiveBandage = hasActiveBandages[bodyPart] or false
                            local hasAnyBandage = hasAnyBandages[bodyPart] or false
                            
                            -- NATURAL PAIN HEALING (only if no bleeding and no bandage at all - not even expired)
                            -- Convert to numbers to prevent type comparison errors
                            local bleedingLevel = tonumber(wound.bleedingLevel) or 0
                            local painLevel = tonumber(wound.painLevel) or 0
                            
                            if not hasAnyBandage and bleedingLevel <= 0 and painLevel > 0 then
                                local oldPain = painLevel
                                wound.painLevel = math.max(painLevel - Config.WoundProgression.painNaturalHealAmount, 0)
                                woundsChanged = true
                                
                                if Config.WoundSystem and Config.WoundSystem.debugging and Config.WoundSystem.debugging.enabled then
                                    print(string.format("^6[SERVER NATURAL HEALING] %s pain naturally healed: %.1f->%.1f^7", 
                                        bodyPart, oldPain, wound.painLevel))
                                end
                            end
                        end
                    end
                    
                    -- Save changes to database and sync to client
                    if woundsChanged then
                        exports['fdb-medic']:SaveWoundData(Player.PlayerData.citizenid, data.wounds)
                        TriggerClientEvent('fdb-medic:client:SyncWoundData', src, data.wounds)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- NetEvents para interação segura com o fdb-medical-core
-- ============================================================

RegisterNetEvent('fdb-medic:server:TreatWound', function(treatmentType, bodyPart)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- 1. O item PRECISA existir no config de tratamentos. Se não existir, não cura nada.
    local treatmentConfig = (Config.BandageTypes and Config.BandageTypes[treatmentType]) or 
                            (Config.TourniquetTypes and Config.TourniquetTypes[treatmentType]) or 
                            (Config.MedicineTypes and Config.MedicineTypes[treatmentType]) or 
                            (Config.InjectionTypes and Config.InjectionTypes[treatmentType])
                            
    if not treatmentConfig then
        print(string.format('[fdb-medic] ^1TENTATIVA SUSPEITA^7: src %s chamou TreatWound com tratamento nao mapeado: %s', tostring(src), tostring(treatmentType)))
        return
    end

    -- 2. O jogador PRECISA ter o item de verdade. RemoveItem falha se não tiver.
    local itemName = treatmentConfig.itemName
    if not itemName then
        print(string.format('[fdb-medic] ^1ERRO DE CONFIGURACAO^7: Tratamento mapeado sem itemName: %s', tostring(treatmentType)))
        return
    end

    local hasItem = Player.Functions.RemoveItem(itemName, 1)
    if not hasItem then
        print(string.format('[fdb-medic] ^1TENTATIVA SUSPEITA^7: src %s tentou TreatWound sem possuir o item: %s (%s)', tostring(src), tostring(itemName), tostring(treatmentType)))
        return
    end

    -- 3. Só agora aplica, com o valor que VEM DO CONFIG, nunca do client.
    local healAmount = treatmentConfig.oneTimeHeal or treatmentConfig.healAmount or 0
    
    if healAmount > 0 then
        exports['fdb-medical-core']:ApplyDamage(src, 'Treatment', bodyPart, -healAmount)
    end
end)

RegisterNetEvent('fdb-medic:server:FullHeal', function()
    local src = source
    
    -- Check permissions (evita cura grátis sem item)
    if not FDBCore.Functions.HasPermission(src, 'admin') then
        -- Se não for admin, podemos permitir apenas se for chamado pelo script
        -- mas por segurança, logamos e ignoramos para evitar abuse de modders.
        print(("[fdb-medic] Aviso: Jogador %s tentou usar FullHeal sem permissão de admin."):format(src))
        return
    end

    -- Chama a export nativa recém-criada no core (que lida com o reset dos vitais)
    exports['fdb-medical-core']:FullHeal(src)
end)

-- Dano de torniquete: valor vem do Config, não do parâmetro do evento
RegisterNetEvent('fdb-medic:server:TourniquetDamage', function(bodyPart, tourniquetType)
    local tourniquetConfig = Config.TourniquetTypes and Config.TourniquetTypes[tourniquetType]
    local damageAmount = (tourniquetConfig and tourniquetConfig.damageAmount) or 3
    exports['fdb-medical-core']:ApplyDamage(source, 'Treatment', bodyPart, damageAmount)
end)

RegisterNetEvent('fdb-medic:server:RespiratoryDepressionDamage', function()
    exports['fdb-medical-core']:ApplyDamage(source, 'Illness', 'Torso', 1)
end)

-- Dano de overdose: valor vem do Config da injeção usada, não do parâmetro do evento
RegisterNetEvent('fdb-medic:server:OverdoseDamage', function(injectionType)
    local injectionConfig = Config.InjectionTypes and Config.InjectionTypes[injectionType]
    local overdoseDamage = (injectionConfig and injectionConfig.healAmount) or 20
    exports['fdb-medical-core']:ApplyDamage(source, 'Poison', 'Torso', overdoseDamage)
end)

RegisterNetEvent('fdb-medic:server:KillMe', function()
    exports['fdb-medical-core']:ApplyDamage(source, 'Generic', 'Torso', 9999)
end)
