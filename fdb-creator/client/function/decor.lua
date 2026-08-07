-- Build DecorSettings from Config (for compatibility with existing code)
DecorSettings = {
    interior = Config.CharSelect.interior,
    interior_sets = Config.CharSelect.interior_sets,
    charselectcam = Config.CharSelect.camera,
    pedslots = {}
}

-- Convert scenario strings to hashes
for k, v in pairs(Config.CharSelect.pedslots) do
    DecorSettings.pedslots[k] = {
        coords = v.coords,
        heading = v.heading,
        scenario = v.scenario and GetHashKey(v.scenario) or nil,
        scenariopoint = v.scenariopoint and GetHashKey(v.scenariopoint) or nil
    }
end

Citizen.CreateThread(function()
    -- Load IMAPs
    if Config.CharSelect.imaps then
        for _, imap in pairs(Config.CharSelect.imaps) do
            RequestImap(GetHashKey(imap))
        end
    end
    
    -- Activate interior sets
    for k, v in pairs(DecorSettings.interior_sets) do
        if not IsInteriorEntitySetActive(DecorSettings.interior, v) then
            ActivateInteriorEntitySet(DecorSettings.interior, v)
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(DecorSettings.interior_sets) do
            if IsInteriorEntitySetActive(DecorSettings.interior, v) then
                DeactivateInteriorEntitySet(DecorSettings.interior, v, true)
            end
        end
    end
end)
