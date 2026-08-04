fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'Sistema de Consumo Baseado no fdb-core'
version '1.0.0'

fdb_propeditor_supported 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@fdb-core/shared/locale.lua',
    'config.lua',
    'config/foods.lua',
    'config/drinks.lua',
    'config/medical.lua',
    'config/drugs.lua',
    'config/smokes.lua'
}

client_scripts {
    'client/configui_sync.lua',
    'client/exports.lua',
    'client/foods.lua',
    'client/drinks.lua',
    'client/medical.lua',
    'client/smokes.lua',
    'client.lua'
}

server_scripts {
    'server/configui_sync.lua',
    'server.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'fdb-core'
}

