-- shared/framework-bridge/bridge.lua
fdb = fdb or {}
fdb.bridge = {}

local FDBCore = nil

-- Tenta obter o core object
Citizen.CreateThread(function()
    local attempts = 0
    while not FDBCore and attempts < 10 do
        pcall(function()
            FDBCore = exports['fdb-core']:GetCoreObject()
        end)
        if not FDBCore then
            attempts = attempts + 1
            Wait(1000)
        end
    end
end)

--- Retorna o objeto do player (no server) ou player data (no client)
---@param source number? Apenas necessário no server
---@return table?
function fdb.bridge.GetPlayer(source)
    if not FDBCore then
        pcall(function()
            FDBCore = exports['fdb-core']:GetCoreObject()
        end)
    end
    
    if not FDBCore then return nil end

    if IsDuplicityVersion() then -- Server side
        if not source then return nil end
        return FDBCore.Functions.GetPlayer(source)
    else -- Client side
        return FDBCore.Functions.GetPlayerData()
    end
end

--- Retorna se o jogador está logado
---@return boolean
function fdb.bridge.IsLoggedIn()
    if IsDuplicityVersion() then
        return true -- No servidor assume-se ativo
    else
        local player = fdb.bridge.GetPlayer()
        return player and player.citizenid ~= nil
    end
end
