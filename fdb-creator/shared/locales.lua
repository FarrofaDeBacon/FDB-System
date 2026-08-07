-- Murphy Creator - Translation System
-- Système de Traduction pour Murphy Creator

Lang = {}
Lang.Locale = Config.Locale or "en" -- Set in config

-- English Translations
Lang.en = {}

-- General UI
Lang.en.UI = {
    cancel = "Cancel",
    accept = "Accept",
    save = "Save",
    back = "Back",
    continue = "Continue",
    delete = "Delete",
    create = "Create",
    edit = "Edit",
    close = "Close",
    reset = "Reset",
    confirm = "Confirm",
    yes = "Yes",
    no = "No",
    play = "Play",
    spawn = "Spawn",
    loading = "Loading...",
    style = "Style",
    colour = "Colour",
    variation = "Variation",
    advanced = "Advanced",
}

-- Character Selection
Lang.en.CharSelect = {
    title = "CHARACTER SELECTION",
    createNew = "Create New",
    selectCharacter = "Select Character",
    deleteWarning = "Warning!",
    deleteMessage = "Are you sure you want to delete this character?",
    cancelDeletion = "Cancel",
    confirmDeletion = "Delete",
    characterInfo = "Character Info",
    sexe = "Gender",
    male = "Male",
    female = "Female",
    lore = "Character Lore",
    birthday = "Birthday",
    day = "Day",
    month = "Month",
    year = "Year",
    noLore = "No lore available",
}

-- Character Creation
Lang.en.CharCreation = {
    title = "CREATE CHARACTER",
    editTitle = "EDIT CHARACTER",
    firstname = "First Name",
    lastname = "Last Name",
    characterLore = "Character lore...",
    playAsAPed = "Play as a ped",
    selectPed = "Select Ped",
    cancelCreation = "Cancel Creation",
    cancelWarning = "You will lose all your changes, are you sure?",
    cancelStop = "Cancel",
    confirmStop = "Continue",
    birthDay = "Day...",
    birthMonth = "Month...",
    birthYear = "Year...",
}

-- Appearance Editor
Lang.en.Appearance = {
    title = "EDIT APPEARANCE",
    globalSettings = "Global Settings",
    skinSettings = "Skin Settings",
    eyeSettings = "Eyes Settings",
    height = "Height",
    headSize = "Head Size",
    body = "Body",
    waist = "Waist",
    legs = "Legs",
    upperBody = "Upper Body",
    lowerBody = "Lower Body",
    teeth = "Teeth",
    eyes = "Eyes",
    skinColour = "Skin Colour",
    eyeColour = "Eye Colour",
    cancel = "Cancel",
    undress = "Undress",
    reset = "Reset",
    resetWarning = "Are you sure you want to reset your changes?",
    resetConfirm = "Reset",
    resetCancel = "Cancel",
}

-- Body Parts / Face Features
Lang.en.BodyParts = {
    head = "Head",
    headShape = "Head Shape",
    headWidth = "Head Width",
    faceWidth = "Face Width",
    faceDepth = "Face Depth",
    foreheadSize = "Forehead Size",
    
    neck = "Neck",
    neckWidth = "Neck Width",
    neckDepth = "Neck Depth",
    
    eyes = "Eyes",
    eyesDepth = "Eyes Depth",
    eyesAngle = "Eyes Angle",
    eyesDistance = "Eyes Distance",
    eyesHeight = "Eyes Height",
    
    eyebrows = "Eyebrows",
    browsHeight = "Brows Height",
    browsWidth = "Brows Width",
    browsDepth = "Brows Depth",
    
    eyelid = "Eyelid",
    eyelidHeight = "Eyelid Height",
    eyelidWidth = "Eyelid Width",
    eyelidLeftOpen = "Left Eyelid O/Close",
    eyelidRightOpen = "Right Eyelid O/Close",
    
    ears = "Ears",
    earsWidth = "Ears Width",
    earsAngle = "Ears Angle",
    earsHeight = "Ears Height",
    earsDepth = "Ears Depth",
    
    cheekbone = "CheekBone",
    cheekboneHeight = "CheekBone Height",
    cheekboneWidth = "CheekBone Width",
    cheekboneDepth = "CheekBone Depth",
    
    jaw = "Jaw",
    jawHeight = "Jaw Height",
    jawWidth = "Jaw Width",
    jawDepth = "Jaw Depth",
    
    chin = "Chin",
    chinHeight = "Chin Height",
    chinWidth = "Chin Width",
    chinDepth = "Chin Depth",
    
    nose = "Nose",
    noseWidth = "Nose Width",
    noseSize = "Nose Size",
    noseHeight = "Nose Height",
    noseAngle = "Nose Angle",
    noseCurvature = "Nose Curvature",
    noseDistance = "Nose Distance",
    
    mouth = "Mouth",
    mouthWidth = "Mouth Width",
    mouthDepth = "Mouth Depth",
    mouthX = "Mouth X",
    mouthY = "Mouth Y",
    
    lips = "Lips",
    lipUpperHeight = "Upper Lip Height",
    lipUpperWidth = "Upper Lip Width",
    lipUpperDepth = "Upper Lip Depth",
    lipLowerHeight = "Lower Lip Height",
    lipLowerWidth = "Lower Lip Width",
    lipLowerDepth = "Lower Lip Depth",
    
    shoulders = "Shoulders",
    shouldersSize = "Shoulders Size",
    shouldersThickness = "Shoulders Thickness",
    backMuscles = "Back Muscles",
    
    arms = "Arms",
    armsSize = "Arms Size",
    
    chest = "Chest",
    chestSize = "Chest Size",
    
    waist = "Waist",
    waistWidth = "Waist Width",
    
    hips = "Hips",
    hipsSize = "Hips Size",
    
    legs = "Legs",
    thightsSize = "Thighs Size",
    calvesSize = "Calves Size",
}

