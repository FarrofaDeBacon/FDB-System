-- ============================================================
-- FDB System | fdb-shops | server/craft_manager.lua
-- Core logic for Crafting at Shop Stations
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local fdbLibs = exports['fdb-libs']

-- Memory map for active crafts to prevent timing cheats
-- Structure: ActiveCrafts[citizenid] = { recipeId = '...', stationId = '...', startedAt = os.time(), timeNeeded = 5 }
local ActiveCrafts = {}
local OpLocks = {}

local function AcquireLock(src, action)
    local key = src .. ':' .. action
    if OpLocks[key] then return false end
    OpLocks[key] = true
    return true
end

local function ReleaseLock(src, action)
    local key = src .. ':' .. action
    OpLocks[key] = nil
end

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
            animation_name = row.animation_name,
            metadata = row.metadata and json.decode(row.metadata) or {}
        }
    end
    return nil
end

local function GetCraftSource(shop, station)
    if not shop.ownerId or shop.ownerId == "" then
        return 'player_inventory'
    end
    if station.metadata and station.metadata.craftSource then
        return station.metadata.craftSource
    end
    return Config.CraftSourceDefault or 'shop_stash'
end
            animation_dict = row.animation_dict,
            animation_name = row.animation_name,
            metadata = row.metadata and json.decode(row.metadata) or {}
        }
    end
    return nil
end

-- ==========================================
-- Callbacks
-- ==========================================

local function GetDefaultTemplateRecipes(templateId)
    if templateId == 'weapons' then
        return {
            {
                id = "craft_ammo_revolver",
                label = "Caixa de Munição de Revólver",
                result = "ammo_box_revolver",
                amount = 1,
                time = 5000,
                category = "municao",
                ingredients = { { name = "iron", amount = 1 }, { name = "gunpowder", amount = 1 } }
            },
            {
                id = "craft_ammo_repeater",
                label = "Caixa de Munição de Repetição",
                result = "ammo_box_repeater",
                amount = 1,
                time = 5000,
                category = "municao",
                ingredients = { { name = "iron", amount = 1 }, { name = "gunpowder", amount = 1 } }
            },
            {
                id = "craft_ammo_shotgun",
                label = "Caixa de Munição de Escopeta",
                result = "ammo_box_shotgun",
                amount = 1,
                time = 6000,
                category = "municao",
                ingredients = { { name = "iron", amount = 1 }, { name = "gunpowder", amount = 1 } }
            },
            {
                id = "craft_ammo_rifle",
                label = "Caixa de Munição de Rifle",
                result = "ammo_box_rifle",
                amount = 1,
                time = 6000,
                category = "municao",
                ingredients = { { name = "iron", amount = 1 }, { name = "gunpowder", amount = 1 } }
            }
        }
    end
    return {}
end

local function GetShopRecipes(shop)
    if not shop then return {} end
    if shop.enabledRecipes and type(shop.enabledRecipes) == 'table' and #shop.enabledRecipes > 0 then
        if type(shop.enabledRecipes[1]) == 'table' then
            return shop.enabledRecipes
        end
    end

    local template = ShopManager.Templates[shop.templateId]
    if template and template.craftableRecipes and #template.craftableRecipes > 0 then
        return template.craftableRecipes
    end

    return GetDefaultTemplateRecipes(shop.templateId)
end

