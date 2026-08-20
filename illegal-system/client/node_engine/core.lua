local currentNodeType = nil
local currentNodeData = nil
local currentNodeToken = nil
local activePrompt = false
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local actionPrompt = nil

local function CreatePrompt(text)
    local str = CreateVarString(10, 'LITERAL_STRING', text)
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, 0x760A9C6F) -- G key
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, true)
    PromptSetVisible(prompt, true)
    PromptSetStandardMode(prompt, true)
    PromptSetGroup(prompt, promptGroup)
    PromptRegisterEnd(prompt)
    return prompt
end

RegisterNetEvent('node_engine:client:StartNodeAction', function(type, data, token)
    currentNodeType = type
    currentNodeData = data
    currentNodeToken = token

    if actionPrompt then
        PromptDelete(actionPrompt)
        actionPrompt = nil
    end

    if type == "open_door" or type == "crack_register" then
        actionPrompt = CreatePrompt(data.prompt or "Interagir")
        activePrompt = true
        
        CreateThread(function()
            while activePrompt do
                Wait(0)
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local dist = #(coords - data.coords)

                if dist < 5.0 then
                    local promptName = CreateVarString(10, 'LITERAL_STRING', "Ação: " .. type)
                    PromptSetActiveGroupThisFrame(promptGroup, promptName)

                    if PromptHasStandardModeCompleted(actionPrompt) then
                        activePrompt = false
                        PromptDelete(actionPrompt)
                        actionPrompt = nil
                        
                        -- Simula a execução do minigame/ação (aguardando o tempo mínimo pro servidor validar)
                        local minTime = (data.minTime or 1) * 1000
                        
                        lib.showTextUI("Executando...")
                        Wait(minTime + 500) -- Aguarda o tempo mais uma margem de segurança
                        lib.hideTextUI()
                        
                        TriggerServerEvent('node_engine:server:ReportNodeCompletion', currentNodeToken, { success = true })
                    end
                end
                
                -- Desenha marcador pra saber onde é
                DrawMarker(0x94FDAE17,
                    data.coords.x, data.coords.y, data.coords.z - 0.95,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    1.0, 1.0, 1.0,
                    255, 0, 0, 150,
                    false, false, 2, false, nil, nil, false)
            end
        end)
    end
end)

RegisterNetEvent('node_engine:client:EndSession', function()
    currentNodeType = nil
    currentNodeData = nil
    currentNodeToken = nil
    activePrompt = false
    if actionPrompt then
        PromptDelete(actionPrompt)
        actionPrompt = nil
    end
    print("[NodeEngine] Sessão concluída com sucesso.")
end)

RegisterCommand('heistdebugc', function()
    print("=== HEIST DEBUG CLIENT ===")
    print("currentNodeType: " .. tostring(currentNodeType))
    print("currentNodeToken: " .. tostring(currentNodeToken))
end, false)
