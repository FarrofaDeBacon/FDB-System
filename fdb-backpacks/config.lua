Config = {}

Config.Backpacks = {
    -- ==========================================
    -- MOCHILAS AJUSTÁVEIS (PROPS FÍSICOS)
    -- ==========================================
    ['backpack_large'] = {
        model = 'p_ambpack01x',
        weight = 40000, -- 40 Kg Capacity (can trigger all weight tiers)
        pos = vector3(-0.5, 0.0, 0.08),
        rot = vector3(-80.0, 0.0, -90.0),
        boneIndex = 278, -- CP_Back
        slots = 25
    },
    ['backpack_medium'] = {
        model = 'p_ambpack02x',
        weight = 25000,  -- 25 Kg Capacity (can trigger walk reduction and sprint disable)
        pos = vector3(-0.3, -0.0, 0.08),
        rot = vector3(-80.0, 0.0, -90.0),
        boneIndex = 278, -- CP_Back
        slots = 20
    },
    ['backpack_small'] = {
        model = 'p_ambpack05x',
        weight = 15000,  -- 15 Kg Capacity (can trigger walk reduction)
        pos = vector3(-0.5, 0.0, 0.08),
        rot = vector3(-80.0, 0.0, -90.0),
        boneIndex = 278, -- CP_Back
        slots = 15
    },
    ['backpack_tiny'] = {
        model = 'p_ambpack04x',
        weight = 7500,  -- 7.5 Kg Capacity
        pos = vector3(-0.2, -0.1, 0.10),
        rot = vector3(14, 0.0, -90.0),
        boneIndex = 278, -- CP_Back
        slots = 10
    },

    -- ==========================================
    -- BOLSAS DE ROUPA (SATCHELS AUTO-AJUSTÁVEIS)
    -- ==========================================
    ['satchel_large'] = {
        isClothing = true,
        model = 'p_cs_satchel01x', -- Modelo físico para quando jogada no chão
        hashMale = 2105864149, -- CLOTHING_ITEM_M_SATCHEL_001 (Arthur/John Satchel Variant 1)
        hashFemale = 1109685657, -- CLOTHING_ITEM_F_SATCHEL_001 (Harriet/Travelling Satchel Variant 1)
        weight = 40000, -- 40 Kg Capacity
        slots = 25
    },
    ['satchel_medium'] = {
        isClothing = true,
        model = 'p_cs_satchel01x', -- Modelo físico para quando jogada no chão
        hashMale = 3997825462, -- CLOTHING_ITEM_M_SATCHEL_001 Variant 2
        hashFemale = 4239336475, -- CLOTHING_ITEM_F_SATCHEL_001 Variant 2
        weight = 25000,  -- 25 Kg Capacity
        slots = 20
    },
    ['satchel_small'] = {
        isClothing = true,
        model = 'p_cs_satchel01x', -- Modelo físico para quando jogada no chão
        hashMale = 3928436241, -- CLOTHING_ITEM_M_SATCHEL_001 Variant 3
        hashFemale = 2116878699, -- CLOTHING_ITEM_F_SATCHEL_001 Variant 3
        weight = 15000,  -- 15 Kg Capacity
        slots = 15
    },
    ['doctor_bag'] = {
        model = 'p_bag01x', -- Bolsa de couro clássica com fivelas
        weight = 20000, -- 20 Kg Capacity
        pos = vector3(0.08, 0.08, 0.05),
        rot = vector3(-90.0, 0.0, 0.0),
        boneIndex = 58271, -- SKEL_L_Hand (Mão Esquerda) - Carrega na mão!
        slots = 18
    },
    ['satchel_charles'] = {
        isClothing = true,
        model = 'p_cs_satchel01x', -- Modelo no chão
        customClothing = {
            male = { drawable = -1401534050, albedo = -413276042, normal = -2000311781, material = -1184798602, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_javier'] = {
        isClothing = true,
        model = 'p_cs_satchel01x', -- Modelo no chão
        customClothing = {
            male = { drawable = 353817708, albedo = -1818127823, normal = -1253617636, material = -1918234145, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -2142348542, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_hosea'] = {
        isClothing = true,
        model = 'p_cs_satchel01x', -- Modelo no chão
        customClothing = {
            male = { drawable = -708993245, albedo = 740800891, normal = 175726555, material = -1397604117, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -131629850, albedo = -736639503, normal = 2118603501, material = 769453092, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    }
,
    ['satchel_outlaw_mpvictim'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -881138760, albedo = 1728737902, normal = -1816187623, material = 242383984, palette = 1669565057, tint0 = 249, tint1 = 249, tint2 = 249 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_rivalcollector'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -881138760, albedo = 1728737902, normal = -1816187623, material = 242383984, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 39 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_treasurehunter'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -881138760, albedo = 1211427027, normal = -1829198372, material = 99307252, palette = -783849117, tint0 = 22, tint1 = 23, tint2 = 127 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_brynntildon'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1453381784, albedo = 522236442, normal = 658498176, material = -250799738, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_cassidy'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1063780442, albedo = 1180348351, normal = 1825435565, material = -714213065, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_grizzledjon'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 550356489, albedo = -1604711837, normal = 928197659, material = 467476255, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_grizzledjon_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 813194112, albedo = -695602874, normal = 1833283607, material = -1769434927, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_jamie'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -484637270, albedo = 1926033332, normal = -755416013, material = -1370228650, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_johnthebaptisingmadman'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 844526326, albedo = -1027216318, normal = 712659917, material = -873166343, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_mp_lee'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -939524227, albedo = 863598418, normal = -341485465, material = 487490502, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_poisonwellshaman'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -679899648, albedo = 1348763889, normal = -530005630, material = -1357819096, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_theodorelevin'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1711155523, albedo = -2026160547, normal = -1565513962, material = 667407912, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_uncle'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -617145166, albedo = -1912391041, normal = 738027152, material = -270697732, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_warvet'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 347796123, albedo = 940229876, normal = -968036858, material = -894435211, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_uniinbred'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -487098466, albedo = -1277552488, normal = -522426287, material = -1678176270, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_kid_recipient'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -487098466, albedo = -174804622, normal = -522426287, material = -90012972, palette = -783849117, tint0 = 1, tint1 = 1, tint2 = 6 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_owlhootfamily'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -487098466, albedo = -174804622, normal = 72277359, material = -90012972, palette = -183908539, tint0 = 0, tint1 = 16, tint2 = 25 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_unicriminals'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -487098466, albedo = -174804622, normal = 615314919, material = -90012972, palette = 399232131, tint0 = 245, tint1 = 243, tint2 = 245 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_bynsurvivalist'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -487098466, albedo = -174804622, normal = 72277359, material = -90012972, palette = -1175980254, tint0 = 245, tint1 = 244, tint2 = 246 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_uniinbred_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1340875429, albedo = 1728737902, normal = -1816187623, material = 242383984, palette = -783849117, tint0 = 11, tint1 = 108, tint2 = 244 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_uniinbred_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1340875429, albedo = 151365544, normal = -1829198372, material = 99307252, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_owlhootfamily_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = -1911852758, palette = -183908539, tint0 = 45, tint1 = 9, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 992762554, normal = 881556643, material = -1911852758, palette = -783849117, tint0 = 124, tint1 = 58, tint2 = 48 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_rkrsurvivalist'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = -1911852758, palette = 1669565057, tint0 = 246, tint1 = 246, tint2 = 250 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = -1078739056, normal = 881556643, material = -1911852758, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = -1078739056, normal = 881556643, material = -1911852758, palette = -1698476236, tint0 = 22, tint1 = 47, tint2 = 8 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v3'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 992762554, normal = 881556643, material = -1911852758, palette = 1734720533, tint0 = 14, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v4'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = -1078739056, normal = 881556643, material = -1911852758, palette = -1436165981, tint0 = 124, tint1 = 58, tint2 = 48 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_mp_fm_bountytarget_males_dlc008'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = 1465835257, palette = 17129595, tint0 = 62, tint1 = 58, tint2 = 61 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_bynsurvivalist_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = -1911852758, palette = -1251868068, tint0 = 254, tint1 = 245, tint2 = 245 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_bynsurvivalist_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = -1911852758, palette = -113397560, tint0 = 253, tint1 = 251, tint2 = 61 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_rkrsurvivalist_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = -1911852758, palette = 864404955, tint0 = 246, tint1 = 254, tint2 = 254 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_kid_recipient_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -276925106, albedo = 506985041, normal = 881556643, material = -1911852758, palette = 1090645383, tint0 = 41, tint1 = 21, tint2 = 52 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_mp'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1760441876, albedo = -736639503, normal = 2118603501, material = 769453092, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_rivalcollector_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1060771462, albedo = 548809269, normal = 1380959211, material = -1344775679, palette = -183908539, tint0 = 10, tint1 = 10, tint2 = 10 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_bynsurvivalist_v3'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1060771462, albedo = 548809269, normal = 1380959211, material = -1344775679, palette = 1669565057, tint0 = 244, tint1 = 242, tint2 = 245 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_htlsurvivalist'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1060771462, albedo = 548809269, normal = 1380959211, material = -1344775679, palette = -113397560, tint0 = 246, tint1 = 246, tint2 = 244 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_a_m_m_rkrsurvivalist_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1060771462, albedo = 548809269, normal = 1380959211, material = -1344775679, palette = -1251868068, tint0 = 241, tint1 = 241, tint2 = 246 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_rob_recipient'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1060771462, albedo = 548809269, normal = 1380959211, material = -1344775679, palette = -783849117, tint0 = 12, tint1 = 2, tint2 = 7 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v5'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 43094795, albedo = 964554365, normal = -743924332, material = -1166850215, palette = -183908539, tint0 = 93, tint1 = 10, tint2 = 63 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v6'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 43094795, albedo = 964554365, normal = -743924332, material = -1166850215, palette = -1436165981, tint0 = 50, tint1 = 48, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_army_v7'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 43094795, albedo = 964554365, normal = -743924332, material = -1166850215, palette = -783849117, tint0 = 16, tint1 = 18, tint2 = 14 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_skinnyoldguy'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 498575346, albedo = 506985041, normal = 881556643, material = -1911852758, palette = -183908539, tint0 = 37, tint1 = 1, tint2 = 8 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_charlessmith'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1401534050, albedo = -413276042, normal = -2000311781, material = -1184798602, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_javierescuella'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 353817708, albedo = -1818127823, normal = -1253617636, material = -1918234145, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_charlessmith_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -636585723, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_dutch'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1631908992, albedo = 337965886, normal = -1171932451, material = -777251490, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_hoseamatthews'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -708993245, albedo = 740800891, normal = 175726555, material = -1397604117, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = -736639503, normal = 2118603501, material = 769453092, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_kieran'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1405224776, albedo = -1184926036, normal = 1226567699, material = 210166028, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 39125012, normal = -973697748, material = 676418295, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['satchel_mrpearson'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -708457422, albedo = -871690581, normal = 1144745374, material = -846136454, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1956537911, albedo = 964075321, normal = -1752628552, material = -939154242, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 30000,
        slots = 20
    },
    ['strap_player_three'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 741078177, albedo = -640511639, normal = -1269962307, material = -719951653, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 741078177, albedo = -640511639, normal = -1269962307, material = -719951653, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 10000, -- Alças levam menos carga
        slots = 5
    },
    ['strap_player_zero'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1322093917, albedo = -323844726, normal = 1030271885, material = -166690571, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1322093917, albedo = -323844726, normal = 1030271885, material = -166690571, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 10000, -- Alças levam menos carga
        slots = 5
    },
    ['strap_player_zero_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 481689152, albedo = -323844726, normal = 1030271885, material = -166690571, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 481689152, albedo = -323844726, normal = 1030271885, material = -166690571, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 10000, -- Alças levam menos carga
        slots = 5
    },
    ['strap_player_three_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -723992676, albedo = -640511639, normal = -1269962307, material = -719951653, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -723992676, albedo = -640511639, normal = -1269962307, material = -719951653, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 10000, -- Alças levam menos carga
        slots = 5
    },
    ['strap_player_three_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1593819023, albedo = -640511639, normal = -1269962307, material = -719951653, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1593819023, albedo = -640511639, normal = -1269962307, material = -719951653, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 10000, -- Alças levam menos carga
        slots = 5
    },
    ['strap_player_zero_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 928473367, albedo = -323844726, normal = 1030271885, material = -166690571, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 928473367, albedo = -323844726, normal = 1030271885, material = -166690571, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 10000, -- Alças levam menos carga
        slots = 5
    },
    ['loadout_a_m_m_wapwarriors'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1829426720, albedo = 1944867123, normal = -1682196979, material = -1051797099, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -1829426720, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -783849117, tint0 = 26, tint1 = 34, tint2 = 43 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_a_m_m_wapwarriors_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1829426720, albedo = 214319391, normal = 837620883, material = 1184323288, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -1829426720, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -783849117, tint0 = 26, tint1 = 34, tint2 = 43 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unibanditos'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1829426720, albedo = 144930946, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 33, tint1 = 33, tint2 = 33 },
            female = { drawable = -1829426720, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -783849117, tint0 = 26, tint1 = 34, tint2 = 43 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_famousgunslinger'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1954583010, albedo = 1967307283, normal = 1964132842, material = 2025847598, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -1954583010, albedo = 95533972, normal = 1895015122, material = 1422200461, palette = -1543234321, tint0 = 32, tint1 = 20, tint2 = 52 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_javierescuella'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 153030231, albedo = 694542677, normal = -1286354113, material = 979262187, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 153030231, albedo = -1179372082, normal = 2010581189, material = 647813544, palette = -783849117, tint0 = 24, tint1 = 21, tint2 = 40 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_javierescuella_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 153030231, albedo = 694542677, normal = -1286354113, material = 979262187, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 153030231, albedo = -1179372082, normal = 2010581189, material = 647813544, palette = -783849117, tint0 = 24, tint1 = 21, tint2 = 40 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_johnmarston'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1778658733, albedo = -464696304, normal = 538691868, material = 1388778131, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1778658733, albedo = 2002415618, normal = 319164431, material = -978397256, palette = -783849117, tint0 = 67, tint1 = 57, tint2 = 65 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_alfredo_montez'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 716511412, albedo = -1619971145, normal = -1394500128, material = -682513100, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 716511412, albedo = -2052279998, normal = -636590419, material = -1956010866, palette = -783849117, tint0 = 14, tint1 = 26, tint2 = 19 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_cripps'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 443844798, albedo = -1483831189, normal = 890151317, material = -512073941, palette = -783849117, tint0 = 23, tint1 = 23, tint2 = 19 },
            female = { drawable = 443844798, albedo = -1595240226, normal = 668187762, material = -1710495034, palette = -783849117, tint0 = 1, tint1 = 21, tint2 = 1 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_msp_smuggler2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 443844798, albedo = -1483831189, normal = 890151317, material = -512073941, palette = -183908539, tint0 = 47, tint1 = 11, tint2 = 29 },
            female = { drawable = 443844798, albedo = -1595240226, normal = 668187762, material = -1710495034, palette = -783849117, tint0 = 1, tint1 = 21, tint2 = 1 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_jorge_montez'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -498969143, albedo = 1967307283, normal = 1964132842, material = 2025847598, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -498969143, albedo = 1653184168, normal = -765171760, material = 1364420450, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unimountainmen'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -2042960089, albedo = 1380043538, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 27, tint1 = 27, tint2 = 27 },
            female = { drawable = -2042960089, albedo = 1710264124, normal = 111373956, material = 1602159736, palette = -183908539, tint0 = 0, tint1 = 7, tint2 = 32 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unimountainmen_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -2042960089, albedo = -407833033, normal = -1682196979, material = -1051797099, palette = -783849117, tint0 = 19, tint1 = 19, tint2 = 19 },
            female = { drawable = -2042960089, albedo = 1710264124, normal = 111373956, material = 1602159736, palette = -183908539, tint0 = 0, tint1 = 7, tint2 = 32 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_a_m_m_wapwarriors_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -2042960089, albedo = 1944867123, normal = -1682196979, material = -1051797099, palette = -1698476236, tint0 = 10, tint1 = 0, tint2 = 0 },
            female = { drawable = -2042960089, albedo = 1710264124, normal = 111373956, material = 1602159736, palette = -183908539, tint0 = 0, tint1 = 7, tint2 = 32 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_owlhootfamily'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1986410300, albedo = 144930946, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 0, tint1 = 7, tint2 = 19 },
            female = { drawable = -1986410300, albedo = 1380043538, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 12, tint1 = 12, tint2 = 28 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unicriminals'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1986410300, albedo = 144930946, normal = 894219189, material = 811644610, palette = -783849117, tint0 = 5, tint1 = 5, tint2 = 5 },
            female = { drawable = -1986410300, albedo = 1380043538, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 12, tint1 = 12, tint2 = 28 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_owlhootfamily_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1688685893, albedo = 144930946, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 0, tint1 = 7, tint2 = 8 },
            female = { drawable = 1688685893, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 1 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_owlhootfamily_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1685285134, albedo = 1790692597, normal = 1320400241, material = -1785940127, palette = -183908539, tint0 = 0, tint1 = 6, tint2 = 5 },
            female = { drawable = -1685285134, albedo = -400120218, normal = -1581392846, material = 2063182029, palette = -783849117, tint0 = 23, tint1 = 15, tint2 = 14 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unicriminals_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1685285134, albedo = 1790692597, normal = 1320400241, material = -1785940127, palette = -783849117, tint0 = 13, tint1 = 13, tint2 = 13 },
            female = { drawable = -1685285134, albedo = -400120218, normal = -1581392846, material = 2063182029, palette = -783849117, tint0 = 23, tint1 = 15, tint2 = 14 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unibanditos_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -511022092, albedo = 1710264124, normal = 111373956, material = 1602159736, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 16 },
            female = { drawable = -511022092, albedo = 1329798762, normal = 1517990817, material = -976268524, palette = 1090645383, tint0 = 21, tint1 = 45, tint2 = 15 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unibanditos_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -511022092, albedo = -382726417, normal = -1002489775, material = -1224051962, palette = -183908539, tint0 = 21, tint1 = 21, tint2 = 21 },
            female = { drawable = -511022092, albedo = 1329798762, normal = 1517990817, material = -976268524, palette = 1090645383, tint0 = 21, tint1 = 45, tint2 = 15 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unicriminals_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 479651103, albedo = 144930946, normal = 894219189, material = 811644610, palette = -783849117, tint0 = 101, tint1 = 7, tint2 = 19 },
            female = { drawable = 479651103, albedo = 1686661875, normal = 1635179031, material = -846743210, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unicriminals_v3'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 479651103, albedo = 144930946, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 10, tint1 = 10, tint2 = 10 },
            female = { drawable = 479651103, albedo = 1686661875, normal = 1635179031, material = -846743210, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1452547621, albedo = -1595240226, normal = 668187762, material = -1710495034, palette = -783849117, tint0 = 1, tint1 = 21, tint2 = 1 },
            female = { drawable = 1452547621, albedo = -510631503, normal = -285320158, material = 1565156244, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1503394334, albedo = 2002415618, normal = 319164431, material = -978397256, palette = -783849117, tint0 = 67, tint1 = 57, tint2 = 65 },
            female = { drawable = -1503394334, albedo = -510631503, normal = -285320158, material = 1565156244, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_army'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1866675535, albedo = -1849630897, normal = -1545325434, material = -1906754602, palette = -783849117, tint0 = 26, tint1 = 26, tint2 = 114 },
            female = { drawable = 1866675535, albedo = -1821031285, normal = -1789502595, material = 960096697, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_fussarhenchman'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1866675535, albedo = -1849630897, normal = 1702044266, material = -835976996, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 17 },
            female = { drawable = 1866675535, albedo = -1821031285, normal = -1789502595, material = 960096697, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_a_m_m_wapwarriors_v3'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 2031769099, albedo = 1944867123, normal = -1682196979, material = -1051797099, palette = -1698476236, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 2031769099, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -783849117, tint0 = 26, tint1 = 34, tint2 = 43 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_a_m_m_wapwarriors_v4'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 2031769099, albedo = 214319391, normal = 837620883, material = 1184323288, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 2031769099, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -783849117, tint0 = 26, tint1 = 34, tint2 = 43 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_owlhootfamily_v3'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 2031769099, albedo = 144930946, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 8 },
            female = { drawable = 2031769099, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -783849117, tint0 = 26, tint1 = 34, tint2 = 43 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unimountainmen_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1370169185, albedo = 144930946, normal = 894219189, material = 811644610, palette = -1952348042, tint0 = 8, tint1 = 42, tint2 = 17 },
            female = { drawable = -1370169185, albedo = 95533972, normal = 1895015122, material = 1422200461, palette = -1543234321, tint0 = 32, tint1 = 20, tint2 = 52 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_a_m_m_wapwarriors_v5'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1370169185, albedo = 214319391, normal = 837620883, material = 1184323288, palette = -783849117, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -1370169185, albedo = 95533972, normal = 1895015122, material = 1422200461, palette = -1543234321, tint0 = 32, tint1 = 20, tint2 = 52 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 696607226, albedo = 95533972, normal = 1895015122, material = 1422200461, palette = -1543234321, tint0 = 32, tint1 = 20, tint2 = 52 },
            female = { drawable = 696607226, albedo = -1179372082, normal = 2010581189, material = 647813544, palette = -783849117, tint0 = 24, tint1 = 21, tint2 = 40 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v3'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -635210078, albedo = 1653184168, normal = -765171760, material = 1364420450, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -635210078, albedo = 2002415618, normal = 319164431, material = -978397256, palette = -783849117, tint0 = 67, tint1 = 57, tint2 = 65 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_fm_bountytarget_males_dlc008'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1021869623, albedo = -2121345061, normal = -1682196979, material = -1051797099, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1021869623, albedo = -2052279998, normal = -636590419, material = -1956010866, palette = -783849117, tint0 = 14, tint1 = 26, tint2 = 19 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_owlhootfamily_v4'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1021869623, albedo = 1380043538, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 6 },
            female = { drawable = 1021869623, albedo = -2052279998, normal = -636590419, material = -1956010866, palette = -783849117, tint0 = 14, tint1 = 26, tint2 = 19 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_unicriminals_v4'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1021869623, albedo = 1380043538, normal = 894219189, material = 811644610, palette = -783849117, tint0 = 18, tint1 = 18, tint2 = 18 },
            female = { drawable = 1021869623, albedo = -2052279998, normal = -636590419, material = -1956010866, palette = -783849117, tint0 = 14, tint1 = 26, tint2 = 19 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v4'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1776705480, albedo = -1179372082, normal = 2010581189, material = 647813544, palette = -783849117, tint0 = 24, tint1 = 21, tint2 = 40 },
            female = { drawable = 1776705480, albedo = -1595240226, normal = 668187762, material = -1710495034, palette = -783849117, tint0 = 1, tint1 = 21, tint2 = 1 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_a_m_m_unicorpse'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 1293788549, albedo = -1427449151, normal = 2039999216, material = -1274623913, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = 1293788549, albedo = 1653184168, normal = -765171760, material = 1364420450, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_javierescuella_v2'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -2012705748, albedo = 694542677, normal = -1286354113, material = 979262187, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -2012705748, albedo = 1710264124, normal = 111373956, material = 1602159736, palette = -183908539, tint0 = 0, tint1 = 7, tint2 = 32 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v5'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = 2121857532, albedo = -2052279998, normal = -636590419, material = -1956010866, palette = -783849117, tint0 = 14, tint1 = 26, tint2 = 19 },
            female = { drawable = 2121857532, albedo = 1380043538, normal = 894219189, material = 811644610, palette = -183908539, tint0 = 12, tint1 = 12, tint2 = 28 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_msp_smuggler2_v1'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -552583096, albedo = -1849630897, normal = -1545325434, material = -1906754602, palette = -783849117, tint0 = 14, tint1 = 14, tint2 = 6 },
            female = { drawable = -552583096, albedo = -407833033, normal = 1659986964, material = 598119560, palette = -183908539, tint0 = 0, tint1 = 0, tint2 = 1 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v6'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -640612118, albedo = -400120218, normal = -1581392846, material = 2063182029, palette = -783849117, tint0 = 23, tint1 = 15, tint2 = 14 },
            female = { drawable = -640612118, albedo = -400120218, normal = -1581392846, material = 2063182029, palette = -783849117, tint0 = 23, tint1 = 15, tint2 = 14 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_mp_v7'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -1982256436, albedo = 1329798762, normal = 1517990817, material = -976268524, palette = 1090645383, tint0 = 21, tint1 = 45, tint2 = 15 },
            female = { drawable = -1982256436, albedo = 1329798762, normal = 1517990817, material = -976268524, palette = 1090645383, tint0 = 21, tint1 = 45, tint2 = 15 }
        },
        weight = 15000,
        slots = 8
    },
    ['loadout_cassidy'] = {
        isClothing = true,
        model = 'p_cs_satchel01x',
        customClothing = {
            male = { drawable = -747166380, albedo = 531583617, normal = 375533060, material = -1018382191, palette = 0, tint0 = 0, tint1 = 0, tint2 = 0 },
            female = { drawable = -747166380, albedo = 1686661875, normal = 1635179031, material = -846743210, palette = -1436165981, tint0 = 0, tint1 = 0, tint2 = 0 }
        },
        weight = 15000,
        slots = 8
    },

    ['wallet_small'] = {
        model = 'p_wallet01x',
        weight = 1000,
        slots = 4
    },
    ['wallet_large'] = {
        model = 'p_wallet02x',
        weight = 2000,
        slots = 8
    },
    ['holster_small'] = {
        model = 'p_holster01x',
        weight = 5000,
        slots = 3,
        acceptedItemTypes = {'weapon', 'ammo'}
    },
    ['holster_large'] = {
        model = 'p_holster02x',
        weight = 8000,
        slots = 8,
        acceptedItemTypes = {'weapon', 'ammo'}
    },
}
