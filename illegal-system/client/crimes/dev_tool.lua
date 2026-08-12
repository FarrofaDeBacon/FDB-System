local devMode = false

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    
    local tZ = cameraRotation.z * 0.0174532924
    local tX = cameraRotation.x * 0.0174532924
    local num = math.abs(math.cos(tX))
    
    local direction = vec3(-math.sin(tZ) * num, math.cos(tZ) * num, math.sin(tX))
    local destination = vec3(cameraCoord.x + direction.x * distance, cameraCoord.y + direction.y * distance, cameraCoord.z + direction.z * distance)
    
    -- REDM Native Raycast
    local shapeTest = StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
    
    return hit, endCoords, entityHit
end

local function PrintCoordinate(label, coords)
    local formatStr = "        %s = vec3(%.2f, %.2f, %.2f),"
    local output = string.format(formatStr, label, coords.x, coords.y, coords.z)
    
    print("\n^2========================================^7")
    print("^3Copiado! Cole isso no seu config.lua:^7")
    print(output)
    print("^2========================================^7\n")
    
    Bridge.Notify("Coordenada salva no F8!", "success")
end

RegisterCommand('robsystem', function()
    devMode = not devMode
    if devMode then
        Bridge.Notify("Modo Dev LIGADO! Olhe pro chão.", "success")
        print("\n^3[ROBSYSTEM] Comandos do Modo Dev:^7")
        print("^5[E]^7 - Salvar Coordenada de Fuga do NPC (Rua)")
        print("^5[G]^7 - Salvar Coordenada da Porta (Burglary)")
        print("^5[H]^7 - Salvar Coordenada da Registradora (Burglary)")
        
        CreateThread(function()
            while devMode do
                Wait(0)
                local hit, endCoords, entityHit = RayCastGamePlayCamera(20.0)
                
                if hit == 1 then
                    local plyCoords = GetEntityCoords(PlayerPedId())
                    -- Linha a laser
                    DrawLine(plyCoords.x, plyCoords.y, plyCoords.z, endCoords.x, endCoords.y, endCoords.z, 255, 0, 0, 255)
                    
                    -- E
                    if IsControlJustPressed(0, 0xCEFD9220) then
                        PrintCoordinate("fleeCoords", endCoords)
                    -- G
                    elseif IsControlJustPressed(0, 0x760A9C6F) then
                        PrintCoordinate("doorCoords", endCoords)
                    -- H
                    elseif IsControlJustPressed(0, 0x24978A28) then
                        PrintCoordinate("registerCoords", endCoords)
                    end
                end
            end
        end)
    else
        Bridge.Notify("Modo Dev DESLIGADO", "error")
    end
end, false)

RegisterCommand('test_grave_exploit', function()
    -- Pega o último token salvo e manda um evento finish imediatamente
    if lastDebugToken then
        TriggerServerEvent('illegal-system:server:finishGraveRobbery', true, 'rare', lastDebugToken)
    else
        print("Precisa rodar /test_minigame primeiro pra gerar um token")
    end
end, false)


