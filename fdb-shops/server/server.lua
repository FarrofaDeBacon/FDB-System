-- ============================================================
-- FDB System | fdb-shops | server/server.lua
-- Event handlers and server callbacks
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()
lib.locale()

-- Replace ox_lib with fdb-libs
local fdbLibs = exports['fdb-libs']


local function IsPlayerNearShop(src, shopId, maxDist)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local coords = GetEntityCoords(ped)
    local shop = ShopManager.GetShop(shopId)
    
    if not shop or not shop.stations or #shop.stations == 0 then return false end
    
    for _, st in ipairs(shop.stations) do
        local sc = type(st.position) == 'string' and json.decode(st.position) or st.position
        if sc and sc.x and sc.y and sc.z then
            local dist = #(coords - vector3(sc.x, sc.y, sc.z))
            if dist <= (maxDist or 15.0) then
                return true
            end
        end
    end
    
    return false
end

-- ==========================================
-- Callbacks (Client -> Server Requests)
-- ==========================================

local function hasStationModule(stationId, shopId, moduleName)
    if not stationId then return false end
    
    local row = MySQL.single.await("SELECT shop_id, metadata FROM shop_stations WHERE id = ?", {tonumber(stationId) or stationId})
    if not row then return false end
    
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

    if perms and not perms.isPublic and (perms.isOwner or perms.isAdmin or perms.financeiro or perms.editar_precos or perms.gerenciar_funcionarios or perms.repor_estoque or perms.craftar or perms.atender) then
        local onDuty = EmployeeManager.IsOnDuty(shopId, citizenid)
        local shop = ShopManager.GetShop(shopId)

        local employees = perms.gerenciar_funcionarios and EmployeeManager.GetEmployees(shopId) or {}
        local bal = perms.financeiro and StashManager.GetBalance(shopId) or 0.0
        
        local todaySales = {}
        local totalDayRevenue = 0.0

        if perms.financeiro then
            local salesQuery = [[
                SELECT id, buyer_name, payment_method, item_name, quantity, total_price, metadata, created_at 
                FROM shop_transactions 
                WHERE shop_id = ? AND transaction_type IN ('venda', 'buy', 'promissoria')
                  AND created_at >= CURDATE()
                ORDER BY created_at DESC 
                LIMIT 50
            ]]
            local rows = MySQL.query.await(salesQuery, {shopId}) or {}
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
        end

        local filteredShopData = {
            shopId = shop.shopId,
            label = shop.label,
            templateId = shop.templateId,
            ownerId = shop.ownerId,
            city = shop.city
        }
        if perms.financeiro or perms.editar_precos then
            filteredShopData.cashBalance = shop.cashBalance
            filteredShopData.ownerPriceVariation = shop.ownerPriceVariation
            filteredShopData.maxPriceVariation = shop.maxPriceVariation
        end
        if perms.editar_precos or perms.repor_estoque or perms.craftar then
            filteredShopData.catalog = shop.catalog
            filteredShopData.enabledRecipes = shop.enabledRecipes
        end

        cb({
            success = true,
            permissions = perms,
            shopData = filteredShopData,
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
    local isEmployeeOrOwner = perms and not perms.isPublic and (perms.isOwner or perms.isAdmin or perms.financeiro or perms.atender or perms.repor_estoque or perms.craftar or perms.gerenciar_funcionarios)

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
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return cb({ success = false }) end
    
    if not IsPlayerNearShop(src, shopId, 15.0) then
        fdbLibs:Notify(src, "Você está muito longe da loja!", "error")
        return cb({ success = false })
    end

    local citizenid = Player.PlayerData.citizenid
    local perms = EmployeeManager.GetPermissions(shopId, citizenid)
    if not perms or perms.isPublic or (not perms.isOwner and not perms.isAdmin and not perms.atender and not perms.craftar and not perms.repor_estoque and not perms.financeiro and not perms.editar_precos and not perms.gerenciar_funcionarios) then
        fdbLibs:Notify(src, "Você não é funcionário desta loja.", "error", 4000)
        return cb({ success = false })
    end

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

    local callerPerms = EmployeeManager.GetPermissions(shopId, Player.PlayerData.citizenid)
    if not callerPerms or not callerPerms.gerenciar_funcionarios then
        fdbLibs:Notify(src, "Você não tem permissão para contratar funcionários.", "error", 4000)
        return
    end

    if type(perms) ~= 'table' then perms = {} end
    local cleanPerms = {
        atender = perms.atender == true,
        repor_estoque = perms.repor_estoque == true,
        craftar = perms.craftar == true,
        financeiro = perms.financeiro == true,
        editar_precos = perms.editar_precos == true,
        gerenciar_funcionarios = perms.gerenciar_funcionarios == true
    }

    if cleanPerms.gerenciar_funcionarios and not callerPerms.isOwner and not callerPerms.isAdmin then
        cleanPerms.gerenciar_funcionarios = false
        fdbLibs:Notify(src, "Apenas proprietários podem conceder permissão de gerência.", "warning", 4000)
    end

    local success = EmployeeManager.Hire(shopId, targetCitizenId, cleanPerms, gradeLevel, roleName)
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

    local callerPerms = EmployeeManager.GetPermissions(shopId, Player.PlayerData.citizenid)
    if not callerPerms or not callerPerms.gerenciar_funcionarios then
        fdbLibs:Notify(src, "Você não tem permissão para alterar cargos.", "error", 4000)
        return
    end

    if type(perms) ~= 'table' then perms = {} end
    local cleanPerms = {
        atender = perms.atender == true,
        repor_estoque = perms.repor_estoque == true,
        craftar = perms.craftar == true,
        financeiro = perms.financeiro == true,
        editar_precos = perms.editar_precos == true,
        gerenciar_funcionarios = perms.gerenciar_funcionarios == true
    }

    if cleanPerms.gerenciar_funcionarios and not callerPerms.isOwner and not callerPerms.isAdmin then
        cleanPerms.gerenciar_funcionarios = false
        fdbLibs:Notify(src, "Apenas proprietários podem conceder permissão de gerência.", "warning", 4000)
    end

    EmployeeManager.UpdatePermissions(shopId, targetCitizenId, cleanPerms, gradeLevel, roleName)
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
            if finalPrice then
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
    if type(data) ~= 'table' or type(data.cart) ~= 'table' or type(data.shopId) ~= 'string' then
        return cb({ success = false, message = "Dados inválidos." })
    end

    local shopId = data.shopId
    local shopLockKey = 'shop_' .. shopId
    
    if not FDBShopLocks.Acquire(src, 'checkout') then
        return cb({ success = false, message = "Aguarde a transação anterior terminar." })
    end
    if not FDBShopLocks.Acquire(shopLockKey, 'checkout') then
        FDBShopLocks.Release(src, 'checkout')
        return cb({ success = false, message = "Aguarde, outro cliente está comprando nesta loja." })
    end
    
    local success, res = pcall(function()
        local Player = FDBCore.Functions.GetPlayer(src)
        if not Player then return { success = false, message = "Jogador não encontrado." } end
        
        if not IsPlayerNearShop(src, shopId, 15.0) then
            return { success = false, message = "Você está muito longe da loja!" }
        end

        local paymentMethod = data.paymentMethod or 'cash'
        local cart = data.cart or {}

        if #cart == 0 or #cart > 100 then
            return { success = false, message = "O carrinho está vazio ou excede o limite." }
        end

        if paymentMethod ~= 'cash' and paymentMethod ~= 'bank' and paymentMethod ~= 'promissoria' then
            return { success = false, message = "Método de pagamento inválido." }
        end

        local shop = ShopManager.GetShop(shopId)
        if not shop then
            return { success = false, message = "Loja não encontrada." }
        end
        
        -- Gating Achado 5
        if shop.config then
            if shop.config.jobRequirement and shop.config.jobRequirement ~= "" then
                local jobType = (Player.PlayerData.job and Player.PlayerData.job.type) or ''
                local jobName = (Player.PlayerData.job and Player.PlayerData.job.name) or ''
                if jobType ~= shop.config.jobRequirement and jobName ~= shop.config.jobRequirement then
                    return { success = false, message = "Você não tem a profissão necessária." }
                end
            end
            if shop.config.openingHour and shop.config.closingHour then
                local hour = GetClockHours()
                local openH = tonumber(shop.config.openingHour) or 0
                local closeH = tonumber(shop.config.closingHour) or 24
                if closeH > openH then
                    if hour < openH or hour >= closeH then
                        return { success = false, message = "A loja está fechada." }
                    end
                else
                    if hour < openH and hour >= closeH then
                        return { success = false, message = "A loja está fechada." }
                    end
                end
            end
        end

        -- Validate payment method against store configuration
        local paymentConfig = (shop.config and shop.config.paymentMethods) or { cash = true, promissoria = false, bank = false }
        if paymentConfig.cash == nil then paymentConfig.cash = true end

        if paymentMethod == 'bank' and not paymentConfig.bank then
            return { success = false, message = "Esta loja não aceita transferências bancárias no Velho Oeste!" }
        end
        if paymentMethod == 'promissoria' and not paymentConfig.promissoria then
            return { success = false, message = "Esta loja não aceita notas promissórias!" }
        end

        -- Server-side Price & Total Recalculation
        local totalCost = 0.0
        local validatedItems = {}

        for _, item in ipairs(cart) do
            if type(item) ~= 'table' then return { success = false, message = "Item inválido no carrinho." } end
            local itemName = item.item_name or item.name
            local amount = SanitizeInt(item.amount, 1, 1000)

            if type(itemName) == 'string' and amount and FDBCore.Shared.Items[itemName] then
                local unitPrice = ShopManager.GetFinalPrice(shopId, itemName)
                if not unitPrice or unitPrice <= 0 then
                    return { success = false, message = "Item indisponível nesta loja." }
                end
                local subtotal = unitPrice * amount
                totalCost = totalCost + subtotal
                table.insert(validatedItems, {
                    name = itemName,
                    amount = amount,
                    unitPrice = unitPrice,
                    subtotal = subtotal,
                    category = FDBCore.Shared.Items[itemName].category or FDBCore.Shared.Items[itemName].type or 'produtos'
                })
            end
        end

        if #validatedItems == 0 then
            return { success = false, message = "Nenhum item válido no pedido." }
        end

        -- Handle Physical Stock
        local isPhysical = (shop.stockMode == 'physical')
        local stashName = 'shop_stock_' .. shopId
        local removedFromStash = {}

        if isPhysical then
            local stashHasAll = true
            for _, itm in ipairs(validatedItems) do
                local s = exports['fdb-inventory']:RemoveItem(stashName, itm.name, itm.amount)
                if s then
                    table.insert(removedFromStash, itm)
                else
                    stashHasAll = false
                    break
                end
            end

            if not stashHasAll then
                -- Rollback stash
                for _, itm in ipairs(removedFromStash) do
                    exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount)
                end
                return { success = false, message = "Estoque físico insuficiente na loja." }
            end
        end

        -- Handle Promissoria or Money Payment
        local noteSlot = nil
        if paymentMethod == 'promissoria' then
            local note = Player.Functions.GetItemByName('promissoria') or Player.Functions.GetItemByName('nota_promissoria')
            if not note then
                if isPhysical then
                    for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
                end
                return { success = false, message = "Você não possui uma nota promissória." }
            end
            noteSlot = note.slot
            if not Player.Functions.RemoveItem(note.name, 1, noteSlot) then
                if isPhysical then
                    for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
                end
                return { success = false, message = "Falha ao utilizar a promissória." }
            end
        else
            local safeCost = SanitizeMoney(totalCost)
            if not safeCost then
                if isPhysical then
                    for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
                end
                return { success = false, message = "Valor total inválido." }
            end
            totalCost = safeCost
            
            local playerBalance = (Player.PlayerData.money and Player.PlayerData.money[paymentMethod]) or 0.0
            if playerBalance < totalCost then
                if isPhysical then
                    for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
                end
                return { success = false, message = ("Saldo insuficiente (%s)."):format(paymentMethod == 'cash' and 'Dinheiro' or 'Banco') }
            end

            if not StashManager.UpdateBalance(shopId, totalCost, "sale") then
                if isPhysical then
                    for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
                end
                return { success = false, message = "A registradora está cheia ou indisponível." }
            end

            local paymentSuccess = Player.Functions.RemoveMoney(paymentMethod, totalCost, "shop-purchase-" .. shopId)
            if not paymentSuccess then
                StashManager.UpdateBalance(shopId, -totalCost, "sale-rollback")
                if isPhysical then
                    for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
                end
                return { success = false, message = "Falha ao debitar valor da conta." }
            end
        end

        -- Add Items to Player Inventory
        local addedItems = {}
        local failedAdd = false
        for _, itm in ipairs(validatedItems) do
            if Player.Functions.AddItem(itm.name, itm.amount) then
                TriggerClientEvent('fdb-inventory:client:ItemBox', src, FDBCore.Shared.Items[itm.name], "add")
                table.insert(addedItems, itm)
            else
                failedAdd = true
                break
            end
        end

        if failedAdd then
            for _, itm in ipairs(addedItems) do
                Player.Functions.RemoveItem(itm.name, itm.amount)
            end
            if paymentMethod == 'promissoria' then
                local noteName = (Player.Functions.GetItemByName('promissoria') and 'promissoria') or 'nota_promissoria'
                Player.Functions.AddItem(noteName, 1, noteSlot)
            else
                Player.Functions.AddMoney(paymentMethod, totalCost, "shop-purchase-refund-" .. shopId)
                StashManager.UpdateBalance(shopId, -totalCost, "sale-rollback")
            end
            if isPhysical then
                for _, itm in ipairs(removedFromStash) do exports['fdb-inventory']:AddItem(stashName, itm.name, itm.amount) end
            end
            return { success = false, message = "Espaço insuficiente no inventário." }
        end

        -- Buyer name
        local buyerChar = Player.PlayerData.charinfo
        local buyerName = (buyerChar.firstname or '') .. ' ' .. (buyerChar.lastname or '')
        if buyerName:gsub('%s+', '') == '' then buyerName = "Cidadão " .. Player.PlayerData.citizenid end

        for _, vi in ipairs(validatedItems) do
            ShopManager.LogTransaction(
                shopId, 
                Player.PlayerData.citizenid, 
                paymentMethod == 'promissoria' and 'promissoria' or 'venda', 
                vi.name, 
                vi.amount, 
                vi.unitPrice, 
                vi.subtotal, 
                vi.category,
                buyerName,
                paymentMethod,
                { items = {vi} }
            )
        end

        local msg = paymentMethod == 'promissoria' and 
            ("Compra registrada via Nota Promissória! Total: $%s"):format(string.format("%.2f", totalCost)) or
            ("Compra concluída! Pago: $%s (%s)"):format(string.format("%.2f", totalCost), paymentMethod == 'cash' and 'Dinheiro' or 'Banco')

        fdbLibs:Notify(src, msg, "success", 4000)
        return { success = true }
    end)
    
    FDBShopLocks.Release(src, 'checkout')
    FDBShopLocks.Release(shopLockKey, 'checkout')
    
    if not success then
        print(("[fdb-shops] Error in checkoutCart: %s"):format(tostring(res)))
        return cb({ success = false, message = "Erro interno no checkout." })
    end

    return cb(res)
end)

