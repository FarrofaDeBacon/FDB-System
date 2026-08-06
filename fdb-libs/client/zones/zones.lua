fdb = fdb or {}
fdb.zones = {}

local activeZones = {}
local insideZones = {}

-- Função auxiliar para criar prompts nativos do RedM
local function createPrompt(text, control, holdDuration)
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, control or 0xE30CD707) -- default 'E'
    local str = CreateVarString(10, 'LITERAL_STRING', text or "Interagir")
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, true)
    PromptSetVisible(prompt, true)
    
    if holdDuration and holdDuration > 0 then
        PromptSetHoldMode(prompt, holdDuration)
    else
        PromptSetStandardMode(prompt, 0)
    end
    
    PromptRegisterEnd(prompt)
    return prompt
end

-- Cria/Adiciona uma nova zona circular
function fdb.zones.Create(name, coords, radius, options)
    options = options or {}
    
    -- Configuração padrão de cor do marcador (ouro/accent color por padrão)
    local markerColor = options.markerColor or { r = 201, g = 161, b = 90, a = 80 }

    activeZones[name] = {
        name = name,
        coords = coords,
        radius = radius,
        onEnter = options.onEnter,
        onExit = options.onExit,
        inside = options.inside,
        onKeyPress = options.onKeyPress,
        
        -- Configurações visuais e de prompts
        drawMarker = options.drawMarker or false,
        markerType = options.markerType or 1, -- 1 = cilindro vertical padrão
        markerColor = markerColor,
        showPrompt = options.showPrompt or false,
        promptText = options.promptText or "Interagir",
        promptKey = options.promptKey or 0xE30CD707, -- default 'E'
        promptHoldDuration = options.promptHoldDuration or 0
    }
    return name
end

-- Remove uma zona
function fdb.zones.Remove(name)
    if activeZones[name] then
        if insideZones[name] then
            if activeZones[name].promptHandle then
                PromptDelete(activeZones[name].promptHandle)
            end
            if activeZones[name].onExit then
                activeZones[name].onExit()
            end
            insideZones[name] = nil
        end
        activeZones[name] = nil
    end
end

-- Thread de checagem de distância
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        for name, zone in pairs(activeZones) do
            local zoneCoords = vector3(zone.coords.x, zone.coords.y, zone.coords.z)
            local dist = #(playerCoords - zoneCoords)

            -- Se estiver perto de alguma zona, diminui o tempo do loop
            if dist < zone.radius + 15.0 then
                sleep = 200

                -- Desenhar marcação visual 3D no chão se ativado
                if zone.drawMarker then
                    sleep = 0 -- Requer renderização a cada frame para evitar piscamento
                    DrawMarker(
                        zone.markerType,
                        zone.coords.x, zone.coords.y, zone.coords.z - 0.95,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        zone.radius * 2.0, zone.radius * 2.0, 1.0,
                        zone.markerColor.r, zone.markerColor.g, zone.markerColor.b, zone.markerColor.a,
                        false, false, 2, false, nil, nil, false
                    )
                end
            end

            if dist <= zone.radius then
                if not insideZones[name] then
                    insideZones[name] = true
                    
                    -- Cria e exibe o prompt nativo ao entrar na área
                    if zone.showPrompt then
                        zone.promptHandle = createPrompt(zone.promptText, zone.promptKey, zone.promptHoldDuration)
                    end

                    if zone.onEnter then
                        zone.onEnter()
                    end
                    TriggerEvent('fdb-libs:zones:onEnter', name)
                end

                -- Checagem de pressionamento de tecla do prompt ativo
                if zone.promptHandle then
                    local completed = false
                    if zone.promptHoldDuration and zone.promptHoldDuration > 0 then
                        completed = PromptHasHoldModeCompleted(zone.promptHandle)
                    else
                        completed = PromptHasStandardModeCompleted(zone.promptHandle)
                    end

                    if completed then
                        if zone.onKeyPress then
                            zone.onKeyPress()
                        end
                        TriggerEvent('fdb-libs:zones:onKeyPress', name)
                    end
                end

                if zone.inside then
                    zone.inside()
                end
            else
                if insideZones[name] then
                    insideZones[name] = nil
                    
                    -- Exclui o prompt ao sair da área
                    if zone.promptHandle then
                        PromptDelete(zone.promptHandle)
                        zone.promptHandle = nil
                    end

                    if zone.onExit then
                        zone.onExit()
                    end
                    TriggerEvent('fdb-libs:zones:onExit', name)
                end
            end
        end

        Wait(sleep)
    end
end)

-- Limpar zonas ao parar o resource
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for name, zone in pairs(activeZones) do
            if insideZones[name] then
                if zone.promptHandle then
                    PromptDelete(zone.promptHandle)
                end
                if zone.onExit then
                    zone.onExit()
                end
            end
        end
        activeZones = {}
        insideZones = {}
    end
end)

-- Exportações para outros resources
exports('CreateZone', fdb.zones.Create)
exports('RemoveZone', fdb.zones.Remove)