-- Descriptors
Lang.en.Descriptors = {
    narrow = "Narrow",
    wide = "Wide",
    large = "Large",
    small = "Small",
    high = "High",
    low = "Low",
    left = "Left",
    right = "Right",
    up = "Up",
    down = "Down",
    open = "Open",
    close = "Close",
    far = "Far",
    near = "Near",
    extruded = "Extruded",
    retracted = "Retracted",
    raised = "Raised",
    lowered = "Lowered",
    detached = "Detached",
    stuck = "Stuck",
}

-- Categories (Barber & Makeup)
Lang.en.Categories = {
    hair = "Hair",
    hairBonnet = "Hair Bonnet",
    beard = "Beard",
    beardComplete = "Full Beards",
    beardMustache = "Mustaches",
    beardChops = "Sideburns",
    beardChin = "Chin Hair",
    eyeliners = "Eyeliners",
    eyebrows = "Eyebrows",
    scars = "Scars 1",
    scars2 = "Scars 2",
    scars3 = "Scars 3",
    lipsticks = "Lipsticks",
    acne = "Acne",
    shadows = "Shadows",
    beardStabble = "Beard Stubble",
    paintedMasks = "Painted Masks",
    ageing = "Ageing",
    blush = "Blush",
    blush2 = "Blush 2",
    complex = "Complex",
    disc = "Disc",
    foundation = "Foundation",
    freckles = "Freckles",
    grime = "Grime",
    hairStabble = "Hair Stubble",
    moles = "Moles",
    spots = "Spots",
}

-- Notifications & Warnings
Lang.en.Notifications = {
    pedWarning = "You're using a ped base, you'll need to customize their hairstyle and clothing. Makeup and lifestyle overlays won't be available.",
    characterCreated = "Character created successfully!",
    characterUpdated = "Character updated successfully!",
    characterDeleted = "Character deleted successfully!",
    actionInProgress = "Action in progress, please wait...",
    dataNotLoaded = "Data not loaded yet, retrying...",
    errorOccurred = "An error occurred, please try again.",
    selectionInProgress = "Character selection in progress, please wait...",
}

-- French Translations (Français)
Lang.fr = {}

-- General UI
Lang.fr.UI = {
    cancel = "Annuler",
    accept = "Accepter",
    save = "Sauvegarder",
    back = "Retour",
    continue = "Continuer",
    delete = "Supprimer",
    create = "Créer",
    edit = "Éditer",
    close = "Fermer",
    reset = "Réinitialiser",
    confirm = "Confirmer",
    yes = "Oui",
    no = "Non",
    play = "Jouer",
    spawn = "Apparaître",
    loading = "Chargement...",
    style = "Style",
    colour = "Couleur",
    variation = "Variation",
    advanced = "Avancé",
}

