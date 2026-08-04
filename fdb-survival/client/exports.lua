-- ============================================================
-- fdb-survival | client/exports.lua
-- Export GetPropEditData para o fdb-propeditor (FASE 4.3)
-- fdb-survival não possui itens com prop ainda — assinatura
-- pronta para quando forem adicionados no futuro.
-- ============================================================

exports('GetPropEditData', function(itemName)
    -- Nenhum item de prop definido no fdb-survival ainda.
    -- Quando itens com prop forem adicionados, popule aqui
    -- seguindo o mesmo contrato do fdb-consume:
    --   return { prop = '...', offsets = {...}, stages = {...} }
    return nil
end)

exports('GetEditableItems', function()
    -- fdb-survival ainda não possui itens editáveis
    return {}
end)
