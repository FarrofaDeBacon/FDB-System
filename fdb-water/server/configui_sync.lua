-- fdb-water/server/configui_sync.lua
local FDBCore = exports['fdb-core']:GetCoreObject()

-- Export para o fdb-configui pegar a configuração atual
exports('GetRuntimeConfig', function()
    return Config
end)

-- Export para o fdb-configui salvar uma modificação
exports('SetRuntimeConfig', function(path, value)
    -- Quebra o caminho (ex: "WoundSystem.debugging.enabled") em uma tabela para acessar a chave final
    local keys = {}
    for key in string.gmatch(path, "([^%.]+)") do
        table.insert(keys, key)
    end
    
    local current = Config
    for i = 1, #keys - 1 do
        if not current[keys[i]] then
            current[keys[i]] = {}
        end
        current = current[keys[i]]
    end
    
    -- Atualiza o valor local
    current[keys[#keys]] = value
    
    -- Envia a nova configuração para todos os clientes
    TriggerClientEvent('fdb-water:client:syncConfig', -1, Config)
    
    print("^2[fdb-water] Configuração '"..path.."' alterada via ConfigUI para: "..tostring(value).."^7")
    return true
end)

-- Export para o fdb-configui resetar as configurações (Não suportado nativamente sem ler o arquivo de novo)
exports('ResetRuntimeConfig', function()
    -- Idealmente, carregaríamos o arquivo config.lua novamente aqui, 
    -- mas para simplificar, o admin pode dar restart no script.
    return false
end)
