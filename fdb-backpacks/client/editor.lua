-- editor.lua v7 - Bone selector + Controles Spooner
local FDBCore = exports['fdb-core']:GetCoreObject()
local tempBackpack = nil
local isEditing = false

local posX, posY, posZ = 0.0, 0.0, 0.0
local rotX, rotY, rotZ = 0.0, 0.0, 0.0
local currentModel = ""
local spawnedEditorObjects = {}

-- Bones mais usados para mochilas no RDR2
local BONES = {
    { id = 278,   name = "CP_Back (Costas)" },
    { id = 24817, name = "SKEL_Spine3 (Coluna Superior)" },
    { id = 57005, name = "SKEL_Spine_Root (Base Coluna)" },
    { id = 12844, name = "SKEL_Pelvis (Quadril)" },
    { id = 28422, name = "SKEL_L_Shoulder (Ombro Esq)" },
    { id = 22711, name = "SKEL_R_Shoulder (Ombro Dir)" },
    { id = 58271, name = "SKEL_L_Hand (Mao Esq)" },
    { id = 60309, name = "SKEL_R_Hand (Mao Dir)" },
    { id = 14201, name = "SKEL_Head (Cabeca)" },
}
local currentBoneIdx = 1 -- indice atual na lista BONES

-- ==========================================
-- CONTROLES (mesmos que o Spooner usa no RDR2)
-- ==========================================
-- Posição
local CTRL_FORWARD  = `INPUT_MOVE_UP_ONLY`    -- W
local CTRL_BACKWARD = `INPUT_MOVE_DOWN_ONLY`  -- S
local CTRL_LEFT     = `INPUT_MOVE_LEFT_ONLY`  -- A
local CTRL_RIGHT    = `INPUT_MOVE_RIGHT_ONLY` -- D
local CTRL_UP       = `INPUT_JUMP`            -- Espaço (posZ+)
local CTRL_DOWN     = `INPUT_SPRINT`          -- Shift  (posZ-)

-- Rotação (setas - confirmar funcionando)
local CTRL_ROT_FWD  = `INPUT_FRONTEND_UP`    -- Seta Cima  = rotX+
local CTRL_ROT_BWD  = `INPUT_FRONTEND_DOWN`  -- Seta Baixo = rotX-
local CTRL_ROT_L    = `INPUT_FRONTEND_LEFT`  -- Seta Esq   = rotY+
local CTRL_ROT_R    = `INPUT_FRONTEND_RIGHT` -- Seta Dir   = rotY-
local CTRL_YAW_L    = `INPUT_FRONTEND_LB`    -- Q          = rotZ+
local CTRL_YAW_R    = `INPUT_CREATOR_RS`     -- C          = rotZ-

-- Salvar / Cancelar / Trocar Bone
local CTRL_SAVE      = `INPUT_CURSOR_ACCEPT`    -- Enter / Clique esq
local CTRL_CANCEL    = `INPUT_FRONTEND_DELETE`  -- Delete
local CTRL_NEXT_BONE = `INPUT_OPEN_SATCHEL_MENU` -- B (troca bone)

-- ==========================================
-- HELPERS
-- ==========================================
local function CleanupEditorObjects()
    for i = 1, #spawnedEditorObjects do
        local obj = spawnedEditorObjects[i]
        if obj and DoesEntityExist(obj) then
            DeleteEntity(obj)
            SetEntityAsNoLongerNeeded(obj)
        end
    end
    spawnedEditorObjects = {}
    tempBackpack = nil
end

local function DrawTxt(text, x, y)
    SetTextScale(0.35, 0.35)
    SetTextColor(255, 255, 255, 255)
    SetTextCentre(false)
    SetTextDropshadow(1, 0, 0, 0, 200)
    local str = CreateVarString(10, "LITERALSTRING", text)
    DisplayText(str, x, y)
end

local function ForceUnfreeze()
    isEditing = false
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetPlayerControl(PlayerId(), true, 256)
    ClearPedTasksImmediately(ped)
    RenderScriptCams(false, false, 0, true, true)
end

