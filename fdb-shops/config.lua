-- ============================================================
-- FDB System | fdb-shops | config.lua
-- General Shop Settings
-- ============================================================

Config = {}

-- Keybind prompt to interact with shops (if not using ox_target)
Config.Keybind = 'J' 

-- Limits the amount of shops a single player can own
Config.MaxShopsPerOwner = 3

-- NOTA DE NOMENCLATURA:
-- buyCatalog = Itens que a LOJA vende (o player COMPRA)
-- sellCatalog = Itens que a LOJA compra (o player VENDE)


-- How often (in ms) to check if the owner is present to hide NPCs (if hide_when_owner_present is enabled)
Config.NpcCheckInterval = 5000

-- Default limits for physical stash
Config.StashMaxWeight = 500000
Config.StashMaxSlots = 50

-- Cash Register Mode
-- 'numeric' -> Only tracks balance in DB. Players withdraw/deposit via menu.
-- 'physical' -> Balances are synced with a physical 'cash' item in the register's stash.
Config.CashRegisterMode = 'physical'

-- Supply Order Discovery Methods
Config.SupplyOrderDiscovery = { 
    enableBoard = true, 
    enableNpcPrompt = true 
}

-- Note: 
-- Products and StoreLocations have been migrated to the database.
-- Do not add them here. Use the /shopcreate admin command or DB directly.
