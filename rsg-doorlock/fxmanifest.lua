fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'fdb-doorlock'
version '1.0.3'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    'server/versionchecker.lua'
}

files {
    'locales/*.json',
}

dependency {
    'fdb-core',
    'ox_lib'
}

lua54 'yes'