-- ==========================================
-- PROCESSO PRINCIPAL
-- ==========================================
local function StartAdjustmentProcess(modelName)
    CleanupEditorObjects()

    if isEditing then
        isEditing = false
        Wait(300)
    end

    currentModel = modelName

    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    local timeout = 100
    while not HasModelLoaded(modelHash) and timeout > 0 do
        Wait(10)
        timeout = timeout - 1
    end

    if not HasModelLoaded(modelHash) then
        TriggerEvent('chat:addMessage', { args = { "Editor", "ERRO modelo invalido: " .. modelName } })
        return
    end

    local ped = PlayerPedId()

    -- Carrega valores da config se existirem
    posX, posY, posZ = 0.0, 0.0, 0.0
    rotX, rotY, rotZ = 0.0, 0.0, 0.0
    currentBoneIdx = 1
    for _, bp in pairs(Config.Backpacks) do
        if bp.model == modelName then
            posX, posY, posZ = bp.pos.x, bp.pos.y, bp.pos.z
            rotX, rotY, rotZ = bp.rot.x, bp.rot.y, bp.rot.z
            -- Tenta localizar o bone salvo na lista
            if bp.boneIndex then
                for i, b in ipairs(BONES) do
                    if b.id == bp.boneIndex then
                        currentBoneIdx = i
                        break
                    end
                end
            end
            break
        end
    end

    -- Spawn do objeto de preview
    local pedCoords = GetEntityCoords(ped)
    local obj = CreateObjectNoOffset(modelHash, pedCoords.x, pedCoords.y, pedCoords.z, true, false, true)
    Wait(150)

    if not obj or obj == 0 then
        TriggerEvent('chat:addMessage', { args = { "Editor", "ERRO ao criar objeto: " .. modelName } })
        return
    end

    table.insert(spawnedEditorObjects, obj)
    tempBackpack = obj
    AttachEntityToEntity(tempBackpack, ped, GetPedBoneIndex(ped, BONES[currentBoneIdx].id),
        posX, posY, posZ, rotX, rotY, rotZ, true, true, false, true, 1, true)

    -- Trava o personagem
    FreezeEntityPosition(ped, true)
    TaskStandStill(ped, -1)
    isEditing = true

    local boneName = BONES[currentBoneIdx].name
    TriggerEvent('chat:addMessage', { args = { "Editor", "OK! WASD=pos | Setas=rot | Q/C=Yaw | Espaco/Shift=Z | B=trocar bone | Enter=salvar Del=sair" } })

    -- ==========================================
    -- LOOP DO EDITOR
    -- ==========================================
    CreateThread(function()
        local step    = 0.005
        local rotStep = 1.5

        while isEditing do
            Wait(0)
            local currentPed = PlayerPedId()

            -- Mantém o boneco parado
            TaskStandStill(currentPed, 500)

            -- Bloqueia apenas ações de combate para não interferir com a leitura
            DisableControlAction(0, 0x07CE1E11, true) -- Shoot
            DisableControlAction(0, 0xF84FA74F, true) -- Aim

            -- Lê posição usando controles de movimento do Spooner
            local wPressed = IsDisabledControlPressed(0, CTRL_FORWARD)
            local sPressed = IsDisabledControlPressed(0, CTRL_BACKWARD)
            local aPressed = IsDisabledControlPressed(0, CTRL_LEFT)
            local dPressed = IsDisabledControlPressed(0, CTRL_RIGHT)
            local rPressed = IsDisabledControlPressed(0, CTRL_UP)   -- Espaço
            local fPressed = IsDisabledControlPressed(0, CTRL_DOWN) -- Shift

            -- Lê rotação (setas + Q/C)
            local rotXP = IsDisabledControlPressed(0, CTRL_ROT_FWD)
            local rotXM = IsDisabledControlPressed(0, CTRL_ROT_BWD)
            local rotYP = IsDisabledControlPressed(0, CTRL_ROT_L)
            local rotYM = IsDisabledControlPressed(0, CTRL_ROT_R)
            local rotZP = IsDisabledControlPressed(0, CTRL_YAW_L)  -- Q
            local rotZM = IsDisabledControlPressed(0, CTRL_YAW_R)  -- C

            -- Aplica deslocamentos
            if wPressed then posX = posX + step end
            if sPressed then posX = posX - step end
            if aPressed then posY = posY + step end
            if dPressed then posY = posY - step end
            if rPressed then posZ = posZ + step end
            if fPressed then posZ = posZ - step end

            if rotXP then rotX = rotX + rotStep end
            if rotXM then rotX = rotX - rotStep end
            if rotYP then rotY = rotY + rotStep end
            if rotYM then rotY = rotY - rotStep end
            if rotZP then rotZ = rotZ + rotStep end
            if rotZM then rotZ = rotZ - rotStep end

            -- Trocas de bone (B)
            local bonePressed = IsDisabledControlJustPressed(0, CTRL_NEXT_BONE)
            if bonePressed then
                currentBoneIdx = (currentBoneIdx % #BONES) + 1
                TriggerEvent('chat:addMessage', { args = { "Editor", "Bone: " .. BONES[currentBoneIdx].name } })
            end

            -- Atualiza o attach com bone atual
            if tempBackpack and DoesEntityExist(tempBackpack) then
                AttachEntityToEntity(tempBackpack, currentPed, GetPedBoneIndex(currentPed, BONES[currentBoneIdx].id),
                    posX, posY, posZ, rotX, rotY, rotZ, true, true, false, true, 1, true)
            end

            -- Salvar / Cancelar
            local savePressed   = IsDisabledControlJustPressed(0, CTRL_SAVE)
            local cancelPressed = IsDisabledControlJustPressed(0, CTRL_CANCEL)

            -- Eixos 3D
            if tempBackpack and DoesEntityExist(tempBackpack) then
                local coords = GetEntityCoords(tempBackpack)
                local fx, fy, fz = GetEntityMatrix(tempBackpack)
                DrawLine(coords.x, coords.y, coords.z, coords.x + fx.x*0.4, coords.y + fx.y*0.4, coords.z + fx.z*0.4, 255,   0,   0, 255)
                DrawLine(coords.x, coords.y, coords.z, coords.x + fy.x*0.4, coords.y + fy.y*0.4, coords.z + fy.z*0.4,   0, 255,   0, 255)
                DrawLine(coords.x, coords.y, coords.z, coords.x + fz.x*0.4, coords.y + fz.y*0.4, coords.z + fz.z*0.4,   0,   0, 255, 255)
            end

            -- HUD
            local boneInfo = BONES[currentBoneIdx]
            DrawTxt("~COLOR_HUD_TEXT~[EDITOR DE MOCHILAS]~s~",                               0.05, 0.12)
            DrawTxt("Modelo: " .. currentModel,                                              0.05, 0.15)
            DrawTxt("Bone: " .. boneInfo.name .. " (ID:" .. boneInfo.id .. ")",             0.05, 0.17)
            DrawTxt(string.format("Pos  X=%.3f  Y=%.3f  Z=%.3f", posX, posY, posZ),          0.05, 0.21)
            DrawTxt(string.format("Rot Px=%.1f Rl=%.1f Yw=%.1f", rotX, rotY, rotZ),          0.05, 0.24)
            DrawTxt("──────────────────────────────────────",                                0.05, 0.27)
            DrawTxt("W/S=PosX  A/D=PosY  Espaco/Shift=PosZ",                                0.05, 0.30)
            DrawTxt("Seta Cima/Baixo=Pitch  Esq/Dir=Roll  Q/C=Yaw",                         0.05, 0.33)
            DrawTxt("B = Trocar Bone",                                                       0.05, 0.36)
            DrawTxt("ENTER/Click = Salvar   DEL = Cancelar",                                0.05, 0.39)

            -- Salvar
            if savePressed then
                isEditing = false
                local boneId = BONES[currentBoneIdx].id
                local line = string.format(
                    "  { model = \"%s\", bone = %d, pos = { x=%.4f, y=%.4f, z=%.4f }, rot = { x=%.2f, y=%.2f, z=%.2f } },",
                    currentModel, boneId, posX, posY, posZ, rotX, rotY, rotZ
                )
                TriggerEvent('chat:addMessage', { args = { "CONFIG", line } })
                print("[FDB-BACKPACKS EDITOR] Cole no Config.Backpacks:")
                print(line)
                ForceUnfreeze()
                CleanupEditorObjects()

                local eqBackpack = LocalPlayer.state.currentBackpackStashId
                if eqBackpack then
                    TriggerEvent('fdb-backpacks:client:cleanupAllAttachedBackpacks')
                    Wait(100)
                    local PlayerData = FDBCore.Functions.GetPlayerData()
                    local metadata = PlayerData.metadata and PlayerData.metadata.equipmentSlots and PlayerData.metadata.equipmentSlots.backpack
                    if metadata then
                        TriggerEvent('fdb-backpacks:client:attachToBack', eqBackpack, metadata.itemName)
                    end
                end
            end

            -- Cancelar
            if cancelPressed then
                isEditing = false
                TriggerEvent('chat:addMessage', { args = { "Editor", "Cancelado." } })
                ForceUnfreeze()
                CleanupEditorObjects()
            end
        end
    end)
end

-- ==========================================
-- EVENTOS E COMANDOS
-- ==========================================
RegisterNetEvent('fdb-backpacks:client:openEditorMenu', function()
    OpenBackpackEditorMenu()
end)

RegisterCommand("ajustarmochila", function()
    OpenBackpackEditorMenu()
end, false)

RegisterCommand("destravarboneco", function()
    ForceUnfreeze()
    CleanupEditorObjects()
    TriggerEvent('chat:addMessage', { args = { "Sistema", "Personagem e camera destravados." } })
end, false)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        ForceUnfreeze()
        CleanupEditorObjects()
    end
end)

