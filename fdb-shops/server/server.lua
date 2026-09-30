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

local function hasStationModule(stationId, shopId, moduleName)
    if not stationId then return true end
    
    local row = MySQL.single.await("SELECT shop_id, metadata FROM shop_stations WHERE id = ?", {tonumber(stationId) or stationId})
    if not row then return true end
    
    if row.shop_id ~= shopId then return false end
    
    if row.metadata and row.metadata ~= '' then
        local meta = json.decode(row.metadata) or {}
        if not meta.modules then return true end
        local modules = meta.modules
        for _, m in ipairs(modules) do
            if m == moduleName then return true end
        end
        return false
    end
    
    return true
end

-- Fetch physical stations for a client
fdbLibs:RegisterServerCallback('fdb-shops:server:getStations', function(source, cb)
    local stations = {}
    local result = MySQL.query.await('SELECT * FROM shop_stations')
    if result then
        for _, row in ipairs(result) do
            table.insert(stations, {
                id = row.id,
                shop_id = row.shop_id,
                type = row.type,
                position = json.decode(row.position),
                allowed_recipes = json.decode(row.allowed_recipes) or {},
                prop_model = row.prop_model,
                animation_dict = row.animation_dict,
                animation_name = row.animation_name,
                npc_model = row.npc_model,
                npc_heading = row.npc_heading,
                spawn_condition = row.spawn_condition,
                hide_when_owner_present = row.hide_when_owner_present == 1,
                hide_radius = row.hide_radius,
                fallback_npc = json.decode(row.fallback_npc) or {},
                config = json.decode(row.config) or {},
                metadata = json.decode(row.metadata) or {}
            })
        end
    end
    cb(stations)
end)

-- Check if a player can open the owner NUI
fdbLibs:RegisterServerCallback('fdb-shops:server:requestOwnerMenu', function(source, cb, shopId)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb({ success = false, message = "Jogador inválido." }) end

    local citizenid = Player.PlayerData.citizenid
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)

    if perms and (perms.isOwner or perms.isAdmin or perms.financeiro or perms.editar_precos or perms.gerenciar_funcionarios or perms.repor_estoque or perms.craftar or perms.atender) then
        local onDuty = EmployeeManager.IsOnDuty(shopId, citizenid)
        local employees = EmployeeManager.GetEmployees(shopId)
        local bal = StashManager.GetBalance(shopId)
        
        -- Query today's sales
        local salesQuery = [[
            SELECT id, buyer_name, payment_method, item_name, quantity, total_price, metadata, created_at 
            FROM shop_transactions 
            WHERE shop_id = ? AND transaction_type IN ('venda', 'buy', 'promissoria')
              AND created_at >= CURDATE()
            ORDER BY created_at DESC 
            LIMIT 50
        ]]
        local rows = MySQL.query.await(salesQuery, {shopId}) or {}
        local todaySales = {}
        local totalDayRevenue = 0.0
        for _, r in ipairs(rows) do
            local price = tonumber(r.total_price) or 0.0
            totalDayRevenue = totalDayRevenue + price
            local itemsSummary = r.item_name or "Itens Diversos"
            if r.metadata then
                local meta = json.decode(r.metadata)
                if meta and meta.items and #meta.items > 0 then
                    local names = {}
                    for _, it in ipairs(meta.items) do
                        table.insert(names, string.format("%dx %s", it.amount or 1, it.name))
                    end
                    itemsSummary = table.concat(names, ", ")
                end
            end
            table.insert(todaySales, {
                id = r.id,
                buyerName = r.buyer_name or "Cliente Desconhecido",
                paymentMethod = r.payment_method or "cash",
                items = itemsSummary,
                total = price,
                createdAt = r.created_at
            })
        end

        local shop = ShopManager.GetShop(shopId)
        cb({
            success = true,
            permissions = perms,
            shopData = shop,
            balance = bal,
            onDuty = onDuty,
            employees = employees,
            todaySales = todaySales,
            totalDayRevenue = totalDayRevenue
        })
    else
        cb({
            success = false,
            message = "Acesso restrito a proprietários, funcionários autorizados ou administradores."
        })
    end
end)

