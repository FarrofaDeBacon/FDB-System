-- ============================================================
-- FDB System | fdb-shops | server/stash_manager.lua
-- Management for physical stashes and cash registers
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()

StashManager = {}

--- Opens the shop's physical stock stash
function StashManager.OpenStock(source, shopId)
    local stashName = 'shop_stock_' .. shopId
    
    local shop = ShopManager.GetShop(shopId)
    if not shop then return end

    -- fdb-inventory API expects source and stash identifier
    exports['fdb-inventory']:OpenInventory(source, stashName, {
        maxweight = Config.StashMaxWeight,
        slots = Config.StashMaxSlots,
        label = "Estoque: " .. shop.label
    })
end

--- Retrieves the current cash balance of a shop
--- Uses the DB balance as the source of truth
function StashManager.GetBalance(shopId)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return 0.0 end
    return shop.cashBalance or 0.0
end

--- Updates the DB cash balance and handles physical cash if enabled
--- Should be run atomically or within a tight sequence
function StashManager.UpdateBalance(shopId, amountDelta, reason)
    local shop = ShopManager.GetShop(shopId)
    if not shop then return false end

    local newBalance = shop.cashBalance + amountDelta
    if newBalance < 0 then return false end -- Cannot go below zero

    -- Update Source of Truth
    shop.cashBalance = newBalance
    MySQL.update.await('UPDATE shops SET cash_balance = ? WHERE shop_id = ?', { newBalance, shopId })

    -- If in Physical mode, we must sync the stash item
    if Config.CashRegisterMode == 'physical' then
        local stashName = 'shop_register_' .. shopId
        if amountDelta > 0 then
            exports['fdb-inventory']:AddItem(stashName, 'cash', amountDelta)
        elseif amountDelta < 0 then
            exports['fdb-inventory']:RemoveItem(stashName, 'cash', math.abs(amountDelta))
        end
    end

    return true
end

--- Deposit cash from a player into the shop
function StashManager.DepositCash(source, shopId, amount)
    if amount <= 0 then return false end
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return false end

    if Player.Functions.RemoveMoney('cash', amount, "shop-deposit") then
        if StashManager.UpdateBalance(shopId, amount, "deposit") then
            ShopManager.LogTransaction(shopId, Player.PlayerData.citizenid, 'deposit', 'cash', amount, 1, amount)
            return true
        else
            -- Refund if failed
            Player.Functions.AddMoney('cash', amount, "shop-deposit-refund")
            return false
        end
    end
    return false
end

--- Withdraw cash from the shop to a player
function StashManager.WithdrawCash(source, shopId, amount)
    if amount <= 0 then return false end
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return false end

    if StashManager.UpdateBalance(shopId, -amount, "withdraw") then
        Player.Functions.AddMoney('cash', amount, "shop-withdraw")
        ShopManager.LogTransaction(shopId, Player.PlayerData.citizenid, 'withdraw', 'cash', amount, 1, amount)
        return true
    end
    return false
end

--- Hooks into fdb-inventory to keep DB cash_balance synced if physical cash is stolen or modified manually
-- This hook must catch additions/removals of 'cash' item in 'shop_register_*' stashes
AddEventHandler('fdb-inventory:server:onInventoryUpdate', function(stashName, itemName, amountDelta)
    if Config.CashRegisterMode ~= 'physical' then return end

    if type(stashName) == 'string' and string.sub(stashName, 1, 14) == 'shop_register_' then
        if itemName == 'cash' then
            local shopId = string.sub(stashName, 15)
            local shop = ShopManager.GetShop(shopId)
            
            if shop then
                -- This is a one-way sync from Stash -> DB to catch manual moves (like robbery)
                -- We must ensure we don't cause an infinite loop with UpdateBalance.
                -- Ideally, UpdateBalance would flag the operation so this event ignores it,
                -- but for now, we just blindly trust the stash total if it changes out-of-band.
                local items = exports['fdb-inventory']:GetItemsByName(stashName, 'cash')
                local totalPhysical = 0
                for _, item in ipairs(items) do
                    totalPhysical = totalPhysical + item.amount
                end

                if shop.cashBalance ~= totalPhysical then
                    shop.cashBalance = totalPhysical
                    MySQL.update('UPDATE shops SET cash_balance = ? WHERE shop_id = ?', { totalPhysical, shopId })
                end
            end
        end
    end
end)
