-- ============================================================
-- FDB System | fdb-barbers | fxmanifest.lua
-- Resource manifest file
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'fdb-barbers'
version '2.0.7'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/hairs.lua',
    'shared/overlays.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'server/versionchecker.lua'
}

files {
    'locales/*.json',
}

dependencies {
    'fdb-core',
    'fdb-menubase',
    'ox_lib'
}

lua54 'yes'

