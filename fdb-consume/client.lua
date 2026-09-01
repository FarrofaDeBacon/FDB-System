local FDBCore = exports['fdb-core']:GetCoreObject()


local isBusy = false

-- SISTEMA DE AUTO-LIMPEZA E PROTEÇÃO
Citizen.CreateThread(function()
    Wait(1000)
    DoScreenFadeIn(1000)
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    AnimpostfxStopAll()
    Citizen.InvokeNative(0x406CCF555B097893, ped, false)
    Citizen.InvokeNative(0x06D26A96CA1BCA75, ped) -- ResetPedMovementClipset
end)

-- Evento de Consumir
RegisterNetEvent('fdb-consume:client:playAnim', function(itemName)
    if isBusy then 
        lib.notify({ title = locale('notify_busy'), type = 'error' })
        return 
    end
    
    local itemData = Config.Items[itemName]
    if not itemData then return end

    local animType = itemData.type
    local baseAnim = Config.Animations[animType] or {}

    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    
    local ped = PlayerPedId()
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`)

    local propModel = itemData.prop or baseAnim.prop
    local maxUses = itemData.uses or baseAnim.uses or 3
    local animDict = itemData.dict or baseAnim.dict
    local animName = itemData.name or baseAnim.name

    -- Remoção dos Triggers Fantasmas (Fase 2)
    -- O fdb-consume/server.lua já removeu o item e atualizou o banco ANTES de chamar essa animação.

    -- Limpa qualquer item que o player estivesse segurando antes (evita misturar garrafa de água com pão)
    TriggerEvent('fdb-consume:client:StopInteractiveConsumable')

    -- Roteador de Animações
    if animType == "Drink" or animType == "Coffee" then
        TriggerEvent('fdb-consume:client:ConsumeDrink', propModel, animType, maxUses, animDict, animName, itemName)
    elseif animType == "Stew" or animType == "Eat" or animType == "Canned" then
        TriggerEvent('fdb-consume:client:ConsumeFood', propModel, animType, maxUses, animDict, animName, itemName)
    elseif animType == "Medical" or animType == "Drug" then
        TriggerEvent('fdb-consume:client:ConsumeMedical', propModel, animType, maxUses, animDict, animName, itemName)
    elseif animType == "Chew" then
        TriggerEvent('fdb-consume:client:Chew', propModel, animDict, animName, itemName)
    elseif animType == "Smoke" then
        TriggerEvent('fdb-consume:prop:cigaret', propModel, maxUses, animDict, animName, itemName)
    elseif animType == "Cigar" then
        TriggerEvent('fdb-consume:prop:cigar', maxUses, animDict, animName)
    else
        print("^1[fdb-consume] ERRO: Tipo de animacao desconhecido: " .. tostring(animType) .. "^7")
    end
    
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
end)

-- Aplicar Health e Stamina do item consumível
-- health: valor relativo (-100 a +100) — soma sobre a saúde atual do ped
-- stamina: valor relativo — restaura fôlego do jogador (0 a 100)
RegisterNetEvent('fdb-consume:client:applyStamina', function(staminaDelta)
    if staminaDelta ~= 0 then
        local currentStamina = GetPlayerStamina(PlayerId())
        local targetPct = math.max(0, math.min(100, currentStamina + staminaDelta))
        -- Restaura o stamina do cavalo ou do player usando native
        Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 1, staminaDelta)
    end
end)
