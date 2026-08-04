fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config/canteen.lua',
    'config/bathing.lua'
}

client_scripts {
    'client/configui_sync.lua',
    'client/structs.js',
    'client/canteen.lua',
    'client/bathing.lua',
    'client/items.lua',
    'client/environment.lua'
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

