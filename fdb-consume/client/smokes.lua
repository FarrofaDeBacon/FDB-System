-- client/smokes.lua
-- credits: HerosTicWorld (https://github.com/HerosTicWorld/heros_tobacco)
-- adapted for fdb-consume

function FPrompt(text, button, hold)
    Citizen.CreateThread(function()
        proppromptdisplayed = false
        PropPrompt = nil
        local buttonhash = button
        local holdbutton = hold or false
        PropPrompt = PromptRegisterBegin()
        PromptSetControlAction(PropPrompt, buttonhash)
        local str = CreateVarString(10, 'LITERAL_STRING', text)
        PromptSetText(PropPrompt, str)
        PromptSetEnabled(PropPrompt, false)
        PromptSetVisible(PropPrompt, false)
        PromptSetHoldMode(PropPrompt, holdbutton)
        PromptRegisterEnd(PropPrompt)
    end)
end

function LMPrompt(text, button, hold)
    Citizen.CreateThread(function()
        UsePrompt = nil
        local buttonhash = button
        local holdbutton = hold or false
        UsePrompt = PromptRegisterBegin()
        PromptSetControlAction(UsePrompt, buttonhash)
        local str = CreateVarString(10, 'LITERAL_STRING', text)
        PromptSetText(UsePrompt, str)
        PromptSetEnabled(UsePrompt, false)
        PromptSetVisible(UsePrompt, false)
        PromptSetHoldMode(UsePrompt, holdbutton)
        PromptRegisterEnd(UsePrompt)
    end)
end

function EPrompt(text, button, hold)
    Citizen.CreateThread(function()
        ChangeStance = nil
        local buttonhash = button
        local holdbutton = hold or false
        ChangeStance = PromptRegisterBegin()
        PromptSetControlAction(ChangeStance, buttonhash)
        local str = CreateVarString(10, 'LITERAL_STRING', text)
        PromptSetText(ChangeStance, str)
        PromptSetEnabled(ChangeStance, false)
        PromptSetVisible(ChangeStance, false)
        PromptSetHoldMode(ChangeStance, holdbutton)
        PromptRegisterEnd(ChangeStance)
    end)
end

local function disablePrompt(handle)
    if handle ~= nil then
        PromptSetEnabled(handle, false)
        PromptSetVisible(handle, false)
    end
end

local function stopSmokingInteractions()
    disablePrompt(PropPrompt)
    disablePrompt(UsePrompt)
    disablePrompt(ChangeStance)
    proppromptdisplayed = false

    local ped = PlayerPedId()
    if ped ~= 0 and DoesEntityExist(ped) then
        ClearPedSecondaryTask(ped)
        ClearPedTasks(ped)
    end
end

AddEventHandler('fdb-consume:client:stopAllFx', function()
    stopSmokingInteractions()
end)

function Anim(actor, dict, body, duration, flags, introtiming, exittiming)
    Citizen.CreateThread(function()
        RequestAnimDict(dict)
        local dur = duration or -1
        local flag = flags or 1
        local intro = tonumber(introtiming) or 1.0
        local exit = tonumber(exittiming) or 1.0
        timeout = 5
        while (not HasAnimDictLoaded(dict) and timeout > 0) do
            timeout = timeout - 1
            if timeout == 0 then
                print("Animation Failed to Load")
            end
            Citizen.Wait(300)
        end
        TaskPlayAnim(actor, dict, body, intro, exit, dur, flag --[[1 for repeat--]], 1, false, false, false, 0, true)
    end)
end

function StopAnim(dict, body)
    Citizen.CreateThread(function()
        StopAnimTask(PlayerPedId(), dict, body, 1.0)
    end)
end

--Cigarette
RegisterNetEvent('fdb-consume:prop:cigaret')
AddEventHandler('fdb-consume:prop:cigaret', function(propModel, maxUses, dict, name, itemName)
    FPrompt(Config.Drop, Config.Prompts.DropKey, false)
    LMPrompt(Config.Smoke, Config.Prompts.SmokeKey, false)
    EPrompt(Config.Change, Config.Prompts.ChangeKey, false)
    ExecuteCommand('close')
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    local male = IsPedMale(ped)
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    
    local hash = GetHashKey(propModel or 'P_CIGARETTE01X')
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 50 do 
            Wait(10)
            timeout = timeout + 1
        end
    end
    
    -- Configuração de Offsets (Com defaults do cigarro original)
    local offsets = {
        bone = "SKEL_R_Finger13",
        mouth_start = { x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 },
        hand_enter = { x = 0.03, y = -0.01, z = 0.0, rx = 0.0, ry = 90.0, rz = 0.0 },
        mouth_puff = { x = -0.017, y = 0.1, z = -0.01, rx = 0.0, ry = 90.0, rz = -90.0 },
        hand_idle = { x = 0.017, y = -0.01, z = -0.01, rx = 0.0, ry = 120.0, rz = 10.0 },
        female_hand_idle = { x = 0.01, y = 0.0, z = 0.01, rx = 0.0, ry = -160.0, rz = -130.0 }
    }
    
    if itemName and Config.Items[itemName] and Config.Items[itemName].offsets then
        local customOffsets = Config.Items[itemName].offsets
        if customOffsets.bone then offsets.bone = customOffsets.bone end
        if customOffsets.mouth_start then offsets.mouth_start = customOffsets.mouth_start end
        if customOffsets.hand_enter then offsets.hand_enter = customOffsets.hand_enter end
        if customOffsets.mouth_puff then offsets.mouth_puff = customOffsets.mouth_puff end
        if customOffsets.hand_idle then offsets.hand_idle = customOffsets.hand_idle end
        if customOffsets.female_hand_idle then offsets.female_hand_idle = customOffsets.female_hand_idle end
    end
    
    local mouth = GetEntityBoneIndexByName(ped, "skel_head")
    local righthand = GetEntityBoneIndexByName(ped, offsets.bone)
    
    local puffsTaken = 0
    maxUses = maxUses or 10 -- Fallback para charutos
    
    local cigaret = 0
    
    if male then
        Anim(ped, "amb_rest@world_human_smoking@male_c@stand_enter", "enter_back_rf", 5400, 0)
        Wait(1000)
        
        cigaret = CreateObject(hash, x, y, z + 0.2, true, true, true)
        AttachEntityToEntity(cigaret, ped, righthand, offsets.hand_enter.x, offsets.hand_enter.y, offsets.hand_enter.z, offsets.hand_enter.rx, offsets.hand_enter.ry, offsets.hand_enter.rz, true, true, false, true, 1, true)
        Wait(1000)
        AttachEntityToEntity(cigaret, ped, mouth, offsets.mouth_puff.x, offsets.mouth_puff.y, offsets.mouth_puff.z, offsets.mouth_puff.rx, offsets.mouth_puff.ry, offsets.mouth_puff.rz, true, true, false, true, 1, true)
        Wait(3000)
        AttachEntityToEntity(cigaret, ped, righthand, offsets.hand_idle.x, offsets.hand_idle.y, offsets.hand_idle.z, offsets.hand_idle.rx, offsets.hand_idle.ry, offsets.hand_idle.rz, true, true, false, true, 1, true)
        
        Wait(1000)
        Anim(ped, "amb_rest@world_human_smoking@male_c@base", "base", -1, 30)
        RemoveAnimDict("amb_rest@world_human_smoking@male_c@stand_enter")
        Wait(1000)
    else --if female
        cigaret = CreateObject(hash, x, y, z + 0.2, true, true, true)
        AttachEntityToEntity(cigaret, ped, mouth, offsets.mouth_start.x, offsets.mouth_start.y, offsets.mouth_start.z, offsets.mouth_start.rx, offsets.mouth_start.ry, offsets.mouth_start.rz, true, true, false, true, 1, true)
        Anim(ped, "amb_rest@world_human_smoking@female_c@base", "base", -1, 30)
        Wait(1000)
        
        AttachEntityToEntity(cigaret, ped, righthand, offsets.female_hand_idle.x, offsets.female_hand_idle.y, offsets.female_hand_idle.z, offsets.female_hand_idle.rx, offsets.female_hand_idle.ry, offsets.female_hand_idle.rz, true, true, false, true, 1, true)
        Wait(2500)
    end

    local stance = "c"

    if proppromptdisplayed == false then
        PromptSetEnabled(PropPrompt, true)
        PromptSetVisible(PropPrompt, true)
        PromptSetEnabled(UsePrompt, true)
        PromptSetVisible(UsePrompt, true)
        PromptSetEnabled(ChangeStance, true)
        PromptSetVisible(ChangeStance, true)
        proppromptdisplayed = true
    end

    if male then
        while IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@male_c@base", "base", 3)
            or IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@nervous_stressed@male_b@base", "base", 3)
            or IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@male_d@base", "base", 3)
            or IsEntityPlayingAnim(ped, "amb_wander@code_human_smoking_wander@male_a@base", "base", 3) do
            Wait(5)
            if IsControlJustReleased(0, Config.Prompts.DropKey) then
                PromptSetEnabled(PropPrompt, false)
                PromptSetVisible(PropPrompt, false)
                PromptSetEnabled(UsePrompt, false)
                PromptSetVisible(UsePrompt, false)
                PromptSetEnabled(ChangeStance, false)
                PromptSetVisible(ChangeStance, false)
                proppromptdisplayed = false

                ClearPedSecondaryTask(ped)
                Anim(ped, "amb_rest@world_human_smoking@male_a@stand_exit", "exit_back", -1, 1)
                Wait(2800)
                DetachEntity(cigaret, true, true)
                SetEntityVelocity(cigaret, 0.0, 0.0, -1.0)
                Wait(1500)
                ClearPedSecondaryTask(ped)
                ClearPedTasks(ped)
                Wait(10)
            end
            if IsControlJustReleased(0, Config.Prompts.ChangeKey) then
                if stance == "c" then
                    Anim(ped, "amb_rest@world_human_smoking@nervous_stressed@male_b@base", "base", -1, 30)
                    Wait(1000)
                    while not IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@nervous_stressed@male_b@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "b"
                elseif stance == "b" then
                    Anim(ped, "amb_rest@world_human_smoking@male_d@base", "base", -1, 30)
                    Wait(1000)
                    while not IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@male_d@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "d"
                elseif stance == "d" then
                    Anim(ped, "amb_rest@world_human_smoking@male_d@trans", "d_trans_a", -1, 30)
                    Wait(4000)
                    Anim(ped, "amb_wander@code_human_smoking_wander@male_a@base", "base", -1, 30, 0)
                    while not IsEntityPlayingAnim(ped, "amb_wander@code_human_smoking_wander@male_a@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "a"
                else --stance=="a"
                    Anim(ped, "amb_rest@world_human_smoking@male_a@trans", "a_trans_c", -1, 30)
                    Wait(4233)
                    Anim(ped, "amb_rest@world_human_smoking@male_c@base", "base", -1, 30, 0)
                    while not IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@male_c@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "c"
                end
            end

            if stance == "c" then
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_rest@world_human_smoking@male_c@idle_a", "idle_a", -1, 30, 0)
                    Wait(8500)
                    Anim(ped, "amb_rest@world_human_smoking@male_c@base", "base", -1, 30, 0)
                    Wait(100)
                end
            elseif stance == "b" then
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_rest@world_human_smoking@nervous_stressed@male_b@idle_a", "idle_a", -1, 30, 0)
                    Wait(3199)
                    Anim(ped, "amb_rest@world_human_smoking@nervous_stressed@male_b@base", "base", -1, 30, 0)
                    Wait(100)
                end
            elseif stance == "d" then
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_rest@world_human_smoking@male_d@idle_a", "idle_a", -1, 30, 0)
                    Wait(6266)
                    Anim(ped, "amb_rest@world_human_smoking@male_d@base", "base", -1, 30, 0)
                    Wait(100)
                end
            else --stance=="a"
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_wander@code_human_smoking_wander@male_a@idle_a", "idle_b", -1, 30, 0)
                    Wait(4466)
                    Anim(ped, "amb_wander@code_human_smoking_wander@male_a@base", "base", -1, 30, 0)
                    Wait(100)
                end
            end
            
            -- Se atingiu o limite de tragos, joga fora o charuto
            if puffsTaken >= maxUses then
                PromptSetEnabled(PropPrompt, false)
                PromptSetVisible(PropPrompt, false)
                PromptSetEnabled(UsePrompt, false)
                PromptSetVisible(UsePrompt, false)
                PromptSetEnabled(ChangeStance, false)
                PromptSetVisible(ChangeStance, false)
                proppromptdisplayed = false

                ClearPedSecondaryTask(ped)
                Anim(ped, "amb_rest@world_human_smoking@male_a@stand_exit", "exit_back", -1, 1)
                Wait(2800)
                DetachEntity(cigaret, true, true)
                SetEntityVelocity(cigaret, 0.0, 0.0, -1.0)
                Wait(1500)
                ClearPedSecondaryTask(ped)
                ClearPedTasks(ped)
                Wait(10)
            end
        end
    else --if female
        while IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@female_c@base", "base", 3)
            or IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@female_b@base", "base", 3)
            or IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@female_a@base", "base", 3) do
            Wait(5)
            if IsControlJustReleased(0, Config.Prompts.DropKey) then
                PromptSetEnabled(PropPrompt, false)
                PromptSetVisible(PropPrompt, false)
                PromptSetEnabled(UsePrompt, false)
                PromptSetVisible(UsePrompt, false)
                PromptSetEnabled(ChangeStance, false)
                PromptSetVisible(ChangeStance, false)
                proppromptdisplayed = false

                ClearPedSecondaryTask(ped)
                Anim(ped, "amb_rest@world_human_smoking@female_b@trans", "b_trans_fire_stand_a", -1, 1)
                Wait(3800)
                DetachEntity(cigaret, true, true)
                Wait(800)
                ClearPedSecondaryTask(ped)
                ClearPedTasks(ped)
                Wait(10)
            end
            if IsControlJustReleased(0, Config.Prompts.ChangeKey) then
                if stance == "c" then
                    Anim(ped, "amb_rest@world_human_smoking@female_b@base", "base", -1, 30)
                    Wait(1000)
                    while not IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@female_b@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "b"
                elseif stance == "b" then
                    Anim(ped, "amb_rest@world_human_smoking@female_b@trans", "b_trans_a", -1, 30)
                    Wait(5733)
                    Anim(ped, "amb_rest@world_human_smoking@female_a@base", "base", -1, 30, 0)
                    while not IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@female_a@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "a"
                else --stance=="a"
                    Anim(ped, "amb_rest@world_human_smoking@female_c@base", "base", -1, 30)
                    Wait(1000)
                    while not IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@female_c@base", "base", 3) do
                        Wait(100)
                    end
                    stance = "c"
                end
            end

            if stance == "c" then
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_rest@world_human_smoking@female_c@idle_b", "idle_f", -1, 30, 0)
                    Wait(8133)
                    Anim(ped, "amb_rest@world_human_smoking@female_c@base", "base", -1, 30, 0)
                    Wait(100)
                end
            elseif stance == "b" then
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_rest@world_human_smoking@female_b@idle_a", "idle_b", -1, 30, 0)
                    Wait(4266)
                    Anim(ped, "amb_rest@world_human_smoking@female_b@base", "base", -1, 30, 0)
                    Wait(100)
                end
            else --stance=="a"
                if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
                    puffsTaken = puffsTaken + 1
                    Anim(ped, "amb_rest@world_human_smoking@female_a@idle_a", "idle_b", -1, 30, 0)
                    Wait(6100)
                    Anim(ped, "amb_rest@world_human_smoking@female_a@base", "base", -1, 30, 0)
                    Wait(100)
                end
            end
            
            -- Se atingiu o limite de tragos, joga fora o charuto
            if puffsTaken >= maxUses then
                PromptSetEnabled(PropPrompt, false)
                PromptSetVisible(PropPrompt, false)
                PromptSetEnabled(UsePrompt, false)
                PromptSetVisible(UsePrompt, false)
                PromptSetEnabled(ChangeStance, false)
                PromptSetVisible(ChangeStance, false)
                proppromptdisplayed = false

                ClearPedSecondaryTask(ped)
                Anim(ped, "amb_rest@world_human_smoking@female_b@trans", "b_trans_fire_stand_a", -1, 1)
                Wait(3800)
                DetachEntity(cigaret, true, true)
                Wait(800)
                ClearPedSecondaryTask(ped)
                ClearPedTasks(ped)
                Wait(10)
            end
        end
    end

    PromptSetEnabled(PropPrompt, false)
    PromptSetVisible(PropPrompt, false)
    PromptSetEnabled(UsePrompt, false)
    PromptSetVisible(UsePrompt, false)
    PromptSetEnabled(ChangeStance, false)
    PromptSetVisible(ChangeStance, false)
    proppromptdisplayed = false

    DetachEntity(cigaret, true, true)
    ClearPedSecondaryTask(ped)
    RemoveAnimDict("amb_wander@code_human_smoking_wander@male_a@base")
    RemoveAnimDict("amb_rest@world_human_smoking@male_a@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@nervous_stressed@male_b@base")
    RemoveAnimDict("amb_rest@world_human_smoking@nervous_stressed@male_b@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@nervous_stressed@male_b@idle_g")
    RemoveAnimDict("amb_rest@world_human_smoking@male_c@base")
    RemoveAnimDict("amb_rest@world_human_smoking@male_c@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@male_d@base")
    RemoveAnimDict("amb_rest@world_human_smoking@male_d@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@male_d@idle_c")
    RemoveAnimDict("amb_rest@world_human_smoking@male_a@trans")
    RemoveAnimDict("amb_rest@world_human_smoking@male_c@trans")
    RemoveAnimDict("amb_rest@world_human_smoking@male_d@trans")
    RemoveAnimDict("amb_rest@world_human_smoking@female_a@base")
    RemoveAnimDict("amb_rest@world_human_smoking@female_a@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@female_a@idle_b")
    RemoveAnimDict("amb_rest@world_human_smoking@female_b@base")
    RemoveAnimDict("amb_rest@world_human_smoking@female_b@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@female_b@idle_b")
    RemoveAnimDict("amb_rest@world_human_smoking@female_c@base")
    RemoveAnimDict("amb_rest@world_human_smoking@female_c@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@female_c@idle_b")
    RemoveAnimDict("amb_rest@world_human_smoking@female_b@trans")
    Wait(100)
    ClearPedTasks(ped)
end)


RegisterNetEvent('fdb-consume:prop:pipe_smoker')
AddEventHandler('fdb-consume:prop:pipe_smoker', function()
    FPrompt(Config.Drop, Config.Prompts.DropKey, false)
    LMPrompt(Config.Smoke, Config.Prompts.SmokeKey, false)
    EPrompt(Config.Change, Config.Prompts.ChangeKey, false)
    ExecuteCommand('close')
    local ped = PlayerPedId()
    local male = IsPedMale(ped)
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local pipe= CreateObject(GetHashKey('P_PIPE01X'), x, y, z + 0.2, true, true, true)
    local righthand = GetEntityBoneIndexByName(ped, "SKEL_R_Finger13")
    AttachEntityToEntity(pipe, ped, righthand, 0.005, -0.045, 0.0, -170.0, 10.0, -15.0, true, true, false, true, 1, true)
    Anim(ped,"amb_wander@code_human_smoking_wander@male_b@trans","nopipe_trans_pipe",-1,30)
    Wait(9000)
    Anim(ped,"amb_rest@world_human_smoking@male_b@base","base",-1,31)

    while not IsEntityPlayingAnim(ped,"amb_rest@world_human_smoking@male_b@base","base", 3) do
        Wait(100)
    end


    if proppromptdisplayed == false then
        PromptSetEnabled(PropPrompt, true)
        PromptSetVisible(PropPrompt, true)
        PromptSetEnabled(UsePrompt, true)
        PromptSetVisible(UsePrompt, true)
        PromptSetEnabled(ChangeStance, true)
        PromptSetVisible(ChangeStance, true)
        proppromptdisplayed = true
	end

    while IsEntityPlayingAnim(ped, "amb_rest@world_human_smoking@male_b@base","base", 3) do

        Wait(2)
		if IsControlJustReleased(0, Config.Prompts.DropKey) then
            PromptSetEnabled(PropPrompt, false)
            PromptSetVisible(PropPrompt, false)
            PromptSetEnabled(UsePrompt, false)
            PromptSetVisible(UsePrompt, false)
            PromptSetEnabled(ChangeStance, false)
            PromptSetVisible(ChangeStance, false)
            proppromptdisplayed = false

            Anim(ped, "amb_wander@code_human_smoking_wander@male_b@trans", "pipe_trans_nopipe", -1, 30)
            Wait(6066)
            DeleteEntity(pipe)
            ClearPedSecondaryTask(ped)
            ClearPedTasks(ped)
            Wait(10)
		end
        
        if IsControlJustReleased(0, Config.Prompts.ChangeKey) then
            Anim(ped, "amb_rest@world_human_smoking@pipe@proper@male_d@wip_base", "wip_base", -1, 30)
            Wait(5000)
            Anim(ped, "amb_rest@world_human_smoking@male_b@base","base", -1, 31)
            Wait(100)
        end

        if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
            if healing then
                local amount = 10
                if lesshealing then
                    amount = 5
                end
                if GetAttributeCoreValue(ped, 0) + amount <= 100 then
                    local addhp = GetAttributeCoreValue(ped, 0) + amount
                    Citizen.InvokeNative(0xC6258F41D86676E0, ped, 0, addhp)
                else
                    Citizen.InvokeNative(0xC6258F41D86676E0, ped, 0, 100)
                end
            end
            Anim(ped, "amb_rest@world_human_smoking@male_b@idle_a","idle_a", -1, 30, 0)
            Wait(22600)
            Anim(ped, "amb_rest@world_human_smoking@male_b@base","base", -1, 31, 0)
            Wait(100)

        --[[
                        Anim(ped, "amb_rest@world_human_smoking@male_b@idle_b","idle_d", -1, 30, 0)
            Wait(15599)
            Anim(ped, "amb_rest@world_human_smoking@male_b@base","base", -1, 31, 0)
            Wait(100)


            else
            Anim(ped, "amb_rest@world_human_smoking@male_b@idle_a","idle_a", -1, 30, 0)
            Wait(22600)
            Anim(ped, "amb_rest@world_human_smoking@male_b@base","base", -1, 31, 0)
            Wait(100) ]]
        end
    end

    PromptSetEnabled(PropPrompt, false)
    PromptSetVisible(PropPrompt, false)
    PromptSetEnabled(UsePrompt, false)
    PromptSetVisible(UsePrompt, false)
    PromptSetEnabled(ChangeStance, false)
    PromptSetVisible(ChangeStance, false)
    proppromptdisplayed = false

    DetachEntity(pipe, true, true)
    ClearPedSecondaryTask(ped)
    RemoveAnimDict("amb_wander@code_human_smoking_wander@male_b@trans")
    RemoveAnimDict("amb_rest@world_human_smoking@male_b@base")
    RemoveAnimDict("amb_rest@world_human_smoking@pipe@proper@male_d@wip_base")
    RemoveAnimDict("amb_rest@world_human_smoking@male_b@idle_a")
    RemoveAnimDict("amb_rest@world_human_smoking@male_b@idle_b")
    Wait(100)
    ClearPedTasks(ped)
    pipeon = false
end)

RegisterNetEvent('fdb-consume:prop:chewingtobacco')
AddEventHandler('fdb-consume:prop:chewingtobacco', function()
    --Citizen.InvokeNative( 0xF6A7C08DF2E28B28, PlayerPedId(), 0, 800.0, false )
    --PlaySoundFrontend("Core_Full", "Consumption_Sounds", true, 0)
    FPrompt(Config.Drop, Config.Prompts.DropKey, false)
    LMPrompt(Config.Smoke, Config.Prompts.SmokeKey, false)
    EPrompt(Config.Change, Config.Prompts.ChangeKey, false)
    ExecuteCommand('close')
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local righthand = GetEntityBoneIndexByName(ped, "SKEL_R_Finger13")

    local basedict = "amb_misc@world_human_chew_tobacco@male_a@base"
    local basedictB = "amb_misc@world_human_chew_tobacco@male_b@base"
    local MaleA =
    {
        [1] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_a",['anim'] = "idle_a" },
        [2] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_a",['anim'] = "idle_b" },
        [3] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_a",['anim'] = "idle_c" },
        [4] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_b",['anim'] = "idle_d" },
        [5] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_b",['anim'] = "idle_e" },
        [6] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_b",['anim'] = "idle_f" },
        [7] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_c",['anim'] = "idle_g" },
        [8] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_c",['anim'] = "idle_h" },
        [9] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_c",['anim'] = "idle_i" },
        [7] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_d",['anim'] = "idle_j" },
        [8] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_d",['anim'] = "idle_k" },
        [9] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_a@idle_d",['anim'] = "idle_l" }
    }
    local MaleB =
    {
        [1] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_a",['anim'] = "idle_a" },
        [2] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_a",['anim'] = "idle_b" },
        [3] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_a",['anim'] = "idle_c" },
        [4] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_b",['anim'] = "idle_d" },
        [5] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_b",['anim'] = "idle_e" },
        [6] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_b",['anim'] = "idle_f" },
        [7] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_c",['anim'] = "idle_g" },
        [8] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_c",['anim'] = "idle_h" },
        [9] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_c",['anim'] = "idle_i" },
        [7] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_d",['anim'] = "idle_j" },
        [8] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_d",['anim'] = "idle_k" },
        [9] = { ['dict'] = "amb_misc@world_human_chew_tobacco@male_b@idle_d",['anim'] = "idle_l" }
    }
    local stance = "MaleA"

    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_a")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_b")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_c")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_d")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_a")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_b")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_c")
    RequestAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_d")

    Anim(ped, "amb_misc@world_human_chew_tobacco@male_a@stand_enter", "enter_back", -1, 30)
    Wait(2500)
    local chewingtobacco = CreateObject(GetHashKey('S_TOBACCOTIN01X'), x, y, z + 0.2, true, true, true)
    Wait(10)
    AttachEntityToEntity(chewingtobacco, ped, righthand, 0.0, -0.05, 0.02, 30.0, 180.0, 0.0, true, true, false, true, 1,
        true)
    Wait(6000)
    DeleteEntity(chewingtobacco)
    Wait(3500)
    Anim(ped, basedict, "base", -1, 31, 0)

    while not IsEntityPlayingAnim(ped, basedict, "base", 3) do
        Wait(100)
    end

    if proppromptdisplayed == false then
        PromptSetEnabled(PropPrompt, true)
        PromptSetVisible(PropPrompt, true)
        PromptSetEnabled(UsePrompt, true)
        PromptSetVisible(UsePrompt, true)
        PromptSetEnabled(ChangeStance, true)
        PromptSetVisible(ChangeStance, true)
        proppromptdisplayed = true
    end

    while IsEntityPlayingAnim(ped, basedict, "base", 3) or IsEntityPlayingAnim(ped, basedictB, "base", 3) do
        Wait(5)
        if IsControlJustReleased(0, Config.Prompts.DropKey) then
            PromptSetEnabled(PropPrompt, false)
            PromptSetVisible(PropPrompt, false)
            PromptSetEnabled(UsePrompt, false)
            PromptSetVisible(UsePrompt, false)
            PromptSetEnabled(ChangeStance, false)
            PromptSetVisible(ChangeStance, false)
            proppromptdisplayed = false

            Anim(ped, "amb_misc@world_human_chew_tobacco@male_b@idle_b", "idle_d", 5500, 30)
            Wait(5500)
            ClearPedSecondaryTask(ped)
            ClearPedTasks(ped)
            Wait(10)
        end

        if IsDisabledControlJustReleased(0, Config.Prompts.SmokeKey) then
            local random = math.random(1, 9)
            if stance == "MaleA" then
                randomdict = MaleA[random]['dict']
                randomanim = MaleA[random]['anim']
            else
                randomdict = MaleB[random]['dict']
                randomanim = MaleB[random]['anim']
            end
            animduration = GetAnimDuration(randomdict, randomanim) * 1000
            Wait(100)
            PromptSetEnabled(PropPrompt, false)
            PromptSetVisible(PropPrompt, false)
            PromptSetEnabled(UsePrompt, false)
            PromptSetVisible(UsePrompt, false)
            PromptSetEnabled(ChangeStance, false)
            PromptSetVisible(ChangeStance, false)
            Anim(ped, randomdict, randomanim, -1, 30, 0)
            Wait(animduration)
            if stance == "MaleA" then
                Anim(ped, basedict, "base", -1, 31, 0)
            else
                Anim(ped, basedictB, "base", -1, 31, 0)
            end
            PromptSetEnabled(PropPrompt, true)
            PromptSetVisible(PropPrompt, true)
            PromptSetEnabled(UsePrompt, true)
            PromptSetVisible(UsePrompt, true)
            PromptSetEnabled(ChangeStance, true)
            PromptSetVisible(ChangeStance, true)
            Wait(100)
        end

        if IsControlJustReleased(0, Config.Prompts.ChangeKey) then
            if stance == "MaleA" then
                Anim(ped, "amb_misc@world_human_chew_tobacco@male_a@trans", "a_trans_b", -1, 30)
                PromptSetEnabled(PropPrompt, false)
                PromptSetVisible(PropPrompt, false)
                PromptSetEnabled(UsePrompt, false)
                PromptSetVisible(UsePrompt, false)
                PromptSetEnabled(ChangeStance, false)
                PromptSetVisible(ChangeStance, false)
                Wait(7333)
                Anim(ped, basedictB, "base", -1, 30, 0)
                while not IsEntityPlayingAnim(ped, basedictB, "base", 3) do
                    Wait(100)
                end
                PromptSetEnabled(PropPrompt, true)
                PromptSetVisible(PropPrompt, true)
                PromptSetEnabled(UsePrompt, true)
                PromptSetVisible(UsePrompt, true)
                PromptSetEnabled(ChangeStance, true)
                PromptSetVisible(ChangeStance, true)
                stance = "MaleB"
            else
                Anim(ped, "amb_misc@world_human_chew_tobacco@male_b@trans", "b_trans_a", -1, 30)
                PromptSetEnabled(PropPrompt, false)
                PromptSetVisible(PropPrompt, false)
                PromptSetEnabled(UsePrompt, false)
                PromptSetVisible(UsePrompt, false)
                PromptSetEnabled(ChangeStance, false)
                PromptSetVisible(ChangeStance, false)
                Wait(5833)
                Anim(ped, basedict, "base", -1, 30, 0)
                while not IsEntityPlayingAnim(ped, basedict, "base", 3) do
                    Wait(100)
                end
                PromptSetEnabled(PropPrompt, true)
                PromptSetVisible(PropPrompt, true)
                PromptSetEnabled(UsePrompt, true)
                PromptSetVisible(UsePrompt, true)
                PromptSetEnabled(ChangeStance, true)
                PromptSetVisible(ChangeStance, true)
                stance = "MaleA"
            end
        end
    end

    PromptSetEnabled(PropPrompt, false)
    PromptSetVisible(PropPrompt, false)
    PromptSetEnabled(UsePrompt, false)
    PromptSetVisible(UsePrompt, false)
    PromptSetEnabled(ChangeStance, false)
    PromptSetVisible(ChangeStance, false)
    proppromptdisplayed = false

    DetachEntity(chewingtobacco, true, true)
    ClearPedSecondaryTask(ped)
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_a@stand_enter")
    RemoveAnimDict(base)
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_a")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_b")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_c")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_a@idle_d")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_a")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_b")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_c")
    RemoveAnimDict("amb_misc@world_human_chew_tobacco@male_b@idle_d")
    ClearPedTasks(ped)
