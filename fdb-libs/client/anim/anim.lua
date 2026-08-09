-- ============================================================
-- FDB System | fdb-libs | client/anim/anim.lua
-- Advanced Animation and Prop Manager
-- ============================================================

local activeProps = {}

-- Toca uma animação e opcionalmente anexa um prop ao ped
local function PlayAnim(ped, dict, anim, options)
    if not ped or ped == 0 then ped = PlayerPedId() end
    options = options or {}
    
    local flag = options.flag or 1
    local duration = options.duration or -1
    local blendIn = options.blendIn or 8.0
    local blendOut = options.blendOut or -8.0
    local playbackRate = options.playbackRate or 0.0

    if not exports['fdb-libs']:LoadAnimDict(dict) then return false end

    TaskPlayAnim(ped, dict, anim, blendIn, blendOut, duration, flag, playbackRate, false, false, false)

    -- Se um prop foi definido, cria e anexa
    if options.prop then
        if not exports['fdb-libs']:LoadModel(options.prop) then 
            return false -- Animação tocou, mas sem prop
        end
        
        local coords = GetEntityCoords(ped)
        local propEntity = CreateObject(joaat(options.prop), coords.x, coords.y, coords.z, true, true, false)
        
        local boneIndex = 0
        if type(options.bone) == "string" then
            boneIndex = GetEntityBoneIndexByName(ped, options.bone)
        elseif type(options.bone) == "number" then
            boneIndex = GetPedBoneIndex(ped, options.bone)
        end
        
        local pos = options.pos or vector3(0.0, 0.0, 0.0)
        local rot = options.rot or vector3(0.0, 0.0, 0.0)
        
        AttachEntityToEntity(propEntity, ped, boneIndex, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(joaat(options.prop))

        table.insert(activeProps, { ped = ped, prop = propEntity })
        return propEntity
    end

    RemoveAnimDict(dict)
    return true
end

-- Limpa todos os props criados por esta lib que estão presos a um ped
local function ClearProps(ped)
    if not ped or ped == 0 then ped = PlayerPedId() end
    
    for i = #activeProps, 1, -1 do
        local data = activeProps[i]
        if data.ped == ped then
            if DoesEntityExist(data.prop) then
                DeleteEntity(data.prop)
            end
            table.remove(activeProps, i)
        end
    end
end

-- Limpa os props automaticamente se o recurso parar
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for i = 1, #activeProps do
            if DoesEntityExist(activeProps[i].prop) then
                DeleteEntity(activeProps[i].prop)
            end
        end
        activeProps = {}
    end
end)

exports('PlayAnim', PlayAnim)
exports('ClearProps', ClearProps)
