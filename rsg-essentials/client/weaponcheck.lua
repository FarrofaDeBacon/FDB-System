local FDBCore = exports['fdb-core']:GetCoreObject()

RegisterNetEvent('fdb-core:client:RemoveWeaponFromTab', function(weaponName)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(weaponName)
    local weapon = GetPedCurrentHeldWeapon(PlayerPedId())
    local serial = exports['fdb-weapons']:weaponInHands()
    local weaponTypeSlot = Citizen.InvokeNative(0x46F032B8DDF46CDE, weaponHash)

    local weaponInSlot = Citizen.InvokeNative(0xDBC4B552B2AE9A83, ped, weaponTypeSlot)

    if weaponInSlot then
        exports['fdb-weapons']:RemoveWeaponFromPeds(weaponName, serial[weaponHash])
    end

    if weaponHash == weapon then 
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    end
end)

CreateThread(function()   
    while true do
        Wait(1000)
        local player = PlayerPedId()
        local weapon = Citizen.InvokeNative(0x8425C5F057012DAB, player) -- GET_CURRENT_PED_WEAPON
        local WeaponData = FDBCore.Shared.Weapons[weapon]
        if WeaponData and WeaponData["name"] ~= "weapon_unarmed" then
            local weaponGroup = Citizen.InvokeNative(0xEDCA14CA5199FF25, weapon) -- GET_WEAPONTYPE_GROUP
            if weaponGroup ~= `group_thrown` then
                local hasItem = FDBCore.Functions.HasItem(WeaponData["name"])
                if not hasItem then
                    -- remove weapon that is not in the inventory of the player
                    SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
                    RemoveWeaponFromPed(player, weapon)
                end
            end
        end
    end
end)
