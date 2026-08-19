ActiveStores = {}

local function LoadStoresFromServer()
    -- Pede os dados para o servidor usando exatamente o mesmo nome registrado
    local stores = lib.callback.await('illegal-system:server:GetActiveStores', false)
    if stores then
        ActiveStores = stores
        -- Dispara um evento local para os outros scripts (ex: store_robbery) montarem os targets
        TriggerEvent('illegal-system:client:StoresLoaded', ActiveStores)
    end
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    LoadStoresFromServer()
end)

AddEventHandler('playerSpawned', function()
    LoadStoresFromServer()
end)

-- Evento que será chamado pelo servidor (no Item 7) quando uma loja for editada e salva
RegisterNetEvent('illegal-system:client:UpdateActiveStores', function(updatedStores)
    ActiveStores = updatedStores
    TriggerEvent('illegal-system:client:StoresLoaded', ActiveStores)
end)
