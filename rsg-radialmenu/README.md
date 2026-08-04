<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🧭 rsg-radialmenu
**Radial interaction menu for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> A fully interactive radial menu system built for RSG Core.  
> Includes categories for player actions, horses, and walk styles.  

---

## 🛠️ Dependencies
- **rsg-core** (framework & player data)  
- **rsg-essentials** (shared actions & menu hooks)  
- **ox_lib** (locale & notifications)  

**License:** GPL‑3.0

---

## ✨ Features
- 🧭 **Radial menu system** for in‑game quick actions.  
- 🧍‍♂️ **Player options** — access walk styles (normal, angry, drunk, etc.).  
- 🐎 **Horse menu** — toggle horse lantern and other actions.  
- 🎮 **Default keybind:** `F6` (changeable in `config.lua`).  
- 🔒 **Hold to open** option for better control.  
- ⚙️ **Nested submenus** supported for complex actions.  
- 🧩 **Extensible:** external scripts can register their own categories dynamically.  
- 🌍 **Locale support** (EN, FR, ES, etc.).  

---

## ⚙️ Configuration (`config.lua`)
```lua
Config = {}

-- Keybind for opening the radial menu
Config.Keybind = "F6"

-- Hold key instead of tap to open
Config.HoldToOpen = false

-- Menu definitions
Config.MenuItems = {
    [1] = {
        id = "citizen",
        title = "Citizen",
        icon = "user",
        items = {
            {
                id = "walkstyles",
                title = "Walk Styles",
                icon = "walking",
                items = {
                    { id = "normal", title = "Normal", icon = "circle" },
                    { id = "angry", title = "Angry", icon = "circle" },
                    { id = "brave", title = "Brave", icon = "circle" },
                    { id = "casual", title = "Casual", icon = "circle" },
                    { id = "drunk", title = "Drunk", icon = "circle" },
                    { id = "old", title = "Old", icon = "circle" },
                    { id = "injured", title = "Injured", icon = "circle" },
                }
            },
        }
    },
    [2] = {
        id = "horse",
        title = "Horse",
        icon = "horse",
        items = {
            { id = "lantern", title = "Lantern", icon = "lightbulb" }
        }
    },
}
```

> 💡 You can add new menus or submenus by inserting entries inside `Config.MenuItems`.  
> For example, add an `"admin"` or `"police"` category for custom server roles.

---

## 🔌 Injecting menu items from other resources

The resource exposes **exports** to add/remove dynamic menu entries at runtime:

```lua
-- ✅ Available exports
exports('AddOption', AddOption)
exports('RemoveOption', RemoveOption)
```

### 1) Add a new category (returns an id you can remove later)
```lua
-- client.lua (in your own resource)
local myCategory = {
  id = 'my_res',
  title = 'My Resource',
  icon = 'star',
  items = {
    { id = 'open_ui', title = 'Open UI', icon = 'window', type = 'client', event = 'my_res:client:openUI' },
    { id = 'do_action', title = 'Do Action', icon = 'hand', type = 'server', event = 'my_res:server:doAction' },
    { id = 'run_cmd', title = 'Run /help', icon = 'circle', type = 'command', event = 'help' },
    -- Optional: only show when a condition is true
    { id = 'police_only', title = 'Police Tools', icon = 'shield', type = 'client', event = 'my_res:client:policeTools',
      canOpen = function()
        local p = exports['rsg-core']:GetCoreObject().Functions.GetPlayerData()
        return p.job and p.job.name == 'police'
      end
    },
  }
}

local menuId = exports['rsg-radialmenu']:AddOption(myCategory)
-- store menuId to remove later if needed
```

### 2) Remove a previously added category
```lua
exports['rsg-radialmenu']:RemoveOption(menuId)
```

### 💡 Item schema (leaf items)
A leaf **must** either provide an `action` function **or** a pair `{ type, event }`:
- `type = 'client'` → `TriggerEvent(event, data)`  
- `type = 'server'` → `TriggerServerEvent(event, data)`  
- `type = 'command'` → `ExecuteCommand(event)`  
- `type = 'rsgcommand'` → `TriggerServerEvent('RSGCore:CallCommand', event, data)`

Optional field: `canOpen = function() return true/false end` — if present and false, the item is filtered out.

> Internally, the selection handler calls your `action(data)` if provided; otherwise it routes by `type`/`event` as above.

---

## 🕹️ Usage
- Press **F6** to open the radial menu.  
- Hover and click to select an action.  
- If `Config.HoldToOpen = true`, hold **F6** instead of tapping.  
- Use submenus for walk styles or horse utilities.  
- You can register custom menu categories at runtime using the exports above.

---

## 📂 Installation
1. Place `rsg-radialmenu` into your `resources/[rsg]` folder.  
2. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure rsg-core
   ensure rsg-essentials
   ensure rsg-radialmenu
   ```
3. Restart your server.  
4. (Optional) Edit `config.lua` to change keybind or add menu items.

---

## 💎 Credits
- **qbcore-framework / qb-radialmenu** — original base system  
  🔗 [https://github.com/qbcore-framework/qb-radialmenu](https://github.com/qbcore-framework/qb-radialmenu)  
- **RexshackGaming / RSG Framework** — adaptation & RedM integration  
  🔗 [https://github.com/Rexshack-RedM](https://github.com/Rexshack-RedM)  
- **RSG / Rexshack‑RedM** — maintenance & UI updates  
- **Community contributors & translators**  
- License: GPL‑3.0
