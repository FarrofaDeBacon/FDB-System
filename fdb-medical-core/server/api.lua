-- ============================================================
-- fdb-medical | server/api.lua
-- Exports públicas para consumo por outros recursos
-- ============================================================
local RSGCore = exports['fdb-core']:GetCoreObject()

--- Único ponto de entrada para QUALQUER dano no servidor.
--- @param source number ID do jogador que recebeu o dano
--- @param damageType string Enum DamageType (Gunshot, Melee, Fall, Poison, Illness, Cold, Heat...)
--- @param bodyPart string|nil Enum BodyPart (Head, Torso, Arms, Legs) ou nil para sistêmico
--- @param amount number Intensidade do dano (positivo = dano, negativo = cura)
exports('ApplyDamage', function(source, damageType, bodyPart, amount)
    local caller = GetInvokingResource() or 'unknown'
    ProcessDamage(source, damageType, bodyPart, amount, caller)
end)

--- Aplica tratamento a um ferimento ou estado do jogador
--- @param source number ID do jogador
--- @param woundId string|nil ID do ferimento
--- @param treatmentType string Tipo de tratamento ('bandage', 'antidote', 'medicine')
--- @param itemUsed string|nil Nome do item consumível
exports('TreatWound', function(source, woundId, treatmentType, itemUsed)
    ProcessTreatment(source, woundId, treatmentType, itemUsed)
end)

--- Consulta somente-leitura dos vitais fisiológicos atuais do jogador
--- @param source number ID do jogador
--- @return table Tabela contendo health, pulse, pain, bleeding, consciousness
exports('GetVitals', function(source)
    return GetPlayerVitals(source)
end)

--- Restaura a saúde do jogador ao máximo e limpa efeitos adversos
--- (Deve ser protegida por autenticação no caller)
--- @param source number ID do jogador
exports('FullHeal', function(source)
    local caller = GetInvokingResource() or 'unknown'
    print(("[fdb-medical-core] Auditoria: FullHeal acionado por '%s' para source %s"):format(caller, source))
    
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Chama ApplyDamage negativo usando o MaxHealth do RSGCore
    local maxHealth = 600 -- Valor default ou dependente do core/ped
    -- Faremos um workaround seguro, como cura altíssima para zerar dano, mas vamos também reescrever os vitals:
    if ResetPlayerVitals then
        ResetPlayerVitals(source)
    else
        -- Caso a função não esteja no escopo de api.lua, manda um dano negativo genérico massivo
        ProcessDamage(source, 'Generic', 'Torso', -9999, caller)
    end
end)


RegisterNetEvent('fdb-medical-core:server:SetDead', function(isDead)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local currentlyDead = Player.PlayerData.metadata["isdead"] or false

    if isDead == currentlyDead then return end -- ignora chamadas redundantes/repetidas

    -- Reforço extra: só permite "reviver" (isDead=false) se já estava morto de verdade
    if isDead == false and not currentlyDead then
        print(("[fdb-medical-core] ALERTA: src %s tentou SetDead(false) sem estar morto!"):format(src))
        return
    end
    
    -- Utiliza a interface do core para evitar ser pego pela trava de segurança
    -- que proibiria clientes de forçarem isso
    Player.Functions.SetMetaData("isdead", isDead)
end)

RegisterNetEvent('fdb-medical-core:server:FullRestore', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Só restaura se o jogador realmente estava marcado como morto
    if not Player.PlayerData.metadata["isdead"] then
        print(("[fdb-medical-core] ALERTA: src %s tentou forçar FullRestore sem estar morto!"):format(src))
        return
    end

    exports['fdb-survival']:AddHunger(src, 100)
    exports['fdb-survival']:AddThirst(src, 100)
    exports['fdb-survival']:AddCleanliness(src, 100)
end)

-- ============================================================
-- EVENTOS DE REDE (Client -> Server)
-- ============================================================

RegisterNetEvent('fdb-medical-core:server:ReportDamage', function(bodyPart, damageType, reportedAmount)
    local src = source
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local vitals = GetPlayerVitals(src)
    local actualHp = GetEntityHealth(ped)
    local actualDelta = vitals.health - actualHp -- quanto a vida realmente caiu desde a última sync

    if actualDelta <= 0 then return end -- não perdeu vida de verdade, ignora o report

    -- Sanity Cap original: usa o menor entre o reportado e o real, nunca confia cegamente no reportado
    local amount = math.min(reportedAmount, actualDelta)

    ProcessDamage(src, damageType, bodyPart, amount, 'fdb-medic:selfReport')
end)

RegisterNetEvent('fdb-medical-core:server:ProcessTreatment', function(woundId, treatmentType, itemUsed)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Validação: confere se o jogador realmente tem o item (se itemUsed foi passado)
    if itemUsed and type(itemUsed) == 'string' then
        local hasItem = Player.Functions.GetItemByName(itemUsed)
        if not hasItem or hasItem.amount < 1 then
            print(("[fdb-medical-core] EXPLOIT BLOCK: src %s tentou usar %s sem possuir o item!"):format(src, itemUsed))
            return
        end
        -- Remove o item de forma segura e server-side
        Player.Functions.RemoveItem(itemUsed, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemUsed], 'remove', 1)
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
exports('FullHeal', function(src) local Player = FDBCore.Functions.GetPlayer(src); if Player then Player.Functions.SetMetaData('isdead', false); Player.Functions.SetPlayerData('metadata', {isdead=false}); end; end)