-- Open Register Callback (determines if employee/owner or customer)
fdbLibs:RegisterServerCallback('fdb-shops:server:openRegister', function(source, cb, shopId)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb({ success = false, message = "Jogador inválido." }) end

    local citizenid = Player.PlayerData.citizenid
    local shop = ShopManager.GetShop(shopId)
    if not shop then return cb({ success = false, message = "Loja não encontrada." }) end

    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    local isEmployeeOrOwner = perms and (perms.isOwner or perms.isAdmin or perms.financeiro or perms.atender or perms.repor_estoque or perms.craftar or perms.gerenciar_funcionarios)

    if not isEmployeeOrOwner then
        return cb({
            success = true,
            isEmployee = false,
            canCustomerBuy = true
        })
    end

    local bal = StashManager.GetBalance(shopId)
    local onDuty = EmployeeManager.IsOnDuty(shopId, citizenid)

    local salesQuery = [[
        SELECT id, buyer_name, payment_method, item_name, quantity, total_price, metadata, created_at 
        FROM shop_transactions 
        WHERE shop_id = ? AND transaction_type IN ('venda', 'buy', 'promissoria')
          AND created_at >= CURDATE()
        ORDER BY created_at DESC 
        LIMIT 50
    ]]
    local rows = MySQL.query.await(salesQuery, {shopId}) or {}
    local todaySales = {}
    local totalDayRevenue = 0.0

    for _, r in ipairs(rows) do
        local price = tonumber(r.total_price) or 0.0
        totalDayRevenue = totalDayRevenue + price
        local itemsSummary = r.item_name or "Itens Diversos"
        if r.metadata then
            local meta = json.decode(r.metadata)
            if meta and meta.items and #meta.items > 0 then
                local names = {}
                for _, it in ipairs(meta.items) do
                    table.insert(names, string.format("%dx %s", it.amount or 1, it.name))
                end
                itemsSummary = table.concat(names, ", ")
            end
        end

        table.insert(todaySales, {
            id = r.id,
            buyerName = r.buyer_name or "Cliente Desconhecido",
            paymentMethod = r.payment_method or "cash",
            items = itemsSummary,
            total = price,
            createdAt = r.created_at
        })
    end

    cb({
        success = true,
        isEmployee = true,
        shopId = shopId,
        shopLabel = shop.label or "Armazém",
        balance = bal,
        totalDayRevenue = totalDayRevenue,
        onDuty = onDuty,
        todaySales = todaySales,
        permissions = perms
    })
end)

-- Toggle Duty Callback
fdbLibs:RegisterServerCallback('fdb-shops:server:toggleDuty', function(source, cb, shopId)
    local Player = FDBCore.Functions.GetPlayer(source)
    if not Player then return cb({ success = false }) end

    local citizenid = Player.PlayerData.citizenid
    local curDuty = EmployeeManager.IsOnDuty(shopId, citizenid)
    local newDuty = not curDuty
    EmployeeManager.SetDuty(shopId, citizenid, newDuty)

    local shop = ShopManager.GetShop(shopId)
    local shopName = shop and shop.label or shopId
    local statusText = newDuty and "Entrou em serviço" or "Saiu de serviço"
    fdbLibs:Notify(source, statusText .. " em " .. shopName, newDuty and "success" or "warning", 4000)
    cb({ success = true, onDuty = newDuty })
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

-- Fetch nearby players to hire
fdbLibs:RegisterServerCallback('fdb-shops:server:getNearbyPlayers', function(source, cb)
    local list = EmployeeManager.GetNearbyPlayers(source, 10.0)
    cb(list)
end)

-- Hire employee
RegisterNetEvent('fdb-shops:server:hireEmployee', function(shopId, targetCitizenId, gradeLevel, roleName, perms)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'gerenciar_funcionarios') then
        fdbLibs:Notify(src, "Você não tem permissão para contratar funcionários.", "error", 4000)
        return
    end

    local success = EmployeeManager.Hire(shopId, targetCitizenId, perms, gradeLevel, roleName)
    if success then
        fdbLibs:Notify(src, "Funcionário contratado com sucesso!", "success", 4000)
        local targetPlayer = FDBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
        if targetPlayer then
            fdbLibs:Notify(targetPlayer.PlayerData.source, "Você foi contratado para a loja " .. shopId .. "!", "success", 5000)
        end
    else
        fdbLibs:Notify(src, "Falha ao contratar funcionário.", "error", 4000)
    end
end)

-- Fire employee
RegisterNetEvent('fdb-shops:server:fireEmployee', function(shopId, targetCitizenId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'gerenciar_funcionarios') then
        fdbLibs:Notify(src, "Você não tem permissão para demitir funcionários.", "error", 4000)
        return
    end

    EmployeeManager.Fire(shopId, targetCitizenId)
    fdbLibs:Notify(src, "Funcionário demitido com sucesso.", "warning", 4000)

    local targetPlayer = FDBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
    if targetPlayer then
        fdbLibs:Notify(targetPlayer.PlayerData.source, "Você foi dispensado da loja " .. shopId .. ".", "warning", 5000)
    end
end)

