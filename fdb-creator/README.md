# Execute SQL File

Execute murphy_creator.sql and murphy_barber.sql in your database.



# REDEMRP Installation steps:
replace event for murphy_creator event,
replace this event,
```lua
RegisterNetEvent('redemrp_charselect:removeLoadingScreen', function()
    SendNUIMessage({
        loading = false
    })
    if not loadingscreenremoved then
        -- OpenCharacterMenu()
        loadingscreenremoved = true
    end
end)
```


# VORP Installation steps:
DEPENDENCIES: vorp_character
Replace this event in vorp_core\server\loadusers.lua
```lua
local roomId = 0
RegisterNetEvent('vorp:playerSpawn', function()
    local _source = source

    local identifier <const> = GetPlayerIdentifierByType(_source, 'steam')
    if not identifier then
        return print("user cant load no identifier steam found", identifier)
    end

    local user <const> = _users[identifier]
    if not user then
        return print("user not found with identifier", identifier)
    end

    roomId = roomId + 1
    SetPlayerRoutingBucket(_source, roomId)

    user.Source(_source)
    TriggerClientEvent("murphy_creator:OpenCharSelect", _source)
    -- local numCharacters <const> = user.Numofcharacters()
    -- if numCharacters <= 0 then
    --     return TriggerEvent("vorp_CreateNewCharacter", _source)
    -- end

    -- local eventName <const> = tonumber(user._charperm) > 1 and "GoToSelectionMenu" or "SpawnUniqueCharacter"
    -- TriggerEvent(("vorp_character:server:%s"):format(eventName), _source)
end)
```

# RSG Installation steps:
DEPENDENCIES: rsg_appearance, rsg_core, rsg_creator
Edit this in resources\[framework]\rsg-multicharacter\client\main.lua
Line 7
```lua
CreateThread(function()
    while true do
        Wait(500)
        if NetworkIsSessionStarted() and PlayerPedId() ~= 0 and IsPedAPlayer(PlayerPedId()) then
            while not IsScreenFadedOut() and not IsScreenFadedIn() do
                Wait(100)
            end
            Wait(1000)
            TriggerServerEvent('murphy_creator:getCharacters')
            return
        end
    end
end)
```
## Optionnal: If you don't have murphy_clothing
In rsg-appearance\client\creator.lua replace ApplySkin function
This will allow the script to load murphy_creator data a script call rsg's loadskin.
```lua
function ApplySkin()
    local _Target = PlayerPedId()
    local citizenid = RSGCore.Functions.GetPlayerData().citizenid
    local currentHealth = LocalPlayer.state.health or GetEntityHealth(_Target)
    local dirtClothes = GetAttributeBaseRank(_Target, 16)
    local dirtHat = GetAttributeBaseRank(_Target, 17)
    local dirtSkin = GetAttributeBaseRank(_Target, 22)

    local promise = promise.new()
    print ("[RSG Appearance] Fetching skin data from server using murphy_creator and rsg-appearance...")
    RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(data)
        print ("[RSG Appearance] Skin data received from server.")
        local _SkinData = data.skin
        local _Clothes = data.clothes
        if _Target == PlayerPedId() then
            local model = GetPedModel(tonumber(_SkinData.sex))
            LoadModel(PlayerPedId(), model)
            _Target = PlayerPedId()
            SetEntityAlpha(_Target, 0)
            LoadedComponents = _SkinData
        end
        FixIssues(_Target)
        local previousPlayerPedId = PlayerPedId()
        -- LoadHeight(_Target, _SkinData)
        -- LoadBoody(_Target, _SkinData)
        -- LoadHead(_Target, _SkinData)
        -- LoadHair(_Target, _SkinData)
        -- LoadBeard(_Target, _SkinData)
        -- LoadEyes(_Target, _SkinData)
        -- LoadFeatures(_Target, _SkinData)
        -- LoadBodyFeature(_Target, _SkinData.body_size, Data.Appearance.body_size)
        -- LoadBodyFeature(_Target, _SkinData.body_waist, Data.Appearance.body_waist)
        -- LoadBodyFeature(_Target, _SkinData.chest_size, Data.Appearance.chest_size)
        -- LoadOverlays(_Target, _SkinData)

        -- First, trigger murphy_creator to load the base skin/model
        TriggerEvent("murphy_creator:loadskin")

        -- Wait for murphy_creator to finish loading
        Wait(4000)

        SetEntityAlpha(_Target, 255)
        SetAttributeCoreValue(_Target, 0, 100)
        SetAttributeCoreValue(_Target, 1, 100)
        SetEntityHealth(_Target, currentHealth, 0)
        Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId(), 0.0)
        Citizen.InvokeNative(0xDE1B1907A83A1550, _Target, 0)
        print(_Target, previousPlayerPedId, PlayerPedId())
        if _Target == previousPlayerPedId then
            print("[RSG Appearance] Skin applied successfully using murphy_creator and rsg-appearance.")
            TriggerEvent('rsg-appearance:client:ApplyClothes', _Clothes, PlayerPedId(), _SkinData)
            -- After applying rsg-appearance clothes, load murphy_clothing
            Wait(500)
            TriggerEvent("murphy_clothing:loadclothes")
        else
            for i, m in pairs(Overlays.overlay_all_layers) do
                Overlays.overlay_all_layers[i] =
                { name = m.name, visibility = 0, tx_id = 1, tx_normal = 0, tx_material = 0, tx_color_type = 0, tx_opacity = 1.0, tx_unk = 0, palette = 0, palette_color_primary = 0, palette_color_secondary = 0, palette_color_tertiary = 0, var = 0, opacity = 0.0 }
            end
        end
        SetAttributeBaseRank(_Target, 16, dirtClothes)
        SetAttributeBaseRank(_Target, 17, dirtHat)
        SetAttributeBaseRank(_Target, 22, dirtSkin)
        promise:resolve()
    end, citizenid)
    print("[RSG Appearance] Applying skin using murphy_creator and rsg-appearance...")
    Citizen.Await(promise)
end
```

