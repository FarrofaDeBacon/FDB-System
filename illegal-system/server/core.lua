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
--- @param rewardType string 'item' | 'cash' — tipo de recompensa
--- @param rewardValue string nome do item ou valor em dinheiro (como string)
local function LogCrimeHistory(citizenid, crimeId, success, rewardType, rewardValue, witnessGenerated, evidenceGenerated)
    MySQL.insert(
        [[INSERT INTO crime_history
            (citizenid, crime_id, success, reward_type, reward_value, witness, evidence, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, NOW())]],
        { citizenid, crimeId, success, rewardType or 'item', rewardValue or '', witnessGenerated, evidenceGenerated }
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

    -- Aplica o cooldown imediatamente para não spammar minigames
    SetCooldown(citizenid, crimeId, crime.cooldown)

    return { ok = true }
end

--- Finaliza o crime baseado no resultado do minigame do client
function CrimeCore.FinishCrime(source, crimeId, success, rewardItem)
    local crime = GetCrimeConfig(crimeId)
    local citizenid = Bridge.GetIdentifier(source)

    if not citizenid then return false end

    local record = EnsureCriminalRecord(citizenid)

    local witnessGenerated = RollWitness(crime)
    local evidenceGenerated = RollEvidence(crime)
    local rewardType = 'item'
    local rewardValue = ''

    if success then
        if rewardItem then
            Bridge.AddItem(source, rewardItem, 1)
            rewardValue = rewardItem
            Bridge.Notify(source, "Você roubou 1x " .. rewardItem .. "!", "success")
        end
        record.xp = record.xp + crime.xp
        record.heat = math.min(Config.Heat.max, record.heat + crime.heat)
    else
        record.heat = math.min(Config.Heat.max, record.heat + math.floor(crime.heat / 2))
    end

    PersistCriminalRecord(citizenid)
    LogCrimeHistory(citizenid, crimeId, success, rewardType, rewardValue, witnessGenerated, evidenceGenerated)

    return {
        success          = success,
        reward           = rewardValue,
        witnessGenerated = witnessGenerated,
        evidenceGenerated= evidenceGenerated,
        newLevel         = GetCriminalLevel(record.xp),
    }
end

--- Expõe a capacidade de logar o crime no histórico para fluxos que dão
--- recompensas customizadas (ex: dinheiro no burglary)
function CrimeCore.LogCrimeEvent(source, crimeId, success, rewardType, rewardValue, witnessGenerated, evidenceGenerated)
    local citizenid = Bridge.GetIdentifier(source)
    if not citizenid then return end
    LogCrimeHistory(citizenid, crimeId, success, rewardType, rewardValue, witnessGenerated, evidenceGenerated)
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
exports('FinishCrime', CrimeCore.FinishCrime)
exports('GetCriminalStatus', CrimeCore.GetCriminalStatus)
exports('LogCrimeEvent', CrimeCore.LogCrimeEvent)
