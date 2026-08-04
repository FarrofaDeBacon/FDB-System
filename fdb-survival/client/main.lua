local FDBCore = exports['fdb-core']:GetCoreObject()

FDB = FDB or {}
FDB.IsLoggedIn = false
FDB.Survival = {
    bladder = 0,
    cleanliness = 100,
    poison = 0,
    illness = 0,
    coldResistance = 0,
    heatResistance = 0,
    drunkenness = 0
}

function FDB.BroadcastState(field, value)
    TriggerEvent('fdb-survival:client:stateChanged', { field = field, value = value })
end

RegisterNetEvent('fdb-survival:client:stateChanged', function(data)
    if data and data.field and FDB.Survival[data.field] ~= nil then
        FDB.Survival[data.field] = data.value
    end
end)

local function SyncLocalMetadata(isInit)
    local PlayerData = FDBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        if isInit then
            FDB.Survival.bladder = PlayerData.metadata["bladder"] or 0
            FDB.Survival.cleanliness = PlayerData.metadata["cleanliness"] or 100
            FDB.Survival.poison = PlayerData.metadata["poison"] or 0
            FDB.Survival.illness = PlayerData.metadata["illness"] or 0
        else
            -- Durante o jogo, não deixamos o server sobrescrever o progresso local (que pode estar até 16s na frente)
            -- Qualquer alteração forçada pelo servidor (ex: comandos de admin) deve usar o evento explícito 'stateChanged'
        end
    end
end

RegisterNetEvent('FDBCore:Client:OnPlayerLoaded', function()
    FDB.IsLoggedIn = true
    SyncLocalMetadata(true)
    
    local PlayerData = FDBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        LocalPlayer.state:set('isWet', PlayerData.metadata["isWet"] or false, true)
    end
end)

RegisterNetEvent('fdb-survival:client:ForceClean', function()
    FDB.Survival.cleanliness = 100
    FDB.BroadcastState('cleanliness', 100)
end)

RegisterNetEvent('fdb-survival:client:AddThirst', function(val)
    FDB.Survival.thirst = val
    FDB.BroadcastState('thirst', val)
end)

RegisterNetEvent('FDBCore:Client:OnPlayerLogout', function()
    FDB.IsLoggedIn = false
end)

RegisterNetEvent('FDBCore:Client:OnPlayerInfoUpdate', function(data)
    SyncLocalMetadata()
end)

RegisterNetEvent('FDBCore:Player:SetPlayerData', function(val)
    SyncLocalMetadata()
end)

CreateThread(function()
    Wait(1000)
    if not FDB.IsLoggedIn then
        local data = FDBCore.Functions.GetPlayerData()
        if data and data.citizenid then
            FDB.IsLoggedIn = true
            SyncLocalMetadata(true)
        end
    end
end)

