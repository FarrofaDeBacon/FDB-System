--[[
    Metade client-side do bridge RSG. Separado de rsg_bridge.lua porque
    aquele é server_script e este precisa ser client_script (ver fxmanifest).

    Bridge.RegisterTargetEntity ainda não está implementado de verdade —
    depende de qual sistema de target o servidor do cliente usa
    (ox_target, rsg-target, etc.). Ver ROADMAP.md > "Pendências de decisão".
]]

if Config.Framework ~= 'rsg' then return end

function Bridge.RegisterTargetEntity(entity, options)
    exports.ox_target:addLocalEntity(entity, options)
end

function Bridge.RegisterGlobalPedTarget(options)
    exports.ox_target:addGlobalPed(options)
end

function Bridge.GetInventoryImageURL(item)
    return 'nui://rsg-inventory/html/images/' .. item .. '.png'
end
