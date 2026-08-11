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
        
        minigame = {
            type = 'tierbar',
            duration = 5.0,
            zones = {
                common   = { start = 10, ["end"] = 35 },
                uncommon = { start = 50, ["end"] = 65 },
                rare     = { start = 80, ["end"] = 88 },
            }
        }
    },

    ['grave_robbery'] = {
        label            = 'Roubo de Túmulo',
        category         = 'roubo',
        difficulty       = 2,           -- 1 = fácil .. 5 = extremo
        xp               = 25,
        heat             = 10,
        witnessChance    = 15,          -- % de gerar testemunha
        evidenceChance   = 20,          -- % de gerar evidência
        cooldown         = 10 * 60,     -- segundos (por jogador)
        requiredItem     = 'shovel',

        loot = {
            common   = { 'coin_half_penny', 'coin_penny_1787', 'cigar' },
            uncommon = { 'silver_ring', 'necklace_pearl_rou', 'tooth_gold', 'pocket_watch_silver' },
            rare     = { 'diamond', 'ruby', 'gold_bar', 'necklace_ancient', 'robbery_ledger' }
        },
        
        minigame = {
            type = 'tierbar',
            duration = 6.0,
            zones = {
                common   = { start = 15, ["end"] = 35 },
                uncommon = { start = 50, ["end"] = 65 },
                rare     = { start = 80, ["end"] = 88 },
            }
        }
    },
}

-- ─────────────────────────────────────────────────────────
-- Configurações Específicas: Roubo de Túmulo
-- ─────────────────────────────────────────────────────────
Config.GraveRespawn = {
    mode = 'ingame_days',   -- ou 'restart'
    minDays = 5,
    maxDays = 9,
    minutesPerIngameDay = 48,
}

Config.Digging = {
    ShovelModel = 'p_shovel02x',
    AnimDict = 'amb_work@world_human_gravedig@working@male_b@base',
    AnimName = 'base',
    AttachBone = 'SKEL_R_Hand',
    AttachOffset = { x = 0.0, y = -0.19, z = -0.089 },
    AttachRotation = { x = 274.19, y = 483.89, z = 378.40 }
}

Config.DirtPile = {
    Model = 'mp005_p_dirtpile_tall_unburied',
    OffsetForward = 0.6,
    OffsetZ = -1.0
}