-- Fetch available recipes for a specific station
fdbLibs:RegisterServerCallback('fdb-shops:server:getCraftMenu', function(source, cb, shopId, stationId)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb(false, "Jogador não encontrado.") end
    local citizenid = Player.PlayerData.citizenid

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

    local station = getStationFromDB(stationId)
    if not station or station.type ~= 'craft' then
        cb(false, "Bancada inválida.")
        return
    end

    if station.shop_id ~= shopId then
        cb(false, "Esta bancada não pertence a esta loja.")
        return
    end

    -- 2. Build Recipe List
    local availableRecipes = {}
    local rawRecipes = GetShopRecipes(shop)
    local hasStationFilter = station.allowed_recipes and #station.allowed_recipes > 0

    for _, recipe in ipairs(rawRecipes) do
        local rId = recipe.id or recipe.result
        if rId then
            local isAllowedAtStation = (not hasStationFilter) or tableContains(station.allowed_recipes, rId)
            if isAllowedAtStation then
                local resName = recipe.result or rId
                local itemData = FDBCore.Shared.Items[resName] or {}
                local fullRecipe = {
                    id = rId,
                    label = recipe.label or itemData.label or resName,
                    result = resName,
                    amount = tonumber(recipe.amount) or 1,
                    time = tonumber(recipe.time) or 5000,
                    category = recipe.category or "artesanato",
                    description = recipe.description or itemData.description or "",
                    ingredients = {}
                }
                for _, ing in ipairs(recipe.ingredients or {}) do
                    local ingData = FDBCore.Shared.Items[ing.name] or {}
                    table.insert(fullRecipe.ingredients, {
                        name = ing.name,
                        label = ing.label or ingData.label or ing.name,
                        amount = tonumber(ing.amount) or 1
                    })
                end
                table.insert(availableRecipes, fullRecipe)
            end
        end
    end

    if #availableRecipes == 0 then
        cb(false, "Nenhuma receita cadastrada nesta loja. Cadastre receitas na aba Craft de /editshops.")
        return
    end

    -- 3. Gather inventory count for materials
    local inventoryData = {}
    local craftSource = GetCraftSource(shop, station)

    if craftSource == 'shop_stash' then
        local stashName = 'shop_stock_' .. shopId
        -- Attempt to get stash items if the API allows
        local success, items = pcall(function() return exports['fdb-inventory']:GetInventoryItems(stashName) end)
        if not success or not items then
            success, items = pcall(function() return exports['fdb-inventory']:GetItems(stashName) end)
        end
        if not success or not items then
            -- DB Fallback for QB Core style
            local row = MySQL.single.await('SELECT items FROM stashitems WHERE stash = ?', {stashName})
            if row and row.items then items = json.decode(row.items) end
        end

        if type(items) == 'table' then
            for _, itm in pairs(items) do
                if type(itm) == 'table' and itm.name then
                    inventoryData[itm.name] = (inventoryData[itm.name] or 0) + (tonumber(itm.amount) or 1)
                end
            end
        end
    else
        if Player.PlayerData and Player.PlayerData.items then
            for _, itm in pairs(Player.PlayerData.items) do
                if itm and itm.name then
                    inventoryData[itm.name] = (inventoryData[itm.name] or 0) + (itm.amount or 1)
                end
            end
        end
    end

    cb(true, availableRecipes, inventoryData)
end)

-- Request to start crafting (Pre-check)
fdbLibs:RegisterServerCallback('fdb-shops:server:requestCraft', function(source, cb, shopId, recipeId, stationId, multiplier)
    local src = source
    if not AcquireLock(src, 'craft') then
        return cb(false, "Aguarde a transação anterior.")
    end
    local function finish(success, msg, data)
        ReleaseLock(src, 'craft')
        return cb(success, msg, data)
    end

    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return finish(false, "Jogador não encontrado.") end
    local citizenid = Player.PlayerData.citizenid

    if not EmployeeManager.HasPermission(shopId, citizenid, 'craftar') then
        return finish(false, "Você não tem permissão para usar esta bancada.")
    end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        return finish(false, "Loja não encontrada.")
    end

    local station = getStationFromDB(stationId)
    if not station or station.type ~= 'craft' then
        return finish(false, "Bancada inválida.")
    end

    if station.shop_id ~= shopId then
        return finish(false, "Esta bancada não pertence a esta loja.")
    end

    -- Find the full recipe object
    local targetRecipe = nil
    local rawRecipes = GetShopRecipes(shop)
    for _, r in ipairs(rawRecipes) do
        if (r.id or r.result) == recipeId then
            targetRecipe = r
            break
        end
    end

    if not targetRecipe then
        return finish(false, "Receita não encontrada na loja.")
    end

    if station.allowed_recipes and #station.allowed_recipes > 0 and not tableContains(station.allowed_recipes, recipeId) then
        return finish(false, "Receita não permitida nesta bancada.")
    end

    local mult = math.max(1, math.floor(tonumber(multiplier) or 1))
    if mult > 100 then mult = 100 end -- limit multiplier

    -- Register the craft in memory to prevent speed hacking
    ActiveCrafts[citizenid] = {
        recipeId = recipeId,
        stationId = stationId,
        startedAt = os.time(),
        multiplier = mult,
        timeNeeded = math.ceil(((tonumber(targetRecipe.time) or 5000) * mult) / 1000)
    }

    -- Return success to client so it can start the progress bar and animations
    return finish(true, targetRecipe, station)
end)

-- ==========================================
-- Events
-- ==========================================

