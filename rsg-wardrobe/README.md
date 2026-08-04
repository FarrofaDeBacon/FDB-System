# fdb-wardrobe

Toggle individual clothing items on/off via chat commands for RSG Framework (RedM).

## Dependencies

- [fdb-core](https://github.com/Rexshack-RedM/fdb-core)
- [fdb-appearance](https://github.com/Rexshack-RedM/fdb-appearance)
- [oxmysql](https://github.com/Rexshack-RedM/oxmysql)
- [ox_lib](https://github.com/Rexshack-RedM/ox_lib)

## Commands

| Command | Toggles |
|---|---|
| `/hat` | Hat |
| `/shirt` | Shirt |
| `/pants` | Pants |
| `/boots` | Boots |
| `/coat` | Coats |
| `/closedcoat` | Closed coats |
| `/gloves` | Gloves |
| `/poncho` | Poncho |
| `/vest` | Vest |
| `/sleeve` | Sleeve style |
| `/eyewear` | Eyewear |
| `/belt` | Belts |
| `/cloak` | Cloak |
| `/chaps` | Chaps |
| `/mask` | Mask |
| `/neckwear` | Neckwear |
| `/accessories` | Accessories |
| `/gauntlets` | Gauntlets |
| `/neckties` | Neckties |
| `/loadouts` | Loadouts |
| `/suspenders` | Suspenders |
| `/satchels` | Satchel |
| `/gunbelt` | Gun belt |
| `/buckle` | Buckle |
| `/skirt` | Skirt |
| `/armor` | Armor |
| `/hairaccessories` | Hair accessories |
| `/leftring` | Left ring |
| `/rightring` | Right ring |
| `/leftholster` | Left holster |
| `/rightholster` | Right holster |
| `/collar1` | Collar (sleeves up) |
| `/collar2` | Collar (sleeves down) |
| `/undress` | Remove all clothing |
| `/dress` | Wear all stored clothing |

## Configuration

Edit `config.lua`:

- `Config.RequiredPermission` — set to an ace name (e.g. `'wardrobe'`) to restrict all commands to players with the `command.<name>` ace. Leave empty for no restriction.
- `Config.ClothingComponents` — defines each clothing slot by name, clothes cache key, state field, and component hash.
- `Config.SkinColours` — maps body size/skin tone combinations to component indices.

### Ace Permissions

To restrict commands, set in `config.lua`:
```lua
Config.RequiredPermission = 'wardrobe'
```

Then in your server config:
```
add_ace group.admin command.wardrobe allow
```

## Exports

### Client

```lua
-- Toggle a clothing item by its config name
exports['fdb-wardrobe']:ToggleClothing(name)

-- Remove all clothing from the local player
exports['fdb-wardrobe']:RemoveAllClothing()

-- Check if a specific clothing item is currently worn (returns boolean)
local wearing = exports['fdb-wardrobe']:IsWearing(name)
```

Example:
```lua
exports['fdb-wardrobe']:ToggleClothing('hat')
if exports['fdb-wardrobe']:IsWearing('mask') then
    print('Player is wearing a mask')
end
```

### Server

```lua
-- Toggle a clothing item for a specific player
exports['fdb-wardrobe']:TogglePlayerClothing(source, name)

-- Remove all clothing from a specific player
exports['fdb-wardrobe']:RemovePlayerClothing(source)

-- Dress a player (wear all stored clothing from DB)
exports['fdb-wardrobe']:DressPlayer(source)
```

Example:
```lua
-- Force remove mask when entering jail
exports['fdb-wardrobe']:TogglePlayerClothing(source, 'masks')

-- Strip all clothing on arrest
exports['fdb-wardrobe']:RemovePlayerClothing(source)

-- Re-dress on release
exports['fdb-wardrobe']:DressPlayer(source)
```

## Installation

1. Ensure all dependencies are installed and started.
2. Add `ensure fdb-wardrobe` to your server config.
3. Configure `config.lua` as needed.
