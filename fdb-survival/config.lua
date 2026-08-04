Config = {}
lib.locale()

-- ConfiguraÃ§Ãµes Globais do Ãlcool
Config.Alcohol = {
    DrunkThreshold = 15,      -- NÃ­vel para comeÃ§ar a ficar tonto
    PassOutThreshold = 100,   -- NÃ­vel para desmaiar de bÃªbado
    DecreaseAmount = 1,       -- Quantidade que diminui por ciclo (1)
    DecreaseInterval = 45000,  -- Tempo do ciclo em ms (45 segundos) - efeito passa BEM mais devagar
    MaxAlcoholLevel = 150,    -- Limite mÃ¡ximo (nÃ£o morre, mas passa mal)
    
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
-- TAXAS DE DRENAGEM BÃSICAS (Por Tick de 4s)
-- ==========================================
Config.DrainRates = {
    TickRate = 4000,           -- FrequÃªncia do loop de sobrevivÃªncia em milissegundos
    Cleanliness = 0.1,         -- Higiene perdida por tick (clima limpo)
    Bladder = 0.2,             -- Aumento da vontade de urinar por tick
    BladderAccidentTime = 60,  -- Segundos segurando a bexiga em 100% antes de mijar nas calÃ§as
    
    -- Multiplicadores de Clima (aplicados sobre Cleanliness)
    WeatherMultipliers = {
        Rain = 2.0             -- Mais sujeira se estiver chovendo (GetRainLevel > 0.1)
    },
    
    -- Ganhos de sujeira/limpeza por evento imediato (nÃ£o Ã© decaimento passivo)
    HygieneEvents = {
        BloodDamage = 15.0,     -- Sujeira ganha ao tomar dano na vida (Sangue)
        FallMud = 10.0,         -- Sujeira ganha ao cair no chÃ£o/rolar (Lama)
        WashInWater = 25.0      -- Quantidade limpa por tick ao entrar na Ã¡gua
    }
}

-- ==========================================
-- DANOS CONTÃNUOS E DOENÃ‡AS
-- ==========================================
Config.Hazards = {
    PoisonDamage = 2,          -- Dano Ã  vida por tick se envenenado (piso 0)
    TemperatureDamage = 3,     -- Dano Ã  vida por tick em clima extremo (piso 0)
    
    ExtremeColdThreshold = -2.0, -- Temperatura em Celsius para considerar muito frio
    ExtremeHeatThreshold = 37.0, -- Temperatura em Celsius para considerar muito calor

    -- Chance de contrair doenÃ§a (Illness) no frio extremo
    IllnessChancePercent = 8,  -- 8% de chance a cada tick de frio
    IllnessGain = 10           -- Quanto de Illness ganha quando a chance acerta
}

-- ==========================================
-- EFEITOS BIOLÃ“GICOS (DoenÃ§a e Veneno AvanÃ§ados)
-- ==========================================
Config.Biological = {
    -- NÃ­veis CrÃ­ticos
    SymptomThreshold = 10,  -- NÃ­vel para comeÃ§ar sintomas leves (tosse e nÃ¡usea visual)
    ModerateThreshold = 50, -- NÃ­vel a partir do qual perde sprint
    SevereThreshold = 80,   -- NÃ­vel a partir do qual perde run e os efeitos ficam agressivos

    -- VÃ´mito (Veneno)
    VomitChanceModerate = 5,  -- 5% de chance por tick de 3s
    VomitChanceSevere = 15,   -- 15% de chance por tick de 3s
    VomitDuration = 7000,     -- Tempo preso na animaÃ§Ã£o (ms)
    VomitCooldown = 5000,     -- Janela de imunidade apÃ³s o vÃ´mito (ms)
    
    -- Dano FÃ­sico (HP Drain no NÃ­vel Severo)
    IllnessHPDrain = 1,       -- Dreno de HP por tick na doenÃ§a severa
    PoisonHPDrain = 3         -- Dreno de HP por tick no veneno severo
}

-- ==========================================
-- EFEITOS DE BUFFS DE CONSUMÃVEIS
-- ==========================================
Config.Buffs = {
    ThermalDuration = 180      -- DuraÃ§Ã£o padrÃ£o em segundos para proteÃ§Ã£o contra frio/calor (ex: hot_soup)
}

-- ==========================================
-- SISTEMA DE BEXIGA (MIJAR/XIXI)
-- ==========================================
Config.BladderSystem = {
    Enabled = true,                -- Se 'false', o jogador não terá necessidade de urinar
    LabelMale = "Mijar",           -- Termo do Target para homens
    LabelFemale = "Fazer Xixi",    -- Termo do Target para mulheres
    
    -- Animações e Tempos (Mijar Voluntário)
    UseScenario = true,            -- Se true, usa AnimationName como cenário. Se false, usa AnimationDict e AnimationName como TaskPlayAnim.
    AnimationDict = "amb_misc@world_human_pee@male_a@idle_b",
    AnimationName = "WORLD_HUMAN_PEE",
    ParticleDict = "core",
    ParticleName = "ent_anim_dog_peeing",
    AnimWaitBefore = 4000,         -- Tempo antes de começar o jato (ms)
    AnimDuration = 6000,           -- Tempo do jato (ms)
    AnimWaitAfter = 3500,          -- Tempo guardando antes de destravar o personagem (ms)
    
    -- Animação de Acidente (Mijar nas calças)
    AccidentUseScenario = true,    -- Se true, usa AccidentAnimation como cenário.
    AccidentAnimDict = "amb_misc@world_human_vomit@male_a@idle_b",
    AccidentAnimation = "WORLD_HUMAN_VOMIT",
    AccidentAnimDuration = 4000,   -- Tempo preso na animação do acidente (ms)
    
    -- Etiqueta / RP
    PrivacyRadius = 15.0,          -- Distância (em metros) para verificar se há mulheres perto
    
    -- Controle por Cidades (Bloquear o uso do target em árvores dentro dessas cidades)
    BlockedTowns = {
        [joaat('stdenis')] = true,
        [joaat('blackwater')] = true,
        [joaat('valentine')] = true,
        [joaat('rhodes')] = true,
        [joaat('strawberry')] = true,
    },

    -- Modelos permitidos para o sistema
    TreeModels = {
        `p_tree_pine01x`, `p_tree_pine02x`, `p_tree_pine03x`, `p_tree_pine04x`, `p_tree_pine05x`, `p_tree_pine06x`,
        `p_tree_oak01x`, `p_tree_oak02x`, `p_tree_oak03x`, `p_tree_birch01x`, `p_tree_birch02x`, `p_tree_birch03x`,
        `p_tree_birch04x`, `p_tree_cypress01x`, `p_tree_palm01x`
    },
    
    OuthouseModels = {
        `p_outhouse01x`, `p_outhouse02x`, `p_privy01x`, `p_privy02x`, `p_toilet01x`, `p_toilet02x`, `p_cs_outhouse01x`
    }
}

-- ==========================================
-- ANIMAÇÕES DE MOVIMENTO (WALK STYLES)
-- ==========================================
Config.Movement = {
    -- Níveis de Álcool
    DrunkLevel3 = 80, 
    DrunkClipset3 = 'move_m@drunk@verydrunk',
    
    DrunkLevel2 = 50,
    DrunkClipset2 = 'move_m@drunk@moderatedrunk',
    
    DrunkLevel1 = 15,
    DrunkClipset1 = 'move_m@drunk@a',
    
    -- Bexiga Aperta
    BladderThreshold = 80,
    BladderClipset = 'war_veteran',
    
    -- Doença e Veneno
    PoisonModerateClipset = 'move_m@drunk@moderatedrunk',
    IllnessSevereClipset = 'move_m@fatigue',
    IllnessModerateClipset = 'move_m@drunk@slightlydrunk',
    
    -- Lama
    MudClipset = 'move_m@mud_wade'
}
