fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'locales/*.json'
}

dependencies {
    'fdb-core',
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/configui_sync.lua',
    'client/main.lua'
}

server_scripts {
    'server/configui_sync.lua',
    'server/main.lua'
}

