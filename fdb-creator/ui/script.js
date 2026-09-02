///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                   //
//                                       FARROFA DEBACON                                             //
//                                                                                                   //
//                        2026 - Farrofa DeBacon / FDB System                                        //
//                                                                                                   //
//                         This Script is working with all UI folder                                 //
//                   to show and hide datas for Clothes creation / modification                      //
//                                                                                                   //
//                                   All Right Reserved - ©                                          //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////// PIN ELEMENT JSON EXAMPLE //////////////////////////

pinElem = [
    {
        "id": 1,
        "name": "Head",
        "direction": "left",
        "startPosition": {
            "x": 0.8,
            "y": 0.4
        },
        "subElem": [

            {
                "id": 1,
                "name": "Nose"
            }, {

                "id": 1,
                "name": "kkjgh"
            }

        ]
    }, {
        "id": 2,
        "name": "Chest",
        "direction": "right",
        "startPosition": {
            "x": 0.1,
            "y": 0.3
        },
        "subElem": [

            {
                "id": 1,
                "name": "Nose"
            }, {

                "id": 1,
                "name": "Nose"
            }

        ]
    }, {
        "id": 3,
        "name": "Legs",
        "direction": "right",
        "startPosition": {
            "x": 0.4,
            "y": 0.2
        },
        "subElem": [

            {
                "id": 1,
                "name": "Nose"
            }, {

                "id": 1,
                "name": "Nose"
            }

        ]
    },
];


pinPerso = [
    {
        "id": 1,
        "name": "Pablo",
        "ExistingChar": true,
        "startPosition": {
            "x": 0.8,
            "y": 0.4
        }
    }, {
        "id": 2,
        "ExistingChar": false,
        "startPosition": {
            "x": 0.1,
            "y": 0.3
        }
    }, {
        "id": 3,
        "name": "Jean Pierre",
        "ExistingChar": true,
        "startPosition": {
            "x": 0.4,
            "y": 0.2
        }
    },
];


// const categories = [

//     {
//         "id": 1,
//         "name": "Shirts",
//         "image": "./img/categories/barber.png"
//     },
//     {
//         "id": 2,
//         "name": "Pants",
//         "image": "./img/categories/lifestyle.png"
//     },
//     {
//         "id": 3,
//         "name": "Shoes",
//         "image": "./img/categories/makeup.png"
//     }
// ]

// // JSON Example for items

// const items = [
//     {
//         "id": 1,
//         "name": "Shirt Style",
//         "category": 1,
//         "totalAmount": 255,
//         "selectorType": "slider",

//         "value": 50
//     },
//     {
//         "id": 2,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 3,
//         "name": "Shirt Style",
//         "category": 1,
//         "totalAmount": 255,
//         "selectorType": "slider",

//         "value": 50
//     },
//     {
//         "id": 4,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 5,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 6,
//         "name": "Pants Style of the sky",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 7,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 8,
//         "name": "Pants Style",
//         "category": 2,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 9,
//         "name": "Pants Style",
//         "category": 2,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     }
// ]

// // JSON Example for contextualDatas
// const contextualDatasExampleVariation = [
//     {
//         "id": 1,
//         "contextual": "variation",
//         "variationAmount": 50,

//         "variationValue": 1,

//         "tints": [
//             {
//                 "tintId": 1,
//                 "value": 25
//             },
//             {
//                 "tintId": 2,
//                 "value": 50
//             },
//             {
//                 "tintId": 3,
//                 "value": 75
//             }
//         ],

//         "advanced": true,
//         "advancedValues": [
//             {
//                 "valueName": "Opacity",
//                 "valueId": 1,
//                 "valueValue": 25,
//                 "maxValue": 100,
//                 "minValue": 0
//             }, {
//                 "valueName": "Palette",
//                 "valueId": 2,
//                 "valueValue": 20,
//                 "maxValue": 25,
//                 "minValue": 1
//             }]

//     }
// ]


////////////////////////// MODIFY ELEMENT JSON EXAMPLE //////////////////////////

// EditionElem =

//     [{
//         "name": "NOSE",
//         "division": [

//             {
//                 "id": 1,
//                 "name": "General Settings",
//                 "icon": "./img/icons/plus.png",
//                 "elements": [{
//                     "id": 1,
//                     "type": "slider_legacy",
//                     "name": "Height",
//                     "totalAmount": 3,

//                     "value": 1

//                 }
//                 ]

//             },
//             {
//                 "id": 2,
//                 "name": "Size Settings",
//                 "icon": "./img/icons/plus.png",
//                 "elements": [
//                     {
//                         "id": 1,
//                         "type": "matrice",
//                         "topValueName": "High",
//                         "bottomValueName": "Low",
//                         "leftValueName": "Narrow",
//                         "rightValueName": "Wide",

//                         "startPositionX": 0.2,
//                         "startPositionY": 0.2,

//                     }, {
//                         "id": 2,
//                         "type": "slider",
//                         "leftValueName": "Prout",
//                         "rightValueName": "Prout",

//                         "startValue": 25

//                     }
//                 ]

//             }, {
//                 "id": 3,
//                 "name": "Prout Settings",
//                 "icon": "./img/icons/eye.png",
//                 "elements": [
//                     {
//                         "id": 1,
//                         "type": "slider",
//                         "leftValueName": "Prout",
//                         "rightValueName": "Prout",

//                         "startValue": 40

//                     }, {
//                         "id": 2,
//                         "type": "matrice",
//                         "topValueName": "High",
//                         "bottomValueName": "Low",
//                         "leftValueName": "Narrow",
//                         "rightValueName": "Wide",

//                         "startPositionX": 0.5,
//                         "startPositionY": 0.5

//                     }, {
//                         "id": 3,
//                         "type": "slider",
//                         "leftValueName": "Prout",
//                         "rightValueName": "Prout",

//                         "startValue": 80

//                     }
//                 ]

//             }
//         ],

//     }

// ]



// const globalApparenceMenu = [

//     {
//         "id": 1,
//         "name": "Height",
//         "totalAmount": 3,
//         "selectorType": "slider",

//         "value": 1
//     }, {
//         "id": 2,
//         "name": "Head Size",
//         "totalAmount": 3,
//         "selectorType": "slider",

//         "value": 1
//     }, {
//         "id": 3,
//         "name": "Belly",
//         "totalAmount": 3,
//         "selectorType": "slider",

//         "value": 1
//     }, {
//         "id": 4,
//         "name": "Tooth",
//         "totalAmount": 3,
//         "selectorType": "slider",

//         "value": 1
//     },

// ]

// const eyeApparenceMenu = [

//     {
//         "id": 1,
//         "selectorType": "colour",
//         "tintAmount": 14,
//         "colours": [
//             {
//                 "id": "1",
//                 "image": "./img/colours/1.png"
//             },
//             {
//                 "id": "2",
//                 "image": "./img/colours/2.png"
//             },
//             {
//                 "id": "3",
//                 "image": "./img/colours/3.png"
//             },
//             {
//                 "id": "4",
//                 "image": "./img/colours/4.png"
//             },
//             {
//                 "id": "5",
//                 "image": "./img/colours/5.png"
//             },
//             {
//                 "id": "6",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "7",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "6",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "8",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "9",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "10",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "11",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "12",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "13",
//                 "image": "./img/colours/6.png"
//             },
//             {
//                 "id": "14",
//                 "image": "./img/colours/6.png"
//             }
//         ],

//         "tintValue": 1
//     },

// ]

// const skinApparenceMenu = [

//     {
//         "id": 1,
//         "selectorType": "colour",
//         "tintAmount": 6,
//         "colours": [
//             {
//                 "id": "1",
//                 "image": "./img/colours/1.png"
//             },
//             {
//                 "id": "2",
//                 "image": "./img/colours/2.png"
//             },
//             {
//                 "id": "3",
//                 "image": "./img/colours/3.png"
//             },
//             {
//                 "id": "4",
//                 "image": "./img/colours/4.png"
//             },
//             {
//                 "id": "5",
//                 "image": "./img/colours/5.png"
//             },
//             {
//                 "id": "6",
//                 "image": "./img/colours/6.png"
//             }
//         ],

//         "tintValue": 1
//     },

// ]


// const pedsList = [
//     {
//         "id": 1,
//         "name": "Enculé",
//         "totalAmount": 3,
//         "selectorType": "slider",

//         "value": 1
//     }, {
//         "id": 2,
//         "name": "Farmer",
//         "totalAmount": 5,
//         "selectorType": "slider",

//         "value": 1
//     }

// ]


// const spawnLocationList = [

//     {
//         "id": 1,
//         "name": "Armadillo",
//         "description": "Armadillo Set in a desert region, Armadillo is a dusty, battered town, typical of the Wild West. It has seen better days but is now ravaged by disease, giving it a dark, almost ghostly atmosphere. The town epitomises the decline of small communities on the edge of civilisation.",

//     }, {
//         "id": 2,
//         "name": "Valentine",
//         "description": "Valentine Un village rural et animé, au cœur des Grandes Plaines. Valentine est un point de rencontre pour les ranchers, les cow-boys et les voyageurs. L'ambiance y est joviale mais parfois chaotique, avec des bagarres fréquentes dans le saloon et une atmosphère de liberté sauvage.",

//     }, {
//         "id": 3,
//         "name": "Saint-denis",
//         "description": "Saint-Denis Inspirée par la Nouvelle-Orléans, Saint-Denis est une grande ville portuaire et cosmopolite. Elle représente l'essor industriel et l'influence culturelle des villes modernes de l'époque. Son ambiance est raffinée mais cache une part d'ombre avec des inégalités sociales et des activités criminelles.",

//     }, {
//         "id": 4,
//         "name": "Blackwater",
//         "description": "Blackwater est une ville en pleine transition, symbolisant le changement entre l'ancien Ouest sauvage et la modernité. Elle est prospère, bien organisée et plus développée que les autres villes du jeu. Cependant, son histoire est marquée par des événements tragiques, notamment une fusillade majeure qui a laissé une empreinte sur son atmosphère",

//     }


// ]


////////////////////////////// TEMP SELECTED DATA EXEMP /////////////////////////////////////////

const selectedCharData = {

    "id": 1,
    "name": "John Marston",
    "lore": "A former outlaw and gunslinger, John Marston is a complex character with a troubled past. He seeks redemption and a chance to start anew, but his violent history often catches up with him.",
    "DayBirth": "12",
    "MonthBirth": "March",
    "YearBirth": "1899",
    "CharacterSex": "Male"

}


////////////////////////// GLOBAL MENU STRUCUTRE //////////////////////////

//Show or not element in the chraracter menu
globalMenuStructure = {

    "CharacterSexe": true,
    "CharacterLore": true,
    "CharacterBirthday": true,
    "playAsAPed": true,
    "EditPed": true //EXPERIMENTAL FEATURE
}

userPed = false;
userSexe = "Male";
isSecondChanceMode = false;


let EditionElem = [];
let pedsList = [];
let categories = [];
let items = [];

let globalApparenceMenu = [];
let eyeApparenceMenu = [];
let skinApparenceMenu = [];



let spawnLocationList = [];


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      GLOBAL ELEMENTS                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////// ELEMENT EDITION MENU //////////////////////////

// Show menu for edition of selected element
function showElementEditionMenu() {

    createEditionMenu();
    const editionMenu = document.getElementById('EditionMenu');
    editionMenu.classList.remove('hidden');

    //CAM
    loadCameraMenu();
    const cameraMenu = document.getElementById('CameraSettings');
    cameraMenu.classList.remove('hidden');
}

function hideElementEditionMenu() {
    const editionMenu = document.getElementById('EditionMenu');
    editionMenu.classList.add('hidden');

    const editionContainer = document.getElementById('EditionMenuElemList');
    editionContainer.innerHTML = '';

    //CAM
    const cameraMenu = document.getElementById('CameraSettings');
    cameraMenu.classList.add('hidden');
}

// Show menu for body parts
function showBodyPartsMenu() {

    const bodyPartsMenu = document.getElementById('BodyPartsMenu');
    bodyPartsMenu.classList.remove('hidden');
}

function hideBodyPartsMenu() {

    const bodyPartsMenu = document.getElementById('BodyPartsMenu');
    bodyPartsMenu.classList.add('hidden');
}

// Show menu for body parts
function showCharSelectMenu() {

    const SelectCharMenu = document.getElementById('SelectCharMenu');
    SelectCharMenu.classList.remove('hidden');
}

function hideCharSelectMenu() {

    const SelectCharMenu = document.getElementById('SelectCharMenu');
    SelectCharMenu.classList.add('hidden');
}

