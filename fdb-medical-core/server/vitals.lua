-- ============================================================
-- fdb-medical | server/vitals.lua
-- Tabela de estado de vitais server-authoritative por jogador
-- ============================================================

local FDBCore = exports["fdb-core"]:GetCoreObject()

PlayerVitals = {}

--- Retorna a tabela de vitais de um jogador (ou inicializa se não existir)
--- @param src number Player ID
--- @return table
function GetPlayerVitals(src)
    if not PlayerVitals[src] then
        PlayerVitals[src] = {
            health = Config.Vitals.MaxHealth,
            pulse = Config.Vitals.DefaultPulse,
            pain = Config.Vitals.DefaultPain,
            bleeding = Config.Vitals.DefaultBleeding,
            consciousness = Config.Vitals.DefaultConsciousness,
            wounds = {}
        }
    end
    return PlayerVitals[src]
end

--- Atualiza a Statebag `medical` do ped do jogador e a metadata oficial
--- @param src number
function SyncVitalsToStatebag(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local vitals = GetPlayerVitals(src)
    Entity(ped).state:set('medical', {
        health = vitals.health,
        pulse = vitals.pulse,
        pain = vitals.pain,
        bleeding = vitals.bleeding,
        consciousness = vitals.consciousness,
        wounds = vitals.wounds or {}
    }, true)
    
    -- Sincroniza metadata oficial do framework para compatibilidade com rsg-spawn, HUDs, etc.
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData('health', vitals.health)
    end
end

function ResetPlayerVitals(src)
    local vitals = GetPlayerVitals(src)
    vitals.health = Config.Vitals.MaxHealth or 600
    vitals.pulse = Config.Vitals.DefaultPulse or 89
    vitals.pain = Config.Vitals.DefaultPain or 0
    vitals.bleeding = Config.Vitals.DefaultBleeding or 0
    vitals.consciousness = Config.Vitals.DefaultConsciousness or 100
    vitals.wounds = {}
    SyncVitalsToStatebag(src)
    -- Garante health no FDBCore metadata
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData('health', vitals.health)
    end
end

--- Salva vitais do jogador no banco de dados ativamente
function SavePlayerVitalsToDB(src, Player)
    Player = Player or FDBCore.Functions.GetPlayer(src)
    local vitals = PlayerVitals[src]
    if vitals and Player and Player.PlayerData and Player.PlayerData.citizenid then
        local citizenid = Player.PlayerData.citizenid
        SaveWoundData(citizenid, vitals.wounds)
    end
end

--- Evento de carregamento do jogador no framework
RegisterNetEvent('FDBCore:Server:PlayerLoaded', function(Player)
    if not Player then return end
    local src = Player.PlayerData.source
    local citizenid = Player.PlayerData.citizenid
    
    -- Garante a inicialização da tabela segura
    local vitals = GetPlayerVitals(src)
    
    -- Puxar a vida (health) e vitais persistidos do banco de dados (salvos na metadata)
    if Player.PlayerData.metadata then
        if Player.PlayerData.metadata["health"] then
            vitals.health = Player.PlayerData.metadata["health"]
        end
        if Player.PlayerData.metadata["pulse"] then vitals.pulse = Player.PlayerData.metadata["pulse"] end
        if Player.PlayerData.metadata["pain"] then vitals.pain = Player.PlayerData.metadata["pain"] end
        if Player.PlayerData.metadata["bleeding"] then vitals.bleeding = Player.PlayerData.metadata["bleeding"] end
        if Player.PlayerData.metadata["consciousness"] then vitals.consciousness = Player.PlayerData.metadata["consciousness"] end
    end
    
    -- Carrega feridas do banco (se existirem)
    local dbWounds = LoadWoundData(citizenid)
    if dbWounds and next(dbWounds) ~= nil then
        vitals.wounds = dbWounds
        print("^2[fdb-medical-core] Loaded wounds for citizenid " .. citizenid .. "^7")
    end
    
    SyncVitalsToStatebag(src)
end)

--- Salvamento Redundante no Drop (Framework)
RegisterNetEvent('FDBCore:Server:PlayerDropped', function(Player)
    if not Player then return end
    local src = Player.PlayerData.source
    SavePlayerVitalsToDB(src, Player)
end)

--- Limpeza ao desconectar (Nativo - Gatilho Infalível)
AddEventHandler('playerDropped', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if Player then
        SavePlayerVitalsToDB(src, Player)
    end
    PlayerVitals[src] = nil
end)
