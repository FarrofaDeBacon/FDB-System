const fs = require('fs');
const path = 'ui-svelte/src/components/InspectionPanel.svelte';
let content = fs.readFileSync(path, 'utf8');

const replacements = [
  { target: '>APPLY TREATMENT', replacement: '>{translations?.ui_applyTreatment || \'APPLY TREATMENT\'}' },
  { target: '>APPLY TOURNIQUET', replacement: '>{translations?.ui_applyTourniquet || \'APPLY TOURNIQUET\'}' },
  { target: '>ADMINISTER INJECTION', replacement: '>{translations?.ui_administerInjection || \'ADMINISTER INJECTION\'}' },
  { target: '>CLOSE BAG', replacement: '>{translations?.ui_closeBag || \'CLOSE BAG\'}' },
  { target: '>CLOSE', replacement: '>{translations?.ui_close || \'CLOSE\'}' },
  { target: '>Detailed Inspection:', replacement: '>{translations?.ui_detailedInspectionLbl || \'Detailed Inspection:\'}' },
  { target: '>+ Bleeding', replacement: '>{translations?.ui_bleedingLbl || \'+ Bleeding\'}' },
  { target: 'Use body inspection and vitals tools to gather information.', replacement: '{translations?.ui_useBodyInspection || \'Use body inspection and vitals tools to gather information.\'}' },
  { target: '>TEMPERATURE CHECK', replacement: '>{translations?.ui_temperatureCheck || \'TEMPERATURE CHECK\'}' }
];

let changed = false;
for (const r of replacements) {
  if (content.includes(r.target)) {
    content = content.replaceAll(r.target, r.replacement);
    changed = true;
    console.log('Replaced', r.target);
  }
}
if (changed) {
  fs.writeFileSync(path, content);
}