//Global Character Menu
function showCharGlobalMenu() {
    const charGlobalMenu = document.getElementById('CharactersMenu');
    charGlobalMenu.classList.remove('hidden');
}

function hideCharGlobalMenu() {
    const charGlobalMenu = document.getElementById('CharactersMenu');
    charGlobalMenu.classList.add('hidden');
}


//Ped list menu
function showPedListMenu() {
    const pedListMenu = document.getElementById('PedSelectionMenu');
    pedListMenu.classList.remove('hidden');
    loadPeds();
}

function hidePedListMenu() {
    const pedListMenu = document.getElementById('PedSelectionMenu');
    pedListMenu.classList.add('hidden');
}

////////////////////////// OUTFIT MENU (MODIFICATION / CREATION) //////////////////////////

// Show and Hide Job Menu
function showOutfitMenu() {
    const outfitMenu = document.getElementById('OutfitMenu');
    outfitMenu.classList.remove('hidden');
    loadCategories();

    //CAM
    loadCameraMenu();
    const cameraMenu = document.getElementById('CameraSettings');
    cameraMenu.classList.remove('hidden');
}

// Hide Outfit Menu
function hideOutfitMenu() {
    const outfitMenu = document.getElementById('OutfitMenu');
    const cameraMenu = document.getElementById('CameraSettings');
    outfitMenu.classList.add('hidden');
    cameraMenu.classList.add('hidden');

    const categoriesContainer = document.getElementById('Categories');
    categoriesContainer.innerHTML = '';

    const itemsContainer = document.getElementById('StyleProperties');
    itemsContainer.innerHTML = '';

    hideContextualMenu();
    const createOutfitBtn = document.getElementById('CreateOutfit');
    if (createOutfitBtn) {
        createOutfitBtn.innerHTML = 'Save - $0.00';
    }
}


////////////////////////// CONTEXTUAL MENU (FOR OUTFIT MODIFICATION / CREATION - TINT, VARIATIONS...) //////////////////////////

// Show Contextual Menu
function showContextualMenu(contextualType) {
    const variationMenu = document.getElementById("VariationSettings");
    const tintMenu = document.getElementById("TintSettings");

    if (contextualType === "variation") {
        // Only show variation menu if it's currently hidden
        if (variationMenu.classList.contains('hidden')) {
            variationMenu.classList.remove('hidden');
            tintMenu.classList.add('hidden');
        }
    } else if (contextualType === "colour") {
        // Only show tint menu if it's currently hidden
        if (tintMenu.classList.contains('hidden')) {
            tintMenu.classList.remove('hidden');
            variationMenu.classList.add('hidden');
        }
    }
}

// Hide Contextual Menu
function hideContextualMenu() {
    const variationSettings = document.getElementById('VariationSettings');
    const tintSettings = document.getElementById('TintSettings');

    if (!variationSettings.classList.contains('hidden')) {
        variationSettings.classList.add('hidden');
    }

    if (!tintSettings.classList.contains('hidden')) {
        tintSettings.classList.add('hidden');
    }
}


// Show Eye Tint Menu
function showEyesContextualMenu() {
    const tintMenu = document.getElementById("TintSettings");
    tintMenu.classList.remove('hidden');
    createEyesColourSelector();
}

// Show Eye Tint Menu
function hideEyesContextualMenu() {
    const tintMenu = document.getElementById("TintSettings");
    tintMenu.classList.add('hidden');
}




//Actual Selected Values
currentSelectedCategorie = 0;
currentSelectedItem = 0;

////////////////////////// EDIT APPARENCE MENU //////////////////////////

function showApparenceMenu() {
    const apparenceMenu = document.getElementById('GlobalCharacterMenu');
    apparenceMenu.classList.remove('hidden');
    createEditApparenceMenu();
    
    // Show/hide Save button based on Second Chance mode
    const saveSecondChanceBtn = document.getElementById('SaveSecondChance');
    const backBtn = document.getElementById('CancelApparenceEdition');
    
    console.log("[SecondChance] showApparenceMenu called, isSecondChanceMode:", isSecondChanceMode);
    console.log("[SecondChance] saveSecondChanceBtn element:", saveSecondChanceBtn);
    
    if (saveSecondChanceBtn) {
        if (isSecondChanceMode) {
            console.log("[SecondChance] Showing Save button");
            saveSecondChanceBtn.classList.remove('hidden');
            saveSecondChanceBtn.style.display = 'block';
            backBtn.setAttribute('data-i18n', 'ui.cancel');
            backBtn.textContent = 'Cancel';
        } else {
            saveSecondChanceBtn.classList.add('hidden');
            backBtn.setAttribute('data-i18n', 'ui.back');
            backBtn.textContent = 'Back';
        }
    } else {
        console.log("[SecondChance] ERROR: SaveSecondChance button not found!");
    }
}

function hideApparenceMenu() {
    const apparenceMenu = document.getElementById('GlobalCharacterMenu');
    apparenceMenu.classList.add('hidden');
}

////////////////////////// SPAWN MENU //////////////////////////

function showSpawnMenu() {
    const spawnMenu = document.getElementById('SpawnMenu');
    spawnMenu.classList.remove('hidden');
    loadSpawnLocations();
}

function hideSpawnMenu() {
    const spawnMenu = document.getElementById('SpawnMenu');
    spawnMenu.classList.add('hidden');
}


////////////////////////// SELECTED CHAR //////////////////////////

function showSelectedCharMenu(charData) {
    const spawnMenu = document.getElementById('ChooseCharacterMenu');
    spawnMenu.classList.remove('hidden');
    loadSelectedCharData(charData);
}

function hideSelectedCharMenu() {
    const spawnMenu = document.getElementById('ChooseCharacterMenu');
    spawnMenu.classList.add('hidden');
}



///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     LOAD CATEGORIES                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


// Load Categories
function loadCategories() {
    const categoriesContainer = document.getElementById('Categories');
    categoriesContainer.innerHTML = '';

    categories.forEach(category => {
        const categoryElem = document.createElement('a');
        categoryElem.classList.add('categoryElem');

        categoryElem.innerHTML = `
                <img src="${category.image}" alt="${category.name}">
        `;

        loadItems();

        categoryElem.addEventListener('click', () => {
            changeCategory(category.id);
            currentSelectedCategorie = category.id;

            //Hide Contextual Datas
            document.getElementById('VariationSettings').classList.add('hidden');
            document.getElementById('TintSettings').classList.add('hidden');

            const cate = document.querySelectorAll('.categoryElem');
            cate.forEach(catego => {
                catego.classList.remove('selected');
            });

            if (currentSelectedCategorie === category.id) {
                categoryElem.classList.add('selected');
            }

        });
        categoriesContainer.appendChild(categoryElem);
    });
}





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       LOAD ITEMS                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function changeCategory(categoryId) {

    items.forEach(item => {

        const itemElem = document.getElementById('item_' + item.id);

        if (item.category === categoryId) {
            itemElem.classList.remove('hidden');
        }
        else {
            itemElem.classList.add('hidden');
        }

    });

};


// Load Items
function loadItems() {
    const itemsContainer = document.getElementById('StyleProperties');
    itemsContainer.innerHTML = '';

    items.forEach(item => {

        if (item.selectorType === "slider") {

            const itemElem = document.createElement('div');
            itemElem.innerHTML = `
                    <div class="styleElem unselectable hidden" id="item_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <p class="sliderValue unselectable" id="sliderValue_${item.id}">Style ${item.value}</p>
                            <div class="sliderElem">
                                <a id="left_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <input type="range" min="0" max="${item.totalAmount}" value="${item.value}" class="slider" id="rangeGlobal_${item.id}">
                                <a id="right_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
                    </div>
                `;

            itemsContainer.appendChild(itemElem);

            //Update Range Background
            updateRangeBackground('rangeGlobal_' + item.id);

            itemElem.addEventListener('click', () => {

                if (currentSelectedItem !== item.id) {

                    //Remove red stroke around all items
                    currentSelectedItem = item.id;
                    const items = document.querySelectorAll('.styleElem');
                    items.forEach(item => {
                        item.classList.remove('selected');

                    });

                    //Show red stoke around selected item
                    const actualItem = document.getElementById('item_' + item.id);
                    actualItem.classList.add('selected');

                    $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                        category: item.id, menu: item.category,
                    }));

                }

            });

            document.getElementById('right_arrow_' + item.id).addEventListener('click', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                if (slider.value !== slider.max) {
                    slider.value = parseInt(slider.value) + 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                    updateRangeBackground('rangeGlobal_' + item.id);
                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));


            });

            document.getElementById('left_arrow_' + item.id).addEventListener('click', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                if (slider.value !== slider.min) {
                    slider.value = parseInt(slider.value) - 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                    updateRangeBackground('rangeGlobal_' + item.id);

                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));


            });

            // document.getElementById('rangeGlobal_' + item.id).addEventListener('input', () => {
            //     const slider = document.getElementById('rangeGlobal_' + item.id);
            //     document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

            //     $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
            //         category: item.id, menu: item.category,,
            //         item: slider.value
            //     }));
            // });

            document.getElementById('rangeGlobal_' + item.id).addEventListener('input', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                updateRangeBackground('rangeGlobal_' + item.id);


            });

            document.getElementById('rangeGlobal_' + item.id).addEventListener('change', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));


            });

        }
        else if (item.selectorType === "selector") {

            const itemElem = document.createElement('div');
            itemElem.innerHTML = `
                    <div class="styleElem typeTwo unselectable" id="item_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <div class="sliderElemTypeTwo">
                                <a id="left_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <p class="sliderValueTypeTwo unselectable" id="sliderValue_${item.id}">Style ${item.value}</p>
                                <input type="range" min="0" max="${item.totalAmount}" value="${item.value}" class="hidden" id="rangeGlobal_${item.id}">
                                <a id="right_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>

                    </div>
                `;

            itemElem.addEventListener('click', () => {

                if (currentSelectedItem !== item.id) {
                    currentSelectedItem = item.id;
                    const items = document.querySelectorAll('.styleElem');
                    items.forEach(item => {
                        item.classList.remove('selected');
                    });


                    if (item.contextual === "variation") {
                        document.getElementById("VariationSettings").classList.remove('hidden');
                        document.getElementById("TintSettings").classList.add('hidden');
                    } else if (item.contextual === "tint") {
                        document.getElementById("TintSettings").classList.remove('hidden');
                        document.getElementById("VariationSettings").classList.add('hidden');
                    }

                    const actualItem = document.getElementById('item_' + item.id);
                    actualItem.classList.add('selected');

                    $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                        item: item.id
                    }));
                }

            });
            itemsContainer.appendChild(itemElem);

            document.getElementById(`right_arrow_${item.id}`).addEventListener('click', () => {
                const slider = document.getElementById(`rangeGlobal_${item.id}`);
                if (slider.value < slider.max) {
                    slider.value = parseInt(slider.value) + 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;
                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));

            });

            document.getElementById(`left_arrow_${item.id}`).addEventListener('click', () => {
                const slider = document.getElementById(`rangeGlobal_${item.id}`);
                if (slider.value > slider.min) {
                    slider.value = parseInt(slider.value) - 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;
                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));
            });


        }
    });
}






