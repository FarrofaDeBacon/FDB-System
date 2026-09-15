-- ============================================================
-- FDB System | fdb-medical-core | fxmanifest.lua
-- ============================================================

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'fdb-medical-core - Single Source of Truth for Physiology and Damage'
version '1.0.0'

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/enums.lua',
    'shared/body_parts.lua',
    'shared/config.lua',
    'shared/config_bones.lua',
    'shared/config_wounds.lua'
}

client_scripts {
    'client/bones.lua',
    'client/sync.lua',
    'client/fracture_effects.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/database.lua',
    'server/vitals.lua',
    'server/fracture_effects.lua',
    'server/wounds.lua',
    'server/fracture_healing.lua',
    'server/bleedout.lua',
    'server/infection.lua',
    'server/damage.lua',
    'server/api.lua'
}

dependencies {
    'fdb-core',
    'ox_lib'
}

exports {
    'ApplyDamage',
    'TreatWound',
    'GetVitals',
    'HasArmFracture',
    'HasTorsoFracture',
    'FullHeal',
    'GetCompleteMedicalProfile',
    'GetBodyPartFromBone'
}
