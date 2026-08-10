--[[
    Crime Core — Etapa 1.

    Regra de ouro: TODA decisão de sucesso/falha, recompensa e efeito colateral
    (heat, xp, testemunha, evidência) é resolvida AQUI, no servidor. O client
    nunca envia "eu consegui" — ele pede "quero tentar", e o servidor decide.
]]

CrimeCore = {}

local playerCooldowns = {} -- [citizenid][crimeId] = timestamp de liberação
local playerCriminalCache = {} -- [citizenid] = { xp, heat, reputation } (espelho em memória, fonte de verdade é o banco)

-- ─────────────────────────────────────────────────────────
-- Helpers internos
-- ─────────────────────────────────────────────────────────

local function GetCrimeConfig(crimeId)
    local crime = Config.Crimes[crimeId]
    if not crime then
        error(('[illegal-system] Crime "%s" não existe em Config.Crimes'):format(crimeId), 2)
    end
    return crime
end

local function IsOnCooldown(citizenid, crimeId)
    local playerCd = playerCooldowns[citizenid]
    if not playerCd or not playerCd[crimeId] then return false end
    return playerCd[crimeId] > Utils.Now()
end

local function SetCooldown(citizenid, crimeId, seconds)
    playerCooldowns[citizenid] = playerCooldowns[citizenid] or {}
    playerCooldowns[citizenid][crimeId] = Utils.Now() + seconds
end

local function GetCriminalLevel(xp)
    local level = 1
    for _, tier in ipairs(Config.CriminalLevels) do
        if xp >= tier.xp then level = tier.level end
    end
    return level
end

--- Carrega (ou cria) o registro criminal do jogador. Cache em memória +
--- upsert no banco. Chamado sob demanda, não em polling.
local function EnsureCriminalRecord(citizenid)
    if playerCriminalCache[citizenid] then
        return playerCriminalCache[citizenid]
    end

    local row = MySQL.single.await(
        'SELECT xp, heat, reputation FROM player_criminal WHERE citizenid = ?',
        { citizenid }
    )

    if not row then
        MySQL.insert.await(
            'INSERT INTO player_criminal (citizenid, xp, heat, reputation) VALUES (?, 0, 0, 0)',
            { citizenid }
        )
        row = { xp = 0, heat = 0, reputation = 0 }
    end

    playerCriminalCache[citizenid] = row
    return row
end

local function PersistCriminalRecord(citizenid)
    local record = playerCriminalCache[citizenid]
    if not record then return end
    MySQL.update(
        'UPDATE player_criminal SET xp = ?, heat = ?, reputation = ? WHERE citizenid = ?',
        { record.xp, record.heat, record.reputation, citizenid }
    )
end

--- Registra o crime no histórico. Nunca guarda o "nome" do jogador junto do
--- crime pro sistema de polícia poder consumir só a descrição/testemunha
--- (ver ROADMAP Etapa 7) — a ligação citizenid -> crime fica isolada aqui,
--- só pra dossiê do próprio jogador e pra investigação policial resolver depois.
local function LogCrimeHistory(citizenid, crimeId, success, rewardGiven, witnessGenerated, evidenceGenerated)
    MySQL.insert(
        [[INSERT INTO crime_history
            (citizenid, crime_id, success, reward, witness, evidence, created_at)
          VALUES (?, ?, ?, ?, ?, ?, NOW())]],
        { citizenid, crimeId, success, rewardGiven, witnessGenerated, evidenceGenerated }
    )
end

-- ─────────────────────────────────────────────────────────
-- Hooks de testemunha/evidência.
-- Hoje só fazem o roll e retornam boolean. Etapa 6/7 vão expandir
-- isso pra gerar de fato a entidade de evidência no mundo e o
-- payload de descrição pra polícia — a assinatura da função não
-- deve precisar mudar quando isso acontecer.
-- ─────────────────────────────────────────────────────────

local function RollWitness(crime)
    return Utils.RollChance(crime.witnessChance)
end

local function RollEvidence(crime)
    return Utils.RollChance(crime.evidenceChance)
end

-- ─────────────────────────────────────────────────────────
-- API pública do Crime Core
-- ─────────────────────────────────────────────────────────

--- Tenta executar um crime pra um jogador. Retorna uma tabela de resultado
--- pro chamador (ex: server/crimes/npc_robbery.lua) decidir o que mostrar
--- na tela do client. Nunca confia em nada vindo do client além do
--- crimeId e do source.
function CrimeCore.AttemptCrime(source, crimeId)
    local crime = GetCrimeConfig(crimeId)
    local citizenid = Bridge.GetIdentifier(source)

    if not citizenid then
        return { ok = false, reason = 'no_player' }
    end

    if IsOnCooldown(citizenid, crimeId) then
        return { ok = false, reason = 'cooldown' }
    end

    local record = EnsureCriminalRecord(citizenid)

    local success = Utils.RollChance(crime.successChance)
    local witnessGenerated = RollWitness(crime)
    local evidenceGenerated = RollEvidence(crime)
    local rewardGiven = 0

    if success then
        rewardGiven = Utils.RandomBetween(crime.rewardMin, crime.rewardMax)
        Bridge.AddMoney(source, rewardGiven, ('crime:%s'):format(crimeId))

        record.xp = record.xp + crime.xp
        record.heat = math.min(Config.Heat.max, record.heat + crime.heat)
    else
        -- falha ainda gera heat (menor) e pode gerar testemunha/evidência —
        -- tentar e falhar não é de graça
        record.heat = math.min(Config.Heat.max, record.heat + math.floor(crime.heat / 2))
    end

    PersistCriminalRecord(citizenid)
    SetCooldown(citizenid, crimeId, crime.cooldown)
    LogCrimeHistory(citizenid, crimeId, success, rewardGiven, witnessGenerated, evidenceGenerated)

    return {
        ok               = true,
        success          = success,
        reward           = rewardGiven,
        witnessGenerated = witnessGenerated,
        evidenceGenerated= evidenceGenerated,
        newLevel         = GetCriminalLevel(record.xp),
    }
end

function CrimeCore.GetCriminalStatus(source)
    local citizenid = Bridge.GetIdentifier(source)
    if not citizenid then return nil end
    local record = EnsureCriminalRecord(citizenid)
    return {
        xp         = record.xp,
        heat       = record.heat,
        reputation = record.reputation,
        level      = GetCriminalLevel(record.xp),
    }
end

-- ─────────────────────────────────────────────────────────
-- Decaimento de Heat (Fase 3)
-- ─────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        Wait(Config.Heat.decayInterval)
        for citizenid, record in pairs(playerCriminalCache) do
            if record.heat > 0 then
                record.heat = math.max(0, record.heat - Config.Heat.decayAmount)
                PersistCriminalRecord(citizenid)
            end
        end
    end
end)

exports('AttemptCrime', CrimeCore.AttemptCrime)
exports('GetCriminalStatus', CrimeCore.GetCriminalStatus)