///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     LOAD CONTEXTUAL                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Load Contextual Datas
function loadContextualDatas(contextualDatas) {
    // Check if contextualDatas is an array
    if (!Array.isArray(contextualDatas)) {
        console.error('contextualDatas must be an array');
        return;
    }

    contextualDatas.forEach(contextualData => {
        if (contextualData.contextual === "variation") {
            // Check if there is only one variation
            if (contextualData.variationAmount === 1) {

                //Don't show the variation menu
                document.getElementById('ContextSettings').classList.add('hidden');
                document.getElementById('separator_var').classList.add('hidden');

            } else {
                document.getElementById('ContextSettings').classList.remove('hidden');
                document.getElementById('separator_var').classList.remove('hidden');
                //Show the variation menu
                document.getElementById('varSlider').innerHTML = `
                
                <p class="unselectable">Var - <span id="actualVar">${contextualData.variationValue}</span></p>

                <div class="unselectable">

                    <a id="left_arrow_variation" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                    <input type="range" name="Variation" id="rangeVariation" min="1" max="${contextualData.variationAmount}" value="${contextualData.variationValue}">
                    <a id="right_arrow_variation" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                </div>
                `;

                document.getElementById('right_arrow_variation').addEventListener('click', () => {
                    const slider = document.getElementById('rangeVariation');
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('actualVar').innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('left_arrow_variation').addEventListener('click', () => {
                    const slider = document.getElementById('rangeVariation');
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('actualVar').innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('rangeVariation').addEventListener('change', () => {
                    const slider = document.getElementById('rangeVariation');
                    document.getElementById('actualVar').innerText = `${slider.value}`;

                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                        category: contextualData.category
                    }));
                });
            };

            advancedContainer = document.getElementById('ContextSettingsAdvanced');
            advancedContainer.innerHTML = '';

            if (contextualData.advanced === true) {

                document.getElementById('ContextSettingsAdvanced').classList.remove('hidden');
                document.getElementById('separator_colour').classList.remove('hidden');

                contextualData.advancedValues.forEach(advanced => {


                    const tintElem = document.createElement('div');
                    tintElem.classList.add('ContextElem');

                    tintElem.innerHTML = `

                    <p class="unselectable">${advanced.valueName} - <span id="actuelAdvandedVar_${advanced.valueId}">${advanced.valueValue}</span></p>
                    <div class="unselectable">

                    <a id="left_arrow_advanced_${advanced.valueId}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                    <input type="range" name="Advanced_${advanced.valueId}" class="contRange" id="rangeadvanced_${advanced.valueId}" min="${advanced.minValue}" max="${advanced.maxValue}" value="${advanced.valueValue}">
                    <a id="right_arrow_advanced_${advanced.valueId}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                    </div>`;

                    advancedContainer.appendChild(tintElem);

                    document.getElementById('right_arrow_advanced_' + advanced.valueId).addEventListener('click', () => {
                        const slider = document.getElementById('rangeadvanced_' + advanced.valueId);
                        if (slider.value !== slider.max) {
                            slider.value = parseInt(slider.value) + 1;
                            document.getElementById('actuelAdvandedVar_' + advanced.valueId).innerText = `${slider.value}`;
                        }

                        $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                            advancedValue: advanced.valueName,
                            itemValue: slider.value,
                            category: contextualData.category
                        }));
                    });

                    document.getElementById('left_arrow_advanced_' + advanced.valueId).addEventListener('click', () => {
                        const slider = document.getElementById('rangeadvanced_' + advanced.valueId);
                        if (slider.value !== slider.min) {
                            slider.value = parseInt(slider.value) - 1;
                            document.getElementById('actuelAdvandedVar_' + advanced.valueId).innerText = `${slider.value}`;
                        }

                        $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                            advancedValue: advanced.valueName,
                            itemValue: slider.value,
                            category: contextualData.category
                        }));
                    });

                    document.getElementById('rangeadvanced_' + advanced.valueId).addEventListener('change', () => {
                        const slider = document.getElementById('rangeadvanced_' + advanced.valueId);
                        document.getElementById('actuelAdvandedVar_' + advanced.valueId).innerText = `${slider.value}`;

                        $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                            advancedValue: advanced.valueName,
                            itemValue: slider.value,
                            category: contextualData.category
                        }));
                    });

                });

            } else {
                document.getElementById('ContextSettingsAdvanced').classList.add('hidden');
                document.getElementById('separator_colour').classList.add('hidden');
            };

            tintContainer = document.querySelector('.TintList');
            tintContainer.innerHTML = '';

            contextualData.tints.forEach(tint => {


                const tintElem = document.createElement('div');
                tintElem.classList.add('ContextElem');

                tintElem.innerHTML = `

                <p class="unselectable">T${tint.tintId} - <span id="actualTint${tint.tintId}">${tint.value}</span></p>
                <div class="unselectable">

                <a id="left_arrow_tint${tint.tintId}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                <input type="range" name="Tint${tint.tintId}" class="contRange" id="rangeTint${tint.tintId}" min="1" max="255" value="${tint.value}">
                <a id="right_arrow_tint${tint.tintId}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                </div>


                `;

                tintContainer.appendChild(tintElem);

                document.getElementById('right_arrow_tint' + tint.tintId).addEventListener('click', () => {
                    const slider = document.getElementById('rangeTint' + tint.tintId);
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('actualTint' + tint.tintId).innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/tintValue`, JSON.stringify({
                        tintId: tint.tintId,
                        value: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('left_arrow_tint' + tint.tintId).addEventListener('click', () => {
                    const slider = document.getElementById('rangeTint' + tint.tintId);
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('actualTint' + tint.tintId).innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/tintValue`, JSON.stringify({
                        tintId: tint.tintId,
                        value: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('rangeTint' + tint.tintId).addEventListener('change', () => {
                    const slider = document.getElementById('rangeTint' + tint.tintId);
                    document.getElementById('actualTint' + tint.tintId).innerText = `${slider.value}`;

                    $.post(`https://${GetParentResourceName()}/tintValue`, JSON.stringify({
                        tintId: tint.tintId,
                        value: slider.value,
                        category: contextualData.category
                    }));
                });

            });


        } else if (contextualData.contextual === "colour") {


            document.getElementById('TintElement').innerHTML = `
                
                <div class="ElemSliderTint unselectable">

                    <div class="sliderElemTypeTwo">
                        <a id="Colour_left_arrow" class="arrow"><img src="./img/arrow.png"
                                alt="Arrow left"></a>
                        <p class="sliderValueTypeTwo unselectable" id="ColourTintValue">Colour ${contextualData.tintValue}</p>
                        <input type="range" name="Colour" class="contRange hidden" id="ColourRange" min="1" max="${contextualData.tintAmount}" value="${contextualData.tintValue}">
                        <a id="Colour_right_arrow" class="arrow"><img src="./img/arrow.png"
                                alt="Arrow right" style="transform: rotate(180deg);"></a>
                    </div>
                </div>`;

            document.getElementById('Colour_right_arrow').addEventListener('click', () => {
                const slider = document.getElementById('ColourRange');
                if (slider.value !== slider.max) {
                    slider.value = parseInt(slider.value) + 1;
                    document.getElementById('ColourTintValue').innerText = `Colour ${slider.value}`;

                    contextualData.colours.forEach(colour => {

                        document.getElementById('Colour_' + colour.id).classList.remove('selected');

                        if (colour.id === slider.value) {
                            document.getElementById('Colour_' + colour.id).classList.add('selected');
                        };

                    });

                }

                $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                    item: slider.value,
                }));
            });

            document.getElementById('Colour_left_arrow').addEventListener('click', () => {
                const slider = document.getElementById('ColourRange');
                if (slider.value !== slider.min) {
                    slider.value = parseInt(slider.value) - 1;
                    document.getElementById('ColourTintValue').innerText = `Colour ${slider.value}`;

                    contextualData.colours.forEach(colour => {

                        document.getElementById('Colour_' + colour.id).classList.remove('selected');

                        if (colour.id === slider.value) {
                            document.getElementById('Colour_' + colour.id).classList.add('selected');
                        };

                    });
                }

                $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                    item: slider.value,
                }));
            });

            //Empty Colour List
            colourList = document.getElementById('ColourList');
            colourList.innerHTML = '';

            //Create new Colour List
            contextualData.colours.forEach(colour => {

                const colourElem = document.createElement('a');

                colourElem.innerHTML = `<img src="${colour.image}" alt="colour ${colour.id}" id="Colour_${colour.id}" class="Colour">`;
                colourList.appendChild(colourElem);

                document.getElementById('Colour_' + colour.id).addEventListener('click', () => {
                    const slider = document.getElementById('ColourRange');
                    slider.value = parseInt(colour.id);

                    document.getElementById('ColourTintValue').innerText = `Colour ${slider.value}`;

                    contextualData.colours.forEach(colour => {

                        document.getElementById('Colour_' + colour.id).classList.remove('selected');

                        if (colour.id === slider.value) {
                            document.getElementById('Colour_' + colour.id).classList.add('selected');
                        };

                    });


                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                    }));
                });

                if (colour.id === (contextualData.tintValue).toString()) {
                    document.getElementById('Colour_' + colour.id).classList.add('selected');
                };

            });


        }
    });
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                GENERATE EDIT APPARENCRE MENU                                      //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


function createEditApparenceMenu() {

    createGlobalApparenceMenu();
    createSkinColourSelector();
    createEyesColourSelector();

}



function createGlobalApparenceMenu() {

    const globalApparenceMenuList = document.getElementById('GlobalSettingsContainer');
    globalApparenceMenuList.innerHTML = '';

    if (globalApparenceMenu.length === 0) {
        document.getElementById('GlobalSettingsContainer').classList.add('hidden');
        document.getElementById('EditionTitleGlobSet').classList.add('hidden');
        document.getElementById('GlobalSetSeparator').classList.add('hidden');
    }
    else {
        document.getElementById('GlobalSettingsContainer').classList.remove('hidden');
        document.getElementById('EditionTitleGlobSet').classList.remove('hidden');
        document.getElementById('GlobalSetSeparator').classList.remove('hidden');
    }

    globalApparenceMenu.forEach(elem => {
        const globalApparenceMenuElem = document.createElement('div');
        globalApparenceMenuElem.classList.add('GlobalSettingsElem');

        globalApparenceMenuElem.innerHTML = `
                <div class="styleElem unselectable" id="item_app_${elem.id}">
                        <p class="elemTitle">${elem.name}</p>
                        <div class="sliderDiv">
                            <p class="sliderValue unselectable" id="sliderValue_app_${elem.id}">Style ${elem.value}</p>
                            <div class="sliderElem">
                                <a id="left_arrow_app_${elem.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <input type="range" min="1" max="${elem.totalAmount}" value="${elem.value}" class="slider" id="rangeGlobalApp_${elem.id}">
                                <a id="right_arrow_app_${elem.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
                    </div>`;

        globalApparenceMenuList.appendChild(globalApparenceMenuElem);

        updateRangeBackground('rangeGlobalApp_' + elem.id);


        document.getElementById('right_arrow_app_' + elem.id).addEventListener('click', () => {
            const slider = document.getElementById('rangeGlobalApp_' + elem.id);
            if (slider.value !== slider.max) {
                slider.value = parseInt(slider.value) + 1;
                document.getElementById('sliderValue_app_' + elem.id).innerText = `Style ${slider.value}`;
                updateRangeBackground('rangeGlobalApp_' + elem.id);
            }

            $.post(`https://${GetParentResourceName()}/globalApparence`, JSON.stringify({
                item: slider.value,
                elem: elem.id
            }));
        });

        document.getElementById('left_arrow_app_' + elem.id).addEventListener('click', () => {
            const slider = document.getElementById('rangeGlobalApp_' + elem.id);

            if (slider.value !== slider.min) {
                slider.value = parseInt(slider.value) - 1;
                document.getElementById('sliderValue_app_' + elem.id).innerText = `Style ${slider.value}`;
                updateRangeBackground('rangeGlobalApp_' + elem.id);
            }

            $.post(`https://${GetParentResourceName()}/globalApparence`, JSON.stringify({
                item: slider.value,
                elem: elem.id
            }));
        });

        document.getElementById('rangeGlobalApp_' + elem.id).addEventListener('input', () => {
            const slider = document.getElementById('rangeGlobalApp_' + elem.id);
            document.getElementById('sliderValue_app_' + elem.id).innerText = `Style ${slider.value}`;
            updateRangeBackground('rangeGlobalApp_' + elem.id);

            $.post(`https://${GetParentResourceName()}/globalApparence`, JSON.stringify({
                item: slider.value,
                elem: elem.id
            }));
        });
    });

}

