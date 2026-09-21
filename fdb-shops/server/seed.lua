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

CreateThread(function()
    Wait(5000) -- Wait for schemas and ShopManager to load

    local check = MySQL.scalar.await('SELECT COUNT(*) FROM shop_templates')
    if check and check > 0 then
        -- Already seeded
        return
    end

    print(('^3[%s] Starting one-time database migration from old Config...^7'):format(resourceName))

    -- 1. Create Templates
    for tId, tData in pairs(defaultTemplates) do
        MySQL.insert('INSERT INTO shop_templates (template_id, label, sellable_items, default_config) VALUES (?, ?, ?, ?)', {
            tId, 
            tData.label, 
            json.encode(tData.sellable), 
            json.encode({ defaultNpc = tData.npc })
        })
    end

    -- 2. Migrate Config.StoreLocations to DB
    if Config and Config.StoreLocations then
        for _, loc in ipairs(Config.StoreLocations) do
            local templateId = loc.products
            local shopId = loc.name
            local label = loc.label
            
            local coords = loc.shopcoords
            local npcCoords = loc.npccoords
            local npcModel = loc.npcmodel or "s_m_m_unibutchers_01"
            local blip = loc.blipsprite

            -- Find region
            local zoneName = exports['fdb-core']:GetZoneAtCoords(coords) or "UNKNOWN"
            local regionId = exports['fdb-economy']:resolveRegion(zoneName)

            -- Insert Shop
            MySQL.insert('INSERT INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES (?, ?, ?, ?, ?, ?)', {
                shopId, 
                templateId, 
                label, 
                regionId,
                json.encode(defaultTemplates[templateId].sellable),
                json.encode({ blipSprite = blip })
            })

            -- Insert Register Station
            MySQL.insert('INSERT INTO shop_stations (shop_id, type, position) VALUES (?, ?, ?)', {
                shopId, 'registradora', json.encode({ x = coords.x, y = coords.y, z = coords.z })
            })

            -- Insert NPC Station
            if npcCoords then
                MySQL.insert('INSERT INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES (?, ?, ?, ?, ?, ?)', {
                    shopId, 'npc', 
                    json.encode({ x = npcCoords.x, y = npcCoords.y, z = npcCoords.z }), 
                    npcModel, npcCoords.w, loc.scenario
                })
            end
        end
    end

    print(('^2[%s] Database migration completed successfully.^7'):format(resourceName))
end)