-- Character Selection
Lang.fr.CharSelect = {
    title = "SÉLECTION DE PERSONNAGE",
    createNew = "Créer Nouveau",
    selectCharacter = "Sélectionner Personnage",
    deleteWarning = "Attention!",
    deleteMessage = "Êtes-vous sûr de vouloir supprimer ce personnage?",
    cancelDeletion = "Annuler",
    confirmDeletion = "Supprimer",
    characterInfo = "Info Personnage",
    sexe = "Sexe",
    male = "Homme",
    female = "Femme",
    lore = "Histoire du Personnage",
    birthday = "Date de Naissance",
    day = "Jour",
    month = "Mois",
    year = "Année",
    noLore = "Aucune histoire disponible",
}

-- Character Creation
Lang.fr.CharCreation = {
    title = "CRÉER PERSONNAGE",
    editTitle = "ÉDITER PERSONNAGE",
    firstname = "Prénom",
    lastname = "Nom",
    characterLore = "Histoire du personnage...",
    playAsAPed = "Jouer en tant que PED",
    selectPed = "Sélectionner PED",
    cancelCreation = "Annuler la Création",
    cancelWarning = "Vous allez perdre tous vos changements, êtes-vous sûr?",
    cancelStop = "Annuler",
    confirmStop = "Continuer",
    birthDay = "Jour...",
    birthMonth = "Mois...",
    birthYear = "Année...",
}

-- Appearance Editor
Lang.fr.Appearance = {
    title = "ÉDITER L'APPARENCE",
    globalSettings = "Paramètres Globaux",
    skinSettings = "Paramètres de Peau",
    eyeSettings = "Paramètres des Yeux",
    height = "Taille",
    headSize = "Taille de Tête",
    body = "Corps",
    waist = "Taille",
    legs = "Jambes",
    upperBody = "Haut du Corps",
    lowerBody = "Bas du Corps",
    teeth = "Dents",
    eyes = "Yeux",
    skinColour = "Couleur de Peau",
    eyeColour = "Couleur des Yeux",
    cancel = "Annuler",
    undress = "Déshabiller",
    reset = "Réinitialiser",
    resetWarning = "Êtes-vous sûr de vouloir réinitialiser vos changements?",
    resetConfirm = "Réinitialiser",
    resetCancel = "Annuler",
}

-- Body Parts / Face Features
Lang.fr.BodyParts = {
    head = "Tête",
    headShape = "Forme de Tête",
    headWidth = "Largeur de Tête",
    faceWidth = "Largeur du Visage",
    faceDepth = "Profondeur du Visage",
    foreheadSize = "Taille du Front",
    
    neck = "Cou",
    neckWidth = "Largeur du Cou",
    neckDepth = "Profondeur du Cou",
    
    eyes = "Yeux",
    eyesDepth = "Profondeur des Yeux",
    eyesAngle = "Angle des Yeux",
    eyesDistance = "Distance des Yeux",
    eyesHeight = "Hauteur des Yeux",
    
    eyebrows = "Sourcils",
    browsHeight = "Hauteur des Sourcils",
    browsWidth = "Largeur des Sourcils",
    browsDepth = "Profondeur des Sourcils",
    
    eyelid = "Paupière",
    eyelidHeight = "Hauteur de Paupière",
    eyelidWidth = "Largeur de Paupière",
    eyelidLeftOpen = "Ouverture Paupière Gauche",
    eyelidRightOpen = "Ouverture Paupière Droite",
    
    ears = "Oreilles",
    earsWidth = "Largeur des Oreilles",
    earsAngle = "Angle des Oreilles",
    earsHeight = "Hauteur des Oreilles",
    earsDepth = "Profondeur des Oreilles",
    
    cheekbone = "Pommettes",
    cheekboneHeight = "Hauteur des Pommettes",
    cheekboneWidth = "Largeur des Pommettes",
    cheekboneDepth = "Profondeur des Pommettes",
    
    jaw = "Mâchoire",
    jawHeight = "Hauteur de Mâchoire",
    jawWidth = "Largeur de Mâchoire",
    jawDepth = "Profondeur de Mâchoire",
    
    chin = "Menton",
    chinHeight = "Hauteur du Menton",
    chinWidth = "Largeur du Menton",
    chinDepth = "Profondeur du Menton",
    
    nose = "Nez",
    noseWidth = "Largeur du Nez",
    noseSize = "Taille du Nez",
    noseHeight = "Hauteur du Nez",
    noseAngle = "Angle du Nez",
    noseCurvature = "Courbure du Nez",
    noseDistance = "Distance du Nez",
    
    mouth = "Bouche",
    mouthWidth = "Largeur de Bouche",
    mouthDepth = "Profondeur de Bouche",
    mouthX = "Bouche X",
    mouthY = "Bouche Y",
    
    lips = "Lèvres",
    lipUpperHeight = "Hauteur Lèvre Sup.",
    lipUpperWidth = "Largeur Lèvre Sup.",
    lipUpperDepth = "Profondeur Lèvre Sup.",
    lipLowerHeight = "Hauteur Lèvre Inf.",
    lipLowerWidth = "Largeur Lèvre Inf.",
    lipLowerDepth = "Profondeur Lèvre Inf.",
    
    shoulders = "Épaules",
    shouldersSize = "Taille des Épaules",
    shouldersThickness = "Épaisseur des Épaules",
    backMuscles = "Muscles du Dos",
    
    arms = "Bras",
    armsSize = "Taille des Bras",
    
    chest = "Poitrine",
    chestSize = "Taille de Poitrine",
    
    waist = "Taille",
    waistWidth = "Largeur de Taille",
    
    hips = "Hanches",
    hipsSize = "Taille des Hanches",
    
    legs = "Jambes",
    thightsSize = "Taille des Cuisses",
    calvesSize = "Taille des Mollets",
}

