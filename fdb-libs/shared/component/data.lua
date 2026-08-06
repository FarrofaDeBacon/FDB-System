fdb = fdb or {}
fdb.component = {}
fdb.component.data = {}

-- Função para obter o hash de categoria a partir de string/inteiro
function fdb.component.getCategoryHash(category)
    if type(category) == "number" then return category end
    if category == "horse_feathers" then
        return -287556490
    end
    return GetHashKey(category)
end

-- Lista de categorias de peds
fdb.component.data.pedCategories = {
    "heads", "eyes", "teeth", "bodies_upper", "bodies_lower", "hair", "hair_bonnet",
    "beards", "beards_chin", "beards_chops", "beards_mustache", "beards_complete",
    "ponchos", "cloaks", "hair_accessories", "dresses", "shawls", "chemises",
    "knickers", "gloves", "coats", "coats_closed", "coat_accessories", "coats_heavy",
    "vests", "vest_accessories", "corsets", "suspenders", "neckties", "shirts_full",
    "shirts_full_overpants", "unionsuit_legs", "unionsuits_full", "spats", "gunbelts",
    "gauntlets", "wrist_bindings", "holsters_left", "holsters_right", "holsters_center",
    "holsters_crossdraw", "holsters_knife", "holsters_quivers", "loadouts", "outfits",
    "belt_buckles", "belts", "skirts", "boots", "pants", "pants_accessories",
    "overalls_full", "overalls_modular_uppers", "overalls_modular_lowers", "boot_accessories",
    "ankle_bindings", "accessories", "satchels", "satchel_straps", "jewelry_rings_right",
    "jewelry_rings_left", "jewelry_rings", "jewelry_bracelets", "jewelry_earrings",
    "jewelry_necklaces", "aprons", "chaps", "badges", "gunbelt_accs", "eyewear",
    "masks", "masks_large", "hats", "hat_accessories", "headwear", "hair",
    "beards_complete", "teeth", "neckwear", "neckerchiefs", "armor",
}

-- Lista de categorias de cavalos
fdb.component.data.horseCategories = {
    "horse_heads", "horse_bodies", "horse_feathers", "horse_blankets", "saddle_horns",
    "saddle_stirrups", "saddle_lanterns", "horse_saddlebags", "horse_bedrolls",
    "horse_tails", "horse_shoes", "horse_mustache", "horse_manes", "horse_accessories",
    "horse_outfits", "horse_saddles", "horse_bridles",
}

-- Ordenação total de carregamento
fdb.component.data.order = {}
for i = 1, #fdb.component.data.pedCategories do
    table.insert(fdb.component.data.order, fdb.component.data.pedCategories[i])
end
for i = 1, #fdb.component.data.horseCategories do
    table.insert(fdb.component.data.order, fdb.component.data.horseCategories[i])
end

-- Lista reversa para nomes a partir do hash
fdb.component.data.categoryName = {}
for i = 1, #fdb.component.data.order do
    local category = fdb.component.data.order[i]
    local hash = fdb.component.getCategoryHash(category)
    fdb.component.data.categoryName[hash] = category
end

-- Mapeamento de categorias que NÃO são roupas
local categoryNotClothes = {
    hair = true, beards = true, hair_bonnet = true, beards_chin = true,
    beards_chops = true, beards_mustache = true, beards_complete = true,
    teeth = true, heads = true, bodies_lower = true, bodies_upper = true,
    eyes = true
}

function fdb.component.isCategoryAClothes(category)
    return not categoryNotClothes[category]
end

-- Obter nome da categoria a partir do hash
function fdb.component.getCategoryNameFromHash(hash)
    return fdb.component.data.categoryName[hash] or "unknown"
end

-- Estados vestíveis (Wearable States)
fdb.component.data.wearableStates = {
    shirts_full = {
        [00] = "base",
        [01] = "closed_collar_rolled_sleeve",
        [10] = "open_collar_full_sleeve",
        [11] = "open_collar_rolled_sleeve",
    },
    neckwear = {
        [0] = "base",
        [1] = "mask_up"
    },
    boots = {
        [0] = "base",
        [1] = "under_pants"
    },
    loadouts = {
        [0] = "base",
        [1] = "base_right",
    },
    vests = {
        [0] = "base",
        [1] = "under_pants"
    },
    hair = {
        [0] = "base",
        [1] = "pomade"
    }
}

-- Mapeamento reverso dos hashes dos estados vestíveis
fdb.component.data.wearableStatesName = {}
for category, states in pairs(fdb.component.data.wearableStates) do
    for _, state in pairs(states) do
        fdb.component.data.wearableStatesName[GetHashKey(state)] = state
    end
end

function fdb.component.getWearableStateNameFromHash(hash)
    return fdb.component.data.wearableStatesName[hash] or "base"
end

-- Paletas de cores padrão de fábrica
fdb.component.data.palettes = {
    "generic_wagon_palette", "generic_skinned_pal", "metaped_tint_animal",
    "metaped_tint_combined", "metaped_tint_combined_leather", "metaped_tint_combined_leather1",
    "metaped_tint_combined_leather2", "metaped_tint_combined_leather3", "metaped_tint_combined_leather4",
    "metaped_tint_combined_leather5", "metaped_tint_combined_leather6", "metaped_tint_eye",
    "metaped_tint_eye_ui", "metaped_tint_generic", "metaped_tint_generic_clean",
    "metaped_tint_generic_weathered", "metaped_tint_generic_worn", "metaped_tint_hair",
    "metaped_tint_hair1", "metaped_tint_hair2", "metaped_tint_hair_ui", "metaped_tint_hair_bed",
    "metaped_tint_hat", "metaped_tint_hat_clean", "metaped_tint_hat_weathered",
    "metaped_tint_hat_worn", "metaped_tint_horse", "metaped_tint_horse_001",
    "metaped_tint_horse_leather", "metaped_tint_horse_leather_001", "metaped_tint_leather",
    "metaped_tint_makeup", "metaped_tint_mpadv",
}

fdb.component.data.palettesHash = {}
for i = 1, #fdb.component.data.palettes do
    local pName = fdb.component.data.palettes[i]
    fdb.component.data.palettesHash[GetHashKey(pName)] = pName
end

function fdb.component.getPaletteNameFromHash(hash)
    return fdb.component.data.palettesHash[hash] or "metaped_tint_generic"
end

-- COMPATIBILIDADE REVERSA COM JO_LIBS
if not jo then jo = {} end
jo.component = fdb.component
