-- ============================================================
-- FDB System | fdb-medical-core | client/bones.lua
-- Fonte unica de GetBodyPartFromBone para ecossistema FDB.
-- ============================================================

local function GetBodyPartFromBone(boneId)
    return Config.Bones[boneId] or 'TORSO'
end

exports('GetBodyPartFromBone', GetBodyPartFromBone)
