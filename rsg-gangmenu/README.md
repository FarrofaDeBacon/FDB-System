<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 💀 fdb-gangmenu
**Gang boss management menu for RedM servers using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> ox_lib–based context menus for **gang bosses** to manage members, funds, and a shared storage. Uses RSG Core prompts at configured locations, with optional map blips.

---

## 🛠️ Dependencies
- [**fdb-core**](https://github.com/Rexshack-RedM/fdb-core) 🤠
- [**ox_lib**](https://github.com/Rexshack-RedM/ox_lib) ⚙️
- [**oxmysql**](https://github.com/overextended/oxmysql) 🗄️ *(required for gang funds)*
- [**fdb-inventory**](https://github.com/Rexshack-RedM/fdb-inventory) 🎒 *(for the gang stash)*

**Interaction:** Context prompt at each `Config.GangLocations[i].coords` opens the main menu (uses `exports['fdb-core']:createPrompt`).  
**Key text:** Prompt displays the configured key from `FDBCore.Shared.Keybinds[Config.Keybind]`.  
**Locales:** `locales/en.json, fr.json, es.json, it.json, el.json, pt-br.json` (loaded via `lib.locale()`).

**Command:** `/gangmenu` opens the main gang management menu.

---

## ✨ Features (detailed)

### 🧭 Main Menu *(boss only)*
- **Manage Members**
  - View the **Member List**.
  - **Set grade** for a member.
  - **Fire** a member.
- **Hire Gang Members**
  - List **nearby civilians** and recruit them into your gang.
- **Storage Access**
  - Open the **shared gang stash** (via `fdb-inventory`), with configurable slots/weight.
- **Money Management**
  - View gang **balance** (server callback).
  - **Deposit** and **Withdraw** funds via input dialogs.

> Access checks use `Player.PlayerData.gang.isboss` on client & server.

### 🗺️ Prompts & Blips
- For every entry in `Config.GangLocations`, the script:
  - Creates a **prompt** at `coords` to open the gang menu.
  - Optionally spawns a **blip** when `showblip = true` with:
    - `Config.Blip.blipName`
    - `Config.Blip.blipSprite`
    - `Config.Blip.blipScale`

### 💰 Gang Funds (SQL-backed)
- Uses the `management_funds` table with `type = 'gang'`.
- Server utilities keep an in-memory cache per gang account and **persist** on change.
- Exposed server events handle **deposit** and **withdraw**, with ox_lib notifications.

---

## 📸 Preview
<img width="329" height="603" alt="image" src="https://github.com/user-attachments/assets/b07aa137-83bd-4bc8-8685-c09b3c78dcac" />

---

## 📜 Example Config

```lua
Config = {}

-- blip settings
Config.Blip = {
    blipSprite = 'blip_honor_bad', -- Config.Blip.blipSprite
    blipScale = 0.2 -- Config.Blip.blipScale
}

-- settings
Config.Keybind = 'J'
Config.StorageMaxWeight = 4000000
Config.StorageMaxSlots = 50

Config.GangLocations = {

    {   -- example
        id = 'gang1',
        name = 'Gang Menu',
        blipname = 'Gang Name',
        coords = vector3(0, 0, 0),
        showblip = false,
        blipforall = false
    },
}
```

---

## 📂 Installation
1. Place `fdb-gangmenu` inside your `resources` (or `resources/[rsg]`) folder.
2. Ensure **fdb-core**, **ox_lib**, **fdb-inventory**, and **oxmysql** are installed and started.
3. **Database:** import `fdb-gangmenu.sql` (creates `management_funds` with `type='gang'`).
4. Edit `config.lua` (keybind, stash sizes, blip & gang locations).
5. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-inventory
   ensure fdb-gangmenu
   ```

---

## 🔐 Permissions
- **Boss‑only actions:** The menu and all actions are restricted to gang leaders (`Player.PlayerData.gang.isboss`).  
- **Grade checks:** Server-side logic validates grade when managing members (promote/demote/fire).

---

## 🗄️ SQL
`fdb-gangmenu.sql` creates (and seeds) the **management_funds** table:
```sql
CREATE TABLE IF NOT EXISTS `management_funds` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `job_name` VARCHAR(50) NOT NULL,
  `amount`  INT(100) NOT NULL,
  `type` ENUM('boss','gang') NOT NULL DEFAULT 'boss',
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_name` (`job_name`),
  KEY `type` (`type`)
);

-- seed example
INSERT INTO `management_funds` (`job_name`, `amount`, `type`) VALUES
('gang1', 0, 'gang');
```

---

## 🌍 Locales
Provided in `locales/`: `en`, `fr`, `es`, `it`, `el`, `pt-br`.  
Loaded via `lib.locale()` on both client and server. Menu text & notifications are fully localized.

---

## 💎 Credits
- RSG / Rexshack-RedM and contributors
- Community testers and translators