function createSkinColourSelector() {

    const skinColourContainer = document.getElementById('skin_colour_selector');

    if (skinApparenceMenu.length === 0) {
        document.getElementById('skin_colour_selector').classList.add('hidden');
        document.getElementById('EditionTitleSkin').classList.add('hidden');
        document.getElementById('SkinSeparator').classList.add('hidden');
    }
    else {
        document.getElementById('skin_colour_selector').classList.remove('hidden');
        document.getElementById('EditionTitleSkin').classList.remove('hidden');
        document.getElementById('SkinSeparator').classList.remove('hidden');
    }

    // Clone and replace container to remove all old event listeners
    const newContainer = skinColourContainer.cloneNode(false);
    skinColourContainer.parentNode.replaceChild(newContainer, skinColourContainer);

    skinApparenceMenu.forEach(elem => {

        newContainer.innerHTML = `

                <div class="TintElem" id="TintElement">

                            <div class="ElemSliderTint">

                                <div class="sliderElemTypeTwo">
                                    <a id="Skin_left_arrow" class="arrow"><img src="./img/arrow.png"
                                            alt="Arrow left"></a>
                                    <p class="sliderValueTypeTwo" id="ColourSkinValue">Colour ${elem.tintValue}</p>
                                    <input type="range" name="Colour" class="contRange hidden" id="SkinColourRange" min="1" max="${elem.tintAmount}" value="${elem.tintValue}">
                                    <a id="Skin_right_arrow" class="arrow"><img src="./img/arrow.png"
                                            alt="Arrow right"style="transform: rotate(180deg);"></a>
                                </div>
                            </div>

                        </div>

                        <div class="TintElem">

                            <div class="coloursDiv" id="ColourListSkin"></div>

                        </div>

                    </div>
            `;

        // Add event listeners only once after innerHTML is set
        setTimeout(() => {
            const rightArrow = document.getElementById('Skin_right_arrow');
            const leftArrow = document.getElementById('Skin_left_arrow');
            
            if (rightArrow) {
                rightArrow.addEventListener('click', () => {
                    const slider = document.getElementById('SkinColourRange');
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('ColourSkinValue').innerText = `Colour ${slider.value}`;

                        elem.colours.forEach(colour => {
                            const colourElem = document.getElementById('ColourSkin_' + colour.id);
                            if (colourElem) {
                                colourElem.classList.remove('selected');
                                if (colour.id === slider.value) {
                                    colourElem.classList.add('selected');
                                }
                            }
                        });
                    }

                    $.post(`https://${GetParentResourceName()}/SkinColourValue`, JSON.stringify({
                        item: slider.value,
                    }));
                });
            }
            
            if (leftArrow) {
                leftArrow.addEventListener('click', () => {
                    const slider = document.getElementById('SkinColourRange');
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('ColourSkinValue').innerText = `Colour ${slider.value}`;

                        elem.colours.forEach(colour => {
                            const colourElem = document.getElementById('ColourSkin_' + colour.id);
                            if (colourElem) {
                                colourElem.classList.remove('selected');
                                if (colour.id === slider.value) {
                                    colourElem.classList.add('selected');
                                }
                            }
                        });
                    }

                    $.post(`https://${GetParentResourceName()}/SkinColourValue`, JSON.stringify({
                        item: slider.value,
                    }));
                });
            }
        }, 0);

        //Empty Colour List
        colourList = document.getElementById('ColourListSkin');
        colourList.innerHTML = '';

        //Create new Colour List
        elem.colours.forEach(colour => {

            const colourElem = document.createElement('a');

            colourElem.innerHTML = `<img src="${colour.image}" alt="colour ${colour.id}" id="ColourSkin_${colour.id}" class="Colour">`;
            colourList.appendChild(colourElem);

            document.getElementById('ColourSkin_' + colour.id).addEventListener('click', () => {
                const slider = document.getElementById('SkinColourRange');
                slider.value = parseInt(colour.id);

                document.getElementById('ColourTintValue').innerText = `Colour ${slider.value}`;

                elem.colours.forEach(colour => {

                    document.getElementById('ColourSkin_' + colour.id).classList.remove('selected');

                    if (colour.id === slider.value) {
                        document.getElementById('ColourSkin_' + colour.id).classList.add('selected');
                    };

                });


                $.post(`https://${GetParentResourceName()}/SkinColourValue`, JSON.stringify({
                    item: slider.value,
                }));
            });

            if (colour.id === (elem.tintValue).toString()) {
                document.getElementById('ColourSkin_' + colour.id).classList.add('selected');
            };

        });


    });

}


function createEyesColourSelector() {

    const eyesColourContainer = document.getElementById('ContextSettingsEyes');

    if (eyeApparenceMenu.length === 0) {
        const eyeSettingsContainer = document.getElementById('EyeSettingsContainer');
        const eyeEditionTitle = document.getElementById('EyeEditionTitle');
        const eyeSeparator = document.getElementById('EyeSeparator');
        if (eyeSettingsContainer) eyeSettingsContainer.classList.add('hidden');
        if (eyeEditionTitle) eyeEditionTitle.classList.add('hidden');
        if (eyeSeparator) eyeSeparator.classList.add('hidden');
        return;
    }

    // Clone and replace container to remove all old event listeners
    const newContainer = eyesColourContainer.cloneNode(false);
    eyesColourContainer.parentNode.replaceChild(newContainer, eyesColourContainer);

    eyeApparenceMenu.forEach(elem => {

        newContainer.innerHTML = `

                <div class="TintElem" id="TintElement">

                            <div class="ElemSliderTint">

                                <div class="sliderElemTypeTwo">
                                    <a id="Eye_left_arrow" class="arrow"><img src="./img/arrow.png"
                                            alt="Arrow left"></a>
                                    <p class="sliderValueTypeTwo" id="ColourEyeValue">Colour ${elem.tintValue}</p>
                                    <input type="range" name="Colour" class="contRange hidden" id="EyeColourRange" min="1" max="${elem.tintAmount}" value="${elem.tintValue}">
                                    <a id="Eye_right_arrow" class="arrow"><img src="./img/arrow.png"
                                            alt="Arrow right"style="transform: rotate(180deg);"></a>
                                </div>
                            </div>

                        </div>

                        <div class="TintElem">

                            <div class="coloursDiv" id="ColourListEye"></div>

                        </div>

                    </div>
            `;

        // Add event listeners only once after innerHTML is set
        setTimeout(() => {
            const rightArrow = document.getElementById('Eye_right_arrow');
            const leftArrow = document.getElementById('Eye_left_arrow');
            
            if (rightArrow) {
                rightArrow.addEventListener('click', () => {
                    const slider = document.getElementById('EyeColourRange');
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('ColourEyeValue').innerText = `Colour ${slider.value}`;

                        elem.colours.forEach(colour => {
                            const colourElem = document.getElementById('ColourEye_' + colour.id);
                            if (colourElem) {
                                colourElem.classList.remove('selected');
                                if (colour.id === slider.value) {
                                    colourElem.classList.add('selected');
                                }
                            }
                        });
                    }

                    $.post(`https://${GetParentResourceName()}/EyeColourValue`, JSON.stringify({
                        item: slider.value,
                    }));
                });
            }
            
            if (leftArrow) {
                leftArrow.addEventListener('click', () => {
                    const slider = document.getElementById('EyeColourRange');
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('ColourEyeValue').innerText = `Colour ${slider.value}`;

                        elem.colours.forEach(colour => {
                            const colourElem = document.getElementById('ColourEye_' + colour.id);
                            if (colourElem) {
                                colourElem.classList.remove('selected');
                                if (colour.id === slider.value) {
                                    colourElem.classList.add('selected');
                                }
                            }
                        });
                    }

                    $.post(`https://${GetParentResourceName()}/EyeColourValue`, JSON.stringify({
                        item: slider.value,
                    }));
                });
            }
        }, 0);

        //Empty Colour List
        colourList = document.getElementById('ColourListEye');
        colourList.innerHTML = '';

        //Create new Colour List
        elem.colours.forEach(colour => {

            const colourElem = document.createElement('a');

            colourElem.innerHTML = `<img src="${colour.image}" alt="colour ${colour.id}" id="ColourEye_${colour.id}" class="Colour">`;
            colourList.appendChild(colourElem);

            document.getElementById('ColourEye_' + colour.id).addEventListener('click', () => {
                const slider = document.getElementById('EyeColourRange');
                slider.value = parseInt(colour.id);

                document.getElementById('ColourEyeValue').innerText = `Colour ${slider.value}`;

                elem.colours.forEach(colour => {

                    document.getElementById('ColourEye_' + colour.id).classList.remove('selected');

                    if (colour.id === slider.value) {
                        document.getElementById('ColourEye_' + colour.id).classList.add('selected');
                    };

                });


                $.post(`https://${GetParentResourceName()}/EyeColourValue`, JSON.stringify({
                    item: slider.value,
                }));
            });

            if (colour.id === (elem.tintValue).toString()) {
                document.getElementById('ColourEye_' + colour.id).classList.add('selected');
            };

        });


    });

}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  GENERATE EDITION MENU                                            //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function createEditionMenu() {

    EditionElem.forEach(elem => {

        titleMenu = document.getElementById('titleEditionMenu');
        titleMenu.innerHTML = elem.name;

        elem.division.forEach(div => {

            const editionContainer = document.getElementById('EditionMenuElemList');
            const editionElement = document.createElement('div');
            editionElement.classList.add('EditionMenuElem');

            editionElement.innerHTML = `
                    <div id="EditionTitle">

                        <img src="${div.icon}" alt="Camera Icon">
                        <h2>${div.name}</h2>


                    </div>

                    <img src="img/separator.png" alt="separator" class="separatorEdition">`;
            editionContainer.appendChild(editionElement);


            div.elements.forEach(element => {

                if (element.type === "matrice") {

                    const editionContainer = document.getElementById('EditionMenuElemList');
                    const matriceContainer = document.createElement('div');

                    matriceContainer.innerHTML = `

                        <div class="matriceContainer" id="matriceContainer_${div.id}_${element.id}">

                        <p>${element.topValueName}</p>

                        <div class="matrice">
                            <p>${element.leftValueName}</p>
                            <div class="matriceElem" id="repere_${div.id}_${element.id}">
                                <div class="selecteur" id="selecteur_${div.id}_${element.id}"></div>
                                <div id="coordonnees_${div.id}_${element.id}" class="hidden">Position: X=0, Y=0</div>
                            </div>
                            <p>${element.rightValueName}</p>
                        </div>

                        <p>${element.bottomValueName}</p>

                    </div>`;

                    editionContainer.appendChild(matriceContainer);

                    loadMatricePosition(element.id, element.startPositionX, element.startPositionY, div.name, div.id, element.XHashes, element.YHashes);



                } else if (element.type === "slider") {


                    const editionContainer = document.getElementById('EditionMenuElemList');
                    const sliderContainer = document.createElement('div');
                    sliderContainer.classList.add('sliderContainer');

                    sliderContainer.innerHTML = `

                        <div class="sliderContainer">

                        <p>${element.leftValueName}</p>

                        <div class="slider">
                            <input type="range" value="${element.startValue}" min="0" max="100" name="Variation" class="creatorSlider" id="slider_editionChar_${element.id}">
                        </div>

                        <p>${element.rightValueName}</p>

                    </div>`;

                    editionContainer.appendChild(sliderContainer);

                    // Send data
                    document.getElementById('slider_editionChar_' + element.id).addEventListener('input', () => {
                        const slider = document.getElementById('slider_editionChar_' + element.id);
                        $.post(`https://${GetParentResourceName()}/sliderCharChange`, JSON.stringify({
                            ElementID: element.id,
                            value: slider.value
                        }));
                    });
                } else if (element.type === "slider_legacy") {

                    const globalApparenceMenuElem = document.createElement('div');
                    globalApparenceMenuElem.classList.add('GlobalSettingsElem');

                    globalApparenceMenuElem.innerHTML = `
                <div class="styleElem unselectable" id="item_app_${div.id}_${element.id}">
                        <p class="elemTitle">${element.name}</p>
                        <div class="sliderDiv">
                            <p class="sliderValue unselectable" id="sliderValue_app_${div.id}_${element.id}">Style ${element.value}</p>
                            <div class="sliderElem">
                                <a id="left_arrow_app_${div.id}_${element.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <input type="range" min="1" max="${element.totalAmount}" value="${element.value}" class="slider" id="rangeGlobalApp_${div.id}_${element.id}">
                                <a id="right_arrow_app_${div.id}_${element.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
                    </div>`;

                    editionContainer.appendChild(globalApparenceMenuElem);

                    updateRangeBackground('rangeGlobalApp_' + div.id + '_' + element.id);


                    document.getElementById('right_arrow_app_' + div.id + '_' + element.id).addEventListener('click', () => {
                        const slider = document.getElementById('rangeGlobalApp_' + div.id + '_' + element.id);
                        if (slider.value !== slider.max) {
                            slider.value = parseInt(slider.value) + 1;
                            document.getElementById('sliderValue_app_' + div.id + '_' + element.id).innerText = `Style ${slider.value}`;
                            updateRangeBackground('rangeGlobalApp_' + div.id + '_' + element.id);
                        }

                        $.post(`https://${GetParentResourceName()}/globalApparence`, JSON.stringify({
                            item: slider.value,
                            elem: element.id
                        }));
                    });

                    document.getElementById('left_arrow_app_' + div.id + '_' + element.id).addEventListener('click', () => {
                        const slider = document.getElementById('rangeGlobalApp_' + div.id + '_' + element.id);

                        if (slider.value !== slider.min) {
                            slider.value = parseInt(slider.value) - 1;
                            document.getElementById('sliderValue_app_' + div.id + '_' + element.id).innerText = `Style ${slider.value}`;
                            updateRangeBackground('rangeGlobalApp_' + div.id + '_' + element.id);
                        }

                        $.post(`https://${GetParentResourceName()}/globalApparence`, JSON.stringify({
                            item: slider.value,
                            elem: element.id
                        }));
                    });

                    document.getElementById('rangeGlobalApp_' + div.id + '_' + element.id).addEventListener('input', () => {
                        const slider = document.getElementById('rangeGlobalApp_' + div.id + '_' + element.id);
                        document.getElementById('sliderValue_app_' + div.id + '_' + element.id).innerText = `Style ${slider.value}`;
                        updateRangeBackground('rangeGlobalApp_' + div.id + '_' + element.id);

                        $.post(`https://${GetParentResourceName()}/globalApparence`, JSON.stringify({
                            item: slider.value,
                            elem: element.id
                        }));
                    });
                }

            });




        });

    });

};


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       INDICATOR MNG                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////// UPDATE LINE POSITION //////////////////////////

