<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 💈 fdb-barbers
**Fully functional barbershop system for RedM (RSG Core).**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Visit barbershops across the map to customize your hair, beard, and overlays with a smooth in-game camera and clean UI.

---

## 🛠️ Dependencies
- **fdb-core** (framework & player data)  
- **fdb-menubase** (menu interface)  
- **ox_lib** (locales, notifications)  
- **oxmysql** (database handler)

**License:** GPL‑3.0

---

## ✨ Features
- 💇‍♂️ **Interactive barbershops** across the map.  
- ✂️ **Change hairstyle, beard, and overlays** with real-time preview.  
- 🧠 **Camera system** with zoom and rotation while editing.  
- 💵 **Configurable price system** (default $5).  
- 🧾 **Persistent appearance** — saved to player skin table.  
- 🧍‍♂️ **NPC barbers** auto-spawned at configured shops.  
- 🗺️ **Blips** for each barbershop location.  
- 🎮 **Menu** built with RSG Menubase (mouse & controller support).  
- 🌍 **Full localization support** (English, French, Spanish, Greek, Italian, Portuguese).  
- ⚙️ **Highly configurable** via `config.lua` and `shared/hairs.lua`.

---

## ⚙️ Configuration (`config.lua`)
```lua
Config = {}

Config.BarberCost = 5           -- Price per haircut
Config.CameraFov = 35.0         -- Default camera zoom
Config.KeyOpen = 'J'            -- Keybind to interact (optional)
Config.UseTarget = false        -- Use fdb-target or proximity prompt

Config.Barbers = {
    { name = "Saint Denis Barbershop", coords = vector3(2651.49, -1211.27, 53.28) },
    { name = "Blackwater Barbershop", coords = vector3(-814.23, -1365.77, 43.68) },
    { name = "Valentine Barbershop", coords = vector3(-280.85, 783.15, 119.51) }
}
```

> 💡 To add a new barbershop, insert a new entry in `Config.Barbers` with name and coordinates.

---

## 🧩 Shared Data
### `shared/hairs.lua`
Defines all hair and beard styles with their corresponding overlay names, texture sets, and labels.  
Each entry can have variants for color and model compatibility.

### `shared/overlays.lua`
Contains overlay definitions (eyebrows, freckles, scars, etc.) used by the barbershop menu.

---

## 🕹️ Usage
- Walk near a configured barbershop or NPC barber.  
- Press **[J]** (or your configured key) to open the menu.  
- Use the menu to browse hairstyles, beards, and overlays.  
- Select **“Purchase”** to apply the style permanently (cost deducted from wallet).  
- Changes are saved automatically to the database.  

---

## 💾 Database
Uses the existing **playerskins** table in your RSG Core database.  
If not present, make sure the table is created by your skin system.

---

## 📂 Installation
1. Place `fdb-barbers` inside `resources/[rsg]`.  
2. Add the resource to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure fdb-core
   ensure fdb-menubase
   ensure fdb-barbers
   ```
3. Restart your server.

---

## 💎 Credits
- **RexshackGaming** — Original resource  
  🔗 https://github.com/Rexshack-RedM  
- **RSG / Rexshack‑RedM** — adaptation & maintenance
- **Humanity Is Insanity#3505 & Zee#2115 from The Crossroads RP for code inspiration and system
- **RedEM-RP for the menu : https://github.com/RedEM-RP/redemrp_menu_base  
- **Community contributors & translators**  
- License: GPL‑3.0