-- Update employee role / permissions
RegisterNetEvent('fdb-shops:server:updateEmployeeRole', function(shopId, targetCitizenId, gradeLevel, roleName, perms)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'gerenciar_funcionarios') then
        fdbLibs:Notify(src, "Você não tem permissão para alterar cargos.", "error", 4000)
        return
    end

    EmployeeManager.UpdatePermissions(shopId, targetCitizenId, perms, gradeLevel, roleName)
    fdbLibs:Notify(src, "Cargo e permissões atualizados!", "success", 4000)
end)

-- ==========================================
-- Events (Actions)
-- ==========================================

-- Player interacting with NPC/Register to open Buy Catalog (StoreFront)
RegisterNetEvent('fdb-shops:server:openstore', function(shopId)
    local src = source
    local shop = ShopManager.GetShop(shopId)

    if not shop then
        print(('^3[%s] WARN: Player %s tried to open invalid shop %s^7'):format(resourceName, src, tostring(shopId)))
        fdbLibs:Notify(src, "Loja não encontrada ou não configurada.", "error", 4000)
        return
    end

    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jobType = (Player.PlayerData.job and Player.PlayerData.job.type) or ''
    local jobName = (Player.PlayerData.job and Player.PlayerData.job.name) or ''
    local isAdmin = FDBCore.Functions.HasPermission(src, 'admin')

    if not isAdmin then
        if shop.templateId == 'armoury' and jobType ~= 'leo' and jobName ~= 'police' and jobName ~= 'sheriff' then 
            fdbLibs:Notify(src, "Apenas forças da lei têm acesso a este arsenal.", "error", 4000)
            return 
        end
        if shop.templateId == 'medic' and jobType ~= 'medic' and jobName ~= 'medic' and jobName ~= 'doctor' then 
            fdbLibs:Notify(src, "Apenas médicos têm acesso a estes suprimentos.", "error", 4000)
            return 
        end
    end

    -- Build catalog for modern StoreFront UI
    local catalogList = {}
    local sourceCatalog = (shop.catalog and #shop.catalog > 0) and shop.catalog or shop.buyCatalog or {}

    for _, catItem in ipairs(sourceCatalog) do
        local itemName = catItem.item_name or catItem.name
        local isActive = (catItem.is_active ~= false and catItem.is_active ~= 0)
        if itemName and isActive then
            local finalPrice = ShopManager.GetFinalPrice(shopId, itemName)
            local itemData = FDBCore.Shared.Items[itemName] or {}
            table.insert(catalogList, {
                item_name = itemName,
                name = itemName,
                label = itemData.label or itemName,
                image = itemData.image or (itemName .. ".png"),
                description = itemData.description or "",
                weight = itemData.weight or 0,
                type = itemData.type or "item",
                price = finalPrice
            })
        end
    end

    local moneyData = {
        cash = (Player.PlayerData.money and Player.PlayerData.money.cash) or 0.0,
        bank = (Player.PlayerData.money and Player.PlayerData.money.bank) or 0.0
    }

    local paymentConfig = (shop.config and shop.config.paymentMethods) or { cash = true, promissoria = false, bank = false }
    if paymentConfig.cash == nil then paymentConfig.cash = true end

    local shopData = {
        shopId = shopId,
        shopLabel = shop.label or "Armazém",
        catalog = catalogList,
        playerMoney = moneyData,
        acceptedPaymentMethods = paymentConfig
    }

    TriggerClientEvent('fdb-shops:client:openStoreFront', src, shopData)
end)

-- Process Cart Checkout
fdbLibs:RegisterServerCallback('fdb-shops:server:checkoutCart', function(source, cb, data)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return cb({ success = false, message = "Jogador não encontrado." }) end

    local shopId = data.shopId
    local paymentMethod = data.paymentMethod or 'cash'
    local cart = data.cart or {}

    if #cart == 0 then
        return cb({ success = false, message = "O carrinho está vazio." })
    end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        return cb({ success = false, message = "Loja não encontrada." })
    end

    -- Validate payment method against store configuration
    local paymentConfig = (shop.config and shop.config.paymentMethods) or { cash = true, promissoria = false, bank = false }
    if paymentConfig.cash == nil then paymentConfig.cash = true end

    if paymentMethod == 'bank' and not paymentConfig.bank then
        return cb({ success = false, message = "Esta loja não aceita transferências bancárias no Velho Oeste!" })
    end
    if paymentMethod == 'promissoria' and not paymentConfig.promissoria then
        return cb({ success = false, message = "Esta loja não aceita notas promissórias!" })
    end

    -- Server-side Price & Total Recalculation
    local totalCost = 0.0
    local validatedItems = {}

    for _, item in ipairs(cart) do
        local itemName = tostring(item.item_name or item.name or '')
        local amount = math.floor(tonumber(item.amount) or 0)

        if itemName ~= '' and amount > 0 then
            local unitPrice = ShopManager.GetFinalPrice(shopId, itemName)
            local subtotal = unitPrice * amount
            totalCost = totalCost + subtotal
            table.insert(validatedItems, {
                name = itemName,
                amount = amount,
                unitPrice = unitPrice,
                subtotal = subtotal
            })
        end
    end

    if #validatedItems == 0 then
        return cb({ success = false, message = "Nenhum item válido no pedido." })
    end

    -- Process payment based on method
    if paymentMethod == 'promissoria' then
        local hasItem = Player.Functions.GetItemByName('promissoria') or Player.Functions.GetItemByName('nota_promissoria')
        if hasItem then
            Player.Functions.RemoveItem(hasItem.name, 1)
            TriggerClientEvent('fdb-inventory:client:ItemBox', src, hasItem, "remove")
        end
    else
        local playerBalance = (Player.PlayerData.money and Player.PlayerData.money[paymentMethod]) or 0.0
        if playerBalance < totalCost then
            return cb({ success = false, message = ("Saldo insuficiente (%s)."):format(paymentMethod == 'cash' and 'Dinheiro' or 'Banco') })
        end

        local paymentSuccess = Player.Functions.RemoveMoney(paymentMethod, totalCost, "shop-purchase-" .. shopId)
        if not paymentSuccess then
            return cb({ success = false, message = "Falha ao debitar valor da conta." })
        end

        -- Credit Shop Cash Balance
        MySQL.update('UPDATE shops SET cash_balance = cash_balance + ? WHERE shop_id = ?', {totalCost, shopId})
        if shop.cashBalance then
            shop.cashBalance = shop.cashBalance + totalCost
        end
    end

    -- Add Items to Player Inventory
    for _, itm in ipairs(validatedItems) do
        Player.Functions.AddItem(itm.name, itm.amount)
        TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[itm.name], "add")
    end

    -- Buyer name
    local buyerChar = Player.PlayerData.charinfo
    local buyerName = (buyerChar.firstname or '') .. ' ' .. (buyerChar.lastname or '')
    if buyerName:gsub('%s+', '') == '' then buyerName = "Cidadão " .. Player.PlayerData.citizenid end

    local cartSummary = {}
    for _, vi in ipairs(validatedItems) do
        table.insert(cartSummary, string.format("%dx %s", vi.amount, vi.name))
    end
    local itemSummaryStr = table.concat(cartSummary, ", ")

    -- Log Transaction with Buyer Name and Payment Method
    ShopManager.LogTransaction(
        shopId, 
        Player.PlayerData.citizenid, 
        paymentMethod == 'promissoria' and 'promissoria' or 'venda', 
        itemSummaryStr, 
        #validatedItems, 
        totalCost, 
        totalCost, 
        'produtos',
        buyerName,
        paymentMethod,
        { items = validatedItems }
    )

    local msg = paymentMethod == 'promissoria' and 
        ("Compra registrada via Nota Promissória! Total: $%s"):format(string.format("%.2f", totalCost)) or
        ("Compra concluída! Pago: $%s (%s)"):format(string.format("%.2f", totalCost), paymentMethod == 'cash' and 'Dinheiro' or 'Banco')

    fdbLibs:Notify(src, msg, "success", 4000)
    cb({ success = true })
end)

