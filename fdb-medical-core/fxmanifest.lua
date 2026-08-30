fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'fdb-medical-core — Fonte Única de Verdade Fisiológica e Dano'
version '1.0.0'

files {
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/enums.lua',
    'shared/config.lua',
    'shared/config_wounds.lua'
}

client_scripts {
    'client/sync.lua',
    'client/fracture_effects.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/vitals.lua',
    'server/wounds.lua',
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
    'HasTorsoFracture'
}