-- Complete Crafting (Atomic Inventory Operation)
RegisterNetEvent('fdb-shops:server:completeCraft', function(shopId, recipeId, stationId, multiplier)
    local src = source
    if not AcquireLock(src, 'craft') then return end

    local player = FDBCore.Functions.GetPlayer(src)
    if not player then 
        ReleaseLock(src, 'craft')
        return 
    end
    
    local citizenid = player.PlayerData.citizenid
    
    -- Permissions check
    if not EmployeeManager.HasPermission(shopId, citizenid, 'craftar') then
        ReleaseLock(src, 'craft')
        fdbLibs:Notify(src, "Sem permissão.", "error")
        return
    end

    local shop = ShopManager.GetShop(shopId)
    local station = getStationFromDB(stationId)

    if not shop or not station then 
        ReleaseLock(src, 'craft')
        return 
    end

    if station.shop_id ~= shopId then
        ReleaseLock(src, 'craft')
        fdbLibs:Notify(src, "Bancada inválida.", "error")
        return
    end

    -- Anti-Cheat Time Verification
    local activeCraft = ActiveCrafts[citizenid]
    if not activeCraft or activeCraft.recipeId ~= recipeId or activeCraft.stationId ~= stationId then
        ReleaseLock(src, 'craft')
        fdbLibs:Notify(src, "Fabricação não autorizada ou já processada.", "error")
        return
    end

    local timePassed = os.time() - activeCraft.startedAt
    if timePassed < (activeCraft.timeNeeded - 1) then
        ReleaseLock(src, 'craft')
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
        ReleaseLock(src, 'craft')
        fdbLibs:Notify(src, "Você se afastou muito da bancada.", "error")
        return
    end

    -- Find recipe
    local recipe = nil
    local rawRecipes = GetShopRecipes(shop)
    for _, r in ipairs(rawRecipes) do
        if (r.id or r.result) == recipeId then recipe = r break end
    end
    if not recipe then 
        ReleaseLock(src, 'craft')
        return 
    end

    if station.allowed_recipes and #station.allowed_recipes > 0 and not tableContains(station.allowed_recipes, recipeId) then
        ReleaseLock(src, 'craft')
        fdbLibs:Notify(src, "Receita não permitida nesta bancada.", "error")
        return
    end

    local craftSource = GetCraftSource(shop, station)
    local stashName = 'shop_stock_' .. shopId
    
    if craftSource == 'player_inventory' then
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
            ReleaseLock(src, 'craft')
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
        if player.Functions.AddItem(recipe.result, yieldAmount) then
            TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[recipe.result], "add")
        else
            -- Reverse
            for _, ing in ipairs(recipe.ingredients or {}) do
                local needed = (ing.amount or 1) * mult
                player.Functions.AddItem(ing.name, needed)
            end
            ReleaseLock(src, 'craft')
            fdbLibs:Notify(src, "Inventário cheio.", "error")
            return
        end
    else
        -- shop_stash
        local removedFromStash = {}
        local stashHasAll = true
        for _, ing in ipairs(recipe.ingredients or {}) do
            local needed = (ing.amount or 1) * mult
            local success = exports['fdb-inventory']:RemoveItem(stashName, ing.name, needed)
            if success then
                table.insert(removedFromStash, {name = ing.name, amount = needed})
            else
                stashHasAll = false
                break
            end
        end
        
        if not stashHasAll then
            -- Rollback
            for _, r in ipairs(removedFromStash) do
                exports['fdb-inventory']:AddItem(stashName, r.name, r.amount)
            end
            ReleaseLock(src, 'craft')
            fdbLibs:Notify(src, "Materiais insuficientes no baú da loja.", "error")
            return
        end
        
        local yieldAmount = (recipe.amount or 1) * mult
        local success = exports['fdb-inventory']:AddItem(stashName, recipe.result, yieldAmount)
        if not success then
            -- Rollback
            for _, r in ipairs(removedFromStash) do
                exports['fdb-inventory']:AddItem(stashName, r.name, r.amount)
            end
            ReleaseLock(src, 'craft')
            fdbLibs:Notify(src, "Espaço insuficiente no baú da loja para o resultado.", "error")
            return
        end
    end

    local yieldAmount = (recipe.amount or 1) * mult

    fdbLibs:Notify(src, "Fabricação concluída com sucesso!", "success")
    ShopManager.LogTransaction(shopId, citizenid, 'craft', recipe.result, yieldAmount, 0, 0, recipe.category or "crafting")
    ReleaseLock(src, 'craft')
end)
