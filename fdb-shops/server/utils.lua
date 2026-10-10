local FDBCore = exports['fdb-core']:GetCoreObject()

function SanitizeMoney(v, max)
    if type(v) ~= 'number' or v ~= v or v == math.huge or v == -math.huge then return nil end
    v = math.floor(v * 100 + 0.5) / 100
    if v <= 0 or v > (max or 999999999) then return nil end
    return v
end

function SanitizeInt(v, min, max)
    if type(v) ~= 'number' or v ~= v or v == math.huge or v == -math.huge then return nil end
    v = math.floor(v)
    if v < (min or 1) or v > (max or 999999999) then return nil end
    return v
end

function MapEconomyCategory(cat)
    if not cat then return 'materials' end
    local c = string.lower(cat)
    if c == 'weapon' or c == 'armas' then return 'weapons' end
    if c == 'ammo' or c == 'municao' then return 'ammo' end
    if c == 'food' or c == 'comida' or c == 'consumable' then return 'food' end
    if c == 'drink' or c == 'bebida' then return 'drink' end
    if c == 'medicine' or c == 'medicamento' then return 'medicine' end
    if c == 'tool' or c == 'ferramentas' then return 'tools' end
    if c == 'luxury' or c == 'luxo' then return 'luxury' end
    if c == 'clothing' or c == 'roupas' then return 'clothing' end
    if c == 'crafting' or c == 'artesanato' then return 'crafting' end
    return 'materials'
end

FDBShopLocks = {
    locks = {}
}

function FDBShopLocks.Acquire(src, action, ttlSec)
    local key = src .. ':' .. action
    local now = os.time()
    if FDBShopLocks.locks[key] and FDBShopLocks.locks[key] > now then 
        return false 
    end
    FDBShopLocks.locks[key] = now + (ttlSec or 10)
    return true
end

function FDBShopLocks.Release(src, action)
    local key = src .. ':' .. action
    FDBShopLocks.locks[key] = nil
end

AddEventHandler('playerDropped', function()
    local src = source
    for k, _ in pairs(FDBShopLocks.locks) do
        if k:sub(1, #tostring(src) + 1) == tostring(src) .. ":" then
            FDBShopLocks.locks[k] = nil
        end
    end
end)
