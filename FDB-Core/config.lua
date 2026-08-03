FDBConfig = {}

FDBConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
FDBConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
FDBConfig.UpdateInterval = 5                             -- how often to save player data in database in minutes
FDBConfig.HidePlayerNames = true

FDBConfig.Money = {}
FDBConfig.Money.MoneyTypes = { cash = 50, gold = 0, bank = 0, valbank = 0, rhobank = 0, blkbank = 0, armbank = 0, bloodmoney = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
FDBConfig.Money.DontAllowMinus = { 'cash', 'gold', 'bloodmoney' }    -- Money that is not allowed going in minus
FDBConfig.Money.MinusLimit = -5000                                   -- The maximum amount you can be negative 
FDBConfig.Money.PayCheckTimeOut = 10                                 -- The time in minutes that it will give the paycheck
FDBConfig.Money.PayCheckSociety = false                              -- If true paycheck will come from the society account that the player is employed at, requires fdb-management
FDBConfig.Money.EnableMoneyItems = true                              -- If true cash and bloodmoney will be represented wih inventory items
FDBConfig.Money.GoldItem = 'gold'                                    -- Inventory item used to represent gold when EnableGoldItems is true

FDBConfig.Gold = {}
FDBConfig.Gold.EnableGoldItems = false

FDBConfig.Player = {}
FDBConfig.Player.Bloodtypes = {
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
}

FDBConfig.Player.PlayerDefaults = {
    citizenid = function() return FDBCore.Player.CreateCitizenId() end,
    cid = 1,
    money = function()
        local moneyDefaults = {}
        for moneytype, startamount in pairs(FDBConfig.Money.MoneyTypes) do
            moneyDefaults[moneytype] = startamount
        end
        return moneyDefaults
    end,
    optin = true,
    charinfo = {
        firstname = 'Firstname',
        lastname = 'Lastname',
        birthdate = '00-00-0000',
        gender = 0,
        nationality = 'USA',
        account = function() return FDBCore.Functions.CreateAccountNumber() end
    },
    job = {
        name = 'unemployed',
        label = 'Civilian',
        payment = 10,
        type = 'none',
        onduty = false,
        isboss = false,
        grade = {
            name = 'Freelancer',
            level = 0
        }
    },
    gang = {
        name = 'none',
        label = 'No Gang Affiliation',
        isboss = false,
        grade = {
            name = 'none',
            level = 0
        }
    },
    metadata = {
        health = 600,
        hunger = 100,
        thirst = 100,
        cleanliness = 100,
        stress = 0,
        isdead = false,
        armor = 0,
        ishandcuffed = false,
        injail = 0,
        jailitems = {},
        status = {},
        rep = {},
        callsign = 'NO CALLSIGN',
        bloodtype = function() return FDBConfig.Player.Bloodtypes[math.random(1, #FDBConfig.Player.Bloodtypes)] end,
        fingerprint = function() return FDBCore.Player.CreateFingerId() end,
        walletid = function() return FDBCore.Player.CreateWalletId() end,
        criminalrecord = {
            hasRecord = false,
            date = nil
        },
    },
    position = FDBConfig.DefaultSpawn,
    items = {},
    weight = 35000,
    slots = 25,
}

FDBConfig.Server = {}                                    -- General server config
FDBConfig.Server.Closed = false                          -- Set server closed (no one can join except people with ace permission 'fdbadmin.join')
FDBConfig.Server.ClosedReason = 'Server Closed'          -- Reason message to display when people can't join the server
FDBConfig.Server.Uptime = 0                              -- Time the server has been up.
FDBConfig.Server.Whitelist = false                       -- Enable or disable whitelist on the server
FDBConfig.Server.WhitelistPermission = 'admin'           -- Permission that's able to enter the server when the whitelist is on
FDBConfig.Server.PVP = true                              -- Enable or disable pvp on the server (Ability to shoot other players)
FDBConfig.Server.Discord = ''                            -- Discord invite link
FDBConfig.Server.CheckDuplicateLicense = true            -- Check for duplicate rockstar license on join
FDBConfig.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

FDBConfig.Commands = {}                                  -- Command Configuration
FDBConfig.Commands.OOCColor = { 255, 151, 133 }          -- RGB color code for the OOC command

FDBConfig.PromptDistance = 1.5
FDBConfig.Player.RevealMap = true
