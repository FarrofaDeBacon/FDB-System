-- Add or change (a) method(s) in the FDBCore.Functions table
local function SetMethod(methodName, handler)
    if type(methodName) ~= 'string' then
        return false, 'invalid_method_name'
    end

    FDBCore.Functions[methodName] = handler

    TriggerEvent('FDBCore:Server:UpdateObject')

    return true, 'success'
end

FDBCore.Functions.SetMethod = SetMethod
exports('SetMethod', SetMethod)

-- Add or change (a) field(s) in the FDBCore table
local function SetField(fieldName, data)
    if type(fieldName) ~= 'string' then
        return false, 'invalid_field_name'
    end

    FDBCore[fieldName] = data

    TriggerEvent('FDBCore:Server:UpdateObject')

    return true, 'success'
end

FDBCore.Functions.SetField = SetField
exports('SetField', SetField)

-- Single add job function which should only be used if you planning on adding a single job
local function AddJob(jobName, job)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if FDBCore.Shared.Jobs[jobName] then
        return false, 'job_exists'
    end

    FDBCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
local function AddJobs(jobs)
    local shouldContinue = true
    local message = 'success'
    local errorItem = nil

    for key, value in pairs(jobs) do
        if type(key) ~= 'string' then
            message = 'invalid_job_name'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        if FDBCore.Shared.Jobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        FDBCore.Shared.Jobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('FDBCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, message, nil
end

FDBCore.Functions.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
local function RemoveJob(jobName)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if not FDBCore.Shared.Jobs[jobName] then
        return false, 'job_not_exists'
    end

    FDBCore.Shared.Jobs[jobName] = nil

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
local function UpdateJob(jobName, job)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if not FDBCore.Shared.Jobs[jobName] then
        return false, 'job_not_exists'
    end

    FDBCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

-- Single add item
local function AddItem(itemName, item)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if FDBCore.Shared.Items[itemName] then
        return false, 'item_exists'
    end

    FDBCore.Shared.Items[itemName] = item

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
local function UpdateItem(itemName, item)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end
    if not FDBCore.Shared.Items[itemName] then
        return false, 'item_not_exists'
    end
    FDBCore.Shared.Items[itemName] = item
    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
local function AddItems(items)
    local shouldContinue = true
    local message = 'success'
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= 'string' then
            message = 'invalid_item_name'
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if FDBCore.Shared.Items[key] then
            message = 'item_exists'
            shouldContinue = false
            errorItem = items[key]
            break
        end

        FDBCore.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('FDBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, message, nil
end

FDBCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
local function RemoveItem(itemName)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if not FDBCore.Shared.Items[itemName] then
        return false, 'item_not_exists'
    end

    FDBCore.Shared.Items[itemName] = nil

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
local function AddGang(gangName, gang)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if FDBCore.Shared.Gangs[gangName] then
        return false, 'gang_exists'
    end

    FDBCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
local function AddGangs(gangs)
    local shouldContinue = true
    local message = 'success'
    local errorItem = nil

    for key, value in pairs(gangs) do
        if type(key) ~= 'string' then
            message = 'invalid_gang_name'
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        if FDBCore.Shared.Gangs[key] then
            message = 'gang_exists'
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        FDBCore.Shared.Gangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('FDBCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, message, nil
end

FDBCore.Functions.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
local function RemoveGang(gangName)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if not FDBCore.Shared.Gangs[gangName] then
        return false, 'gang_not_exists'
    end

    FDBCore.Shared.Gangs[gangName] = nil

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
local function UpdateGang(gangName, gang)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if not FDBCore.Shared.Gangs[gangName] then
        return false, 'gang_not_exists'
    end

    FDBCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('FDBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('FDBCore:Server:UpdateObject')
    return true, 'success'
end

FDBCore.Functions.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

local resourceName = GetCurrentResourceName()
local function GetCoreVersion(InvokingResource)
    local resourceVersion = GetResourceMetadata(resourceName, 'version')
    if InvokingResource and InvokingResource ~= '' then
        print(('%s called fdbcore version check: %s'):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

FDBCore.Functions.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        name,
        FDBCore.Functions.GetIdentifier(playerId, 'license'),
        FDBCore.Functions.GetIdentifier(playerId, 'discord'),
        FDBCore.Functions.GetIdentifier(playerId, 'ip'),
        origin,
        2147483647,
        'Anti Cheat'
    })
    DropPlayer(playerId, Lang:t('info.exploit_banned', { discord = FDBCore.Config.Server.Discord }))
    TriggerEvent('fdb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'red', name .. ' has been banned for exploiting ' .. origin, true)
end

exports('ExploitBan', ExploitBan)
