<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 👱 fdb-appearance
**Character creator and clothing system for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Full appearance, character creation, and clothing system for RedM built on RSG Core.  
> Includes gender selection, detailed features, and dynamic clothing support.

---

## 🛠️ Dependencies
- [**fdb-core**](https://github.com/Rexshack-RedM/fdb-core) 🤠
- [**ox_lib**](https://github.com/Rexshack-RedM/ox_lib) ⚙️ *(for notifications and UI)*
- [**fdb-menubase**](https://github.com/Rexshack-RedM/fdb-menubase) 🎨 *(for in-game menus)*
- [**oxmysql**](https://github.com/overextended/oxmysql) 🗄️ *(for player skins storage)*

**Data files:** The `/data` folder includes lists for hair, overlays, features, and clothing variations.  
**Locales:** `locales/en.json`, `locales/pt-br.json` loaded via `lib.locale()`.  
**Images:** UI icons and references are stored in `/img`.

---

## ✨ Features

### 🧍 Character Creation
- Fully interactive **character creator**.
- Select **gender, first name, last name, nationality, birthdate**.
- Adjust all appearance details using menus powered by **fdb-menubase**.
- Real-time preview while creating your character.

### 👕 Clothing System
- Choose and apply clothing dynamically from predefined lists in `data/clothes_list.lua`.
- Save and load outfits.
- Purchase new clothing ,the system calculates price differences automatically.
- Supports male and female components, hair, overlays, and features.

### 💾 Server-Side Persistence
- Automatically saves appearance and clothing to SQL.
- Commands/events handled server-side for security:
  - `fdb-appearance:server:SaveSkin`
  - `fdb-appearance:server:saveOutfit`
- Uses table `playerskins` with columns: `citizenid`, `skin`, `clothes`.

### 💰 Price Calculation
- Automatic cost calculation when changing clothes.
- Deducts in-game cash using FDBCore’s economy system:
  ```lua
  Player.Functions.RemoveMoney('cash', price, 'buy-clothes')
  ```

### 🌍 Localization
- Built-in language support (English, Portuguese-BR).
- Easy to extend with new locale files.

---

## 📸 Preview
*(soon)*

---

## 📂 Installation
1. Place `fdb-appearance` inside your `resources/[rsg]` folder.
2. Ensure `fdb-core`, `ox_lib`, `fdb-menubase`, and `oxmysql` are installed.
3. Import the SQL for player skins if not already present:
   ```sql
   CREATE TABLE IF NOT EXISTS `playerskins` (
       `citizenid` VARCHAR(50) NOT NULL,
       `skin` LONGTEXT NULL DEFAULT NULL,
       `clothes` LONGTEXT NULL DEFAULT NULL,
       PRIMARY KEY (`citizenid`)
   );
   ```
4. Start in your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-menubase
   ensure fdb-appearance
   ```
5. Restart your server and create a new character.

---

## 🧩 Configuration
Edit `config.lua` to adjust menu keybinds, storage options, or other parameters.  
The `/data` folder defines which clothes, hairstyles, and overlays are available.

---

## 💾 Example Server Events
```lua
-- Save full skin + clothing
TriggerServerEvent('fdb-appearance:server:SaveSkin', skinData, clothesData, true)

-- Save outfit only
TriggerServerEvent('fdb-appearance:server:saveOutfit', clothesData, isMale, outfitName)
```

---

## 🧠 Notes
- The script integrates deeply with **FDBCore** player data (`citizenid`, `money`, etc.).  
- Designed to be modular and expandable with new data sets.

---

## 💎 Credits
- Original resource created by: [QRCore-RedM-Re](https://github.com/QRCore-RedM-Re)  
- Modified and adapted for RSG Core by Rexshack Gaming  
- Contributors: community developers and testers  
- License: GPL‑3.0  

