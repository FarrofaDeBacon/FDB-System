-- ============================================================
-- FDB System | fdb-creator | shared/config.lua
-- Main configuration file for fdb-creator
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
Config = {}

Config.framework = 'fdb-core' -- Framework to use. Options: 'REDEMRP2k23', 'rsg-core', 'vorp', 'rdr3mp', 'rdr3mp-legacy'
Config.fdb_clothing = true -- Set to true if you are using fdb_clothing
Config.LoadSkinCommand = "mc" -- Command to load fdb_creator data
Config.DevMode = true -- Set to true to enable developer mode, which allows you to use the F3 key to open the character creator
Config.Locale = "en" -- Language: 'en' for English, 'fr' for French

--[[
    â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
    â•‘                    CHARACTER SELECT CONFIGURATION                          â•‘
    â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•£
    â•‘  Configure the interior, camera, and character positions for charselect   â•‘
    â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

-- Interior Configuration
Config.CharSelect = {
    -- Interior ID (0 = no interior/exterior location)
    interior = 78337,
    
    -- Player spawn position when opening charselect/creator
    playerSpawn = {
        coords = vector3(-2785.515, -3058.224, -13.34043),
        heading = 349.0,
    },
    
    -- IMAPs to load (comment out or remove if not needed)
    imaps = {
        "MP006_A4SUPP_MOONSHINE03",
        "MP006_A4SUPP_MOONSHINE03_PLUG",
    },
    
    -- Interior entity sets to activate
    interior_sets = {
        "mp006_mshine_band2",
        "mp006_mshine_theme_goth",
        -- "mp006_mshine_bar_benchAndFrame",
        -- "mp006_mshine_dressing_1",
        -- "mp006_mshine_hidden_door_open",
        -- "mp006_mshine_location1",
        -- "mp006_mshine_pic_02",
        -- "mp006_mshine_shelfwall1",
        -- "mp006_mshine_shelfwall2",
        -- "mp006_mshine_Still_02",
        -- "mp006_mshine_still_hatch",
    },
    
    -- Camera settings
    camera = {
        coords = vector3(-2781.93, -3050.32, -11.65),   -- Camera position
        target = vector3(-2781.13, -3053.62, -11.70),   -- Where the camera looks at
        fov = 40.0,                                      -- Field of view (lower = more zoom)
    },
    
    -- Character slot positions (add more if you increase the max slots in slots.lua)
    -- scenario = standing animation | scenariopoint = sitting/prop animation
    pedslots = {
        [1] = {
            coords = vector3(-2780.148, -3058.581, -13.34043),
            heading = 0.0,
            scenariopoint = "PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE"
        },
        [2] = {
            coords = vector3(-2782.359, -3058.382, -13.34042),
            heading = -10.0,
            scenariopoint = "PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE"
        },
        [3] = {
            coords = vector3(-2779.928, -3055.968, -13.34043),
            heading = 95.82,
            scenario = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED"
        },
        [4] = {
            coords = vector3(-2780.274, -3053.504, -13.34042),
            heading = 41.82,
            scenario = "WORLD_HUMAN_LEAN_BACK_WALL_SMOKING"
        },
        [5] = {
            coords = vector3(-2782.446, -3052.998, -13.34043),
            heading = 292.65,
            scenario = "WORLD_HUMAN_LEAN_WALL_LEFT"
        },
        [6] = {
            coords = vector3(-2784.195, -3061.677, -13.34044),
            heading = 337.10,
            scenario = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS"
        },
        -- Add more slots here if needed (up to your max in Config.Slots.default)
        -- [7] = {
        --     coords = vector3(x, y, z),
        --     heading = 0.0,
        --     scenario = "WORLD_HUMAN_STAND_IMPATIENT"
        -- },
    },
}

--[[
    â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
    â•‘                       CHARACTER SLOTS LIMITS                               â•‘
    â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•£
    â•‘  Maximum number of characters per player (by role or identifier)          â•‘
    â•‘  Priority: identifier > role > default                                     â•‘
    â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

Config.Slots = {
    default = 5,  -- Default max characters for all players
    
    -- Role-based limits (overrides default)
    role = {
        superadmin = 5,
        admin = 5,
        -- vip = 8,  -- Example: VIP players get 8 slots
    },
    
    -- Specific player limits (overrides role and default)
    identifier = {
        -- ["steam:11000010c04648e"] = 10,  -- Example: specific player gets 10 slots
    }
}

--[[
    â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
    â•‘                       PED MODEL PERMISSIONS                                â•‘
    â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•£
    â•‘  Access to custom ped models in the character creator                     â•‘
    â•‘  Priority: identifier > role > default                                     â•‘
    â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

Config.PedPermission = {
    default = true,  -- true = access to ped models, false = no access
    
    role = {
        superadmin = true,
        admin = true,
    },
    
    identifier = {
        -- ["steam:11000010c04648e"] = true,
    }
}

--[[
    â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
    â•‘                    CHARACTER DELETION PERMISSIONS                          â•‘
    â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•£
    â•‘  Who can delete characters? (optional restriction)                        â•‘
    â•‘  Priority: identifier > role > default                                     â•‘
    â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

Config.CharacterDeletion = {
    enabled = true,           -- true = deletion enabled, false = no one can delete
    restrictToRoles = false,  -- false = everyone can delete, true = only allowed roles/identifiers
    
    -- If restrictToRoles = true, only these roles can delete characters
    role = {
        superadmin = true,
        admin = true,
        -- moderator = true,
    },
    
    -- Specific players who can always delete (overrides role)
    identifier = {
        -- ["steam:11000010c04648e"] = true,
    }
}

--[[
    â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
    â•‘                       ADMIN COMMANDS                                       â•‘
    â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•£
    â•‘  Admin commands for character management                                   â•‘
    â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
]]

Config.Commands = {
    deleteCharacter = {
        enabled = true,                    -- Enable/disable the command
        command = "deletechar",            -- Command name: /deletechar [charidentifier]
        allowedRoles = {                   -- Roles allowed to use this command
            "superadmin",
            "admin",
        },
        allowedIdentifiers = {             -- Specific players allowed (steam identifier)
            -- "steam:11000010c04648e",
        }
    },
    
    -- "Second Chance" command - Reopen character customization menu for a player
    secondChance = {
        enabled = true,                    -- Enable/disable the command
        command = "secondchance",          -- Command name: /secondchance [playerid]
        allowedRoles = {                   -- Roles allowed to use this command
            "superadmin",
            "admin",
        },
        allowedIdentifiers = {             -- Specific players allowed (steam identifier)
            -- "steam:11000010c04648e",
        }
    }
}

