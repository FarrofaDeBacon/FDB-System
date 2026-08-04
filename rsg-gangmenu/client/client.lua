local FDBCore = exports['fdb-core']:GetCoreObject()

local PlayerGang = FDBCore.Functions.GetPlayerData().gang
local isFromCommand = false  -- Variable to track the menu's origin

lib.locale()

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerGang = FDBCore.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('FDBCore:Client:OnPlayerLoaded', function()
    PlayerGang = FDBCore.Functions.GetPlayerData().gang
end)

local function comma_valueGang(amount)
    local formatted = amount
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

-------------------------------------------------------------------------------------------
-- prompts and blips if needed
-------------------------------------------------------------------------------------------
local gangBlips = {}

local function CreateGangBlips()
    -- Verfiy if PlayerGang exist
    if not PlayerGang or not PlayerGang.name then
        return 
    end

    -- Delete old blips
    for _, blip in pairs(gangBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    gangBlips = {}

    -- Create new blips
    for _, v in pairs(Config.GangLocations) do
        if v.showblip == true then
            -- If blipforall = true, show to everyone
            -- If blipforall = false, show only to gang members
            if v.blipforall == true or (PlayerGang.name and PlayerGang.name == v.id) then
                local GangMenuBlip = BlipAddForCoords(1664425300, v.coords)
                SetBlipSprite(GangMenuBlip, joaat(Config.Blip.blipSprite), true)
                SetBlipScale(GangMenuBlip, Config.Blip.blipScale)
                SetBlipName(GangMenuBlip, v.blipname)  -- Use the gang’s custom name
                gangBlips[#gangBlips + 1] = GangMenuBlip
            end
        end
    end
end

CreateThread(function()
    for _, v in pairs(Config.GangLocations) do
        exports['fdb-core']:createPrompt(v.id, v.coords, FDBCore.Shared.Keybinds[Config.Keybind], locale('cl_open').. ' ' ..v.name, {
            type = 'client',
            event = 'fdb-gangmenu:client:mainmenu',
            args = {},
        })
    end
    
    CreateGangBlips()
end)

-- Update blips when the player loads
RegisterNetEvent('FDBCore:Client:OnPlayerLoaded', function()
    PlayerGang = FDBCore.Functions.GetPlayerData().gang
    Wait(1000)
    CreateGangBlips()
end)

-- Update blips when the gang changes
RegisterNetEvent('FDBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerGang = GangInfo
    CreateGangBlips()
end)

-------------------------------------------------------------------------------------------
-- main menu
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:mainmenu', function()
    if not PlayerGang.name or not PlayerGang.isboss then return end
    isFromCommand = false  -- Reset because we came from the blip
    lib.registerContext({
        id = 'gang_mainmenu',
        title = locale('cl_1'),
        options = {
            {
                title = locale('cl_2'),
                description = locale('cl_3'),
                icon = 'fa-solid fa-list',
                event = 'fdb-gangmenu:client:employeelist',
                arrow = true
            },
            {
                title = locale('cl_4'),
                description = locale('cl_5'),
                icon = 'fa-solid fa-hand-holding',
                event = 'fdb-gangmenu:client:HireMenu',
                arrow = true
            },
            {
                title = locale('cl_6'),
                description = locale('cl_7'),
                icon = 'fa-solid fa-box-open',
                event = 'fdb-gangmenu:client:Stash',
                arrow = true
            },
            {
                title = locale('cl_8'),
                description = locale('cl_9'),
                icon = 'fa-solid fa-sack-dollar',
                event = 'fdb-gangmenu:client:SocietyMenu',
                arrow = true
            },
        }
    })
    lib.showContext('gang_mainmenu')
end)

-------------------------------------------------------------------------------------------
-- employee menu
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:employeelist', function()
    FDBCore.Functions.TriggerCallback('fdb-gangmenu:server:GetEmployees', function(result)
        local options = {}
        for _, v in pairs(result) do
            options[#options + 1] = {
                title = v.name,
                description = v.grade.name,
                icon = 'fa-solid fa-circle-user',
                event = 'fdb-gangmenu:client:ManageEmployee',
                args = { player = v, work = PlayerGang },
                arrow = true,
            }
        end
        lib.registerContext({
            id = 'employeelist_menu',
            title = locale('cl_10'),
            menu = isFromCommand and 'gang_commandmenu' or 'gang_mainmenu',  -- Changes depending on the origin
            onBack = function() end,
            position = 'top-right',
            options = options
        })
        lib.showContext('employeelist_menu')
    end, PlayerGang.name)
end)

-------------------------------------------------------------------------------------------
-- manage employees
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:ManageEmployee', function(data)
    local options = {}
    for k, v in pairs(FDBCore.Shared.Gangs[data.work.name].grades) do
        options[#options + 1] = {
            title = locale('cl_11').. ' ' ..v.name,
            description = locale('cl_12').. ': ' .. k,
            icon = 'fa-solid fa-file-pen',
            serverEvent = 'fdb-gangmenu:server:GradeUpdate',
            args = { cid = data.player.empSource, grade = tonumber(k), gradename = v.name }
        }
    end
    options[#options + 1] = {
        title = locale('cl_13'),
        icon = 'fa-solid fa-user-large-slash',
        serverEvent = 'fdb-gangmenu:server:FireMember',
        args = data.player.empSource,
        iconColor = 'red'
    }
    lib.registerContext({
        id = 'managemembers_menu',
        title = locale('cl_14'),
        menu = 'employeelist_menu',
        onBack = function() end,
        position = 'top-right',
        options = options
    })
    lib.showContext('managemembers_menu')
