AddEventHandler('fdb-lockpick:client:openLockpick', function(callback)
    lockpickCallback = callback
    openLockpick(true)
end)

RegisterNUICallback('callback', function(data, cb)
    openLockpick(false)
    if lockpickCallback then
        lockpickCallback(data.success)
        lockpickCallback = nil
    end
    cb('ok')
end)

RegisterNUICallback('exit', function(data, cb)
    openLockpick(false)
    if lockpickCallback then
        lockpickCallback(false)
        lockpickCallback = nil
    end
    if cb then cb('ok') end
end)

openLockpick = function(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool,
    })
    SetCursorLocation(0.5, 0.2)
    lockpicking = bool
end