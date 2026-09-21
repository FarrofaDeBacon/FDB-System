fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'fdb-shops'
version '1.0.1'

ui_page 'ui-svelte/dist/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/freecam.lua',
    'client/editor.lua',
    'client/client.lua',
    'client/owner_menu.lua',
    'client/crafting.lua',
    'client/placement.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/shop_manager.lua',
    'server/employee_manager.lua',
    'server/stash_manager.lua',
    'server/craft_manager.lua',
    'server/admin_commands.lua',
    'server/editor.lua',
    'server/seed.lua',
    'server/server.lua',
}

files {
    'locales/*.json',
    'ui-svelte/dist/index.html',
    'ui-svelte/dist/assets/*'
}

dependencies {
    'fdb-core',
    'fdb-inventory',
    'fdb-economy',
    'fdb-libs',
    'oxmysql',
    'ox_target'
}

lua54 'yes'