-- Owner/Employee Actions

RegisterNetEvent('fdb-shops:server:openStash', function(shopId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    local shop = ShopManager.GetShop(shopId)
    if shop and shop.ownerId and shop.ownerId ~= "" then
        local onDuty = EmployeeManager.IsOnDuty(shopId, Player.PlayerData.citizenid)
        if not onDuty then
            fdbLibs:Notify(src, "Você precisa entrar em serviço no Painel da Loja ou Registradora para acessar o estoque!", "error", 4000)
            return
        end
    end

    if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'repor_estoque') then
        StashManager.OpenStock(src, shopId)
    else
        fdbLibs:Notify(src, "Você não tem permissão para acessar o estoque", "error")
    end
end)

RegisterNetEvent('fdb-shops:server:depositCash', function(shopId, stationId, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not hasStationModule(stationId, shopId, 'finances') then
        fdbLibs:Notify(src, "Este painel não possui módulo financeiro", "error")
        return
    end

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

RegisterNetEvent('fdb-shops:server:withdrawCash', function(shopId, stationId, amount)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not hasStationModule(stationId, shopId, 'finances') then
        fdbLibs:Notify(src, "Este painel não possui módulo financeiro", "error")
        return
    end

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

RegisterNetEvent('fdb-shops:server:updatePriceVariation', function(shopId, stationId, variation)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not hasStationModule(stationId, shopId, 'prices') then
        fdbLibs:Notify(src, "Este painel não possui módulo de preços", "error")
        return
    end

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
