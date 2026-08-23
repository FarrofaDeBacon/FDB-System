fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'Encomenda - Sistema de Ilegal'
description 'Crime Core - sistema modular de criminalidade (Etapa 1 + Etapa 2: Roubo de NPC)'
version '0.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/utils.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/interface.lua',
    'bridge/rsg_bridge.lua',
    'bridge/fdb_bridge.lua',
    'server/core.lua',
    'server/editor.lua',
    'server/crimes/npc_robbery.lua',
    'server/crimes/store_robbery.lua',
    'server/node_engine/core.lua'
}

client_scripts {
    'bridge/interface.lua',
    'bridge/rsg_bridge_client.lua',
    'bridge/fdb_bridge_client.lua',
    'client/core.lua',
    'client/stores.lua',
    'client/freecam.lua',
    'client/editor.lua',
    'client/crimes/dev_tool.lua',
    'client/crimes/store_robbery.lua',
    'client/node_engine/core.lua'
}

dependencies {
    'fdb-core',
    'fdb-libs',
    'ox_lib',
    'ox_target',
    'oxmysql',
    'wasvendel_doorlock'
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*'
}