-- Owner/Employee Actions

RegisterNetEvent('fdb-shops:server:openStash', function(shopId)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not IsPlayerNearShop(src, shopId, 15.0) then
        fdbLibs:Notify(src, "Você está muito longe da loja!", "error")
        return
    end

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
    if not FDBShopLocks.Acquire(src, 'finance') then return end

    local ok, err = pcall(function()
        local Player = FDBCore.Functions.GetPlayer(src)
        if not Player then return end
        
        if not IsPlayerNearShop(src, shopId, 15.0) then
            fdbLibs:Notify(src, "Você está muito longe da loja!", "error")
            return
        end
        
        if not hasStationModule(stationId, shopId, 'finances') then
            fdbLibs:Notify(src, "Este painel não possui módulo financeiro", "error")
            return
        end

        if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'financeiro') then
            local safeAmount = SanitizeMoney(amount)
            if not safeAmount then
                fdbLibs:Notify(src, "Valor inválido.", "error")
                return
            end
            if StashManager.DepositCash(src, shopId, safeAmount) then
                fdbLibs:Notify(src, "Depósito realizado com sucesso", "success")
            else
                fdbLibs:Notify(src, "Falha no depósito. Verifique seu saldo.", "error")
            end
        else
            fdbLibs:Notify(src, "Você não tem permissão para depositar", "error")
        end
    end)
    
    FDBShopLocks.Release(src, 'finance')
    
    if not ok then
        print(("[fdb-shops] Error in depositCash: %s"):format(tostring(err)))
    end
