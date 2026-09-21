-- ============================================================
-- FDB System | fdb-shops | server/seed.lua
-- One-time migration script to populate DB from old Config
-- ============================================================

local FDBCore = exports['fdb-core']:GetCoreObject()
local resourceName = GetCurrentResourceName()

-- Defines default templates based on old config logic
local defaultTemplates = {
    ['normal'] = {
        label = "Armazém Geral",
        sellable = {
            { name = 'bread', price = 0.10 },
            { name = 'water', price = 0.10 },
        },
        npc = "u_m_m_rhdgenstoreowner_01"
    },
    ['weapons'] = {
        label = "Armeiro",
        sellable = {
            { name = 'weapon_revolver_cattleman', price = 50 },
            { name = 'weapon_repeater_carbine', price = 90 },
            { name = 'ammo_box_revolver', price = 10 },
            { name = 'ammo_box_repeater', price = 10 },
        },
        npc = "u_m_m_valgunsmith_01"
    },
    ['saloon'] = {
        label = "Saloon",
        sellable = {
            { name = 'beer', price = 1.0 },
            { name = 'stew', price = 3.0 },
        },
        npc = "u_m_o_blwbartender_01"
    },
    ['armoury'] = {
        label = "Arsenal Policial",
        sellable = {
            { name = 'weapon_revolver_cattleman', price = 0 },
            { name = 'ammo_box_revolver', price = 0 }
        },
        npc = "s_m_m_unibutchers_01"
    },
    ['medic'] = {
        label = "Farmácia",
        sellable = {
            { name = 'bandage', price = 0 },
            { name = 'firstaid', price = 0 }
        },
        npc = "s_m_m_unibutchers_01"
    },
    ['prison'] = {
        label = "Cantina Prisional",
        sellable = {
            { name = 'bread', price = 0.10 },
            { name = 'water', price = 0.10 }
        },
        npc = "s_m_m_unibutchers_01"
    }
}

local fallbackStores = {
    {
        label = 'Valentine General Store',
        name = 'gen-valentine',
        products = 'normal',
        shopcoords = vec3(-315.65, 804.28, 118.98),
        npccoords = vec4(-315.65, 804.28, 118.98, 282.89),
        npcmodel = 'u_m_m_valgeneralstoreowner_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Rhodes General Store',
        name = 'gen-rhodes',
        products = 'normal',
        shopcoords = vec3(1329.17, -1293.44, 77.02),
        npccoords = vec4(1329.17, -1293.44, 77.02, 126.96),
        npcmodel = 'u_m_m_rhdgenstoreowner_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Annesburg General Store',
        name = 'gen-annesburg',
        products = 'normal',
        shopcoords = vec3(2930.97, 1365.38, 45.20),
        npccoords = vec4(2930.97, 1365.38, 45.20, 252.02),
        npcmodel = 'u_m_m_rhdgenstoreowner_02',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Saint Denis General Store',
        name = 'gen-stdenis',
        products = 'normal',
        shopcoords = vec3(2859.36, -1202.19, 49.59),
        npccoords = vec4(2859.36, -1202.19, 49.59, 14.85),
        npcmodel = 'u_m_m_nbxgeneralstoreowner_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Tumbleweed General Store',
        name = 'gen-tumbleweed',
        products = 'normal',
        shopcoords = vec3(-5486.04, -2937.99, -0.40),
        npccoords = vec4(-5486.04, -2937.99, -0.40, 131.21),
        npcmodel = 's_m_m_unibutchers_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Armadillo General Store',
        name = 'gen-armadillo',
        products = 'normal',
        shopcoords = vec3(-3687.35, -2623.34, -13.43),
        npccoords = vec4(-3687.35, -2623.34, -13.43, 276.71),
        npcmodel = 'u_m_m_armgeneralstoreowner_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Blackwater General Store',
        name = 'gen-blackwater',
        products = 'normal',
        shopcoords = vec3(-784.77, -1322.15, 43.88),
        npccoords = vec4(-784.77, -1322.15, 43.88, 194.64),
        npcmodel = 'u_m_o_blwgeneralstoreowner_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Van Horn General Store',
        name = 'gen-vanhorn',
        products = 'normal',
        shopcoords = vec3(3025.60, 562.29, 44.72),
        npccoords = vec4(3025.60, 562.29, 44.72, 262.32),
        npcmodel = 's_m_m_unibutchers_01',
        blipsprite = 'blip_shop_store'
    },
    {
        label = 'Valentine Gunsmith',
        name = 'wep-valentine',
        products = 'weapons',
        shopcoords = vec3(-281.17, 778.94, 119.50),
        npccoords = vec4(-281.17, 778.94, 119.50, 0.59),
        npcmodel = 'u_m_m_valgunsmith_01',
        blipsprite = 'blip_shop_gunsmith'
    },
    {
        label = 'Tumbleweed Gunsmith',
        name = 'wep-tumbleweed',
        products = 'weapons',
        shopcoords = vec3(-5506.41, -2963.95, -0.64),
        npccoords = vec4(-5506.41, -2963.95, -0.64, 110.02),
        npcmodel = 'u_m_m_tumgunsmith_01',
        blipsprite = 'blip_shop_gunsmith'
    },
    {
        label = 'Saint Denis Gunsmith',
        name = 'wep-stdenis',
        products = 'weapons',
        shopcoords = vec3(2717.14, -1286.90, 49.64),
        npccoords = vec4(2717.14, -1286.90, 49.64, 29.91),
        npcmodel = 'u_m_m_nbxgunsmith_01',
        blipsprite = 'blip_shop_gunsmith'
    },
    {
        label = 'Rhodes Gunsmith',
        name = 'wep-rhodes',
        products = 'weapons',
        shopcoords = vec3(1322.31, -1323.02, 77.89),
        npccoords = vec4(1322.31, -1323.02, 77.89, 354.88),
        npcmodel = 'u_m_m_rhdgunsmith_01',
        blipsprite = 'blip_shop_gunsmith'
    },
    {
        label = 'Annesburg Gunsmith',
        name = 'wep-annesburg',
        products = 'weapons',
        shopcoords = vec3(2948.42, 1319.44, 44.82),
        npccoords = vec4(2948.42, 1319.44, 44.82, 79.11),
        npcmodel = 'u_m_m_asbgunsmith_01',
        blipsprite = 'blip_shop_gunsmith'
    },
    {
        label = 'Blackwater Saloon',
        name = 'blk-saloon',
        products = 'saloon',
        shopcoords = vec3(-817.69, -1319.29, 43.68),
        npccoords = vec4(-817.69, -1319.29, 43.68, 281.47),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    },
    {
        label = 'Valentine Saloon',
        name = 'val-saloon',
        products = 'saloon',
        shopcoords = vec3(-313.44, 806.14, 118.98),
        npccoords = vec4(-313.44, 806.14, 118.98, 283.74),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    },
    {
        label = 'La Bastille Saloon',
        name = 'lab-saloon',
        products = 'saloon',
        shopcoords = vec3(2639.87, -1226.13, 53.38),
        npccoords = vec4(2639.87, -1226.13, 53.38, 90.83),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    },
    {
        label = 'Rhodes Saloon',
        name = 'rho-saloon',
        products = 'saloon',
        shopcoords = vec3(1340.25, -1374.71, 80.48),
        npccoords = vec4(1340.25, -1374.71, 80.48, 260.32),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    },
    {
        label = 'Annesburg Saloon',
        name = 'ann-saloon',
        products = 'saloon',
        shopcoords = vec3(2966.13, 1353.66, 44.86),
        npccoords = vec4(2966.13, 1353.66, 44.86, 80.05),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    },
    {
        label = 'Old Light Saloon',
        name = 'old-saloon',
        products = 'saloon',
        shopcoords = vec3(2948.17, 528.08, 45.34),
        npccoords = vec4(2948.17, 528.08, 45.34, 182.96),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    },
    {
        label = 'Tumbleweed Saloon',
        name = 'tumble-saloon',
        products = 'saloon',
        shopcoords = vec3(-5518.50, -2906.52, -1.75),
        npccoords = vec4(-5518.50, -2906.52, -1.75, 216.14),
        npcmodel = 'u_m_o_blwbartender_01',
        blipsprite = 'blip_saloon'
    }
}