# config.lua — Quick Configuration Guide

This file sets up the main options for your character creator resource.

---

## Config.framework

Specifies which framework to use.  
**Options:**  
- `'REDEMRP2k23'`
- `'rsg-core'`
- `'vorp'`

**Example:**
```lua
Config.framework = 'vorp'
```

## Config.murphy_clothing
Enable or disable integration with the murphy_clothing resource.

- true: Use murphy_clothing.
- false: Do not use murphy_clothing.
Example:
```lua
Config.murphy_clothing = true
```

## Config.MaxCharacterSlots
Sets the maximum number of character slots per permission group.

- base: Default slot count for all users.
- superadmin: Slot count for users with superadmin permission.
Example:
```lua
Config.MaxCharacterSlots = {
    base = 1,
    superadmin = 5,
}
```

# slots.lua — Quick Configuration Guide

This file manages character slot limits and ped model access permissions for your RedM character creator.

---

## Slots

Defines the maximum number of character slots available:

- **default**: The default slot limit for all users.
- **role**: Override the default for specific roles (e.g., `superadmin`, `admin`).
- **identifier**: Override both default and role for specific identifiers (e.g., Steam hex).

**Example:**
```lua
Slots = {
    default = 5,
    role = {
        superadmin = 5,
        admin = 5,
    },
    identifier = {
        ["steam:11000010c04648e"] = 5,
    }
}
```
## PedPermission
Controls access to ped models in the creator:

- default: Default access (true = allowed, false = denied).
- role: Override default for specific roles.
- identifier: Override both default and role for specific identifiers.
Example:
```lua
PedPermission = {
    default = true,
    role = {
        superadmin = true,
        admin = true,
    },
    identifier = {
        ["steam:11000010c04648e"] = true,
    }
}
```

# Configuration Guide — settings.lua

This file configures the character creation system for your RedM server. Below you will find explanations for each section and tips on how to customize them.

---

## 1. SpawnLocation

Defines the available spawn locations for new or existing characters.

- **id**: Unique identifier for the location.
- **name**: Display name of the location.
- **description**: Description shown in the UI.
- **coords**: Camera position (`vector3(x, y, z)`).
- **target**: Camera target point (`vector3(x, y, z)`).
- **fov**: Camera field of view (in degrees).
- **pedspawn**: Where the character will spawn (`vector3(x, y, z)`).
- **pedspawnheading**: Character heading (in degrees).

**Example:**
```lua
{
    id = 1,
    name = "Armadillo",
    description = "A dusty, battered town typical of the Wild West...",
    coords = vector3(-3646.41, -2619.23, -12.62),
    target = vector3(-3666.02, -2602.20, -12.79),
    fov = 70.0,
    pedspawn = vector3(-3647.277, -2618.289, -14.57223),
    pedspawnheading = 8.36,
}
```
Add or remove locations by copying or deleting entries in the SpawnLocation table.


## 2. HeightMax & HeightMin
Set the maximum and minimum allowed character height.
```lua
HeightMax = 1.05
HeightMin = 0.95
```

## 3. ExpressionsMaxValues
Defines the minimum and maximum values for each facial/body morph.
Edit these only if you want to restrict or expand customization options.

Example:
```lua
["Head_Width"] = {min = -1.0, max = 1.0},
```

## 4. ApparenceMenu
Configures the main appearance menu (height, body, waist, legs, upper).

- id: Unique identifier.
- name: Display name.
- totalAmount: Number of available options.
- selectorType: Type of selector (e.g., "slider").
- value: Default value.
Example:
```lua
{
    id = "height",
    name = "Height",
    totalAmount = 100,
    selectorType = "slider",
    value = 50
}
```

## 5. EditionElem
Defines the advanced face and body editing menu.

Each key (e.g., headshape, neck, brows, etc.) is a category.
- division: List of subcategories or sliders/matrices for each area.
- elements: Define sliders or matrices, their values, names, and ids.
- Example for neck width:
```lua
{
    id = "Neck_Width",
    type = "slider",
    leftValueName = "Narrow",
    rightValueName = "Wide",
    startValue = 50,
}
```
- Example for a matrix (2D slider):
```lua
{
    id = 1,
    type = "matrice",
    topValueName = "High",
    bottomValueName = "Low",
    leftValueName = "Narrow",
    rightValueName = "Wide",
    startPositionX = 0.5,
    startPositionY = 0.5,
    XHashes = "Jaw_Height",
    YHashes = "Jaw_Width"
}
```

## Tips
Add or remove spawn locations by editing the SpawnLocation table.
Adjust min/max values in ExpressionsMaxValues to control customization limits.
Add new categories in EditionElem for more detailed customization.
Follow the structure: Each entry must respect Lua syntax (commas, braces, etc.).

## Note
Changes take effect after restarting the script or server.
For new sliders or matrices, use the existing structure in EditionElem as a template.
Always make a backup before editing this file.