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

    ['store_robbery'] = {
        label            = 'Assalto a Loja',
        category         = 'roubo',
        difficulty       = 3,
        xp               = 30,
        heat             = 20,
        cooldown         = 3600,
        requiredItem     = 'lockpick', -- Para a noite
        reactions = {
            comply = 60,
            fight = 20,
            flee = 20,
        },
        loot = {
            common = { 'cannedbeans', 'apple', 'bread' },
            uncommon = { 'ammo_revolver', 'cigar' },
            rare = { 'goldnugget', 'pocketwatch' }
        },
        burglary = {
            enabled = true,
            dog = {
                enabled = true,
                chance = 40,
                barkDuration = 15,
            },
            witness = {
                enabled = true,
                chanceAfterDog = 30,
                notifyLawman = true,
                alertRadius = 300.0,
                showMapBlip = true,
                coordsJitter = 80.0,
                alertText = "Latidos estranhos foram reportados perto de uma loja...",
            },
            armedNpc = {
                enabled = true,
                onlyIfNoCopsOnline = true,
                delayAfterDog = { min = 20, max = 40 },
                catchChance = 50,
            },
            caughtOutcome = {
                knockoutChance = 60,
                knockout = { enabled = true, damage = 0 },
                jail = { enabled = false, minutes = 10 },
            },
        }
    },

    ['store_burglary'] = {
        label            = 'Arrombamento de Loja',
        category         = 'roubo',
        difficulty       = 2,
        xp               = 15,
        heat             = 10,
        cooldown         = 300, -- 5 minutos de cooldown por jogador (apenas para evitar spam do minigame)
        requiredItem     = 'lockpick',
        minigame = {
            door = { duration = 8.0, zones = { common = {start=20,["end"]=40} } },
            register = { duration = 5.0, zones = { common = {start=30,["end"]=50} } }
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
        cooldown         = 1,           -- 1 SEGUNDO (PARA TESTES!)
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

    door_lockpick = {
        name             = 'Arrombamento de Porta',
        xp               = 10,          -- XP ganho ao arrombar
        heat             = 5,           -- Nível de Heat gerado
        witnessChance    = 15.0,        -- 15% de chance de gerar testemunha
        evidenceChance   = 20.0,        -- 20% de chance de deixar evidência
        cooldown         = 0,           -- Cooldown de 0s (Doorlock já cuida de fechar a porta etc)
        requiredItem     = 'lockpick',
    },
}

-- ─────────────────────────────────────────────────────────
-- Configurações Específicas: Roubo de Túmulo
-- ─────────────────────────────────────────────────────────
Config.GraveRespawn = {
    -- 'restart' = O túmulo volta a ficar disponível toda vez que reiniciar o servidor/script
    -- 'persistent' = Salva no banco de dados, e só volta após X dias do jogo
    mode = 'persistent', 
    
    -- Opções válidas apenas se o mode for 'persistent'
    minDays = 3, -- Mínimo de dias in-game para o túmulo voltar
    maxDays = 7, -- Máximo de dias in-game para o túmulo voltar
    minutesPerIngameDay = 48 -- Quantos minutos da vida real dura um dia no seu servidor
}

Config.StoreRobberyRespawn = {
    mode = 'persistent', 
    minDays = 1, -- Mínimo de dias in-game para a registradora voltar a ter dinheiro
    maxDays = 3, -- Máximo de dias in-game para a registradora voltar a ter dinheiro
    minutesPerIngameDay = 48
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
    Models = {
        'mp005_p_dirtpile_tall_unburied',
        'p_coffin02x'
    },
    OffsetForward = 0.6,
    OffsetZ = -1.0
}

Config.GraveModels = {
    -2146427795,
    'p_gravestone01ax', 'p_gravestone01x', 'p_gravestone02x', 'p_gravestone03ax', 'p_gravestone03x',
    'p_gravestone04x', 'p_gravestone05x', 'p_gravestone06x', 'p_gravestone07ax', 'p_gravestone07x',
    'p_gravestone08ax', 'p_gravestone08x', 'p_gravestone09x', 'p_gravestone10x', 'p_gravestone11x',
    'p_gravestone12x', 'p_gravestone13x', 'p_gravestone14ax', 'p_gravestone14x', 'p_gravestone15x',
    'p_gravestone16ax', 'p_gravestone16x', 'p_gravestonebroken01x', 'p_gravestonebroken02x',
    'p_gravestonebroken05x', 'p_gravestone_srd08x', 'p_gravestoneclean01x', 'p_gravestoneclean02ax',
    'p_gravestoneclean02x', 'p_gravestoneclean03x', 'p_gravestoneclean04ax', 'p_gravestoneclean04x',
    'p_gravestoneclean05ax', 'p_gravestoneclean05x', 'p_gravestoneclean06ax', 'p_gravestoneclean06x',
    'p_gravestonegunslinger01x', 'p_gravestonejanedoe01x', 'p_gravestonejanedoe02x',
    'p_gravestonejohndoe01x', 'p_gravestonejohndoe02x', 'p_grvestne_v_01x', 'p_grvestne_v_02x',
    'p_grvestne_v_03x', 'p_grvestne_v_04x', 'p_grvestne_v_05x', 'p_grvestne_v_06x', 'p_grvestne_v_07x',
    'p_gravemarker01x', 'p_gravemarker02x', 'p_graveplaque01x', 'p_gravemound01x', 'p_gravemound02x',
    'p_gravemound03x', 'p_gravemound04x', 'p_gravefresh01x', 'p_graveindian01x', 'p_grave06x',
    'p_gravefather01x', 'p_gravemother01x', 'p_williegrave01x', 'p_gravedug03x', 'p_gravedug06x',
    'p_gravediggingopen2x', 'p_gravedugcover01x', 'p_gravedugcover02x', 'p_massgrave01x',
    'p_massgrave02x', 'p_massgrave03x', 'p_arthur_grave_b', 'p_arthur_grave_g', 'p_davey_grave',
    'p_hosea_grave', 'p_jenny_grave', 'p_kieran_grave', 'p_lenny_grave', 'p_sean_grave',
    'p_susans_grave', 'p_eagle_grave', 'p_dea_01_grave_04', 'p_dea_01_grave_07', 'p_dea_grave_03',
    'p_dea_grave_05', 'p_dea_grave_06', 'p_dea_grave_08', 'p_dea_grave_09', 'dea_01_grave_010',
    'dea_01_grave_011', 'dea_01_grave_012', 'mp008_p_mp_gravemarker01x', 'sfe2_dis_defacedgrave_01',
    'sfe2_dis_defacedgrave_02', 'sfe2_dis_defacedgrave_slod', 'sfe2_dis_defgrave_02_deb',
    'wat_ext_grave', 'wat_ext_grave_lod'
}




Config.Stores = {
    -- Zonas de lojas onde os NPCs podem ser assaltados
    {
        name = "Valentine General Store",
        coords = vec3(-322.25, 804.05, 117.93),
        radius = 20.0,
        doorCoords = vec3(-319.70, 796.53, 116.94), -- Coordenada da porta principal (MERCADO) no wasvendel
        registerCoords = vec3(-323.5, 804.5, 117.93),
        fleeCoords = vec3(-318.0, 808.0, 117.9),
        openHour = 6,
        closeHour = 22,
        registerCash = { min = 15, max = 45 }
    },
    {
        name = "Valentine Gunsmith",
        coords = vec3(-278.43, 775.12, 119.52),
        radius = 20.0,
        doorCoords = vec3(-276.5, 774.5, 119.52),
        registerCoords = vec3(-280.1812, 778.8729, 119.5040),
        registerHeading = 301.1332,
        openHour = 6,
        closeHour = 22,
        registerCash = { min = 30, max = 80 }
    },
    {
        name = "Valentine Doctor",
        coords = vec3(-245.92, 781.08, 118.47),
        radius = 20.0,
        doorCoords = vec3(-247.5, 781.5, 118.47),
        registerCoords = vec3(-288.2099, 805.1098, 119.3859),
        registerHeading = 358.5668,
        openHour = 6,
        closeHour = 22,
        registerCash = { min = 20, max = 60 }
    },
    {
        name = "Rhodes General Store",
        coords = vec3(1329.80, -1294.37, 77.02),
        radius = 20.0,
        doorCoords = vec3(1328.0, -1293.0, 77.02), -- Coordenadas aproximadas (Ajustar no jogo)
        registerCoords = vec3(1329.80, -1294.37, 77.02), -- Coordenadas aproximadas (Ajustar no jogo)
        registerHeading = 60.0,
        openHour = 6,
        closeHour = 22,
        registerCash = { min = 25, max = 70 }
    }
}