local function GuessRegion(shopName)
    local n = string.lower(shopName)
    if n:find("valentine") or n:find("annesburg") or n:find("vanhorn") or n:find("val-") or n:find("ann-") or n:find("old-") then return "new_hanover" end
    if n:find("rhodes") or n:find("stdenis") or n:find("rho-") or n:find("lab-") then return "lemoyne" end
    if n:find("tumbleweed") or n:find("armadillo") or n:find("tum-") or n:find("arm-") then return "new_austin" end
    if n:find("blackwater") or n:find("blk-") then return "west_elizabeth" end
    return nil
end

CreateThread(function()
    Wait(5000) -- Wait for schemas and ShopManager to load

    local check = MySQL.scalar.await('SELECT COUNT(*) FROM shops')
    if check and check > 10 then
        -- Already seeded shops
        return
    end

    print(('^3[%s] Starting one-time database migration from old Config...^7'):format(resourceName))

    -- 1. Create Templates
    for tId, tData in pairs(defaultTemplates) do
        MySQL.insert('INSERT IGNORE INTO shop_templates (template_id, label, sellable_items, default_config) VALUES (?, ?, ?, ?)', {
            tId, 
            tData.label, 
            json.encode(tData.sellable), 
            json.encode({ defaultNpc = tData.npc })
        })
    end

    -- 2. Migrate Config.StoreLocations to DB
    local storesToMigrate = (Config and Config.StoreLocations) or fallbackStores
    if storesToMigrate then
        for _, loc in ipairs(storesToMigrate) do
            local templateId = loc.products
            local shopId = loc.name
            local label = loc.label
            
            local coords = loc.shopcoords
            local npcCoords = loc.npccoords
            local npcModel = loc.npcmodel or "s_m_m_unibutchers_01"
            local blip = loc.blipsprite

            -- Find region
            local regionId = GuessRegion(shopId)

            -- Insert Shop
            MySQL.insert('INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES (?, ?, ?, ?, ?, ?)', {
                shopId, 
                templateId, 
                label, 
                regionId,
                json.encode(defaultTemplates[templateId].sellable),
                json.encode({ blipSprite = blip })
            })

            -- Insert Register Station
            MySQL.insert('INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES (?, ?, ?)', {
                shopId, 'registradora', json.encode({ x = coords.x, y = coords.y, z = coords.z })
            })

            -- Insert NPC Station
            if npcCoords then
                MySQL.insert('INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES (?, ?, ?, ?, ?, ?)', {
                    shopId, 'npc', 
                    json.encode({ x = npcCoords.x, y = npcCoords.y, z = npcCoords.z }), 
                    npcModel, npcCoords.w, loc.scenario
                })
            end
        end
    end

    print(('^2[%s] Database migration completed successfully.^7'):format(resourceName))
end)