end)

RegisterNetEvent('fdb-consume:client:Chew', function(propModel, animDict, animName, itemName)
    local ped = PlayerPedId()
    
    local hash = GetHashKey(propModel)
    local prop = nil
    if IsModelValid(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(10) end
        
        local coords = GetEntityCoords(ped)
        prop = CreateObject(hash, coords.x, coords.y, coords.z, true, true, false)
        local boneName = 'SKEL_L_HAND'
        local x, y, z = 0.0, 0.0, 0.0
        local rx, ry, rz = 0.0, 0.0, 0.0
        
        if itemName and Config.Items[itemName] and Config.Items[itemName].offsets then
            local off = Config.Items[itemName].offsets
            if off.bone then boneName = off.bone end
            if off.hand_idle then
                x, y, z = off.hand_idle.x or x, off.hand_idle.y or y, off.hand_idle.z or z
                rx, ry, rz = off.hand_idle.rx or rx, off.hand_idle.ry or ry, off.hand_idle.rz or rz
            end
        end
        
        local boneIndex = GetEntityBoneIndexByName(ped, boneName)
        AttachEntityToEntity(prop, ped, boneIndex, x, y, z, rx, ry, rz, true, true, false, true, 1, true)
    else
        print("fdb-consume ERRO: Prop invalido: " .. tostring(propModel))
    end
    
    local dict = animDict or "mech_inventory@eating@multi_bite@sphere_d8-2_sandwich"
    local name = animName or "quick_left_hand"
    RequestAnimDict(dict)
    local t1 = 0
    while not HasAnimDictLoaded(dict) and t1 < 100 do Wait(10); t1 = t1 + 1 end
    
    if HasAnimDictLoaded(dict) then
        -- Flag 1 para forçar a tocar (Looping) ou Flag 48
        TaskPlayAnim(ped, dict, name, 8.0, -8.0, 4000, 1, 0.0, false, false, false)
    else
        print("fdb-consume ERRO: Dicionário de animação inicial não encontrado: " .. tostring(dict))
    end
    Wait(4000)
    if prop then DeleteObject(prop) end
    
    -- Mudar para a animação do veado que mastiga, mas usando o nativo FACIAL (para NUNCA bloquear o corpo!)
    local chewDict = "face_creatures@gestures@deer"
    local chewName = "chew_01"
    RequestAnimDict(chewDict)
    local t2 = 0
    while not HasAnimDictLoaded(chewDict) and t2 < 100 do Wait(10); t2 = t2 + 1 end
    
    if HasAnimDictLoaded(chewDict) then
        -- PlayFacialAnim nativo (só afeta o rosto, deixa o corpo 100% livre pra andar)
        Citizen.InvokeNative(0x7A6535691B477C48, ped, chewName, chewDict)
    else
        print("fdb-consume ERRO: Dicionário facial não encontrado: " .. tostring(chewDict))
    end
    
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local isChewing = true
        
        -- Cria o Prompt Nativo do RedM
        local spitPrompt = PromptRegisterBegin()
        PromptSetControlAction(spitPrompt, 0x07CE1E61) -- Botão Esquerdo do Mouse
        PromptSetText(spitPrompt, CreateVarString(10, 'LITERAL_STRING', "Cuspir"))
        PromptSetEnabled(spitPrompt, true)
        PromptSetVisible(spitPrompt, true)
        PromptSetHoldMode(spitPrompt, false)
        PromptRegisterEnd(spitPrompt)
        
        while isChewing do
            Wait(0)
            -- 0x07CE1E61 = Left Mouse Button
            if IsControlJustPressed(0, 0x07CE1E61) or (GetGameTimer() - startTime > 60000) then
                isChewing = false
                
                -- Esconde o prompt nativo
                PromptSetEnabled(spitPrompt, false)
                PromptSetVisible(spitPrompt, false)
                
                local pedId = PlayerPedId()
                
                if not IsPedDeadOrDying(pedId, true) then
                    local spitDict = "amb_misc@world_human_chew_tobacco@male_a@trans"
                    local spitName = "a_trans_b"
                    RequestAnimDict(spitDict)
                    local timeout = 0
                    while not HasAnimDictLoaded(spitDict) and timeout < 50 do Wait(10); timeout = timeout + 1 end
                    
                    if HasAnimDictLoaded(spitDict) then
                        TaskPlayAnim(pedId, spitDict, spitName, 8.0, -8.0, -1, 48, 0.0, false, false, false)
                    end
                end
            end
        end
    end)
end)