function updateLine(index, sens) {


    if (sens === "right") {

        const dot = document.getElementById('dot_' + index);
        const line = document.getElementById('line_' + index);
        const indicator = document.getElementById('head_' + index);

        if (!dot || !line || !indicator) return;

        const dotRect = dot.getBoundingClientRect();
        const indicatorRect = indicator.getBoundingClientRect();

        const startX = dotRect.left + dotRect.width / 2;
        const startY = dotRect.top + dotRect.height / 2;

        const endX = indicatorRect.right;
        const endY = indicatorRect.bottom;

        const distance = Math.min(
            Math.abs(endX - startX),
            Math.abs(endY - startY)
        );

        const dirX = endX > startX ? 1 : -1;
        const dirY = endY > startY ? 1 : -1;

        const inflectionX = startX + (distance * dirX + 35);
        const inflectionY = startY + (distance * dirY);

        const length1 = Math.sqrt(Math.pow(inflectionX - startX, 2) + Math.pow(inflectionY - startY, 2));
        const angle1 = Math.atan2(inflectionY - startY, inflectionX - startX);

        const length2 = Math.sqrt(Math.pow(endX - inflectionX, 2) + Math.pow(endY - inflectionY, 2));
        const angle2 = Math.atan2(endY - inflectionY, endX - inflectionX);

        line.style.width = `${length1}px`;
        line.style.left = `${startX}px`;
        line.style.top = `${startY}px`;
        line.style.transform = `rotate(${angle1}rad)`;

        let line2 = document.getElementById('line2' + index);
        if (!line2) {
            line2 = document.createElement('div');
            line2.id = 'line2' + index;
            line2.className = 'line';
            document.getElementById('pin' + index).appendChild(line2);
        }

        line2.style.width = `${length2}px`;
        line2.style.left = `${inflectionX}px`;
        line2.style.top = `${inflectionY}px`;
        line2.style.transform = `rotate(${angle2}rad)`;


    } else if (sens === "left") {

        const dot = document.getElementById('dot_' + index);
        const line = document.getElementById('line_' + index);
        const indicator = document.getElementById('head_' + index);

        if (!dot || !line || !indicator) return;

        const dotRect = dot.getBoundingClientRect();
        const indicatorRect = indicator.getBoundingClientRect();

        // Point à droite, étiquette à gauche - inversons les positions
        const startX = dotRect.left + dotRect.width / 2;
        const startY = dotRect.top + dotRect.height / 2;

        // On utilise le côté gauche de l'indicateur (étiquette) maintenant
        const endX = indicatorRect.left;
        const endY = indicatorRect.top + indicatorRect.height;

        const distance = Math.min(
            Math.abs(endX - startX),
            Math.abs(endY - startY)
        );

        const dirX = endX > startX ? 1 : -1;
        const dirY = endY > startY ? 1 : -1;

        const inflectionX = startX + (distance * dirX * 1); // Point d'inflexion ajusté
        const inflectionY = startY + (distance * dirY * 1);

        const length1 = Math.sqrt(Math.pow(inflectionX - startX, 2) + Math.pow(inflectionY - startY, 2));
        const angle1 = Math.atan2(inflectionY - startY, inflectionX - startX);

        const length2 = Math.sqrt(Math.pow(endX - inflectionX, 2) + Math.pow(endY - inflectionY, 2));
        const angle2 = Math.atan2(endY - inflectionY, endX - inflectionX);

        line.style.width = `${length1}px`;
        line.style.left = `${startX}px`;
        line.style.top = `${startY}px`;
        line.style.transform = `rotate(${angle1}rad)`;

        let line2 = document.getElementById('line2_' + index); // Correction de l'ID
        if (!line2) {
            line2 = document.createElement('div');
            line2.id = 'line2_' + index; // Correction de l'ID
            line2.className = 'line';
            document.getElementById('pin' + index).appendChild(line2);
        }

        line2.style.width = `${length2}px`;
        line2.style.left = `${inflectionX}px`;
        line2.style.top = `${inflectionY}px`;
        line2.style.transform = `rotate(${angle2}rad)`;

    }
}


function updateSelectLine(index) {

    const dot = document.getElementById('dot_select_' + index);
    const line = document.getElementById('line_select_' + index);
    const indicator = document.getElementById('head_select_' + index);

    if (!dot || !line || !indicator) return;

    const dotRect = dot.getBoundingClientRect();
    const indicatorRect = indicator.getBoundingClientRect();

    const startX = dotRect.left + dotRect.width / 2;
    const startY = dotRect.top + dotRect.height / 2;

    const endX = indicatorRect.right;
    const endY = indicatorRect.bottom;

    const distance = Math.min(
        Math.abs(endX - startX),
        Math.abs(endY - startY)
    );

    const dirX = endX > startX ? 1 : -1;
    const dirY = endY > startY ? 1 : -1;

    const inflectionX = startX + (distance * dirX + 35);
    const inflectionY = startY + (distance * dirY);

    const length1 = Math.sqrt(Math.pow(inflectionX - startX, 2) + Math.pow(inflectionY - startY, 2));
    const angle1 = Math.atan2(inflectionY - startY, inflectionX - startX);

    const length2 = Math.sqrt(Math.pow(endX - inflectionX, 2) + Math.pow(endY - inflectionY, 2));
    const angle2 = Math.atan2(endY - inflectionY, endX - inflectionX);

    line.style.width = `${length1}px`;
    line.style.left = `${startX}px`;
    line.style.top = `${startY}px`;
    line.style.transform = `rotate(${angle1}rad)`;

    let line2 = document.getElementById('line2' + index);
    if (!line2) {
        line2 = document.createElement('div');
        line2.id = 'line2_select' + index;
        line2.className = 'line';
        document.getElementById('pinSelect' + index).appendChild(line2);
    }

    line2.style.width = `${length2}px`;
    line2.style.left = `${inflectionX}px`;
    line2.style.top = `${inflectionY}px`;
    line2.style.transform = `rotate(${angle2}rad)`;



}

////////////////////////// INDICATOR POSITION ON START //////////////////////////

function positionnerElementStart(index, x, y, sens) {
    const container = document.getElementById('pin' + index);

    if (!container) return;

    const pixelX = x * window.innerWidth;
    const pixelY = y * window.innerHeight;

    container.style.left = `${pixelX}px`;
    container.style.top = `${pixelY}px`;

    setTimeout(() => {
        updateLine(index, sens);
    }, 10);

    // return container;
}


function positionnerSelectElementStart(index, x, y, sens) {
    const container = document.getElementById('pinSelect' + index);

    if (!container) return;

    const pixelX = x * window.innerWidth;
    const pixelY = y * window.innerHeight;

    container.style.left = `${pixelX}px`;
    container.style.top = `${pixelY}px`;

    setTimeout(() => {
        updateSelectLine(index, sens);
    }, 10);

    // return container;
}

////////////////////////// UPDATE POSITION OF THE DOT //////////////////////////

function updateDotPos(index, x, y, sens) {
    const container = document.getElementById('pin' + index);
    const dot = document.getElementById('dot_' + index);

    if (!container || !dot) return;

    const pixelX = x * window.innerWidth;
    const pixelY = y * window.innerHeight;

    const parentX = parseFloat(container.style.left);
    const parentY = parseFloat(container.style.top);

    dot.style.position = 'absolute';
    dot.style.left = `${pixelX - parentX}px`;
    dot.style.top = `${pixelY - parentY}px`;

    setTimeout(() => {
        updateLine(index, sens);
    }, 10);

    // return dot;

}

function updateSelectDotPos(index, x, y) {
    const container = document.getElementById('pin_select' + index);
    const dot = document.getElementById('dot_select' + index);

    const pixelX = x * window.innerWidth;
    const pixelY = y * window.innerHeight;

    const parentX = parseFloat(container.style.left);
    const parentY = parseFloat(container.style.top);

    dot.style.position = 'absolute';
    dot.style.left = `${pixelX - parentX}px`;
    dot.style.top = `${pixelY - parentY}px`;

    setTimeout(() => {
        updateSelectLine(index, sens);
    }, 10);

    // return dot;

}



////////////////////////// CREATE (GENERATE) PIN FROM JSON //////////////////////////

function createPin(pinElem) {

    pinElem.forEach(pin => {

        if (pin.direction === "right") {


            const pinContainer = document.getElementById('pinContainer');
            const pinElem = document.createElement('div');
            pinElem.classList.add('container');
            pinElem.id = 'pin' + pin.id;

            pinElem.innerHTML = `
                <div class="head-indicator" id="head_${pin.id}">

                 <p>${pin.name}</p>
                 <img src="./img/arrow.png" alt="arrow" class="right_arrow">
                  
                </div>
                <div id="line_${pin.id}" class="line"></div>
                <div id="dot_${pin.id}" class="dot"></div>

                <div id="Under_menu_${pin.id}" class="under_menu hidden">
                </div>

        `;

            pinContainer.appendChild(pinElem);
            positionnerElementStart(pin.id, pin.startPosition.x, pin.startPosition.y, pin.direction);

            header_act = document.getElementById('pin' + pin.id);

            header_act.addEventListener('mouseenter', () => {
                const underMenu = document.getElementById('Under_menu_' + pin.id);
                underMenu.classList.remove('hidden');
                underMenuAppears(pin.id, "hide");

            });
            header_act.addEventListener('mouseleave', () => {
                const underMenu = document.getElementById('Under_menu_' + pin.id);
                underMenu.classList.add('hidden');
                underMenuAppears(pin.id, "show");
            });



            pin.subElem.forEach(subElem => {
                const underMenu = document.getElementById('Under_menu_' + pin.id);
                const elemUnder = document.createElement('a');
                elemUnder.classList.add('under_elem');
                elemUnder.id = 'elem_under_' + subElem.id;
                elemUnder.innerHTML = subElem.name;
                underMenu.appendChild(elemUnder);

                elemUnder.addEventListener('click', () => {

                    $.post(`https://${GetParentResourceName()}/showEditionMenu`, JSON.stringify({
                        pinId: pin.id,
                        pinName: pin.name,

                        elemId: subElem.id,
                        subElemName: subElem.name
                    }));
                });
            });

        } else if (pin.direction === "left") {


            const pinContainer = document.getElementById('pinContainer');
            const pinElem = document.createElement('div');
            pinElem.classList.add('container-right');
            pinElem.id = 'pin' + pin.id;

            pinElem.innerHTML = `
                <div class="head-indicator-right" id="head_${pin.id}">

                 <img src="./img/arrow.png" alt="arrow" class="right_arrow-right">
                 <p>${pin.name}</p>

                  
                </div>

                <div id="line_${pin.id}" class="line-right"></div>
                <div id="dot_${pin.id}" class="dot-right"></div>

                <div id="Under_menu_${pin.id}" class="under_menu-right hidden">
                </div>

        `;

            pinContainer.appendChild(pinElem);
            positionnerElementStart(pin.id, pin.startPosition.x, pin.startPosition.y, pin.direction);

            header_act = document.getElementById('pin' + pin.id);

            header_act.addEventListener('mouseenter', () => {
                const underMenu = document.getElementById('Under_menu_' + pin.id);
                underMenu.classList.remove('hidden');
                underMenuAppears(pin.id, "hide");

                document.getElementById('Under_menu_' + pin.id).addEventListener('mouseenter', () => {
                    const underMenu = document.getElementById('Under_menu_' + pin.id);
                    underMenu.classList.remove('hidden');
                    underMenuAppears(pin.id, "hide");
                });

                document.getElementById('Under_menu_' + pin.id).addEventListener('mouseleave', () => {
                    const underMenu = document.getElementById('Under_menu_' + pin.id);
                    underMenu.classList.add('hidden');
                    underMenuAppears(pin.id, "show");
                });

            });
            header_act.addEventListener('mouseleave', () => {
                const underMenu = document.getElementById('Under_menu_' + pin.id);
                underMenu.classList.add('hidden');
                underMenuAppears(pin.id, "show");
            });



            pin.subElem.forEach(subElem => {
                const underMenu = document.getElementById('Under_menu_' + pin.id);

                // Create flex wrapper div
                const flexWrapper = document.createElement('div');
                flexWrapper.style.display = 'flex';

                // Create the link element
                const elemUnder = document.createElement('a');
                elemUnder.classList.add('under_elem');
                elemUnder.id = 'elem_under_' + subElem.id;
                elemUnder.innerHTML = subElem.name;

                // Create empty div
                const emptyDiv = document.createElement('div');
                emptyDiv.style.width = '50px';

                // Append elements to the flex wrapper
                flexWrapper.appendChild(elemUnder);
                flexWrapper.appendChild(emptyDiv);

                // Append the flex wrapper to the underMenu
                underMenu.appendChild(flexWrapper);

                elemUnder.addEventListener('click', () => {
                    $.post(`https://${GetParentResourceName()}/showEditionMenu`, JSON.stringify({
                        pinId: pin.id,
                        pinName: pin.name,
                        elemId: subElem.id,
                        subElemName: subElem.name
                    }));
                });
            });


        }

    });



}


