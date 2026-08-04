<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🔫 fdb-weapons
**Weapon handling, degradation & repair for RSG Framework.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Degradation over time, damage modifiers, repair workflow with a usable repair kit, and an admin `/infinityammo` toggle.  
> Includes an ammo type map for bows, thrown weapons and firearms.

---

## 🛠️ Dependencies
- **fdb-core** (framework)
- **ox_lib** (locales, notifications)

**Locales included:** `en`, `fr`, `es`, `it`, `pt-br`, `el`, `ro`  
**License:** GPL‑3.0

---

## ✨ Features (from this resource)
- 🧰 **Repair Kit item** (`weapon_repair_kit`) → progress bar + server‑side repair.
- 📉 **Weapon degradation** (`Config.DegradeRate`) and **damage modifiers** (ranged/melee).
- 🧭 **Weapon components** toggle (`Config.WeaponComponents`) for custom component flow.
- ♾️ **Admin command** `/infinityammo` → server checks permission, toggles infinite ammo on client.
- 🎯 **Ammo type mapping** (`AmmoWeaponTypes`) for bows, thrown weapons, revolvers, rifles, repeaters, shotguns, etc.
- 🌍 **Multi‑language** via `ox_lib.locale()` and `locales/*.json`.

---

## ⚙️ Configuration (`config.lua`) — real keys
```lua
Config = {}

Config.Debug = false

-- If false, you can use /loadweapon for equipped weapon (as noted in code)
Config.WeaponComponents = true

-- Timings & degradation
-- Config.UpdateAmmo = 10000 -- (commented in repo)
Config.RepairTime = 30000
Config.DegradeRate = 0.01

-- Damage modifiers
Config.WeaponDmg = 0.65
Config.MeleeDmg  = 1.0

-- Ammo mapping (excerpt)
AmmoWeaponTypes = {
    ['weapon_bow']                      = 'AMMO_ARROW',
    ['weapon_bow_improved']             = 'AMMO_ARROW',
    ['weapon_thrown_throwing_knives']   = 'AMMO_THROWING_KNIVES',
    ['weapon_thrown_tomahawk']          = 'AMMO_TOMAHAWK',
    ['weapon_melee_hatchet']            = 'AMMO_HATCHET',
    -- ... (see full table in this repo)
}
```

---

## 🎮 Commands
| Command | Access | Description |
|--------|--------|-------------|
| `/infinityammo` | Admin | Toggles infinite ammo for the current weapon (server permission checked). |

The client event is `fdb-weapons:toggle`; the server validates with `FDBCore.Functions.HasPermission(src, 'admin')` before triggering it.

---

## 🧺 Inventory Item (one‑line format)
Add to your items file (RSG inventory format):
```lua
weapon_repair_kit = { name = 'weapon_repair_kit', label = 'Weapon Repair Kit', weight = 200, type = 'item', image = 'weapon_repair_kit.png', unique = false, useable = true, decay = 0, delete = true, shouldClose = true, description = 'Tools and oil to repair a worn weapon.' },
```

This item is registered server‑side as usable and calls the client repair flow:
```lua
FDBCore.Functions.CreateUseableItem('weapon_repair_kit', function(source, item)
    TriggerClientEvent('fdb-weapons:client:repairweapon', source)
end)
```

---

## 🔁 Repair Flow (from code)
1. Player uses **`weapon_repair_kit`**.  
2. Client locks inventory, shows **progress bar** for `Config.RepairTime`.  
3. Server removes the kit and **repairs the held weapon** (by serial).  
4. Inventory unlocks and a localized notification is shown.

---

## 🧩 Developer Notes
- Exports available on client:
  - `exports('weaponInHands', ...)` → returns table with current weapon data/serial.  
  - `exports('UsedWeapons', ...)` → access cache of used weapons by serial.
- Client applies `SetPlayerWeaponDamageModifier` and `SetPlayerMeleeWeaponDamageModifier` continuously based on config.
- The resource uses `lib.locale()`; edit `locales/en.json` (and others) to customize UI text.

---

## 📂 Installation
1. Add `fdb-weapons` to `resources/[rsg]`.  
2. Ensure `fdb-core` and `ox_lib` are running before it.  
3. Add the inventory item above and an icon if desired.  
4. In `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-weapons
   ```
5. Restart your server.

---

## 📝 SQL
Included SQL files:
- `player_weapons.sql`
- `player_weapons_2.1_update.sql`

Apply them if you plan to persist weapon information as designed by this resource.

---

## 💎 Credits
- https://github.com/qbcore-redm-framework/qbr-weapons
- https://github.com/QRCore-RedM-Re/qr-weapons
- **RSG / Rexshack-RedM** — framework integration & localization support  
- Community translators  
- License: GPL‑3.0
