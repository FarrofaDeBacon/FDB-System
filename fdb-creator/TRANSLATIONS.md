# Murphy Creator - Translation System
# Système de Traduction Murphy Creator

## Configuration

To change the language, edit `shared/config.lua`:

```lua
Config.Locale = "en" -- 'en' for English, 'fr' for French
```

## Available Languages / Langues Disponibles

- 🇬🇧 **English** (en) - Default
- 🇫🇷 **Français** (fr) - French

## Usage in Lua / Utilisation en Lua

Use the `_U()` function to get translations:

```lua
-- _U(category, key)
local cancelText = _U("UI", "cancel")  -- Returns "Cancel" or "Annuler"
local titleText = _U("CharSelect", "title")  -- Returns "CHARACTER SELECTION" or "SÉLECTION DE PERSONNAGE"

-- Examples:
print(_U("UI", "save"))  -- "Save" or "Sauvegarder"
print(_U("Appearance", "height"))  -- "Height" or "Taille"
print(_U("BodyParts", "nose"))  -- "Nose" or "Nez"
```

### Categories Available:
- `UI` - General UI elements (buttons, etc.)
- `CharSelect` - Character selection screen
- `CharCreation` - Character creation
- `Appearance` - Appearance editor
- `BodyParts` - Face and body parts
- `Descriptors` - Descriptive words (narrow, wide, etc.)
- `Categories` - Barber & makeup categories
- `Notifications` - Messages and warnings

### Backward Compatibility:
Old code using `Lang.Creator["Height"]` still works!

```lua
-- Old way (still works):
ShowAdvancedRightNotification(Lang.Creator["Ped Warning"], ...)

-- New way:
ShowAdvancedRightNotification(_U("Notifications", "pedWarning"), ...)
```

## Usage in JavaScript (NUI) / Utilisation en JavaScript

### Include in HTML:
Add these scripts to your `index.html` BEFORE `script.js`:

```html
<script src="locales/locale-helper.js"></script>
<script src="locales/en.js"></script>  <!-- Default locale -->
```

### Using translations in JavaScript:

```javascript
// Get translation
const cancelText = t('ui.cancel');  // Returns "Cancel" or "Annuler"
const title = t('charSelect.title');  // Returns character selection title

// Examples:
console.log(t('ui.save'));  // "Save" or "Sauvegarder"
console.log(t('bodyParts.nose'));  // "Nose" or "Nez"
console.log(t('appearance.height'));  // "Height" or "Taille"

// With fallback:
const text = t('some.missing.key', 'Default Text');
```

### Using data-i18n attribute in HTML:

```html
<!-- Button text will be automatically translated -->
<button data-i18n="ui.cancel">Cancel</button>
<h1 data-i18n="charSelect.title">CHARACTER SELECTION</h1>

<!-- For placeholders: -->
<input type="text" data-i18n="charCreation.firstname" placeholder="First Name">
```

Then call `updateTranslations()` after the page loads or when changing language.

### Load different locale dynamically:

```javascript
// Load French locale
loadLocale('fr').then(() => {
    console.log('French locale loaded!');
});
```

## Adding a New Language / Ajouter une Nouvelle Langue

### 1. Create Lua translation file:

Create `shared/locales.lua` and add your language:

```lua
-- Spanish example
Lang.es = {}

Lang.es.UI = {
    cancel = "Cancelar",
    accept = "Aceptar",
    save = "Guardar",
    -- ... add all translations
}

-- Add all other categories...
```

### 2. Create JavaScript translation file:

Create `ui/locales/es.js`:

```javascript
const Locale_ES = {
    ui: {
        cancel: "Cancelar",
        accept: "Aceptar",
        save: "Guardar",
        // ... add all translations
    },
    // Add all other categories...
};

if (typeof window !== 'undefined') {
    window.Locale = Locale_ES;
}
```

### 3. Update config:

```lua
Config.Locale = "es"
```

## Translation Keys Reference

### UI Keys:
- cancel, accept, save, back, continue, delete, create, edit, close, reset, confirm, yes, no, play, spawn, loading, style, colour, variation, advanced

### Character Selection Keys:
- title, createNew, selectCharacter, deleteWarning, deleteMessage, characterInfo, sexe, male, female, lore, birthday, day, month, year

### Body Parts Keys:
- head, headShape, headWidth, faceWidth, neck, neckWidth, eyes, eyesDepth, eyebrows, browsHeight, ears, earsWidth, cheekbone, jaw, chin, nose, mouth, lips, shoulders, arms, chest, waist, hips, legs

### Descriptors Keys:
- narrow, wide, large, small, high, low, left, right, up, down, open, close, far, near, extruded, retracted, raised, lowered

## Examples / Exemples

### Lua Example:
```lua
-- In client/NUI/NUICallbacks.lua
ShowAdvancedRightNotification(
    _U("Notifications", "pedWarning"), 
    "menu_textures", 
    "menu_icon_alert", 
    "COLOR_RED", 
    5000
)

-- In client/settings/settings.lua
{
    name = _U("Appearance", "height"),
    totalAmount = 3,
    selectorType = "slider",
    value = 1
}
```

### JavaScript Example:
```javascript
// In script.js
document.getElementById('cancelButton').innerText = t('ui.cancel');

// Dynamic content
const title = document.createElement('h1');
title.setAttribute('data-i18n', 'charSelect.title');
title.textContent = t('charSelect.title');

// Update all translations after loading
window.addEventListener('message', (event) => {
    if (event.data.type === 'setLocale') {
        loadLocale(event.data.locale).then(() => {
            updateTranslations();
        });
    }
});
```