end)

RegisterNetEvent('fdb-shops:server:withdrawCash', function(shopId, stationId, amount)
    local src = source
    if not FDBShopLocks.Acquire(src, 'finance') then return end

    local ok, err = pcall(function()
        local Player = FDBCore.Functions.GetPlayer(src)
        if not Player then return end
        
        if not IsPlayerNearShop(src, shopId, 15.0) then
            fdbLibs:Notify(src, "Você está muito longe da loja!", "error")
            return
        end

        if not hasStationModule(stationId, shopId, 'finances') then
            fdbLibs:Notify(src, "Este painel não possui módulo financeiro", "error")
            return
        end

        if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'financeiro') then
            local safeAmount = SanitizeMoney(amount)
            if not safeAmount then
                fdbLibs:Notify(src, "Valor inválido.", "error")
                return
            end
            local bal = StashManager.GetBalance(shopId)
            if safeAmount > bal then
                fdbLibs:Notify(src, "O caixa não tem saldo suficiente", "error")
                return
            end

            if StashManager.WithdrawCash(src, shopId, safeAmount) then
                fdbLibs:Notify(src, "Saque realizado com sucesso", "success")
            else
                fdbLibs:Notify(src, "Falha no saque.", "error")
            end
        else
            fdbLibs:Notify(src, "Você não tem permissão para sacar", "error")
        end
    end)
    
    FDBShopLocks.Release(src, 'finance')
    
    if not ok then
        print(("[fdb-shops] Error in withdrawCash: %s"):format(tostring(err)))
    end
end)

RegisterNetEvent('fdb-shops:server:updatePriceVariation', function(shopId, stationId, variation)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not IsPlayerNearShop(src, shopId, 15.0) then
        fdbLibs:Notify(src, "Você está muito longe da loja!", "error")
        return
    end

    if not hasStationModule(stationId, shopId, 'prices') then
        fdbLibs:Notify(src, "Este painel não possui módulo de preços", "error")
        return
    end

    if EmployeeManager.HasPermission(shopId, Player.PlayerData.citizenid, 'editar_precos') then
        local shop = ShopManager.GetShop(shopId)
        if not shop then return end

        local variationFloat = tonumber(variation)
        if type(variationFloat) ~= 'number' or variationFloat ~= variationFloat or variationFloat == math.huge or variationFloat == -math.huge then return end

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
