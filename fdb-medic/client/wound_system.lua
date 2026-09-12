-- =========================================================
-- FDB-MEDIC - WOUND SYSTEM (Phase C refactor)
-- =========================================================
-- This file handles core wound detection.
-- All progression, ballistics, and health logic have been moved
-- to the server (fdb-medical-core).
-- =========================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local LastDamageTime = 0
local DAMAGE_COOLDOWN = 1000
local PlayerHealth = nil
local LastKnownWeaponHash = nil

AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        print(string.format('[DEBUG] CEventNetworkEntityDamage fired! victim: %s, PlayerPed: %s', tostring(victim), tostring(PlayerPedId())))
        
        if victim == PlayerPedId() then
            print('[DEBUG CEventNetworkEntityDamage] args completos:')
            for i, v in ipairs(args) do
                print(('  [%d] = %s'):format(i, tostring(v)))
            end
            -- Still capture it for now so testing works if it is 7, but we are primarily debugging
            LastKnownWeaponHash = args[7] 
        end
    end
end)

Config = Config or {}
Config.Bones = {
    [0] = 'NONE',

    -- HEAD (união das duas fontes)
    [21030] = 'HEAD', [21031] = 'HEAD', [27981] = 'HEAD', [57278] = 'HEAD', [54890] = 'HEAD',

    -- NECK (união das duas fontes)
    [14283] = 'NECK', [24015] = 'NECK', [52596] = 'NECK', [32630] = 'NECK',
    [32631] = 'NECK', [32632] = 'NECK', [14284] = 'NECK', [14285] = 'NECK',

    -- SPINE (inclui pélvis, ver conflito 56200 acima)
    [14410] = 'SPINE', [14411] = 'SPINE', [14412] = 'SPINE', [14413] = 'SPINE',
    [14414] = 'SPINE', [11569] = 'SPINE', [56200] = 'SPINE',

    -- TORSO genérico (não confirmado por nenhuma fonte, fallback)
    [23553] = 'TORSO', [64729] = 'TORSO',

    -- LARM (inclui clavícula esquerda, ver conflito 30226 acima)
    [37873] = 'LARM', [53675] = 'LARM', [30226] = 'LARM',
    [43700] = 'LARM', [24238] = 'LARM', [55540] = 'LARM', [53562] = 'LARM',

    -- LHAND (mão + dedos, união das duas fontes)
    [34606] = 'LHAND',
    [41403] = 'LHAND', [41404] = 'LHAND', [41405] = 'LHAND',
    [41323] = 'LHAND', [41324] = 'LHAND', [41325] = 'LHAND', [41326] = 'LHAND',
    [41307] = 'LHAND', [41308] = 'LHAND', [41309] = 'LHAND', [41310] = 'LHAND',
    [41355] = 'LHAND', [41356] = 'LHAND', [41357] = 'LHAND', [41358] = 'LHAND',
    [41339] = 'LHAND', [41340] = 'LHAND', [41341] = 'LHAND', [41342] = 'LHAND',
    [35940] = 'LHAND', [43154] = 'LHAND', [60440] = 'LHAND', [35924] = 'LHAND',
    [35908] = 'LHAND', [35892] = 'LHAND', [35876] = 'LHAND', [55214] = 'LHAND',
    [55198] = 'LHAND', [55246] = 'LHAND', [55230] = 'LHAND',

    -- LLEG (união das duas fontes — a segunda tinha bem mais IDs)
    [65478] = 'LLEG', [55120] = 'LLEG', [40091] = 'LLEG', [52390] = 'LLEG',
    [65480] = 'LLEG', [21174] = 'LLEG', [49844] = 'LLEG', [38229] = 'LLEG',
    [51618] = 'LLEG', [17816] = 'LLEG', [21124] = 'LLEG', [12785] = 'LLEG',
    [881] = 'LLEG', [65034] = 'LLEG', [62433] = 'LLEG', [8936] = 'LLEG',
    [2474] = 'LLEG', [8980] = 'LLEG', [55253] = 'LLEG', [15681] = 'LLEG',
    [12865] = 'LLEG', [3003] = 'LLEG',

    -- LFOOT
    [45454] = 'LFOOT', [53081] = 'LFOOT',

    -- RARM
    [46065] = 'RARM', [54187] = 'RARM', [54802] = 'RARM',
    [46260] = 'RARM', [65198] = 'RARM', [31186] = 'RARM',

    -- RHAND (mão + dedos)
    [22798] = 'RHAND',
    [16827] = 'RHAND', [16828] = 'RHAND', [16829] = 'RHAND',
    [16747] = 'RHAND', [16748] = 'RHAND', [16749] = 'RHAND', [16750] = 'RHAND',
    [16731] = 'RHAND', [16732] = 'RHAND', [16733] = 'RHAND', [16734] = 'RHAND',
    [16779] = 'RHAND', [16780] = 'RHAND', [16781] = 'RHAND', [16782] = 'RHAND',
    [16763] = 'RHAND', [16764] = 'RHAND', [16765] = 'RHAND', [16766] = 'RHAND',
    [11364] = 'RHAND', [41618] = 'RHAND', [14992] = 'RHAND', [11348] = 'RHAND',
    [11332] = 'RHAND', [11316] = 'RHAND', [11300] = 'RHAND', [61341] = 'RHAND',
    [61325] = 'RHAND', [61373] = 'RHAND', [61357] = 'RHAND', [36407] = 'RHAND',

    -- RLEG
    [6884] = 'RLEG', [43312] = 'RLEG', [64298] = 'RLEG', [27814] = 'RLEG',
    [65384] = 'RLEG', [19638] = 'RLEG', [6170] = 'RLEG', [17720] = 'RLEG',
    [22660] = 'RLEG', [10571] = 'RLEG', [64874] = 'RLEG', [30131] = 'RLEG',
    [46712] = 'RLEG', [53296] = 'RLEG', [14866] = 'RLEG', [31046] = 'RLEG',
    [11991] = 'RLEG', [10651] = 'RLEG', [5217] = 'RLEG',

    -- RFOOT
    [33646] = 'RFOOT', [41273] = 'RFOOT',
}

