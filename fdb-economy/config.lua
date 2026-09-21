-- ============================================================
-- FDB System | fdb-economy | config.lua
-- Regional Economy Engine Configuration
-- ============================================================

Config = {}

-- ==========================================
-- GENERAL SETTINGS
-- ==========================================

-- Método de detecção de região
-- 'native'  → Usa GetNameOfZone() do RDR3, mapeado para regionId via Config.RegionZones
-- 'polygon' → Usa polígonos customizados desenhados no fdb-mapmenu (futuro)
Config.RegionDetection = 'native'

-- Intervalo de recálculo da inflação regional (em minutos)
Config.RecalcIntervalMinutes = 30

-- Taxa base padrão (1.0 = preço original, sem inflação)
Config.DefaultBaseRate = 1.0

-- Limites mínimo e máximo da taxa regional (trava contra explosão/deflação)
Config.DefaultMinRate = 0.5
Config.DefaultMaxRate = 2.0

-- Quanto a taxa tende ao baseline por ciclo de recálculo (0.0 = sem decay, 1.0 = reset total)
Config.DecayTowardBaseline = 0.05

-- Pesos para o cálculo de inflação
Config.VolumeWeight = 0.3        -- Quanto o volume de transações influencia a taxa
Config.MoneySupplyWeight = 0.2   -- Quanto a massa monetária influencia a taxa (futuro)

-- ==========================================
-- MAPEAMENTO DE REGIÕES (modo 'native')
-- ==========================================
-- Cada região agrupa múltiplas zonas nativas do RDR3.
-- GetNameOfZone() retorna o nome interno da zona (ex: "VALENTINE").
-- Esta tabela mapeia essas zonas para um regionId único.

Config.RegionZones = {
    new_hanover = {
        'VALENTINE', 'VAL', 'EMERALD', 'HEARTLANDS', 'HEARTL',
        'CUMBERLAND', 'CUMBER', 'ROANOKE', 'ROANOK',
        'HANOVER', 'CALIBAN', 'ELYSIAN',
    },
    lemoyne = {
        'RHODES', 'SAINTDENIS', 'STDENI', 'BAYOU', 'BAYOUNWA',
        'BLUEWATER', 'BLUEWAT', 'BRAITHWAITE', 'BRAITH',
        'CALIGA', 'CLEMENS', 'DEWBERRY', 'LAGRAS', 'SHANN',
    },
    west_elizabeth = {
        'BLACKWATER', 'BLCKWT', 'STRAWBERRY', 'STRAWB',
        'BIGVALLEY', 'BIGVAL', 'TALLTREES', 'TALLTR',
        'OWANJILA', 'AURORA', 'BEECHER', 'MONTO', 'QUAKER',
    },
    ambarino = {
        'COLTER', 'GRIZZLIES', 'GRIZZ', 'WAPITI',
        'DAKOTA', 'CUMBER', 'WINDOW', 'SPIDER',
        'TEMPER', 'BARROW', 'CAIRN', 'DONNER',
    },
    new_austin = {
        'TUMBLEWEED', 'TUMBLE', 'ARMADILLO', 'ARMADI',
        'MACFARLANES', 'MACFAR', 'GAPTOOTH', 'GAPTOO',
        'CHOLLA', 'HENNIGAN', 'MERCER', 'PLAINVIEW', 'RIDGEWOOD',
        'RILEY', 'SILENTST', 'BENEDICT', 'THIEVE',
    },
}

-- ==========================================
-- MODIFICADORES POR CATEGORIA DE ITEM
-- ==========================================
-- Cada categoria tem um multiplicador sobre o baseRate da região.
-- Categorias são strings livres — o admin pode criar quantas quiser.
-- Itens sem categoria usam multiplicador 1.0.

Config.CategoryModifiers = {
    weapons    = 1.2,    -- Armas são 20% mais caras que o base
    ammo       = 1.1,    -- Munição 10% acima
    food       = 0.9,    -- Comida 10% abaixo (abundante)
    drink      = 0.85,   -- Bebidas 15% abaixo
    medicine   = 1.15,   -- Medicina 15% acima (rara)
    materials  = 1.0,    -- Materiais no preço base
    tools      = 1.05,   -- Ferramentas 5% acima
    luxury     = 1.5,    -- Luxo 50% acima
    clothing   = 1.1,    -- Roupas 10% acima
    crafting   = 1.0,    -- Itens de craft no base
}

-- ==========================================
-- CONFIGURAÇÕES AVANÇADAS
-- ==========================================

-- Número mínimo de transações para que o volume comece a influenciar o recálculo
Config.MinTransactionsForVolume = 10

-- Máximo de registros de transação mantidos na tabela (limpeza automática de histórico antigo)
Config.MaxTransactionHistoryDays = 30

-- Debug: Imprime no console detalhes de cada recálculo
Config.Debug = false
