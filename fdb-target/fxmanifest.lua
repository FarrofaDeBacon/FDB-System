-- Resource standalone, ainda não integrado a nenhum consumidor. Migração do illegal-system fica pra quando houver um segundo caso de uso confirmado.
fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

description 'fdb-target - Core Targeting System for FDB'
version '1.0.0'

client_scripts {
    'client/main.lua',
}
