fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'fdb-economy — Regional inflation engine'
version '1.0.0'

shared_scripts {
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/engine.lua',
    'server/exports.lua',
}

files {
    'locales/*.json',
}

dependencies {
    'fdb-core',
    'fdb-libs',
    'oxmysql',
}

lua54 'yes'