end)

-------------------------------------------------------------------------------------------
-- hire employees
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:HireMenu', function()
    FDBCore.Functions.TriggerCallback('fdb-gangmenu:getplayers', function(players)
        local options = {}
        for _, v in pairs(players) do
            if v and v ~= PlayerId() then
                options[#options + 1] = {
                    title = v.name,
                    description = locale('cl_15').. ': ' .. v.citizenid .. ' - '.. locale('cl_16') .. ': '.. v.sourceplayer,
                    icon = 'fa-solid fa-user-check',
                    serverEvent = 'fdb-gangmenu:server:HireMember',
                    args = v.sourceplayer,
                    arrow = true
                }
            end
        end
        lib.registerContext({
            id = 'hiremembers_menu',
            title = locale('cl_4'),
            menu = isFromCommand and 'gang_commandmenu' or 'gang_mainmenu',  -- Changes depending on the origin
            onBack = function() end,
            position = 'top-right',
            options = options
        })
        lib.showContext('hiremembers_menu')
    end)
end)

-------------------------------------------------------------------------------------------
-- boss stash
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:Stash', function()
    local stashname = 'gang_' .. PlayerGang.name
    TriggerServerEvent('fdb-gangmenu:server:openinventory', stashname)
end)

-------------------------------------------------------------------------------------------
-- society menu
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:SocietyMenu', function()
    local currentmoney = FDBCore.Functions.GetPlayerData().money['cash']
    FDBCore.Functions.TriggerCallback('fdb-gangmenu:server:GetAccount', function(cb)
        lib.registerContext({
            id = 'gangsociety_menu',
            menu = 'gang_mainmenu',
            title = locale('cl_17').. ': $ ' .. comma_valueGang(cb),
            options = {
                {
                    title = locale('cl_18'),
                    description = locale('cl_19'),
                    icon = 'fa-solid fa-money-bill-transfer',
                    event = 'fdb-gangmenu:client:SocetyDeposit',
                    args = currentmoney,
                    iconColor = 'green',
                    arrow = true
                },
                {
                    title = locale('cl_20'),
                    description = locale('cl_21'),
                    icon = 'fa-solid fa-money-bill-transfer',
                    event = 'fdb-gangmenu:client:SocetyWithDraw',
                    args = comma_valueGang(cb),
                    iconColor = 'red',
                    arrow = true
                },
            }
        })
        lib.showContext('gangsociety_menu')
    end, PlayerGang.name)
end)

-------------------------------------------------------------------------------------------
-- society deposit
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:SocetyDeposit', function(money)
    local input = lib.inputDialog(locale('cl_22').. ': $ ' .. money, {
        {
            label = locale('cl_23'),
            type = 'number',
            required = true,
            icon = 'fa-solid fa-dollar-sign'
        },
    })
    if not input then return end
    TriggerServerEvent('fdb-gangmenu:server:depositMoney', tonumber(input[1]))
end)

-------------------------------------------------------------------------------------------
-- society withdraw
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:SocetyWithDraw', function(money)
    local input = lib.inputDialog(locale('cl_22').. ': $ ' .. money, {
        {
            label = locale('cl_23'),
            type = 'number',
            required = true,
            icon = 'fa-solid fa-dollar-sign'
        },
    })
    if not input then return end
    TriggerServerEvent('fdb-gangmenu:server:withdrawMoney', tonumber(input[1]))
end)

-------------------------------------------------------------------------------------------
-- command menu
-------------------------------------------------------------------------------------------
RegisterNetEvent('fdb-gangmenu:client:commandmenu', function()
    if not PlayerGang.name or not PlayerGang.isboss then return end
    isFromCommand = true  -- Mark that we came from the command
    lib.registerContext({
        id = 'gang_commandmenu',
        title = locale('cl_1'),
        options = {
            {
                title = locale('cl_2'),
                description = locale('cl_3'),
                icon = 'fa-solid fa-list',
                event = 'fdb-gangmenu:client:employeelist',
                arrow = true
            },
            {
                title = locale('cl_4'),
                description = locale('cl_5'),
                icon = 'fa-solid fa-hand-holding',
                event = 'fdb-gangmenu:client:HireMenu',
                arrow = true
            },
        }
    })
    lib.showContext('gang_commandmenu')
end)

-------------------------------------------------------------------------------------------
-- gangmenu command
-------------------------------------------------------------------------------------------
RegisterCommand('gangmenu', function()
    if not PlayerGang.name or not PlayerGang.isboss then
        lib.notify({
            title = locale('cl_1'),
            description = locale('cl_cmd_error'),
            type = 'error',
            duration = 5000
        })
        return
    end
    TriggerEvent('fdb-gangmenu:client:commandmenu')
end, false)