Config.GraveModels = {
    'p_gravestone01ax', 'p_gravestone01bx', 'p_gravestone01cx', 'p_gravestone01x',
    'p_gravestone02ax', 'p_gravestone02bx', 'p_gravestone02cx', 'p_gravestone02x',
    'p_gravestone03ax', 'p_gravestone03bx', 'p_gravestone03cx', 'p_gravestone03dx', 'p_gravestone03ex',
    'p_gravestone03x', 'p_gravestone04x', 'p_gravestone05x', 'p_gravestone06x', 'p_gravestone07x',
    'p_gravestone08x', 'p_gravestone09x', 'p_gravestone10x', 'p_gravestone11x', 'p_gravestone12x',
    'p_gravestone13x', 'p_gravestone14x', 'p_gravestone15x', 'p_gravestone16x', 'p_gravestone17x',
    'p_gravestone18x', 'p_gravestone19x', 'p_gravestone20x', 'p_gravestone21x', 'p_gravestone22x',
    'p_gravestone_anim01x', 'p_gravestone_anim02x', 'p_gravestone_anim03x', 'p_gravestone_anim04x',
    'p_gravestone_anim05x', 'p_gravestone_anim06x', 'p_gravestone_anim07x', 'p_gravestone_anim08x',
    'p_gravestone_anim09x', 'p_gravestone_anim10x', 'p_gravestone_broken01x', 'p_gravestone_broken02x',
    'p_gravestone_broken03x', 'p_gravestone_broken04x', 'p_gravestone_broken05x', 'p_gravestone_broken06x',
    'p_gravestone_broken07x', 'p_gravestone_broken08x', 'p_gravestone_broken09x', 'p_gravestone_broken10x',
    'p_gravestone_broken11x', 'p_gravestone_broken12x', 'p_gravestone_broken13x', 'p_gravestone_broken14x',
    'p_gravestone_broken15x', 'p_gravestone_broken16x', 'p_gravestone_broken17x', 'p_gravestone_broken18x',
    'p_gravestone_broken19x', 'p_gravestone_clean01x', 'p_gravestone_clean02x', 'p_gravestone_clean03x',
    'p_gravestone_clean04x', 'p_gravestone_clean05x', 'p_gravestone_clean06x', 'p_gravestone_clean07x',
    'p_gravestone_de01x', 'p_gravestone_driftwood01x', 'p_gravestone_eb01x', 'p_gravestone_endless01x',
    'p_gravestone_endless02x', 'p_gravestone_flat01x', 'p_gravestone_flat02x', 'p_gravestone_flat03x',
    'p_gravestone_iron01x', 'p_gravestone_iron02x', 'p_gravestone_iron03x', 'p_gravestone_iron04x',
    'p_gravestone_iron05x', 'p_gravestone_iron06x', 'p_gravestone_iron07x', 'p_gravestone_iron08x',
    'p_gravestone_ironcross01x', 'p_gravestone_ironcross02x', 'p_gravestone_log01x', 'p_gravestone_obelisk01x',
    'p_gravestone_obelisk02x', 'p_gravestone_obelisk03x', 'p_gravestone_obelisk04x', 'p_gravestone_rock01x',
    'p_gravestone_rock02x', 'p_gravestone_rock03x', 'p_gravestone_rock04x', 'p_gravestone_rock05x',
    'p_gravestone_rock06x', 'p_gravestone_rock07x', 'p_gravestone_rock08x', 'p_gravestone_rock09x',
    'p_gravestone_rock10x', 'p_gravestone_rock11x', 'p_gravestone_rock12x', 'p_gravestone_rock13x',
    'p_gravestone_rock14x', 'p_gravestone_rock15x', 'p_gravestone_rock16x', 'p_gravestone_rock17x',
    'p_gravestone_statue01x', 'p_gravestone_tree01x', 'p_gravestone_vault01x', 'p_gravestone_vault02x',
    'p_gravestone_vault03x', 'p_gravestone_vault04x', 'p_gravestone_vault05x', 'p_gravestone_vault06x',
    'p_gravestone_wall01x', 'p_gravestone_wood01x', 'p_gravestone_wood02x', 'p_gravestone_wood03x',
    'p_gravestone_wood04x', 'p_gravestone_wood05x', 'p_gravestone_wood06x', 'p_gravestone_wood07x',
    'p_gravestone_wood08x', 'p_gravestone_wood09x', 'p_gravestone_wood10x', 'p_gravestone_wood11x',
    'p_gravestone_wood12x', 'p_gravestone_wood13x', 'p_gravestone_woodcross01x', 'p_gravestone_woodcross02x',
    'p_gravestone_woodcross03x', 'p_gravestone_woodcross04x', 'p_gravestone_woodcross05x', 'p_gravestone_woodcross06x',
    'p_gravestone_woodcross07x', 'p_gravestone_woodcross08x', 'p_gravestone_woodcross09x', 'p_gravestone_woodcross10x',
    'p_gravestone_woodcross11x', 'p_gravestone_woodcross12x', 'p_grave_mound_a', 'p_grave_mound_b',
    'p_arthur_grave_b', 'p_arthur_grave_h', 'p_davey_grave', 'p_eagleflies_grave', 'p_hosea_grave', 'p_john_grave',
    'p_kieran_grave', 'p_lenny_grave', 'p_mac_grave', 'p_sean_grave', 'p_susan_grave', 'p_uncle_grave'
}
