fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Antigravity'
description 'Survival Engine'
version '1.0.0'

fdb_propeditor_supported 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/configui_sync.lua',
    'client/alcohol.lua',
    'client/main.lua',
    'client/cleanliness.lua',
    'client/bladder.lua',
    'client/temperature.lua',
    'client/health.lua',
    'client/exports.lua',
    'client/movement.lua',
    'client/illness.lua'
}

server_scripts {
    'server/configui_sync.lua',
    'server/main.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'fdb-core'
}

