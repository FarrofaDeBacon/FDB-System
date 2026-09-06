-- ============================================================
-- fdb-hudpremium | client/main.lua
-- Inicialização, loop principal (Lua-3)
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
local nuiReady = false
local hudForceHidden = false
local KVP_KEY = "fdb-hudpremium:settings"

-- Cache de status para otimização e redução de spam de tráfego NUI
local lastStatus = {
    health = -1, stamina = -1,
    armor = -1, oxygen = -1, isTalking = false, voiceRange = -1,
    isMounted = false, horseHealth = -1, horseStamina = -1
}

-- Helper para normalizar valores entre 0 e 100
local function GetNormalized(current, max)
    if max == 0 then return 0 end
    return math.max(0, math.min(100, math.floor((current / max) * 100)))
end

-- -------------------------------------------------------
-- Ocultação de Núcleos e HUD Nativo do RDR2
-- -------------------------------------------------------
CreateThread(function()
    while true do
        Wait(1000)
        -- Esconde ícones e núcleos nativos do jogador (Health, Stamina, DeadEye)
        for i = 0, 5 do
            Citizen.InvokeNative(0xC116E6DF68DCE667, i, 2) -- _UITUTORIAL_SET_RPG_ICON_VISIBILITY (2 = Always Hide)
        end
        -- Esconde núcleos nativos do cavalo (Health, Stamina, Courage)
        for i = 6, 11 do
            Citizen.InvokeNative(0xC116E6DF68DCE667, i, 2)
        end
    end
end)

-- -------------------------------------------------------
-- Persistência de Posições (KVP)
-- -------------------------------------------------------
local function LoadSettings()
    local savedSettings = GetResourceKvpString(KVP_KEY)
    if savedSettings then
        local decoded = json.decode(savedSettings)
        if decoded then
            SendNUIMessage({
                action = "loadSettings",
                positions = decoded.positions,
                configs = decoded.configs,
                global = decoded.global,
                colors = decoded.colors, -- Fallback legado
                scales = decoded.scales   -- Fallback legado
            })
            print(locale('hud_settings_loaded'))
        end
    end
end

-- -------------------------------------------------------
-- Eventos do Framework (FDBCore)
-- -------------------------------------------------------
AddEventHandler('FDBCore:Client:OnPlayerLoaded', function()
    PlayerData = FDBCore.Functions.GetPlayerData()
    isLoggedIn = true
    LoadSettings()
    if not hudForceHidden then
        SendNUIMessage({ action = 'setVisibility', value = true })
    end
end)

AddEventHandler('FDBCore:Client:OnPlayerLogout', function()
    PlayerData = {}
    isLoggedIn = false
    SendNUIMessage({ action = 'setVisibility', value = false })
end)

local function SyncMetadata()
    if not PlayerData or not PlayerData.metadata then return end
    if nuiReady and not hudForceHidden then
        local hunger      = PlayerData.metadata["hunger"]      or 100
        local thirst      = PlayerData.metadata["thirst"]      or 100
        local stress      = PlayerData.metadata["stress"]      or 0
        local bladder     = PlayerData.metadata["bladder"]     or 0
        local cleanliness = PlayerData.metadata["cleanliness"] or 100
        local illness     = PlayerData.metadata["illness"]     or 0
        local poison      = PlayerData.metadata["poison"]      or 0
        local alcohol     = PlayerData.metadata["alcohol"]     or 0

        SendNUIMessage({ action = 'food',        value = hunger      })
        SendNUIMessage({ action = 'water',       value = thirst      })
        SendNUIMessage({ action = 'stress',      value = stress      })
        SendNUIMessage({ action = 'bladder',     value = bladder     })
        SendNUIMessage({ action = 'cleanliness', value = cleanliness })
        SendNUIMessage({ action = 'illness',     value = illness     })
        SendNUIMessage({ action = 'poison',      value = poison      })
        SendNUIMessage({ action = 'drunkenness', value = alcohol     })
    end
end

RegisterNetEvent('FDBCore:Client:OnPlayerInfoUpdate', function(data)
    PlayerData = FDBCore.Functions.GetPlayerData()
    SyncMetadata()
end)

RegisterNetEvent('FDBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    SyncMetadata()
end)

-- -------------------------------------------------------
-- Callbacks NUI
-- -------------------------------------------------------
RegisterNUICallback("uiReady", function(data, cb)
    nuiReady = true
    LoadSettings()
    if isLoggedIn and not hudForceHidden then
        SendNUIMessage({ action = 'setVisibility', value = true })
    end
    cb("ok")
end)

RegisterNUICallback("saveSettings", function(data, cb)
    if data then
        local encoded = json.encode(data)
        SetResourceKvp(KVP_KEY, encoded)
        print("[fdb-hudpremium] Configurações de layout salvas com sucesso.")
    end
    cb("ok")
end)

