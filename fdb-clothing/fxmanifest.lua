-- ============================================================
-- FDB System | fdb-clothing | fxmanifest.lua
-- Resource manifest file
-- Author: FarrofaDeBacon | Last Modified: 2026-08-08
-- ============================================================
fx_version "adamant"
games { "rdr3" }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
version '3.31.0'

client_scripts {
    'shared/callbacks_wrapper.lua',
	'shared/albedo_data.lua',
	'shared/componentsbody.lua',
	'shared/wearablestates.lua',
	'shared/config.lua',
	'shared/lang.lua',
	'shared/fdb_assets.lua',
	'client/function.lua',
	'client/menufunction.lua',
	'client/dataview.lua',
	'client/menubuilder.lua',
	'client/NUICallbacks.lua',
	'client/client.lua',
	'client/adapters/RSGAdapter.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'shared/callbacks_wrapper.lua',
	'shared/albedo_data.lua',
	'shared/componentsbody.lua',
	'shared/wearablestates.lua',
	'shared/config.lua',
	'shared/lang.lua',
	'shared/fdb_assets.lua',
	'server/adapters/RSGAdapter.lua',
	'server/main.lua',
}

files {
	'ui/**/*',
	'ui/*',
	'ui/lang.js',
}

ui_page 'ui/index.html'

lua54 'yes'

dependency '/assetpacks'

