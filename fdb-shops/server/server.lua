-- ============================================================
-- FDB System | fdb-shops | server/server.lua
-- Event handlers and server callbacks
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()
lib.locale()

-- Replace ox_lib with fdb-libs
local fdbLibs = exports['fdb-libs']

-- ==========================================
-- Callbacks (Client -> Server Requests)
-- ==========================================

-- Check if a player can open the owner NUI
fdbLibs:RegisterServerCallback('fdb-shops:server:requestOwnerMenu', function(source, cb, shopId)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    local citizenid = Player.PlayerData.citizenid
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)

    if perms then
        cb({
            success = true,
            permissions = perms,
            shopData = ShopManager.GetShop(shopId)
        })
    else
        cb({success = false})
    end
end)

-- Fetch employees for NUI
fdbLibs:RegisterServerCallback('fdb-shops:server:getEmployees', function(source, cb, shopId)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end

    if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'gerenciar_funcionarios') then
        local emps = EmployeeManager.GetEmployees(shopId)
        cb(emps)
    else
        cb({})
    end
end)

-- ==========================================
-- Events (Actions)
-- ==========================================

-- Player interacting with NPC/Register to open Buy Catalog
RegisterNetEvent('fdb-shops:server:openstore', function(shopId)
    local src = source
    local shop = ShopManager.GetShop(shopId)

    if not shop then
        print(('^3[%s] WARN: Player %s tried to open invalid shop %s^7'):format(resourceName, src, tostring(shopId)))
        return
    end

    -- Job restrictions are now handled by templates or config, not hardcoded
    -- But for backward compatibility with old config structure (armoury requires leo, etc):
    local Player = FDBCore.Functions.GetPlayer(src)
    local jobType = Player.PlayerData.job.type
    
    if shop.templateId == 'armoury' and jobType ~= 'leo' then return end
    if shop.templateId == 'medic' and jobType ~= 'medic' then return end

    -- Build the formatted inventory for fdb-inventory shop API
    -- The new system maintains this integration to display the shop UI
    local itemTable = {}
    for _, catItem in ipairs(shop.buyCatalog) do
        local finalPrice = ShopManager.GetFinalPrice(shopId, catItem.name)
        table.insert(itemTable, {
            name = catItem.name,
            amount = catItem.amount or 50, -- Or check stash if we use physical limits
            price = finalPrice,
            -- buyPrice (for selling to shop) is separate, usually in sellCatalog
        })
    end

    local success, err
    if not exports['fdb-inventory']:DoesShopExist(shopId) then
        success, err = pcall(exports['fdb-inventory'].CreateShop, exports['fdb-inventory'], {
            name = shopId,
            label = shop.label,
            slots = #itemTable,
            items = itemTable,
        })
        if not success then
            print(('^1[%s] ERROR: Failed to create inventory shop for %s - %s^7'):format(resourceName, shopId, tostring(err)))
            return
        end
    else
        -- Update prices dynamically on open
        exports['fdb-inventory']:CreateShop({
            name = shopId,
            label = shop.label,
            items = itemTable
        })
    end

    success, err = pcall(exports['fdb-inventory'].OpenShop, exports['fdb-inventory'], src, shopId)
    if not success then
        print(('^1[%s] ERROR: Failed to open shop %s for player %s - %s^7'):format(resourceName, shopId, Player.PlayerData.citizenid, tostring(err)))
    end
end)

-- Owner/Employee Actions

RegisterNetEvent('fdb-shops:server:depositCash', function(shopId, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'financeiro') then
        if StashManager.DepositCash(src, shopId, amount) then
            fdbLibs:Notify(src, "Depósito realizado com sucesso", "success")
        else
            fdbLibs:Notify(src, "Falha no depósito. Verifique seu saldo.", "error")
        end
    else
        fdbLibs:Notify(src, "Você não tem permissão para depositar", "error")
    end
end)

RegisterNetEvent('fdb-shops:server:withdrawCash', function(shopId, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'financeiro') then
        local bal = StashManager.GetBalance(shopId)
        if amount > bal then
            fdbLibs:Notify(src, "O caixa não tem saldo suficiente", "error")
            return
        end

        if StashManager.WithdrawCash(src, shopId, amount) then
            fdbLibs:Notify(src, "Saque realizado com sucesso", "success")
        else
            fdbLibs:Notify(src, "Falha no saque.", "error")
        end
    else
        fdbLibs:Notify(src, "Você não tem permissão para sacar", "error")
    end
end)

RegisterNetEvent('fdb-shops:server:updatePriceVariation', function(shopId, variation)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'editar_precos') then
        local shop = ShopManager.GetShop(shopId)
        if not shop then return end

        local variationFloat = tonumber(variation)
        if not variationFloat then return end

        if variationFloat > shop.maxPriceVariation then
            variationFloat = shop.maxPriceVariation
        elseif variationFloat < -shop.maxPriceVariation then
            variationFloat = -shop.maxPriceVariation
        end

        shop.ownerPriceVariation = variationFloat
        MySQL.update('UPDATE shops SET owner_price_variation = ? WHERE shop_id = ?', {variationFloat, shopId})
        
        fdbLibs:Notify(src, "Variação de preço atualizada", "success")
    end
end)
