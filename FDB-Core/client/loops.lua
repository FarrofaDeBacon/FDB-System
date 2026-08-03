CreateThread(function()
    local interval = (1000 * 60) * FDBCore.Config.UpdateInterval

    while true do
        Wait(interval)
        if LocalPlayer.state.isLoggedIn then 
            TriggerServerEvent("FDBCore:UpdatePlayer")
        end     
    end
end)