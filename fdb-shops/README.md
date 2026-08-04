<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🛒 fdb-shops
**Config‑driven shop system for RedM using RSG Core and fdb-inventory.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Adds General Stores and Gunsmiths across the map with **ox_lib prompts**, **map blips**, and inventory‑backed shop UIs.  
> Products, prices, stock, and locations are all defined in `config.lua`.

---

## 🛠️ Dependencies
- [**fdb-core**](https://github.com/Rexshack-RedM/fdb-core) 🤠
- [**ox_lib**](https://github.com/Rexshack-RedM/ox_lib) ⚙️ *(for locales and prompts)*
- [**fdb-inventory**](https://github.com/Rexshack-RedM/fdb-inventory) 🎒 *(shop UI & persistence)*
- [**oxmysql**](https://github.com/overextended/oxmysql) 🗄️ *(if inventory persistence is enabled)*

**Locales:** `locales/en.json, fr.json, es.json, el.json, pt-br.json`.  
**Keybind:** `Config.Keybind` (default `'J'`) is displayed in the interaction prompt.

---

## ✨ Features

### 🏪 Store Types
- Define product groups in `Config.Products` (e.g., `normal`, `weapons`, `medic`, etc.).
- Each entry is a list of items with:
  - `name` (item name),
  - `amount` (initial stock; omit for unlimited),
  - `price` (buy price; add `buyPrice` to allow selling to the shop),
  - `maxStock` (cap for player‑sold items),
  - `minQuality` (min condition for buy‑back),
  - `restock` (per restock cycle).

### 🗺️ Locations & Blips
- Add stores in `Config.StoreLocations` (label, name, product group, coords).
- Optional blip per store with `blipsprite`, `blipscale`, and `showblip`.

### 🧾 Inventory Integration
- On resource start, server registers each store with **rsg‑inventory**:
  ```lua
  exports['fdb-inventory']:CreateShop({
      name = shopConfig.name,
      label = shopConfig.label,
      slots = #itemTable,
      items = itemTable,
      persistentStock = shopConfig.persistentStock,
  })
  ```
- When prompted, server opens the shop UI:
  ```lua
  exports['fdb-inventory']:OpenShop(source, name)
  ```
- Supports **persistent stock** with `persistentStock = true`.

### 🔐 Access Restrictions
- Example: medical shops require `playerjobtype == 'medic'`.
- You can extend checks server‑side to gate other product groups.

### 🧭 Prompts
- Client registers a prompt at each store:
  ```lua
  exports['fdb-core']:createPrompt(v.name, v.shopcoords, FDBCore.Shared.Keybinds[Config.Keybind], locale('lang_1') .. v.label, {
      type = 'server',
      event = 'fdb-shops:server:openstore',
      args = { v.products, v.name, v.label },
  })
  ```

---

## 📜 Example (excerpt from `config.lua`)

```lua
Config.Products = {
  ['normal'] = {
    { name = 'bread', amount = 50, price = 0.10 },
    { name = 'water', amount = 50, price = 0.10 },
  },
  ['weapons'] = {
    { name = 'weapon_revolver_cattleman', amount = 1, price = 50 },
    { name = 'weapon_revolver_doubleaction', amount = 1, price = 127 },
    -- ...
  },
}

Config.StoreLocations = {
  {
    label = 'Rhodes General Store',
    name = 'gen-rhodes',
    products = 'normal',
    shopcoords = vector3(1328.99, -1293.28, 77.02 -0.8),
    blipsprite = 'blip_shop_store',
    blipscale = 0.2,
    showblip = true,
    persistentStock = false,
  },
  {
    label = 'Annesburg Gunsmith',
    name = 'wep-annesburg',
    products = 'weapons',
    shopcoords = vector3(2946.50, 1319.53, 44.82),
    blipsprite = 'blip_shop_gunsmith',
    blipscale = 0.2,
    showblip = true,
    persistentStock = false,
  },
}
```

---

## 📂 Installation
1. Place `fdb-shops` inside your `resources/[rsg]` folder.
2. Ensure **fdb-core**, **ox_lib**, **fdb-inventory**, and **oxmysql** are installed.
3. Configure `config.lua` (products, locations, prices, persistence).
4. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-inventory
   ensure fdb-shops
   ```
5. Restart your server.

---

## 🌍 Locales
Included languages: `en`, `fr`, `es`, `el`, `pt-br`.  
Uses `lib.locale()` for prompts and messages.

---

## 💎 Credits
- **RSG / Rexshack-RedM** and contributors  
- Community testers and translators  
- License: GPL‑3.0  
