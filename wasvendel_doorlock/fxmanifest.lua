fx_version "cerulean"
game "rdr3"
lua54 "yes"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

author "wasvendel"
version "1.1.1"

dependencies {
    "oxmysql",
}

shared_scripts {
    "config.lua",
    "lang.lua",
}

client_scripts {
    "client/door_hashes.lua",
    "client/door_search.lua",
    "client/placement.lua",
    "client.lua",
}

server_scripts {
    "server/schema.lua",
    "server/bridge.lua",
    "server/server.lua",
}

ui_page "html/index.html"

files {
    "html/index.html",
    "html/style.css",
    "html/script.js",
    "html/crock.ttf",
}

escrow_ignore {
    'client/door_hashes.lua',
    'client/door_search.lua',
    'client/placement.lua',
    'client.lua',
    'server/schema.lua',
    'server/bridge.lua',
    'server/server.lua',
    'config.lua',
    'lang.lua',
}

dependency '/assetpacks'
dependency '/assetpacks-redm'