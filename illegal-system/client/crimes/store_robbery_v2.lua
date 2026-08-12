local isRobbingStore = false

local function PlayRobberyAnimation(ped)
    local dict = "script_common@jail_cell@unlock@key"
    local anim = "action"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 31, 0, false, 0, false, 0, false)
end

-- ==========================================
-- 1. MÉTODOS DIURNOS (Assalto Estático ao Caixa)
-- ==========================================
RegisterNetEvent('illegal-system:client:startStoreRobbery', function(storeName, sessionToken)
    if isRobbingStore then return end
    isRobbingStore = true
    
    local ped = PlayerPedId()
    PlayRobberyAnimation(ped)
    
    if lib.progressBar({
        duration = 8000,
        label = "Limpando o Caixa...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        }
    }) then
        ClearPedTasks(ped)
        isRobbingStore = false
        TriggerServerEvent('illegal-system:server:finishStoreRobbery', storeName, sessionToken)
    else
        ClearPedTasks(ped)
        isRobbingStore = false
        TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)
        Bridge.Notify("Você cancelou o assalto.", "error")
    end
end)

-- ==========================================
-- 2. MÉTODOS NOTURNOS (Burglary)
-- ==========================================
RegisterNetEvent('illegal-system:client:startBurglaryMinigame', function(storeName, targetType, sessionToken)
    local minigameConfig = Config.Crimes['store_robbery'].minigame
    
    if minigameConfig.type == 'tierbar' then
        SendNUIMessage({
            action = "START_MINIGAME",
            duration = minigameConfig.duration,
            zones = minigameConfig.zones
        })
        SetNuiFocus(true, false)
        
        -- Simular animação de arrombamento (kneel)
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, false, false, false)
        
        local timer = minigameConfig.duration * 1000
        local elapsed = 0
        local result = nil
        
        local listener
        listener = RegisterNUICallback('minigameResult', function(data, cb)
            result = data.tier
            cb('ok')
        end)
        
        while elapsed < timer and result == nil do
            Wait(100)
            elapsed = elapsed + 100
        end
        
        SetNuiFocus(false, false)
        ClearPedTasks(PlayerPedId())
        
        if result and result ~= 'fail' then
            TriggerServerEvent('illegal-system:server:finishBurglary', storeName, targetType, sessionToken, result, elapsed)
        else
            Bridge.Notify("Você falhou no arrombamento!", "error")
        end
    end
end)

-- ==========================================
-- 3. TARGETS (Terceiro Olho)
-- ==========================================
CreateThread(function()
    for _, store in ipairs(Config.Stores) do
        -- Tranca da Porta (Somente à noite)
        exports.ox_target:addBoxZone({
            coords = store.doorCoords,
            size = vec3(2.0, 2.0, 3.0),
            rotation = 0,
            options = {
                {
                    name = 'burglary_door_'..store.name,
                    icon = 'fa-solid fa-unlock',
                    label = 'Arrombar Porta',
                    canInteract = function()
                        local hour = GetClockHours()
                        if hour < store.openHour or hour >= store.closeHour then return true end
                        return false
                    end,
                    onSelect = function()
                        TriggerServerEvent('illegal-system:server:attemptBurglary', store.name, 'door')
                    end
                }
            }
        })
        
        -- Caixa Registradora (Dia e Noite)
        exports.ox_target:addBoxZone({
            coords = store.registerCoords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 0,
            options = {
                {
                    name = 'robbery_register_day_'..store.name,
                    icon = 'fa-solid fa-gun',
                    label = 'Assaltar o Caixa',
                    canInteract = function()
                        local hour = GetClockHours()
                        if hour >= store.openHour and hour < store.closeHour then return true end
                        return false
                    end,
                    onSelect = function()
                        TriggerServerEvent('illegal-system:server:attemptStoreRobbery', store.name)
                    end
                },
                {
                    name = 'burglary_register_night_'..store.name,
                    icon = 'fa-solid fa-cash-register',
                    label = 'Arrombar Registradora',
                    canInteract = function()
                        local hour = GetClockHours()
                        if hour < store.openHour or hour >= store.closeHour then return true end
                        return false
                    end,
                    onSelect = function()
                        TriggerServerEvent('illegal-system:server:attemptBurglary', store.name, 'register')
                    end
                }
            }
        })
    end
end)