-- Descriptors
Lang.fr.Descriptors = {
    narrow = "Étroit",
    wide = "Large",
    large = "Grand",
    small = "Petit",
    high = "Haut",
    low = "Bas",
    left = "Gauche",
    right = "Droite",
    up = "Haut",
    down = "Bas",
    open = "Ouvert",
    close = "Fermé",
    far = "Loin",
    near = "Proche",
    extruded = "Saillant",
    retracted = "Rétracté",
    raised = "Relevé",
    lowered = "Abaissé",
    detached = "Détaché",
    stuck = "Collé",
}

-- Categories (Barber & Makeup)
Lang.fr.Categories = {
    hair = "Cheveux",
    hairBonnet = "Bonnet Cheveux",
    beard = "Barbe",
    beardComplete = "Barbes Complètes",
    beardMustache = "Moustaches",
    beardChops = "Favoris",
    beardChin = "Poils du Menton",
    eyeliners = "Eye-liners",
    eyebrows = "Sourcils",
    scars = "Cicatrices 1",
    scars2 = "Cicatrices 2",
    scars3 = "Cicatrices 3",
    lipsticks = "Rouges à Lèvres",
    acne = "Acné",
    shadows = "Ombres",
    beardStabble = "Barbe Naissante",
    paintedMasks = "Masques Peints",
    ageing = "Vieillissement",
    blush = "Fard à Joues",
    blush2 = "Fard à Joues 2",
    complex = "Complexe",
    disc = "Disque",
    foundation = "Fond de Teint",
    freckles = "Taches de Rousseur",
    grime = "Saleté",
    hairStabble = "Cheveux Courts",
    moles = "Grains de Beauté",
    spots = "Taches",
}

-- Notifications & Warnings
Lang.fr.Notifications = {
    pedWarning = "Vous utilisez un modèle PED, vous devrez personnaliser la coiffure et les vêtements. Les overlays de maquillage ne seront pas disponibles.",
    characterCreated = "Personnage créé avec succès!",
    characterUpdated = "Personnage mis à jour avec succès!",
    characterDeleted = "Personnage supprimé avec succès!",
    actionInProgress = "Action en cours, veuillez patienter...",
    dataNotLoaded = "Données pas encore chargées, nouvelle tentative...",
    errorOccurred = "Une erreur s'est produite, veuillez réessayer.",
    selectionInProgress = "Sélection du personnage en cours, veuillez patienter...",
}

-- Helper function to get translation
function _U(category, key)
    local locale = Lang[Lang.Locale]
    if not locale then
        print("[murphy_creator] Language '" .. Lang.Locale .. "' not found, falling back to English")
        locale = Lang.en
    end
    
    if not locale[category] then
        print("[murphy_creator] Category '" .. category .. "' not found in language")
        return key
    end
    
    if not locale[category][key] then
        print("[murphy_creator] Translation key '" .. key .. "' not found in category '" .. category .. "'")
        return key
    end
    
    return locale[category][key]
end

-- Backward compatibility with old Lang.Creator format
Lang.Creator = {}
setmetatable(Lang.Creator, {
    __index = function(t, key)
        -- Try to find in BodyParts first, then Descriptors, then Appearance
        return _U("BodyParts", key) or _U("Descriptors", key) or _U("Appearance", key) or key
    end
})

-- Backward compatibility with old Lang.Categories format
Lang.Categories = {}
setmetatable(Lang.Categories, {
    __index = function(t, key)
        return _U("Categories", key) or key
    end
})
