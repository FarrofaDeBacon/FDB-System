local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()


local function initBait()
    for i = 1, #Config.Baits do
        local bait = Config.Baits[i]

        RSGCore.Functions.CreateUseableItem(bait, function(source, item)
            local src = source
            local Player = RSGCore.Functions.GetPlayer(src) -- why do we need this?
            TriggerClientEvent('rsg-fishing:client:usebait', src, item.name)
        end)
    end
end
-- end of make bait useable

-- remove bait when used on fishing rod
RegisterServerEvent('rsg-fishing:server:removeBaitItem')
AddEventHandler('rsg-fishing:server:removeBaitItem', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', 1)
end)

local fishEntity = {
    [`A_C_FISHBLUEGIL_01_MS`]        = 'a_c_fishbluegil_01_ms',
    [`A_C_FISHBLUEGIL_01_SM`]        = 'a_c_fishbluegil_01_sm',
    [`A_C_FISHBULLHEADCAT_01_MS`]    = 'a_c_fishbullheadcat_01_ms',
    [`A_C_FISHBULLHEADCAT_01_SM`]    = 'a_c_fishbullheadcat_01_sm',
    [`A_C_FISHCHAINPICKEREL_01_MS`]  = 'a_c_fishchainpickerel_01_ms',
    [`A_C_FISHCHAINPICKEREL_01_SM`]  = 'a_c_fishchainpickerel_01_sm',
    [`A_C_FISHCHANNELCATFISH_01_LG`] = 'a_c_fishchannelcatfish_01_lg',
    [`A_C_FISHCHANNELCATFISH_01_XL`] = 'a_c_fishchannelcatfish_01_xl',
    [`A_C_FISHLAKESTURGEON_01_LG`]   = 'a_c_fishlakesturgeon_01_lg',
    [`A_C_FISHLARGEMOUTHBASS_01_LG`] = 'a_c_fishlargemouthbass_01_lg',
    [`A_C_FISHLARGEMOUTHBASS_01_MS`] = 'a_c_fishlargemouthbass_01_ms',
    [`A_C_FISHLONGNOSEGAR_01_LG`]    = 'a_c_fishlongnosegar_01_lg',
    [`A_C_FISHMUSKIE_01_LG`]         = 'a_c_fishmuskie_01_lg',
    [`A_C_FISHNORTHERNPIKE_01_LG`]   = 'a_c_fishnorthernpike_01_lg',
    [`A_C_FISHPERCH_01_MS`]          = 'a_c_fishperch_01_ms',
    [`A_C_FISHPERCH_01_SM`]          = 'a_c_fishperch_01_sm',
    [`A_C_FISHRAINBOWTROUT_01_LG`]   = 'a_c_fishrainbowtrout_01_lg',
    [`A_C_FISHRAINBOWTROUT_01_MS`]   = 'a_c_fishrainbowtrout_01_ms',
    [`A_C_FISHREDFINPICKEREL_01_MS`] = 'a_c_fishredfinpickerel_01_ms',
    [`A_C_FISHREDFINPICKEREL_01_SM`] = 'a_c_fishredfinpickerel_01_sm',
    [`A_C_FISHROCKBASS_01_MS`]       = 'a_c_fishrockbass_01_ms',
    [`A_C_FISHROCKBASS_01_SM`]       = 'a_c_fishrockbass_01_sm',
    [`A_C_FISHSALMONSOCKEYE_01_LG`]  = 'a_c_fishsalmonsockeye_01_lg',
    [`A_C_FISHSALMONSOCKEYE_01_ML`]  = 'a_c_fishsalmonsockeye_01_ml',
    [`A_C_FISHSALMONSOCKEYE_01_MS`]  = 'a_c_fishsalmonsockeye_01_ms',
    [`A_C_FISHSMALLMOUTHBASS_01_LG`] = 'a_c_fishsmallmouthbass_01_lg',
    [`A_C_FISHSMALLMOUTHBASS_01_MS`] = 'a_c_fishsmallmouthbass_01_ms',
}

