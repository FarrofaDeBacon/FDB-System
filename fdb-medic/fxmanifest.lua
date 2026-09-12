fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
author 'FarrofaDeBacon'
description 'fdb-medic - Advanced Medical System for RedM | Dev: Artmines'
use_experimental_fxv2_oal 'yes'
version '0.3.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'ConfigMissions.lua',
    'client/client_shared.lua',   -- Load shared functions after config
}

files {
    'locales/*.json',
    'ui-svelte/dist/index.html',
    'ui-svelte/dist/assets/**/*'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',          -- Core server functionality
    'server/sv_bag.lua',          -- Medical bag server logic
    'server/medical_server.lua',  -- NEW: Medical inspection system with /inspect command
    'server/configui_sync.lua'    -- fdb-configui sync layer
}

client_scripts {
    'client/client.lua',          -- Core client functionality (death, revive, UI)
    'client/bag.lua',             -- Medical bag system
    'client/job_system.lua',      -- Job-related functionality & Missions
    'client/wound_system.lua',    -- Advanced wound detection & tracking
    'client/infection_system.lua', -- Infection progression system
    'client/treatment_system.lua', -- Treatment application system
    'client/wound_healing.lua',   -- Wound healing to scars system
    'client/envanim_system.lua',  -- Environmental & animal attack system
    'client/configui_sync.lua'    -- fdb-configui sync layer
}

dependencies {
    'fdb-core',
    'fdb-bossmenu',
    'ox_lib',
    'fdb-medical-core'
}

lua54 'yes'
ui_page 'ui-svelte/dist/index.html'