RegisterNUICallback("closeEditor", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

-- -------------------------------------------------------
-- Loop de Coleta de Ticks Básicos (500ms) - Vida e Fôlego
-- -------------------------------------------------------
CreateThread(function()
    local firstTick = true
    while true do
        Wait(500)
        
        if isLoggedIn and nuiReady and not hudForceHidden then
            local ped = PlayerPedId()
            
            -- Saúde do jogador (Tank + Core combinados em 0-100 para a UI)
            local currentHealth = GetEntityHealth(ped)
            -- Saúde do jogador (Fisiologia fdb-medical-core + Fallback de ped)
            local medState = Entity(ped).state.medical
            
            if firstTick then
                print("[fdb-hudpremium] FIRST TICK MEDICAL STATE: " .. (medState and json.encode(medState) or "NIL"))
                firstTick = false
            end

            local health = 0
            if medState and medState.health ~= nil then
                local maxHp = GetEntityMaxHealth(ped)
                health = GetNormalized(medState.health - 100, maxHp - 100)
            else
                local maxHealth = GetEntityMaxHealth(ped)
                local healthTank = GetNormalized(currentHealth - 100, maxHealth - 100)
                local healthCore = Citizen.InvokeNative(0x36731AC041289BB1, ped, 0)
                if not tonumber(healthCore) then healthCore = 0 end
                healthCore = (healthCore <= 1.0) and (healthCore * 100) or healthCore
                health = math.floor((healthTank / 2) + (healthCore / 2))
            end
            
            -- Fôlego (Stamina) do jogador
            local rawStamina = GetPlayerStamina(PlayerId())
            
            -- Native de mount silenciado
            local testStaminaPoints = Citizen.InvokeNative(0x0FF421E467373FCF, ped, Citizen.ResultAsFloat())
            
            local staminaTank = math.max(0, math.min(100, math.floor(rawStamina)))
            local staminaCore = Citizen.InvokeNative(0x36731AC041289BB1, ped, 1)
            
            -- Stamina debug silenced to reduce console noise

            if not tonumber(staminaCore) then staminaCore = 0 end
            staminaCore = (staminaCore <= 1.0) and (staminaCore * 100) or staminaCore
            local stamina = math.floor((staminaTank / 2) + (staminaCore / 2))
            
            -- Armadura (RedM não usa colete GTA)
            local rawArmor = 0
            local armor = 0
            
            -- Oxigênio
            local oxygen = 100
            if IsPedSwimmingUnderWater(ped) then
                local rawOxygen = Citizen.InvokeNative(0x7E3F55ED251B76D3, PlayerId(), Citizen.ResultAsFloat())
                oxygen = GetNormalized(rawOxygen, Config.Vitals.MaxOxygen)
            end
            
            -- Sistema de Voz (pma-voice / RedM)
            local isTalking = false
            if MumbleIsPlayerTalking then
                isTalking = MumbleIsPlayerTalking(PlayerId())
            elseif NetworkIsPlayerTalking then
                isTalking = NetworkIsPlayerTalking(PlayerId())
            end
            local voiceRange = LocalPlayer.state.proximity and LocalPlayer.state.proximity.distance or 2.5
            
            -- Cavalo (Mount)
            local mount = GetMount(ped)
            local isMounted = false
            local horseHealth = 0
            local horseStamina = 0
            local horseDirtTier = 'clean'
            local horseAgitationTier = 'calm'
            local horseIsExhausted = false
            
            if mount and mount ~= 0 then
                isMounted = true
                local hHealthTank = GetNormalized(GetEntityHealth(mount), GetEntityMaxHealth(mount))
                local hHealthCore = Citizen.InvokeNative(0x36731AC041289BB1, mount, 0)
                if not tonumber(hHealthCore) then hHealthCore = 0 end
                hHealthCore = (hHealthCore <= 1.0) and (hHealthCore * 100) or hHealthCore
                horseHealth = math.floor((hHealthTank / 2) + (hHealthCore / 2))

                local maxHorseStamina = Citizen.InvokeNative(0xCB42AFE2B613EE55, mount, Citizen.ResultAsFloat()) or 100.0
                local currentHorseStamina = Citizen.InvokeNative(0x775A1CA7893AA8B5, mount, Citizen.ResultAsFloat()) or 100.0
                local hStaminaTank = math.max(0, math.min(100, math.floor((currentHorseStamina / maxHorseStamina) * 100)))
                local hStaminaCore = Citizen.InvokeNative(0x36731AC041289BB1, mount, 1)
                if not tonumber(hStaminaCore) then hStaminaCore = 0 end
                hStaminaCore = (hStaminaCore <= 1.0) and (hStaminaCore * 100) or hStaminaCore
                horseStamina = math.floor((hStaminaTank / 2) + (hStaminaCore / 2))

                -- Leitura das Statebags do Servidor (Fase C)
                local mState = Entity(mount).state
                horseDirtTier = mState.dirtTier or 'clean'
                horseAgitationTier = mState.agitationTier or 'calm'
                horseIsExhausted = mState.isExhausted or false
            end
            
            -- Envia apenas atualizações reativas de alta prioridade se algum valor mudou
            if health ~= lastStatus.health then
                lastStatus.health = health
                SendNUIMessage({ action = 'health', value = health })
            end
            if stamina ~= lastStatus.stamina then
                lastStatus.stamina = stamina
                SendNUIMessage({ action = 'stamina', value = stamina })
            end
            if armor ~= lastStatus.armor then
                lastStatus.armor = armor
                SendNUIMessage({ action = 'armor', value = armor })
            end
            if oxygen ~= lastStatus.oxygen then
                lastStatus.oxygen = oxygen
                SendNUIMessage({ action = 'oxygen', value = oxygen })
            end
            if isTalking ~= lastStatus.isTalking then
                lastStatus.isTalking = isTalking
                SendNUIMessage({ action = 'isTalking', value = isTalking })
            end
            if voiceRange ~= lastStatus.voiceRange then
                lastStatus.voiceRange = voiceRange
                SendNUIMessage({ action = 'voice', value = voiceRange })
            end
            
            -- Sincronização da Montaria (Reset Explícito ao desmontar)
            if isMounted ~= lastStatus.isMounted 
               or horseHealth ~= lastStatus.horseHealth 
               or horseStamina ~= lastStatus.horseStamina 
               or horseDirtTier ~= lastStatus.horseDirtTier 
               or horseAgitationTier ~= lastStatus.horseAgitationTier 
               or horseIsExhausted ~= lastStatus.horseIsExhausted then

                lastStatus.isMounted = isMounted
                lastStatus.horseHealth = horseHealth
                lastStatus.horseStamina = horseStamina
                lastStatus.horseDirtTier = horseDirtTier
                lastStatus.horseAgitationTier = horseAgitationTier
                lastStatus.horseIsExhausted = horseIsExhausted
                
                if isMounted then
                    SendNUIMessage({ 
                        action = 'horseHealth', 
                        value = horseHealth,
                        dirtTier = horseDirtTier,
                        agitationTier = horseAgitationTier,
                        isExhausted = horseIsExhausted
                    })
                    SendNUIMessage({ 
                        action = 'horseStamina', 
                        value = horseStamina,
                        dirtTier = horseDirtTier,
                        agitationTier = horseAgitationTier,
                        isExhausted = horseIsExhausted
                    })
                    SendNUIMessage({
                        action = 'horseState',
                        dirtTier = horseDirtTier,
                        agitationTier = horseAgitationTier,
                        isExhausted = horseIsExhausted
                    })
                else
                    -- Reset explícito a 0 para esconder da UI
                    SendNUIMessage({ action = 'horseHealth', value = 0 })
                    SendNUIMessage({ action = 'horseStamina', value = 0 })
                    SendNUIMessage({ action = 'horseState', dirtTier = 'clean', agitationTier = 'calm', isExhausted = false })
                end
            end
        end
    end
end)

-- -------------------------------------------------------
-- Receptor de Alterações de Estado (Consume / Survival)
-- -------------------------------------------------------
RegisterNetEvent('fdb-survival:client:stateChanged', function(data)
    if not nuiReady then return end
    SendNUIMessage({ action = data.field, value = data.value })
end)

-- -------------------------------------------------------
-- Recurso reiniciado com jogador já na sessão (Restart)
-- -------------------------------------------------------
CreateThread(function()
    Wait(1000)
    if not isLoggedIn then
        local data = FDBCore.Functions.GetPlayerData()
        if data and data.citizenid then
            PlayerData = data
            isLoggedIn = true
            LoadSettings()
            if not hudForceHidden then
                SendNUIMessage({ action = 'setVisibility', value = true })
            end
        end
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local data = FDBCore.Functions.GetPlayerData()
        if data and data.citizenid then
            PlayerData = data
            isLoggedIn = true
            LoadSettings()
            if not hudForceHidden then
                SendNUIMessage({ action = 'setVisibility', value = true })
            end
            SyncMetadata()
        end
    end
end)

RegisterCommand("hud", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "toggleEditor",
        value = true
    })
end, false)

-- -------------------------------------------------------
-- Toggle HUD visibility from external scripts (e.g. fdb-creator)
-- When visible=false, sets hudForceHidden to block all auto-show
-- When visible=true, clears the block and re-shows
-- -------------------------------------------------------
RegisterNetEvent('fdb-hudpremium:client:toggleHud', function(visible)
    hudForceHidden = not visible
    SendNUIMessage({ action = 'setVisibility', value = visible })
    if visible then
        isLoggedIn = true
    end
end)
