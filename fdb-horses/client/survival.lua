local FDBCore = exports['fdb-core']:GetCoreObject()

FDB = FDB or {}
FDB.HorseSurvival = {
    hunger     = 100,
    thirst     = 100,
    dirt       = 0,
    illness    = 0,
    poison     = 0,
    agitation  = 0
}

local activeHorsePed = 0

-- ============================================================
-- ÚNICO LISTENER QUE ESCREVE EM FDB.HorseSurvival
-- Disparado exclusivamente pelo servidor via TriggerClientEvent.
-- Nenhum outro bloco neste arquivo (e em nenhum outro arquivo client/)
-- escreve nesta tabela. O loop local só lê para aplicar efeitos visuais.
-- ============================================================
RegisterNetEvent('fdb-horses:client:stateChanged', function(data)
    if not data then return end
    for field, value in pairs(data) do
        if FDB.HorseSurvival[field] ~= nil then
            FDB.HorseSurvival[field] = value
        end
    end
end)

-- ============================================================
-- Vincula / desvincula o cavalo ativo ao receber spawn/despawn
-- Ambos disparados pelo client.lua (SpawnHorse / horsePed = 0)
-- ============================================================
RegisterNetEvent('fdb-horses:client:ApplySurvivalData', function(horse, metadata)
    activeHorsePed = horse
    if metadata then
        for field, _ in pairs(FDB.HorseSurvival) do
            FDB.HorseSurvival[field] = metadata[field] or FDB.HorseSurvival[field]
        end
    else
        FDB.HorseSurvival = { hunger = 100, thirst = 100, dirt = 0, illness = 0, poison = 0, agitation = 0 }
    end
    -- Aplica sujeira visual do valor salvo
    if activeHorsePed and activeHorsePed ~= 0 then
        Citizen.InvokeNative(0x5DA12E025D47D4E5, activeHorsePed, 16, math.floor(FDB.HorseSurvival.dirt))
    end
    -- Informa ao servidor o networkId do ped para que ele possa escrever statebags
    local netId = NetworkGetNetworkIdFromEntity(horse)
    TriggerServerEvent('fdb-horses:server:RegisterHorseNet', netId)
end)

RegisterNetEvent('fdb-horses:client:ClearSurvivalData', function()
    activeHorsePed = 0
    TriggerServerEvent('fdb-horses:server:UnregisterHorseNet')
end)

-- ============================================================
-- Funções de leitura pública (somente leitura — sem escrita)
-- Outros arquivos chamam isso em vez de acessar FDB.HorseSurvival diretamente
-- ============================================================
function GetHorseSurvival(field)
    if field then return FDB.HorseSurvival[field] end
    return FDB.HorseSurvival
end

function GetActiveHorsePed()
    return activeHorsePed
end

-- ============================================================
-- Loop de EFEITOS VISUAIS (só lê FDB.HorseSurvival, nunca escreve)
-- O servidor envia stateChanged → o único listener atualiza a tabela
-- Este loop aplica as consequências visuais desses valores no ped
-- ============================================================
CreateThread(function()
    while true do
        Wait(Config.Metabolism.DrainInterval)
        if activeHorsePed ~= 0 and DoesEntityExist(activeHorsePed) and not IsEntityDead(activeHorsePed) then

            -- Aplica sujeira visual conforme o valor recebido do servidor
            local currentDirt = FDB.HorseSurvival.dirt
            local nativeDirt = tonumber(Citizen.InvokeNative(0x147149F2E909323C, activeHorsePed, 16, Citizen.ResultAsInteger())) or currentDirt
            if math.floor(nativeDirt) ~= math.floor(currentDirt) then
                Citizen.InvokeNative(0x5DA12E025D47D4E5, activeHorsePed, 16, math.floor(currentDirt))
            end

            -- Efeitos físicos de fome/sede zeradas (visual apenas — valor vem do servidor)
            if FDB.HorseSurvival.hunger == 0 or FDB.HorseSurvival.thirst == 0 then
                local health = GetEntityHealth(activeHorsePed)
                if health > 0 then SetEntityHealth(activeHorsePed, health - 1) end
            end

            -- Efeito de doença: dreno de stamina core visual
            if FDB.HorseSurvival.illness > 0 then
                local stamina = tonumber(Citizen.InvokeNative(0x36731AC041289BB1, activeHorsePed, 1)) or 0
                if stamina > 5.0 then
                    Citizen.InvokeNative(0xC6258F41D86676E0, activeHorsePed, 1, stamina - 5.0)
                end
            end
        end
    end
end)

-- ============================================================
-- Notifica o servidor que o cavalo está ativo (heartbeat)
-- Servidor usa isso pra saber qual jogador tem cavalo no mundo
-- e incluir no loop de metabolismo server-side
-- ============================================================
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- Nada aqui — o ApplySurvivalData já notifica o servidor via SpawnHorse
end)
