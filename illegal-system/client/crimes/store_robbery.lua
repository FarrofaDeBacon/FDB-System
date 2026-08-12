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
        TaskHandsUp(ped, 5000, PlayerPedId(), -1, true)
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
        if storeConfig and storeConfig.fleeCoords then
            -- Usa a coordenada de fuga personalizada (que o jogador capturou no Modo Dev)
            TaskGoToCoordAnyMeans(ped, storeConfig.fleeCoords.x, storeConfig.fleeCoords.y, storeConfig.fleeCoords.z, 2.0, 0, 0, 786603, 0xbf800000)
        else
            -- Se não tiver configurado ainda, se abaixa (fallback)
            TaskCower(ped, -1)
        end
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
                    print("DEBUG Lojista - Entidade Mirada ID:", targetEntity)
                    print("DEBUG Lojista - GetPedCanBeTargetted:", GetPedCanBeTargetted(targetEntity))
                    local coords = GetEntityCoords(targetEntity)
                    local store = GetStoreZone(coords)
                    
                    if store then
                        local hour = GetClockHours()
                        if hour >= store.openHour and hour < store.closeHour then
                            if not robbedPeds[targetEntity] then
                                robbedPeds[targetEntity] = true
                                isRobbingStore = true
                                currentRobbedPed = targetEntity
                                
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
