local activeProp = nil
local isHoldingDrink = false
local consumePrompt = nil
local dropPrompt = nil

local function CreateDrinkPrompts()
    Citizen.CreateThread(function()
        consumePrompt = nil
        chugPrompt = nil
        dropPrompt = nil

        consumePrompt = PromptRegisterBegin()
        PromptSetControlAction(consumePrompt, Config.Prompts.SmokeKey)
        PromptSetText(consumePrompt, CreateVarString(10, 'LITERAL_STRING', Config.Smoke))
        PromptSetEnabled(consumePrompt, true)
        PromptSetVisible(consumePrompt, true)
        PromptSetHoldMode(consumePrompt, false)
        PromptRegisterEnd(consumePrompt)
        
        chugPrompt = PromptRegisterBegin()
        PromptSetControlAction(chugPrompt, Config.Prompts.ChugKey)
        PromptSetText(chugPrompt, CreateVarString(10, 'LITERAL_STRING', Config.Chug))
        PromptSetEnabled(chugPrompt, true)
        PromptSetVisible(chugPrompt, true)
        PromptSetHoldMode(chugPrompt, false)
        PromptRegisterEnd(chugPrompt)

        dropPrompt = PromptRegisterBegin()
        PromptSetControlAction(dropPrompt, Config.Prompts.DropKey)
        PromptSetText(dropPrompt, CreateVarString(10, 'LITERAL_STRING', Config.Drop))
        PromptSetEnabled(dropPrompt, true)
        PromptSetVisible(dropPrompt, true)
        PromptSetHoldMode(dropPrompt, false)
        PromptRegisterEnd(dropPrompt)
    end)
end

RegisterNetEvent('fdb-consume:client:ConsumeDrink', function(propModel, animType, maxUses, animDict, animName, itemName)
    local ped = PlayerPedId()

    if isHoldingDrink then
        TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
    end

    isHoldingDrink = true
    maxUses = maxUses or 3

    if animType == "Coffee" then
        RequestModel(`p_mug01_coffee`)
        while not HasModelLoaded(`p_mug01_coffee`) do Wait(10) end
        
        local coords = GetEntityCoords(ped)
        activeProp = CreateObject(`p_mug01_coffee`, coords.x, coords.y, coords.z, true, true, false)
        TaskItemInteraction_2(ped, 599184882, activeProp, GetHashKey('p_cs_coffee_mug01x_ph_r_hand'), -583731576, 1, 0, 0.0)
        
        Wait(5000)
        TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
        return
    end

    local modelHash = GetHashKey(propModel)
    RequestModel(modelHash)
    local attempts = 0
    while not HasModelLoaded(modelHash) and attempts < 100 do Wait(10); attempts = attempts + 1 end
    if not HasModelLoaded(modelHash) then isHoldingDrink = false; return end

    local coords = GetEntityCoords(ped)
    activeProp = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
    
    local boneName = 'SKEL_R_HAND'
    local x, y, z = 0.05, -0.07, -0.05
    local rx, ry, rz = -75.0, 60.0, 0.0

    if itemName and Config.Items[itemName] and Config.Items[itemName].offsets then
        local off = Config.Items[itemName].offsets
        if off.bone then boneName = off.bone end
        if off.hand_idle then
            x, y, z = off.hand_idle.x or x, off.hand_idle.y or y, off.hand_idle.z or z
            rx, ry, rz = off.hand_idle.rx or rx, off.hand_idle.ry or ry, off.hand_idle.rz or rz
        end
    end

    local boneIndex = GetEntityBoneIndexByName(ped, boneName)

    AttachEntityToEntity(activeProp, ped, boneIndex, x, y, z, rx, ry, rz, true, true, false, true, 1, true)
    CreateDrinkPrompts()

    Citizen.CreateThread(function()
        local isAnimating = false
        while isHoldingDrink do
            Wait(0)
            DisableControlAction(0, Config.Prompts.SmokeKey, true)
            DisableControlAction(0, Config.Prompts.ChugKey, true)
            
            if IsControlJustReleased(0, Config.Prompts.DropKey) then
                TriggerServerEvent('fdb-consume:server:cancelConsumable')
                TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
            end

            -- MODO 1: Clique Rápido (Dar um Gole)
            if IsDisabledControlJustPressed(0, Config.Prompts.SmokeKey) and not isAnimating then
                isAnimating = true
                local dict = animDict or "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5"
                local clip = animName or "chug_a"

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(10) end
                
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, 2000, 31, 0.0, false, false, false)
                TriggerServerEvent('fdb-consume:server:takeBite')
                
                Wait(2000)
                ClearPedSecondaryTask(ped)
                isAnimating = false
            end

            -- MODO 2: Segurar Botão Direito (Beber de Uma Vez)
            if IsDisabledControlJustPressed(0, Config.Prompts.ChugKey) and not isAnimating then
                isAnimating = true
                local dict = animDict or "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5"
                local clip = animName or "chug_a"

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(10) end
                
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, -1, 31, 0.0, false, false, false)
                
                local lastBiteTime = GetGameTimer()
                TriggerServerEvent('fdb-consume:server:takeBite')

                while IsDisabledControlPressed(0, Config.Prompts.ChugKey) and isHoldingDrink do
                    Wait(0)
                    DisableControlAction(0, Config.Prompts.SmokeKey, true)
                    DisableControlAction(0, Config.Prompts.ChugKey, true)
                    local now = GetGameTimer()
                    if now - lastBiteTime > 2000 then
                        TriggerServerEvent('fdb-consume:server:takeBite')
                        lastBiteTime = now
                    end
                end
                
                ClearPedSecondaryTask(ped)
                isAnimating = false
            end
        end
    end)
end)

RegisterNetEvent('fdb-consume:client:StopInteractiveConsumable', function()
    if isHoldingDrink then
        isHoldingDrink = false
        if consumePrompt then PromptDelete(consumePrompt); consumePrompt = nil end
        if chugPrompt then PromptDelete(chugPrompt); chugPrompt = nil end
        if dropPrompt then PromptDelete(dropPrompt); dropPrompt = nil end
        if activeProp and DoesEntityExist(activeProp) then DeleteObject(activeProp); activeProp = nil end
        ClearPedTasks(PlayerPedId())
    end
end)
