<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🕊️ fdb-telegram
**Interactive telegram & bird post delivery system for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Send and receive telegrams through post offices or trained birds with a full UI and immersive animations.  
> Adapted from FRP’s bird post concept and fully integrated into the RSG Framework.

---

## 🛠️ Dependencies
- [**fdb-core**](https://github.com/Rexshack-RedM/fdb-core) 🤠  
- [**ox_lib**](https://github.com/overextended/ox_lib) ⚙️ *(notifications, prompts, locales)*  
- [**fdb-inventory**](https://github.com/Rexshack-RedM/fdb-inventory) 🎒 *(for the birdpost item)*  

**Locales included:** `en`, `fr`, `es`, `it`, `pt-br`, `el`  
**License:** GPL‑3.0  

---

## ✨ Features
- 📬 **Send and receive telegrams** through post offices or the `birdpost` item.  
- 🕊️ **Bird delivery system** with configurable attach offsets per model & sex.  
- 🏤 **Multiple post offices** with blips and configurable coordinates.  
- 💵 **Optional charge per letter** via `Config.ChargePlayer` and `Config.CostPerLetter`.  
- 🔔 **Notifications & locales** through `ox_lib`.  
- 🌍 **Multi-language** and **HUD integration**.  
- ⚙️ **Optimized logic:** only runs while a bird is active or approaching its recipient.  

---

## 🪶 Feature Highlights
- Fully integrated into RSG Telegram  
- Change bird model to any birds we want  
- Notification to sender when the letter is delivered successfully  
- Notification to recipient when the Bird Post is approaching  
- Notification to recipient when he/she is inside a building  
- Notification to recipient when he/she is on a horse and about to pick up the letter  
- Auto resurrect the bird when it dies before the letter is sent successfully  
- Set bird arrival delay (default is 20 seconds)  
- Bird timeout (default is 180 seconds). When timeout reached, the bird will fail to deliver the letter and the recipient can retrieve the letter on the nearby Post Office  
- Optimised loops and fully optimised logics, will only run when the target person is getting a Bird Post approaching  
- Animation for writing and sending the letter  
- Bird Post blip (with blue colour) for the recipient to be able to detect Bird Post position  
- Send letter to ourself for debugging/testing purpose  
- RSG Core Framework Locales support  
- Fully integrated into fdb-hud  
- The bird will follow the target person anywhere until he/she picks up the letter (until the timeout we set reached)  
- Automatic resource cleanup for 'ensure' freaks like myself  
- The bird may stuck at the tall building, that's RDR2 feature. There's no bird flying on the cities, so whenever a Bird Post is coming we'll be notified to stay away from any buildings  
- More improvements to come later  

---

## ⚙️ Configuration (`config.lua`)

```lua
Config = {}

-- Bird attach offsets per model and sex
Config.BirdAttach = {
    ["A_C_Hawk_01"] = {
        Male   = { 296, 0.19,  0.01, 0.27, 0.0, 0.0, 0.0 },
        Female = { 363, 0.12, -0.02, 0.27, 0.0, 0.0, 0.0 }
    }
}

-- General Settings
Config.Debug           = false
Config.AllowSendToSelf = false
Config.ChargePlayer    = true
Config.CostPerLetter   = 0.50
Config.BirdPostItem    = 'birdpost'  -- Item name for bird post delivery

-- Post Office Locations (example excerpt)
Config.PostOfficeLocations = {
    {
        name       = 'Wapiti Post Office',
        location   = 'wapitipostoffice',
        coords     = vector3(-1765.084, -384.1582, 157.74119),
        blipsprite = 'blip_post_office',
        blipscale  = 0.2,
        showblip   = true
    },
    {
        name       = 'Emerald Ranch Station Post Office',
        location   = 'emeraldranch-postoffice',
        coords     = vector3(1522.04, 439.54, 90.68),
        blipsprite = 'blip_post_office',
        blipscale  = 0.2,
        showblip   = true
    },
}
```

---

## 🧺 Inventory Item (one-line format)

Add this to `fdb-inventory/items.lua`:
```lua
birdpost = { name = 'birdpost', label = 'Telegram Bird', weight = 500, type = 'item', image = 'birdspost.png', unique = true, useable = true, shouldClose = true, description = 'A trained bird used to deliver telegrams.' },
```

**Note:** The item name (`birdpost`) can be customized via `Config.BirdPostItem` in `config.lua`. Make sure the item name in your inventory matches the config setting.

Usage registration:
```lua
FDBCore.Functions.CreateUseableItem('birdpost', function(src)
    TriggerClientEvent('fdb-telegram:client:openUI', src)
end)
```

---

## 📂 Installation
1. Place `fdb-telegram` inside `resources/[rsg]`.  
2. Import `fdb-telegram.sql` into your database.  
3. Add the `birdpost` item (and image) to your inventory setup.  
4. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-inventory
   ensure fdb-telegram
   ```
5. Restart your server.

---

## 💎 Credits
- **FRP (Faroeste Roleplay)** — for the original frp_peagle 
- **RSG / Rexshack-RedM** — adaptation & framework integration
- **RexShack / RexShack#3041** — for the original RSG Telegram
- **MOVZX / Goghor#9453** — conversions, optimisations, additions, etc
- **Sadicius** — redesign and others
- License: GPL‑3.0
