# fdb-bathing

Interactive bathing system for RedM servers using RSG Core.

## Dependencies

- [fdb-core](https://github.com/Rexshack-RedM/fdb-core)
- [ox_lib](https://github.com/Rexshack-RedM/ox_lib)
- [fdb-wardrobe](https://github.com/Rexshack-RedM/fdb-wardrobe)
- [fdb-appearance](https://github.com/Rexshack-RedM/fdb-appearance)

## Installation

1. Place `fdb-bathing` inside your `resources/[rsg]` folder.
2. Ensure all dependencies are installed and started.
3. Adjust bath prices and zone coordinates in `config.lua`.
4. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure fdb-core
   ensure fdb-wardrobe
   ensure fdb-appearance
   ensure fdb-bathing
   ```
5. Restart your server.

## Configuration

- `Config.NormalBathPrice` — price for a standard bath (default: 1)
- `Config.DeluxeBathPrice` — price for an assisted deluxe bath (default: 5)
- `Config.BathingZones` — bathhouse locations, animations, door hashes, and NPC models
- `Config.BathingModes` — scrub animations and their scrub frequencies

## Features

- Bathhouses in Saint Denis, Valentine, Annesburg, Strawberry, Blackwater, Vanhorn, and Rhodes
- Normal and deluxe (NPC-assisted) baths with unique animations
- Server-authorised payment with session locking to prevent concurrent use
- Invincibility toggled server-side during bathing
- Automatic undress/dress via fdb-wardrobe exports
- Wetness cleared on bath exit
- Localised prompts and notifications via ox_lib
- Server-side validation of all incoming events

## Exports

```lua
exports('IsBathingActive', function()
    return LocalPlayer.state.isBathingActive
end)
```

## License

GPL-3.0
