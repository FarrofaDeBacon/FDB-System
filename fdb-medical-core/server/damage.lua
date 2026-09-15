-- ============================================================
-- FDB System | fdb-medical-core | server/damage.lua
-- ============================================================

-- ============================================================
-- fdb-medical | server/damage.lua
-- ÃšNICO ponto de escrita para dano e saÃºde no servidor
-- ============================================================

local FDBCore = exports["fdb-core"]:GetCoreObject()

--- Aplica dano ou alteraÃ§Ã£o de vida server-side no ped de um jogador
--- @param src number ID do jogador
--- @param damageType string Tipo de dano (DamageType enum)
--- @param bodyPart string|nil Parte do corpo atingida (BodyPart enum)
--- @param amount number Quantidade de dano (positivo para dano, negativo para cura)
--- @param originResource string|nil Nome do recurso que originou o dano
function ProcessDamage(src, damageType, bodyPart, amount, originResource)
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local vitals = GetPlayerVitals(src)
    originResource = originResource or GetInvokingResource() or 'unknown'
    bodyPart = bodyPart or BodyPart.TORSO

    -- Log de auditoria server-side (Desativado para nÃ£o floodar o console)
    -- print(string.format(
    --     locale('log_damage_applied'),
    --     tostring(src), tostring(originResource), tostring(damageType), tostring(bodyPart), tostring(amount)
    -- ))

    -- Ajuste de SaÃºde
    -- Usa vitals.health como base para nÃ£o duplicar o dano (jÃ¡ que currentHp jÃ¡ pode estar menor pelo motor do jogo)
    local maxHp = Config.Vitals.MaxHealth or 600
    local newHp = math.max(0, math.min(maxHp, math.floor(vitals.health - amount)))

    -- Aplica nativamente via Server (Ãšnico local do projeto!)
    TriggerClientEvent('fdb-medical-core:client:setHealth', src, newHp)

    -- Atualiza os vitais fisiolÃ³gicos
    vitals.health = newHp
    if amount > 0 then
        -- Dano aumenta pulso diretamente (pulso nÃ£o Ã© puramente dependente de wound)
        vitals.pulse = math.min(Config.Vitals.MaxPulse, vitals.pulse + math.floor(amount * 0.3))
        
        if damageType == DamageType.Gunshot or damageType == DamageType.Melee or damageType == DamageType.Animal then
            RegisterWound(src, bodyPart, damageType, amount)
            -- RegisterWound jÃ¡ chama RecalculateVitals() internamente
        else
            -- Para danos genÃ©ricos (queimadura, queda leve), apenas atualizamos agregados
            -- Se precisarmos de dor base nÃ£o-relacionada a wounds no futuro, 
            -- implementaremos vitals.basePain. Por enquanto, a fonte de verdade
            -- de pain/bleeding Ã© sempre RecalculateVitals via wounds.
            RecalculateVitals(src)
        end
    else
        RecalculateVitals(src)
    end

    SyncVitalsToStatebag(src)
end

--- Aplica um tratamento a um ferimento do jogador
--- @param src number ID do jogador
--- @param woundId string|nil ID ou tipo do ferimento (na prÃ¡tica, o bodyPart)
--- @param treatmentType string Tipo do tratamento (bandagem, antÃ­doto, cirurgia)
--- @param itemUsed string Nome do item usado
function ProcessTreatment(src, woundId, treatmentType, itemUsed)
    local vitals = GetPlayerVitals(src)
    print(string.format(
        locale('log_treatment_applied'),
        tostring(src), tostring(itemUsed or 'none'), tostring(treatmentType)
    ))

    local bodyPart = woundId
    if bodyPart and vitals.wounds and vitals.wounds[bodyPart] then
        local wound = vitals.wounds[bodyPart]
        
        if treatmentType == 'bandage' or treatmentType == 'heal' then
            wound.treated = true
            wound.bleeding = 0
            
            if treatmentType == 'heal' then
                wound.severity = 0
                wound.pain = 0
                wound.infectionStage = 0
                wound.infected = false
            end
        elseif treatmentType == 'antidote' then
            wound.infectionStage = 0
            wound.infected = false
        elseif treatmentType == 'splint' and wound.boneDamage then
            local range = Config.Fractures.HealDaysGame[bodyPart] or {min=15, max=22}
            local days = math.random(range.min, range.max)
            wound.healUntil = GetGameMinutes() + (days * 1440)
        end
    end

    RecalculateVitals(src)
    SyncVitalsToStatebag(src)
end

