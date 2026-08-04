<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🥤 rsg-canteen
**Simple canteen system for RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Drink from tiered canteens (100/75/50/25/0), play a canteen animation, and increase player thirst via rsg-hud.  
> Includes a server refill event and a water types table for integration.

---

## 🛠️ Dependencies
- **rsg-core** (framework)  
- **ox_lib** (locales, notifications)  
- **rsg-hud** (thirst update event)

**Locales included:** `en`, `fr`, `es`, `it`, `pt-br`, `el`  
**License:** GPL‑3.0

---

## ✨ Features
- 🔄 **Tiered items:** `canteen100` → `canteen75` → `canteen50` → `canteen25` → `canteen0`.  
- 🥤 **Drink effect:** increases thirst by `Config.DrinkAmount` and plays an animation with a visible canteen prop.  
- 🚫 **Empty check:** using `canteen0` shows a localized “Canteen Empty” error.  
- ♻️ **Refill hook:** server event `rsg-canteen:server:refillcanteen` converts `canteen0` → `canteen100`.  
- 🌊 **WaterTypes table:** names/hashes of seas, lakes and rivers (for external checks/integration).
  - **By Default** all water with a hashname in this table will allow you to refill any canteen that is item canteen0, canteen25, canteen50 and canteen75
- 🌍 **Multi-language** via `lib.locale()`.

---

## ⚙️ Configuration (`config.lua`)
```lua
Config = {}

-- amount of thirst restored per drink
Config.DrinkAmount = 25

-- water types database (name, waterhash, watertype)
Config.WaterTypes = {
  { name = 'Sea of Coronado',       waterhash = -247856387,  watertype = 'sea'   },
  { name = 'San Luis River',        waterhash = -1504425495, watertype = 'river' },
  { name = 'Lake Don Julio',        waterhash = -1369817450, watertype = 'lake'  },
  -- ... see full list in this repo
}
```

---

## 🔁 How it works

- Server registers all canteen items as usable:
 ```lua
RSGCore.Functions.CreateUseableItem('canteen75', function(source, item)
    TriggerClientEvent('rsg-canteen:client:drink', source, Config.DrinkAmount, 'canteen75')
end)
```

- On use: server triggers the client event `rsg-canteen:client:drink(amount, item)`
- No inventory changes happen at this stage.

- Client plays a short drink animation, spawns a canteen prop, and evaluates:
    - If the canteen is refillable (canteen0, 25, 50, 75) and the player is in valid water,
      it triggers a refill to canteen100.
    - If not in water or using a non-refillable canteen, it triggers a downgrade to the next lower tier.
    - If the item is canteen0 and the player is not in valid water, client shows a localized error
      and blocks thirst gain.

- Thirst is only updated if the canteen is successfully refilled or degraded:
```lua
TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + amount)
```
- To refill, the client triggers one of the following server events:
```lua
TriggerServerEvent('rsg-canteen:server:givefullcanteen')      -- from canteen0
TriggerServerEvent('rsg-canteen:server:givefullcanteen25')   -- from canteen25
TriggerServerEvent('rsg-canteen:server:givefullcanteen50')   -- from canteen50
TriggerServerEvent('rsg-canteen:server:givefullcanteen75')   -- from canteen75
```
- Each removes the partial canteen and gives canteen100, with Inventory ItemBox feedback.

- External scripts can refill any canteen tier using:
```lua
TriggerServerEvent('rsg-canteen:server:refillcanteen', 'canteen25')
```

- This performs the same logic as above and is safe to call from outside this resource.


---

## 🧺 Inventory Items
Add to your items file (RSG inventory format):
```lua
canteen100 = { name = 'canteen100', label = 'Canteen (Full)',   weight = 200, type = 'item', image = 'canteen100.png', unique = false, useable = true, decay = 0, delete = true, shouldClose = true, description = 'A full canteen of water.' },
canteen75  = { name = 'canteen75',  label = 'Canteen (3/4)',    weight = 200, type = 'item', image = 'canteen75.png',  unique = false, useable = true, decay = 0, delete = true, shouldClose = true, description = 'A canteen that is three-quarters full.' },
canteen50  = { name = 'canteen50',  label = 'Canteen (Half)',   weight = 200, type = 'item', image = 'canteen50.png',  unique = false, useable = true, decay = 0, delete = true, shouldClose = true, description = 'A half-full canteen.' },
canteen25  = { name = 'canteen25',  label = 'Canteen (1/4)',    weight = 200, type = 'item', image = 'canteen25.png',  unique = false, useable = true, decay = 0, delete = true, shouldClose = true, description = 'A canteen with a small amount of water.' },
canteen0   = { name = 'canteen0',   label = 'Canteen (Empty)',  weight = 200, type = 'item', image = 'canteen0.png',   unique = false, useable = true, decay = 0, delete = true, shouldClose = true, description = 'An empty canteen that needs refilling.' },
```

---

## 📂 Installation
1. Add `rsg-canteen` to `resources/[rsg]`.  
2. Ensure `rsg-core`, `ox_lib`, and `rsg-hud` are installed.  
3. Add the canteen items above (and icons if you use them).  
4. In `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure rsg-core
   ensure rsg-canteen
   ```
5. Restart your server.

---

## 🌍 Locales
```json
{
  "cl_lang_1": "Canteen Empty",
  "cl_lang_2": "you need to fill up your canteen first!"
}
```

---

## 💎 Credits
- RSG / Rexshack-RedM adaptation & maintenance  
- Community contributors & translators  
- License: GPL‑3.0
