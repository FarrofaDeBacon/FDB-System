<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🎣 rsg-fishing
**Interactive fishing system for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Cast, hook, and reel with a native-backed minigame.  
> Supports multiple baits, fish sizes/species, weight metadata, keep/throw, and Discord logging.

---

## 🛠️ Dependencies
- [**rsg-core**](https://github.com/Rexshack-RedM/rsg-core) 🤠  
- [**ox_lib**](https://github.com/overextended/ox_lib) ⚙️ *(locales, notifications)*  
- [**rsg-inventory**](https://github.com/Rexshack-RedM/rsg-inventory) 🎒 *(items & ItemBox)*  

**Locales included:** `en`, `fr`, `es`, `it`, `pt-br`, `el`  
**License:** GPL-3.0

---

## ✨ Features

- 🎯 **Fishing minigame** with difficulty and reel speed controls (native fishing struct).
- 🪱 **Baits**: bread, corn, cheese, worm, cricket, crawdad, dragonfly… (`Config.Baits`)
- 🐟 **Species & Sizes**: pickerel, trout, bass, catfish, salmon, perch, chain pickerel… with **SM/MS/ML/LG** variants.
- ⚖️ **Weight metadata** saved on the fish item (e.g., `metadata = { weight = "2.13" }`).
- 🧺 **Keep or Throw**: choose to keep fish (add item) or throw it back.
- 🔔 **Discord logging** (if `rsg-log` present): embeds with player name, species and weight.
- 🌐 **Multi-language** prompts/buttons via `ox_lib` locales.
- 🧩 **JS helper** (`client_js.js`) to **get/set native fishing data** for a smoother minigame.

---

## 🎮 Actions
Prompts shown during the flow:
- **Prepare Fishing Rod**, **Cast Fishing Rod**, **Hook**, **Reset Cast**  
- **Reel Lure**, **Reel In**  
- **Keep Fish**, **Throw Fish**  

*(Actual keys depend on your client keybinds and prompt setup; texts are localized.)*

---

## ⚙️ Configuration (`config.lua`)

### Core settings
```lua
Config = {}

-- Minigame tuning
Config.Difficulty = 1250     -- use -1 for testing (easier)
Config.ReelSpeed  = 0.0125   -- reel acceleration
Config.Debug      = false
```

### Baits
```lua
Config.Baits = {
  "p_baitBread01x",
  "p_baitCorn01x",
  "p_baitCheese01x",
  "p_baitWorm01x",
  "p_baitCricket01x",
  "p_crawdad01x",
  "p_finishedragonfly01x",
}
```
All bait items are automatically registered as **usable** on the server and call the client event:
```lua
TriggerClientEvent('rsg-fishing:client:usebait', src, item.name)
```

### Fish database
Two mappings are used:

- **`FishData`**: model → data tables (weights/behavior) used by the minigame  
- **`fishNames` / `fishEntity`**: model → (display name, item key, description key)

Example:
```lua
A_C_FISHBLUEGIL_01_SM        = {"Bluegill (Small)","PROVISION_FISH_BLUEGILL","PROVISION_FISH_BLUEGILL_DESC"},
A_C_FISHBLUEGIL_01_MS        = {"Bluegill (Medium)","PROVISION_FISH_BLUEGILL","PROVISION_FISH_BLUEGILL_DESC"},
A_C_FISHCHAINPICKEREL_01_SM  = {"Chain Pickerel (Small)","PROVISION_FISH_CHAIN_PICKEREL","PROVISION_FISH_CHPICKREL_DESC"},
A_C_FISHCHANNELCATFISH_01_LG = {"Channel Catfish (Large)","PROVISION_FISH_CHANNEL_CATFISH","PROVISION_FISH_CHNCATFISH_DESC"},
-- ...
```

> ✅ Ensure **every item key** (e.g., `PROVISION_FISH_BLUEGILL`) **exists in `rsg-inventory`** with a proper item definition.

---

## 🧺 Inventory items (examples)

Add bait items (RSG Inventory format):
```lua
p_baitbread01x     = { name = 'p_baitbread01x',     label = 'Bread Bait',     weight = 50,  type = 'item', image = 'p_baitbread01x.png',     unique = false, useable = true,  decay = 300, delete = true, shouldClose = true, description = 'Simple bread bait' },
p_baitcorn01x      = { name = 'p_baitcorn01x',      label = 'Corn Bait',      weight = 50,  type = 'item', image = 'p_baitcorn01x.png',      unique = false, useable = true,  decay = 300, delete = true, shouldClose = true, description = 'Sweet corn bait' },
p_baitcheese01x    = { name = 'p_baitcheese01x',    label = 'Cheese Bait',    weight = 50,  type = 'item', image = 'p_baitcheese01x.png',    unique = false, useable = true,  decay = 300, delete = true, shouldClose = true, description = 'Pungent cheese bait' },
p_baitworm01x      = { name = 'p_baitworm01x',      label = 'Worm Bait',      weight = 50,  type = 'item', image = 'p_baitworm01x.png',      unique = false, useable = true,  decay = 300, delete = true, shouldClose = true, description = 'Classic worm bait' },
p_baitcricket01x   = { name = 'p_baitcricket01x',   label = 'Cricket Bait',   weight = 50,  type = 'item', image = 'p_baitcricket01x.png',   unique = false, useable = true,  decay = 300, delete = true, shouldClose = true, description = 'Lively cricket bait' },
p_crawdad01x       = { name = 'p_crawdad01x',       label = 'Crawdad Bait',   weight = 50,  type = 'item', image = 'p_crawdad01x.png',       unique = false, useable = true,  decay = 300, delete = true, shouldClose = true, description = 'Fresh crawdad bait' },
p_finishedragonfly01x = { name = 'p_finishedragonfly01x', label = 'Dragonfly Bait', weight = 50, type = 'item', image = 'p_finishedragonfly01x.png', unique = false, useable = true, decay = 300, delete = true, shouldClose = true, description = 'Eye-catching dragonfly bait' },
```

Add fish items (the **keys must match** the ones in config mappings):
```lua
PROVISION_FISH_BLUEGILL         = { name = 'PROVISION_FISH_BLUEGILL',         label = 'Bluegill',            weight = 100, type = 'item', image = 'fish_bluegill.png',         unique = false, useable = false, decay = 0,   delete = false, shouldClose = true, description = 'A common bluegill. Metadata includes weight.' },
PROVISION_FISH_CHAIN_PICKEREL   = { name = 'PROVISION_FISH_CHAIN_PICKEREL',   label = 'Chain Pickerel',      weight = 100, type = 'item', image = 'fish_chain_pickerel.png',   unique = false, useable = false, decay = 0,   delete = false, shouldClose = true, description = 'A feisty pickerel. Metadata includes weight.' },
PROVISION_FISH_CHANNEL_CATFISH  = { name = 'PROVISION_FISH_CHANNEL_CATFISH',  label = 'Channel Catfish',     weight = 100, type = 'item', image = 'fish_channel_catfish.png',  unique = false, useable = false, decay = 0,   delete = false, shouldClose = true, description = 'Large whiskered catfish. Metadata includes weight.' },
PROVISION_FISH_STEELHEAD_TROUT  = { name = 'PROVISION_FISH_STEELHEAD_TROUT',  label = 'Rainbow Trout',       weight = 100, type = 'item', image = 'fish_steelhead_trout.png',  unique = false, useable = false, decay = 0,   delete = false, shouldClose = true, description = 'Colorful trout. Metadata includes weight.' },
-- add the rest to match your `fishEntity` mapping…
```

> ℹ️ The server calls:  
> `Player.Functions.AddItem(fishItemName, 1, nil, { weight = fish_weight })`  
> so **weight is stored as metadata** on the item.

---

## 📂 Installation
1. Put `rsg-fishing` in `resources/[rsg]`.  
2. Ensure `rsg-core`, `ox_lib`, and `rsg-inventory` are installed.  
3. Add to `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure rsg-core
   ensure rsg-inventory
   ensure rsg-fishing
   ```
4. Restart your server.

---

## 🌍 Locales
Loaded by `lib.locale()`;

---

## 💎 Credits
- Original source **FRP_Framework** → https://github.com/Faroeste-Roleplay/frp-lua-rdr3  
- Additional edits/improvements from **VORP Core** → https://github.com/VORPCORE/vorp_fishing-lua  
- RSG / Rexshack-RedM adaptation & maintenance  
- Community contributors & translators  
- License: GPL-3.0  
