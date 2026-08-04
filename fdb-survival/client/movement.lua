-- fdb-survival/client/movement.lua
-- ÚNICO responsável por clipset de movimento e por SetPedMoveRateOverride.
-- Nenhum outro arquivo deve chamar esses natives diretamente.

local currentClipset = nil
local baseClipset = nil

-- ==========================================
-- THREAD 1: CLIPSET (Executa a cada 500ms)
-- ==========================================
local function ResolveClipset()
    local drunkenness = FDB.Survival.drunkenness or 0
    local bladder = FDB.Survival.bladder or 0
    local illness = FDB.Survival.illness or 0
    local poison = FDB.Survival.poison or 0
    if drunkenness >= 80 then
        return 'move_m@drunk@verydrunk'
    elseif drunkenness >= 50 then
        return 'move_m@drunk@moderatedrunk'
    elseif drunkenness >= Config.Alcohol.DrunkThreshold then
        return 'move_m@drunk@a'
    elseif poison >= Config.Biological.ModerateThreshold then
        return 'move_m@drunk@moderatedrunk'
    elseif illness >= Config.Biological.SevereThreshold then
        return 'move_m@fatigue'
    elseif illness >= Config.Biological.ModerateThreshold then
        return 'move_m@drunk@slightlydrunk'
    elseif bladder >= 80 then
        return 'war_veteran'
    elseif FDB.Survival.inMud then
        return 'move_m@mud_wade'
    end
    return baseClipset -- volta ao estilo preferido pelo jogador ou nil (padrão do jogo)
end

CreateThread(function()
    while true do
        Wait(500)

        if FDB.IsLoggedIn then
            local ped = PlayerPedId()
            local targetClipset = ResolveClipset()
            
            if targetClipset ~= currentClipset then
                if targetClipset then
                    -- Solicita o clipset apenas na primeira vez
                    RequestClipSet(targetClipset)
                    local timer = 0
                    while not HasClipSetLoaded(targetClipset) and timer < 100 do
                        Wait(10)
                        timer = timer + 1
                    end
                    if HasClipSetLoaded(targetClipset) then
                        SetPedMovementClipset(ped, targetClipset, true)
                    end
                else
                    Citizen.InvokeNative(0x58F7DB5BD8FA2288, ped) -- ClearPedMovementClipset
                end
                currentClipset = targetClipset
            end
        end
    end
end)

-- ==========================================
-- THREAD 2: VELOCIDADE E CONTROLES (Wait 0)
-- ==========================================
FDB.Survival.moveRateModifiers = FDB.Survival.moveRateModifiers or {}

RegisterNetEvent('fdb-survival:client:SetMoveRateModifier', function(key, rate)
    if rate == nil or rate >= 1.0 then
        FDB.Survival.moveRateModifiers[key] = nil -- remove, sem penalidade
    else
        FDB.Survival.moveRateModifiers[key] = rate
    end
end)

-- Sistema de voto de sprint disable (qualquer resource pode votar)
-- Uso: TriggerEvent('fdb-survival:client:SetSprintDisable', 'fracture_torso', true/false)
FDB.Survival.sprintDisableVotes = FDB.Survival.sprintDisableVotes or {}
FDB.Survival.disableSprintFracture = false

RegisterNetEvent('fdb-survival:client:SetSprintDisable')
AddEventHandler('fdb-survival:client:SetSprintDisable', function(key, active)
    if active then
        FDB.Survival.sprintDisableVotes[key] = true
    else
        FDB.Survival.sprintDisableVotes[key] = nil
    end
    -- Qualquer voto ativo = sprint desabilitado
    FDB.Survival.disableSprintFracture = (next(FDB.Survival.sprintDisableVotes) ~= nil)
    print('[fdb-survival] Sprint disable votes: ' .. tostring(FDB.Survival.disableSprintFracture) .. ' (key: ' .. tostring(key) .. ' = ' .. tostring(active) .. ')')
end)

local function ResolveMoveRate(baseRate)
    local rates = { baseRate }
    for _, rate in pairs(FDB.Survival.moveRateModifiers) do
        table.insert(rates, rate)
    end
    return math.min(table.unpack(rates))
end

