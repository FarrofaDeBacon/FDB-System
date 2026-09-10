-- fdb-medic/client/configui_sync.lua

RegisterNetEvent('fdb-medic:client:syncConfig')
AddEventHandler('fdb-medic:client:syncConfig', function(newConfig)
    -- Atualiza a tabela Config global
    Config = newConfig
end)

-- Listener para o tema da HUD via fdb-configui
RegisterNetEvent('fdb-configui:client:configChanged')
AddEventHandler('fdb-configui:client:configChanged', function(path, value)
    if path == 'hud.theme' then
        SendNUIMessage({
            action = 'setTheme',
            theme = value
        })
    end
end)

-- Buscar tema inicial no login/spawn
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded')
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    if GetResourceState('fdb-configui') == 'started' then
        pcall(function()
            lib.callback('fdb-configui:server:getGlobalConfig', false, function(globalConfig)
                if globalConfig and globalConfig.hud and globalConfig.hud.theme then
                    SendNUIMessage({
                        action = 'setTheme',
                        theme = globalConfig.hud.theme
                    })
                end
            end)
        end)
    end
end)
