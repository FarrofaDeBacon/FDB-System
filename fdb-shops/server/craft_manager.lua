-- ============================================================
-- FDB System | fdb-shops | server/craft_manager.lua
-- Core logic for Crafting at Shop Stations
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local fdbLibs = exports['fdb-libs']

-- Memory map for active crafts to prevent timing cheats
-- Structure: ActiveCrafts[citizenid] = { recipeId = '...', stationId = '...', startedAt = os.time(), timeNeeded = 5 }
local ActiveCrafts = {}

-- ==========================================
-- Helper Functions
-- ==========================================

-- Check if an array contains a value
local function tableContains(tbl, val)
    if not tbl then return false end
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

-- Find the station config in memory
local function getStationFromDB(stationId)
    local result = MySQL.query.await('SELECT * FROM shop_stations WHERE id = ?', {stationId})
    if result and result[1] then
        local row = result[1]
        return {
            id = row.id,
            shop_id = row.shop_id,
            type = row.type,
            position = json.decode(row.position),
            allowed_recipes = json.decode(row.allowed_recipes) or {},
            prop_model = row.prop_model,
            animation_dict = row.animation_dict,
            animation_name = row.animation_name
        }
    end
    return nil
end

-- ==========================================
-- Callbacks
-- ==========================================

-- Fetch available recipes for a specific station
fdbLibs:RegisterServerCallback('fdb-shops:server:getCraftMenu', function(source, cb, shopId, stationId)
    local citizenid = FDBCore.Functions.GetPlayer(source).PlayerData.citizenid

    -- 1. Check Permissions
    if not EmployeeManager.HasPermission(shopId, citizenid, 'craftar') then
        cb(false, "Você não tem permissão para usar esta bancada.")
        return
    end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        cb(false, "Loja não encontrada.")
        return
    end

    local template = ShopManager.Templates[shop.templateId]
    if not template then
        cb(false, "Template da loja não encontrado.")
        return
    end

    local station = getStationFromDB(stationId)
    if not station or station.type ~= 'craft' then
        cb(false, "Bancada inválida.")
        return
    end

    if station.shop_id ~= shopId then
        cb(false, "Esta bancada não pertence a esta loja.")
        return
    end

    -- 2. Build 3-Layer Cascaded Recipe List (Template -> Shop -> Station)
    local availableRecipes = {}
    
    local hasShopFilter = shop.enabledRecipes and #shop.enabledRecipes > 0
    local hasStationFilter = station.allowed_recipes and #station.allowed_recipes > 0

    for _, recipe in ipairs(template.craftableRecipes or {}) do
        if recipe.id then
            local isEnabledInShop = (not hasShopFilter) or tableContains(shop.enabledRecipes, recipe.id)
            local isAllowedAtStation = (not hasStationFilter) or tableContains(station.allowed_recipes, recipe.id)

            if isEnabledInShop and isAllowedAtStation then
                -- Enrich with item label and description if missing
                local itemData = FDBCore.Shared.Items[recipe.result or recipe.id] or {}
                local fullRecipe = {
                    id = recipe.id,
                    label = recipe.label or itemData.label or recipe.id,
                    result = recipe.result or recipe.id,
                    amount = recipe.amount or 1,
                    time = recipe.time or 5000,
                    category = recipe.category or "artesanato",
                    description = recipe.description or itemData.description or "",
                    ingredients = {}
                }
                for _, ing in ipairs(recipe.ingredients or {}) do
                    local ingData = FDBCore.Shared.Items[ing.name] or {}
                    table.insert(fullRecipe.ingredients, {
                        name = ing.name,
                        label = ing.label or ingData.label or ing.name,
                        amount = ing.amount or 1
                    })
                end
                table.insert(availableRecipes, fullRecipe)
            end
        end
    end

    if #availableRecipes == 0 then
        cb(false, "Nenhuma receita disponível nesta bancada.")
        return
    end

    -- 3. Gather player's inventory count for materials
    local inventoryData = {}
    local player = FDBCore.Functions.GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.items then
        for _, itm in pairs(player.PlayerData.items) do
            if itm and itm.name then
                inventoryData[itm.name] = (inventoryData[itm.name] or 0) + (itm.amount or 1)
            end
        end
    end

    cb(true, availableRecipes, inventoryData)
end)

