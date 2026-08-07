fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

description 'fdb-appearance'
version '2.5.6'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/functions.lua',
}

ui_page 'ui/build/index.html'

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

files {
    'img/*.png',
    'data/features.lua',
    'data/overlays.lua',
    'data/clothing.lua',
    'data/hairs_list.lua',
    'data/clothes_list.lua',
    'locales/*.json',
    'ui/build/index.html',
    'ui/build/assets/*',
}

ox_libs {
    'locale',
}

dependencies {
    'fdb-core',
    'ox_lib',
    'fdb-menubase',
    'fdb-libs'
}