////////////////////////// SELECT CHAR PIN CREATOR //////////////////////////

function createPinSelection(pinPerso) {

    const pinsContainer = document.getElementById('selectCharPinContainer');
        pinsContainer.innerHTML = '';

    pinPerso.forEach(pin => {

        if (pin.ExistingChar === true) {

            const pinContainer = document.getElementById('selectCharPinContainer');
            const pinElem = document.createElement('div');
            pinElem.classList.add('container_select');
            pinElem.id = 'pinSelect' + pin.id;

            pinElem.innerHTML = `
                <div class="head-indicator-select" id="head_select_${pin.id}">

                 <p>${pin.name}</p>
                <img src="./img/arrow.png" alt="arrow" class="right_arrow">
                  
                </div>

                </div>

        `;

            pinContainer.appendChild(pinElem);
            positionnerSelectElementStart(pin.id, pin.startPosition.x, pin.startPosition.y, pin.direction);

            header_act = document.getElementById('pinSelect' + pin.id);

            header_act.addEventListener('click', () => {

                $.post(`https://${GetParentResourceName()}/selectedChar`, JSON.stringify({
                    pinId: pin.id,
                    pinName: pin.name,
                }));
            });

        } else if (pin.ExistingChar === false) {


            const pinContainer = document.getElementById('selectCharPinContainer');
            const pinElem = document.createElement('div');
            pinElem.classList.add('container_select');
            pinElem.id = 'pinSelect' + pin.id;

            pinElem.innerHTML = `
                <div class="head-indicator-select" id="head_select_${pin.id}">

                 <p>Create New</p>
                <img src="./img/icons/plus.png" alt="arrow" class="right_arrow" style="transform: scale(1.5);">
                  
                </div>

                </div>

        `;

            pinContainer.appendChild(pinElem);
            positionnerSelectElementStart(pin.id, pin.startPosition.x, pin.startPosition.y, pin.direction);

            header_act = document.getElementById('pinSelect' + pin.id);

            header_act.addEventListener('click', () => {

                $.post(`https://${GetParentResourceName()}/createNewChar`, JSON.stringify({
                }));
            });

        }

    });



}



////////////////////////// SUB MENU ELEMENTS //////////////////////////

function underMenuAppears(pinAct, state) {
    pinElem.forEach(pin => {

        if (state === "hide") {
            if (pin.id !== pinAct) {
                const underMenu = document.getElementById('pin' + pin.id);
                underMenu.classList.add('hidden');
            }
        } else if (state === "show") {
            const underMenu = document.getElementById('pin' + pin.id);
            underMenu.classList.remove('hidden');
        }

    });


}

////////////////////////// UPDATE POSITION OF THE PIN //////////////////////////

function positionPin(pinElem) {
    pinElem.forEach(pin => {
        updateDotPos(pin.id, pin.startPosition.x, pin.startPosition.y, pin.direction);
    });
}

function positionSelectPin(pinElem) {
    pinElem.forEach(pin => {
        updateSelectDotPos(pin.id, pin.startPosition.x, pin.startPosition.y, pin.direction);
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                  LOAD SELECTED CHAR DATA                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////



function loadSelectedCharData(charData) {

    //Past character data inside the menu

    //Name of the character
    document.getElementById('titleSelectedCharactersMenu').innerHTML = charData.name;

    if (globalMenuStructure.CharacterSexe === true && globalMenuStructure.CharacterLore === true && globalMenuStructure.CharacterLore === true) {

        document.getElementById('selectedSeparator').classList.remove('hidden');
        document.getElementById('SelectedEditionTitle').classList.remove('hidden');
    }

    if (globalMenuStructure.CharacterSexe === true) {

        //Sex of the character
        document.getElementById('Selectedsexe_selector').classList.remove('hidden');
        document.getElementById('SelectedsliderValue_sexe_selector').innerHTML = charData.CharacterSex;

    }

    if (globalMenuStructure.CharacterLore === true) {

        //Lore of the character
        document.getElementById('selectedCharacterLore').classList.remove('hidden');
        document.getElementById('selectedCharacterLore').innerHTML = charData.lore;

    }

    if (globalMenuStructure.CharacterLore === true) {


        document.getElementById('SelectedBirthdayContainer').classList.remove('hidden');

        //birthday of the character
        document.getElementById('SelectedCharacterBirthDay').value = charData.DayBirth;
        document.getElementById('SelectedCharacterBirthMonth').value = charData.MonthBirth;
        document.getElementById('SelectedCharacterBirthYear').value = charData.YearBirth;

    }









}



///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       GET CHAR DATA                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


function getCharData() {

    //Name of the character
    characterName = document.getElementById('characterName').value;
    characterSurname = document.getElementById('characterSurname').value;


    //Lore of the character
    characterLore = document.getElementById('characterLore').value;

    //birthday of the character
    characterBirthDay = document.getElementById('characterBirthDay').value;
    characterBirthMonth = document.getElementById('characterBirthMonth').value;
    characterBirthYear = document.getElementById('characterBirthYear').value;

    $.post(`https://${GetParentResourceName()}/CharValues`, JSON.stringify({
        CharacterName: characterName,
        CharacterSurname: characterSurname,
        CharacterLore: characterLore,
        CharacterBirthDay: characterBirthDay,
        CharacterBirthMonth: characterBirthMonth,
        CharacterBirthYear: characterBirthYear,

        CharacterIsAPed: userPed,
        CharacterSexe: userSexe

    }));

}

//Reset all character Info
function resetCharData() {

    //Name of the character
    characterName = document.getElementById('characterName').value = "";
    characterSurname = document.getElementById('characterSurname').value = "";


    //Lore of the character
    characterLore = document.getElementById('characterLore').value = "";

    //birthday of the character
    characterBirthDay = document.getElementById('characterBirthDay').value = '';
    characterBirthMonth = document.getElementById('characterBirthMonth').value = '';
    characterBirthYear = document.getElementById('characterBirthYear').value = '';

    userPed = false;
    loadPedStatus();
    userSexe = "Male";
    loadSexeStatus();

}

function loadPedStatus() {


    const PedVariation = document.getElementById('ped_selector');


    btnSelectPed = document.getElementById('SelectPed');

    if (userPed === "true") {

        btnSelectPed.classList.remove('hidden');

        PedVariation.innerHTML = `

                                    <p class="elemTitle">Play as a ped</p>
                        <div class="sliderDiv">
                            <div class="sliderElemTypeTwo">
                                <a id="left_arrow_ped_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow left"></a>
                                <p class="sliderValueTypeTwo unselectable" id="sliderValue_ped_selector">True</p>
                                <input type="range" min="0" max="1" value="1" class="hidden"
                                    id="rangeGlobal_ped_selector">
                                <a id="right_arrow_ped_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
        `;

        document.getElementById('right_arrow_ped_selector').addEventListener('click', () => {
            userPed = "false";
            loadPedStatus();
            loadCharCreationInputs();

        });

        document.getElementById('left_arrow_ped_selector').addEventListener('click', () => {
            userPed = "false";
            loadPedStatus();
            loadCharCreationInputs();


        });

        btnSelectPed.addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/PedSelection`, JSON.stringify({}));
        });

        $.post(`https://${GetParentResourceName()}/PedTrueFalse`, JSON.stringify({
            userPed: userPed
        }));

    } else {

        btnSelectPed.classList.add('hidden');
        PedVariation.innerHTML = `

           <p class="elemTitle">Play as a ped</p>
                        <div class="sliderDiv">
                            <div class="sliderElemTypeTwo">
                                <a id="left_arrow_ped_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow left"></a>
                                <p class="sliderValueTypeTwo unselectable" id="sliderValue_ped_selector">False</p>
                                <input type="range" min="0" max="1" value="0" class="hidden"
                                    id="rangeGlobal_ped_selector">
                                <a id="right_arrow_ped_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
        `;

        document.getElementById('right_arrow_ped_selector').addEventListener('click', () => {
            userPed = "true";
            loadPedStatus();
            loadCharCreationInputs();

        });

        document.getElementById('left_arrow_ped_selector').addEventListener('click', () => {
            userPed = "true";
            loadPedStatus();
            loadCharCreationInputs();
        });

        $.post(`https://${GetParentResourceName()}/PedTrueFalse`, JSON.stringify({
            userPed: userPed
        }));
    }

}


function loadSexeStatus() {


    const SexeVariation = document.getElementById('sexe_selector');

    if (userSexe === "Male") {

        SexeVariation.innerHTML = `

                                    <p class="elemTitle">Sexe</p>
                        <div class="sliderDiv">
                            <div class="sliderElemTypeTwo">
                                <a id="left_arrow_sexe_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow left"></a>
                                <p class="sliderValueTypeTwo unselectable" id="sliderValue_sexe_selector">Male</p>
                                <input type="range" min="0" max="1" value="1" class="hidden"
                                    id="rangeGlobal_sexe_selector">
                                <a id="right_arrow_sexe_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
        `;

        document.getElementById('right_arrow_sexe_selector').addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/sexeStatusChanged`, JSON.stringify({
                currentSexe: "Female"
            }));
        });

        document.getElementById('left_arrow_sexe_selector').addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/sexeStatusChanged`, JSON.stringify({
                currentSexe: "Female"
            }));
        });

    } else {

        SexeVariation.innerHTML = `

           <p class="elemTitle">Sexe</p>
                        <div class="sliderDiv">
                            <div class="sliderElemTypeTwo">
                                <a id="left_arrow_sexe_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow left"></a>
                                <p class="sliderValueTypeTwo unselectable" id="sliderValue_sexe_selector">Female</p>
                                <input type="range" min="0" max="1" value="1" class="hidden"
                                    id="rangeGlobal_sexe_selector">
                                <a id="right_arrow_sexe_selector" class="arrow"><img src="./img/arrow.png"
                                        alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
        `;

        document.getElementById('right_arrow_sexe_selector').addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/sexeStatusChanged`, JSON.stringify({
                currentSexe: "Male"
            }));
        });

        document.getElementById('left_arrow_sexe_selector').addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/sexeStatusChanged`, JSON.stringify({
                currentSexe: "Male"
            }));
        });
    }

}


function loadCharCreationInputs() {

    //All containes
    const birthdayContainer = document.getElementById('BirthdayContainer');
    const loreContainer = document.getElementById('characterLore');
    const pedContainer = document.getElementById('ped_selector');
    const pedTitle = document.getElementById('PedTitle');
    const pedSeparator = document.getElementById('PedSeparator');
    const sexeContainer = document.getElementById('sexe_selector');

    const editCharacterButton = document.getElementById('EditChar');

    //If Character birthday is enabled = ask the user
    if (globalMenuStructure.CharacterBirthday === true) {
        birthdayContainer.classList.remove('hidden');
    } else {

        birthdayContainer.classList.add('hidden');
    }

    //If Character lore is enabled = ask the user
    if (globalMenuStructure.CharacterLore === true) {
        loreContainer.classList.remove('hidden');
    } else {

        loreContainer.classList.add('hidden');
    }

    //If  Play as a ped is enabled = ask the user
    if (globalMenuStructure.playAsAPed === true) {
        pedContainer.classList.remove('hidden');
        pedTitle.classList.remove('hidden');
        pedSeparator.classList.remove('hidden');
    } else {

        pedContainer.classList.add('hidden');
        pedTitle.classList.add('hidden');
        pedSeparator.classList.add('hidden');
    }

    //If Character sexe is enabled = ask the user
    if (globalMenuStructure.CharacterSexe === true) {
        sexeContainer.classList.remove('hidden');
    } else {

        sexeContainer.classList.add('hidden');
    }

    //If Edit ped is enabled = ask the user
    if (globalMenuStructure.EditPed === false) {

        if (userPed === "true") {
            editCharacterButton.classList.add('hidden');
        }
        else {
            editCharacterButton.classList.remove('hidden');
        }

    } else {

        if (userPed === "true") {
            editCharacterButton.classList.remove('hidden');
        }
        else {
            editCharacterButton.classList.remove('hidden');
        }
    }


}

