-- Fonte única de GetBodyPartFromBone para qualquer resource do ecossistema FDB.
-- Consome Config.Bones de shared/config_bones.lua.

local function GetBodyPartFromBone(boneId)
    return Config.Bones[boneId] or 'TORSO'
end

exports('GetBodyPartFromBone', GetBodyPartFromBone)
