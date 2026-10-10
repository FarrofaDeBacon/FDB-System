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
    
    -- Ensure columns are DECIMAL instead of FLOAT (Issue 13) and add stock_mode (Block 2)
    pcall(function()
        MySQL.query.await('ALTER TABLE shops MODIFY COLUMN cash_balance DECIMAL(12,2) DEFAULT 0.00')
        MySQL.query.await('ALTER TABLE shops MODIFY COLUMN owner_price_variation DECIMAL(12,2) DEFAULT 0.00')
        MySQL.query.await('ALTER TABLE shops ADD COLUMN stock_mode VARCHAR(50) DEFAULT "infinite"')
    end)
    
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

    local catalogRows = MySQL.query.await('SELECT * FROM shop_catalog_items')
    local shopCatalogs = {}
    if catalogRows then
        for _, row in ipairs(catalogRows) do
            if not shopCatalogs[row.shop_id] then shopCatalogs[row.shop_id] = {} end
            table.insert(shopCatalogs[row.shop_id], {
                id = row.id,
                item_name = row.item_name,
                price = tonumber(row.price) or 0.0,
                is_active = (row.is_active == 1 or row.is_active == true)
            })
        end
    end

    local shops = MySQL.query.await('SELECT * FROM shops')
    if shops then
        for _, s in ipairs(shops) do
            local cat = shopCatalogs[s.shop_id] or {}
            if #cat == 0 then
                local legacyBuy = json.decode(s.buy_catalog) or {}
                for _, b in ipairs(legacyBuy) do
                    if b.name then
                        table.insert(cat, {
                            item_name = b.name,
                            price = tonumber(b.price) or 0.0,
                            is_active = true
                        })
                    end
                end
            end

            ShopManager.Shops[s.shop_id] = {
                templateId = s.template_id,
                label = s.label,
                ownerId = s.owner_id,
                enabledRecipes = json.decode(s.enabled_recipes) or {},
                enabledSellItems = json.decode(s.enabled_sell_items) or {},
                buyCatalog = json.decode(s.buy_catalog) or {},
                sellCatalog = json.decode(s.sell_catalog) or {},
                catalog = cat,
                cashBalance = s.cash_balance,
                ownerPriceVariation = s.owner_price_variation,
                maxPriceVariation = s.max_price_variation,
                regionId = s.region_id,
                city = s.city or 'outros',
                config = json.decode(s.config) or {},
                stockMode = s.stock_mode or (s.owner_id and s.owner_id ~= "" and 'physical' or 'infinite')
            }
        end
        print(('^2[%s] Loaded %d templates and %d shops with catalog items.^7'):format(resourceName, #templates, #shops))
    end
end)

--- Get a Shop from cache (with DB fallback)
function ShopManager.GetShop(shopId)
    if not shopId then return nil end
    if ShopManager.Shops[shopId] then
        return ShopManager.Shops[shopId]
    end

    local s = MySQL.single.await('SELECT * FROM shops WHERE shop_id = ?', {shopId})
    if s then
        local catRows = MySQL.query.await('SELECT * FROM shop_catalog_items WHERE shop_id = ?', {shopId}) or {}
        local cat = {}
        for _, row in ipairs(catRows) do
            table.insert(cat, {
                id = row.id,
                item_name = row.item_name,
                price = tonumber(row.price) or 0.0,
                is_active = (row.is_active == 1 or row.is_active == true)
            })
        end
        if #cat == 0 then
            local legacyBuy = json.decode(s.buy_catalog) or {}
            for _, b in ipairs(legacyBuy) do
                if b.name then
                    table.insert(cat, {
                        item_name = b.name,
                        price = tonumber(b.price) or 0.0,
                        is_active = true
                    })
                end
            end
        end

        ShopManager.Shops[s.shop_id] = {
            templateId = s.template_id,
            label = s.label,
            ownerId = s.owner_id,
            enabledRecipes = json.decode(s.enabled_recipes) or {},
            enabledSellItems = json.decode(s.enabled_sell_items) or {},
            buyCatalog = json.decode(s.buy_catalog) or {},
            sellCatalog = json.decode(s.sell_catalog) or {},
            catalog = cat,
            cashBalance = tonumber(s.cash_balance) or 0.0,
            ownerPriceVariation = tonumber(s.owner_price_variation) or 0.0,
            maxPriceVariation = tonumber(s.max_price_variation) or 0.15,
            regionId = s.region_id,
            city = s.city or 'outros',
            config = json.decode(s.config) or {},
            stockMode = s.stock_mode or (s.owner_id and s.owner_id ~= "" and 'physical' or 'infinite')
        }
        return ShopManager.Shops[s.shop_id]
    end
    return nil
end

--- Resolve region and save it when a shop is created or moved
function ShopManager.UpdateShopRegion(shopId, coords)
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

    -- Find base price in the catalog (active items first)
    local catalogItem = nil
    if shop.catalog then
        for _, item in ipairs(shop.catalog) do
            local name = item.item_name or item.name
            local active = (item.is_active ~= false and item.is_active ~= 0)
            if name == itemName and active then
                catalogItem = { name = name, price = tonumber(item.price) or 0.0, category = item.category }
                break
            end
        end
    end
    if not catalogItem and shop.buyCatalog then
        for _, item in ipairs(shop.buyCatalog) do
            if item.name == itemName then
                catalogItem = { name = item.name, price = tonumber(item.price) or 0.0, category = item.category }
                break
            end
        end
    end

    if not catalogItem then return nil end

    local basePrice = tonumber(catalogItem.price) or 0.0
    -- Use economy export if region is defined
    if shop.regionId and exports['fdb-economy'] then
        local cat = catalogItem.category or "materials"
        pcall(function()
            local ecoPrice = exports['fdb-economy']:getPrice(basePrice, shop.regionId, cat)
            if ecoPrice and tonumber(ecoPrice) then
                basePrice = tonumber(ecoPrice)
            end
        end)
    end

    -- Apply owner variation (- variation is discount, + is markup)
    local ownerVar = tonumber(shop.ownerPriceVariation) or 0.0
    local finalPrice = basePrice * (1.0 + ownerVar)

    return math.max(0, finalPrice)
end

--- Log a transaction and notify the economy engine
function ShopManager.LogTransaction(shopId, playerId, txType, itemName, qty, unitPrice, totalPrice, categoryOverride, buyerName, paymentMethod, metadata)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return end

    local metaStr = metadata and (type(metadata) == 'table' and json.encode(metadata) or tostring(metadata)) or nil
    MySQL.insert([[
        INSERT INTO shop_transactions (shop_id, player_id, transaction_type, item_name, quantity, unit_price, total_price, region_id, buyer_name, payment_method, metadata) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        shopId, playerId, txType, itemName, qty, unitPrice, totalPrice, shop.regionId, buyerName, paymentMethod or 'cash', metaStr
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
