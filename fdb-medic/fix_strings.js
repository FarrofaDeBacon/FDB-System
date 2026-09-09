const fs = require('fs');

function fixInspectionPanel() {
  let file = fs.readFileSync('ui-svelte/src/components/InspectionPanel.svelte', 'utf8');

  // Fix applyBandage, applyTourniquet, administerMedicine fetch blocks by relying on translations
  file = file.replace(/showNotification\(`Successfully applied \$\{bandage\?\.name\} to \$\{selectedBodyPart\}`,\s*'fa-check-circle'\);/g, 
    "// Notification handled by medical-treatment-response event");
  file = file.replace(/addTreatmentEntry\(`Applied \$\{bandage\?\.name\} to \$\{selectedBodyPart\} for bleeding control`\);/g, 
    "// Handled by medical-treatment-response");
  file = file.replace(/showNotification\(result\.message \|\| `Failed to apply \$\{bandage\?\.name\}`,\s*'fa-times-circle'\);/g, 
    "showNotification(result.message || `${translations?.ui_failedToApply || 'Failed to apply'} ${bandage?.name}`, 'fa-times-circle');");
  file = file.replace(/showNotification\('Bandage application failed',\s*'fa-times-circle'\)/g, 
    "showNotification(translations?.ui_bandageApplicationFailed || 'Bandage application failed', 'fa-times-circle')");

  file = file.replace(/showNotification\(`Successfully applied \$\{tourniquet\?\.name\} to \$\{selectedBodyPart\}`,\s*'fa-check-circle'\);/g, 
    "// Notification handled by medical-treatment-response event");
  file = file.replace(/addTreatmentEntry\(`Applied \$\{tourniquet\?\.name\} to \$\{selectedBodyPart\} for severe bleeding control`\);/g, 
    "// Handled by medical-treatment-response");
  file = file.replace(/showNotification\(result\.message \|\| `Failed to apply \$\{tourniquet\?\.name\}`,\s*'fa-times-circle'\);/g, 
    "showNotification(result.message || `${translations?.ui_failedToApply || 'Failed to apply'} ${tourniquet?.name}`, 'fa-times-circle');");
  file = file.replace(/showNotification\('Tourniquet application failed',\s*'fa-times-circle'\)/g, 
    "showNotification(translations?.ui_tourniquetApplicationFailed || 'Tourniquet application failed', 'fa-times-circle')");

  file = file.replace(/showNotification\(`Successfully administered \$\{medicine\?\.name\}`,\s*'fa-check-circle'\);/g, 
    "// Notification handled by medical-treatment-response event");
  file = file.replace(/addTreatmentEntry\(`Applied \$\{medicine\?\.name\} for pain management`\);/g, 
    "// Handled by medical-treatment-response");
  file = file.replace(/showNotification\(result\.message \|\| `Failed to administer \$\{medicine\?\.name\}`,\s*'fa-times-circle'\);/g, 
    "showNotification(result.message || `${translations?.ui_failedToAdminister || 'Failed to administer'} ${medicine?.name}`, 'fa-times-circle');");
  file = file.replace(/showNotification\('Medicine application failed',\s*'fa-times-circle'\)/g, 
    "showNotification(translations?.ui_medicineApplicationFailed || 'Medicine application failed', 'fa-times-circle')");

  // Fix giveInjection
  file = file.replace(/window\.postMessage\(\{\s*type:\s*'medical-treatment',\s*action:\s*'give-injection',[\s\S]*?\}\s*,\s*'\*'\);/g,
    `fetch(\`https://\${(window as any).GetParentResourceName()}/medical-treatment\`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'give-injection',
        data: {
          playerId: data.playerId,
          bodyPart: selectedBodyPart,
          itemType: selectedInjectionType,
          itemName: injection?.itemname || injection?.name || 'injection',
          displayName: injection?.name || 'Injection'
        }
      })
    }).catch(() => showNotification(translations?.ui_injectionApplicationFailed || 'Injection application failed', 'fa-times-circle'));`);

  // Fix isScar strings
  file = file.replace(/boneIntegrity: 'Healed - Scar tissue formed',/g, "boneIntegrity: translations?.ui_healedScar || 'Healed - Scar tissue formed',");
  file = file.replace(/softTissue: 'Scar tissue present from previous injury',/g, "softTissue: translations?.ui_scarTissuePresent || 'Scar tissue present from previous injury',");
  file = file.replace(/bloodFlow: 'Normal circulation restored',/g, "bloodFlow: translations?.ui_normalCirculationRestored || 'Normal circulation restored',");
  file = file.replace(/painResponse: 'No active pain - fully healed',/g, "painResponse: translations?.ui_noActivePain || 'No active pain - fully healed',");
  file = file.replace(/swelling: 'None - injury has healed',/g, "swelling: translations?.ui_noneHealed || 'None - injury has healed',");
  file = file.replace(/discoloration: 'Permanent scar tissue visible',/g, "discoloration: translations?.ui_permanentScar || 'Permanent scar tissue visible',");
  file = file.replace(/woundDescription: \`OLD HEALED INJURY: \$\{woundData\.metadata\?\.description \|\| 'Unknown injury'\}\`/g, "woundDescription: `${translations?.ui_oldHealedInjury || 'OLD HEALED INJURY:'} ${woundData.metadata?.description || translations?.ui_unknownInjury || 'Unknown injury'}`");
  file = file.replace(/recommendation: 'No treatment required - wound has fully healed into scar tissue'/g, "recommendation: translations?.ui_noTreatmentScar || 'No treatment required - wound has fully healed into scar tissue'");

  // Fix doctor bag
  file = file.replace(/{ name: 'Stethoscope', icon: 'fa-stethoscope', action: 'stethoscope', desc: 'Check heart and lung sounds' }/g, 
    "{ name: translations?.ui_stethoscope || 'Stethoscope', icon: 'fa-stethoscope', action: 'stethoscope', desc: translations?.ui_stethoscopeDesc || 'Check heart and lung sounds' }");
  file = file.replace(/{ name: 'Reflex Hammer', icon: 'fa-hammer', action: 'reflexes', desc: 'Check nervous system response' }/g, 
    "{ name: translations?.ui_reflexHammer || 'Reflex Hammer', icon: 'fa-hammer', action: 'reflexes', desc: translations?.ui_reflexHammerDesc || 'Check nervous system response' }");
  file = file.replace(/{ name: 'Medical Flashlight', icon: 'fa-lightbulb', action: 'pupils', desc: 'Check pupil response' }/g, 
    "{ name: translations?.ui_medicalFlashlight || 'Medical Flashlight', icon: 'fa-lightbulb', action: 'pupils', desc: translations?.ui_medicalFlashlightDesc || 'Check pupil response' }");

  // Fix VITAL SIGNS RESULTS, etc.
  file = file.replace(/<span>VITAL SIGNS RESULTS<\/span>/g, "<span>{translations?.ui_vitalSignsResults || 'VITAL SIGNS RESULTS'}</span>");
  file = file.replace(/<div>Heart Rate:<\/div>/g, "<div>{translations?.ui_heartRate || 'Heart Rate:'}</div>");
  file = file.replace(/<div>Temperature:<\/div>/g, "<div>{translations?.ui_temperature || 'Temperature:'}</div>");
  file = file.replace(/<div>Breathing:<\/div>/g, "<div>{translations?.ui_breathing || 'Breathing:'}</div>");
  file = file.replace(/<div>Status:<\/div>/g, "<div>{translations?.ui_status || 'Status:'}</div>");
  file = file.replace(/<span>TEMPERATURE CHECK<\/span>/g, "<span>{translations?.ui_temperatureCheck || 'TEMPERATURE CHECK'}</span>");
  file = file.replace(/Click on body parts to perform detailed inspection/g, "{translations?.ui_clickBodyParts || 'Click on body parts to perform detailed inspection'}");
  file = file.replace(/Medical assessment findings:/g, "{translations?.ui_medicalAssessmentFindings || 'Medical assessment findings:'}");
  file = file.replace(/No active treatments/g, "{translations?.ui_noActiveTreatments || 'No active treatments'}");
  file = file.replace(/No assessment history/g, "{translations?.ui_noAssessmentHistory || 'No assessment history'}");
  file = file.replace(/>Item:/g, ">{translations?.ui_item || 'Item:'}");
  file = file.replace(/Applied:/g, "{translations?.ui_appliedLbl || 'Applied:'}");

  fs.writeFileSync('ui-svelte/src/components/InspectionPanel.svelte', file);
}

function fixMedicalPanel() {
  let file = fs.readFileSync('ui-svelte/src/components/MedicalPanel.svelte', 'utf8');

  file = file.replace(/No bandages needed at this time\./g, "{translations?.ui_noBandagesNeeded || 'No bandages needed at this time.'}");
  file = file.replace(/Select Tourniquet Type/g, "{translations?.ui_selectTourniquetType || 'Select Tourniquet Type'}");
  file = file.replace(/Select Severely Bleeding Part/g, "{translations?.ui_selectSeverelyBleedingPart || 'Select Severely Bleeding Part'}");
  file = file.replace(/SEVERE BLEEDING: Level /g, "{translations?.ui_severeBleedingLevel || 'SEVERE BLEEDING: Level '}");
  file = file.replace(/Manage your current treatments/g, "{translations?.ui_manageTreatments || 'Manage your current treatments'}");
  file = file.replace(/No active treatments/g, "{translations?.ui_noActiveTreatments || 'No active treatments'}");
  file = file.replace(/ACTIVE TREATMENTS/g, "{translations?.ui_activeTreatmentsTitle || 'ACTIVE TREATMENTS'}");
  file = file.replace(/APPLY TOURNIQUET/g, "{translations?.ui_applyTourniquetTitle || 'APPLY TOURNIQUET'}");
  file = file.replace(/>Item:/g, ">{translations?.ui_item || 'Item:'}");
  file = file.replace(/Applied:/g, "{translations?.ui_appliedLbl || 'Applied:'}");
  file = file.replace(/\(No bandages in inventory\)/g, "({translations?.ui_noBandagesInInventory || 'No bandages in inventory'})");

  fs.writeFileSync('ui-svelte/src/components/MedicalPanel.svelte', file);
}

fixInspectionPanel();
fixMedicalPanel();