///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          LOAD PEDS                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

currentSelectedPed = 0;

// Load Items
function loadPeds() {
    const itemsContainer = document.getElementById('PedListContainer');
    itemsContainer.innerHTML = '';

    pedsList.forEach(item => {


        const itemElem = document.createElement('div');
        itemElem.innerHTML = `
                    <div class="styleElem unselectable" id="item_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <p class="sliderValue unselectable" id="sliderValue_${item.id}">Style ${item.value}</p>
                            <div class="sliderElem">
                                <a id="left_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <input type="range" min="1" max="${item.totalAmount}" value="${item.value}" class="slider" id="rangeGlobal_${item.id}">
                                <a id="right_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
                    </div>
                `;

        itemsContainer.appendChild(itemElem);

        updateRangeBackground('rangeGlobal_' + item.id);

        itemElem.addEventListener('click', () => {

            if (currentSelectedPed !== item.id) {
                currentSelectedPed = item.id;
                const items = document.querySelectorAll('.styleElem');
                items.forEach(item => {
                    item.classList.remove('selected');

                });

                const actualItem = document.getElementById('item_' + item.id);
                actualItem.classList.add('selected');

                $.post(`https://${GetParentResourceName()}/pedValue`, JSON.stringify({
                    id: item.id
                }));

            }

        });

        document.getElementById('right_arrow_' + item.id).addEventListener('click', () => {
            const slider = document.getElementById('rangeGlobal_' + item.id);
            if (slider.value !== slider.max) {
                slider.value = parseInt(slider.value) + 1;
                document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                updateRangeBackground('rangeGlobal_' + item.id);
            }

            $.post(`https://${GetParentResourceName()}/pedValue`, JSON.stringify({
                id: item.id,
                item: slider.value
            }));


        });

        document.getElementById('left_arrow_' + item.id).addEventListener('click', () => {
            const slider = document.getElementById('rangeGlobal_' + item.id);
            if (slider.value !== slider.min) {
                slider.value = parseInt(slider.value) - 1;
                document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                updateRangeBackground('rangeGlobal_' + item.id);

            }

            $.post(`https://${GetParentResourceName()}/pedValue`, JSON.stringify({
                id: item.id,
                item: slider.value
            }));


        });

        // document.getElementById('rangeGlobal_' + item.id).addEventListener('input', () => {
        //     const slider = document.getElementById('rangeGlobal_' + item.id);
        //     document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

        //     $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
        //         category: item.id, menu: item.category,,
        //         item: slider.value
        //     }));
        // });

        document.getElementById('rangeGlobal_' + item.id).addEventListener('input', () => {
            const slider = document.getElementById('rangeGlobal_' + item.id);
            document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

            updateRangeBackground('rangeGlobal_' + item.id);


        });

        document.getElementById('rangeGlobal_' + item.id).addEventListener('change', () => {
            const slider = document.getElementById('rangeGlobal_' + item.id);
            $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                category: item.id, menu: item.category,
                item: slider.value
            }));


        });
    });
}

// Search peds
function searchPeds() {
    const searchInput = document.getElementById('searchPed');
    const filter = searchInput.value.toLowerCase();
    const itemsContainer = document.getElementById('PedListContainer');
    const items = itemsContainer.getElementsByClassName('styleElem');

    for (let i = 0; i < items.length; i++) {
        const titleElement = items[i].getElementsByClassName('elemTitle')[0];
        if (titleElement) {
            const txtValue = titleElement.textContent || titleElement.innerText;
            if (txtValue.toLowerCase().indexOf(filter) > -1) {
                items[i].parentElement.style.display = "";
            } else {
                items[i].parentElement.style.display = "none";
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        LOAD CAMERA                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function loadCameraMenu() {

    //NE PAS SUPPRIMER OU REMPLACER JSON LOCAL
    const cameraDatas = [
        {
            "cameraName": 'Z',
            "value": 154
        },
        {
            "cameraName": 'R',
            "value": 180
        }
    ]


    const camContainer = document.querySelector('.CameraList');
    // Clone and replace container to remove all old event listeners
    const newContainer = camContainer.cloneNode(false);
    camContainer.parentNode.replaceChild(newContainer, camContainer);

    cameraDatas.forEach(cam => {


        const camElem = document.createElement('div');
        camElem.classList.add('CamElem');

        camElem.innerHTML = `

                <p class="unselectable">${cam.cameraName}</p>
                <div class="unselectable">

                    <a id="left_arrow_cam_${cam.cameraName}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                    <input type="range" value="${cam.value}" min="1" max="360" name="Variation" class="contRange" id="camRange_${cam.cameraName}">
                    <a id="right_arrow_cam_${cam.cameraName}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                </div>`;

        newContainer.appendChild(camElem);

        document.getElementById('right_arrow_cam_' + cam.cameraName).addEventListener('click', () => {
            const slider = document.getElementById('camRange_' + cam.cameraName);
            if (slider.value !== slider.max) {
                slider.value = parseInt(slider.value) + 1;
            }



            $.post(`https://${GetParentResourceName()}/cameraChange`, JSON.stringify({
                cameraName: cam.cameraName,
                value: slider.value
            }));
        });

        document.getElementById('left_arrow_cam_' + cam.cameraName).addEventListener('click', () => {
            const slider = document.getElementById('camRange_' + cam.cameraName);
            if (slider.value !== slider.min) {
                const slider = document.getElementById('camRange_' + cam.cameraName);
                if (slider.value !== slider.min) {
                    slider.value = parseInt(slider.value) - 1;
                }
            }

            $.post(`https://${GetParentResourceName()}/cameraChange`, JSON.stringify({
                cameraName: cam.cameraName,
                value: slider.value
            }));
        });

        document.getElementById('camRange_' + cam.cameraName).addEventListener('input', () => {
            const slider = document.getElementById('camRange_' + cam.cameraName);

            $.post(`https://${GetParentResourceName()}/cameraChange`, JSON.stringify({
                cameraName: cam.cameraName,
                value: slider.value
            }));
        });

    });

}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        SPAWN MENU                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

actualLocationId = 1;

function loadSpawnLocations() {

    spawnLocationList.forEach(location => {

        if (location.id === actualLocationId) {
            $.post(`https://${GetParentResourceName()}/spawnPreview`, JSON.stringify({
                SpawnLocationId: location.id,
                SpawnLocationName: location.name,
            }));
            const spawnLocationContainer = document.getElementById('SpawnMenu');
            
            // Clone and replace container to remove all old event listeners
            const newContainer = spawnLocationContainer.cloneNode(false);
            spawnLocationContainer.parentNode.replaceChild(newContainer, spawnLocationContainer);
            newContainer.id = 'SpawnMenu';

            newContainer.innerHTML = `

                    <a id="left_arrow_spawn" class="arrow_spawn unselectable"><img src="./img/arrow.png" alt="Arrow right">
                    </a>

                    <div id="city_lore_area">

                        <div id="city_lore_title">
                            <h1>${location.name}</h1>
                        </div>

                        <div id="city_lore_text">
                            <p>${location.description}</p>
                        </div>

                        <a id="spawnCharacter" class="button" style="width: 250px !important;">Spawn</a>

                    </div>


                    <a id="right_arrow_spawn" class="arrow_spawn unselectable"><img src="./img/arrow.png" alt="Arrow right"
                            style="transform: rotate(180deg);">
                    </a>`;

            const spawnCharacter = document.getElementById('spawnCharacter');
            const rightArrow = document.getElementById('right_arrow_spawn');
            const leftArrow = document.getElementById('left_arrow_spawn');
            
            if (spawnCharacter) {
                spawnCharacter.addEventListener('click', () => {
                    $.post(`https://${GetParentResourceName()}/spawnCharacter`, JSON.stringify({
                        SpawnLocationId: location.id,
                        SpawnLocationName: location.name,
                    }));
                });
            }

            if (rightArrow) {
                rightArrow.addEventListener('click', () => {
                    if (actualLocationId !== spawnLocationList.length) {
                        actualLocationId = actualLocationId + 1;
                        loadSpawnLocations();
                    }
                    else {
                        actualLocationId = 1;
                        loadSpawnLocations();
                    }
                });
            }

            if (leftArrow) {
                leftArrow.addEventListener('click', () => {
                    if (actualLocationId !== 1) {
                        actualLocationId = actualLocationId - 1;
                        loadSpawnLocations();
                    }
                    else {
                        actualLocationId = spawnLocationList.length;
                        loadSpawnLocations();
                    }
                });
            }
        }

    });

}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         DOM                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

document.addEventListener('DOMContentLoaded', function () {


    loadPedStatus();
    loadSexeStatus();
    loadCharCreationInputs();

    ////////////////////////// SEARCH FUNCTIONALITY //////////////////////////
    const searchPedInput = document.getElementById('searchPed');
    if (searchPedInput) {
        searchPedInput.addEventListener('input', searchPeds);
    }

    ////////////////////////// CANCEL APPARENCE EDITION //////////////////////////
    CancelApparenceEdition = document.getElementById('CancelApparenceEdition');
    CancelApparenceEdition.addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/CancelApparenceEdition`, JSON.stringify({
            secondChanceMode: isSecondChanceMode
        }));
        isSecondChanceMode = false;
    });

    ////////////////////////// SAVE SECOND CHANCE //////////////////////////
    const saveSecondChanceBtn = document.getElementById('SaveSecondChance');
    if (saveSecondChanceBtn) {
        saveSecondChanceBtn.addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/SaveSecondChance`, JSON.stringify({}));
            isSecondChanceMode = false;
        });
    }

    ////////////////////////// UNDRESS APPARENCE EDITION //////////////////////////
    UndressApparenceEdition = document.getElementById('UndressApparenceEdition');
    UndressApparenceEdition.addEventListener('click', () => {
        hidePedListMenu();
        $.post(`https://${GetParentResourceName()}/UndressApparenceEdition`, JSON.stringify({}));
    });

    ////////////////////////// RESET APPARENCE EDITION //////////////////////////
    document.getElementById('ResetApparenceEdition').addEventListener('click', () => {

        document.getElementById('DeletionConfirmation').classList.remove('hidden');

        document.getElementById('DeletionConfirmation').innerHTML = `

                <div id = "DeletionConfirmationElem" >

                <div id = "DeletionConfirmationContent" >

                <div id="DeletionConfirmationTitle">

                    <h1>Warning!</h1>
                    <p>Are you sure you want to reset your changes?</p>

                </div>

                <div id="DeletionConfirmationInteraction">

                    <a id="cancelResetChanges" class="button_del">Cancel</a>
                    <a id="confirmResetChanges" class="button_del">Reset</a>

                </div>

                </div>

                </div>
        `;

        //Accept Deletion
        document.getElementById('confirmResetChanges').addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/resetApparenceEdition`, JSON.stringify({}));
            document.getElementById('DeletionConfirmation').classList.add('hidden');
        });

        //Cancel Deletion
        document.getElementById('cancelResetChanges').addEventListener('click', () => {
            document.getElementById('DeletionConfirmation').classList.add('hidden');
        });

    });

    ////////////////////////// CANCEL CHARACTER EDITION //////////////////////////
    document.getElementById('CancelCharEdition').addEventListener('click', () => {

        $.post(`https://${GetParentResourceName()}/cancelCharEdition`, JSON.stringify({}));

    });

    ////////////////////////// CANCEL CHARACTER EDITION //////////////////////////
    document.getElementById('CancelCharCreation').addEventListener('click', () => {

        document.getElementById('DeletionConfirmation').classList.remove('hidden');

        document.getElementById('DeletionConfirmation').innerHTML = `

                <div id = "DeletionConfirmationElem" >

                <div id = "DeletionConfirmationContent" >

                <div id="DeletionConfirmationTitle">

                    <h1>Warning!</h1>
                    <p>You will lose all your changes, are you sure?</p>

                </div>

                <div id="DeletionConfirmationInteraction">

                    <a id="cancelStopCreation" class="button_del">Cancel</a>
                    <a id="confirmStopCreation" class="button_del">Continue</a>

                </div>

                </div>

                </div>
        `;

        //Accept Deletion
        document.getElementById('confirmStopCreation').addEventListener('click', () => {
            resetCharData();
            hideCharGlobalMenu();
            $.post(`https://${GetParentResourceName()}/cancelCharCreation`, JSON.stringify({}));
            document.getElementById('DeletionConfirmation').classList.add('hidden');
        });

        //Cancel Deletion
        document.getElementById('cancelStopCreation').addEventListener('click', () => {
            document.getElementById('DeletionConfirmation').classList.add('hidden');
        });

    });


    ////////////////////////// CREATE CHARACTER EDITION //////////////////////////
    CreateChar = document.getElementById('CreateChar');
    CreateChar.addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/CreateChar`, JSON.stringify({}));
    });

    ////////////////////////// CREATE CHARACTER EDITION //////////////////////////
    editChar = document.getElementById('EditChar');
    editChar.addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/EditChart`, JSON.stringify({}));
    });

    ////////////////////////// CANCEL PED SELECTION //////////////////////////
    cancelCharCreation = document.getElementById('CancelPedSelection');
    cancelCharCreation.addEventListener('click', () => {
        hidePedListMenu();
        $.post(`https://${GetParentResourceName()}/cancelPedSelection`, JSON.stringify({}));
    });


    ////////////////////////// PLAY SELECTED CHAR //////////////////////////
    PlaySelectedChar = document.getElementById('PlaySelectedChar');
    PlaySelectedChar.addEventListener('click', () => {
        hidePedListMenu();
        $.post(`https://${GetParentResourceName()}/PlaySelectedChar`, JSON.stringify({}));
    });

    ////////////////////////// DELETE SELECTED CHAR //////////////////////////
    document.getElementById('DeleteSelectedChar').addEventListener('click', () => {

        document.getElementById('DeletionConfirmation').classList.remove('hidden');

        document.getElementById('DeletionConfirmation').innerHTML = `

                <div id = "DeletionConfirmationElem" >

                <div id = "DeletionConfirmationContent" >

                <div id="DeletionConfirmationTitle">

                    <h1>Warning!</h1>
                    <p>Are you sure you want to delete this character?</p>

                </div>

                <div id="DeletionConfirmationInteraction">

                    <a id="cancelCharDeletion" class="button_del">Cancel</a>
                    <a id="confirmCharDeletion" class="button_del">Delete</a>

                </div>

                </div>

                </div>
        `;

        //Accept Deletion
        document.getElementById('confirmCharDeletion').addEventListener('click', () => {
            hidePedListMenu();
            $.post(`https://${GetParentResourceName()}/DeleteSelectedChar`, JSON.stringify({}));
            document.getElementById('DeletionConfirmation').classList.add('hidden');
        });

        //Cancel Deletion
        document.getElementById('cancelCharDeletion').addEventListener('click', () => {
            document.getElementById('DeletionConfirmation').classList.add('hidden');
        });

    });

    ////////////////////////// DELETE SELECTED CHAR //////////////////////////
    CancelSelectedChar = document.getElementById('CancelSelectedChar');
    CancelSelectedChar.addEventListener('click', () => {
        hidePedListMenu();
        $.post(`https://${GetParentResourceName()}/CancelSelectedChar`, JSON.stringify({}));
    });

    document.getElementById('CancelOutfit').addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/backToOutfitList`);
    });
});

////////////////////////// MATRICE POSITION //////////////////////////


function loadMatricePosition(Matrice, startX, startY, itemName, itemId, XHashes, YHashes) {
    const repere = document.getElementById('repere_' + itemId + '_' + Matrice);
    const selecteur = document.getElementById('selecteur_' + itemId + '_' + Matrice);
    const coordonnees = document.getElementById('coordonnees_' + itemId + '_' + Matrice);


    // const repereRect = repere.getBoundingClientRect();
    // const largeurRect = repereRect.width;
    // const hauteurRect = repereRect.height;

    // selecteur.style.left = centreX + 'px';
    // selecteur.style.top = centreY + 'px';


    actualPostionX = startX * 135;
    actualPostionY = startY * 135;

    console.log(actualPostionX, actualPostionY);
    deplacerPoint(actualPostionX, actualPostionY);



    let isDragging = false;

    function deplacerPoint(x, y) {

        x = Math.max(0, Math.min(135, x));
        y = Math.max(0, Math.min(135, y));

        selecteur.style.left = x + 'px';
        selecteur.style.top = y + 'px';

        actualPostionX = x;
        actualPostionY = y;
        coordonnees.textContent = `Position: X=${Math.round(x)}, Y=${Math.round(y)}`;


    }

    repere.addEventListener('click', function (e) {
        if (e.target === selecteur) return;

        const rect = repere.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        deplacerPoint(x, y);

        console.log(actualPostionX / repere.offsetWidth, actualPostionY / repere.offsetHeight);

        $.post(`https://${GetParentResourceName()}/matriceElem`, JSON.stringify({
            item: itemName,
            matriceId: Matrice,
            X: actualPostionX / repere.offsetWidth,
            Y: actualPostionY / repere.offsetHeight,
            XHashes: XHashes,
            YHashes: YHashes
        }));
    });

    selecteur.addEventListener('mousedown', function (e) {
        isDragging = true;
        e.preventDefault();
        selecteur.style.cursor = 'grabbing';
        e.stopPropagation();
    });

    document.addEventListener('mousemove', function (e) {
        if (!isDragging) return;

        const rect = repere.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        deplacerPoint(x, y);

        $.post(`https://${GetParentResourceName()}/matriceElem`, JSON.stringify({
            item: itemName,
            matriceId: Matrice,
            X: actualPostionX / repere.offsetWidth,
            Y: actualPostionY / repere.offsetHeight,
            XHashes: XHashes,
            YHashes: YHashes
        }));
    });

    document.addEventListener('mouseup', function () {
        if (isDragging) {
            isDragging = false;
            selecteur.style.cursor = 'grab';

            //console.log(actualPostionX / repere.offsetWidth, actualPostionY / repere.offsetHeight);


        }


    });

    document.addEventListener('mouseleave', function () {
        if (isDragging) {
            isDragging = false;
            selecteur.style.cursor = 'grab';
        }
    });
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        MESSAGES                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

