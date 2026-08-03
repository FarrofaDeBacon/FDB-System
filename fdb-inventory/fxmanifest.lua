fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
ox_lib 'locale'
lua54 'yes'

description 'fdb-inventory'
version '2.8.4'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/helpers.lua',
}

client_scripts {
    'client/drops/functions.lua',
    'client/functions.lua',
    'client/commands.lua',
    'client/exports.lua',
    'client/events.lua',
    'client/drops/events.lua',
    'client/ui/events.lua',
    'client/ui/callbacks.lua',
    'client/ui/trade_events.lua',
    'client/ui/trade_callbacks.lua',
    'client/ui/trade_target.lua',
    'client/drops/ui/callbacks.lua',
    'client/main.lua',
    'client/hotbar_keys.lua',
    'client/drops/loops.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/shops/functions.lua',
    'server/exports.lua',
    'server/shops/exports.lua',
    'server/main.lua',
    'server/events/*.lua',
    'server/drops/events/*.lua',
    'server/shops/events/*.lua',
    'server/commands.lua',
    'server/versionchecker.lua',
    'server/wipe_equipment_data.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'ui/dist/images/*',
    "shared/*.lua", --- for lib.load
    'locales/*.json',
}
