fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

description 'fdb-libs - Custom UI and Utilities Library for FDB System'
version '1.0.0'

ui_page 'ui/build/index.html'

shared_scripts {
    'config.lua',
    'shared/locales/*.lua',
    'shared/framework-bridge/bridge.lua',
    'shared/component/data.lua',
}

client_scripts {
    'client/utils/loaders.lua',
    'client/anim/anim.lua',
    'client/theme/theme.lua',
    'client/theme/theme_editor.lua',
    'client/menu/menu.lua',
    'client/notify/notify.lua',
    'client/progress/progress.lua',
    'client/input/input.lua',
    'client/minigame/minigame.lua',
    'client/callback/callback.lua',
    'client/blip/blip.lua',
    'client/zones/zones.lua',
    'client/component/component.lua',
    'client/context/context.lua',
}

server_scripts {
    'server/notify/notify.lua',
    'server/callback/callback.lua',
}

files {
    'ui/build/index.html',
    'ui/build/assets/*'
}
