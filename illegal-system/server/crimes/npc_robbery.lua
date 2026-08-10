--[[
    Roubo de NPC — Etapa 2. Primeiro crime jogável, serve pra validar o
    fluxo inteiro do Crime Core ponta a ponta.

    O client só pede a tentativa (RegisterNetEvent abaixo) depois de tocar
    a animação/minigame local — mas o resultado que importa (dinheiro, xp,
    heat) vem inteiramente da resposta do servidor.
]]

RegisterNetEvent('illegal-system:server:attemptNpcRobbery', function()
    local source = source
    local result = CrimeCore.AttemptCrime(source, 'npc_robbery')

    if not result.ok then
        if result.reason == 'cooldown' then
            Bridge.Notify(source, 'Espere um pouco antes de tentar de novo.', 'error')
        else
            Bridge.Notify(source, 'Não foi possível concluir a ação.', 'error')
        end
        return
    end

    if result.success then
        Bridge.Notify(source, ('Você conseguiu $%d.'):format(result.reward), 'success')
    else
        Bridge.Notify(source, 'A vítima percebeu e você não conseguiu nada.', 'error')
    end

    if result.witnessGenerated then
        -- Etapa 7 vai substituir isso por um evento real pro sistema de
        -- polícia consumir (descrição, não identidade)
        print(('[illegal-system] Testemunha gerada para roubo de NPC (source %s)'):format(source))
    end

    TriggerClientEvent('illegal-system:client:npcRobberyResult', source, result)
end)
