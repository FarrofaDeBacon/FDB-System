local FDBCore = exports['fdb-core']:GetCoreObject()
local medicbag = 0
local deployedtable = nil
local MedicMenus = {}
exports['rsg-target']:AddTargetModel(1259819729, {
    options = {
        {
            type = "client",
            event = 'fdb-medic:client:pickup',
            icon = "fas fa-undo",
            label = locale('cl_bag_pickup'),
            distance = 3.0
        }
    }
})

exports['rsg-target']:AddTargetModel(1259819729, {
    options = {
        {
            icon = 'far fa-gear',
            label = locale('cl_bag_open'),
            type = "client",
            event = 'fdb-medic:client:medicbagMenu',
        },
    },
    distance = 2.0,
})

AddEventHandler('fdb-medic:client:bagstorage', function()
    local job = FDBCore.Functions.GetPlayerData().job.name
    if not IsMedicJob(job) then return end
    TriggerServerEvent('fdb-medic:server:openbaginv')
end)

RegisterNetEvent('fdb-medic:client:pickup', function()
    if deployedtable ~= nil then
        local obj = NetworkGetEntityFromNetworkId(deployedtable)
        local objCoords = GetEntityCoords()
        local ped = PlayerPedId()
        NetworkRequestControlOfEntity(obj)
        SetEntityAsMissionEntity(obj,false,true)
        DeleteEntity(obj)
        DeleteObject(obj)
        if not DoesEntityExist(obj) then
            TriggerServerEvent('fdb-medic:server:pickup', deployedtable)
            TriggerServerEvent('fdb-medic:server:pickuptab')
            deployedtable = nil
        end
        Wait(500)
        ClearPedTasks(ped)
    else
        lib.notify( {title = locale('cl_bag_no_medicbag'), type = 'error' })
    end
end)

RegisterNetEvent('fdb-medic:client:medicbag', function()
    print("Event triggered!")
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local forward = GetEntityForwardVector(ped)
    local x, y, z = table.unpack(coords + forward * 0.5)
    local model = GetHashKey('p_bag_leather_doctor')
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end
    local object = CreateObject(model, x, y, z + 1.0, true, true, false)
    if DoesEntityExist(object) then
        PlaceObjectOnGroundProperly(object)
        SetEntityHeading(object, heading)
        FreezeEntityPosition(object, true)
        deployedtable = NetworkGetNetworkIdFromEntity(object)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CROUCH_INSPECT", -1, true)
        Wait(5000)
        ClearPedTasks(ped)
    else
        print("Failed to spawn the object!")
    end
    SetModelAsNoLongerNeeded(model)
end)

CreateThread(function()
    for _, v in ipairs(Config.MedicBagCrafting) do
        local IngredientsMetadata = {}
        local itemInfo = FDBCore.Shared.Items[tostring(v.receive)]
        if itemInfo then
            local setheader = itemInfo.label
            local itemimg = "nui://"..Config.Image..itemInfo.image
            for i, ingredient in ipairs(v.ingredients) do
                local ingInfo = FDBCore.Shared.Items[ingredient.item]
                local ingLabel = ingInfo and ingInfo.label or ingredient.item
                table.insert(IngredientsMetadata, { label = ingLabel, value = ingredient.amount })
            end
            local option = {
                title = setheader,
                icon = itemimg,
                event = 'fdb-medic:client:mediccraft',
                metadata = IngredientsMetadata,
                args = {
                    title = setheader,
                    category = v.category,
                    ingredients = v.ingredients,
                    crafttime = v.crafttime,
                    craftingrep = v.craftingrep,
                    receive = v.receive,
                    giveamount = v.giveamount
                }
            }
            if not MedicMenus[v.category] then
                MedicMenus[v.category] = {
                    id = 'crafting_menu_' .. v.category,
                    title = v.category,
                    menu = 'crafting_menu',
                    onBack = function() end,
                    options = { option }
                }
            else
                table.insert(MedicMenus[v.category].options, option)
            end
        else
            print("^1[fdb-medic] Error: Item " .. tostring(v.receive) .. " does not exist in FDBCore.Shared.Items^7")
        end
    end
end)

CreateThread(function()
    for category, MenuData in pairs(MedicMenus) do
        RegisterNetEvent('fdb-medic:client:' .. category)
        AddEventHandler('fdb-medic:client:' .. category, function()
            lib.registerContext(MenuData)
            lib.showContext(MenuData.id)
        end)
    end
end)

RegisterNetEvent('fdb-medic:client:craftingmenu', function()
    local Menu = {
        id = 'med_craft',
        title = locale('cl_bag_medic_craft'),
        options = {}
    }

    for category, MenuData in pairs(MedicMenus) do
        table.insert(Menu.options, {
            title = category,
            event = 'fdb-medic:client:' .. category,
            arrow = true
        })
    end
    lib.registerContext(Menu)
    lib.showContext(Menu.id)
end)

RegisterNetEvent('fdb-medic:client:medicbagMenu', function()
    lib.registerContext({
        id = 'medicbag_menu',
        title = locale('cl_bag_medicbag_menu'),
        options = {
            {
                title = locale('cl_bag_medicbag_craftmenu_title'),
                description = locale('cl_bag_medicbag_craftmenu_desc'),
                icon = 'fa-solid fa-user-secret',
                event = 'fdb-medic:client:craftingmenu',
                arrow = true
            },
            {
                title = locale('cl_bag_medicbag_openstash_title'),
                description = locale('cl_bag_medicbag_openstash_desc'),
                icon = 'fa-solid fa-user',
                event = 'fdb-medic:client:bagstorage',
                arrow = true
            },
        }
    })
    lib.showContext('medicbag_menu')
end)

RegisterNetEvent('fdb-medic:client:checkingredients', function(data)
    FDBCore.Functions.TriggerCallback('fdb-medic:server:checkingredients', function(hasRequired)
    if (hasRequired) then
        if Config.Debug == true then
            print("passed")
        end
        TriggerEvent('fdb-medic:crafting', data.name, data.item, tonumber(data.crafttime), data.receive)
    else
        if Config.Debug == true then
            print("failed")
        end
        return
    end
    end, Config.medicbagRecipes[data.item].ingredients)
end)

RegisterNetEvent('fdb-medic:client:mediccraft', function(data)
    FDBCore.Functions.TriggerCallback('fdb-medic:server:checkingredients', function(hasRequired)
        if hasRequired == true then
            local ped = PlayerPedId()
            TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), data.crafttime, true, false, false, false)
            lib.progressBar({
                duration = tonumber(data.crafttime),
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disableControl = true,
                disable = {
                    move = true,
                    mouse = true,
                },
                label = locale('cl_bag_medicbag_craft_label').. FDBCore.Shared.Items[data.receive].label,
            })
            TriggerServerEvent('fdb-medic:server:finishcrafting', data)
            ClearPedTasks(ped)
        else
            lib.notify({ title = locale('cl_bag_medicbag_craft_notify'), type = 'inform', duration = 7000 })
        end
    end, data.ingredients)
end)

