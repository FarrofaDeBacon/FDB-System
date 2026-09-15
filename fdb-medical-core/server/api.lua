-- ============================================================
-- FDB System | fdb-medical-core | server/api.lua
-- Public exports for consumption by other resources
-- ============================================================
local FDBCore = exports['fdb-core']:GetCoreObject()

--- Single entry point for ANY damage on the server.
--- @param source number Player ID receiving the damage
--- @param damageType string Enum DamageType (Gunshot, Melee, Fall, Poison, Illness, Cold, Heat...)
--- @param bodyPart string|nil Enum BodyPart (Head, Torso, Arms, Legs) or nil for systemic
--- @param amount number Damage intensity (positive = damage, negative = heal)
exports('ApplyDamage', function(source, damageType, bodyPart, amount)
    local caller = GetInvokingResource() or 'unknown'
    ProcessDamage(source, damageType, bodyPart, amount, caller)
end)

--- Applies treatment to a wound or player state
--- @param source number Player ID
--- @param woundId string|nil Wound ID
--- @param treatmentType string Treatment type ('bandage', 'antidote', 'medicine')
--- @param itemUsed string|nil Consumable item name
exports('TreatWound', function(source, woundId, treatmentType, itemUsed)
    ProcessTreatment(source, woundId, treatmentType, itemUsed)
end)

--- Read-only query of the player's current physiological vitals
--- @param source number Player ID
--- @return table Table containing health, pulse, pain, bleeding, consciousness
exports('GetVitals', function(source)
    return GetPlayerVitals(source)
end)

--- Restores the player's health to maximum and clears adverse effects
--- (Must be protected by caller authentication)
--- @param source number Player ID
exports('FullHeal', function(source)
    local caller = GetInvokingResource() or 'unknown'
    print(("[fdb-medical-core] Audit: FullHeal triggered by '%s' for source %s"):format(caller, source))
    
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Calls negative ApplyDamage using FDBCore's MaxHealth
    local maxHealth = 600 -- Default value or dependent on core/ped
    -- We will use a safe workaround, like a very high heal to zero out damage, but we will also rewrite the vitals:
    if ResetPlayerVitals then
        ResetPlayerVitals(source)
    else
        ProcessDamage(source, 'Generic', 'Torso', -9999, caller)
    end
    -- Synchronize health with FDBCore/HUD (max 600)
    local PlayerData = FDBCore.Functions.GetPlayer(source)
    if PlayerData then
        PlayerData.Functions.SetMetaData('health', 600)
        -- REMOVED SetPlayerData('metadata', ...) - overwrites entire metadata (loss of hunger/thirst/etc)
    end
end)


RegisterNetEvent('fdb-medical-core:server:SetDead', function(isDead)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local currentlyDead = Player.PlayerData.metadata["isdead"] or false

    if isDead == currentlyDead then return end -- ignores redundant/repeated calls

    -- Extra reinforcement: only allows "revive" (isDead=false) if they were actually dead
    if isDead == false and not currentlyDead then
        print(("[fdb-medical-core] ALERTA: src %s tentou SetDead(false) sem estar morto!"):format(src))
        return
    end
    
    -- Uses the core interface to avoid being caught by the security lock
    -- that would prohibit clients from forcing this
    Player.Functions.SetMetaData("isdead", isDead)
end)

RegisterNetEvent('fdb-medical-core:server:FullRestore', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Only restores if the player was actually marked as dead
    if not Player.PlayerData.metadata["isdead"] then
        print(("[fdb-medical-core] ALERTA: src %s tentou forÃ§ar FullRestore sem estar morto!"):format(src))
        return
    end

    exports['fdb-survival']:AddHunger(src, 100)
    exports['fdb-survival']:AddThirst(src, 100)
    exports['fdb-survival']:AddCleanliness(src, 100)
end)

-- ============================================================
-- NETWORK EVENTS (Client -> Server)
-- ============================================================

RegisterNetEvent('fdb-medical-core:server:ReportDamage', function(bodyPart, damageType, reportedAmount)
    local src = source
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local vitals = GetPlayerVitals(src)
    local actualHp = GetEntityHealth(ped)
    local actualDelta = vitals.health - actualHp -- how much health actually dropped since last sync

    if actualDelta <= 0 then return end -- didn't actually lose health, ignore report

    -- Original Sanity Cap: uses the smallest between reported and actual, never blindly trusts reported
    local amount = math.min(reportedAmount, actualDelta)

    ProcessDamage(src, damageType, bodyPart, amount, 'fdb-medic:selfReport')
end)

RegisterNetEvent('fdb-medical-core:server:ProcessTreatment', function(woundId, treatmentType, itemUsed)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Validation: checks if the player actually has the item (if itemUsed was passed)
    if itemUsed and type(itemUsed) == 'string' then
        local hasItem = Player.Functions.GetItemByName(itemUsed)
        if not hasItem or hasItem.amount < 1 then
            print(("[fdb-medical-core] EXPLOIT BLOCK: src %s tentou usar %s sem possuir o item!"):format(src, itemUsed))
            return
        end
        -- Safely removes the item server-side
        Player.Functions.RemoveItem(itemUsed, 1)
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[itemUsed], 'remove', 1)
    end
    
    ProcessTreatment(src, woundId, treatmentType, itemUsed)
end)

RegisterNetEvent('fdb-medical-core:server:ConvertWoundToScar', function(bodyPart)
    local src = source
    local vitals = GetPlayerVitals(src)
    
    if vitals.wounds and vitals.wounds[bodyPart] then
        local wound = vitals.wounds[bodyPart]
        -- Only convert if it's currently treated and not bleeding
        if wound.treated and (wound.bleeding == 0 or wound.bleeding == nil) then
            wound.isScar = true
            wound.scarTime = os.time()
            wound.severity = 0
            wound.pain = 0
            wound.bleeding = 0
            
            print(("[fdb-medical-core] SCAR: src %s | %s converted to scar"):format(src, bodyPart))
            
            RecalculateVitals(src)
            SyncVitalsToStatebag(src)
        end
    end
end)

--- Export to provide the complete medical profile for MDT/Svelte (fdb-medic)
--- @param citizenid string
--- @return table
exports('GetCompleteMedicalProfile', function(citizenid)
    local Player = FDBCore.Functions.GetPlayerByCitizenId(citizenid)
    
    if Player then
        -- Online player: Returns real-time data
        local src = Player.PlayerData.source
        local vitals = GetPlayerVitals(src)
        return {
            wounds = vitals.wounds or {},
            treatments = vitals.treatments or {},
            infections = vitals.infections or {},
            bandages = vitals.bandages or {},
            scars = GetPlayerScars(citizenid) or {}
        }
    else
        -- Offline player: Loads from database (Only Wounds and Scars for now)
        return {
            wounds = LoadWoundData(citizenid) or {},
            treatments = {},
            infections = {},
            bandages = {},
            scars = GetPlayerScars(citizenid) or {}
        }
    end
end)


--- Clears all wounds in memory for a player
--- @param source number Player ID
exports('ClearAllWounds', function(source)
    if GetPlayerVitals and SyncVitalsToStatebag then
        local vitals = GetPlayerVitals(source)
        if vitals then
            vitals.wounds = {}
            SyncVitalsToStatebag(source)
        end
    end
end)
