-- ============================================================
-- FDB System | fdb-shops | server/admin_commands.lua
-- Admin Commands for CRUD operations on Shops
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local fdbLibs = exports['fdb-libs']

-- /shopcreate [templateId] [shopId] [label]
FDBCore.Commands.Add('shopcreate', 'Criar uma nova loja física a partir de um template', {
    {name = 'templateId', help = 'ID do Template (ex: gen_store, gunsmith)'},
    {name = 'shopId', help = 'ID único da loja (ex: val_gen_01)'},
    {name = 'label', help = 'Nome de exibição da loja'}
}, true, function(source, args)
    local templateId = args[1]
    local shopId = args[2]
    local label = table.concat(args, ' ', 3)

    if not templateId or not shopId or not label or label == '' then
        fdbLibs:Notify(source, '/shopcreate [template] [id] [nome]', 'error')
        return
    end

    if not ShopManager.Templates[templateId] then
        fdbLibs:Notify(source, 'Template não encontrado: ' .. templateId, 'error')
        return
    end

    if ShopManager.Shops[shopId] then
        fdbLibs:Notify(source, 'Loja com ID ' .. shopId .. ' já existe.', 'error')
        return
    end

    -- The physical placement of stations (NPC, register) would normally be handled 
    -- through an admin UI/tool, but this command initializes the DB record.
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    MySQL.insert('INSERT INTO shops (shop_id, template_id, label, config) VALUES (?, ?, ?, ?)', {
        shopId, templateId, label, json.encode({})
    })

    -- Instatiate in memory cache
    ShopManager.Shops[shopId] = {
        templateId = templateId,
        label = label,
        ownerId = nil,
        enabledRecipes = {},
        enabledSellItems = {},
        buyCatalog = {},
        sellCatalog = {},
        cashBalance = 0.0,
        ownerPriceVariation = 0.0,
        maxPriceVariation = 0.15,
        regionId = nil,
        config = {}
    }

    ShopManager.UpdateShopRegion(shopId, coords)

    -- Create Default Test Stations around the player
    local cx, cy, cz = coords.x, coords.y, coords.z

    -- 1. Register
    MySQL.insert('INSERT INTO shop_stations (shop_id, type, position) VALUES (?, ?, ?)', {
        shopId, 'registradora', json.encode({ x = cx, y = cy, z = cz })
    })

    -- 2. Physical Stash
    MySQL.insert('INSERT INTO shop_stations (shop_id, type, position) VALUES (?, ?, ?)', {
        shopId, 'bau', json.encode({ x = cx + 1.5, y = cy, z = cz })
    })

    -- 3. Craft Station (allowing all template recipes by default for testing)
    local allowedRecipes = {}
    if ShopManager.Templates[templateId] and ShopManager.Templates[templateId].craftableRecipes then
        for _, r in ipairs(ShopManager.Templates[templateId].craftableRecipes) do
            if r.id then table.insert(allowedRecipes, r.id) end
        end
    end

    MySQL.insert('INSERT INTO shop_stations (shop_id, type, position, allowed_recipes, animation_dict, animation_name) VALUES (?, ?, ?, ?, ?, ?)', {
        shopId, 'craft', json.encode({ x = cx - 1.5, y = cy, z = cz }), json.encode(allowedRecipes), 'mini@repair', 'fixing_a_ped'
    })

    -- 4. Enable Recipes in shop_recipes table
    if #allowedRecipes > 0 then
        for _, recipeId in ipairs(allowedRecipes) do
            MySQL.insert('INSERT IGNORE INTO shop_recipes (shop_id, recipe_id) VALUES (?, ?)', { shopId, recipeId })
            table.insert(ShopManager.Shops[shopId].enabledRecipes, recipeId)
        end
    end

    fdbLibs:Notify(source, 'Loja salva! REINICIE o script (ensure fdb-shops) para spawnar os blips e bancadas.', 'success', 8000)
end, 'admin')

