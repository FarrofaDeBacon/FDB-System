-- ============================================================
-- fdb-consume | exports.lua
-- Export GetPropEditData para o fdb-propeditor (Fase 4.2)
-- Retorna os dados necessários para o editor de prop de um item
-- ============================================================

exports('GetPropEditData', function(itemName)
    local itemData = Config.Items[itemName]
    if not itemData then return nil end

    -- Retorna apenas os campos que o editor precisa
    return {
        prop    = itemData.prop,
        offsets = itemData.offsets,
        -- Stages customizados por tipo de item (opcional)
        -- Se nil, o fdb-propeditor usa o fallback padrão de fumo
        stages  = itemData.editorStages or nil,
    }
end)

exports('GetEditableItems', function()
    local list = {}
    for k, v in pairs(Config.Items) do
        if v.prop then
            table.insert(list, k)
        end
    end
    table.sort(list)
    return list
end)
