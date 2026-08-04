local FDBCore = exports['fdb-core']:GetCoreObject()

local function SanitizeConfig(tbl, visited)
    visited = visited or {}
    if visited[tbl] then return nil end
    visited[tbl] = true
    
    local newTbl = {}
    for k, v in pairs(tbl) do
        local typeV = type(v)
        if typeV == 'string' or typeV == 'number' or typeV == 'boolean' then
            newTbl[k] = v
        elseif typeV == 'table' then
            newTbl[k] = SanitizeConfig(v, visited)
        elseif typeV == 'vector3' or typeV == 'vector4' then
            -- Convert userdata vector to table for JSON serialization
            newTbl[k] = { x = v.x, y = v.y, z = v.z, w = v.w }
        end
        -- Functions, threads, userdata are ignored
    end
    return newTbl
end
RegisterCommand('configui', function(source, args, rawCommand)
    local src = source
    if not FDBCore.Functions.HasPermission(src, 'admin') then return end
    
    if #args < 1 then
        TriggerClientEvent('fdb-configui:client:openPanel', src, nil, nil, Config.SupportedScripts)
        return
    end
    
    local resource = args[1]
    if GetResourceState(resource) ~= 'started' then
        TriggerClientEvent('ox_lib:notify', src, {title = 'Erro', description = 'Resource não encontrado ou não iniciado.', type = 'error'})
        return
    end
    
    -- Busca as confs
    local status, config = pcall(function()
        return exports[resource]:GetRuntimeConfig()
    end)
    
    if not status then
        print("^1[fdb-configui] CMD Error fetching config for " .. resource .. ": " .. tostring(config) .. "^7")
        TriggerClientEvent('ox_lib:notify', src, {title = 'Erro', description = 'Resource alvo não suporta GetRuntimeConfig ou deu erro.', type = 'error'})
        return
    end
    
    if not config then
        print("^1[fdb-configui] CMD Config is nil for " .. resource .. "^7")
        TriggerClientEvent('ox_lib:notify', src, {title = 'Erro', description = 'Resource alvo retornou config vazia.', type = 'error'})
        return
    end

    TriggerClientEvent('fdb-configui:client:openPanel', src, resource, SanitizeConfig(config))
end, false)

lib.callback.register('fdb-configui:server:saveConfig', function(source, resource, path, value)
    if not FDBCore.Functions.HasPermission(source, 'admin') then return false end
    
    local status, result = pcall(function()
        return exports[resource]:SetRuntimeConfig(path, value)
    end)
    
    if not status or not result then
        return false
    end
    return true
end)

lib.callback.register('fdb-configui:server:resetConfig', function(source, resource)
    if not FDBCore.Functions.HasPermission(source, 'admin') then return false end
    
    local status, result = pcall(function()
        return exports[resource]:ResetRuntimeConfig()
    end)
    
    if not status or not result then
        return false
    end
    return true
end)

lib.callback.register('fdb-configui:server:fetchConfig', function(source, resource)
    if not FDBCore.Functions.HasPermission(source, 'admin') then return nil end
    
    if GetResourceState(resource) ~= 'started' then
        return nil
    end
    
    local status, config = pcall(function()
        return exports[resource]:GetRuntimeConfig()
    end)
    
    if not status then
        print("^1[fdb-configui] Error fetching config for " .. resource .. ": " .. tostring(config) .. "^7")
        return nil
    end
    
    if not config then
        print("^1[fdb-configui] Config is nil for " .. resource .. "^7")
        return nil
    end
    
    return SanitizeConfig(config)
end)
