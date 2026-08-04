local FDBCore = exports['fdb-core']:GetCoreObject()

local fliesPtfx = nil
local isIllnessScreenActive = false
local isPoisonScreenActive = false
local isVomiting = false

-- Efeitos Biológicos (Doenças e Mau Cheiro)
CreateThread(function()
    while true do
        Wait(3000)
        local illness = FDB.Survival.illness or 0
        local poison = FDB.Survival.poison or 0
        -- print(string.format("[DEBUG FDB] loop illness rodando | IsLoggedIn: %s | illness: %s | poison: %s", tostring(FDB.IsLoggedIn), tostring(illness), tostring(poison)))
        
        if FDB.IsLoggedIn then
            local ped = PlayerPedId()
            local cleanliness = FDB.Survival.cleanliness or 100
            
            -- ================================
            -- 1. TRILHA DA SUJEIRA (Cleanliness)
            -- ================================
            -- Nível 3 (Imundo < 5): Moscas
            if cleanliness < 20 then
                if not fliesPtfx then
                    local dict = "core"
                    local name = "ent_amb_insect_fly_swarm_shit"
                    
                    if not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(dict)) then -- HasNamedPtfxAssetLoaded
                        Citizen.InvokeNative(0xF2B2353BBC0D4E8F, GetHashKey(dict)) -- RequestNamedPtfxAsset
                        local counter = 0
                        while not Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(dict)) and counter <= 300 do
                            Wait(10)
                            counter = counter + 1
                        end
                    end

                    if Citizen.InvokeNative(0x65BB72F29138F5D6, GetHashKey(dict)) then
                        Citizen.InvokeNative(0xA10DB07FC234DD12, dict) -- UseParticleFxAsset
                        local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_Spine2")
                        -- Criar a partícula local (não-networked) para garantir que podemos apagar
                        fliesPtfx = StartParticleFxLoopedOnEntityBone(name, ped, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, boneIndex, 1.0, false, false, false)
                    end
                end
                
                -- Reação dos NPCs desativada temporariamente pois natives de Flee e Anim estão quebrando a IA (ficam presos)
                -- (O loop dos NPCs ficava aqui)
            else
                if fliesPtfx then
                    StopParticleFxLooped(fliesPtfx, true)
                    RemoveParticleFx(fliesPtfx, true)
                    fliesPtfx = nil
                end
            end
            
            -- ================================
            -- 2. TRILHA DA DOENÇA (Illness)
            -- ================================
            -- Nível 1: Tosse (Frequência escala com a doença)
            if illness >= Config.Biological.SymptomThreshold then
                if math.random(1, 100) <= (10 + (illness / 2)) then
                    local dict = "mech_loco_m@character@arthur@fidgets@sick@normal@unarmed"
                    RequestAnimDict(dict)
                    local t = 0
                    while not HasAnimDictLoaded(dict) and t < 50 do
                        Wait(10)
                        t = t + 1
                    end
                    if HasAnimDictLoaded(dict) then
                        -- Flag 31: Upper body, permite mover, não aborta fácil. Duração 2500ms.
                        TaskPlayAnim(ped, dict, "cough_a", 8.0, -8.0, 2500, 31, 0, false, false, false)
                    end
                end
            end
            
            -- Nível 3: Dreno de HP lento e Tela de Saúde Crítica
            if illness >= Config.Biological.SevereThreshold then
                if not AnimpostfxIsRunning("PlayerHealthPoor") then
                    AnimpostfxPlay("PlayerHealthPoor")
                end
                isIllnessScreenActive = true
                TriggerServerEvent('fdb-survival:server:reportHazardDamage', 'Illness', Config.Biological.IllnessHPDrain)
            else
                if isIllnessScreenActive then
                    AnimpostfxStop("PlayerHealthPoor")
                    isIllnessScreenActive = false
                end
            end
            
            -- ================================
            -- 3. TRILHA DO ENVENENAMENTO (Poison)
            -- ================================
            -- Nível 1: Ondas de Náusea (Efeito Visual)
            if poison >= Config.Biological.SymptomThreshold then
                if not AnimpostfxIsRunning("PlayerDrunk01") then
                    AnimpostfxPlay("PlayerDrunk01")
                end
                isPoisonScreenActive = true
            else
                if isPoisonScreenActive then
                    AnimpostfxStop("PlayerDrunk01")
                    isPoisonScreenActive = false
                end
            end
            
            -- Nível 2: Vômito Físico (Scenario seguro com timeout e cooldown)
            if poison >= Config.Biological.ModerateThreshold and not isVomiting then
                local chance = (poison >= Config.Biological.SevereThreshold) and Config.Biological.VomitChanceSevere or Config.Biological.VomitChanceModerate
                if math.random(1, 100) <= chance then
                    if not LocalPlayer.state.isBathingActive then
                        isVomiting = true
                        TaskStartScenarioInPlace(ped, GetHashKey("WORLD_HUMAN_VOMIT"), -1, true, false, false, false)
                        
                        -- Timeout de segurança: limpa a task e dá um respiro antes do próximo
                        SetTimeout(Config.Biological.VomitDuration, function()
                            ClearPedTasks(ped)
                            SetTimeout(Config.Biological.VomitCooldown, function()
                                isVomiting = false
                            end)
                        end)
                    end
                end
            end
            
            -- Nível 3: Dreno Acelerado de Vida
            if poison >= Config.Biological.SevereThreshold then
                TriggerServerEvent('fdb-survival:server:reportHazardDamage', 'Poison', Config.Biological.PoisonHPDrain)
            end
            
        end
    end
end)

-- Limpeza ao deslogar
RegisterNetEvent('FDBCore:Client:OnPlayerUnload', function()
    if fliesPtfx then
        StopParticleFxLooped(fliesPtfx, true)
        RemoveParticleFx(fliesPtfx, true)
        fliesPtfx = nil
    end
    if isIllnessScreenActive then
        AnimpostfxStop("PlayerHealthPoor")
        isIllnessScreenActive = false
    end
    if isPoisonScreenActive then
        AnimpostfxStop("PlayerDrunk01")
        isPoisonScreenActive = false
    end
end)

-- Limpeza absoluta ao reiniciar o script (evita partículas órfãs eternas)
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if fliesPtfx then
            StopParticleFxLooped(fliesPtfx, true)
            RemoveParticleFx(fliesPtfx, true)
            fliesPtfx = nil
        end
        if isIllnessScreenActive then
            AnimpostfxStop("PlayerHealthPoor")
            isIllnessScreenActive = false
        end
        if isPoisonScreenActive then
            AnimpostfxStop("PlayerDrunk01")
            isPoisonScreenActive = false
        end
    end
end)
