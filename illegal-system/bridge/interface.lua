--[[
    Bridge.* é o ÚNICO ponto de contato entre o Crime Core e o framework
    (RSG-Core, FDB-Core, ou outro no futuro). Nada em server/*.lua ou
    client/*.lua deve chamar RSGCore.* ou FDBCore.* diretamente.

    Cada arquivo de bridge concreto (ex: rsg_bridge.lua) precisa
    implementar todas as funções abaixo. As que não forem implementadas
    mantêm o stub de erro, então um bridge incompleto falha alto e cedo
    em vez de falhar silenciosamente em produção.
]]

Bridge = {}

local function NotImplemented(name)
    return function(...)
        error(('[illegal-system] Bridge.%s não foi implementado pelo bridge carregado (Config.Framework = %s)')
            :format(name, tostring(Config.Framework)), 2)
    end
end

-- ── Jogador / economia ─────────────────────────────────────
Bridge.GetPlayer         = NotImplemented('GetPlayer')          -- (source) -> playerObject | nil
Bridge.GetIdentifier     = NotImplemented('GetIdentifier')      -- (source) -> citizenid/identifier string
Bridge.AddMoney          = NotImplemented('AddMoney')           -- (source, amount, reason) -> boolean
Bridge.RemoveMoney       = NotImplemented('RemoveMoney')        -- (source, amount, reason) -> boolean
Bridge.AddItem           = NotImplemented('AddItem')            -- (source, item, count, metadata) -> boolean
Bridge.HasItem           = NotImplemented('HasItem')            -- (source, item, count) -> boolean

-- ── Permissões (comandos admin) ────────────────────────────
Bridge.HasPermission     = NotImplemented('HasPermission')      -- (source, permission) -> boolean

-- ── Notificação / UI ───────────────────────────────────────
Bridge.Notify             = NotImplemented('Notify')            -- (source, message, type) -> nil

-- ── Interação no mundo (cliente) ───────────────────────────
Bridge.RegisterTargetEntity = NotImplemented('RegisterTargetEntity') -- (entity, options) -> nil
Bridge.RegisterGlobalPedTarget = NotImplemented('RegisterGlobalPedTarget') -- (options) -> nil
Bridge.GetInventoryImageURL = NotImplemented('GetInventoryImageURL') -- (item) -> string
