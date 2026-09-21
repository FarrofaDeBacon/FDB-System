-- ============================================================
-- FDB System | fdb-shops | config.lua
-- General Shop Settings
-- ============================================================

Config = {}

-- Keybind prompt to interact with shops (if not using ox_target)
Config.Keybind = 'J' 

-- Use ox_target and NPCs for shops
Config.UseNPCs = true 

-- Default NPC Model if none specified
Config.NPCModel = 's_m_m_unibutchers_01' 

-- Opening and closing hours (0-23)
Config.DefaultOpenHour = 6 
Config.DefaultCloseHour = 22 

-- Limits the amount of shops a single player can own
Config.MaxShopsPerOwner = 3

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
