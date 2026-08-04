local drinkStages = {
    { name = 'hand_idle', animDict = 'amb_rest@world_human_smoking@male_c@base', animName = 'base', bone = 'SKEL_R_HAND' }
}

local items = {
    ['water'] = {
        type = "Drink",
        hunger = 0,
        thirst = 50,
        stress = 5,
        alcohol = -5,
        health = 0,
        stamina = 5,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 } },
        editorStages = drinkStages,
        uses = 1,
        give = { item = "empty_bottle", count = 1 }
    },
    ['beer'] = {
        type = "Drink",
        hunger = -3,
        thirst = 0,
        stress = -10,
        alcohol = 25,
        health = 5,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 } },
        editorStages = drinkStages,
        uses = 5,
        give = { item = "empty_bottle", count = 1 }
    },
    ['coffee'] = {
        type = "Coffee",
        hunger = 5,
        thirst = 15,
        stress = -20,
        alcohol = 0,
        health = 5,
        stamina = 15,
        prop = "p_mug01_coffee",
        offsets = { hand_idle = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 } },
        editorStages = drinkStages,
        uses = 4,
        give = { item = "empty_mug", count = 1 }
    },
    ['whiskey'] = {
        type = "Drink",
        hunger = 0,
        thirst = 10,
        stress = -30,
        alcohol = 20,
        health = -5,
        stamina = 0,
        uses = 3,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 } },
        editorStages = drinkStages,
        give = { item = "empty_bottle", count = 1 }
    },
    ['guarma_rum'] = {
        type = "Drink",
        hunger = 0,
        thirst = 10,
        stress = -25,
        alcohol = 25,
        health = -10,
        stamina = 30,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 } },
        editorStages = drinkStages,
        give = { item = "empty_bottle", count = 1 }
    },
    ['milk'] = {
        type = "Drink",
        hunger = 10,
        stress = -5,
        alcohol = -10,
        health = 10,
        stamina = 5,
        uses = 5,
        prop = "p_bottle01x",
        offsets = { hand_idle = { x = 0.05, y = -0.07, z = -0.05, rx = -75.0, ry = 60.0, rz = 0.0 } },
        editorStages = drinkStages,
        give = { item = "empty_bottle", count = 1 }
    }
}

Config.AddItems(items)

