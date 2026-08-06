fdb = fdb or {}
fdb.component = fdb.component or {}

-- Atualizar ped variation e textura nativa do RedM
function fdb.component.RefreshPed(ped)
    ped = ped or PlayerPedId()
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true) -- SetActiveMetaPedComponentsUpdated
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) -- UpdatePedVariation
    Citizen.InvokeNative(0x704C908E9C405136, ped) -- buffer check
end

-- Esperar o ped carregar/renderizar
function fdb.component.WaitPedLoaded(ped)
    ped = ped or PlayerPedId()
    local attempts = 0
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) and attempts < 100 do -- IsPedReadyToRender
        attempts = attempts + 1
        Wait(10)
    end
end

-- Aplicar uma roupa/componente específico ao ped
function fdb.component.Apply(ped, category, hash, isMp)
    ped = ped or PlayerPedId()
    if type(hash) == "string" then hash = GetHashKey(hash) end
    if isMp == nil then isMp = true end
    
    local categoryHash = fdb.component.getCategoryHash(category)

    -- Aplica o shop item
    if hash and hash ~= 0 then
        Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, hash, false, isMp, false) -- ApplyShopItemToPed
    end
    
    fdb.component.RefreshPed(ped)
    fdb.component.WaitPedLoaded(ped)
end

-- Remover uma categoria de roupa do ped
function fdb.component.Remove(ped, category)
    ped = ped or PlayerPedId()
    local categoryHash = fdb.component.getCategoryHash(category)
    Citizen.InvokeNative(0x0D7181955D372CE1, ped, categoryHash, 0) -- RemoveTagFromMetaPed
    fdb.component.RefreshPed(ped)
end

-- Ajustar características faciais (Face Features) - Valores de -1.0 a 1.0
function fdb.component.SetFaceFeature(ped, index, value)
    ped = ped or PlayerPedId()
    local floatValue = (value or 0.0) * 1.0
    floatValue = math.max(-1.0, math.min(1.0, floatValue))
    Citizen.InvokeNative(0xE74D7AA96489BC4D, ped, index, floatValue) -- SetCharExpression (SetPedFaceFeature)
    fdb.component.RefreshPed(ped)
end

-- Aplicar sobreposições (Overlays: Cabelo, Barba, Maquiagem, Cicatrizes)
-- @param overlayId: Índice do overlay (0 a 16)
-- @param textureId: ID da textura/albedo
-- @param opacity: Transparência (0.0 a 1.0)
-- @param tint0, tint1, tint2: Índices de cores da paleta
function fdb.component.SetOverlay(ped, overlayId, textureId, opacity, tint0, tint1, tint2)
    ped = ped or PlayerPedId()
    opacity = math.max(0.0, math.min(1.0, opacity or 1.0))
    tint0 = tint0 or 0
    tint1 = tint1 or 0
    tint2 = tint2 or 0

    -- Aplica o overlay nativo do RedM
    Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, overlayId, textureId, opacity, tint0, tint1, tint2)
    fdb.component.RefreshPed(ped)
end

-- Exportações para outros recursos
exports('RefreshPed', fdb.component.RefreshPed)
exports('WaitPedLoaded', fdb.component.WaitPedLoaded)
exports('ApplyComponent', fdb.component.Apply)
exports('RemoveComponent', fdb.component.Remove)
exports('SetFaceFeature', fdb.component.SetFaceFeature)
exports('SetOverlay', fdb.component.SetOverlay)

-- RETROCOMPATIBILIDADE COM JO_LIBS
if not jo then jo = {} end
jo.component.apply = fdb.component.Apply
jo.component.remove = fdb.component.Remove
jo.component.refreshPed = fdb.component.RefreshPed
jo.component.waitPedLoaded = fdb.component.WaitPedLoaded
