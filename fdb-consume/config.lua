Config = {}
lib.locale()

Config.Drop = locale('prompt_drop')
Config.Smoke = locale('prompt_bite')
Config.Chug = locale('prompt_chug')
Config.Change = locale('prompt_change_pose')

Config.Prompts = {
    DropKey = 0x27D1C284, -- R
    SmokeKey = 0x07CE1E61, -- Clique Botão Esquerdo do Mouse
    ChugKey = 0xF84FA74F,  -- Clique Botão Direito do Mouse (INPUT_INTERACT_LOCKON_POS / RIGHT MOUSE)
    ChangeKey = 0xCC1075A7 -- Roda do Mouse para Baixo
}

-- Animações Padrão
Config.Animations = {
    Eat = { dict = "mech_inventory@eating@multi_bite@sphere_d8-2_sandwich", name = "quick_right_hand", prop = "s_inv_bread01x", time = 5000, uses = 3 },
    Drink = { dict = "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5", name = "chug_a", prop = "p_bottleBeer01x", time = 5000, uses = 3 },
    Stew = { dict = "mech_inventory@eating@multi_bite@stew", name = "quick_inv_eat_stew", prop = "p_bowl04x_stew", time = 8000, uses = 1 },
    Coffee = { dict = "", name = "", prop = "p_mug01_coffee", time = 5000, uses = 3 }, -- Coffee usa Native Invoke
    Canned = { dict = "mech_inventory@eating@canned_food@cylinder@d8-2_h10-5", name = "right_hand", prop = "s_canrigapricots01x", time = 8000, uses = 3 },
    Medical = { dict = "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5", name = "chug_a", prop = "p_bottlejd01x", time = 4000, uses = 1 },
    Drug = { dict = "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5", name = "chug_a", prop = "p_cs_bottle_moonshine", time = 4000, uses = 1 },
    Smoke = { dict = "amb_rest@world_human_smoke_cigar@male_a@idle_a", name = "idle_a", prop = "p_cigar01x", time = 8000, uses = 999 }
}

-- Itens Consumíveis e seus Efeitos
Config.Items = {}

function Config.AddItems(newItems)
    print("^3[fdb-consume] Config.AddItems chamado!^7")
    local count = 0
    for k, v in pairs(newItems) do
        Config.Items[k] = v
        count = count + 1
    end
    print("^3[fdb-consume] Adicionados " .. count .. " itens ao Config.Items^7")
end