-- Request to start crafting (Pre-check)
fdbLibs:RegisterServerCallback('fdb-shops:server:requestCraft', function(source, cb, shopId, recipeId, stationId, multiplier)
    local citizenid = FDBCore.Functions.GetPlayer(source).PlayerData.citizenid

    if not EmployeeManager.HasPermission(shopId, citizenid, 'craftar') then
        cb(false, "Você não tem permissão para usar esta bancada.")
        return
    end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        cb(false, "Loja não encontrada.")
        return
    end

    local template = ShopManager.Templates[shop.templateId]
    local station = getStationFromDB(stationId)
    if not station or station.type ~= 'craft' then
        cb(false, "Bancada inválida.")
        return
    end

    if station.shop_id ~= shopId then
        cb(false, "Esta bancada não pertence a esta loja.")
        return
    end

    local hasStationFilter = station.allowed_recipes and #station.allowed_recipes > 0
    if hasStationFilter and not tableContains(station.allowed_recipes, recipeId) then
        cb(false, "Esta receita não pode ser feita nesta bancada.")
        return
    end

    local hasShopFilter = shop.enabledRecipes and #shop.enabledRecipes > 0
    if hasShopFilter and not tableContains(shop.enabledRecipes, recipeId) then
        cb(false, "Esta receita está desativada na loja.")
        return
    end

    -- Find the full recipe object
    local targetRecipe = nil
    for _, r in ipairs(template.craftableRecipes or {}) do
        if r.id == recipeId then
            targetRecipe = r
            break
        end
    end

    if not targetRecipe then
        cb(false, "Receita não encontrada no template.")
        return
    end

    local mult = math.max(1, math.floor(tonumber(multiplier) or 1))

    -- Register the craft in memory to prevent speed hacking
    ActiveCrafts[citizenid] = {
        recipeId = recipeId,
        stationId = stationId,
        startedAt = os.time(),
        multiplier = mult,
        timeNeeded = math.ceil(((targetRecipe.time or 5000) * mult) / 1000)
    }

    -- Return success to client so it can start the progress bar and animations
    cb(true, targetRecipe, station)
end)

-- ==========================================
-- Events
-- ==========================================

-- Complete Crafting (Atomic Inventory Operation)
RegisterNetEvent('fdb-shops:server:completeCraft', function(shopId, recipeId, stationId, multiplier)
    local src = source
    local player = FDBCore.Functions.GetPlayer(src)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    
    -- Permissions check
    if not EmployeeManager.HasPermission(shopId, citizenid, 'craftar') then
        fdbLibs:Notify(src, "Sem permissão.", "error")
        return
    end

    local shop = ShopManager.GetShop(shopId)
    local template = ShopManager.Templates[shop.templateId]
    local station = getStationFromDB(stationId)

    if not shop or not template or not station then return end

    if station.shop_id ~= shopId then
        fdbLibs:Notify(src, "Bancada inválida.", "error")
        return
    end

    -- Anti-Cheat Time Verification
    local activeCraft = ActiveCrafts[citizenid]
    if not activeCraft or activeCraft.recipeId ~= recipeId or activeCraft.stationId ~= stationId then
        fdbLibs:Notify(src, "Fabricação não autorizada ou já processada.", "error")
        return
    end

    local timePassed = os.time() - activeCraft.startedAt
    if timePassed < (activeCraft.timeNeeded - 1) then -- 1 second tolerance for network lag
        fdbLibs:Notify(src, "Fabricação rápida detectada (Anti-Cheat).", "error")
        ActiveCrafts[citizenid] = nil
        return
    end

    local mult = activeCraft.multiplier or math.max(1, math.floor(tonumber(multiplier) or 1))
    ActiveCrafts[citizenid] = nil

    -- Distance check
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local stationPos = vec3(station.position.x, station.position.y, station.position.z)
    if #(pos - stationPos) > 6.0 then
        fdbLibs:Notify(src, "Você se afastou muito da bancada.", "error")
        return
    end

    -- Find recipe
    local recipe = nil
    for _, r in ipairs(template.craftableRecipes or {}) do
        if r.id == recipeId then recipe = r break end
    end
    if not recipe then return end

    -- Verify player materials
    local hasAll = true
    for _, ing in ipairs(recipe.ingredients or {}) do
        local needed = (ing.amount or 1) * mult
        local item = player.Functions.GetItemByName(ing.name)
        if not item or (item.amount or 0) < needed then
            hasAll = false
            break
        end
    end

    if not hasAll then
        fdbLibs:Notify(src, "Materiais insuficientes em seu inventário.", "error")
        return
    end

    -- Remove ingredients from player
    for _, ing in ipairs(recipe.ingredients or {}) do
        local needed = (ing.amount or 1) * mult
        player.Functions.RemoveItem(ing.name, needed)
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[ing.name], "remove")
    end

    -- Add crafted result
    local yieldAmount = (recipe.amount or 1) * mult
    player.Functions.AddItem(recipe.result, yieldAmount)
    TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[recipe.result], "add")

    fdbLibs:Notify(src, "Fabricação concluída com sucesso!", "success")
    ShopManager.LogTransaction(shopId, citizenid, 'craft', recipe.result, yieldAmount, 0, 0, recipe.category or "crafting")
