-- ============================================================
-- FDB System | fdb-libs | client/noisebar/noisebar.lua (NOVO ARQUIVO)
-- Barra de barulho genérica — mostra, atualiza valor 0-100, esconde.
-- Não sabe nada sobre cachorro, loja, ou o que acontece quando estoura.
-- Isso é responsabilidade de quem chama (illegal-system, futuramente
-- outros crimes de stealth como a Etapa 4 de roubo de casas).
-- ============================================================

fdb = fdb or {}
fdb.noisebar = {}

local active = false

--- Mostra a barra na tela, vazia.
function fdb.noisebar.Show(config)
    SendNUIMessage({
        action = "showRiskBar",
        config = config or {}
    })
end

--- Atualiza o valor da barra.
--- @param value number 0-100
function fdb.noisebar.Update(value)
    SendNUIMessage({
        action = "updateRiskBar",
        value = value
    })
end

--- Esconde a barra.
function fdb.noisebar.Hide()
    SendNUIMessage({
        action = "hideRiskBar"
    })
end

exports('ShowRiskBar', fdb.noisebar.Show)
exports('UpdateRiskBar', fdb.noisebar.Update)
exports('HideRiskBar', fdb.noisebar.Hide)
