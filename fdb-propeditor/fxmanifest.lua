fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'fdb-propeditor'
author 'Farrofa DeBacon'
description 'Motor de Posicionamento Compartilhado com Câmera Livre'

shared_scripts {
    '@fdb-libs/shared/bridge.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/freecam.lua'
}

server_scripts {
    'server/main.lua'
}

exports {
    'StartPlacementCamera'
}
