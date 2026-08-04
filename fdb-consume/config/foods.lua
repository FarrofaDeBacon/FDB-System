local foodStages = {
    { name = 'hand_idle', animDict = 'amb_rest@world_human_smoking@male_c@base', animName = 'base', bone = 'SKEL_R_HAND' }
}

local items = {
    ['bread'] = {
        type = "Eat",
        hunger = 25,
        thirst = 0,
        stress = 5,
        alcohol = 0,
        health = 5,
        stamina = 0,
        prop = "s_inv_bread01x",
        offsets = { hand_idle = { x = 0.1, y = 0.0, z = -0.05, rx = -90.0, ry = 0.0, rz = 0.0 } },
        editorStages = foodStages,
        uses = 5
    },
    ['stew'] = {
        type = "Stew",
        hunger = 50,
        thirst = 25,
        stress = 20,
        alcohol = -10,
        health = 20,
        stamina = 20,
        prop = "p_bowl04x_stew",
        offsets = { hand_idle = { x = 0.1, y = -0.01, z = -0.07, rx = -90.0, ry = 100.0, rz = 0.0 } },
        editorStages = foodStages,
        uses = 1
    },
    ['canned_apricots'] = {
        type = "Canned",
        hunger = 50,
        thirst = 20,
        stress = 10,
        alcohol = -3,
        health = 10,
        prop = "p_canned_apricot01x",
        offsets = { hand_idle = { x = 0.10, y = -0.01, z = -0.07, rx = -90.0, ry = 10.0, rz = 0.0 } },
        editorStages = foodStages,
        uses = 4
    },
    ['canned_beans'] = {
        type = "Canned",
        hunger = 60,
        thirst = 10,
        stress = 5,
        health = 15,
        prop = "p_canned_beans01x",
        offsets = { hand_idle = { x = 0.10, y = -0.01, z = -0.07, rx = -90.0, ry = 10.0, rz = 0.0 } },
        editorStages = foodStages,
        uses = 4
    },
    ['apple'] = {
        type = "Eat",
        hunger = 15,
        thirst = 10,
        health = 5,
        prop = "p_apple01x",
        offsets = { hand_idle = { x = 0.1, y = -0.01, z = -0.07, rx = -90.0, ry = 100.0, rz = 0.0 } },
        editorStages = foodStages,
        uses = 2
    },
    ['cheese'] = {
        type = "Eat",
        hunger = 30,
        thirst = -5,
        health = 5,
        prop = "p_baitcheese01x",
        offsets = { hand_idle = { x = 0.1, y = -0.01, z = -0.07, rx = -90.0, ry = 100.0, rz = 0.0 } },
        editorStages = foodStages,
        uses = 3
    }
}

Config.AddItems(items)

