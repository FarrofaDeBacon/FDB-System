local FDBCore = exports['fdb-core']:GetCoreObject()
local equippedWeight = 0

-- Export público para obter o modificador de velocidade atual
exports('GetBackpackWeightModifier', function()
    local stashId = LocalPlayer.state.currentBackpackStashId
    if not stashId then
        return 1.0
    end
    if equippedWeight <= 10000 then
        return 1.0
    elseif equippedWeight > 10000 and equippedWeight <= 20000 then
        return 0.85
    else
        return 0.70
    end
end)

-- Thread 1: Busca o peso atualizado da mochila no servidor periodicamente
CreateThread(function()
    while true do
        local sleep = 2000
        local stashId = LocalPlayer.state.currentBackpackStashId
        if stashId then
            local success, weight = pcall(function()
                return lib.callback.await('fdb-backpacks:server:getStashWeight', false, stashId)
            end)
            if success and weight then
                equippedWeight = weight
                -- print(("[Backpack Weight] Stash: %s | Peso Atual: %s g (%0.2f Kg)"):format(stashId, equippedWeight, equippedWeight / 1000))
            end
        else
            equippedWeight = 0
            sleep = 1000
        end
        Wait(sleep)
    end
end)

-- Thread 2 (Desativada): Movida para o Maestro (fdb-survival/client/movement.lua)
--[[
CreateThread(function()
    while true do
        local sleep = 1000
        local stashId = LocalPlayer.state.currentBackpackStashId
        if stashId and equippedWeight > 10000 then
            sleep = 0
            local ped = PlayerPedId()
            
            if equippedWeight > 20000 then
                DisableControlAction(0, 0x8FFC75D6, true) -- INPUT_SPRINT
                DisableControlAction(0, 0xE30CD707, true) -- INPUT_RUN
                SetPedMaxMoveBlendRatio(ped, 1.0)
                SetPedMoveRateOverride(ped, 0.75)
            else
                DisableControlAction(0, 0x8FFC75D6, true) 
                SetPedMaxMoveBlendRatio(ped, 2.0) 
                SetPedMoveRateOverride(ped, 0.85) 
            end
        end
        Wait(sleep)
    end
end)
]]
