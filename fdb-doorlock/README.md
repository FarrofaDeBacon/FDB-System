<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🚪 fdb-doorlock
**Advanced, fully synchronized door locking system for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Lock/Unlock single or double doors with proper key animations, job-based permissions, and server-side sync.  
> Includes jail gate handling and multi-language prompts via `ox_lib` locales.

---

## 🛠️ Dependencies
- [**fdb-core**](https://github.com/Rexshack-RedM/fdb-core) 🤠  
- [**ox_lib**](https://github.com/overextended/ox_lib) ⚙️ *(notifications & locales)*  

**Locales:** `en`, `fr`, `es`, `it`, `pt-br`, `el`  
**License:** GPL‑3.0  

---

## ✨ Features
- 🔒 **Server-synced locks** — state replicated for all players on toggle.
- 👮 **Job permissions** — `authorizedJobs` restrict who can toggle each door.
- 🚪 **Single & double doors** — use `doorid` for one door or `doors = { ... }` for pairs.
- 🎞️ **Key unlock animation** — plays a hand-key animation with a key prop before toggling.
- 🧭 **Per-door distance & yaw** — fine-tune interaction range and facing.
- 🗺️ **Custom prompt position** — `textCoords` separate from `objCoords` for cleaner UX.
- 🧑‍⚖️ **Sisika jail gates** — force-lock defined gates on resource start via `Config.JailDoors`.
- 🌍 **Multi-language** — status strings and prompt labels via `lib.locale()`.

---

## 🧱 Architecture & Flow

**Client**  
- Creates a **hold-mode prompt** (default key: `ENTER`) grouped by `doorLockPrompt`.
- Disables interaction if player is **dead, cuffed, hogtied or lassoed**.
- Shows current **Door Status: Locked/Unlocked** (localized).
- Plays **unlock key animation** and attaches prop (`P_KEY02X`) before sending update.
- Calls `TriggerServerEvent('fdb-doorlock:updatedoorsv', idx, newState)` on hold-complete.
- Receives `fdb-doorlock:setState` to update local `Config.DoorList[idx].locked`.

**Server**  
- Verifies permission using `authorizedJobs` and the player’s `job.name`.
- If authorized, broadcasts `fdb-doorlock:setState` to **all clients**.
- Otherwise, only plays the **client-side animation** via `fdb-doorlock:changedoor` response.

---

## ⚙️ Configuration (`config.lua`)

### Single door
```lua
{
  authorizedJobs = { 'vallaw' },         -- who can toggle
  doorid = 1988748538,                   -- door model hash
  objCoords  = vector3(-276.01, 802.59, 118.41),  -- object position
  textCoords = vector3(-276.01, 802.59, 119.41),  -- prompt position
  objYaw = 10.0,                         -- facing (visual reference)
  locked = true,                         -- initial state
  distance = 3.0                         -- interact range (default ~1.25 if omitted)
},
```

### Double doors (group)
```lua
{
  textCoords = vector3(-757.27, -1269.34, 44.04),
  authorizedJobs = { 'blklaw' },
  locked = true,
  distance = 3.0,
  doors = {
    { objYaw = 90.0, doorid = 3410720590, objCoords = vector3(-757.04, -1268.48, 43.07) },
    { objYaw = 90.0, doorid = 160636303,  objCoords = vector3(-757.47, -1270.30, 43.05) }
  }
},
```

### Jail front gates (Sisika)
```lua
Config.JailDoors = {
  -- these hashes are force-locked on resource start
  906662604, 1121239638, 2617210026, 3984556459
}
```

> 💡 **Tips**
> - Use `textCoords` to avoid prompts spawning inside geometry.  
> - `distance` can be reduced to prevent toggling through walls.  
> - For double doors, put both halves in the same `doors = { ... }` group.

---

## 🧩 Native Door Handling (under the hood)

This resource uses RDR2 **door system natives** to ensure consistent locking:  
- `0xD99229FE93B46286` — add/define door to door system  
- `0x6BAB9442830C7F53` — set door state (0 = unlocked, 3 = locked)  
- `0x160AA1B32F6139B8` — get door system state  
- `0xB6E6FBA95C7324AC` — freeze door entity position when locked

You normally **don’t need** to call these yourself — just configure `Config.DoorList`.

---

## 🧪 Events & API

### Client → Server
```lua
-- after playing key animation (hold prompt complete)
TriggerServerEvent('fdb-doorlock:updatedoorsv', doorIndex, newState)
```

### Server → Client
```lua
-- authorize and broadcast new state
TriggerClientEvent('fdb-doorlock:setState', -1, doorIndex, newState)

-- fallback: play animation only (no state change) for the caller
TriggerClientEvent('fdb-doorlock:changedoor', src, doorIndex, newState)
```

### Client (handlers)
```lua
RegisterNetEvent('fdb-doorlock:changedoor')  -- plays key animation, then requests update
RegisterNetEvent('fdb-doorlock:setState')    -- applies locked/unlocked status locally
```

---

## 🔐 Permissions
Access is controlled per door via `authorizedJobs`.  
Jobs are resolved from `FDBCore.Functions.GetPlayer(src).PlayerData.job.name`.

**Examples:**  
- Sheriff stations: `vallaw`, `rholaw`, `blklaw`, `stdenlaw`, etc.  
- Private interiors: create a custom job or add multiple jobs to `authorizedJobs`.

---

## 📂 Installation
1. Place `fdb-doorlock` inside your `resources/[rsg]` folder.  
2. Ensure `fdb-core` and `ox_lib` are installed.  
3. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-doorlock
   ```
4. Restart your server.

---

## 🌍 Locales
Included: `en`, `fr`, `es`, `it`, `pt-br`, `el`  
Loaded automatically via `lib.locale()` with keys:
- `sv_nokey` → “You do not have a key!”  
- `cl_use_door` → “Use”, `cl_door_status_base` → “Door Status: ”  
- `cl_door_status_lock` / `cl_door_status_unlock`

---

## 🧠 Troubleshooting
- **Prompt doesn’t show** → Check `textCoords` and increase `distance`.  
- **Can toggle without keys** → Make sure your player’s `job.name` isn’t in `authorizedJobs`.  
- **Doors don’t move** → Verify `doorid` hashes and world positions. Some interiors use **different door models** per map.  
- **Rapid spam** → A small **cooldown** is applied client-side after a toggle. Reduce `distance` if needed.

---

## 💎 Credits
- **RSG / Rexshack-RedM** — base framework & adaptation  
- Inspired by **QR-Doorlock** — refactored for RSG compatibility  
- Community contributors & translators  
- License: GPL‑3.0  
