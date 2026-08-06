# fdb-libs

Custom UI and Utilities Library for **FDB System** (RedM). This resource acts as the core UI, interaction, and bridging module for all fdb-system scripts, featuring custom responsive web interfaces, geofencing, blips, and server-client communication callbacks.

---

## 🎨 Design System & Aesthetics

The UI is built with a responsive Svelte-based framework optimized for RedM. By default, it establishes a solid, uniform background color system to ensure consistency across all HUD and interaction components:

* **Accent Theme Presets:** Supports `western_gold` (default RDR2 style), `dark_coal`, `blood_red`, and a fully customizable `custom` layout defined in `config.lua`.
* **Uniform Colors:** Uses standard CSS variables (`--fdb-background-color`, `--fdb-accent-color`, etc.) with customizable image background overrides.

---

## 📦 Mapped Modules & API Documentation

### 1. 🔔 Notifications (`notify`)
Provides a premium notification banner system in the top-right corner.

* **Client Export:**
  ```lua
  exports['fdb-libs']:Notify(text, type, duration)
  ```
  * `text` (string): Message content.
  * `type` (string): `"success"`, `"error"`, `"warning"`, `"info"`.
  * `duration` (integer): Display time in milliseconds (default: `5000`).

---

### 2. ⏳ Progress Bar (`progress`)
Displays a fluid progress bar in the center-bottom HUD.

* **Client Export:**
  ```lua
  local success = exports['fdb-libs']:Progress({
      duration = 5000,
      label = "Colhendo Plantas...",
      useLimit = true,   -- Trava o jogador na animação
      canCancel = true   -- Permite cancelar com BACKSPACE/ESC
  })
  if success then
      -- Ação concluída com sucesso
  end
  ```

---

### 3. 📝 Input Dialog (`input`)
Renders an elegant multi-input questionnaire/dialog modal.

* **Client Export:**
  ```lua
  local data = exports['fdb-libs']:InputDialog("Título do Menu", {
      { type = 'input', label = 'Nome', placeholder = 'Digite seu nome...' },
      { type = 'number', label = 'Idade', min = 1, max = 99 },
      { type = 'select', label = 'Sexo', options = { {label = "Masculino", value = "M"}, {label = "Feminino", value = "F"} } },
      { type = 'checkbox', label = 'Termos' },
      { type = 'slider', label = 'Altura', min = 140, max = 210 }
  })
  -- 'data' retorna uma lista indexada com as respostas correspondentes
  ```

---

### 4. 🎛️ Interactive Menus (`menu`)
Generates customizable lists, sub-menus, sliders, and checkboxes in a native RDR2 design.

* **Client Export:**
  ```lua
  exports['fdb-libs']:CreateMenu('meu_menu', 'Título', 'Subtítulo', {
      { label = 'Opção 1', description = 'Abre um sub-menu' },
      { label = 'Slider Exemplo', type = 'slider', min = 1, max = 10, value = 5 },
      { label = 'Checkbox Exemplo', type = 'checkbox', checked = true }
  }, {
      onSelect = function(index, item) ... end,
      onChange = function(index, item) ... end,
      onClose = function() ... end
  })
  ```

---

### 🔓 5. Minigame (`minigame`)
A reaction-based lockpicking minigame. The player must press SPACE inside the target sweet-spots to unlock cylinders.

* **Client Export:**
  ```lua
  local success = exports['fdb-libs']:StartMinigame({
      duration = 1200,    -- Velocidade de rotação
      targetWidth = 8,    -- Largura da zona doce (dificuldade)
      rounds = 4          -- Quantidade de cilindros
  })
  ```

---

### 🌐 6. Server Callbacks (`callback`)
Enables quick and easy request-response triggers between client and server.

* **Server Register:**
  ```lua
  exports['fdb-libs']:RegisterServerCallback('fdb-libs:server:checkMoney', function(source, cb, amount)
      cb(hasMoney)
  end)
  ```
* **Client Trigger (Asynchronous):**
  ```lua
  exports['fdb-libs']:TriggerServerCallback('fdb-libs:server:checkMoney', function(hasMoney)
      -- Ação
  end, 100)
  ```
* **Client Trigger (Synchronous / Await):**
  ```lua
  local hasMoney = exports['fdb-libs']:TriggerServerCallbackAsync('fdb-libs:server:checkMoney', 100)
  ```

---

### 📍 7. Blips / Map Markers (`blip`)
Adds and manages custom blips on the RedM world map.

* **Client Exports:**
  ```lua
  local blip = exports['fdb-libs']:CreateBlip(coords, name, sprite, blipHash, color)
  exports['fdb-libs']:RemoveBlip(blip)
  ```

---

### ⭕ 8. Geofencing Zones (`zones`)
Manages physical coordinates with distance check threads, custom visual cylinder markers, and native game interact prompts.

* **Configuration (in `config.lua`):**
  Configure the default marker color, marker type, default prompt key, and visibility.
* **Client Export:**
  ```lua
  exports['fdb-libs']:CreateZone("nome_zona", coords, 3.0, {
      drawMarker = true,
      showPrompt = true,
      promptText = "Acessar Loja",
      onEnter = function() ... end,
      onExit = function() ... end,
      onKeyPress = function() ... end -- Executado ao pressionar a tecla [E] do prompt
  })
  ```

---

## 🛠️ Installation & Setup

1. Copy the folder to your `resources` directory.
2. Add `ensure fdb-libs` in your `server.cfg`.
3. Configure the active theme and zone settings inside `config.lua`.
