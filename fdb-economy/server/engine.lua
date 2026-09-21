-- ============================================================
-- FDB System | fdb-economy | server/engine.lua
-- Regional Inflation Engine Logic
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()

EconomyEngine = {
    Regions = {} -- In-memory cache
}

-- Load all regions from DB on startup
CreateThread(function()
    Wait(2000) -- Wait for DB initialization
    local result = MySQL.query.await('SELECT * FROM region_economy')
    if result then
        for _, row in ipairs(result) do
            EconomyEngine.Regions[row.region_id] = {
                baseRate = row.base_rate,
                categoryModifiers = json.decode(row.category_modifiers) or {},
                minRate = row.min_rate,
                maxRate = row.max_rate,
                volumeWeight = row.volume_weight,
                moneySupplyWeight = row.money_supply_weight,
                recalcInterval = row.recalc_interval_minutes,
                decayTowardBaseline = row.decay_toward_baseline,
                transactionVolume = row.transaction_volume,
                lastRecalc = row.last_recalc
            }
        end
        if Config.Debug then
            print(('^2[%s] Loaded %d regions into memory cache.^7'):format(resourceName, #result))
        end
    end
end)

-- Mapping: Zone Name -> Region ID with validation
local zoneToRegionMap = {}
for regionId, zones in pairs(Config.RegionZones) do
    for _, zone in ipairs(zones) do
        local uZone = string.upper(zone)
        if zoneToRegionMap[uZone] then
            print(('^1[%s] ERROR: Zone %s is duplicated in regions %s and %s!^7'):format(resourceName, uZone, zoneToRegionMap[uZone], regionId))
        else
            zoneToRegionMap[uZone] = regionId
        end
    end
end

--- Resolve a Region ID from a RDR3 Zone Name
--- @param zoneName string Native RDR3 zone name
--- @return string|nil regionId
function EconomyEngine.ResolveRegionFromZone(zoneName)
    if not zoneName then return nil end
    return zoneToRegionMap[string.upper(zoneName)]
end

--- Get final multiplier for a specific item in a region
--- @param regionId string
--- @param category string
--- @return float multiplier
function EconomyEngine.GetPriceMultiplier(regionId, category)
    local region = EconomyEngine.Regions[regionId]
    if not region then return 1.0 end

    local base = region.baseRate
    local catModifier = 1.0
    
    if category and region.categoryModifiers[category] then
        catModifier = region.categoryModifiers[category]
    end

    local finalMultiplier = base * catModifier

    -- Clamp by min/max
    if finalMultiplier < region.minRate then finalMultiplier = region.minRate end
    if finalMultiplier > region.maxRate then finalMultiplier = region.maxRate end

    return finalMultiplier
end

--- Logs a transaction to adjust volume
function EconomyEngine.LogTransaction(regionId, shopId, itemName, category, qty, unitPrice, totalPrice, txType)
    if not regionId or not EconomyEngine.Regions[regionId] then return end

    MySQL.insert('INSERT INTO economy_transactions (region_id, shop_id, item_name, category, quantity, unit_price, total_price, transaction_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    {
        regionId, shopId, itemName, category, qty, unitPrice, totalPrice, txType
    })

    -- Increment in-memory volume for next recalc
    EconomyEngine.Regions[regionId].transactionVolume = EconomyEngine.Regions[regionId].transactionVolume + qty
    
    -- Sync volume back to DB periodically (done during recalc, but we can do a lightweight update here if needed)
    MySQL.update('UPDATE region_economy SET transaction_volume = transaction_volume + ? WHERE region_id = ?', {qty, regionId})
end

--- Recalculate inflation based on transaction volume and decay
function EconomyEngine.Recalculate()
    if Config.Debug then print(('^3[%s] Starting regional economy recalculation...^7'):format(resourceName)) end
    
    for regionId, region in pairs(EconomyEngine.Regions) do
        local oldRate = region.baseRate
        local newRate = oldRate

        -- 1. Apply Volume Influence
        if region.transactionVolume > Config.MinTransactionsForVolume then
            -- Simple logic: High volume -> Inflates prices (higher demand)
            -- For every 100 items traded, increase base rate by a small margin scaled by volumeWeight
            local inflationFactor = (region.transactionVolume / 100) * (region.volumeWeight * 0.01)
            newRate = newRate + inflationFactor
        end

        -- 2. Apply Decay toward baseline (Deflation / Normalization)
        -- Tends back to Config.DefaultBaseRate over time if volume doesn't counteract
        local diff = Config.DefaultBaseRate - newRate
        newRate = newRate + (diff * region.decayTowardBaseline)

        -- 3. Clamp values
        if newRate < region.minRate then newRate = region.minRate end
        if newRate > region.maxRate then newRate = region.maxRate end

        if newRate ~= oldRate then
            region.baseRate = newRate
            
            MySQL.update('UPDATE region_economy SET base_rate = ?, transaction_volume = 0, last_recalc = CURRENT_TIMESTAMP WHERE region_id = ?', 
            { newRate, regionId })
            
            if Config.Debug then
                print(('^2[%s] Region %s base_rate updated: %.3f -> %.3f (Volume: %d)^7'):format(resourceName, regionId, oldRate, newRate, region.transactionVolume))
            end
        else
            MySQL.update('UPDATE region_economy SET transaction_volume = 0, last_recalc = CURRENT_TIMESTAMP WHERE region_id = ?', 
            { regionId })
        end

        -- Reset volume for the next cycle
        region.transactionVolume = 0
    end
end

-- Recalculation Loop
CreateThread(function()
    while true do
        Wait(Config.RecalcIntervalMinutes * 60 * 1000)
        EconomyEngine.Recalculate()
    end
end)
