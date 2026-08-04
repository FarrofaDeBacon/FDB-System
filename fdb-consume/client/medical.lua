RegisterNetEvent('fdb-consume:client:ConsumeMedical', function(propModel, animType, maxUses, animDict, animName, itemName)
    local ped = PlayerPedId()
    
    local dict = animDict or "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5"
    local clip = animName or "chug_a"

    local modelHash = GetHashKey(propModel)
    RequestModel(modelHash)
    local attempts = 0
    while not HasModelLoaded(modelHash) and attempts < 100 do Wait(10); attempts = attempts + 1 end

    local coords = GetEntityCoords(ped)
    local prop = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
    local boneName = 'SKEL_R_HAND'
    local x, y, z = 0.0, 0.0, 0.04
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

    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 50 do Wait(10); timeout = timeout + 1 end
    
    if timeout < 50 then
        TaskPlayAnim(ped, dict, clip, 1.0, 1.0, 2000, 31, 0.0, false, false, false)
        Wait(1000)
        TriggerServerEvent('fdb-consume:server:takeBite')
        Wait(1000)
    else
        TriggerServerEvent('fdb-consume:server:cancelConsume')
    end

    ClearPedTasks(ped)
    if DoesEntityExist(prop) then
        DetachEntity(prop, true, true)
        DeleteObject(prop)
    end
end)
