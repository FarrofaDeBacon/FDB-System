Config = {}

-- ─────────────────────────────────────────────────────────
-- Framework alvo. O bridge carregado no fxmanifest precisa
-- corresponder a isso (rsg_bridge.lua ⇄ 'rsg').
-- ─────────────────────────────────────────────────────────
Config.Framework = 'fdb'

-- ─────────────────────────────────────────────────────────
-- Heat: decai com o tempo, independente de XP/Reputação.
-- ─────────────────────────────────────────────────────────
Config.Heat = {
    decayAmount   = 1,      -- quanto cai por tick
    decayInterval = 60000,  -- a cada quantos ms (60s)
    max           = 100,
}

-- ─────────────────────────────────────────────────────────
-- Progressão de nível criminal (XP acumulado -> nível)
-- ─────────────────────────────────────────────────────────
Config.CriminalLevels = {
    { level = 1, xp = 0 },
    { level = 2, xp = 250 },
    { level = 3, xp = 750 },
    { level = 4, xp = 1500 },
    { level = 5, xp = 3000 },
    { level = 6, xp = 6000 },
    { level = 7, xp = 10000 },
}

-- ─────────────────────────────────────────────────────────
-- Configuração de Imagens (Inventário)
-- ─────────────────────────────────────────────────────────
-- Defina de onde a UI deve carregar as imagens.
-- Ex: 'nui://fdb-inventory/html/images/' ou 'nui://rsg-inventory/html/images/'
Config.InventoryURL = 'nui://rsg-inventory/html/images/'

-- ─────────────────────────────────────────────────────────
-- Catálogo de crimes. Cada entrada = 1 crime, sem precisar
-- de código novo no Core pra existir.
-- ─────────────────────────────────────────────────────────
Config.Crimes = {

    ['npc_robbery'] = {
        label            = 'Roubo de NPC',
        category         = 'furto',
        difficulty       = 1,           -- 1 = fácil .. 5 = extremo
        xp               = 15,
        heat             = 5,
        witnessChance    = 25,          -- % de gerar testemunha
        evidenceChance   = 10,          -- % de gerar evidência
        cooldown         = 5 * 60,      -- segundos (por jogador)
        
        -- Configuração de Loot para o Minigame
        -- common (Branco): fácil de acertar
        -- uncommon (Amarelo): médio
        -- rare (Azul): difícil
        loot = {
            common   = { 'water', 'lockpick', 'bandage' },
            uncommon = { 'phone', 'rolex' },
            rare     = { 'goldbar', 'weapon_pistol' }
        },
    },

    -- próximos crimes entram aqui como novas entradas,
    -- sem tocar em server/core.lua
}
