local currentNodeType = nil
local currentNodeData = nil
local currentNodeToken = nil
local currentZoneId = nil

RegisterNetEvent('node_engine:client:StartNodeAction', function(type, data, token)
    print("[NodeEngine Debug] Recebido StartNodeAction. Tipo: " .. tostring(type))
    currentNodeType = type
    currentNodeData = data
    currentNodeToken = token

    if currentZoneId then
        exports.ox_target:removeZone(currentZoneId)
        currentZoneId = nil
    end

    if type == "open_door" or type == "crack_register" then
        print("[NodeEngine Debug] Criando ox_target zone para: " .. type)
        currentZoneId = exports.ox_target:addSphereZone({
            coords = data.coords,
            radius = 1.5,
            debug = true, -- Exibe a zona visível para facilitar o teste da Fase 1
            options = {
                {
                    name = 'node_action',
                    label = data.prompt or "Interagir",
                    icon = "fas fa-hand",
                    onSelect = function()
                        -- Removemos o target instantaneamente para evitar spam
                        exports.ox_target:removeZone(currentZoneId)
                        currentZoneId = nil
                        
                        local minTime = (data.minTime or 1) * 1000
                        lib.showTextUI("Executando...")
                        Wait(minTime + 500)
                        lib.hideTextUI()
                        
                        TriggerServerEvent('node_engine:server:ReportNodeCompletion', currentNodeToken, { success = true })
                    end
                }
            }
        })
    end
end)

RegisterNetEvent('node_engine:client:EndSession', function()
    currentNodeType = nil
    currentNodeData = nil
    currentNodeToken = nil
    if currentZoneId then
        exports.ox_target:removeZone(currentZoneId)
        currentZoneId = nil
    end
    print("[NodeEngine] Sessão concluída com sucesso.")
end)

RegisterCommand('heistdebugc', function()
    print("=== HEIST DEBUG CLIENT ===")
    print("currentNodeType: " .. tostring(currentNodeType))
    print("currentNodeToken: " .. tostring(currentNodeToken))
end, false)
