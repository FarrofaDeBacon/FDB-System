local isRobbingStore = false
local robbedPeds = {}
local currentRobbedPed = 0

local function GetStoreZone(pedCoords)
    for _, store in ipairs(Config.Stores) do
        local dist = #(pedCoords - store.coords)
        if dist <= store.radius then
            return store
        end
    end
    return nil
end

local function HandlePedReaction(ped, reaction, storeName)
    local storeConfig = nil
    for _, s in ipairs(Config.Stores) do
        if s.name == storeName then
            storeConfig = s
            break
        end
    end

    SetBlockingOfNonTemporaryEvents(ped, true)
    
    if reaction == 'comply' then
        local dict = "mech_loco_m@generic@reaction@handsup@unarmed@normal"
        local anim = "loop"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end
        
        ClearPedTasksImmediately(ped)
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 31, 0, false, 0, false, 0, false)
        Bridge.Notify("Calma, calma! Leve tudo!", "success")
        Wait(5000)
        ClearPedTasks(ped)
        TaskCower(ped, -1)
        
    elseif reaction == 'fight' then
        Bridge.Notify("Você não vai levar nada meu!", "error")
        GiveWeaponToPed_2(ped, 0x1D073A89, 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        TaskCombatPed(ped, PlayerPedId(), 0, 16)
        
    elseif reaction == 'flee' then
        Bridge.Notify("Por favor, não me machuque!", "error")
        TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, false, false)
    end
    
    SetTimeout(30000, function()
        if DoesEntityExist(ped) then
            SetBlockingOfNonTemporaryEvents(ped, false)
            ClearPedTasks(ped)
        end
    end)
end

RegisterNetEvent('illegal-system:client:storeRobberyReaction', function(reaction, storeName)
    if currentRobbedPed > 0 and DoesEntityExist(currentRobbedPed) then
        HandlePedReaction(currentRobbedPed, reaction, storeName)
        currentRobbedPed = 0
    end
    Wait(5000)
    isRobbingStore = false
end)

RegisterNetEvent('illegal-system:client:storeRobberyFailed', function(reason)
    if reason == 'cooldown' then
        Bridge.Notify("Sistema", "Esta área já foi roubada recentemente.", "error")
    end
    isRobbingStore = false
    currentRobbedPed = 0
end)

CreateThread(function()
    -- 1. Método Diurno: Assalto à mão armada (Mirando no NPC)
    CreateThread(function()
        while true do
            Wait(250)
            if not isRobbingStore and IsPedArmed(PlayerPedId(), 4) then
                local isAiming, targetEntity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if isAiming and targetEntity and DoesEntityExist(targetEntity) and not IsPedAPlayer(targetEntity) then
                    local coords = GetEntityCoords(targetEntity)
                    local store = GetStoreZone(coords)
                    
                    if store then
                        local hour = GetClockHours()
                        if hour >= store.openHour and hour < store.closeHour then
                            if not robbedPeds[targetEntity] then
                                robbedPeds[targetEntity] = true
                                isRobbingStore = true
                                currentRobbedPed = targetEntity
                                SetBlockingOfNonTemporaryEvents(targetEntity, true)
                                TriggerServerEvent('illegal-system:server:attemptStoreRobbery', store.name, 'day')
                            end
                        end
                    end
                end
            else
                Wait(1000)
            end
        end
    end)
    
    -- 2. Método Noturno: Burglary (Porta e Registradora)
    for _, store in ipairs(Config.Stores) do
        -- Tranca da Porta
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
                        if hour < store.openHour or hour >= store.closeHour then
                            return true
                        end
                        return false
                    end,
                    onSelect = function()
                        TriggerServerEvent('illegal-system:server:attemptBurglary', store.name, 'door')
                    end
                }
            }
        })
        
        -- Caixa Registradora
        exports.ox_target:addBoxZone({
            coords = store.registerCoords,
            size = vec3(1.5, 1.5, 1.5),
            rotation = 0,
            options = {
                {
                    name = 'burglary_register_'..store.name,
                    icon = 'fa-solid fa-cash-register',
                    label = 'Arrombar Registradora',
                    canInteract = function()
                        local hour = GetClockHours()
                        if hour < store.openHour or hour >= store.closeHour then
                            return true
                        end
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

-- Iniciar Minigames do Burglary
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
