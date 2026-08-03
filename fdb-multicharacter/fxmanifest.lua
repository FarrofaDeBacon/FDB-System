fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'fdb-multicharacter'
version '2.3.5'

ui_page "ui/dist/index.html"

client_scripts {
    'client/main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/versionchecker.lua'
}

files {
    'ui/dist/index.html',
    'ui/dist/red_overlay.png',
    'ui/dist/assets/*',
}

dependencies {
    'fdb-core'
}

lua54 'yes'
