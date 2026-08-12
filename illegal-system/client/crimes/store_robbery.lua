local isRobbingStore = false
local robbedPeds = {}
local currentRobbedPed = 0

-- Injeta atributos no lojista assim que o fdb-shops spawna ele
AddEventHandler('fdb-shops:client:npcCreated', function(npc, shopData)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedFleeAttributes(npc, 0, false)
end)

-- Bloqueia a IA nativa retroativamente nos NPCs que já existem
CreateThread(function()
    Wait(2000) -- Espera o fdb-shops iniciar caso reiniciem juntos
    for _, store in ipairs(Config.Stores) do
        local handle, ped = FindFirstPed()
        local success
        repeat
            if #(GetEntityCoords(ped) - store.coords) <= store.radius then
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, false)
            end
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end
end)
local function GetStoreZone(pedCoords)
    for _, store in ipairs(Config.Stores) do
        local dist = #(pedCoords - store.coords)
        if dist <= store.radius then
            return store
        end
    end
    return nil
end

RegisterNetEvent('illegal-system:client:startStoreRobbery', function(storeName, sessionToken)
    local ped = currentRobbedPed -- o NPC que foi mirado, salvo no passo 2

    local reactionRoll = math.random(1, 100)
    local crimeConfig = Config.Crimes['store_robbery']
    local complyChance = crimeConfig.reactions.comply
    local fightChance = complyChance + crimeConfig.reactions.fight
    local reaction = reactionRoll <= complyChance and 'comply'
        or reactionRoll <= fightChance and 'fight'
        or 'flee'

    SetBlockingOfNonTemporaryEvents(ped, true)

    if reaction == 'comply' then
        TaskHandsUp(ped, 8000, PlayerPedId(), -1, true)
        Bridge.Notify("Calma, calma! Leve tudo!", "success")

        if lib.progressBar({
            duration = 8000, label = "Levando o dinheiro...",
            disable = { car = true, move = true, combat = false }, canCancel = true
        }) then
            TriggerServerEvent('illegal-system:server:finishStoreRobbery', storeName, sessionToken)
        else
            TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)
        end
        isRobbingStore = false

    elseif reaction == 'fight' then
        Bridge.Notify("Você não vai levar nada meu!", "error")
        GiveWeaponToPed_2(ped, 0x1D073A89, 50, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        SetPedCombatMovement(ped, 0) -- 0 = Stationary (Fica parado atirando)
        TaskCombatPed(ped, PlayerPedId(), 0, 16)
        isRobbingStore = false
        TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)

    elseif reaction == 'flee' then
        Bridge.Notify("Por favor, não me machuque!", "error")
        -- FIX do bug de hoje: TaskSmartFleePed em vez de TaskGoToCoordAnyMeans.
        -- Foge do jogador com desvio de obstáculo, não trava mais no balcão.
        TaskSmartFleePed(ped, PlayerPedId(), 100.0, -1, false, false)
        isRobbingStore = false
        TriggerServerEvent('illegal-system:server:cancelStoreRobbery', storeName, sessionToken)
    end

    SetTimeout(30000, function()
        if DoesEntityExist(ped) then
            SetBlockingOfNonTemporaryEvents(ped, false)
            ClearPedTasks(ped)
        end
        robbedPeds[ped] = nil
    end)
end)

RegisterNetEvent('illegal-system:client:storeRobberyFailed', function(reason)
    if reason == 'cooldown' then
        Bridge.Notify("Sistema", "Esta área já foi roubada recentemente.", "error")
    end
    isRobbingStore = false
    currentRobbedPed = 0
end)

CreateThread(function()
    CreateThread(function()
        while true do
            Wait(250)
            if not isRobbingStore then
                local hasWep, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true, 0, true)
                if hasWep and weaponHash ~= GetHashKey('WEAPON_UNARMED') then
                    local isFreeAiming, targetFreeAim = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    local isTargeting, targetLockOn = GetPlayerTargetEntity(PlayerId())
                    local isAiming = isFreeAiming or isTargeting
                    local targetEntity = isFreeAiming and targetFreeAim or targetLockOn

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
