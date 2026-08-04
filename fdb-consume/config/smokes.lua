local items = {
    ['cigar'] = {
        type = "Smoke",
        hunger = 0,
        thirst = -5,
        stress = -20,
        alcohol = 0,
        health = 5,
        stamina = 5,
        prop = "p_cigar01x",
        offsets = {
            bone = "SKEL_R_Finger12",
            mouth_start = { x = -0.0, y = 0.0, z = 0.000, rx = 0.0, ry = 0.0, rz = 0.0 },
            hand_enter = { x = 0.040, y = -0.050, z = 0.015, rx = -150.0, ry = 142.0, rz = -40.0 },
            mouth_puff = { x = -0.020, y = 0.115, z = 0.000, rx = 0.0, ry = 0.0, rz = 0.0 },
            hand_idle = { x = 0.040, y = -0.050, z = 0.015, rx = -150.0, ry = 142.0, rz = -40.0 },
            female_hand_idle = { x = 0.01, y = 0.0, z = 0.01, rx = 0.0, ry = -160.0, rz = -130.0 }
        }
    },
    ['cigarette'] = {
        type = "Smoke",
        hunger = 0,
        thirst = -2,
        stress = -10,
        alcohol = 0,
        health = 2,
        stamina = 2,
        prop = "p_cigarette01x",
        offsets = {
            bone = "SKEL_R_Finger13",
            mouth_start = { x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
            hand_enter = { x = 0.03, y = -0.01, z = 0.0, rx = 0.0, ry = 90.0, rz = 0.0 },
            mouth_puff = { x = -0.017, y = 0.1, z = -0.01, rx = 0.0, ry = 90.0, rz = -90.0 },
            hand_idle = { x = 0.017, y = -0.01, z = -0.01, rx = 0.0, ry = 120.0, rz = 10.0 },
            female_hand_idle = { x = 0.01, y = 0.0, z = 0.01, rx = 0.0, ry = -160.0, rz = -130.0 }
        }
    },
    ['chewing_tobacco'] = {
        type = "Chew", -- Usa o novo método assíncrono de mastigar
        hunger = 0,
        thirst = -5,
        stress = -15,
        alcohol = 0,
        health = 0,
        stamina = 20,
        dict = "mech_pickup@system@lh@use", -- Animação de abrir a lata e colocar na boca
        name = "2h_tabacco",
        prop = "p_tobaccopouch01x", -- Prop 100% válido do RedM (bolsa de tabaco)
        offsets = {
            bone = "SKEL_R_Finger13",
            mouth_start = { x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
            hand_enter = { x = 0.03, y = -0.01, z = 0.0, rx = 0.0, ry = 90.0, rz = 0.0 },
            mouth_puff = { x = -0.017, y = 0.1, z = -0.01, rx = 0.0, ry = 90.0, rz = -90.0 },
            hand_idle = { x = 0.017, y = -0.01, z = -0.01, rx = 0.0, ry = 120.0, rz = 10.0 },
            female_hand_idle = { x = 0.01, y = 0.0, z = 0.01, rx = 0.0, ry = -160.0, rz = -130.0 }
        }
    }
}

Config.AddItems(items)