-- Teleporta até uma loja existente (Para testes do admin)
FDBCore.Commands.Add('shopgo', 'Teleporta até uma loja', {{name = 'shopId', help = 'ID da loja (ex: gen-valentine)'}}, true, function(source, args)
    local shopId = args[1]
    if not shopId then return end
    
    -- Busca as coordenadas da registradora ou do npc dessa loja
    local result = MySQL.query.await('SELECT position FROM shop_stations WHERE shop_id = ? LIMIT 1', { shopId })
    if result and result[1] then
        local pos = json.decode(result[1].position)
        local Player = FDBCore.Functions.GetPlayer(source)
        
        if pos and pos.x then
            -- SetPedCoordsKeepVehicle requires x,y,z
            SetEntityCoords(GetPlayerPed(source), pos.x, pos.y, pos.z, false, false, false, false)
            fdbLibs:Notify(source, 'Teleportado para a loja: ' .. shopId, 'success', 3000)
        end
    else
        fdbLibs:Notify(source, 'Loja não encontrada', 'error', 3000)
    end
end, 'admin')

-- Comando para mover uma bancada/NPC para onde o admin está pisando
FDBCore.Commands.Add('shopmovestation', 'Move uma bancada/NPC para sua posição atual', {
    {name = 'shopId', help = 'ID da loja (ex: gen-valentine)'},
    {name = 'type', help = 'Tipo (registradora, npc, bau, craft, etc)'}
}, true, function(source, args)
    local shopId = args[1]
    local type = args[2]
    if not shopId or not type then return end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local posStr = json.encode({ x = math.floor(coords.x*100)/100, y = math.floor(coords.y*100)/100, z = math.floor(coords.z*100)/100 })
    
    local rows = MySQL.update.await('UPDATE shop_stations SET position = ?, npc_heading = ? WHERE shop_id = ? AND type = ?', {
        posStr, heading, shopId, type
    })
    
    if rows > 0 then
        fdbLibs:Notify(source, ('Bancada %s atualizada! Dê /shopreload'):format(type), 'success', 5000)
    else
        fdbLibs:Notify(source, 'Bancada não encontrada nessa loja.', 'error', 5000)
    end
end, 'admin')


-- /shopsetowner [shopId] [citizenid]
FDBCore.Commands.Add('shopsetowner', 'Define o dono de uma loja', {
    {name = 'shopId', help = 'ID único da loja'},
    {name = 'citizenid', help = 'Citizen ID do jogador (ou 0 para remover)'}
}, true, function(source, args)
    local shopId = args[1]
    local citizenid = args[2]

    if not shopId or not citizenid then
        return
    end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        fdbLibs:Notify(source, 'Loja não encontrada', 'error')
        return
    end

    if citizenid == '0' or citizenid == '' then
        citizenid = nil
    end

    if citizenid then
        local ownedCount = 0
        for _, s in pairs(ShopManager.Shops) do
            if s.ownerId == citizenid then
                ownedCount = ownedCount + 1
            end
        end

        if ownedCount >= Config.MaxShopsPerOwner then
            fdbLibs:Notify(source, 'Jogador atingiu o limite de lojas: ' .. Config.MaxShopsPerOwner, 'error')
            return
        end
    end

    shop.ownerId = citizenid
    MySQL.update('UPDATE shops SET owner_id = ? WHERE shop_id = ?', {citizenid, shopId})

    fdbLibs:Notify(source, 'Dono atualizado para: ' .. (citizenid or "Nenhum"), 'success')
end, 'admin')

-- /shopinfo [shopId]
FDBCore.Commands.Add('shopinfo', 'Exibe informações de debug da loja', {
    {name = 'shopId', help = 'ID único da loja'}
}, true, function(source, args)
    local shopId = args[1]
    if not shopId then return end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        fdbLibs:Notify(source, 'Loja não encontrada', 'error')
        return
    end

    print(('--- INFO LOJA %s ---'):format(shopId))
    print('Template:', shop.templateId)
    print('Label:', shop.label)
    print('Owner:', shop.ownerId or "Nenhum")
    print('Region:', shop.regionId or "Nenhuma")
    print('Caixa:', shop.cashBalance)
    print('Variação Dono:', shop.ownerPriceVariation)
end, 'admin')
