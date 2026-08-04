local IsDrunk = false
local IsPassedOut = false

-- Helper para Animações
local function PlayAnimation(ped, dict, name, flag, duration)
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 50 do 
        Wait(10)
        timeout = timeout + 1
    end
    if timeout >= 50 then 
        return 
    end
    TaskPlayAnim(ped, dict, name, 8.0, -8.0, duration, flag, 0, false, false, false)
end

-- Efeitos do Álcool
RegisterNetEvent('fdb-survival:client:stateChanged', function(data)
    if data.field ~= 'drunkenness' then return end
    local alcoholLevel = data.value
    local ped = PlayerPedId()
    
    if alcoholLevel > Config.Alcohol.PassOutThreshold then
        if not IsPassedOut then
            IsPassedOut = true
            lib.notify({title = locale('notify_blackout_title'), description = locale('notify_blackout_desc'), type = 'error'})
            
            Citizen.CreateThread(function()
                local lastCheck = 0
                while IsPassedOut do
                    Wait(0)
                    DisableAllControlActions(0)
                    
                    local now = GetGameTimer()
                    if now - lastCheck > 1000 then
                        local p = PlayerPedId()
                        if not IsEntityPlayingAnim(p, 'amb_rest@world_human_sleep_ground@arm@male_b@idle_b', 'idle_f', 3) then
                            ClearPedTasks(p)
                            PlayAnimation(p, 'amb_rest@world_human_sleep_ground@arm@male_b@idle_b', 'idle_f', 1, -1)
                        end
                        lastCheck = now
                    end
                end
            end)
        end
    elseif alcoholLevel > Config.Alcohol.DrunkThreshold then
        if IsPassedOut then
            IsPassedOut = false
            ClearPedTasks(ped)
            lib.notify({title = locale('notify_hangover_title'), description = locale('notify_hangover_desc'), type = 'inform'})
        end

        if not IsDrunk then
            IsDrunk = true
            lib.notify({title = locale('notify_drunk_title'), description = locale('notify_drunk_desc'), type = 'inform'})
            
            ShakeGameplayCam("DRUNK_SHAKE", 0.5)
            Citizen.InvokeNative(0x406CCF555B04FAD3, ped, true, 1.0) 
            
            -- O clipset mp_style_drunk será aplicado pelo movement.lua

            
            Citizen.CreateThread(function()
                while IsDrunk do
                    Wait(500)
                    local p = PlayerPedId()
                    if IsPedSprinting(p) or IsPedRunning(p) then
                        local drunkenness = FDB.Survival.drunkenness or 0
                        local tripChance = 35
                        if drunkenness >= 50 then
                            tripChance = 50
                        end
                        
                        if math.random(1, 100) <= tripChance then
                            SetPedToRagdoll(p, 3000, 3000, 0, false, false, false)
                            lib.notify({title = '😵 Oops!', description = 'Você tentou correr bêbado e tropeçou!', type = 'error'})
                            Wait(4000)
                        end
                    end
                end
            end)
        end
    else
        if IsPassedOut then
            IsPassedOut = false
            ClearPedTasks(ped)
        end
        if IsDrunk then
            IsDrunk = false
            Citizen.InvokeNative(0x406CCF555B04FAD3, ped, false, 0.0)
            -- ResetPedMovementClipset removido; movement.lua cuida disso
            
            ShakeGameplayCam("DRUNK_SHAKE", 0.0)
            lib.notify({title = '💧 Sóbrio', description = 'O efeito do álcool passou.', type = 'success'})
        end
    end
end)

