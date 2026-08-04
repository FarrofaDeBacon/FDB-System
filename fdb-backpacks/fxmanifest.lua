fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'fdb-backpacks - Novo script de mochilas físicas com sistema de gaveta deslizante'
version '1.0.0'
author 'Antigravity'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/animations.lua',
    'client/ground.lua',
    'client/target.lua',
    'client/weight.lua',
    'client/damage.lua',
    'client/editor.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/validation.lua',
    'server/durability.lua',
    'server/persistence.lua',
    'server/stash.lua',
    'server/main.lua'
}

lua54 'yes'
