-- ============================================================
-- FDB System | fdb-economy | server/exports.lua
-- Public API for other resources (like fdb-shops)
-- ============================================================

--- Resolves a Region ID from a World Position
--- @param zoneName string Native RDR3 zone name (obtained from GetNameOfZone client-side)
--- @return string|nil regionId
exports('resolveRegion', function(zoneName)
    return EconomyEngine.ResolveRegionFromZone(zoneName)
end)

--- Gets the final multiplier for a specific item in a region
--- @param regionId string
--- @param category string
--- @return float multiplier
exports('getPriceMultiplier', function(regionId, category)
    return EconomyEngine.GetPriceMultiplier(regionId, category)
end)

--- Helper: Get final calculated price for a base price
--- @param basePrice float
--- @param regionId string
--- @param category string
--- @return float finalPrice
exports('getPrice', function(basePrice, regionId, category)
    local mult = EconomyEngine.GetPriceMultiplier(regionId, category)
    return basePrice * mult
end)

--- Logs a transaction (buy/sell/craft) to adjust regional inflation volume
--- @param regionId string
--- @param shopId string
--- @param itemName string
--- @param category string
--- @param qty int
--- @param unitPrice float
--- @param totalPrice float
--- @param txType string ('buy', 'sell', 'craft', 'supply')
exports('logTransaction', function(regionId, shopId, itemName, category, qty, unitPrice, totalPrice, txType)
    EconomyEngine.LogTransaction(regionId, shopId, itemName, category, qty, unitPrice, totalPrice, txType)
end)
