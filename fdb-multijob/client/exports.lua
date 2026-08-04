-- Client Exports for fdb-multijob

-- Open the multijob menu
exports('OpenMultijobMenu', function()
    TriggerEvent('fdb-multijob:client:openmenu')
end)
