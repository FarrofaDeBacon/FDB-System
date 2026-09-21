-- ============================================================
-- FDB System | fdb-shops | server/admin_commands.lua
-- Admin Commands for CRUD operations on Shops
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()

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
        TriggerClientEvent('ox_lib:notify', source, {title = 'Uso Incorreto', description = '/shopcreate [template] [id] [nome]', type = 'error'})
        return
    end

    if not ShopManager.Templates[templateId] then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Erro', description = 'Template não encontrado: ' .. templateId, type = 'error'})
        return
    end

    if ShopManager.Shops[shopId] then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Erro', description = 'Loja com ID ' .. shopId .. ' já existe.', type = 'error'})
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

    TriggerClientEvent('ox_lib:notify', source, {title = 'Sucesso', description = 'Loja criada e adicionada à memória.', type = 'success'})
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
        TriggerClientEvent('ox_lib:notify', source, {title = 'Erro', description = 'Loja não encontrada', type = 'error'})
        return
    end

    if citizenid == '0' or citizenid == '' then
        citizenid = nil
    end

    shop.ownerId = citizenid
    MySQL.update('UPDATE shops SET owner_id = ? WHERE shop_id = ?', {citizenid, shopId})

    TriggerClientEvent('ox_lib:notify', source, {title = 'Sucesso', description = 'Dono atualizado para: ' .. (citizenid or "Nenhum"), type = 'success'})
end, 'admin')

-- /shopinfo [shopId]
FDBCore.Commands.Add('shopinfo', 'Exibe informações de debug da loja', {
    {name = 'shopId', help = 'ID único da loja'}
}, true, function(source, args)
    local shopId = args[1]
    if not shopId then return end

    local shop = ShopManager.GetShop(shopId)
    if not shop then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Erro', description = 'Loja não encontrada', type = 'error'})
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
