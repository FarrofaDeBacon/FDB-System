-- ============================================================
-- FDB System | fdb-medical-core | client/bones.lua
-- Single source of GetBodyPartFromBone for the FDB ecosystem.
-- ============================================================

local function GetBodyPartFromBone(boneId)
    return Config.Bones[boneId] or 'TORSO'
end

exports('GetBodyPartFromBone', GetBodyPartFromBone)
