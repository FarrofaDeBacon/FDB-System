local FDBCore = exports['fdb-core']:GetCoreObject()

RegisterServerEvent('fdb-animations:server:Open')
AddEventHandler('fdb-animations:server:Open', function()
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM favorites_animations WHERE citizenid = @citizenid;', {['@citizenid'] = citizenid}, function(result)
        if not result[1] then
            MySQL.Async.execute('INSERT INTO favorites_animations (citizenid) VALUES (@citizenid);', { ['@citizenid'] = citizenid })
        end

        TriggerClientEvent('fdb-animations:client:Open', src, result[1] and json.decode(result[1].favorites) or {})
    end)
end)

RegisterServerEvent('fdb-animations:server:Favorite')
AddEventHandler('fdb-animations:server:Favorite', function(Animation, Favorite)
    local src = source
    local Player = FDBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM favorites_animations WHERE citizenid = @citizenid;', {['@citizenid'] = citizenid}, function(result)
        if result[1] then
            local favorites = json.decode(result[1].favorites)

            local InTable = false

            for i, v in pairs(favorites) do
                if not Favorite and v == Animation.Label then
                    InTable = true
                    table.remove(favorites, i)
                    break
                end
            end

            if Favorite and not InTable then
                table.insert(favorites, Animation.Label)
            end

            MySQL.update('UPDATE favorites_animations SET favorites = @favorites WHERE citizenid = @citizenid;', { ['@favorites'] = json.encode(favorites), ['@citizenid'] = citizenid })
        end
    end)
end)