-- fdb-propeditor/server/main.lua

lib.callback.register('fdb-propeditor:server:CheckPermission', function(source)
    -- Ace permission required to use the prop editor
    if IsPlayerAceAllowed(source, 'command.propedit') then
        return true
    end
    
    -- If not allowed, we can notify the server console if needed, but returning false is enough.
    return false
end)
