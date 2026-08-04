<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🌅 fdb-spawn
**Spawn/respawn flow for RedM servers using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Simple, fast, and polished spawn pipeline for both **new** and **existing** players.  
> Displays localized loading info, applies saved appearance, places the player at a configured spawn, and triggers FDBCore lifecycle events.

---

## 🛠️ Dependencies
- [**fdb-core**](https://github.com/Rexshack-RedM/fdb-core) 🤠
- [**ox_lib**](https://github.com/Rexshack-RedM/ox_lib) ⚙️ *(locales & UI helpers)*
- [**fdb-appearance**](https://github.com/Rexshack-RedM/fdb-appearance) 💅 *(apply saved skin on spawn)*
- [**fdb-weapons**](https://github.com/Rexshack-RedM/fdb-weapons) 🔫 *(optional auto dual‑wield)*
- [**weathersync**](https://github.com/Rexshack-RedM/weathersync) 🌦️ *(optional, toggled on existing player flow)*

**Locales:** `locales/en.json, fr.json, el.json` (loaded via `lib.locale()`).  
**Config:** `config.lua` for spawn location, tips, and auto dual‑wield.

---

## ✨ Features

### 🧭 Two Spawn Flows
- **Existing Player**
  - Fades screen, shows **Citizen ID** and localized **loading message** (+ random tip).
  - Restores last known position and heading from `PlayerData.position`.
  - Optional **Auto Dual‑Wield** via `fdb-weapons` (configurable).
  - Triggers:
    - `FDBCore:Server:OnPlayerLoaded`
    - `FDBCore:Client:OnPlayerLoaded`
- **New Player**
  - Applies saved skin with `exports['fdb-appearance']:ApplySkin()`.
  - Teleports to **Config.SpawnLocation** (default: **Valentine Station**).
  - Executes `/revive`, fades in, and triggers FDBCore load events.

### 📝 Random Tips
- Rotate tips on the loading string using `Config.RandomTips`:
```lua
Config.RandomTips = {
  'TIP : use [LALT] to targert',
  'TIP : use [H] to call your horse',
  'TIP : use [I] to open your inventory',
}
```

### ⚙️ Config
```lua
Config.AutoDualWield = true

Config.SpawnLocation = { coords = vector4(-169.47, 629.38, 114.03, 236.72) } -- valentine station
```

---

## 📂 Installation
1. Place `fdb-spawn` inside your `resources/[rsg]` folder.
2. Ensure **fdb-core**, **ox_lib**, **fdb-appearance**, and **fdb-weapons** (optional) are installed.
3. Configure `config.lua` (spawn point, tips, dual‑wield).
4. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-appearance
   ensure fdb-spawn
   ```
5. Restart your server.

---

## 🌍 Locales
Included languages: `en`, `fr`, `el`.  
Use `lib.locale()` to add more via `locales/*.json`.

---

## 💎 Credits
- **RSG / Rexshack-RedM** and contributors  
- Community testers and translators  
- License: GPL‑3.0  
