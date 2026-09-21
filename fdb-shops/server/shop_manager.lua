-- ============================================================
-- FDB System | fdb-shops | server/shop_manager.lua
-- Core Business Logic for Shops
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()

ShopManager = {
    Shops = {},       -- In-memory cache of shops
    Templates = {}    -- In-memory cache of templates
}

-- Load all templates and shops on boot
CreateThread(function()
    Wait(2000)
    
    local templates = MySQL.query.await('SELECT * FROM shop_templates')
    if templates then
        for _, t in ipairs(templates) do
            ShopManager.Templates[t.template_id] = {
                label = t.label,
                craftableRecipes = json.decode(t.craftable_recipes) or {},
                sellableItems = json.decode(t.sellable_items) or {},
                defaultConfig = json.decode(t.default_config) or {}
            }
        end
    end

    local shops = MySQL.query.await('SELECT * FROM shops')
    if shops then
        for _, s in ipairs(shops) do
            ShopManager.Shops[s.shop_id] = {
                templateId = s.template_id,
                label = s.label,
                ownerId = s.owner_id,
                enabledRecipes = json.decode(s.enabled_recipes) or {},
                enabledSellItems = json.decode(s.enabled_sell_items) or {},
                buyCatalog = json.decode(s.buy_catalog) or {},
                sellCatalog = json.decode(s.sell_catalog) or {},
                cashBalance = s.cash_balance,
                ownerPriceVariation = s.owner_price_variation,
                maxPriceVariation = s.max_price_variation,
                regionId = s.region_id,
                config = json.decode(s.config) or {}
            }
        end
        print(('^2[%s] Loaded %d templates and %d shops.^7'):format(resourceName, #templates, #shops))
    end
end)

--- Get a Shop from cache
function ShopManager.GetShop(shopId)
    return ShopManager.Shops[shopId]
end

--- Resolve region and save it when a shop is created or moved
function ShopManager.UpdateShopRegion(shopId, coords)
    -- Server cannot natively resolve zones. This should be set manually or via client.
    local regionId = nil

    if regionId then
        MySQL.update('UPDATE shops SET region_id = ? WHERE shop_id = ?', { regionId, shopId })
        if ShopManager.Shops[shopId] then
            ShopManager.Shops[shopId].regionId = regionId
        end
    end
    return regionId
end

--- Get the final price for an item (Economy Base * Region * Owner Variation)
function ShopManager.GetFinalPrice(shopId, itemName)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return 0 end

    -- Find base price in the catalog
    local catalogItem = nil
    for _, item in ipairs(shop.buyCatalog) do
        if item.name == itemName then
            catalogItem = item
            break
        end
    end

    if not catalogItem then return 0 end

    local basePrice = catalogItem.price
    -- Use economy export if region is defined
    if shop.regionId then
        local cat = catalogItem.category or "materials"
        basePrice = exports['fdb-economy']:getPrice(basePrice, shop.regionId, cat)
    end

    -- Apply owner variation (- variation is discount, + is markup)
    -- variation is a float like 0.10 for +10%
    local ownerVar = shop.ownerPriceVariation or 0.0
    local finalPrice = basePrice * (1.0 + ownerVar)

    return math.max(0, finalPrice)
end

--- Log a transaction and notify the economy engine
function ShopManager.LogTransaction(shopId, playerId, txType, itemName, qty, unitPrice, totalPrice, categoryOverride)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return end

    MySQL.insert('INSERT INTO shop_transactions (shop_id, player_id, transaction_type, item_name, quantity, unit_price, total_price, region_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    {
        shopId, playerId, txType, itemName, qty, unitPrice, totalPrice, shop.regionId
    })

    -- Notify economy engine
    if shop.regionId then
        local cat = categoryOverride
        
        if not cat then
            cat = "materials"
            for _, item in ipairs(shop.buyCatalog) do
                if item.name == itemName then
                    cat = item.category or "materials"
                    break
                end
            end
        end

        exports['fdb-economy']:logTransaction(shop.regionId, shopId, itemName, cat, qty, unitPrice, totalPrice, txType)
    end
end