local function GetBodyPartFromBone(boneId)
    -- DEBUG TEMPORARIO PRA IDENTIFICAR 23553 E 64729
    if boneId == 23553 or boneId == 64729 then
        print("HIT BONE NO DEBUG: ", boneId)
    end
    return Config.Bones[boneId] or 'TORSO'
end

local function GetWeaponDamageTypeEnum(weaponHash)
    if Config and Config.WeaponDamage and Config.WeaponDamage[weaponHash] then
        local st = Config.WeaponDamage[weaponHash].status
        if st == 'bullet' or st == 'pellets' or st == 'shrapnel' then return 'gunshot' end
        if st == 'deep_cut' or st == 'embedded_hatchet' or st == 'bruise' or st == 'arrow' then return 'melee' end
        if st == 'claw_marks' then return 'animal' end
    end
    
    -- Use Citizen.InvokeNative since GetWeaponDamageType wrapper may not exist in RedM
    local typeInt = Citizen.InvokeNative(0x3BE0BB12D25FB305, weaponHash, Citizen.ResultAsInteger())
    if typeInt == 3 then
        return 'gunshot'
    elseif typeInt == 2 or typeInt == 1 then
        return 'melee'
    elseif typeInt == 5 or typeInt == 4 or typeInt == 11 then
        return 'fire'
    elseif typeInt == 6 or typeInt == 10 then
        return 'fall'
    end
    
    -- Fallback for animal attacks/claws which sometimes register as melee or unarmed
    print(string.format("[DEBUG fdb-medic] GetWeaponDamageTypeEnum returned unknown typeInt %s for hash %s", tostring(typeInt), tostring(weaponHash)))
    return 'animal'
end

