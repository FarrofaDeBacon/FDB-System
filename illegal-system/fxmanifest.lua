fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships officially.'

author 'Encomenda - Sistema de Ilegal'
description 'Crime Core - sistema modular de criminalidade (Etapa 1 + Etapa 2: Roubo de NPC)'
version '0.1.0'

shared_scripts {
    'config.lua',
    'shared/utils.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/interface.lua',
    'bridge/rsg_bridge.lua',
    'bridge/fdb_bridge.lua', -- trocar por outro bridge se o framework mudar
    'server/core.lua',
    'server/crimes/npc_robbery.lua',
}

    'bridge/fdb_bridge.lua', -- trocar por outro bridge se o framework mudar
    'server/core.lua',
    'server/crimes/npc_robbery.lua',
}

client_scripts {
    'bridge/rsg_bridge_client.lua',
    'bridge/fdb_bridge_client.lua',
    'client/core.lua',
}

dependencies {
    'fdb-core',
    'oxmysql',
}
