# 🎬 Complete Guide - CharSelect / Decor / Camera Configuration

This guide explains how to fully customize the character selection location in **murphy_creator**.

---

## 📁 Single file to modify

| File | Description |
|------|-------------|
| `shared/config.lua` | **All configuration is here!** |

---

## 🔢 1. Modify character limit

📄 **File:** `shared/config.lua` - Section `Config.Slots`

```lua
Config.Slots = {
    default = 10,  -- ← Max number of characters by default (change 5 → 10)
    
    role = {
        superadmin = 15,  -- ← Limit for superadmins
        admin = 10,       -- ← Limit for admins
        vip = 8,          -- ← You can add other roles
    },
    
    identifier = {
        ["steam:XXXXXXXXXX"] = 20,  -- ← Limit for a specific player
    }
}
```

**Priority:** `identifier` > `role` > `default`

---

## 🏠 2. Change interior (decor)

📄 **File:** `shared/config.lua` - Section `Config.CharSelect`

### 2.1 Configure interior and spawn

```lua
Config.CharSelect = {
    interior = 78337,  -- ← Interior ID (0 = exterior)
    
    -- Position where player spawns (charselect & creator)
    playerSpawn = {
        coords = vector3(-2785.515, -3058.224, -13.34043),
        heading = 349.0,
    },
    
    imaps = {          -- ← IMAPs to load
        "MP006_A4SUPP_MOONSHINE03",
        "MP006_A4SUPP_MOONSHINE03_PLUG",
    },
    
    interior_sets = {  -- ← Entity sets to activate
        "mp006_mshine_band2",
        "mp006_mshine_theme_goth",
    },
```

### 2.2 List of popular interiors (RDR2)

| Interior | ID | IMAP |
|----------|-----|------|
| Moonshine Shack | 78337 | MP006_A4SUPP_MOONSHINE03 |
| Valentine Saloon | 70145 | None |
| Saint Denis Saloon | 55297 | None |
| Blackwater Hotel | 112897 | None |

> 💡 For an exterior location, set `interior = 0` and empty `imaps` and `interior_sets`.

---

## 📷 3. Configure camera

📄 **File:** `shared/config.lua` - Section `Config.CharSelect.camera`

```lua
camera = {
    coords = vector3(-2781.93, -3050.32, -11.65),   -- Camera position
    target = vector3(-2781.13, -3053.62, -11.70),   -- Point the camera looks at
    fov = 40.0,                                      -- Field of view (30-60)
},
```

| Parameter | Description | Recommended value |
|-----------|-------------|-------------------|
| `coords` | Camera XYZ position | Facing the characters |
| `target` | Point the camera looks toward | Center of characters |
| `fov` | Field of View (zoom) | 30-50 (40 = standard) |

---

## 👤 4. Configure character positions

📄 **File:** `shared/config.lua` - Section `Config.CharSelect.pedslots`

```lua
pedslots = {
    [1] = {
        coords = vector3(-2780.148, -3058.581, -13.34043),
        heading = 0.0,
        scenariopoint = "PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE"
    },
    [2] = {
        coords = vector3(-2782.359, -3058.382, -13.34042),
        heading = -10.0,
        scenario = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED"
    },
    -- Add as many slots as Config.Slots.default
},
```

| Parameter | Description |
|-----------|-------------|
| `coords` | Position vector3(x, y, z) |
| `heading` | Orientation (0-360°) |
| `scenario` | Standing animation |
| `scenariopoint` | Sitting/prop animation |

### 🎭 Available animations:

**Standing (scenario):**
- `"WORLD_HUMAN_SMOKE_NERVOUS_STRESSED"`
- `"WORLD_HUMAN_LEAN_BACK_WALL_SMOKING"`
- `"WORLD_HUMAN_LEAN_WALL_LEFT"`
- `"WORLD_HUMAN_STAND_IMPATIENT"`
- `"WORLD_HUMAN_DRINKING"`
- `"WORLD_HUMAN_BARTENDER_CLEAN_GLASS"`

**Sitting (scenariopoint):**
- `"PROP_HUMAN_SEAT_CHAIR"`
- `"PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE"`
- `"PROP_HUMAN_SEAT_BENCH"`

---

## 📝 5. Complete example: 10 slots

```lua
Config.Slots = {
    default = 10,
    role = { superadmin = 10, admin = 10 },
    identifier = {}
}

Config.CharSelect = {
    interior = 78337,
    imaps = { "MP006_A4SUPP_MOONSHINE03", "MP006_A4SUPP_MOONSHINE03_PLUG" },
    interior_sets = { "mp006_mshine_band2", "mp006_mshine_theme_goth" },
    
    camera = {
        coords = vector3(-2781.93, -3050.32, -11.65),
        target = vector3(-2781.13, -3053.62, -11.70),
        fov = 50.0,  -- Wider to see 10 characters
    },
    
    pedslots = {
        [1] = { coords = vector3(-2780.148, -3058.581, -13.34043), heading = 0.0, scenariopoint = "PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE" },
        [2] = { coords = vector3(-2782.359, -3058.382, -13.34042), heading = -10.0, scenariopoint = "PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE" },
        [3] = { coords = vector3(-2779.928, -3055.968, -13.34043), heading = 95.82, scenario = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED" },
        [4] = { coords = vector3(-2780.274, -3053.504, -13.34042), heading = 41.82, scenario = "WORLD_HUMAN_LEAN_BACK_WALL_SMOKING" },
        [5] = { coords = vector3(-2782.446, -3052.998, -13.34043), heading = 292.65, scenario = "WORLD_HUMAN_LEAN_WALL_LEFT" },
        [6] = { coords = vector3(-2784.195, -3061.677, -13.34044), heading = 337.10, scenario = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS" },
        [7] = { coords = vector3(-2786.5, -3058.0, -13.34043), heading = 270.0, scenario = "WORLD_HUMAN_STAND_IMPATIENT" },
        [8] = { coords = vector3(-2786.5, -3055.5, -13.34043), heading = 250.0, scenario = "WORLD_HUMAN_DRINKING" },
        [9] = { coords = vector3(-2784.0, -3054.0, -13.34043), heading = 200.0, scenario = "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED" },
        [10] = { coords = vector3(-2778.5, -3057.0, -13.34043), heading = 90.0, scenario = "WORLD_HUMAN_LEAN_WALL_LEFT" },
    },
}
```

---

## ⚠️ Important points

1. **Number of pedslots ≥ Config.Slots.default**
2. **Test positions** to avoid overlapping
3. **Adjust FOV** if you have many characters
