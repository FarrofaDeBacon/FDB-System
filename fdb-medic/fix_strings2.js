const fs = require('fs');

function fixInspectionPanel() {
  let file = fs.readFileSync('ui-svelte/src/components/InspectionPanel.svelte', 'utf8');

  // Fix remaining notifications
  file = file.replace(/showNotification\('Patient condition updated after treatment', 'fa-sync'\);/g, 
    "showNotification(translations?.ui_patientConditionUpdated || 'Patient condition updated after treatment', 'fa-sync');");
  file = file.replace(/showNotification\(event\.data\.data\.message \|\| 'Tool used successfully', 'fa-check-circle'\);/g, 
    "showNotification(event.data.data.message || translations?.ui_toolUsedSuccessfully || 'Tool used successfully', 'fa-check-circle');");
  file = file.replace(/showNotification\(event\.data\.data\?\.message \|\| 'Unable to use tool', 'fa-times-circle'\);/g, 
    "showNotification(event.data.data?.message || translations?.ui_unableToUseTool || 'Unable to use tool', 'fa-times-circle');");

  // Fix Bandages Array
  file = file.replace(/\{ id: 'cloth', name: 'Cloth Strip', desc: 'Basic cloth strip - crude but available', icon: 'fa-band-aid', itemname: 'cloth_band', effectiveness: 60 \},/g, 
    "{ id: 'cloth', name: translations?.ui_item_cloth_name || 'Cloth Strip', desc: translations?.ui_item_cloth_desc || 'Basic cloth strip - crude but available', icon: 'fa-band-aid', itemname: 'cloth_band', effectiveness: 60 },");
  file = file.replace(/\{ id: 'cotton', name: 'Cotton Bandage', desc: 'Standard cotton bandage - reliable frontier medicine', icon: 'fa-band-aid', itemname: 'cotton_band', effectiveness: 75 \},/g, 
    "{ id: 'cotton', name: translations?.ui_item_cotton_name || 'Cotton Bandage', desc: translations?.ui_item_cotton_desc || 'Standard cotton bandage - reliable frontier medicine', icon: 'fa-band-aid', itemname: 'cotton_band', effectiveness: 75 },");
  file = file.replace(/\{ id: 'linen', name: 'Linen Wrap', desc: 'Quality linen wrap - superior absorbency', icon: 'fa-band-aid', itemname: 'linen_band', effectiveness: 85 \},/g, 
    "{ id: 'linen', name: translations?.ui_item_linen_name || 'Linen Wrap', desc: translations?.ui_item_linen_desc || 'Quality linen wrap - superior absorbency', icon: 'fa-band-aid', itemname: 'linen_band', effectiveness: 85 },");
  file = file.replace(/\{ id: 'sterile', name: 'Sterilized Gauze', desc: 'Professional medical gauze - sterile and effective', icon: 'fa-band-aid', itemname: 'sterile_band', effectiveness: 95 \}/g, 
    "{ id: 'sterile', name: translations?.ui_item_sterile_name || 'Sterilized Gauze', desc: translations?.ui_item_sterile_desc || 'Professional medical gauze - sterile and effective', icon: 'fa-band-aid', itemname: 'sterile_band', effectiveness: 95 }");

  // Fix Tourniquets Array
  file = file.replace(/\{ id: 'rope', name: 'Rope Tourniquet', desc: 'Improvised rope tourniquet - rough but effective', icon: 'fa-compress', itemname: 'tourniquet_rope', effectiveness: 70 \},/g, 
    "{ id: 'rope', name: translations?.ui_item_rope_name || 'Rope Tourniquet', desc: translations?.ui_item_rope_desc || 'Improvised rope tourniquet - rough but effective', icon: 'fa-compress', itemname: 'tourniquet_rope', effectiveness: 70 },");
  file = file.replace(/\{ id: 'leather', name: 'Leather Strap', desc: 'Leather strap tourniquet - durable frontier solution', icon: 'fa-compress', itemname: 'tourniquet_leather', effectiveness: 75 \},/g, 
    "{ id: 'leather', name: translations?.ui_item_leather_name || 'Leather Strap', desc: translations?.ui_item_leather_desc || 'Leather strap tourniquet - durable frontier solution', icon: 'fa-compress', itemname: 'tourniquet_leather', effectiveness: 75 },");
  file = file.replace(/\{ id: 'cloth', name: 'Cloth Tourniquet', desc: 'Cloth tourniquet - basic emergency bleeding control', icon: 'fa-compress', itemname: 'tourniquet_cloth', effectiveness: 65 \},/g, 
    "{ id: 'cloth', name: translations?.ui_item_clothT_name || 'Cloth Tourniquet', desc: translations?.ui_item_clothT_desc || 'Cloth tourniquet - basic emergency bleeding control', icon: 'fa-compress', itemname: 'tourniquet_cloth', effectiveness: 65 },");
  file = file.replace(/\{ id: 'medical', name: 'Medical Tourniquet', desc: 'Professional medical tourniquet - hospital grade', icon: 'fa-compress', itemname: 'tourniquet_medical', effectiveness: 95 \}/g, 
    "{ id: 'medical', name: translations?.ui_item_medicalT_name || 'Medical Tourniquet', desc: translations?.ui_item_medicalT_desc || 'Professional medical tourniquet - hospital grade', icon: 'fa-compress', itemname: 'tourniquet_medical', effectiveness: 95 }");

  // Fix Medicines Array
  file = file.replace(/\{ id: 'laudanum', name: 'Laudanum', desc: 'Opium-based painkiller - powerful but addictive', icon: 'fa-prescription-bottle', itemname: 'medicine_laudanum', effectiveness: 85 \},/g, 
    "{ id: 'laudanum', name: translations?.ui_item_laudanum_name || 'Laudanum', desc: translations?.ui_item_laudanum_desc || 'Opium-based painkiller - powerful but addictive', icon: 'fa-prescription-bottle', itemname: 'medicine_laudanum', effectiveness: 85 },");
  file = file.replace(/\{ id: 'morphine', name: 'Morphine Powder', desc: 'Powerful opiate analgesic - strongest painkiller available', icon: 'fa-prescription-bottle', itemname: 'medicine_morphine', effectiveness: 95 \},/g, 
    "{ id: 'morphine', name: translations?.ui_item_morphine_name || 'Morphine Powder', desc: translations?.ui_item_morphine_desc || 'Powerful opiate analgesic - strongest painkiller available', icon: 'fa-prescription-bottle', itemname: 'medicine_morphine', effectiveness: 95 },");
  file = file.replace(/\{ id: 'whiskey', name: 'Medicinal Whiskey', desc: 'Alcohol-based antiseptic and anesthetic - frontier medicine', icon: 'fa-prescription-bottle', itemname: 'medicine_whiskey', effectiveness: 60 \},/g, 
    "{ id: 'whiskey', name: translations?.ui_item_whiskey_name || 'Medicinal Whiskey', desc: translations?.ui_item_whiskey_desc || 'Alcohol-based antiseptic and anesthetic - frontier medicine', icon: 'fa-prescription-bottle', itemname: 'medicine_whiskey', effectiveness: 60 },");
  file = file.replace(/\{ id: 'quinine', name: 'Quinine Powder', desc: 'Antimalarial and fever reducer - specialized treatment', icon: 'fa-prescription-bottle', itemname: 'medicine_quinine', effectiveness: 70 \}/g, 
    "{ id: 'quinine', name: translations?.ui_item_quinine_name || 'Quinine Powder', desc: translations?.ui_item_quinine_desc || 'Antimalarial and fever reducer - specialized treatment', icon: 'fa-prescription-bottle', itemname: 'medicine_quinine', effectiveness: 70 }");

  // Fix Injections Array
  file = file.replace(/\{ id: 'adrenaline', name: 'Adrenaline Shot', desc: 'Cardiac stimulant for emergency resuscitation - use with extreme caution', icon: 'fa-syringe', itemname: 'injection_adrenaline', riskLevel: 'high' \},/g, 
    "{ id: 'adrenaline', name: translations?.ui_item_adrenaline_name || 'Adrenaline Shot', desc: translations?.ui_item_adrenaline_desc || 'Cardiac stimulant for emergency resuscitation - use with extreme caution', icon: 'fa-syringe', itemname: 'injection_adrenaline', riskLevel: 'high' },");
  file = file.replace(/\{ id: 'cocaine', name: 'Cocaine Solution', desc: 'Local anesthetic for surgical procedures - numbs pain effectively', icon: 'fa-syringe', itemname: 'injection_cocaine', riskLevel: 'medium' \},/g, 
    "{ id: 'cocaine', name: translations?.ui_item_cocaine_name || 'Cocaine Solution', desc: translations?.ui_item_cocaine_desc || 'Local anesthetic for surgical procedures - numbs pain effectively', icon: 'fa-syringe', itemname: 'injection_cocaine', riskLevel: 'medium' },");
  file = file.replace(/\{ id: 'strychnine', name: 'Strychnine \(Micro\)', desc: 'Stimulant for paralysis and respiratory failure - extremely dangerous', icon: 'fa-syringe', itemname: 'injection_strychnine', riskLevel: 'extreme' \},/g, 
    "{ id: 'strychnine', name: translations?.ui_item_strychnine_name || 'Strychnine (Micro)', desc: translations?.ui_item_strychnine_desc || 'Stimulant for paralysis and respiratory failure - extremely dangerous', icon: 'fa-syringe', itemname: 'injection_strychnine', riskLevel: 'extreme' },");
  file = file.replace(/\{ id: 'saline', name: 'Salt Water', desc: 'Hydration and blood volume replacement - safe basic treatment', icon: 'fa-syringe', itemname: 'injection_saline', riskLevel: 'low' \}/g, 
    "{ id: 'saline', name: translations?.ui_item_saline_name || 'Salt Water', desc: translations?.ui_item_saline_desc || 'Hydration and blood volume replacement - safe basic treatment', icon: 'fa-syringe', itemname: 'injection_saline', riskLevel: 'low' }");

  // Fix Tool list (thermometer, etc)
  file = file.replace(/\{ name: 'Thermometer', icon: 'fa-thermometer-half', action: 'thermometer', desc: 'Measure body temperature' \},/g, 
    "{ name: translations?.ui_tool_thermometer || 'Thermometer', icon: 'fa-thermometer-half', action: 'thermometer', desc: translations?.ui_tool_thermometer_desc || 'Measure body temperature' },");
  file = file.replace(/\{ name: 'Laudanum', icon: 'fa-prescription-bottle', action: 'laudanum', desc: 'Opium-based painkiller' \},/g, 
    "{ name: translations?.ui_tool_laudanum || 'Laudanum', icon: 'fa-prescription-bottle', action: 'laudanum', desc: translations?.ui_tool_laudanum_desc || 'Opium-based painkiller' },");
  file = file.replace(/\{ name: 'Whiskey', icon: 'fa-wine-bottle', action: 'whiskey', desc: 'Antiseptic and anesthetic' \},/g, 
    "{ name: translations?.ui_tool_whiskey || 'Whiskey', icon: 'fa-wine-bottle', action: 'whiskey', desc: translations?.ui_tool_whiskey_desc || 'Antiseptic and anesthetic' },");
  file = file.replace(/\{ name: 'Field Surgery Kit', icon: 'fa-first-aid', action: 'field-kit', desc: 'Emergency surgical tools' \},/g, 
    "{ name: translations?.ui_tool_surgerykit || 'Field Surgery Kit', icon: 'fa-first-aid', action: 'field-kit', desc: translations?.ui_tool_surgerykit_desc || 'Emergency surgical tools' },");
  file = file.replace(/\{ name: 'Smelling Salts', icon: 'fa-vial', action: 'smelling-salts', desc: 'Revive unconscious patients' \}/g, 
    "{ name: translations?.ui_tool_smellingsalts || 'Smelling Salts', icon: 'fa-vial', action: 'smelling-salts', desc: translations?.ui_tool_smellingsalts_desc || 'Revive unconscious patients' }");

  fs.writeFileSync('ui-svelte/src/components/InspectionPanel.svelte', file);
}

function fixMedicalPanel() {
  let file = fs.readFileSync('ui-svelte/src/components/MedicalPanel.svelte', 'utf8');

  file = file.replace(/<div class="medic-label">Medical <span>Panel<\/span><\/div>/g, 
    '<div class="medic-label">{translations?.ui_medical || \'Medical\'} <span>{translations?.ui_panel || \'Panel\'}</span></div>');

  fs.writeFileSync('ui-svelte/src/components/MedicalPanel.svelte', file);
}

fixInspectionPanel();
fixMedicalPanel();