-- =======================================================
-- LOOP PRINCIPAL (4s)
-- =======================================================
CreateThread(function()
    local syncTimer = 0
    while true do
        Wait(Config.DrainRates.TickRate)
        if FDB.IsLoggedIn then
            local ped = PlayerPedId()
            
            -- Dreno de Higiene Gradual e por Clima/Terreno
            local cleanlinessDrain = Config.DrainRates.Cleanliness
            if GetRainLevel() > 0.1 then
                cleanlinessDrain = cleanlinessDrain * Config.DrainRates.WeatherMultipliers.Rain
            end
            
            local currentHealth = GetEntityHealth(ped)
            if not FDB.Survival.lastHealth then FDB.Survival.lastHealth = currentHealth end
            
            if currentHealth < FDB.Survival.lastHealth then
                cleanlinessDrain = cleanlinessDrain + Config.DrainRates.HygieneEvents.BloodDamage
            end
            FDB.Survival.lastHealth = currentHealth
            
            if IsPedRagdoll(ped) or IsPedFalling(ped) then
                cleanlinessDrain = cleanlinessDrain + Config.DrainRates.HygieneEvents.FallMud
            end
            
            

            local oldCleanliness = FDB.Survival.cleanliness
            FDB.Survival.cleanliness = math.max(0, math.min(100, FDB.Survival.cleanliness - cleanlinessDrain))
            if math.floor(FDB.Survival.cleanliness) ~= math.floor(oldCleanliness) then
                FDB.BroadcastState('cleanliness', math.floor(FDB.Survival.cleanliness))
            end

            -- Aumento de Bexiga
            local bladderDrain = Config.DrainRates.Bladder
            local oldBladder = FDB.Survival.bladder
            FDB.Survival.bladder = math.min(100, FDB.Survival.bladder + bladderDrain)
            if math.floor(FDB.Survival.bladder) ~= math.floor(oldBladder) then
                FDB.BroadcastState('bladder', math.floor(FDB.Survival.bladder))
            end

            -- Dano por Veneno de Cobra Contínuo (Nativo)
            local isPoisoned = Citizen.InvokeNative(0x137772C61AEC7E11, ped)
            if isPoisoned then
                if GetEntityHealth(ped) > 0 and not IsEntityDead(ped) then
                    TriggerServerEvent('fdb-survival:server:reportHazardDamage', 'Poison', Config.Hazards.PoisonDamage)
                end
            end

            -- Termorregulação (Dano em Temperatura Extrema)
            local coords = GetEntityCoords(ped)
            Citizen.InvokeNative(0xB98B78C3768AF6E0, true)
            local temp = GetTemperatureAtCoords(coords.x, coords.y, coords.z)
            
            -- Envia temp para o HUD
            FDB.BroadcastState('temp', math.floor(temp))
            
            local hasThermalProtection = false
            if temp < Config.Hazards.ExtremeColdThreshold and (FDB.Survival.coldResistance > 0 and not LocalPlayer.state.isWet) then
                hasThermalProtection = true
            elseif temp > Config.Hazards.ExtremeHeatThreshold and FDB.Survival.heatResistance > 0 then
                hasThermalProtection = true
            end
            
            if (temp < Config.Hazards.ExtremeColdThreshold or temp > Config.Hazards.ExtremeHeatThreshold) and not hasThermalProtection then
                -- No health damage purely for being wet, only temperature damage
                if GetEntityHealth(ped) > 0 and not IsEntityDead(ped) then
                    local damageType = (temp < Config.Hazards.ExtremeColdThreshold) and 'Cold' or 'Heat'
                    TriggerServerEvent('fdb-survival:server:reportHazardDamage', damageType, Config.Hazards.TemperatureDamage)
                end
                
                local illnessMultiplier = LocalPlayer.state.isWet and 3 or 1
                if temp < Config.Hazards.ExtremeColdThreshold and math.random(1, 100) <= (Config.Hazards.IllnessChancePercent * illnessMultiplier) then
                    local oldIllness = FDB.Survival.illness
                    FDB.Survival.illness = math.min(100, FDB.Survival.illness + Config.Hazards.IllnessGain)
                    if math.floor(FDB.Survival.illness) ~= math.floor(oldIllness) then
                        FDB.BroadcastState('illness', math.floor(FDB.Survival.illness))
                    end
                end
            end
            
            -- Efeitos de doença agora são processados exclusivamente pelo fdb-survival/client/illness.lua

            -- Salvar no banco a cada 16s (4 ticks)
            syncTimer = syncTimer + (Config.DrainRates.TickRate / 1000)
            if syncTimer >= 16 then
                syncTimer = 0
                -- Em fdb-survival, atualizamos apenas as vars q dominamos
                TriggerServerEvent('fdb-survival:server:SaveMeta', 'cleanliness', math.floor(FDB.Survival.cleanliness))
                TriggerServerEvent('fdb-survival:server:SaveMeta', 'bladder', math.floor(FDB.Survival.bladder))
                TriggerServerEvent('fdb-survival:server:SaveMeta', 'poison', math.floor(FDB.Survival.poison))
                TriggerServerEvent('fdb-survival:server:SaveMeta', 'illness', math.floor(FDB.Survival.illness))
            end
        end
    end
end)

-- =======================================================
-- LOOP DE STAMINA (Velocidade e Movimento)
-- =======================================================


CreateThread(function()
    while true do
        local sleep = 0
        if FDB.IsLoggedIn then
            local ped = PlayerPedId()
            local stamina = Citizen.InvokeNative(0x36731AC041289BB1, ped, 1) -- GetAttributeCoreValue for Stamina
            
            sleep = 500
        else
            sleep = 1000
        end
        Wait(sleep)
    end
end)
