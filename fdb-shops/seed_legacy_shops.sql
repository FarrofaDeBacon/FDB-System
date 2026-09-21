-- FDB System: Seed Database for 20 Legacy Shops
-- Executar no seu HeidiSQL / Banco de Dados

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-valentine', 'normal', 'Valentine General Store', 'new_hanover', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-valentine', 'registradora', '{"x":-315.65,"y":804.28,"z":118.98}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-valentine', 'npc', '{"x":-315.65,"y":804.28,"z":118.98}', 'u_m_m_valgeneralstoreowner_01', 282.89, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-valentine', 'stash', '{"x":-314.15,"y":804.28,"z":118.98}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-valentine', 'craft', '{"x":-317.15,"y":804.28,"z":118.98}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-rhodes', 'normal', 'Rhodes General Store', 'lemoyne', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-rhodes', 'registradora', '{"x":1329.17,"y":-1293.44,"z":77.02}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-rhodes', 'npc', '{"x":1329.17,"y":-1293.44,"z":77.02}', 'u_m_m_rhdgenstoreowner_01', 126.96, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-rhodes', 'stash', '{"x":1330.67,"y":-1293.44,"z":77.02}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-rhodes', 'craft', '{"x":1327.67,"y":-1293.44,"z":77.02}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-annesburg', 'normal', 'Annesburg General Store', 'new_hanover', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-annesburg', 'registradora', '{"x":2930.97,"y":1365.38,"z":45.2}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-annesburg', 'npc', '{"x":2930.97,"y":1365.38,"z":45.2}', 'u_m_m_rhdgenstoreowner_02', 252.02, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-annesburg', 'stash', '{"x":2932.47,"y":1365.38,"z":45.2}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-annesburg', 'craft', '{"x":2929.47,"y":1365.38,"z":45.2}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-stdenis', 'normal', 'Saint Denis General Store', 'lemoyne', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-stdenis', 'registradora', '{"x":2859.36,"y":-1202.19,"z":49.59}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-stdenis', 'npc', '{"x":2859.36,"y":-1202.19,"z":49.59}', 'u_m_m_nbxgeneralstoreowner_01', 14.85, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-stdenis', 'stash', '{"x":2860.86,"y":-1202.19,"z":49.59}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-stdenis', 'craft', '{"x":2857.86,"y":-1202.19,"z":49.59}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-tumbleweed', 'normal', 'Tumbleweed General Store', 'new_austin', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-tumbleweed', 'registradora', '{"x":-5486.04,"y":-2937.99,"z":-0.4}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-tumbleweed', 'npc', '{"x":-5486.04,"y":-2937.99,"z":-0.4}', 's_m_m_unibutchers_01', 131.21, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-tumbleweed', 'stash', '{"x":-5484.54,"y":-2937.99,"z":-0.4}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-tumbleweed', 'craft', '{"x":-5487.54,"y":-2937.99,"z":-0.4}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-armadillo', 'normal', 'Armadillo General Store', 'new_austin', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-armadillo', 'registradora', '{"x":-3687.35,"y":-2623.34,"z":-13.43}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-armadillo', 'npc', '{"x":-3687.35,"y":-2623.34,"z":-13.43}', 'u_m_m_armgeneralstoreowner_01', 276.71, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-armadillo', 'stash', '{"x":-3685.85,"y":-2623.34,"z":-13.43}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-armadillo', 'craft', '{"x":-3688.85,"y":-2623.34,"z":-13.43}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-blackwater', 'normal', 'Blackwater General Store', 'west_elizabeth', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-blackwater', 'registradora', '{"x":-784.77,"y":-1322.15,"z":43.88}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-blackwater', 'npc', '{"x":-784.77,"y":-1322.15,"z":43.88}', 'u_m_o_blwgeneralstoreowner_01', 194.64, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-blackwater', 'stash', '{"x":-783.27,"y":-1322.15,"z":43.88}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-blackwater', 'craft', '{"x":-786.27,"y":-1322.15,"z":43.88}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('gen-vanhorn', 'normal', 'Van Horn General Store', 'new_hanover', '[{"name":"bread","price":0.1},{"name":"water","price":0.1}]', '{"blipSprite":"blip_shop_store"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-vanhorn', 'registradora', '{"x":3025.6,"y":562.29,"z":44.72}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('gen-vanhorn', 'npc', '{"x":3025.6,"y":562.29,"z":44.72}', 's_m_m_unibutchers_01', 262.32, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('gen-vanhorn', 'stash', '{"x":3027.1,"y":562.29,"z":44.72}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('gen-vanhorn', 'craft', '{"x":3024.1,"y":562.29,"z":44.72}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('wep-valentine', 'weapons', 'Valentine Gunsmith', 'new_hanover', '[{"name":"weapon_revolver_cattleman","price":50},{"name":"weapon_repeater_carbine","price":90},{"name":"ammo_box_revolver","price":10},{"name":"ammo_box_repeater","price":10}]', '{"blipSprite":"blip_shop_gunsmith"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-valentine', 'registradora', '{"x":-281.17,"y":778.94,"z":119.5}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('wep-valentine', 'npc', '{"x":-281.17,"y":778.94,"z":119.5}', 'u_m_m_valgunsmith_01', 0.59, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-valentine', 'stash', '{"x":-279.67,"y":778.94,"z":119.5}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('wep-valentine', 'craft', '{"x":-282.67,"y":778.94,"z":119.5}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('wep-tumbleweed', 'weapons', 'Tumbleweed Gunsmith', 'new_austin', '[{"name":"weapon_revolver_cattleman","price":50},{"name":"weapon_repeater_carbine","price":90},{"name":"ammo_box_revolver","price":10},{"name":"ammo_box_repeater","price":10}]', '{"blipSprite":"blip_shop_gunsmith"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-tumbleweed', 'registradora', '{"x":-5506.41,"y":-2963.95,"z":-0.64}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('wep-tumbleweed', 'npc', '{"x":-5506.41,"y":-2963.95,"z":-0.64}', 'u_m_m_tumgunsmith_01', 110.02, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-tumbleweed', 'stash', '{"x":-5504.91,"y":-2963.95,"z":-0.64}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('wep-tumbleweed', 'craft', '{"x":-5507.91,"y":-2963.95,"z":-0.64}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('wep-stdenis', 'weapons', 'Saint Denis Gunsmith', 'lemoyne', '[{"name":"weapon_revolver_cattleman","price":50},{"name":"weapon_repeater_carbine","price":90},{"name":"ammo_box_revolver","price":10},{"name":"ammo_box_repeater","price":10}]', '{"blipSprite":"blip_shop_gunsmith"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-stdenis', 'registradora', '{"x":2717.14,"y":-1286.9,"z":49.64}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('wep-stdenis', 'npc', '{"x":2717.14,"y":-1286.9,"z":49.64}', 'u_m_m_nbxgunsmith_01', 29.91, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-stdenis', 'stash', '{"x":2718.64,"y":-1286.9,"z":49.64}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('wep-stdenis', 'craft', '{"x":2715.64,"y":-1286.9,"z":49.64}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('wep-rhodes', 'weapons', 'Rhodes Gunsmith', 'lemoyne', '[{"name":"weapon_revolver_cattleman","price":50},{"name":"weapon_repeater_carbine","price":90},{"name":"ammo_box_revolver","price":10},{"name":"ammo_box_repeater","price":10}]', '{"blipSprite":"blip_shop_gunsmith"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-rhodes', 'registradora', '{"x":1322.31,"y":-1323.02,"z":77.89}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('wep-rhodes', 'npc', '{"x":1322.31,"y":-1323.02,"z":77.89}', 'u_m_m_rhdgunsmith_01', 354.88, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-rhodes', 'stash', '{"x":1323.81,"y":-1323.02,"z":77.89}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('wep-rhodes', 'craft', '{"x":1320.81,"y":-1323.02,"z":77.89}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('wep-annesburg', 'weapons', 'Annesburg Gunsmith', 'new_hanover', '[{"name":"weapon_revolver_cattleman","price":50},{"name":"weapon_repeater_carbine","price":90},{"name":"ammo_box_revolver","price":10},{"name":"ammo_box_repeater","price":10}]', '{"blipSprite":"blip_shop_gunsmith"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-annesburg', 'registradora', '{"x":2948.42,"y":1319.44,"z":44.82}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('wep-annesburg', 'npc', '{"x":2948.42,"y":1319.44,"z":44.82}', 'u_m_m_asbgunsmith_01', 79.11, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('wep-annesburg', 'stash', '{"x":2949.92,"y":1319.44,"z":44.82}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('wep-annesburg', 'craft', '{"x":2946.92,"y":1319.44,"z":44.82}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('blk-saloon', 'saloon', 'Blackwater Saloon', 'west_elizabeth', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('blk-saloon', 'registradora', '{"x":-817.69,"y":-1319.29,"z":43.68}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('blk-saloon', 'npc', '{"x":-817.69,"y":-1319.29,"z":43.68}', 'u_m_o_blwbartender_01', 281.47, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('blk-saloon', 'stash', '{"x":-816.19,"y":-1319.29,"z":43.68}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('blk-saloon', 'craft', '{"x":-819.19,"y":-1319.29,"z":43.68}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('val-saloon', 'saloon', 'Valentine Saloon', 'new_hanover', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('val-saloon', 'registradora', '{"x":-313.44,"y":806.14,"z":118.98}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('val-saloon', 'npc', '{"x":-313.44,"y":806.14,"z":118.98}', 'u_m_o_blwbartender_01', 283.74, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('val-saloon', 'stash', '{"x":-311.94,"y":806.14,"z":118.98}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('val-saloon', 'craft', '{"x":-314.94,"y":806.14,"z":118.98}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('lab-saloon', 'saloon', 'La Bastille Saloon', 'lemoyne', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('lab-saloon', 'registradora', '{"x":2639.87,"y":-1226.13,"z":53.38}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('lab-saloon', 'npc', '{"x":2639.87,"y":-1226.13,"z":53.38}', 'u_m_o_blwbartender_01', 90.83, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('lab-saloon', 'stash', '{"x":2641.37,"y":-1226.13,"z":53.38}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('lab-saloon', 'craft', '{"x":2638.37,"y":-1226.13,"z":53.38}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('rho-saloon', 'saloon', 'Rhodes Saloon', 'lemoyne', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('rho-saloon', 'registradora', '{"x":1340.25,"y":-1374.71,"z":80.48}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('rho-saloon', 'npc', '{"x":1340.25,"y":-1374.71,"z":80.48}', 'u_m_o_blwbartender_01', 260.32, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('rho-saloon', 'stash', '{"x":1341.75,"y":-1374.71,"z":80.48}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('rho-saloon', 'craft', '{"x":1338.75,"y":-1374.71,"z":80.48}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('ann-saloon', 'saloon', 'Annesburg Saloon', 'new_hanover', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('ann-saloon', 'registradora', '{"x":2966.13,"y":1353.66,"z":44.86}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('ann-saloon', 'npc', '{"x":2966.13,"y":1353.66,"z":44.86}', 'u_m_o_blwbartender_01', 80.05, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('ann-saloon', 'stash', '{"x":2967.63,"y":1353.66,"z":44.86}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('ann-saloon', 'craft', '{"x":2964.63,"y":1353.66,"z":44.86}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('old-saloon', 'saloon', 'Old Light Saloon', 'new_hanover', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('old-saloon', 'registradora', '{"x":2948.17,"y":528.08,"z":45.34}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('old-saloon', 'npc', '{"x":2948.17,"y":528.08,"z":45.34}', 'u_m_o_blwbartender_01', 182.96, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('old-saloon', 'stash', '{"x":2949.67,"y":528.08,"z":45.34}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('old-saloon', 'craft', '{"x":2946.67,"y":528.08,"z":45.34}', 'mini@repair', 'fixing_a_ped');

INSERT IGNORE INTO shops (shop_id, template_id, label, region_id, buy_catalog, config) VALUES ('tumble-saloon', 'saloon', 'Tumbleweed Saloon', 'UNKNOWN', '[{"name":"beer","price":1},{"name":"stew","price":3}]', '{"blipSprite":"blip_saloon"}');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('tumble-saloon', 'registradora', '{"x":-5518.5,"y":-2906.52,"z":-1.75}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, npc_model, npc_heading, animation_name) VALUES ('tumble-saloon', 'npc', '{"x":-5518.5,"y":-2906.52,"z":-1.75}', 'u_m_o_blwbartender_01', 216.14, 'WORLD_HUMAN_WRITE_NOTEBOOK');
INSERT IGNORE INTO shop_stations (shop_id, type, position) VALUES ('tumble-saloon', 'stash', '{"x":-5517,"y":-2906.52,"z":-1.75}');
INSERT IGNORE INTO shop_stations (shop_id, type, position, animation_dict, animation_name) VALUES ('tumble-saloon', 'craft', '{"x":-5520,"y":-2906.52,"z":-1.75}', 'mini@repair', 'fixing_a_ped');