-- ==========================================
CreateThread(function()
    while true do
        local sleep = 500
        if FDB.IsLoggedIn then
            sleep = 0
            local ped = PlayerPedId()

            if LocalPlayer.state.isBathingActive then
                goto continue
            end
            
            -- 1. STAMINA
            local stamina = Citizen.InvokeNative(0x36731AC041289BB1, ped, 1) -- GetAttributeCoreValue for Stamina
            local staminaPercent = 100
            if stamina then
                staminaPercent = (stamina <= 1.0) and (stamina * 100) or stamina
            end
            
            local finalRate = 1.0
            local blendRatio = 3.0
            local disableSprintStamina = false
            local disableRunStamina = false
            if staminaPercent < 10 then
                disableSprintStamina = true
                disableRunStamina = true
                finalRate = 0.5
                blendRatio = 1.0
            elseif staminaPercent < 30 then
                disableSprintStamina = true
                finalRate = 0.8
            end

            -- 2.2 MOCHILA (BACKPACK)
            local disableSprintBackpack = false
            local disableRunBackpack = false
            if GetResourceState('fdb-backpacks') == 'started' then
                local mod = exports['fdb-backpacks']:GetBackpackWeightModifier()
                if mod == 0.70 then -- Peso > 20kg
                    disableSprintBackpack = true
                    disableRunBackpack = true
                    blendRatio = 1.0
                    finalRate = finalRate * 0.75
                elseif mod == 0.85 then -- Peso entre 10kg e 20kg
                    disableSprintBackpack = true
                    blendRatio = 2.0
                    finalRate = finalRate * 0.85
                end
            end

            -- 2.3 SUJEIRA EXTREMA (MAU CHEIRO)
            local cleanliness = FDB.Survival.cleanliness or 100
            if cleanliness < 20 then
                -- Se estiver muito sujo, a velocidade de movimento cai levemente, simulando cansaço extra
                finalRate = finalRate * 0.95
            end
            
            -- 2.5 DRUNKENNESS (Álcool)
            local drunkenness = FDB.Survival.drunkenness or 0
            local disableSprintDrunk = false
            local disableRunDrunk = false
            if drunkenness >= 80 then
                disableSprintDrunk = true
                disableRunDrunk = true
            elseif drunkenness >= 50 then
                disableSprintDrunk = true
            end
            
            -- 3. BEXIGA
            local bladder = FDB.Survival.bladder or 0
            local disableSprintBladder = false
            local disableJumpBladder = false
            if bladder >= 80 then
                disableSprintBladder = true
                disableJumpBladder = true
            end
            
            -- 3.5 DOENÇA E VENENO
            local illness = FDB.Survival.illness or 0
            local poison = FDB.Survival.poison or 0
            local disableSprintIllness = false
            local disableRunIllness = false
            if illness >= Config.Biological.SevereThreshold or poison >= Config.Biological.SevereThreshold then
                disableSprintIllness = true
                disableRunIllness = true
            elseif poison >= Config.Biological.ModerateThreshold or illness >= Config.Biological.ModerateThreshold then
                disableSprintIllness = true
            end
            
            -- 3.8 FRATURAS NO TORSO (flag local setada via evento de fdb-medical-core)
            local disableSprintFracture = FDB.Survival.disableSprintFracture or false
            
            -- 4. RESOLVER CONTROLES
            if disableSprintStamina or disableSprintBackpack or disableSprintBladder or disableSprintDrunk or disableSprintIllness or disableSprintFracture then
                DisableControlAction(0, 0x8FFC75D6, true) -- INPUT_SPRINT
            end
            if disableRunStamina or disableRunBackpack or disableRunDrunk or disableRunIllness then
                DisableControlAction(0, 0xE30CD707, true) -- INPUT_RUN
            end
            if disableJumpBladder then
                DisableControlAction(0, 0xD9D0E16C, true) -- INPUT_JUMP
            end
            
            -- 5. RESOLVER ANIMAÇÃO BASE (Blend Ratio)
            SetPedMaxMoveBlendRatio(ped, blendRatio)
            
            -- 6. RESOLVER VELOCIDADE DE MOVIMENTO (SetPedMoveRateOverride)
            local resolvedRate = ResolveMoveRate(finalRate)
            Citizen.InvokeNative(0x082B1D45D8C4EEBD, ped, resolvedRate) -- SetPedMoveRateOverride

            ::continue::
        end
        Wait(sleep)
    end
end)

-- ==========================================
-- THREAD 3: EVENTOS DE PREFERÊNCIA
-- ==========================================
RegisterNetEvent('fdb-survival:client:setWalkstyle', function(style)
    if style == 'default' or style == 'normal' then
        baseClipset = nil
    else
        baseClipset = style
    end
    -- Força a reavaliação imediata
    currentClipset = nil
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    baseClipset = nil
    currentClipset = nil
    FDB.Survival.moveRateModifiers = {}
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    baseClipset = nil
    currentClipset = nil
    FDB.Survival.moveRateModifiers = {}
end)

-- Reset ao trocar de personagem / respawnar
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    currentClipset = nil
end)
