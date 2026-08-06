fdb = fdb or {}
fdb.blip = {}

local Blips = {}

-- Criar um novo blip no mapa
function fdb.blip.Create(locationOrEntity, name, sprite, blipHash, color)
    if not blipHash then blipHash = 1664425300 end
    if type(sprite) == "string" then sprite = GetHashKey(sprite) end

    local blip
    if type(locationOrEntity) == "number" then
        if not DoesEntityExist(locationOrEntity) then
            return false
        end
        blip = BlipAddForEntity(blipHash, locationOrEntity)
    else
        blip = BlipAddForCoords(blipHash, locationOrEntity.x, locationOrEntity.y, locationOrEntity.z)
    end

    SetBlipSprite(blip, sprite)
    SetBlipName(blip, name)
    if color then
        local colorHash = type(color) == "string" and GetHashKey(color) or color
        BlipAddModifier(blip, colorHash)
    end

    table.insert(Blips, blip)
    return blip
end

-- Remover um blip específico
function fdb.blip.Remove(blip)
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
        for i, b in ipairs(Blips) do
            if b == blip then
                table.remove(Blips, i)
                break
            end
        end
    end
end

-- Limpar todos os blips criados quando o recurso parar
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, blip in ipairs(Blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
end)

-- Exportações para outros resources
exports('CreateBlip', fdb.blip.Create)
exports('RemoveBlip', fdb.blip.Remove)
