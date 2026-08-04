local medicalStages = {
    { name = 'hand_idle', animDict = 'amb_rest@world_human_smoking@male_c@base', animName = 'base', bone = 'SKEL_R_HAND' }
}

local items = {
    ['horse_stimulant'] = {
        type = "Medical",
        hunger = 0,
        thirst = 0,
        stress = -10,
        alcohol = 0,
        health = 50,
        stamina = 50,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.0, y = 0.0, z = 0.04, rx = 0.0, ry = 0.0, rz = 0.0 } },
        editorStages = medicalStages
    },
    ['horse_reviver'] = {
        type = "Medical",
        hunger = 0,
        thirst = 0,
        stress = -20,
        alcohol = 0,
        health = 100,
        stamina = 100,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.0, y = 0.0, z = 0.04, rx = 0.0, ry = 0.0, rz = 0.0 } },
        editorStages = medicalStages
    },
    ['medicine'] = {
        type = "Medical",
        hunger = 0,
        thirst = 0,
        stress = -10,
        alcohol = 0,
        health = 20,
        stamina = 20,
        cureIllness = true,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.0, y = 0.0, z = 0.04, rx = 0.0, ry = 0.0, rz = 0.0 } },
        editorStages = medicalStages
    },
    ['antidote'] = {
        type = "Medical",
        hunger = 0,
        thirst = 0,
        stress = -10,
        alcohol = 0,
        health = 20,
        stamina = 20,
        curePoison = true,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.0, y = 0.0, z = 0.04, rx = 0.0, ry = 0.0, rz = 0.0 } },
        editorStages = medicalStages
    }
}

Config.AddItems(items)
