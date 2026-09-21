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
    
    for _, recipe in ipairs(template.craftableRecipes) do
        if recipe.id then
            local isEnabledInShop = tableContains(shop.enabledRecipes, recipe.id)
            local isAllowedAtStation = tableContains(station.allowed_recipes, recipe.id)

            if isEnabledInShop and isAllowedAtStation then
                table.insert(availableRecipes, recipe)
            end
        end
    end

    if #availableRecipes == 0 then
        cb(false, "Nenhuma receita disponível nesta bancada.")
        return
    end

    cb(true, availableRecipes)
end)

-- Request to start crafting (Pre-check)
fdbLibs:RegisterServerCallback('fdb-shops:server:requestCraft', function(source, cb, shopId, recipeId, stationId)
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
    
    if not station or not tableContains(station.allowed_recipes, recipeId) then
        cb(false, "Esta receita não pode ser feita nesta bancada.")
        return
    end

    if station.shop_id ~= shopId then
        cb(false, "Esta bancada não pertence a esta loja.")
        return
    end

    if not tableContains(shop.enabledRecipes, recipeId) then
        cb(false, "Esta receita está desativada na loja.")
        return
    end

    -- Find the full recipe object
    local targetRecipe = nil
    for _, r in ipairs(template.craftableRecipes) do
        if r.id == recipeId then
            targetRecipe = r
            break
        end
    end

    if not targetRecipe then
        cb(false, "Receita não encontrada no template.")
        return
    end

    -- Register the craft in memory to prevent speed hacking
    ActiveCrafts[citizenid] = {
        recipeId = recipeId,
        stationId = stationId,
        startedAt = os.time(),
        timeNeeded = math.ceil((targetRecipe.time or 5000) / 1000)
    }

    -- Return success to client so it can start the progress bar and animations
    cb(true, targetRecipe, station)
end)

-- ==========================================
-- Events
-- ==========================================

-- Complete Crafting (Atomic Inventory Operation)
RegisterNetEvent('fdb-shops:server:completeCraft', function(shopId, recipeId, stationId)
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
        -- Clear state
        ActiveCrafts[citizenid] = nil
        return
    end

    -- Clear state to prevent double execution
    ActiveCrafts[citizenid] = nil

    -- Distance check (Security to ensure player didn't teleport away)
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)
    local stationPos = vec3(station.position.x, station.position.y, station.position.z)
    if #(pos - stationPos) > 5.0 then
        fdbLibs:Notify(src, "Você se afastou muito da bancada.", "error")
        return
    end

    -- Find recipe
    local recipe = nil
    for _, r in ipairs(template.craftableRecipes) do
        if r.id == recipeId then recipe = r break end
    end
    if not recipe then return end

    local stashName = 'shop_stock_' .. shopId

    -- 1. Atomic Order: Remove ingredients first
    local removedIngs = {}
    local success = true

    for _, ing in ipairs(recipe.ingredients) do
        if exports['fdb-inventory']:RemoveItem(stashName, ing.name, ing.amount) then
            table.insert(removedIngs, {name = ing.name, amount = ing.amount})
        else
            success = false
            break
        end
    end

    -- If we failed to get all ingredients, rollback the ones we DID remove
    if not success then
        for _, ing in ipairs(removedIngs) do
            exports['fdb-inventory']:AddItem(stashName, ing.name, ing.amount)
        end
        fdbLibs:Notify(src, "Materiais insuficientes no baú da loja.", "error")
        return
    end

    -- 2. Atomic Order: Add crafted result to stash
    local added = exports['fdb-inventory']:AddItem(stashName, recipe.result, recipe.amount)
    
    if not added then
        -- Rollback all ingredients if stash is full
        for _, ing in ipairs(removedIngs) do
            exports['fdb-inventory']:AddItem(stashName, ing.name, ing.amount)
        end
        fdbLibs:Notify(src, "Baú da loja está cheio!", "error")
        return
    end

    -- 3. Finalize
    fdbLibs:Notify(src, "Fabricação concluída com sucesso!", "success")

    -- Log transaction dynamically
    local category = recipe.category or "crafting"
    ShopManager.LogTransaction(shopId, citizenid, 'craft', recipe.result, recipe.amount, 0, 0, category)
end)
