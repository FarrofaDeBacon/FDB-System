local activeProp = nil
local activeProp2 = nil
local isHoldingFood = false
local consumePrompt = nil
local dropPrompt = nil

local function CreateFoodPrompts()
    Citizen.CreateThread(function()
        consumePrompt = nil
        dropPrompt = nil

        consumePrompt = PromptRegisterBegin()
        PromptSetControlAction(consumePrompt, Config.Prompts.SmokeKey) -- Botão Esquerdo
        PromptSetText(consumePrompt, CreateVarString(10, 'LITERAL_STRING', locale('prompt_bite')))
        PromptSetEnabled(consumePrompt, true)
        PromptSetVisible(consumePrompt, true)
        PromptSetHoldMode(consumePrompt, false)
        PromptRegisterEnd(consumePrompt)

        dropPrompt = PromptRegisterBegin()
        PromptSetControlAction(dropPrompt, Config.Prompts.DropKey) -- R
        PromptSetText(dropPrompt, CreateVarString(10, 'LITERAL_STRING', locale('prompt_drop')))
        PromptSetEnabled(dropPrompt, true)
        PromptSetVisible(dropPrompt, true)
        PromptSetHoldMode(dropPrompt, false)
        PromptRegisterEnd(dropPrompt)
    end)
end

RegisterNetEvent('fdb-consume:client:ConsumeFood', function(propModel, animType, maxUses, animDict, animName, itemName)
    local ped = PlayerPedId()

    if isHoldingFood then
        TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
        Wait(50)
    end
    
    isHoldingFood = true
    maxUses = maxUses or 3

    if animType == "Stew" then
        RequestModel(`p_bowl04x_stew`)
        RequestModel(`p_spoon01x`)
        while not HasModelLoaded(`p_bowl04x_stew`) or not HasModelLoaded(`p_spoon01x`) do Wait(10) end
        
        local coords = GetEntityCoords(ped)
        activeProp = CreateObject(`p_bowl04x_stew`, coords.x, coords.y, coords.z, true, true, false)
        activeProp2 = CreateObject(`p_spoon01x`, coords.x, coords.y, coords.z, true, true, false)
        
        Citizen.InvokeNative(0x669655FFB29EF1A9, activeProp, 0, "Stew_Fill", 1.0)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, activeProp, 20)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, activeProp2, 82)
        TaskItemInteraction_2(ped, 599184882, activeProp, `p_bowl04x_stew_ph_l_hand`, -583731576, 1, 0, 0.0)
        TaskItemInteraction_2(ped, 599184882, activeProp2, `p_spoon01x_ph_r_hand`, -583731576, 1, 0, 0.0)
        Citizen.InvokeNative(0xB35370D5353995CB, ped, -583731576, 1.0)
        
        Wait(8000)
        if itemName then
            TriggerServerEvent('fdb-consume:server:giveReturnItem', itemName)
        end
        TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
        return
    end

    local modelHash = GetHashKey(propModel)
    RequestModel(modelHash)
    
    local attempts = 0
    while not HasModelLoaded(modelHash) and attempts < 100 do Wait(10); attempts = attempts + 1 end

    if not HasModelLoaded(modelHash) then isHoldingFood = false; return end

    local coords = GetEntityCoords(ped)
    activeProp = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
    
    local boneName = 'SKEL_R_HAND'
    local x, y, z = 0.1, -0.01, -0.07
    local rx, ry, rz = -90.0, 100.0, 0.0

    if animType == "Canned" then
        x, y, z = 0.10, -0.01, -0.07
        rx, ry, rz = -90.0, 10.0, 0.0
    end

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

    if animType == "Stew" then
        RequestModel(`p_spoon01x`)
        while not HasModelLoaded(`p_spoon01x`) do Wait(10) end
        activeProp2 = CreateObject(`p_spoon01x`, coords.x, coords.y, coords.z, true, true, false)
        local spoonBoneIndex = GetEntityBoneIndexByName(ped, "PH_R_HAND")
        AttachEntityToEntity(activeProp2, ped, spoonBoneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end

    CreateFoodPrompts()

    Citizen.CreateThread(function()
        local isAnimating = false
        while isHoldingFood do
            Wait(0)
            DisableControlAction(0, Config.Prompts.SmokeKey, true)
            DisableControlAction(0, Config.Prompts.ChugKey, true)
            
            if IsControlJustReleased(0, Config.Prompts.DropKey) then
                TriggerServerEvent('fdb-consume:server:cancelConsume')
                TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
            end

            -- MODO 1: Clique Rápido (Mordida Unica)
            if IsDisabledControlJustPressed(0, Config.Prompts.SmokeKey) and not isAnimating then
                isAnimating = true
                local dict = animDict or "mech_inventory@eating@multi_bite@sphere_d8-2_sandwich"
                local clip = animName or "quick_right_hand"
                
                if not animDict and animType == "Canned" then
                    dict = "mech_inventory@eating@canned_food@cylinder@d8-2_h10-5"
                    clip = "left_hand"
                end

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(10) end
                
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, 2000, 31, 0.0, false, false, false)
                TriggerServerEvent('fdb-consume:server:takeBite')
                
                Wait(2000)
                ClearPedSecondaryTask(ped)
                isAnimating = false
            end

            -- MODO 2: Segurar Botão Direito (Comer Tudo)
            if IsDisabledControlJustPressed(0, Config.Prompts.ChugKey) and not isAnimating then
                isAnimating = true
                local dict = animDict or "mech_inventory@eating@multi_bite@sphere_d8-2_sandwich"
                local clip = animName or "quick_right_hand"
                
                if not animDict and animType == "Canned" then
                    dict = "mech_inventory@eating@canned_food@cylinder@d8-2_h10-5"
                    clip = "left_hand"
                end

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(10) end
                
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, -1, 31, 0.0, false, false, false)
                
                local lastBiteTime = GetGameTimer()
                TriggerServerEvent('fdb-consume:server:takeBite')

                while IsDisabledControlPressed(0, Config.Prompts.ChugKey) and isHoldingFood do
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
    if isHoldingFood then
        isHoldingFood = false
        if consumePrompt then PromptDelete(consumePrompt); consumePrompt = nil end
        if chugPrompt then PromptDelete(chugPrompt); chugPrompt = nil end
        if dropPrompt then PromptDelete(dropPrompt); dropPrompt = nil end
        if activeProp and DoesEntityExist(activeProp) then DeleteObject(activeProp); activeProp = nil end
        if activeProp2 and DoesEntityExist(activeProp2) then DeleteObject(activeProp2); activeProp2 = nil end
        ClearPedTasks(PlayerPedId())
    end
end)

