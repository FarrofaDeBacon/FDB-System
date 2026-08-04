Config = {}
lib.locale()

-- Configurações Globais do Álcool
Config.Alcohol = {
    DrunkThreshold = 15,      -- Nível para começar a ficar tonto
    PassOutThreshold = 100,   -- Nível para desmaiar de bêbado
    DecreaseAmount = 1,       -- Quantidade que diminui por ciclo (1)
    DecreaseInterval = 45000,  -- Tempo do ciclo em ms (45 segundos) - efeito passa BEM mais devagar
    MaxAlcoholLevel = 150,    -- Limite máximo (não morre, mas passa mal)
    
    -- Efeitos
    VomitDuration = 10000,
    SleepDuration = 20000,
}

Config.Metabolism = {
    DrainInterval = 4000, -- Intervalo base em ms
    HungerDrain = 0.08,   -- Dreno por intervalo
    ThirstDrain = 0.12,   -- Dreno por intervalo
}

-- ==========================================
-- TAXAS DE DRENAGEM BÁSICAS (Por Tick de 4s)
-- ==========================================
Config.DrainRates = {
    TickRate = 4000,           -- Frequência do loop de sobrevivência em milissegundos
    Cleanliness = 0.1,         -- Higiene perdida por tick (clima limpo)
    Bladder = 0.2,             -- Aumento da vontade de urinar por tick
    BladderAccidentTime = 60,  -- Segundos segurando a bexiga em 100% antes de mijar nas calças
    
    -- Multiplicadores de Clima (aplicados sobre Cleanliness)
    WeatherMultipliers = {
        Rain = 2.0             -- Mais sujeira se estiver chovendo (GetRainLevel > 0.1)
    },
    
    -- Ganhos de sujeira/limpeza por evento imediato (não é decaimento passivo)
    HygieneEvents = {
        BloodDamage = 15.0,     -- Sujeira ganha ao tomar dano na vida (Sangue)
        FallMud = 10.0,         -- Sujeira ganha ao cair no chão/rolar (Lama)
        WashInWater = 25.0      -- Quantidade limpa por tick ao entrar na água
    }
}

-- ==========================================
-- DANOS CONTÍNUOS E DOENÇAS
-- ==========================================
Config.Hazards = {
    PoisonDamage = 2,          -- Dano à vida por tick se envenenado (piso 0)
    TemperatureDamage = 3,     -- Dano à vida por tick em clima extremo (piso 0)
    
    ExtremeColdThreshold = -2.0, -- Temperatura em Celsius para considerar muito frio
    ExtremeHeatThreshold = 37.0, -- Temperatura em Celsius para considerar muito calor

    -- Chance de contrair doença (Illness) no frio extremo
    IllnessChancePercent = 8,  -- 8% de chance a cada tick de frio
    IllnessGain = 10           -- Quanto de Illness ganha quando a chance acerta
}

-- ==========================================
-- EFEITOS BIOLÓGICOS (Doença e Veneno Avançados)
-- ==========================================
Config.Biological = {
    -- Níveis Críticos
    SymptomThreshold = 10,  -- Nível para começar sintomas leves (tosse e náusea visual)
    ModerateThreshold = 50, -- Nível a partir do qual perde sprint
    SevereThreshold = 80,   -- Nível a partir do qual perde run e os efeitos ficam agressivos

    -- Vômito (Veneno)
    VomitChanceModerate = 5,  -- 5% de chance por tick de 3s
    VomitChanceSevere = 15,   -- 15% de chance por tick de 3s
    VomitDuration = 7000,     -- Tempo preso na animação (ms)
    VomitCooldown = 5000,     -- Janela de imunidade após o vômito (ms)
    
    -- Dano Físico (HP Drain no Nível Severo)
    IllnessHPDrain = 1,       -- Dreno de HP por tick na doença severa
    PoisonHPDrain = 3         -- Dreno de HP por tick no veneno severo
}

-- ==========================================
-- EFEITOS DE BUFFS DE CONSUMÍVEIS
-- ==========================================
Config.Buffs = {
    ThermalDuration = 180      -- Duração padrão em segundos para proteção contra frio/calor (ex: hot_soup)
}

-- ==========================================
-- SISTEMA DE BEXIGA (MIJAR/XIXI)
-- ==========================================
Config.BladderSystem = {
    Enabled = true,                -- Se 'false', o jogador não terá necessidade de urinar
    LabelMale = "Mijar",           -- Termo do Target para homens
    LabelFemale = "Fazer Xixi"     -- Termo do Target para mulheres
}

-- ==========================================
-- CONFIGURAÇÕES DE INTERAÇÃO (TARGET)
-- ==========================================
Config.PeeModels = {
    -- Árvores
    `p_tree_pine01x`,
    `p_tree_pine02x`,
    `p_tree_pine03x`,
    `p_tree_pine04x`,
    `p_tree_pine05x`,
    `p_tree_pine06x`,
    `p_tree_oak01x`,
    `p_tree_oak02x`,
    `p_tree_oak03x`,
    `p_tree_birch01x`,
    `p_tree_birch02x`,
    `p_tree_birch03x`,
    `p_tree_birch04x`,
    `p_tree_cypress01x`,
    `p_tree_palm01x`,
    -- Fossas (Outhouses)
    `p_outhouse01x`,
    `p_outhouse02x`,
    `p_privy01x`,
    `p_privy02x`,
    `p_toilet01x`,
    `p_toilet02x`,
    `p_cs_outhouse01x`
}