CreateThread(function()
    repeat Wait(1000) until LocalPlayer.state['isLoggedIn']
    
    print("^2[fdb-medic] Wound detection loop running^7")
    
    while true do
        local ok, err = pcall(function()
            local ped = PlayerPedId()
            local currentTime = GetGameTimer()
            
            if not PlayerHealth then
                PlayerHealth = GetEntityHealth(ped)
            end
            
            local currentHealth = GetEntityHealth(ped)
            
            if currentHealth < PlayerHealth and (currentTime - LastDamageTime > DAMAGE_COOLDOWN) then
                LastDamageTime = currentTime
                
                local amount = PlayerHealth - currentHealth
                local hit, boneId = GetPedLastDamageBone(ped)
                
                print(string.format("[DEBUG fdb-medic] Health dropped! Amount: %d, HitBone: %s, BoneID: %s", amount, tostring(hit), tostring(boneId)))
                
                local weaponHash = LastKnownWeaponHash
                LastKnownWeaponHash = nil -- Consome e limpa, evita vazar para dano futuro
                
                -- Fallback para PvE (NPCs) onde o evento de rede não dispara
                if not weaponHash then
                    local causeHash = GetPedCauseOfDeath(ped)
                    if causeHash and causeHash ~= 0 and causeHash ~= GetHashKey("WEAPON_UNARMED") then
                        weaponHash = causeHash
                    else
                        -- Mini-heurística O(N) otimizada APENAS para o exato frame do dano
                        local peds = GetGamePool('CPed')
                        local playerCoords = GetEntityCoords(ped)
                        for _, otherPed in ipairs(peds) do
                            if otherPed ~= ped and not IsEntityDead(otherPed) then
                                local dist = #(playerCoords - GetEntityCoords(otherPed))
                                if dist < 60.0 and IsPedInCombat(otherPed, ped) then
                                    local hasWeapon, currentWeapon = GetCurrentPedWeapon(otherPed, true)
                                    if hasWeapon and currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
                                        weaponHash = currentWeapon
                                        print("[DEBUG fdb-medic] Mini-heuristic found PvE weapon: " .. tostring(weaponHash))
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                weaponHash = weaponHash or GetHashKey("WEAPON_UNARMED")
                
                local bodyPart = hit and GetBodyPartFromBone(boneId) or 'Torso'
                local damageType = GetWeaponDamageTypeEnum(weaponHash)
                
                print(string.format("[fdb-medic] Detected damage: %d on %s (Type: %s)", amount, bodyPart, damageType))
                
                TriggerServerEvent('fdb-medical-core:server:ReportDamage', bodyPart, damageType, amount)
                if hit then
                    ClearPedLastDamageBone(ped) -- Clean up after processing
                end
                
                PlayerHealth = currentHealth
            elseif currentHealth > PlayerHealth then
                -- Healed via other means
                PlayerHealth = currentHealth
            end
        end)

        if not ok then
            print("^1[fdb-medic] ERRO na thread de detecção: " .. tostring(err) .. "^7")
        end
        
        Wait(200)
    end
end)

-- Reseta a saúde base após ser revivido ou carregar o personagem para evitar dano fantasma de dessincronização
local function ResetBaselineHealth()
    Wait(2000) -- Aguarda a engine estabilizar a vida após o revive
    local ped = PlayerPedId()
    PlayerHealth = GetEntityHealth(ped)
    ClearPedLastDamageBone(ped)
    print("[DEBUG fdb-medic] PlayerHealth baseline reset after revive/load to: " .. tostring(PlayerHealth))
end

RegisterNetEvent('fdb-medic:client:adminRevive', ResetBaselineHealth)
RegisterNetEvent('fdb-medic:client:playerRevive', ResetBaselineHealth)
RegisterNetEvent('fdb-medic:client:revive', ResetBaselineHealth)
RegisterNetEvent('FDBCore:Client:OnPlayerLoaded', ResetBaselineHealth)

