Citizen.CreateThread(function()
    SetDiscordAppId(Config.Discord.DiscordAppID)

    SetDiscordRichPresenceAsset(Config.Discord.AppBigAssetID)
    SetDiscordRichPresenceAssetText(Config.Discord.AppBigAssetText)

    SetDiscordRichPresenceAssetSmall(Config.Discord.AppSmallAssetID)
    SetDiscordRichPresenceAssetSmallText(Config.Discord.AppSmallAssetText)

    SetDiscordRichPresenceAction(0, Config.Discord.FirstButtonPlaceholder, Config.Discord.FirstButtonLink)
    SetDiscordRichPresenceAction(1, Config.Discord.SecondButtonPlaceholder, Config.Discord.SecondButtonLink)

    while true do
        TriggerServerEvent('fdb-discord:getdata')

        Citizen.Wait(Config.Discord.UpdateEvery)
    end
end)

RegisterNetEvent("fdb-discord:receivedata", function(richPresenceString)
    SetRichPresence(richPresenceString)
end)
