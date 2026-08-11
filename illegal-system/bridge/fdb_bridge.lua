--[[
    Implementação de Bridge.* para FDB-Core vanilla.
    Único arquivo que conhece fdbCore.Functions.* — se o cliente trocar
    de framework, é este arquivo (e só este) que muda.
]]

if Config.Framework ~= 'fdb' then return end

local fdbCore = exports['fdb-core']:GetCoreObject()

function Bridge.GetPlayer(source)
    return fdbCore.Functions.GetPlayer(source)
end

function Bridge.GetIdentifier(source)
    local Player = Bridge.GetPlayer(source)
    if not Player then return nil end
    return Player.PlayerData.citizenid
end

function Bridge.AddMoney(source, amount, reason)
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.AddMoney('cash', amount, reason or 'illegal-system')
end

function Bridge.RemoveMoney(source, amount, reason)
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.RemoveMoney('cash', amount, reason or 'illegal-system')
end

function Bridge.AddItem(source, item, count, metadata)
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.AddItem(item, count, false, metadata)
end

function Bridge.HasItem(source, item, count)
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.HasItem(item, count)
end

function Bridge.HasPermission(source, permission)
    return fdbCore.Functions.HasPermission(source, permission)
end

function Bridge.Notify(source, message, notifyType)
    exports['fdb-libs']:Notify(source, message, notifyType or 'info')
end

function Bridge.GetInventoryImageURL(item)
    return 'nui://fdb-inventory/html/images/' .. item .. '.png'
end

-- ── Lado cliente (só roda se este arquivo também for client_script;
--    hoje não é — client/core.lua tem seu próprio require de target) ──