local fishNames = {
    [`A_C_FISHBLUEGIL_01_MS`]        = Config.fishData.A_C_FISHBLUEGIL_01_MS[1],
    [`A_C_FISHBLUEGIL_01_SM`]        = Config.fishData.A_C_FISHBLUEGIL_01_SM[1],
    [`A_C_FISHBULLHEADCAT_01_MS`]    = Config.fishData.A_C_FISHBULLHEADCAT_01_MS[1],
    [`A_C_FISHBULLHEADCAT_01_SM`]    = Config.fishData.A_C_FISHBULLHEADCAT_01_SM[1],
    [`A_C_FISHCHAINPICKEREL_01_MS`]  = Config.fishData.A_C_FISHCHAINPICKEREL_01_MS[1],
    [`A_C_FISHCHAINPICKEREL_01_SM`]  = Config.fishData.A_C_FISHCHAINPICKEREL_01_SM[1],
    [`A_C_FISHCHANNELCATFISH_01_LG`] = Config.fishData.A_C_FISHCHANNELCATFISH_01_LG[1],
    [`A_C_FISHCHANNELCATFISH_01_XL`] = Config.fishData.A_C_FISHCHANNELCATFISH_01_XL[1],
    [`A_C_FISHLAKESTURGEON_01_LG`]   = Config.fishData.A_C_FISHLAKESTURGEON_01_LG[1],
    [`A_C_FISHLARGEMOUTHBASS_01_LG`] = Config.fishData.A_C_FISHLARGEMOUTHBASS_01_LG[1],
    [`A_C_FISHLARGEMOUTHBASS_01_MS`] = Config.fishData.A_C_FISHLARGEMOUTHBASS_01_MS[1],
    [`A_C_FISHLONGNOSEGAR_01_LG`]    = Config.fishData.A_C_FISHLONGNOSEGAR_01_LG[1],
    [`A_C_FISHMUSKIE_01_LG`]         = Config.fishData.A_C_FISHMUSKIE_01_LG[1],
    [`A_C_FISHNORTHERNPIKE_01_LG`]   = Config.fishData.A_C_FISHNORTHERNPIKE_01_LG[1],
    [`A_C_FISHPERCH_01_MS`]          = Config.fishData.A_C_FISHPERCH_01_MS[1],
    [`A_C_FISHPERCH_01_SM`]          = Config.fishData.A_C_FISHPERCH_01_SM[1],
    [`A_C_FISHRAINBOWTROUT_01_LG`]   = Config.fishData.A_C_FISHRAINBOWTROUT_01_LG[1],
    [`A_C_FISHRAINBOWTROUT_01_MS`]   = Config.fishData.A_C_FISHRAINBOWTROUT_01_MS[1],
    [`A_C_FISHREDFINPICKEREL_01_MS`] = Config.fishData.A_C_FISHREDFINPICKEREL_01_MS[1],
    [`A_C_FISHREDFINPICKEREL_01_SM`] = Config.fishData.A_C_FISHREDFINPICKEREL_01_SM[1],
    [`A_C_FISHROCKBASS_01_MS`]       = Config.fishData.A_C_FISHROCKBASS_01_MS[1],
    [`A_C_FISHROCKBASS_01_SM`]       = Config.fishData.A_C_FISHROCKBASS_01_SM[1],
    [`A_C_FISHSALMONSOCKEYE_01_LG`]  = Config.fishData.A_C_FISHSALMONSOCKEYE_01_LG[1],
    [`A_C_FISHSALMONSOCKEYE_01_ML`]  = Config.fishData.A_C_FISHSALMONSOCKEYE_01_ML[1],
    [`A_C_FISHSALMONSOCKEYE_01_MS`]  = Config.fishData.A_C_FISHSALMONSOCKEYE_01_MS[1],
    [`A_C_FISHSMALLMOUTHBASS_01_LG`] = Config.fishData.A_C_FISHSMALLMOUTHBASS_01_LG[1],
    [`A_C_FISHSMALLMOUTHBASS_01_MS`] = Config.fishData.A_C_FISHSMALLMOUTHBASS_01_MS[1],
}

-- add fish caught to inventory
RegisterServerEvent('rsg-fishing:FishToInventory')
AddEventHandler('rsg-fishing:FishToInventory', function(fishModel, weight)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local fish = fishEntity[fishModel]
    local fish_name = fishNames[fishModel]
    local fish_weight = string.format('%.2f%%', (weight * 54.25)):gsub('%%', '')

    -- Get the player's character name correctly
    local charinfo = Player.PlayerData.charinfo
    local firstname = charinfo.firstname
    local lastname = charinfo.lastname

    Player.Functions.AddItem(fish, 1, nil, { weight = fish_weight })
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[fish], 'add', 1)
    TriggerClientEvent('ox_lib:notify', src,
        { title = locale('sv_you_got_fish_name') .. ' ' .. fish_name, type = 'success', duration = 5000 })
    TriggerEvent('rsg-log:server:CreateLog', 'fishing', locale('sv_discord_b'), 'green',
        firstname .. ' ' .. lastname .. ' ' .. locale('sv_discord_c') .. ' ' .. fish_weight .. 'KG ' .. fish_name)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    initBait()
end)