-- Ao iniciar: limpa camera presa de versoes anteriores
CreateThread(function()
    Wait(1000)
    RenderScriptCams(false, false, 0, true, true)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetPlayerControl(PlayerId(), true, 256)
    ClearPedTasksImmediately(ped)
end)

-- ==========================================
-- MENUS
-- ==========================================
function OpenBackpackEditorMenu()
    lib.registerContext({
        id = 'backpack_editor_menu',
        title = 'Ajustador de Mochilas & Bolsas',
        options = {
            { title = 'Mochilas (Costas)',            description = 'Grandes estilo trapper e civil', menu = 'backpack_menu_costas' },
            { title = 'Satchels & Bolsas (Tiracolo)', description = 'Modelos transversais e maletas', menu = 'backpack_menu_satchels' },
            { title = 'Bolsas Menores & Especiais',   description = 'Sacos, dinheiro e sela',         menu = 'backpack_menu_especiais' },
            { title = 'Equipamentos Especiais',       description = 'Aljava de flechas e outros',     menu = 'backpack_menu_equipamento' },
        }
    })
    lib.registerContext({
        id = 'backpack_menu_costas', title = 'Mochilas (Costas)', menu = 'backpack_editor_menu',
        options = {
            { title = 'Trapper Backpack', description = 'p_trapperbackpack01x', event = 'fdb-backpacks:client:startAdjust', args = 'p_trapperbackpack01x' },
            { title = 'Amb Pack 01',      description = 'p_ambpack01x',          event = 'fdb-backpacks:client:startAdjust', args = 'p_ambpack01x' },
            { title = 'Amb Pack 02',      description = 'p_ambpack02x',          event = 'fdb-backpacks:client:startAdjust', args = 'p_ambpack02x' },
            { title = 'Amb Pack 04',      description = 'p_ambpack04x',          event = 'fdb-backpacks:client:startAdjust', args = 'p_ambpack04x' },
            { title = 'Amb Pack 05',      description = 'p_ambpack05x',          event = 'fdb-backpacks:client:startAdjust', args = 'p_ambpack05x' },
        }
    })
    lib.registerContext({
        id = 'backpack_menu_satchels', title = 'Satchels & Bolsas', menu = 'backpack_editor_menu',
        options = {
            { title = 'Arthur Satchel',      description = 'p_cs_satchel01x',      event = 'fdb-backpacks:client:startAdjust', args = 'p_cs_satchel01x' },
            { title = 'Alternative Satchel', description = 'p_satchel01x',          event = 'fdb-backpacks:client:startAdjust', args = 'p_satchel01x' },
            { title = 'Knapsack (Trouxa)',   description = 's_knapsack01x',         event = 'fdb-backpacks:client:startAdjust', args = 's_knapsack01x' },
            { title = 'Bolsa Levin',         description = 'p_cs_baglevin01x',      event = 'fdb-backpacks:client:startAdjust', args = 'p_cs_baglevin01x' },
            { title = 'Saco Generico',       description = 'p_bag01x',              event = 'fdb-backpacks:client:startAdjust', args = 'p_bag01x' },
            { title = 'Maleta de Medico',    description = 'p_bag_leather_doctor',  event = 'fdb-backpacks:client:startAdjust', args = 'p_bag_leather_doctor' },
        }
    })
    lib.registerContext({
        id = 'backpack_menu_especiais', title = 'Menores & Especiais', menu = 'backpack_editor_menu',
        options = {
            { title = 'Bolsa de Dinheiro', description = 'p_moneybag05x',       event = 'fdb-backpacks:client:startAdjust', args = 'p_moneybag05x' },
            { title = 'Saco de Carvao',    description = 'p_coalbag02x',         event = 'fdb-backpacks:client:startAdjust', args = 'p_coalbag02x' },
            { title = 'Saco de Batata',    description = 'p_ambsack02x',         event = 'fdb-backpacks:client:startAdjust', args = 'p_ambsack02x' },
            { title = 'Bolsa Nativista',   description = 'p_indiantipibag01x',   event = 'fdb-backpacks:client:startAdjust', args = 'p_indiantipibag01x' },
            { title = 'Trouxa de Sela',    description = 'p_cs_saddlebundle01x', event = 'fdb-backpacks:client:startAdjust', args = 'p_cs_saddlebundle01x' },
        }
    })
    lib.registerContext({
        id = 'backpack_menu_equipamento', title = 'Equipamento', menu = 'backpack_editor_menu',
        options = {
            { title = 'Aljava de Flechas', description = 'p_quiver01x', event = 'fdb-backpacks:client:startAdjust', args = 'p_quiver01x' },
        }
    })
    lib.showContext('backpack_editor_menu')
