-- client/interactives.lua
-- Sistema Interativo para Comidas e Bebidas

local activeProp = nil
local activeType = nil
local consumePrompt = nil
local dropPrompt = nil
local isHoldingConsumable = false

function CreateConsumablePrompts(animType)
    Citizen.CreateThread(function()
        consumePrompt = nil
        dropPrompt = nil

        local consumeText = (animType == "drink" or animType == "medical" or animType == "drug") and "Dar Gole" or "Dar Mordida"
        
        consumePrompt = PromptRegisterBegin()
        PromptSetControlAction(consumePrompt, Config.Prompts.SmokeKey) -- Usa o botão esquerdo (mesmo do trago)
        PromptSetText(consumePrompt, CreateVarString(10, 'LITERAL_STRING', consumeText))
        PromptSetEnabled(consumePrompt, true)
        PromptSetVisible(consumePrompt, true)
        PromptSetHoldMode(consumePrompt, false)
        PromptRegisterEnd(consumePrompt)

        dropPrompt = PromptRegisterBegin()
        PromptSetControlAction(dropPrompt, Config.Prompts.DropKey) -- R
        PromptSetText(dropPrompt, CreateVarString(10, 'LITERAL_STRING', "Jogar Fora"))
        PromptSetEnabled(dropPrompt, true)
        PromptSetVisible(dropPrompt, true)
        PromptSetHoldMode(dropPrompt, false)
        PromptRegisterEnd(dropPrompt)
    end)
end

function DeleteConsumablePrompts()
    if consumePrompt then
        PromptDelete(consumePrompt)
        consumePrompt = nil
    end
    if dropPrompt then
        PromptDelete(dropPrompt)
        dropPrompt = nil
    end
end

RegisterNetEvent('fdb-consume:client:StartInteractiveConsumable', function(animType, propHash, attachDef)
    local ped = PlayerPedId()
    
    if isHoldingConsumable then
        -- Já está segurando, joga fora o antigo
        TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
    end

    isHoldingConsumable = true
    activeType = animType
    
    local coords = GetEntityCoords(ped)
    activeProp = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, false)
    
    local boneIndex = GetEntityBoneIndexByName(ped, 'SKEL_R_HAND')
    AttachEntityToEntity(activeProp, ped, boneIndex, attachDef.x, attachDef.y, attachDef.z, attachDef.rx, attachDef.ry, attachDef.rz, true, true, false, true, 1, true)

    CreateConsumablePrompts(animType)

    Citizen.CreateThread(function()
        local isAnimating = false
        while isHoldingConsumable do
            Wait(0)
            if IsControlJustReleased(0, Config.Prompts.DropKey) then
                TriggerServerEvent('fdb-consume:server:cancelConsume')
                TriggerEvent('fdb-consume:client:StopInteractiveConsumable')
            end

            if IsDisabledControlJustPressed(0, Config.Prompts.SmokeKey) then
                local dict = "mech_inventory@eating@multi_bite@sphere_d8-2_sandwich"
                local clip = "quick_right_hand"
                
                if activeType == "drink" or activeType == "medical" or activeType == "drug" then
                    dict = "amb_rest_drunk@world_human_drinking@male_a@idle_a"
                    clip = "idle_a"
                elseif activeType == "canned" then
                    dict = "mech_inventory@eating@canned_food@cylinder@d8-2_h10-5"
                    clip = "left_hand"
                end

                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do Wait(10) end
                
                TaskPlayAnim(ped, dict, clip, 8.0, -8.0, -1, 31, 0.0, false, false, false)
                
                local lastBiteTime = GetGameTimer()
                TriggerServerEvent('fdb-consume:server:takeBite')

                while IsDisabledControlPressed(0, Config.Prompts.SmokeKey) and isHoldingConsumable do
                    Wait(0)
                    DisableControlAction(0, Config.Prompts.SmokeKey, true)
                    local now = GetGameTimer()
                    if now - lastBiteTime > 2000 then
                        TriggerServerEvent('fdb-consume:server:takeBite')
                        lastBiteTime = now
                    end
                end
                
                ClearPedTasks(ped)
            end
        end
    end)
end)

RegisterNetEvent('fdb-consume:client:StopInteractiveConsumable', function()
    if isHoldingConsumable then
        isHoldingConsumable = false
        DeleteConsumablePrompts()
        
        if activeProp and DoesEntityExist(activeProp) then
            DetachEntity(activeProp, true, true)
            DeleteObject(activeProp)
            activeProp = nil
        end
        activeType = nil
        ClearPedTasks(PlayerPedId())
    end
end)
