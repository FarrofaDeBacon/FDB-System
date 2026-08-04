fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'fdb-weaponcomp'
version '2.8.2'

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'fdb-core',
}

lua54 'yes'