-- illegal-system/client/editor.lua
local isEditorOpen = false

function StartPlacementCamera(spawnType, model)
    exports.wasvendel_doorlock:StartPlacement({}, function(result)
        if result and result.ok then
            -- Se for registradora ou spawns, precisamos do heading para a UI
            local heading = 0.0
            if spawnType == 'register' or spawnType == 'guard' or spawnType == 'dog' then
                heading = GetEntityHeading(PlayerPedId()) -- Usa o heading atual do jogador como ref
            end
            
            SendNUIMessage({
                action = "stopPlacement",
                spawnType = spawnType,
                model = model,
                result = { x = result.position.x, y = result.position.y, z = result.position.z },
                heading = heading
            })
        else
            SendNUIMessage({
                action = "stopPlacement",
                result = nil
            })
        end
    end)
end

RegisterNUICallback("startPlacement", function(data, cb)
    SetNuiFocus(false, false)
    StartPlacementCamera(data.type, data.model)
    cb('ok')
end)
