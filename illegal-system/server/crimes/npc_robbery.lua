--[[
    Roubo de NPC — Etapa 2. Primeiro crime jogável, serve pra validar o
    fluxo inteiro do Crime Core ponta a ponta.

    O client só pede a tentativa (RegisterNetEvent abaixo) depois de tocar
    a animação/minigame local — mas o resultado que importa (dinheiro, xp,
    heat) vem inteiramente da resposta do servidor.
]]

local activeRobberies = {}

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

    local lootConfig = Config.Crimes['npc_robbery'].loot
    local items = {
        common = lootConfig.common[math.random(#lootConfig.common)],
        uncommon = lootConfig.uncommon[math.random(#lootConfig.uncommon)],
        rare = lootConfig.rare[math.random(#lootConfig.rare)]
    }

    activeRobberies[source] = items

    -- Manda o client iniciar a UI do minigame com os itens selecionados
    TriggerClientEvent('illegal-system:client:startNpcRobberyMinigame', source, {
        items = items,
        images = {
            common = Config.InventoryURL .. items.common .. '.png',
            uncommon = Config.InventoryURL .. items.uncommon .. '.png',
            rare = Config.InventoryURL .. items.rare .. '.png'
        }
    })
end)

RegisterNetEvent('illegal-system:server:finishNpcRobbery', function(success, tier)
    local source = source
    local activeItems = activeRobberies[source]

    if not activeItems then return end
    activeRobberies[source] = nil -- limpa cache para evitar exploit

    local rewardItem = nil
    if success and tier and activeItems[tier] then
        rewardItem = activeItems[tier]
    else
        success = false
    end

    local result = CrimeCore.FinishCrime(source, 'npc_robbery', success, rewardItem)

    if result.success then
        Bridge.Notify(source, 'Você conseguiu roubar um item!', 'success')
    else
        Bridge.Notify(source, 'A vítima percebeu e você não conseguiu nada.', 'error')
    end

    if result.witnessGenerated then
        print(('[illegal-system] Testemunha gerada para roubo de NPC (source %s)'):format(source))
    end
end)