end

RegisterNetEvent('fdb-backpacks:client:startAdjust', function(data)
    local modelName = data
    if type(data) == "table" then modelName = data.args or data[1] end
    if not modelName or type(modelName) ~= "string" then modelName = "p_cs_satchel01x" end
    StartAdjustmentProcess(modelName)
end)

RegisterCommand("limparmochilaslocais", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local hashes = {
        GetHashKey("p_trapperbackpack01x"), GetHashKey("p_ambpack01x"),    GetHashKey("p_ambpack02x"),
        GetHashKey("p_ambpack04x"),         GetHashKey("p_ambpack05x"),    GetHashKey("p_cs_satchel01x"),
        GetHashKey("p_satchel01x"),         GetHashKey("s_knapsack01x"),   GetHashKey("p_cs_baglevin01x"),
        GetHashKey("p_bag01x"),             GetHashKey("p_bag_leather_doctor"), GetHashKey("p_moneybag05x"),
        GetHashKey("p_coalbag02x"),         GetHashKey("p_ambsack02x"),    GetHashKey("p_indiantipibag01x"),
        GetHashKey("p_cs_saddlebundle01x"), GetHashKey("p_quiver01x")
    }
    local count = 0
    for _, hash in ipairs(hashes) do
        local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 50.0, hash, false, false, false)
        while object ~= 0 do
            SetEntityAsMissionEntity(object, true, true)
            DeleteObject(object)
            DeleteEntity(object)
            count = count + 1
            object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 50.0, hash, false, false, false)
        end
    end
    TriggerEvent('chat:addMessage', { args = { "Limpeza", string.format("Deletadas %d mochilas orfas.", count) } })
end, false)
