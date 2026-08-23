local FDBCore = exports['fdb-core']:GetCoreObject()
local isLoggedIn = false

local DRYING_TIME_MS = 120000 -- 2 minutes out of water to dry
local TICK_RATE = 4000 -- Matches Config.DrainRates.TickRate from fdb-survival
local timeOutWater = 0

local function ResetDryingTimer()
    timeOutWater = 0
end

local function StartDryingTimer()
    if LocalPlayer.state.isWet then
        timeOutWater = timeOutWater + TICK_RATE
        if timeOutWater >= DRYING_TIME_MS then
            TriggerServerEvent('fdb-water:server:dryPlayer')
            lib.notify({title = 'Seco', description = 'O vento e o tempo secaram suas roupas.', type = 'success'})
            timeOutWater = 0
        end
    else
        timeOutWater = 0
    end
end

RegisterNetEvent('FDBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    timeOutWater = 0
end)

RegisterNetEvent('FDBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

CreateThread(function()
    while true do
        Wait(TICK_RATE)
        if isLoggedIn then
            local ped = cache.ped
            
            if IsEntityInWater(ped) and GetEntitySubmergedLevel(ped) > 0.3 then
                ResetDryingTimer()
                
                -- Anti-spam for cleanliness
                local pData = FDBCore.Functions.GetPlayerData()
                if pData and pData.metadata then
                    local currentCleanliness = pData.metadata['cleanliness'] or 100
                    if currentCleanliness < 100 then
                        TriggerServerEvent('fdb-water:server:WashInRiver')
                    end
                end
                
                -- Anti-spam for isWet
                if not LocalPlayer.state.isWet then
                    TriggerServerEvent('fdb-water:server:makeWet')
                    lib.notify({title = 'Encharcado', description = 'Você entrou na água e suas roupas estão completamente molhadas!', type = 'inform'})
                end
            else
                StartDryingTimer()
            end
        end
    end
end)

local DrinkPrompt
local FillPrompt
local function SetupDrinkPrompt()
    local str1 = 'Beber Água'
    DrinkPrompt = PromptRegisterBegin()
    PromptSetControlAction(DrinkPrompt, 0xCEFD9220) -- E key
    PromptSetText(DrinkPrompt, CreateVarString(10, 'LITERAL_STRING', str1))
    PromptSetEnabled(DrinkPrompt, false)
    PromptSetVisible(DrinkPrompt, false)
    PromptSetStandardMode(DrinkPrompt, true)
    PromptSetHoldMode(DrinkPrompt, 1000)
    PromptRegisterEnd(DrinkPrompt)

    local str2 = 'Encher Cantil/Garrafa'
    FillPrompt = PromptRegisterBegin()
    PromptSetControlAction(FillPrompt, 0x760A9C6F) -- G key
    PromptSetText(FillPrompt, CreateVarString(10, 'LITERAL_STRING', str2))
    PromptSetEnabled(FillPrompt, false)
    PromptSetVisible(FillPrompt, false)
    PromptSetStandardMode(FillPrompt, true)
    PromptSetHoldMode(FillPrompt, 1000)
    PromptRegisterEnd(FillPrompt)
end

CreateThread(function()
    SetupDrinkPrompt()
    local isDrinking = false
    
    while true do
        local wait = 1000
        if isLoggedIn and Config.EnableWaterPrompts then
            local ped = cache.ped
            if IsEntityInWater(ped) and GetEntitySubmergedLevel(ped) > 0.1 and not isDrinking and not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) then
                local coords = GetEntityCoords(ped)
                local water = GetWaterMapZoneAtCoords(coords.x, coords.y, coords.z)
                
                -- Check if it's a valid natural water source (not inside a bathtub)
                if water ~= 0 then
                    wait = 0
                    PromptSetVisible(DrinkPrompt, true)
                    PromptSetEnabled(DrinkPrompt, true)
                    PromptSetVisible(FillPrompt, true)
                    PromptSetEnabled(FillPrompt, true)
                    
                    if PromptHasHoldModeCompleted(DrinkPrompt) then
                        isDrinking = true
                        PromptSetVisible(DrinkPrompt, false)
                        PromptSetEnabled(DrinkPrompt, false)
                        PromptSetVisible(FillPrompt, false)
                        PromptSetEnabled(FillPrompt, false)
                        
                        TaskStartScenarioInPlace(ped, joaat('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
                        Wait(4000)
                        ClearPedTasks(ped)
                        
                        TriggerServerEvent('fdb-water:server:DrinkNaturalWater')
                        
                        Wait(3000) -- anti-spam cooldown
                        isDrinking = false
                    end

                    if PromptHasHoldModeCompleted(FillPrompt) then
                        isDrinking = true
                        PromptSetVisible(DrinkPrompt, false)
                        PromptSetEnabled(DrinkPrompt, false)
                        PromptSetVisible(FillPrompt, false)
                        PromptSetEnabled(FillPrompt, false)
                        
                        TriggerServerEvent('fdb-water:server:FillContainerFromPrompt')
                        Wait(5000)
                        isDrinking = false
                    end
                else
                    PromptSetVisible(DrinkPrompt, false)
                    PromptSetEnabled(DrinkPrompt, false)
                    PromptSetVisible(FillPrompt, false)
                    PromptSetEnabled(FillPrompt, false)
                end
            else
                if DrinkPrompt then
                    PromptSetVisible(DrinkPrompt, false)
                    PromptSetEnabled(DrinkPrompt, false)
                    PromptSetVisible(FillPrompt, false)
                    PromptSetEnabled(FillPrompt, false)
                end
            end
        end
        Wait(wait)
    end
end)