window.addEventListener('message', (event) => {

    if (event.data.type === 'placeElem') {
        pinElem = event.data.pins;
        showBodyPartsMenu();
        createPin(pinElem);
    } else if (event.data.type === 'updateElem') {
        pinElem = event.data.pins;
        positionPin(pinElem);
    }

    if (event.data.type === 'openSelectCharMenu') {
        pinPerso = event.data.pinsSelectChar;
        showCharSelectMenu();
        createPinSelection(pinPerso);
    } else if (event.data.type === 'updateElemSelectCharMenu') {
        pinPerso = event.data.pinsSelectChar;
        positionSelectPin(pinPerso);
    }

    if (event.data.type === 'hideSelectCharMenu') {
        hideCharSelectMenu();
    }

    if (event.data.type === 'hideBodyPartsMenu') {
        hideBodyPartsMenu();
        const pinContainer = document.getElementById('pinContainer');
        pinContainer.innerHTML = '';
    }


    if (event.data.type === 'showEditionMenu') {
        EditionElem = event.data.edition;
        showElementEditionMenu()
    } else if (event.data.type === 'hideEditionMenu') {
        hideElementEditionMenu();
    }

    if (event.data.type === 'showCharGlobalMenu') {
        // Check if this is Second Chance mode
        if (event.data.secondChanceMode) {
            isSecondChanceMode = true;
        } else {
            isSecondChanceMode = false;
        }
        if (event.data.charInputs) {
            globalMenuStructure = event.data.charInputs;
        }
        showCharGlobalMenu();
    }
    
    // Second Chance: Set the flag, the apparence menu will be opened by openEditApparenceMenu
    if (event.data.type === 'showSecondChanceMenu') {
        console.log("[SecondChance] Received showSecondChanceMenu message");
        isSecondChanceMode = true;
        console.log("[SecondChance] isSecondChanceMode set to:", isSecondChanceMode);
        // showApparenceMenu() will be called by openEditApparenceMenu
    }
    else if (event.data.type === 'hideCharGlobalMenu') {
        hideCharGlobalMenu();
    }
    if (event.data.type === 'changeuserSexe') {
        userSexe = event.data.userSexe;
        loadSexeStatus();
    }
    //Get all character data
    if (event.data.type === 'getAllCharDatas') {
        getCharData();
    }

    //Reset all character data
    if (event.data.type === 'resetCharData') {
        resetCharData();
    }

    //Peds list Menu
    if (event.data.type === 'showPedsList') {
        pedsList = event.data.pedsList;
        showPedListMenu();
    }
    else if (event.data.type === 'hidePedsList') {
        hidePedsList();
    }

    // Open Outfit Menu
    if (event.data.type === "openOutfitMenu") {
        console.log("Activer le menu outfit")
        if (event.data.categories) {
            categories = event.data.categories;
        }

        // if (event.data.menu == "wearable") {
        //     this.document.getElementById('CreateOutfit').classList.add('cache');
        // }
        // else {
        //     this.document.getElementById('CreateOutfit').classList.remove('cache');
        // }

        outfitElemId = event.data.outfitId;

        if (event.data.menu == "modify") {
            menuType = "modify";
        }
        else {
            menuType = "default";
        }

        if (event.data.items) {
            items = event.data.items;
        }
        showOutfitMenu();

    }

    // Close Outfit Menu
    if (event.data.type === "closeOutfitMenu") {
        console.log("Fermer le menu outfit")
        hideOutfitMenu();
    }

    // Open Edit apparence Menu
    if (event.data.type === "openEditApparenceMenu") {
        console.log("Activer le menu apparence")
        if (event.data.skinColours) {
            skinApparenceMenu = event.data.skinColours;
        }

        if (event.data.apparenceMenu) {
            globalApparenceMenu = event.data.apparenceMenu;
        }
        showApparenceMenu();
    } else if (event.data.type === "hideEditApparenceMenu") {
        hideApparenceMenu();
    } else if (event.data.type === "hideGlobalCharacterMenu") {
        hideApparenceMenu();
        isSecondChanceMode = false;
    }


    // Open Spawn Menu
    if (event.data.type === "openSpawnMenu") {
        console.log("Activer le menu apparence")
        if (event.data.spawnLocation) {
            spawnLocationList = event.data.spawnLocation;
        }
        showSpawnMenu();
    } else if (event.data.type === "hideSpawnMenu") {
        hideSpawnMenu();
    }


    // Open Selected Menu
    if (event.data.type === "openSelectedCharMenu") {
        console.log("Activer le menu choix du perso")
        if (event.data.selectedDataChar) {
            showSelectedCharMenu(event.data.selectedDataChar);
        }

    } else if (event.data.type === "hideSelectedCharMenu") {
        hideSelectedCharMenu();
    }

    // Load contextualDatas
    if (event.data.type === "contextualDatas") {

        // Convert to array if it's an object
        const contextualData = Array.isArray(event.data.data) ? event.data.data : [event.data.data];
        const contextualType = contextualData[0]?.contextual
        showContextualMenu(contextualType);
        loadContextualDatas(contextualData);
        console.log("Charger les données de l'item", contextualData);
    }

    // Hide contextualDatas
    if (event.data.type === "hidecontextualDatas") {
        console.log("Cacher le contextuel");
        hideContextualMenu();
    }


    // Open Eye Menu
    if (event.data.type === "openEyesPersoMenu") {
        console.log("Activer le menu choix des yeux du perso")
        if (event.data.eyesColours) {
            eyeApparenceMenu = event.data.eyesColours;
            showEyesContextualMenu();
        }


    } else if (event.data.type === "hideEyesPersoMenu") {
        hideEyesContextualMenu();
    }
});

///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    LOAD RED INPUT                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


function updateRangeBackground(rangeInput) {
    // Utilise un id unique pour chaque style lié à un slider
    const styleId = 'style_' + rangeInput;
    // Supprime l'ancien style s'il existe
    const oldStyle = document.getElementById(styleId);
    if (oldStyle) {
        oldStyle.parentNode.removeChild(oldStyle);
    }

    const rangeInputElem = document.getElementById(rangeInput);
    if (!rangeInputElem) return;
    const value = rangeInputElem.value;
    const min = rangeInputElem.min || 0;
    const max = rangeInputElem.max || 100;
    const percentage = ((value - min) / (max - min)) * 100;

    const backgroundStyle = `
        #${rangeInput} {
            background: linear-gradient(to right, 
                red 0%, 
                red ${percentage}%, 
                #ddd ${percentage}%, 
                #ddd 100%
            ) !important;
        }

        /* Styles supplémentaires pour assurer la compatibilité avec différents navigateurs */
        #${rangeInput}::-webkit-slider-runnable-track {
            background: transparent;
        }
        #${rangeInput}::-moz-range-track {
            background: transparent;
        }
        #${rangeInput}::-ms-track {
            background: transparent;
        }
    `;

    const style = document.createElement('style');
    style.id = styleId;
    style.textContent = backgroundStyle;
    document.head.appendChild(style);
}
