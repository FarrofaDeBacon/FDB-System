fx_version "adamant"
games { "rdr3" }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
version '1.30.0'
client_scripts {
    'shared/**.lua',
    'client/**.lua',
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/**.lua',
    'server/adapters/RSGAdapter.lua',
    'server/function.lua',
    'server/callbacks.lua',
}

escrow_ignore {
    'shared/*.lua',
    'client/**.lua',
    'server/adapters/*.lua',
}

files {
    'ui/**/*',
    'ui/*',
    'ui/locales/*.js',
}

ui_page 'ui/index.html'

lua54 'yes'

dependency '/assetpacks'