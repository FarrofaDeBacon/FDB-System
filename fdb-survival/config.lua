Config = {}
lib.locale()

-- ConfiguraÃƒÂ§ÃƒÂµes Globais do ÃƒÂlcool
Config.Alcohol = {
    DrunkThreshold = 15,      -- NÃƒÂ­vel para comeÃƒÂ§ar a ficar tonto
    PassOutThreshold = 100,   -- NÃƒÂ­vel para desmaiar de bÃƒÂªbado
    DecreaseAmount = 1,       -- Quantidade que diminui por ciclo (1)
    DecreaseInterval = 45000,  -- Tempo do ciclo em ms (45 segundos) - efeito passa BEM mais devagar
    MaxAlcoholLevel = 150,    -- Limite mÃƒÂ¡ximo (nÃƒÂ£o morre, mas passa mal)
    
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
-- TAXAS DE DRENAGEM BÃƒÂSICAS (Por Tick de 4s)
-- ==========================================
Config.DrainRates = {
    TickRate = 4000,           -- FrequÃƒÂªncia do loop de sobrevivÃƒÂªncia em milissegundos
    Cleanliness = 0.1,         -- Higiene perdida por tick (clima limpo)
    Bladder = 0.2,             -- Aumento da vontade de urinar por tick
    BladderAccidentTime = 60,  -- Segundos segurando a bexiga em 100% antes de mijar nas calÃƒÂ§as
    
    -- Multiplicadores de Clima (aplicados sobre Cleanliness)
    WeatherMultipliers = {
        Rain = 2.0             -- Mais sujeira se estiver chovendo (GetRainLevel > 0.1)
    },
    
    -- Ganhos de sujeira/limpeza por evento imediato (nÃƒÂ£o ÃƒÂ© decaimento passivo)
    HygieneEvents = {
        BloodDamage = 15.0,     -- Sujeira ganha ao tomar dano na vida (Sangue)
        FallMud = 10.0,         -- Sujeira ganha ao cair no chÃƒÂ£o/rolar (Lama)
        WashInWater = 25.0      -- Quantidade limpa por tick ao entrar na ÃƒÂ¡gua
    }
}

-- ==========================================
-- DANOS CONTÃƒÂNUOS E DOENÃƒâ€¡AS
-- ==========================================
Config.Hazards = {
    PoisonDamage = 2,          -- Dano ÃƒÂ  vida por tick se envenenado (piso 0)
    TemperatureDamage = 3,     -- Dano ÃƒÂ  vida por tick em clima extremo (piso 0)
    
    ExtremeColdThreshold = -2.0, -- Temperatura em Celsius para considerar muito frio
    ExtremeHeatThreshold = 37.0, -- Temperatura em Celsius para considerar muito calor

    -- Chance de contrair doenÃƒÂ§a (Illness) no frio extremo
    IllnessChancePercent = 8,  -- 8% de chance a cada tick de frio
    IllnessGain = 10           -- Quanto de Illness ganha quando a chance acerta
}

-- ==========================================
-- EFEITOS BIOLÃƒâ€œGICOS (DoenÃƒÂ§a e Veneno AvanÃƒÂ§ados)
-- ==========================================
Config.Biological = {
    -- NÃƒÂ­veis CrÃƒÂ­ticos
    SymptomThreshold = 10,  -- NÃƒÂ­vel para comeÃƒÂ§ar sintomas leves (tosse e nÃƒÂ¡usea visual)
    ModerateThreshold = 50, -- NÃƒÂ­vel a partir do qual perde sprint
    SevereThreshold = 80,   -- NÃƒÂ­vel a partir do qual perde run e os efeitos ficam agressivos

    -- VÃƒÂ´mito (Veneno)
    VomitChanceModerate = 5,  -- 5% de chance por tick de 3s
    VomitChanceSevere = 15,   -- 15% de chance por tick de 3s
    VomitDuration = 7000,     -- Tempo preso na animaÃƒÂ§ÃƒÂ£o (ms)
    VomitCooldown = 5000,     -- Janela de imunidade apÃƒÂ³s o vÃƒÂ´mito (ms)
    
    -- Dano FÃƒÂ­sico (HP Drain no NÃƒÂ­vel Severo)
    IllnessHPDrain = 1,       -- Dreno de HP por tick na doenÃƒÂ§a severa
    PoisonHPDrain = 3         -- Dreno de HP por tick no veneno severo
}

-- ==========================================
-- EFEITOS DE BUFFS DE CONSUMÃƒÂVEIS
-- ==========================================
Config.Buffs = {
    ThermalDuration = 180      -- DuraÃƒÂ§ÃƒÂ£o padrÃƒÂ£o em segundos para proteÃƒÂ§ÃƒÂ£o contra frio/calor (ex: hot_soup)
}

-- ==========================================
-- SISTEMA DE BEXIGA (MIJAR/XIXI)
-- ==========================================
Config.BladderSystem = {
    Enabled = true,                -- Se 'false', o jogador nÃ£o terÃ¡ necessidade de urinar
    LabelMale = "Mijar",           -- Termo do Target para homens
    LabelFemale = "Fazer Xixi",    -- Termo do Target para mulheres
    
    -- AnimaÃ§Ãµes e Tempos (Mijar VoluntÃ¡rio)
    UseScenario = true,            -- Se true, usa AnimationName como cenÃ¡rio. Se false, usa AnimationDict e AnimationName como TaskPlayAnim.
    AnimationDict = "amb_misc@world_human_pee@male_a@idle_b",
    AnimationName = "WORLD_HUMAN_PEE",
    ParticleDict = "core",
    ParticleName = "ent_anim_dog_peeing",
    AnimWaitBefore = 4000,         -- Tempo antes de comeÃ§ar o jato (ms)
    AnimDuration = 6000,           -- Tempo do jato (ms)
    AnimWaitAfter = 3500,          -- Tempo guardando antes de destravar o personagem (ms)
    
    -- AnimaÃ§Ã£o de Acidente (Mijar nas calÃ§as)
    AccidentUseScenario = true,    -- Se true, usa AccidentAnimation como cenÃ¡rio.
    AccidentAnimDict = "amb_misc@world_human_vomit@male_a@idle_b",
    AccidentAnimation = "WORLD_HUMAN_VOMIT",
    AccidentAnimDuration = 4000,   -- Tempo preso na animaÃ§Ã£o do acidente (ms)
    
    -- Etiqueta / RP
    PrivacyRadius = 15.0,          -- DistÃ¢ncia (em metros) para verificar se hÃ¡ mulheres perto
    
    -- Controle por Cidades (Bloquear o uso do target em Ã¡rvores dentro dessas cidades)
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
        `p_outhouse01x`, `p_outhouse02x`, `p_privy01x`, `p_privy02x`, `p_toilet01x`, `p_toilet02x`, `p_cs_outhouse01x`, 1029309300
    }
}

-- ==========================================
-- ANIMAÃ‡Ã•ES DE MOVIMENTO (WALK STYLES)
-- ==========================================
Config.Movement = {
    -- NÃ­veis de Ãlcool
    DrunkLevel3 = 80, 
    DrunkClipset3 = 'move_m@drunk@verydrunk',
    
    DrunkLevel2 = 50,
    DrunkClipset2 = 'move_m@drunk@moderatedrunk',
    
    DrunkLevel1 = 15,
    DrunkClipset1 = 'move_m@drunk@a',
    
    -- Bexiga Aperta
    BladderThreshold = 80,
    BladderClipset = 'war_veteran',
    
    -- DoenÃ§a e Veneno
    PoisonModerateClipset = 'move_m@drunk@moderatedrunk',
    IllnessSevereClipset = 'move_m@fatigue',
    IllnessModerateClipset = 'move_m@drunk@slightlydrunk',
    
    -- Lama
    MudClipset = 'move_m@mud_wade'
}
