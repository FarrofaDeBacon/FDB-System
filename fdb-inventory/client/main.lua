local RSGCore = exports['rsg-core']:GetCoreObject()
local config = require 'shared.config'


lib.callback.register('fdb-inventory:client:isInMelee', function()
    local ped = cache.ped
    return IsPedInMeleeCombat(ped)
end)

-- Thread to using ox_target
CreateThread(function()
    local models = config.VendingObjects
    if not models or #models == 0 then return end -- exit if no vending models defined

    exports.ox_target:addModel(models, {
        label = locale('info.vending'),             -- label displayed in the target menu
        icon = 'fa-solid fa-cash-register',        -- icon for the interaction
        distance = 2.5,                             -- maximum distance to interact
        onSelect = function(data)                   -- function triggered when player selects the vending machine
            data.coords = GetEntityCoords(data.entity) -- get the coords of the vending machine entity
            TriggerServerEvent('fdb-inventory:server:openVending', data) -- request the vending inventory from server
        end,
    })
end)

-- Thread to handle keybinds for inventory and hotbar
CreateThread(function()
    -- Mapping of keys to commands
    local commands = {
        [config.Keybinds.Open]             = { command = "inventory" }, -- open inventory
        [config.Keybinds.Hotbar]           = { command = "hotbar" },    -- toggle hotbar
    }

    -- Main loop to check key inputs every frame
    while true do
        Wait(0)
        for control, meta in pairs(commands) do
            if IsControlJustReleased(0, control) then
                if Inventory.CanPlayerUseInventory() then
                    ExecuteCommand(meta.command)
                end
                break
            end
        end
    end
end)
