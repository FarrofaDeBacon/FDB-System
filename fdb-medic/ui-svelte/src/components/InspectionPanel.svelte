<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import '../assets/css/rightside-inspection.css';
  import weatheredPaper from '../assets/imgs/weathered_paper.png';
  import selectionBoxBg from '../assets/imgs/selection_box_bg_1d.png';
  import '../assets/css/medpanel.css';

  export let data: any = {};
  export let configData: any = {};
  export let translations: any = {};
  export let onClose: () => void;

  let currentView = 'home';
  let notification: { message: string, icon: string } | null = null;
  
  let checkingVitals = false;
  let vitalsProgress = 0;
  let vitalsChecked = false;
  let showVitalsSubMenu = false;
  let vitalsAnimating = false;

  let checkingTemperature = false;
  let temperatureProgress = 0;
  let temperatureChecked = false;
  let showThermometerSubMenu = false;
  let thermometerAnimating = false;

  let showDoctorsBagSubMenu = false;
  let doctorsBagAnimating = false;

  let selectedBandageType: string | null = null;
  let selectedTourniquetType: string | null = null;
  let selectedMedicineType: string | null = null;
  let selectedInjectionType: string | null = null;
  let selectedBodyPart: string | null = null;

  let medicalAssessment: string[] = [];
  let treatmentsApplied: string[] = [];

  let discoveredInjuries: Record<string, any> = {};
  let inspectedBones: Set<string> = new Set();
  let selectedBone: string | null = null;
  let detailedInspectionResults: Record<string, any> = {};
  let hasInspectedFully = false;

  function handleKeyDown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      onClose();
    }
  }

  onMount(() => {
    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('message', handleMessage);

    setTimeout(() => {
      try {
        fetch(`https://${(window as any).GetParentResourceName()}/medical-request`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'check-vitals',
            data: { playerId: data.playerId, playerSource: data.playerSource }
          })
        }).catch(() => {});
      } catch (error) {}
    }, 500);
  });

  onDestroy(() => {
    window.removeEventListener('keydown', handleKeyDown);
    window.removeEventListener('message', handleMessage);
  });

  function handleMessage(event: MessageEvent) {
    const { type, success, message, action, bodyPart, itemName, updatedConditions, playerId, conditions, bandageTypes, tourniquetTypes, medicineTypes, injectionTypes, bodyParts, health, isDead, isUnconscious } = event.data;
    
    if (type === 'medical-treatment-response') {
      if (success) {
        const bodyPartName = bodyPart !== 'patient' ? getBodyPartName(bodyPart) : (translations?.ui_patient || 'patient');
        showNotification(`${translations?.ui_successfullyApplied || 'Successfully applied'} ${itemName} ${translations?.ui_to || 'to'} ${bodyPartName}`, 'fa-check-circle');
        addTreatmentEntry(`${translations?.ui_applied || 'Applied'} ${itemName} ${translations?.ui_to || 'to'} ${bodyPartName}`);
        
        if (action === 'apply-bandage') {
          selectedBandageType = null;
          selectedBodyPart = null;
        } else if (action === 'apply-tourniquet') {
          selectedTourniquetType = null;
          selectedBodyPart = null;
        } else if (action === 'administer-medicine') {
          selectedMedicineType = null;
        } else if (action === 'give-injection') {
          selectedInjectionType = null;
        }
      } else {
        showNotification(message || `${translations?.ui_youDontHave || "You don't have"} ${itemName} ${translations?.ui_inYourInventory || 'in your inventory'}`, 'fa-times-circle');
      }
    } else if (type === 'patient-condition-update') {
      if (playerId === data.playerId) {
        // Real-time update logic
      }
    } else if (type === 'medical-config-data') {
      configData = {
        bandageTypes: bandageTypes || {},
        tourniquetTypes: tourniquetTypes || {},
        medicineTypes: medicineTypes || {},
        injectionTypes: injectionTypes || {},
        bodyParts: bodyParts || {}
      };
    } else if (type === 'vitals-response') {
      updateVitalsFromHealth(health, isDead, isUnconscious);
    } else if (type === 'update-mission-wounds') {
      if (Number(data.playerId) === -1 && event.data.data) {
        const updatedData = event.data.data;
        Object.assign(data, {
          wounds: updatedData.wounds,
          treatments: updatedData.treatments,
          infections: updatedData.infections,
          bandages: updatedData.bandages,
          healthData: updatedData.healthData,
          bloodLevel: updatedData.bloodLevel,
          isBleeding: updatedData.isBleeding
        });
        data = data;
        showNotification(translations?.ui_patientConditionUpdated || 'Patient condition updated after treatment', 'fa-sync');
      }
    } else if (type === 'tool-usage-result') {
      if (event.data.data?.success) {
        showNotification(event.data.data.message || translations?.ui_toolUsedSuccessfully || 'Tool used successfully', 'fa-check-circle');
      } else {
        showNotification(event.data.data?.message || translations?.ui_unableToUseTool || 'Unable to use tool', 'fa-times-circle');
      }
    }
  }

  let currentPatientVitals: { heartRate: number, status: string, description: string, health: number } | null = null;

  function updateVitalsFromHealth(health: number, isDead: boolean, isUnconscious: boolean) {
    let heartRate = 0;
    let status = '';
    let description = '';

    if (isDead) {
      heartRate = 0;
      status = translations?.vitals_noPulseDetected || 'No Pulse Detected';
      description = translations?.vitals_noPulse || 'Patient shows no signs of life. No pulse or breathing detected.';
    } else if (isUnconscious) {
      heartRate = 40 + Math.random() * 20; 
      status = translations?.vitals_weakPulseStatus || 'Weak Pulse';
      description = translations?.vitals_unconsciousPulse || 'Patient is unconscious. Weak, irregular pulse detected.';
    } else {
      const healthPercent = Math.max(0, Math.min(100, health));
      if (healthPercent >= 90) {
        heartRate = 60 + Math.random() * 20;
        status = translations?.vitals_normalStatus || 'Normal';
        description = translations?.vitals_normalPulse || 'Strong, regular pulse. Patient appears stable.';
      } else if (healthPercent >= 75) {
        heartRate = 80 + Math.random() * 20;
        status = translations?.vitals_elevatedStatus || 'Elevated';
        description = translations?.vitals_elevatedPulse || 'Pulse slightly elevated. Patient may be in mild distress.';
      } else if (healthPercent >= 50) {
        heartRate = 100 + Math.random() * 30;
        status = translations?.vitals_tachycardia || 'Tachycardia';
        description = translations?.vitals_fastPulse || 'Rapid pulse detected. Patient shows signs of significant distress.';
      } else if (healthPercent >= 25) {
        heartRate = 120 + Math.random() * 40;
        status = translations?.vitals_severeTachycardia || 'Severe Tachycardia';
        description = translations?.vitals_criticalPulse || 'Dangerously fast pulse. Patient in critical condition.';
      } else if (healthPercent > 0) {
        heartRate = 40 + Math.random() * 30;
        status = translations?.vitals_weakIrregular || 'Weak & Irregular';
        description = translations?.vitals_weakPulse || 'Weak, irregular pulse. Patient is barely clinging to life.';
      }
    }

    heartRate = Math.round(heartRate);

    if (vitalsChecked) {
      addAssessmentEntry(`Updated vital signs: Heart rate ${heartRate} BPM - ${status}`);
      addAssessmentEntry(`Clinical assessment: ${description}`);
    }

    currentPatientVitals = { heartRate, status, description, health };
  }


  $: bandageTypes = Object.keys(configData?.bandageTypes || {}).length > 0 
    ? Object.entries(configData.bandageTypes).map(([key, config]: [string, any]) => ({
        id: key,
        name: config.label || translations?.unknownBandage || 'Unknown Bandage',
        desc: config.description || '',
        icon: 'fa-band-aid',
        itemname: config.itemName || key,
        effectiveness: config.effectiveness || 50
      }))
    : [
        { id: 'cloth', name: translations?.ui_item_cloth_name || 'Cloth Strip', desc: translations?.ui_item_cloth_desc || 'Basic cloth strip - crude but available', icon: 'fa-band-aid', itemname: 'cloth_band', effectiveness: 60 },
        { id: 'cotton', name: translations?.ui_item_cotton_name || 'Cotton Bandage', desc: translations?.ui_item_cotton_desc || 'Standard cotton bandage - reliable frontier medicine', icon: 'fa-band-aid', itemname: 'cotton_band', effectiveness: 75 },
        { id: 'linen', name: translations?.ui_item_linen_name || 'Linen Wrap', desc: translations?.ui_item_linen_desc || 'Quality linen wrap - superior absorbency', icon: 'fa-band-aid', itemname: 'linen_band', effectiveness: 85 },
        { id: 'sterile', name: translations?.ui_item_sterile_name || 'Sterilized Gauze', desc: translations?.ui_item_sterile_desc || 'Professional medical gauze - sterile and effective', icon: 'fa-band-aid', itemname: 'sterile_band', effectiveness: 95 }
      ];

  $: tourniquetTypes = Object.keys(configData?.tourniquetTypes || {}).length > 0 
    ? Object.entries(configData.tourniquetTypes).map(([key, config]: [string, any]) => ({
        id: key,
        name: config.label || translations?.unknownTourniquet || 'Unknown Tourniquet',
        desc: `${translations?.effectiveness || 'Effectiveness'}: ${config.effectiveness || 70}% - ${translations?.maxDuration || 'Max duration'}: ${Math.floor((config.maxDuration || 1200) / 60)} min`,
        icon: 'fa-compress',
        itemname: config.itemName || key,
        effectiveness: config.effectiveness || 70
      }))
    : [
        { id: 'rope', name: translations?.ui_item_rope_name || 'Rope Tourniquet', desc: translations?.ui_item_rope_desc || 'Improvised rope tourniquet - rough but effective', icon: 'fa-compress', itemname: 'tourniquet_rope', effectiveness: 70 },
        { id: 'leather', name: translations?.ui_item_leather_name || 'Leather Strap', desc: translations?.ui_item_leather_desc || 'Leather strap tourniquet - durable frontier solution', icon: 'fa-compress', itemname: 'tourniquet_leather', effectiveness: 75 },
        { id: 'cloth', name: translations?.ui_item_clothT_name || 'Cloth Tourniquet', desc: translations?.ui_item_clothT_desc || 'Cloth tourniquet - basic emergency bleeding control', icon: 'fa-compress', itemname: 'tourniquet_cloth', effectiveness: 65 },
        { id: 'medical', name: translations?.ui_item_medicalT_name || 'Medical Tourniquet', desc: translations?.ui_item_medicalT_desc || 'Professional medical tourniquet - hospital grade', icon: 'fa-compress', itemname: 'tourniquet_medical', effectiveness: 95 }
      ];

  $: medicineTypes = Object.keys(configData?.medicineTypes || {}).length > 0 
    ? Object.entries(configData.medicineTypes).map(([key, config]: [string, any]) => ({
        id: key,
        name: config.label || translations?.unknownMedicine || 'Unknown Medicine',
        desc: config.description || '',
        icon: 'fa-prescription-bottle',
        itemname: config.itemName || key,
        effectiveness: config.effectiveness || 50
      }))
    : [
        { id: 'laudanum', name: translations?.ui_item_laudanum_name || 'Laudanum', desc: translations?.ui_item_laudanum_desc || 'Opium-based painkiller - powerful but addictive', icon: 'fa-prescription-bottle', itemname: 'medicine_laudanum', effectiveness: 85 },
        { id: 'morphine', name: translations?.ui_item_morphine_name || 'Morphine Powder', desc: translations?.ui_item_morphine_desc || 'Powerful opiate analgesic - strongest painkiller available', icon: 'fa-prescription-bottle', itemname: 'medicine_morphine', effectiveness: 95 },
        { id: 'whiskey', name: translations?.ui_item_whiskey_name || 'Medicinal Whiskey', desc: translations?.ui_item_whiskey_desc || 'Alcohol-based antiseptic and anesthetic - frontier medicine', icon: 'fa-prescription-bottle', itemname: 'medicine_whiskey', effectiveness: 60 },
        { id: 'quinine', name: translations?.ui_item_quinine_name || 'Quinine Powder', desc: translations?.ui_item_quinine_desc || 'Antimalarial and fever reducer - specialized treatment', icon: 'fa-prescription-bottle', itemname: 'medicine_quinine', effectiveness: 70 }
      ];

  $: injectionTypes = Object.keys(configData?.injectionTypes || {}).length > 0 
    ? Object.entries(configData.injectionTypes).map(([key, config]: [string, any]) => ({
        id: key,
        name: config.label || translations?.unknownInjection || 'Unknown Injection',
        desc: config.description || '',
        icon: 'fa-syringe',
        itemname: config.itemName || key,
        riskLevel: config.riskLevel || 'medium'
      }))
    : [
        { id: 'adrenaline', name: translations?.ui_item_adrenaline_name || 'Adrenaline Shot', desc: translations?.ui_item_adrenaline_desc || 'Cardiac stimulant for emergency resuscitation - use with extreme caution', icon: 'fa-syringe', itemname: 'injection_adrenaline', riskLevel: 'high' },
        { id: 'cocaine', name: translations?.ui_item_cocaine_name || 'Cocaine Solution', desc: translations?.ui_item_cocaine_desc || 'Local anesthetic for surgical procedures - numbs pain effectively', icon: 'fa-syringe', itemname: 'injection_cocaine', riskLevel: 'medium' },
        { id: 'strychnine', name: translations?.ui_item_strychnine_name || 'Strychnine (Micro)', desc: translations?.ui_item_strychnine_desc || 'Stimulant for paralysis and respiratory failure - extremely dangerous', icon: 'fa-syringe', itemname: 'injection_strychnine', riskLevel: 'extreme' },
        { id: 'saline', name: translations?.ui_item_saline_name || 'Salt Water', desc: translations?.ui_item_saline_desc || 'Hydration and blood volume replacement - safe basic treatment', icon: 'fa-syringe', itemname: 'injection_saline', riskLevel: 'low' }
      ];

  function showNotification(message: string, icon: string = 'fa-check-circle') {
    notification = { message, icon };
    setTimeout(() => {
      notification = null;
    }, 4500);
  }

  function calculateVitals() {
    if (currentPatientVitals) {
      let statusColor = 'var(--status-good)';
      if (currentPatientVitals.heartRate === 0 || currentPatientVitals.status.includes('No Pulse')) {
        statusColor = 'var(--status-critical)';
      } else if (currentPatientVitals.heartRate < 50 || currentPatientVitals.status.includes('Weak')) {
        statusColor = 'var(--status-medium)';
      } else if (currentPatientVitals.heartRate > 120 || currentPatientVitals.status.includes('Tachycardia')) {
        statusColor = 'var(--status-critical)';
      } else if (currentPatientVitals.heartRate > 100 || currentPatientVitals.status.includes('Elevated')) {
        statusColor = 'var(--status-medium)';
      }
      return {
        heartRate: currentPatientVitals.heartRate,
        status: currentPatientVitals.status,
        description: currentPatientVitals.description || currentPatientVitals.status,
        statusColor
      };
    }

    const bloodLevel = data.bloodLevel || 100;
    let baseHeartRate = 70;
    let totalSeverity = 0;

    if (data.wounds) {
      Object.values(data.wounds).forEach((wound: any) => {
        const severity = (wound.severity || 0) + (wound.bleeding || 0) * 2;
        totalSeverity += severity;
      });
    }

    if (bloodLevel < 50) baseHeartRate += 40;
    else if (bloodLevel < 70) baseHeartRate += 25;
    else if (bloodLevel < 90) baseHeartRate += 10;

    if (totalSeverity > 300) baseHeartRate += 20;
    else if (totalSeverity > 150) baseHeartRate += 10;

    const heartRate = Math.min(Math.max(baseHeartRate, 40), 180);

    let status = translations?.ui_stable || 'Stable';
    let statusColor = 'var(--status-good)';

    if (bloodLevel < 30 || totalSeverity > 400) {
      status = translations?.ui_critical || 'Critical';
      statusColor = 'var(--status-critical)';
    } else if (bloodLevel < 60 || totalSeverity > 200) {
      status = translations?.ui_serious || 'Serious';
      statusColor = 'var(--status-medium)';
    } else if (bloodLevel < 80 || totalSeverity > 100) {
      status = translations?.ui_injured || 'Injured';
      statusColor = '#e67e22';
    }

    return { heartRate, status, statusColor, description: status };
  }

  $: vitals = calculateVitals();

  function calculateTemperature() {
    const baseTemp = 98.6;
    const bloodLevel = data.bloodLevel || 100;
    let totalSeverity = 0;

    if (data.wounds) {
      Object.values(data.wounds).forEach((wound: any) => {
        const severity = (wound.severity || 0) + (wound.bleeding || 0) * 2;
        totalSeverity += severity;
      });
    }

    let tempAdjustment = 0;
    if (totalSeverity > 300) tempAdjustment += 3.5;
    else if (totalSeverity > 150) tempAdjustment += 2;
    else if (totalSeverity > 50) tempAdjustment += 1;

    if (bloodLevel < 30) tempAdjustment -= 2;
    else if (bloodLevel < 60) tempAdjustment -= 1;

    return Math.round((baseTemp + tempAdjustment) * 10) / 10;
  }

  function mapFrontendToBackend(frontendBodyPart: string): string {
    const mapping: { [key: string]: string } = {
      'head': 'HEAD', 'spine': 'SPINE', 'upbody': 'UPPER_BODY', 'lowbody': 'LOWER_BODY',
      'larm': 'LARM', 'rarm': 'RARM', 'lhand': 'LHAND', 'rhand': 'RHAND',
      'lleg': 'LLEG', 'rleg': 'RLEG', 'lfoot': 'LFOOT', 'rfoot': 'RFOOT'
    };
    return mapping[frontendBodyPart.toLowerCase()] || frontendBodyPart.toUpperCase();
  }

  function getBodyPartName(bodyPart: string): string {
    const bp = bodyPart.toLowerCase();
    if (translations && translations[`ui_body_${bp}`]) {
      return translations[`ui_body_${bp}`];
    }
    const backendBodyPart = mapFrontendToBackend(bodyPart);
    if (configData?.bodyParts && configData.bodyParts[backendBodyPart]) {
      return configData.bodyParts[backendBodyPart].label || configData.bodyParts[backendBodyPart];
    }
    const fallbackNames: { [key: string]: string } = {
      'head': 'Head', 'spine': 'Spine', 'upbody': 'Upper Body', 'lowbody': 'Lower Body',
      'larm': 'Left Arm', 'rarm': 'Right Arm', 'lhand': 'Left Hand', 'rhand': 'Right Hand',
      'lleg': 'Left Leg', 'rleg': 'Right Leg', 'lfoot': 'Left Foot', 'rfoot': 'Right Foot'
    };
    return fallbackNames[bp] || bodyPart;
  }

  function getWoundData(frontendBodyPart: string) {
    if (!data.wounds) return null;
    const backendBodyPart = mapFrontendToBackend(frontendBodyPart);
    return data.wounds[backendBodyPart] || null;
  }

  function needsMedicine(frontendBodyPart: string): boolean {
    const discoveredWound = discoveredInjuries[frontendBodyPart];
    if (!discoveredWound) return false;
    const hasPain = discoveredWound.severity && discoveredWound.severity > 0;
    if (!hasPain) return false;
    
    if (Number(data.playerId) === -1 && data.wounds) {
      const backendBodyPart = mapFrontendToBackend(frontendBodyPart);
      const currentWound = data.wounds[backendBodyPart];
      if (currentWound && currentWound.treatments) {
        // Lua tables normalize
        const trts = Array.isArray(currentWound.treatments) ? currentWound.treatments : Object.values(currentWound.treatments);
        for (const treatment of trts) {
          if ((treatment as any).status === "active" && (treatment as any).treatsCondition === "pain") {
            return false;
          }
        }
      }
    }
    return true;
  }

  function needsBandage(frontendBodyPart: string): boolean {
    const discoveredWound = discoveredInjuries[frontendBodyPart];
    if (!discoveredWound) return false;
    return discoveredWound.bleeding && discoveredWound.bleeding >= 1 && discoveredWound.bleeding <= 6;
  }

  function isBandaged(frontendBodyPart: string): boolean {
    if (Number(data.playerId) === -1 && data.wounds) {
      const backendBodyPart = mapFrontendToBackend(frontendBodyPart);
      const currentWound = data.wounds[backendBodyPart];
      if (currentWound && currentWound.treatments) {
        const trts = Array.isArray(currentWound.treatments) ? currentWound.treatments : Object.values(currentWound.treatments);
        for (const treatment of trts) {
          if ((treatment as any).status === "active" && (treatment as any).treatsCondition === "bleeding") {
            return true;
          }
        }
      }
    }
    return false;
  }

  function needsTourniquet(frontendBodyPart: string): boolean {
    const discoveredWound = discoveredInjuries[frontendBodyPart];
    if (!discoveredWound) return false;
    return discoveredWound.bleeding && discoveredWound.bleeding >= 60;
  }

  function isTourniqueted(frontendBodyPart: string): boolean {
    if (Number(data.playerId) === -1 && data.wounds) {
      const backendBodyPart = mapFrontendToBackend(frontendBodyPart);
      const currentWound = data.wounds[backendBodyPart];
      if (currentWound && currentWound.treatments) {
        const trts = Array.isArray(currentWound.treatments) ? currentWound.treatments : Object.values(currentWound.treatments);
        for (const treatment of trts) {
          if ((treatment as any).status === "active" && (treatment as any).treatsCondition === "severe_bleeding") {
            return true;
          }
        }
      }
    }
    return false;
  }

  function addAssessmentEntry(entry: string) {
    if (!medicalAssessment.includes(entry)) {
      medicalAssessment = [...medicalAssessment, entry];
    }
  }

  function addTreatmentEntry(treatment: string) {
    const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    treatmentsApplied = [...treatmentsApplied, `${timestamp} - ${treatment}`];
  }

  function closeVitalsSubMenu() {
    vitalsAnimating = false;
    setTimeout(() => { showVitalsSubMenu = false; }, 300);
  }

  function closeDoctorsBagSubMenu() {
    doctorsBagAnimating = false;
    setTimeout(() => { showDoctorsBagSubMenu = false; }, 300);
  }

  function closeThermometerSubMenu() {
    thermometerAnimating = false;
    setTimeout(() => { showThermometerSubMenu = false; }, 300);
  }

  function switchView(view: string) {
    if (view === 'vitals') {
      if (showDoctorsBagSubMenu) closeDoctorsBagSubMenu();
      if (showThermometerSubMenu) closeThermometerSubMenu();
      showVitalsSubMenu = true;
      vitalsAnimating = true;
      return;
    }
    if (view === 'doctors-bag') {
      if (showVitalsSubMenu) closeVitalsSubMenu();
      if (showThermometerSubMenu) closeThermometerSubMenu();
      showDoctorsBagSubMenu = true;
      doctorsBagAnimating = true;
      return;
    }
    
    currentView = view;
    checkingVitals = false;
    vitalsProgress = 0;
    selectedBandageType = null;
    selectedTourniquetType = null;
    selectedMedicineType = null;
    selectedInjectionType = null;
    selectedBodyPart = null;
    
    if (showVitalsSubMenu) closeVitalsSubMenu();
    if (showDoctorsBagSubMenu) closeDoctorsBagSubMenu();
    if (showThermometerSubMenu) closeThermometerSubMenu();
  }

  let vitalsInterval: any;
  function startVitalsCheck() {
    if (checkingVitals) return;
    
    window.postMessage({
      type: 'medical-request',
      action: 'check-vitals',
      data: { playerId: data.playerId, playerSource: data.playerSource }
    }, '*');
    
    checkingVitals = true;
    vitalsProgress = 0;
    
    vitalsInterval = setInterval(() => {
      vitalsProgress += 3.33;
      if (vitalsProgress >= 100) {
        clearInterval(vitalsInterval);
        vitalsChecked = true;
        checkingVitals = false;
        vitalsProgress = 100;
        
        try {
          fetch(`https://${(window as any).GetParentResourceName()}/medical-request`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              action: 'check-vitals',
              data: { playerId: data.playerId, playerSource: data.playerSource }
            })
          }).catch(() => {});
        } catch (e) {}
      }
    }, 100);
  }

  function stopVitalsCheck() {
    checkingVitals = false;
    vitalsProgress = 0;
    if (vitalsInterval) clearInterval(vitalsInterval);
  }

  let tempInterval: any;
  function startTemperatureCheck() {
    if (checkingTemperature) return;
    checkingTemperature = true;
    temperatureProgress = 0;
    
    tempInterval = setInterval(() => {
      temperatureProgress += 3.33;
      if (temperatureProgress >= 100) {
        clearInterval(tempInterval);
        temperatureChecked = true;
        checkingTemperature = false;
        temperatureProgress = 100;
        window.postMessage({ 
          type: 'temperature-checked', 
          data: { playerId: data.playerId, temperature: calculateTemperature() }
        }, '*');
      }
    }, 100);
  }

  function stopTemperatureCheck() {
    checkingTemperature = false;
    temperatureProgress = 0;
    if (tempInterval) clearInterval(tempInterval);
  }

  function applyBandage() {
    if (!selectedBandageType || !selectedBodyPart) return;
    const bandage = bandageTypes.find(b => b.id === selectedBandageType);
    showNotification(`${translations?.ui_checkingInventoryFor || 'Checking inventory for'} ${bandage?.name}...`, 'fa-clock');
    
    try {
      fetch(`https://${(window as any).GetParentResourceName()}/medical-treatment`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'apply-bandage',
          data: {
            playerId: data.playerId,
            bodyPart: selectedBodyPart,
            itemType: selectedBandageType,
            itemName: bandage?.itemname || bandage?.name || 'bandage',
            displayName: bandage?.name || 'Bandage'
          }
        })
      }).then(r => r.json()).then(result => {
        if (result.status === 'success') {
          // Notification handled by medical-treatment-response event
          // Handled by medical-treatment-response
          selectedBandageType = null;
          selectedBodyPart = null;
        } else {
          showNotification(result.message || `${translations?.ui_failedToApply || 'Failed to apply'} ${bandage?.name}`, 'fa-times-circle');
        }
      }).catch(() => showNotification(translations?.ui_bandageApplicationFailed || 'Bandage application failed', 'fa-times-circle'));
    } catch (e) {}
  }

  function applyTourniquet() {
    if (!selectedTourniquetType || !selectedBodyPart) return;
    const tourniquet = tourniquetTypes.find(t => t.id === selectedTourniquetType);
    showNotification(`${translations?.ui_checkingInventoryFor || 'Checking inventory for'} ${tourniquet?.name}...`, 'fa-clock');
    
    try {
      fetch(`https://${(window as any).GetParentResourceName()}/medical-treatment`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'apply-tourniquet',
          data: {
            playerId: data.playerId,
            bodyPart: selectedBodyPart,
            itemType: selectedTourniquetType,
            itemName: tourniquet?.itemname || tourniquet?.name || 'tourniquet',
            displayName: tourniquet?.name || 'Tourniquet'
          }
        })
      }).then(r => r.json()).then(result => {
        if (result.status === 'success') {
          // Notification handled by medical-treatment-response event
          // Handled by medical-treatment-response
          selectedTourniquetType = null;
          selectedBodyPart = null;
        } else {
          showNotification(result.message || `${translations?.ui_failedToApply || 'Failed to apply'} ${tourniquet?.name}`, 'fa-times-circle');
        }
      }).catch(() => showNotification(translations?.ui_tourniquetApplicationFailed || 'Tourniquet application failed', 'fa-times-circle'));
    } catch (e) {}
  }

  function administerMedicine() {
    if (!selectedMedicineType) return;
    const medicine = medicineTypes.find(m => m.id === selectedMedicineType);
    showNotification(`${translations?.ui_checkingInventoryFor || 'Checking inventory for'} ${medicine?.name}...`, 'fa-clock');
    
    try {
      fetch(`https://${(window as any).GetParentResourceName()}/medical-treatment`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'administer-medicine',
          data: {
            playerId: data.playerId,
            bodyPart: 'patient',
            itemType: selectedMedicineType,
            itemName: medicine?.itemname || medicine?.name || 'medicine',
            displayName: medicine?.name || 'Medicine'
          }
        })
      }).then(r => r.json()).then(result => {
        if (result.status === 'success') {
          // Notification handled by medical-treatment-response event
          // Handled by medical-treatment-response
          selectedMedicineType = null;
        } else {
          showNotification(result.message || `${translations?.ui_failedToAdminister || 'Failed to administer'} ${medicine?.name}`, 'fa-times-circle');
        }
      }).catch(() => showNotification(translations?.ui_medicineApplicationFailed || 'Medicine application failed', 'fa-times-circle'));
    } catch (e) {}
  }

  function giveInjection() {
    if (!selectedInjectionType || !selectedBodyPart) return;
    const injection = injectionTypes.find(i => i.id === selectedInjectionType);
    
    fetch(`https://${(window as any).GetParentResourceName()}/medical-treatment`, {
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
    }).catch(() => showNotification(translations?.ui_injectionApplicationFailed || 'Injection application failed', 'fa-times-circle'));
    
    showNotification(`${translations?.ui_checkingInventoryFor || 'Checking inventory for'} ${injection?.name}...`, 'fa-clock');
  }

  function inspectBodyPart(bodyPart: string) {
    selectedBone = bodyPart;
    inspectedBones.add(bodyPart);
    inspectedBones = inspectedBones;
    
    const woundData = getWoundData(bodyPart);

    if (woundData && !woundData.isScar && ((woundData.severity || 0) > 3 || (woundData.bleeding || 0) > 2)) {
      discoveredInjuries[bodyPart] = woundData;
      discoveredInjuries = discoveredInjuries;
    }
    
    const allBodyParts = ['head', 'spine', 'upbody', 'lowbody', 'larm', 'rarm', 'lhand', 'rhand', 'lleg', 'rleg', 'lfoot', 'rfoot'];
    if (inspectedBones.size >= allBodyParts.length * 0.8) {
      hasInspectedFully = true;
    }
    
    const generateDetailedReport = () => {
      if (!woundData) {
        return {
          boneIntegrity: translations?.ui_normalBoneIntegrity || 'Normal',
          softTissue: translations?.ui_noVisibleDamage || 'No visible damage',
          bloodFlow: translations?.ui_normalCirculationReport || 'Normal circulation',
          painResponse: translations?.ui_noSignificantPain || 'No significant pain response',
          swelling: translations?.ui_noneDetected || 'None detected',
          discoloration: translations?.ui_normalSkin || 'Normal skin tone',
          woundDescription: translations?.ui_noWoundsDetected || 'No wounds detected in this area',
          recommendation: translations?.ui_noImmediateTreatment || 'No immediate treatment required'
        };
      }

      if (woundData.isScar) {
        return {
          boneIntegrity: translations?.ui_healedScar || 'Healed - Scar tissue formed',
          softTissue: translations?.ui_scarTissuePresent || 'Scar tissue present from previous injury',
          bloodFlow: translations?.ui_normalCirculationRestored || 'Normal circulation restored',
          painResponse: translations?.ui_noActivePain || 'No active pain - fully healed',
          swelling: translations?.ui_noneHealed || 'None - injury has healed',
          discoloration: translations?.ui_permanentScar || 'Permanent scar tissue visible',
          woundDescription: `${translations?.ui_oldHealedInjury || 'OLD HEALED INJURY:'} ${woundData.text || translations?.ui_unknownInjury || 'Unknown injury'}`,
          recommendation: translations?.ui_noTreatmentScar || 'No treatment required - wound has fully healed into scar tissue'
        };
      }

      const severity = woundData.severity || 0;
      const bleeding = woundData.bleeding || 0;
      
      const getPainDesc = (level: number) => {
        if (level === 0) return translations?.ui_noPain || 'No pain';
        return translations?.[`ui_severity_${level}`] || data.injuryStates?.[level]?.pain || `Pain level ${level}`;
      };
      
      const getBleedingDesc = (level: number) => {
        if (level === 0) return translations?.ui_noBleeding || 'No bleeding';
        return translations?.[`ui_bleeding_${level}`] || data.injuryStates?.[level]?.bleeding || `Bleeding level ${level}`;
      };
      
      const getTreatmentRecommendation = (painLvl: number, bleedingLvl: number) => {
        if (bleedingLvl > 0 && painLvl > 0) {
          const maxLevel = Math.max(painLvl, bleedingLvl);
          if (translations?.[`ui_rec_combined_${maxLevel}`]) return translations[`ui_rec_combined_${maxLevel}`];
          if (data.injuryStates?.[maxLevel]?.unifiedDesc) return data.injuryStates[maxLevel].unifiedDesc;
          return translations?.ui_rec_combined_default || 'Combined pain and bleeding treatment needed';
        } else if (bleedingLvl > 0) {
          if (translations?.[`ui_rec_bleed_${bleedingLvl}`]) return translations[`ui_rec_bleed_${bleedingLvl}`];
          if (data.injuryStates?.[bleedingLvl]?.bleedDesc) return data.injuryStates[bleedingLvl].bleedDesc;
          if (bleedingLvl >= 8) return translations?.ui_rec_bleed_urgent || 'URGENT: Control bleeding immediately - life threatening';
          if (bleedingLvl >= 6) return translations?.ui_rec_bleed_severe || 'Apply tourniquet or pressure bandage to stop bleeding';
          if (bleedingLvl >= 4) return translations?.ui_rec_bleed_moderate || 'Apply bandage to control bleeding';
          return translations?.ui_rec_bleed_minor || 'Monitor bleeding, apply basic bandage if needed';
        } else if (painLvl > 0) {
          if (translations?.[`ui_rec_pain_${painLvl}`]) return translations[`ui_rec_pain_${painLvl}`];
          if (data.injuryStates?.[painLvl]?.painDesc) return data.injuryStates[painLvl].painDesc;
          if (painLvl >= 8) return translations?.ui_rec_pain_urgent || 'URGENT: Severe pain management required - administer strong painkillers';
          if (painLvl >= 6) return translations?.ui_rec_pain_severe || 'Significant pain management needed - use pain medication';
          if (painLvl >= 4) return translations?.ui_rec_pain_moderate || 'Apply pain relief measures - basic painkillers recommended';
          return translations?.ui_rec_pain_minor || 'Monitor discomfort, rest and basic pain relief if needed';
        }
        return translations?.ui_rec_none || 'No immediate treatment required';
      };
      
      const totalSeverity = severity + (bleeding * 2);
      
      return {
        boneIntegrity: severity >= 75 ? (translations?.ui_possibleFracture || 'Possible fracture detected') : severity >= 50 ? (translations?.ui_boneBruising || 'Bone bruising suspected') : (translations?.ui_normalBone || 'Normal'),
        softTissue: bleeding > 0 ? getBleedingDesc(bleeding) : severity > 0 ? (translations?.ui_contusionsPresent ? translations.ui_contusionsPresent.replace('{desc}', getPainDesc(severity)) : `Contusions present (${getPainDesc(severity)})`) : (translations?.ui_noVisibleDamage || 'No visible damage'),
        bloodFlow: bleeding > 6 ? (translations?.ui_activeBleeding ? translations.ui_activeBleeding.replace('{desc}', getBleedingDesc(bleeding)) : `${translations?.ui_activeBleedingFallback || 'Active bleeding:'} ${getBleedingDesc(bleeding)}`) : bleeding > 0 ? (translations?.ui_bleedingObserved ? translations.ui_bleedingObserved.replace('{desc}', getBleedingDesc(bleeding)) : `${getBleedingDesc(bleeding)} ${translations?.ui_observed || 'observed'}`) : (translations?.ui_normalCirculation || 'Normal circulation'),
        painResponse: severity > 0 ? (translations?.ui_patientReports ? translations.ui_patientReports.replace('{desc}', getPainDesc(severity)) : `Patient reports: ${getPainDesc(severity)}`) : (translations?.ui_noSignificantPain || 'No significant pain response'),
        swelling: totalSeverity > 12 ? (translations?.ui_significantSwelling || 'Significant swelling present') : totalSeverity > 6 ? (translations?.ui_minorSwelling || 'Minor swelling detected') : (translations?.ui_noneDetected || 'None detected'),
        discoloration: bleeding > 3 ? (translations?.ui_bloodPooling || 'Blood pooling visible') : severity >= 50 ? (translations?.ui_bruisingDiscoloration || 'Bruising and discoloration') : (translations?.ui_normalSkin || 'Normal skin tone'),
        woundDescription: woundData.text || (translations?.ui_noWoundDescription || 'No detailed wound description available'),
        recommendation: getTreatmentRecommendation(severity, bleeding)
      };
    };

    const detailedReport = generateDetailedReport();
    detailedInspectionResults[bodyPart] = detailedReport;
    detailedInspectionResults = detailedInspectionResults;

    if (woundData && !woundData.isScar && ((woundData.severity || 0) > 3 || (woundData.bleeding || 0) > 2)) {
      const bodyPartName = getBodyPartName(bodyPart);
      const severity = woundData.severity || 0;
      const bleeding = woundData.bleeding || 0;

      if (severity > 70) addAssessmentEntry(`${bodyPartName}: ${translations?.ui_criticalInjuryDetected || 'Critical injury detected - immediate attention required'}`);
      else if (severity > 40) addAssessmentEntry(`${bodyPartName}: ${translations?.ui_moderateInjuryFound || 'Moderate injury found - treatment recommended'}`);
      else if (bleeding > 15) addAssessmentEntry(`${bodyPartName}: ${translations?.ui_activeBleedingObserved || 'Active bleeding observed'}`);
      else addAssessmentEntry(`${bodyPartName}: ${translations?.ui_minorInjuryNoted || 'Minor injury noted'}`);
    }
    
    window.postMessage({ 
      type: 'inspect-body-part', 
      data: {
        playerId: data.playerId,
        bodyPart,
        woundData,
        detailedReport,
        patientName: data.playerName
      }
    }, '*');
  }

  function handleMedicalAction(action: string, target?: string, extra?: any) {
    if (action === 'use-tool' && target === 'thermometer') {
      showThermometerSubMenu = true;
      thermometerAnimating = true;
      return;
    }

    try {
      fetch(`https://${(window as any).GetParentResourceName()}/medical-action`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action,
          target,
          extra,
          playerId: data.playerId,
          patientName: data.playerName
        })
      });
    } catch (e) {}
  }

</script>

<div class="medical-inspection-rightsidepanel medical-field-book" data-theme="light" style="display: block;">
  <div class="medic-action-sidebar">
    <div class="medic-action-btn home-btn" class:active={currentView === 'home'} on:click={() => switchView('home')}>
      <i class="fas fa-home"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'bandage'} on:click={() => switchView('bandage')}>
      <i class="fas fa-plus-circle"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'tourniquet'} on:click={() => switchView('tourniquet')}>
      <i class="fas fa-compress"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'medicine'} on:click={() => switchView('medicine')}>
      <i class="fas fa-pills"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'injection'} on:click={() => switchView('injection')}>
      <i class="fas fa-syringe"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'body-inspection'} on:click={() => switchView('body-inspection')}>
      <i class="fas fa-search"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'vitals'} on:click={() => switchView('vitals')}>
      <i class="fas fa-heartbeat"></i><div class="action-tooltip"></div>
    </div>
    <div class="medic-action-btn" class:active={currentView === 'doctors-bag'} on:click={() => switchView('doctors-bag')}>
      <i class="fas fa-briefcase-medical"></i><div class="action-tooltip">{translations?.ui_doctorsBag || "Doctor's Bag"}</div>
    </div>
    <div class="medic-action-btn" on:click={() => document.querySelector('.medical-field-book').dataset.theme = document.querySelector('.medical-field-book').dataset.theme === 'light' ? 'dark' : 'light'}>
      <i class="fas fa-adjust"></i><div class="action-tooltip">Toggle Theme</div>
    </div>
  </div>

  <div class="rightsidepanel-container">
    <div class="rightsidepanel-header">
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <div class="panel-close-btn" on:click={onClose}>&times;</div>
      <div class="panel-title">
        <i class="fas fa-stethoscope"></i>
        {translations?.ui_medicalInspection || 'MEDICAL INSPECTION'}
      </div>
      <div class="panel-subtitle">{translations?.ui_patientMedicalAssessment || 'Patient Medical Assessment'}</div>
    </div>

    <div class="medic-inspection-content">
      {#if currentView === 'home'}
        <div class="quick-patient-info">
          <div class="patient-name-large">Dr. {data.playerName || translations?.ui_unknownMedic || 'Unknown Medic'}</div>
          <div class="patient-id-small">{translations?.ui_fieldPhysician || 'Field Physician - Medical Corps'}</div>
        </div>

        <div class="inspection-divider"></div>

        <div class="blood-level-display">
          <div class="blood-header">
            <i class="fas fa-briefcase-medical"></i>
            <span>{translations?.ui_medicalBag || 'MEDICAL KIT STATUS'}</span>
          </div>
          <div style="padding: 1vw; text-align: center;">
            <div style="font-size: 0.8vw; color: var(--status-good); margin-bottom: 0.5vw;">
              <i class="fas fa-check-circle" style="margin-right: 0.5vw;"></i>
              {translations?.tool_fieldSurgeryKit || 'Field Kit Ready'}
            </div>
            <div style="font-size: 0.6vw; color: white;">
              {translations?.ui_allInstrumentsOperational || 'All medical instruments operational'}
            </div>
          </div>
        </div>

        <div class="inspection-divider"></div>

        <div class="medical-details-section">
          <div class="section-title">
            <i class="fas fa-clipboard-list"></i>
            <span>{translations?.ui_patientAssessment || 'PATIENT ASSESSMENT'}</span>
          </div>
          <div class="details-content">
            {#if medicalAssessment.length === 0}
              <div style="text-align: center; padding: 2vw; color: rgba(226, 199, 146, 0.6);">
                <i class="fas fa-search" style="font-size: 1.5vw; margin-bottom: 0.5vw;"></i>
                <div style="font-size: 0.7vw; margin-bottom: 0.3vw;">{translations?.ui_noAssessmentCompleted || 'No assessment completed'}</div>
                <div style="font-size: 0.5vw;">{translations?.ui_useBodyInspection || 'Use body inspection and vitals to evaluate patient condition'}</div>
              </div>
            {:else}
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.8vw; font-style: italic;">
                {translations?.ui_medicalAssessmentFindings || 'Medical assessment findings:'}
              </div>
              <div style="max-height: 18vw; overflow-y: auto; margin-bottom: 1vw;">
                {#each medicalAssessment as finding}
                  <div style="font-size: 0.8vw; color: white; margin-bottom: 0.3vw; padding: 0.4vw 0.8vw; border-left: 2px solid white; background: rgba(226, 199, 146, 0.05);">
                    • {finding}
                  </div>
                {/each}
              </div>
              
              {#if treatmentsApplied.length > 0}
                <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw; font-style: italic;">
                  {translations?.treatmentsApplied || 'Treatments Applied'}:
                </div>
                <div style="max-height: 8vw; overflow-y: auto;">
                  {#each treatmentsApplied as treatment}
                    <div style="font-size: 0.55vw; color: var(--status-good); margin-bottom: 0.2vw; padding: 0.2vw 0.5vw; border-left: 2px solid var(--status-good); background: rgba(39, 174, 96, 0.05);">
                      • {treatment}
                    </div>
                  {/each}
                </div>
              {/if}
            {/if}
          </div>
        </div>
      {/if}

      {#if currentView === 'vitals'}
        <div class="vitals-checking-view">
          <div class="section-title">
            <i class="fas fa-heartbeat"></i>
            <span>{translations?.vitalSignsChecking || 'VITAL SIGNS CHECKING'}</span>
          </div>
          
          {#if !vitalsChecked}
            <div class="vitals-panel" style="text-align: center; padding: 2vw;">
              <div style="font-size: 0.8vw; color: white; margin-bottom: 1vw;">
                <i class="fas fa-stethoscope" style="font-size: 2vw; margin-bottom: 0.5vw;"></i>
                <div>{translations?.placeStethoscope || "Place stethoscope on patient's chest"}</div>
              </div>
              
              <div style="font-size: 0.6vw; color: white; margin-bottom: 1.5vw;">
                {checkingVitals ? (translations?.listeningHeartbeat || 'Listening for heartbeat... Keep holding!') : (translations?.holdToCheckVitals || 'Hold the button below for 3 seconds to check vitals')}
              </div>
              
              <div class="vitals-controls" style="display: flex; gap: 1vw; justify-content: center;">
                <button 
                  class="vitals-hold-btn"
                  on:mousedown={startVitalsCheck}
                  on:mouseup={stopVitalsCheck}
                  on:mouseleave={stopVitalsCheck}
                  style="background: {checkingVitals ? 'var(--status-medium)' : 'white'}; color: #2c1810; border: none; padding: 0.8vw 1.5vw; border-radius: 0.3vw; font-size: 0.7vw; cursor: pointer; position: relative; overflow: hidden;"
                >
                  <i class="fas fa-hand-paper" style="margin-right: 0.5vw;"></i>
                  {checkingVitals ? (translations?.checking || 'CHECKING...') : (translations?.holdToCheck || 'HOLD TO CHECK')}
                  {#if checkingVitals}
                    <div style="position: absolute; bottom: 0; left: 0; width: {vitalsProgress}%; height: 100%; background: rgba(39, 174, 96, 0.3); transition: width 0.1s ease;"></div>
                  {/if}
                </button>
                
                <button 
                  on:click={() => switchView('home')}
                  style="background: transparent; color: white; border: 1px solid white; padding: 0.8vw 1.5vw; border-radius: 0.3vw; font-size: 0.7vw; cursor: pointer;"
                >
                  <i class="fas fa-times" style="margin-right: 0.5vw;"></i>
                  {translations?.cancel || 'CANCEL'}
                </button>
              </div>
            </div>
          {:else}
            <div class="vitals-results" style="padding: 1vw;">
              <div class="section-title" style="margin-bottom: 1vw;">
                <i class="fas fa-check-circle" style="color: var(--status-good);"></i>
                <span>{translations?.ui_vitalSignsResults || 'VITAL SIGNS RESULTS'}</span>
              </div>
              <div style="display: flex; flex-direction: column; gap: 0.5vw;">
                <div style="display: flex; justify-content: space-between; padding: 0.3vw; background: rgba(226, 199, 146, 0.05); border-radius: 0.2vw;">
                  <span style="color: white; font-size: 0.7vw;">{translations?.ui_heartRateLbl || 'Heart Rate:'}</span>
                  <span style="color: white; font-size: 0.7vw; font-weight: bold;">{vitals.heartRate} BPM</span>
                </div>
                <div style="display: flex; justify-content: space-between; padding: 0.3vw; background: rgba(226, 199, 146, 0.05); border-radius: 0.2vw;">
                  <span style="color: white; font-size: 0.7vw;">{translations?.ui_temperatureLbl || 'Temperature:'}</span>
                  <span style="color: white; font-size: 0.7vw; font-weight: bold;">{data.vitals?.temperature || '98.6'} °F</span>
                </div>
                <div style="display: flex; justify-content: space-between; padding: 0.3vw; background: rgba(226, 199, 146, 0.05); border-radius: 0.2vw;">
                  <span style="color: white; font-size: 0.7vw;">{translations?.ui_breathingLbl || 'Breathing:'}</span>
                  <span style="color: white; font-size: 0.7vw; font-weight: bold;">{data.vitals?.breathing || '16'} /min</span>
                </div>
                <div style="display: flex; justify-content: space-between; padding: 0.3vw; background: rgba(226, 199, 146, 0.05); border-radius: 0.2vw;">
                  <span style="color: white; font-size: 0.7vw;">{translations?.ui_statusLbl || 'Status:'}</span>
                  <span style="color: {vitals.statusColor}; font-size: 0.7vw; font-weight: bold;">{vitals.status}</span>
                </div>
              </div>
            </div>
          {/if}
        </div>
      {/if}

      {#if currentView === 'body-inspection'}
        <div class="body-inspection-view">
          <div class="section-title">
            <i class="fas fa-search-plus"></i>
            <span>{translations?.ui_bodyInspectionTitle || 'BODY INSPECTION MODE'}</span>
          </div>
          
          <div style="font-size: 0.6vw; color: white; margin-bottom: 0.8vw; font-style: italic;">
            {translations?.ui_clickBodyParts || 'Click on body parts to perform detailed inspection'}
          </div>
          
          <div class="body-parts-grid" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.3vw; margin-bottom: 1vw;">
            {#each ['head', 'spine', 'upbody', 'lowbody', 'larm', 'rarm', 'lhand', 'rhand', 'lleg', 'rleg', 'lfoot', 'rfoot'] as bodyPart}
              <!-- svelte-ignore a11y-click-events-have-key-events -->
              <div 
                class="body-part-item {inspectedBones.has(bodyPart) ? 'inspected' : ''} {selectedBone === bodyPart ? 'selected' : ''}"
                on:click={() => inspectBodyPart(bodyPart)}
                style="padding: 0.4vw; background: {selectedBone === bodyPart ? 'rgba(226, 199, 146, 0.2)' : inspectedBones.has(bodyPart) ? 'rgba(226, 199, 146, 0.1)' : 'rgba(0,0,0,0.1)'}; border: 1px solid {selectedBone === bodyPart ? 'white' : 'rgba(226, 199, 146, 0.3)'}; border-radius: 0.2vw; cursor: pointer; font-size: 0.6vw; color: white; text-align: center; position: relative;"
              >
                {getBodyPartName(bodyPart)}
                {#if getWoundData(bodyPart) && ((getWoundData(bodyPart).severity || 0) >= 25 || (getWoundData(bodyPart).bleeding || 0) >= 30)}
                  <div style="position: absolute; top: 2px; right: 2px; width: 6px; height: 6px; background: {(getWoundData(bodyPart).bleeding || 0) >= 6 ? 'var(--status-critical)' : 'var(--status-medium)'}; border-radius: 50%;"></div>
                {/if}
                {#if inspectedBones.has(bodyPart)}
                  <i class="fas fa-check" style="position: absolute; bottom: 2px; right: 2px; font-size: 0.5vw; color: var(--status-good);"></i>
                {/if}
              </div>
            {/each}
          </div>

          {#if selectedBone && detailedInspectionResults[selectedBone]}
            <div class="bone-inspection-details" style="padding: 0.8vw; background: rgba(226, 199, 146, 0.05); border-radius: 0.3vw; max-height: 20vw; overflow-y: auto;">
              <h4 style="color: white; font-size: 0.8vw; margin-bottom: 0.5vw;">
                {translations?.ui_detailedInspectionLbl || 'Detailed Inspection:'} {getBodyPartName(selectedBone)}
              </h4>
              <div class="detailed-results" style="font-size: 0.55vw; line-height: 1.4;">
                {#each Object.entries(detailedInspectionResults[selectedBone]) as [key, value]}
                  <div style="margin-bottom: 0.4vw; display: flex; flex-direction: column;">
                    <span style="color: white; font-weight: bold; text-transform: capitalize;">
                      {translations?.[`ui_report_${key}`] || key.replace(/([A-Z])/g, ' $1')}:
                    </span>
                    <span style="color: {key === 'recommendation' && typeof value === 'string' && value.includes('URGENT') ? 'var(--status-critical)' : key === 'recommendation' && typeof value === 'string' && value.includes('Treatment') ? 'var(--status-medium)' : key === 'woundDescription' ? '#E2C792' : 'white'}; margin-left: 0.5vw; font-style: {key === 'recommendation' || key === 'woundDescription' ? 'italic' : 'normal'}; line-height: {key === 'woundDescription' ? '1.4' : 'normal'};">
                      {value}
                    </span>
                  </div>
                {/each}
              </div>
            </div>
          {/if}
        </div>
      {/if}

      {#if currentView === 'bandage'}
        <div class="bandage-view">
          <div class="section-title">
            <i class="fas fa-plus-circle"></i>
            <span>{translations?.ui_applyBandageTitle || 'APPLY BANDAGE'}</span>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-exclamation-triangle"></i>
              <span>{translations?.ui_infectionControl || 'INFECTION CONTROL'}</span>
            </div>
            <div class="infection-warning-section" style="background: rgba(139, 169, 85, 0.25); border: 0.05vw solid rgba(139, 169, 85, 0.4); border-radius: 0.3vw; padding: 0.8vw; box-shadow: 0 0 0.8vw rgba(139, 169, 85, 0.3);">
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_cleanWound || 'Clean wound thoroughly before applying any bandage'}</div>
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_changeBandages || 'Change bandages regularly to prevent infection'}</div>
              <div style="font-size: 0.6vw; color: white;">• {translations?.ui_watchInfection || 'Watch for signs of infection: swelling, pus, unusual odor'}</div>
            </div>
          </div>
          
          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-user-injured"></i>
              <span>{translations?.ui_bleedingConditions || 'BLEEDING CONDITIONS (Light/Moderate)'}</span>
            </div>
            <div class="treatment-grid">
              {#each Object.entries(discoveredInjuries).filter(([bp, _]) => needsBandage(bp)) as [bodyPart, wound]}
                <div 
                  class="treatment-option {selectedBodyPart === bodyPart ? 'selected' : ''}"
                  on:click={() => !isBandaged(bodyPart) ? selectedBodyPart = bodyPart : null}
                  style="padding: 0.5vw; margin: 0.2vw 0; background: {selectedBodyPart === bodyPart ? 'rgba(226, 199, 146, 0.2)' : 'rgba(226, 199, 146, 0.05)'}; border: 1px solid {selectedBodyPart === bodyPart ? 'white' : 'rgba(226, 199, 146, 0.3)'}; border-radius: 0.2vw; cursor: {isBandaged(bodyPart) ? 'default' : 'pointer'}; display: flex; justify-content: space-between; align-items: center; opacity: {isBandaged(bodyPart) ? 0.7 : 1};"
                >
                  <span style="color: white; font-size: 0.7vw;">{getBodyPartName(bodyPart).toUpperCase()}</span>
                  <span style="color: {isBandaged(bodyPart) ? 'var(--status-good)' : wound.bleeding >= 60 ? 'var(--status-critical)' : (wound.severity + wound.bleeding*2) > 6 ? 'var(--status-medium)' : '#e67e22'}; font-size: 0.6vw;">
                    {isBandaged(bodyPart) ? (translations?.ui_bandaged || 'Bandaged') : wound.bleeding >= 60 ? (translations?.ui_critical || 'Critical') : (wound.severity + wound.bleeding*2) > 6 ? (translations?.ui_injured || 'Injured') : (translations?.ui_bleeding || 'Bleeding')}
                  </span>
                </div>
              {/each}
              {#if Object.entries(discoveredInjuries).filter(([bp, _]) => needsBandage(bp)).length === 0}
                <div style="color: rgba(255, 255, 255, 0.6); font-size: 0.6vw; font-style: italic; text-align: center; padding: 1vw;">
                  {Object.keys(discoveredInjuries).length === 0 ? (translations?.ui_noWoundsDiscovered || 'No wounds discovered yet. Perform body inspection to identify bleeding wounds.') : (translations?.ui_noLightBleedingWounds || 'No light/moderate bleeding wounds discovered (requires bleeding level 1-6).')}
                </div>
              {/if}
            </div>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-briefcase"></i>
              <span>{translations?.ui_availiableBandages || 'AVAILABLE BANDAGES'}</span>
            </div>
            <div class="bandage-selection-grid" style="display: flex; flex-wrap: wrap; gap: 0.4vw;">
              {#each bandageTypes as bandage}
                <div 
                  class="bandage-type {selectedBandageType === bandage.id ? 'selected' : ''}"
                  on:click={() => selectedBandageType = bandage.id}
                  style="padding: 0.8vw; height: auto; background: {selectedBandageType === bandage.id ? 'rgba(226, 199, 146, 0.15)' : 'rgba(0, 0, 0, 0.2)'}; border: 1px solid {selectedBandageType === bandage.id ? 'white' : 'rgba(226, 199, 146, 0.4)'}; border-radius: 0.3vw; cursor: pointer; display: flex; align-items: center; flex: 0 0 calc(50% - 0.2vw); box-sizing: border-box;"
                >
                  <div style="display: flex; flex-direction: column; align-items: center; text-align: center; width: 100%;">
                    <i class="fas {bandage.icon}" style="font-size: 1.8vw; color: white; margin-bottom: 0.3vw;"></i>
                    <div style="color: white; font-size: 0.8vw; font-weight: bold; margin-bottom: 0.2vw;">{bandage.name}</div>
                    <div style="color: rgba(226, 199, 146, 0.9); font-size: 0.65vw; line-height: 1.2;">{bandage.desc}</div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          {#if selectedBandageType && selectedBodyPart}
            <div style="text-align: center; margin-top: 1vw;">
              <button 
                on:click={applyBandage}
                style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.8vw 2vw; border-radius: 0.3vw; font-size: 0.7vw; cursor: pointer; font-weight: bold;"
              >
                <i class="fas fa-plus" style="margin-right: 0.5vw;"></i> {translations?.ui_applyTreatment || 'APPLY TREATMENT'}
              </button>
            </div>
          {/if}
        </div>
      {/if}

      {#if currentView === 'tourniquet'}
        <div class="tourniquet-view">
          <div class="section-title">
            <i class="fas fa-compress"></i>
            <span>{translations?.ui_applyTourniquetTitle || 'APPLY TOURNIQUET'}</span>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-exclamation-triangle"></i>
              <span>{translations?.ui_tourniquetSafety || 'TOURNIQUET SAFETY'}</span>
            </div>
            <div class="warning-notes-section">
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_applyProximal || 'Apply proximal to bleeding source, never over joints'}</div>
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_tightenUntilStop || 'Tighten until bleeding stops - document application time'}</div>
              <div style="font-size: 0.6vw; color: white;">• {translations?.ui_riskLimbLoss || 'Risk of limb loss if left on too long - monitor closely'}</div>
            </div>
          </div>
          
          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-user-injured"></i>
              <span>{translations?.ui_severeBleedingConditions || 'SEVERE BLEEDING CONDITIONS'}</span>
            </div>
            <div class="treatment-grid">
              {#each Object.entries(discoveredInjuries).filter(([bp, _]) => needsTourniquet(bp)) as [bodyPart, wound]}
                <div 
                  class="treatment-option {selectedBodyPart === bodyPart ? 'selected' : ''}"
                  on:click={() => !isTourniqueted(bodyPart) ? selectedBodyPart = bodyPart : null}
                  style="padding: 0.5vw; margin: 0.2vw 0; background: {selectedBodyPart === bodyPart ? 'rgba(226, 199, 146, 0.2)' : 'rgba(226, 199, 146, 0.05)'}; border: 1px solid {selectedBodyPart === bodyPart ? 'white' : 'rgba(226, 199, 146, 0.3)'}; border-radius: 0.2vw; cursor: {isTourniqueted(bodyPart) ? 'default' : 'pointer'}; display: flex; justify-content: space-between; align-items: center; opacity: {isTourniqueted(bodyPart) ? 0.7 : 1};"
                >
                  <span style="color: white; font-size: 0.7vw;">{getBodyPartName(bodyPart).toUpperCase()}</span>
                  <span style="color: {isTourniqueted(bodyPart) ? 'var(--status-good)' : wound.bleeding > 8 ? 'var(--status-critical)' : 'var(--status-medium)'}; font-size: 0.6vw;">
                    {isTourniqueted(bodyPart) ? (translations?.ui_tourniqueted || 'Tourniqueted') : wound.bleeding > 8 ? (translations?.ui_severeBleeding || 'Severe Bleeding') : (translations?.ui_heavyBleeding || 'Heavy Bleeding')}
                  </span>
                </div>
              {/each}
              {#if Object.entries(discoveredInjuries).filter(([bp, _]) => needsTourniquet(bp)).length === 0}
                <div style="color: rgba(255, 255, 255, 0.6); font-size: 0.6vw; font-style: italic; text-align: center; padding: 1vw;">
                  {Object.keys(discoveredInjuries).length === 0 ? (translations?.ui_noSevereBleedingDiscovered || 'No wounds discovered yet. Perform body inspection to identify severe bleeding.') : (translations?.ui_noSevereBleedingWounds || 'No severe bleeding wounds discovered (requires bleeding level 7+).')}
                </div>
              {/if}
            </div>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-briefcase"></i>
              <span>{translations?.ui_availableTourniquets || 'AVAILABLE TOURNIQUETS'}</span>
            </div>
            <div class="tourniquet-selection-grid" style="display: flex; flex-wrap: wrap; gap: 0.4vw;">
              {#each tourniquetTypes as tourniquet}
                <div 
                  class="tourniquet-type {selectedTourniquetType === tourniquet.id ? 'selected' : ''}"
                  on:click={() => selectedTourniquetType = tourniquet.id}
                  style="padding: 0.8vw; height: auto; background: {selectedTourniquetType === tourniquet.id ? 'rgba(226, 199, 146, 0.15)' : 'rgba(0, 0, 0, 0.2)'}; border: 1px solid {selectedTourniquetType === tourniquet.id ? 'white' : 'rgba(226, 199, 146, 0.4)'}; border-radius: 0.3vw; cursor: pointer; display: flex; align-items: center; flex: 0 0 calc(50% - 0.2vw); box-sizing: border-box;"
                >
                  <div style="display: flex; flex-direction: column; align-items: center; text-align: center; width: 100%;">
                    <i class="fas {tourniquet.icon}" style="font-size: 1.8vw; color: white; margin-bottom: 0.3vw;"></i>
                    <div style="color: white; font-size: 0.8vw; font-weight: bold; margin-bottom: 0.2vw;">{tourniquet.name}</div>
                    <div style="color: rgba(226, 199, 146, 0.9); font-size: 0.65vw; line-height: 1.2;">{tourniquet.desc}</div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          {#if selectedTourniquetType && selectedBodyPart}
            <div style="text-align: center; margin-top: 1vw;">
              <button 
                on:click={applyTourniquet}
                style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.8vw 2vw; border-radius: 0.3vw; font-size: 0.7vw; cursor: pointer; font-weight: bold;"
              >
                <i class="fas fa-compress" style="margin-right: 0.5vw;"></i> {translations?.ui_applyTourniquet || 'APPLY TOURNIQUET'}
              </button>
            </div>
          {/if}
        </div>
      {/if}

      {#if currentView === 'medicine'}
        <div class="medicine-view">
          <div class="section-title">
            <i class="fas fa-pills"></i>
            <span>{translations?.ui_administerMedicine || 'ADMINISTER MEDICINE'}</span>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-exclamation-triangle"></i>
              <span>{translations?.ui_administrationNotes || 'ADMINISTRATION NOTES'}</span>
            </div>
            <div class="warning-notes-section">
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_ensureSwallow || 'Ensure patient can swallow before administering oral medications'}</div>
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_monitorReactions || 'Monitor patient for adverse reactions after administration'}</div>
              <div style="font-size: 0.6vw; color: white;">• {translations?.ui_drowsinessWarning || 'Some medicines may cause drowsiness or altered consciousness'}</div>
            </div>
          </div>
          
          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-user-injured"></i>
              <span>{translations?.ui_painConditions || 'PAIN CONDITIONS'}</span>
            </div>
            <div class="treatment-grid">
              {#each Object.entries(discoveredInjuries).filter(([bp, _]) => needsMedicine(bp)) as [bodyPart, wound]}
                <div 
                  class="treatment-option {selectedBodyPart === bodyPart ? 'selected' : ''}"
                  on:click={() => selectedBodyPart = bodyPart}
                  style="padding: 0.6vw; background: {selectedBodyPart === bodyPart ? 'rgba(226, 199, 146, 0.15)' : 'rgba(0, 0, 0, 0.2)'}; border: 1px solid {selectedBodyPart === bodyPart ? 'white' : 'rgba(226, 199, 146, 0.4)'}; border-radius: 0.3vw; cursor: pointer; display: flex; flex-direction: column; align-items: center; text-align: center; margin: 0.2vw;"
                >
                  <span style="color: white; font-size: 0.7vw;">{getBodyPartName(bodyPart).toUpperCase()}</span>
                  <span style="color: {wound.severity >= 75 ? 'var(--status-critical)' : wound.severity >= 50 ? 'var(--status-medium)' : 'var(--status-good)'}; font-size: 0.6vw;">
                    {wound.severity >= 75 ? (translations?.ui_severePain || 'Severe Pain') : wound.severity >= 50 ? (translations?.ui_moderatePain || 'Moderate Pain') : (translations?.ui_mildPain || 'Mild Pain')}
                  </span>
                  {#if wound.bleeding > 0}
                    <span style="color: var(--status-medium); font-size: 0.5vw;">{translations?.ui_bleedingLbl || '+ Bleeding'} ({wound.bleeding})</span>
                  {/if}
                </div>
              {/each}
              {#if Object.entries(discoveredInjuries).filter(([bp, _]) => needsMedicine(bp)).length === 0}
                <div style="color: rgba(255, 255, 255, 0.6); font-size: 0.6vw; font-style: italic; text-align: center; padding: 1vw;">
                  {Object.keys(discoveredInjuries).length === 0 ? (translations?.ui_noWoundsDiscovered || 'No wounds discovered yet. Perform body inspection to identify pain conditions.') : (translations?.ui_noPainConditions || 'No pain conditions discovered (requires pain level 1+).')}
                </div>
              {/if}
            </div>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-briefcase"></i>
              <span>{translations?.ui_availableMedicine || 'AVAILABLE MEDICINES'}</span>
            </div>
            <div class="medicine-selection-grid" style="display: flex; flex-wrap: wrap; gap: 0.4vw;">
              {#each medicineTypes as medicine}
                <div 
                  class="medicine-type {selectedMedicineType === medicine.id ? 'selected' : ''}"
                  on:click={() => selectedMedicineType = medicine.id}
                  style="padding: 0.8vw; height: auto; background: {selectedMedicineType === medicine.id ? 'rgba(226, 199, 146, 0.15)' : 'rgba(0, 0, 0, 0.2)'}; border: 1px solid {selectedMedicineType === medicine.id ? 'white' : 'rgba(226, 199, 146, 0.4)'}; border-radius: 0.3vw; cursor: pointer; display: flex; align-items: center; flex: 0 0 calc(50% - 0.2vw); box-sizing: border-box;"
                >
                  <div style="display: flex; flex-direction: column; align-items: center; text-align: center; width: 100%;">
                    <i class="fas {medicine.icon}" style="font-size: 1.8vw; color: white; margin-bottom: 0.3vw;"></i>
                    <div style="color: white; font-size: 0.8vw; font-weight: bold; margin-bottom: 0.2vw;">{medicine.name}</div>
                    <div style="color: rgba(226, 199, 146, 0.9); font-size: 0.65vw; line-height: 1.2;">{medicine.desc}</div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          {#if selectedMedicineType}
            <div style="text-align: center; margin-top: 1vw;">
              <button 
                on:click={administerMedicine}
                style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.8vw 2vw; border-radius: 0.3vw; font-size: 0.7vw; cursor: pointer; font-weight: bold;"
              >
                <i class="fas fa-pills" style="margin-right: 0.5vw;"></i> {translations?.ui_administerMedicine || 'ADMINISTER MEDICINE'}
              </button>
            </div>
          {/if}
        </div>
      {/if}

      
      {#if currentView === 'body-inspection'}
        <div class="body-inspection-view" style="display: flex; flex-direction: column; align-items: center; position: relative; height: 100%; width: 100%; overflow: hidden;">
          <div class="section-title" style="margin-bottom: 1vw;">
            <i class="fas fa-search"></i>
            <span>{translations?.ui_bodyInspection || 'BODY INSPECTION'}</span>
          </div>
          
          <div class="medic-details" style="position: relative; width: 100%; height: 35vw; transform: scale(0.9); margin-top: -2vw;">
            {#each ["head", "spine", "upper", "larm", "lhand", "rarm", "rhand", "lleg", "rleg", "lfoot", "rfoot", "lower"] as part}
              <div class="medic-{part}" style="cursor: pointer; transition: filter 0.2s;" 
                   on:click={() => inspectBodyPart(part)}
                   on:mouseenter={(e) => e.currentTarget.style.filter = 'brightness(1.5) drop-shadow(0 0 5px rgba(226, 199, 146, 0.8))'}
                   on:mouseleave={(e) => e.currentTarget.style.filter = 'none'}>
                <div class="medic-{part}-first {discoveredInjuries[part] ? (discoveredInjuries[part].bleeding > 0 || discoveredInjuries[part].severity > 0 ? 'wounded-body-part' : '') : ''}" style="position: relative;">
                  <div class="body-part-icon" style="width: 100%; height: 100%;"></div>
                  
                  {#if inspectedBones.has(part)}
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: rgba(255,255,255,0.8); font-size: 0.8vw;">
                      {#if discoveredInjuries[part]}
                        <i class="fas fa-exclamation-triangle" style="color: {discoveredInjuries[part].bleeding >= 60 || discoveredInjuries[part].severity >= 75 ? 'var(--status-critical)' : 'var(--status-medium)'}; text-shadow: 0 0 3px black;"></i>
                      {:else}
                        <i class="fas fa-check" style="color: var(--status-good); text-shadow: 0 0 3px black;"></i>
                      {/if}
                    </div>
                  {/if}
                </div>
              </div>
            {/each}
          </div>

          {#if selectedBone}
            <div style="width: 100%; background: rgba(0,0,0,0.4); padding: 1vw; border-radius: 0.5vw; border: 1px solid rgba(226,199,146,0.3); margin-top: 1vw;">
              <div style="color: var(--text-main); font-weight: bold; font-size: 0.8vw; border-bottom: 1px solid rgba(226,199,146,0.3); padding-bottom: 0.5vw; margin-bottom: 0.5vw;">
                {getBodyPartName(selectedBone).toUpperCase()} {translations?.ui_inspectionReport || 'INSPECTION REPORT'}
              </div>
              
              {#if detailedInspectionResults[selectedBone]}
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5vw; font-size: 0.6vw; align-items: start;">
                  <div style="line-height: 1.4;"><span style="color: #aaa;">{translations?.ui_boneIntegrity || 'Bone Integrity:'}</span> <span style="color: {detailedInspectionResults[selectedBone].boneIntegrity.includes('fracture') ? 'var(--status-critical)' : 'white'}">{detailedInspectionResults[selectedBone].boneIntegrity}</span></div>
                  <div style="line-height: 1.4;"><span style="color: #aaa;">{translations?.ui_softTissue || 'Soft Tissue:'}</span> <span style="color: white;">{detailedInspectionResults[selectedBone].softTissue}</span></div>
                  <div style="line-height: 1.4;"><span style="color: #aaa;">{translations?.ui_bloodFlow || 'Blood Flow:'}</span> <span style="color: {detailedInspectionResults[selectedBone].bloodFlow.includes('Active') ? 'var(--status-critical)' : 'white'}">{detailedInspectionResults[selectedBone].bloodFlow}</span></div>
                  <div style="line-height: 1.4;"><span style="color: #aaa;">{translations?.ui_painResponse || 'Pain Response:'}</span> <span style="color: {detailedInspectionResults[selectedBone].painResponse.includes('Severe') || detailedInspectionResults[selectedBone].painResponse.includes('8') ? 'var(--status-critical)' : 'white'}">{detailedInspectionResults[selectedBone].painResponse}</span></div>
                </div>
                
                <div style="margin-top: 0.5vw; padding-top: 0.5vw; border-top: 1px dashed rgba(226,199,146,0.2); font-size: 0.6vw; line-height: 1.4;">
                  <span style="color: #aaa;">{translations?.ui_recommendation || 'Recommendation:'}</span> <span style="color: {detailedInspectionResults[selectedBone].recommendation.includes('URGENT') ? 'var(--status-critical)' : 'var(--status-good)'}">{detailedInspectionResults[selectedBone].recommendation}</span>
                </div>
              {:else}
                <div style="color: #888; font-size: 0.6vw; font-style: italic;">{translations?.ui_processingReport || 'Processing inspection data...'}</div>
              {/if}
            </div>
          {:else}
            <div style="color: #888; font-size: 0.7vw; font-style: italic; margin-top: 1vw;">
              {translations?.ui_selectBodyPartToInspect || 'Click on a body part to inspect for hidden injuries'}
            </div>
          {/if}
          
          {#if hasInspectedFully}
            <div style="margin-top: 1vw; color: var(--status-good); font-size: 0.6vw; font-weight: bold; background: rgba(39, 174, 96, 0.1); padding: 0.5vw 1vw; border-radius: 0.2vw; border: 1px solid rgba(39, 174, 96, 0.3);">
              <i class="fas fa-check-double"></i> {translations?.ui_fullBodyInspectionComplete || 'FULL BODY INSPECTION COMPLETE'}
            </div>
          {/if}
        </div>
      {/if}


      {#if currentView === 'injection'}
        <div class="injection-view">
          <div class="section-title">
            <i class="fas fa-syringe"></i>
            <span>{translations?.ui_giveInjectionTitle || 'GIVE INJECTION'}</span>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-exclamation-triangle"></i>
              <span>{translations?.ui_injectionSafety || 'INJECTION SAFETY'}</span>
            </div>
            <div class="warning-notes-section">
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_sterilizeSite || 'Sterilize injection site before administration'}</div>
              <div style="font-size: 0.6vw; color: white; margin-bottom: 0.5vw;">• {translations?.ui_properTechnique || 'Use proper injection technique to avoid nerve damage'}</div>
              <div style="font-size: 0.6vw; color: white;">• {translations?.ui_monitorAllergic || 'Monitor for immediate allergic reactions'}</div>
            </div>
          </div>
          
          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-user-injured"></i>
              <span>{translations?.ui_emergengyConditions || 'EMERGENCY/SEVERE CONDITIONS'}</span>
            </div>
            <div class="treatment-grid">
              {#each Object.entries(discoveredInjuries).filter(([bp, wound]) => wound && ((wound.severity && wound.severity >= 75) || (wound.bleeding && wound.bleeding >= 60))) as [bodyPart, wound]}
                <div 
                  class="treatment-option {selectedBodyPart === bodyPart ? 'selected' : ''}"
                  on:click={() => selectedBodyPart = bodyPart}
                  style="padding: 0.6vw; background: {selectedBodyPart === bodyPart ? 'rgba(226, 199, 146, 0.15)' : 'rgba(0, 0, 0, 0.2)'}; border: 1px solid {selectedBodyPart === bodyPart ? 'white' : 'rgba(226, 199, 146, 0.4)'}; border-radius: 0.3vw; cursor: pointer; display: flex; flex-direction: column; align-items: center; text-align: center; margin: 0.2vw;"
                >
                  <span style="color: white; font-size: 0.7vw;">{getBodyPartName(bodyPart).toUpperCase()}</span>
                  <span style="color: {(wound.severity >= 75 || wound.bleeding >= 60) ? 'var(--status-critical)' : 'var(--status-medium)'}; font-size: 0.6vw;">
                    {wound.severity >= 75 && wound.bleeding >= 60 ? (translations?.ui_criticalEmergency || 'Critical Emergency') : wound.severity >= 75 ? (translations?.ui_severePain || 'Severe Pain') : (translations?.ui_severeBleeding || 'Severe Bleeding')}
                  </span>
                </div>
              {/each}
              {#if Object.entries(discoveredInjuries).filter(([bp, wound]) => wound && ((wound.severity && wound.severity >= 75) || (wound.bleeding && wound.bleeding >= 60))).length === 0}
                <div style="color: rgba(255, 255, 255, 0.6); font-size: 0.6vw; font-style: italic; text-align: center; padding: 1vw;">
                  {Object.keys(discoveredInjuries).length === 0 ? (translations?.ui_noWoundsDiscovered || 'No wounds discovered yet. Perform body inspection to identify critical conditions.') : (translations?.ui_noEmergencyConditions || 'No emergency conditions found (requires severe pain 8+ or critical bleeding 7+).')}
                </div>
              {/if}
            </div>
          </div>

          <div class="medical-details-section" style="margin-bottom: 1vw;">
            <div class="section-title" style="font-size: 0.7vw; margin-bottom: 0.5vw;">
              <i class="fas fa-briefcase"></i>
              <span>{translations?.ui_availableInjuctions || 'AVAILABLE INJECTIONS'}</span>
            </div>
            <div class="injection-selection-grid" style="display: flex; flex-wrap: wrap; gap: 0.4vw;">
              {#each injectionTypes as injection}
                <div 
                  class="injection-type {selectedInjectionType === injection.id ? 'selected' : ''}"
                  on:click={() => selectedInjectionType = injection.id}
                  style="padding: 0.8vw; height: auto; background: {selectedInjectionType === injection.id ? 'rgba(226, 199, 146, 0.15)' : 'rgba(0, 0, 0, 0.2)'}; border: 1px solid {selectedInjectionType === injection.id ? 'white' : 'rgba(226, 199, 146, 0.4)'}; border-radius: 0.3vw; cursor: pointer; display: flex; align-items: center; flex: 0 0 calc(50% - 0.2vw); box-sizing: border-box;"
                >
                  <div style="display: flex; flex-direction: column; align-items: center; text-align: center; width: 100%;">
                    <i class="fas {injection.icon}" style="font-size: 1.8vw; color: white; margin-bottom: 0.3vw;"></i>
                    <div style="color: white; font-size: 0.8vw; font-weight: bold; margin-bottom: 0.2vw;">{injection.name}</div>
                    <div style="color: rgba(226, 199, 146, 0.9); font-size: 0.65vw; line-height: 1.2;">{injection.desc}</div>
                  </div>
                </div>
              {/each}
            </div>
          </div>

          {#if selectedInjectionType && selectedBodyPart}
            <div style="text-align: center; margin-top: 1vw;">
              <button 
                on:click={giveInjection}
                style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.8vw 2vw; border-radius: 0.3vw; font-size: 0.7vw; cursor: pointer; font-weight: bold;"
              >
                <i class="fas fa-syringe" style="margin-right: 0.5vw;"></i> {translations?.ui_administerInjection || 'ADMINISTER INJECTION'}
              </button>
            </div>
          {/if}
        </div>
      {/if}
      
    </div>
  </div>

  {#if showVitalsSubMenu}
    <div class="vitals-submenu {vitalsAnimating ? 'submenu-slide-in' : ''}" style="position: fixed; bottom: 5vw; left: 50%; transform: translateX(-50%); background-image: url({weatheredPaper}); background-size: 100% 100%; background-position: center; border-radius: 0.5vw; padding: 1vw; z-index: 1000; min-width: 20vw;">
      <div class="submenu-title" style="color: white; font-size: 0.8vw; font-weight: bold; text-align: center; margin-bottom: 1vw;">
        <i class="fas fa-heartbeat" style="margin-right: 0.5vw;"></i>
        {translations?.ui_vitalSignsChecking || 'VITAL SIGNS CHECK'}
      </div>
      {#if !vitalsChecked}
        <div style="text-align: center;">
          <div class="heartbeat-animation" style="font-size: 3vw; color: var(--status-critical); margin-bottom: 1vw; text-align: center; transform: scale({checkingVitals ? 1.2 : 1});">
            <i class="fas fa-heart"></i>
          </div>
          <div style="font-size: 0.6vw; color: white; margin-bottom: 1vw;">
            {checkingVitals ? (translations?.ui_listeningHeartbeat || 'Listening for heartbeat... Keep holding!') : (translations?.ui_holdToCheckVitals || 'Hold the button below for 3 seconds')}
          </div>
          <div style="display: flex; gap: 1vw; justify-content: center;">
            <button 
              on:mousedown={startVitalsCheck}
              on:mouseup={stopVitalsCheck}
              on:mouseleave={stopVitalsCheck}
              style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.6vw 1.2vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; position: relative; overflow: hidden; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
            >
              <i class="fas fa-hand-paper" style="margin-right: 0.5vw;"></i>
              {checkingVitals ? (translations?.ui_checking || 'CHECKING...') : (translations?.ui_holdToCheck || 'HOLD TO CHECK')}
              {#if checkingVitals}
                <div style="position: absolute; bottom: 0; left: 0; width: {vitalsProgress}%; height: 100%; background: rgba(39, 174, 96, 0.3); transition: width 0.1s ease;"></div>
              {/if}
            </button>
            <button 
              on:click={closeVitalsSubMenu}
              style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.6vw 1.2vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
            >
              {translations?.ui_cancel || 'CANCEL'}
            </button>
          </div>
        </div>
      {:else}
        <div style="display: flex; flex-direction: column; gap: 0.3vw; padding: 0 1vw;">
          <div style="display: flex; justify-content: space-between; font-size: 0.6vw; padding: 0 0.5vw;">
            <span style="color: white;">{translations?.ui_heartRateLbl || 'Heart Rate:'}</span>
            <span style="color: {vitals.heartRate > 100 || vitals.heartRate < 60 ? 'var(--status-critical)' : 'var(--status-good)'}; font-weight: bold; text-shadow: 1px 1px 2px rgba(0,0,0,0.3);">{vitals.heartRate} BPM</span>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 0.6vw; padding: 0 0.5vw;">
            <span style="color: white;">{translations?.ui_statusLbl || 'Status:'}</span>
            <span style="color: {vitals.statusColor}; font-weight: bold;">{vitals.status}</span>
          </div>
          <button 
            on:click={() => {closeVitalsSubMenu(); vitalsChecked = false;}}
            style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.5vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; margin-top: 0.5vw; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
          >
            {translations?.ui_close || 'CLOSE'}
          </button>
        </div>
      {/if}
    </div>
  {/if}

  {#if showDoctorsBagSubMenu}
    <div class="doctors-bag-submenu {doctorsBagAnimating ? 'submenu-slide-in' : ''}" style="position: fixed; bottom: 5vw; left: 50%; transform: translateX(-50%); background-image: url({weatheredPaper}); background-size: 100% 100%; background-position: center; border-radius: 0.5vw; padding: 1vw; z-index: 1000; min-width: 25vw;">
      <div class="submenu-title" style="color: white; font-size: 0.8vw; font-weight: bold; text-align: center; margin-bottom: 1vw;">
        <i class="fas fa-briefcase-medical" style="margin-right: 0.5vw;"></i>
        {translations?.ui_doctorsBag || 'DOCTORS BAG'}
      </div>
      <div class="medical-tools-grid" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.5vw;">
        {#each [
          { name: translations?.ui_stethoscope || 'Stethoscope', icon: 'fa-stethoscope', action: 'stethoscope', desc: translations?.ui_stethoscopeDesc || 'Check heart and lung sounds' },
          { name: translations?.ui_tool_thermometer || 'Thermometer', icon: 'fa-thermometer-half', action: 'thermometer', desc: translations?.ui_tool_thermometer_desc || 'Measure body temperature' },
          { name: translations?.ui_tool_laudanum || 'Laudanum', icon: 'fa-prescription-bottle', action: 'laudanum', desc: translations?.ui_tool_laudanum_desc || 'Opium-based painkiller' },
          { name: translations?.ui_tool_whiskey || 'Whiskey', icon: 'fa-wine-bottle', action: 'whiskey', desc: translations?.ui_tool_whiskey_desc || 'Antiseptic and anesthetic' },
          { name: translations?.ui_tool_surgerykit || 'Field Surgery Kit', icon: 'fa-first-aid', action: 'field-kit', desc: translations?.ui_tool_surgerykit_desc || 'Emergency surgical tools' },
          { name: translations?.ui_tool_smellingsalts || 'Smelling Salts', icon: 'fa-vial', action: 'smelling-salts', desc: translations?.ui_tool_smellingsalts_desc || 'Revive unconscious patients' }
        ] as tool}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <div
            class="medical-tool"
            on:click={() => handleMedicalAction('use-tool', tool.action)}
            style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; padding: 0.6vw; border-radius: 0.3vw; cursor: pointer; border: none; display: flex; align-items: center; justify-content: flex-start; transition: transform 0.1s ease;"
          >
            <div style="width: 2.5vw; display: flex; justify-content: center; align-items: center; margin-right: 0.5vw;">
              <i class="fas {tool.icon}" style="font-size: 1.2vw; color: white;"></i>
            </div>
            <div>
              <div style="color: white; font-size: 0.6vw; font-weight: bold; margin-bottom: 0.1vw;">{tool.name}</div>
              <div style="color: {tool.desc.includes('painkiller') || tool.desc.includes('Opium') ? 'var(--status-critical)' : tool.desc.includes('Check') || tool.desc.includes('Measure') ? 'var(--status-good)' : 'var(--status-medium)'}; font-size: 0.45vw;">{tool.desc}</div>
            </div>
          </div>
        {/each}
      </div>
      <div style="text-align: center; margin-top: 1vw;">
        <button 
          on:click={closeDoctorsBagSubMenu}
          style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.5vw 1vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
        >
          <i class="fas fa-times" style="margin-right: 0.5vw;"></i> {translations?.ui_closeBag || 'CLOSE BAG'}
        </button>
      </div>
    </div>
  {/if}

  {#if showThermometerSubMenu}
    <div class="thermometer-submenu" style="position: fixed; bottom: 5vw; left: 50%; transform: translateX(-50%); background-image: url({weatheredPaper}); background-size: 100% 100%; background-position: center; border-radius: 0.5vw; padding: 1vw; z-index: 1000; min-width: 20vw;">
      <div class="submenu-title" style="color: white; font-size: 0.8vw; font-weight: bold; text-align: center; margin-bottom: 1vw;">
        <i class="fas fa-thermometer-half" style="margin-right: 0.5vw;"></i>
        {translations?.ui_temperatureCheck || 'TEMPERATURE CHECK'}
      </div>
      
      {#if !temperatureChecked}
        <div style="text-align: center;">
          <div style="position: relative; margin-bottom: 1vw; display: inline-block;">
            <div class="thermometer-container" style="position: relative; display: inline-block;">
              <div class="thermometer-fill" style="height: {checkingTemperature ? temperatureProgress * 0.02 : 0}vw; position: absolute; bottom: 0.8vw; left: 50%; transform: translateX(-50%); width: 0.2vw; background: linear-gradient(to top, var(--status-critical) 0%, var(--status-medium) 70%, #f1c40f 100%); transition: height 0.1s ease; z-index: -1; border-radius: 0.1vw;"></div>
              <i class="fas fa-thermometer-empty" style="font-size: 4vw; color: #8B4513; position: relative; z-index: 1;"></i>
            </div>
          </div>
          
          <div style="font-size: 0.6vw; color: white; margin-bottom: 1vw;">
            {checkingTemperature ? (translations?.ui_readingTemperature || 'Reading temperature... Keep holding!') : (translations?.ui_holdToCheckTemperature || 'Hold the button below for 3 seconds')}
          </div>
          
          <div style="display: flex; gap: 1vw; justify-content: center;">
            <button 
              on:mousedown={startTemperatureCheck}
              on:mouseup={stopTemperatureCheck}
              on:mouseleave={stopTemperatureCheck}
              style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.6vw 1.2vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
            >
              <i class="fas fa-thermometer-half" style="margin-right: 0.5vw;"></i>
              {checkingTemperature ? (translations?.ui_reading || 'READING...') : (translations?.ui_holdToCheck || 'HOLD TO CHECK')}
            </button>
            <button 
              on:click={() => showThermometerSubMenu = false}
              style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.6vw 1.2vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
            >
              {translations?.ui_cancel || 'CANCEL'}
            </button>
          </div>
        </div>
      {:else}
        <div style="text-align: center;">
          <div style="font-size: 1.5vw; color: #8B4513; margin-bottom: 1vw;">
            {calculateTemperature()}°F
          </div>
          <div style="font-size: 0.6vw; color: #8B4513; margin-bottom: 1vw;">
            {calculateTemperature() > 100.4 ? (translations?.ui_feverDetected || 'Fever detected') : calculateTemperature() < 97 ? (translations?.ui_hypothermiaRisk || 'Hypothermia risk') : (translations?.ui_normalTemperature || 'Normal temperature')}
          </div>
          <button 
            on:click={() => {
              showThermometerSubMenu = false;
              temperatureChecked = false;
              showNotification(`${translations?.ui_patientTemperature || 'Patient temperature'}: ${calculateTemperature()}°F`, 'fa-thermometer-half');
            }}
            style="background-image: url({selectionBoxBg}); background-size: cover; background-position: center; color: white; border: none; padding: 0.5vw; border-radius: 0.3vw; font-size: 0.6vw; cursor: pointer; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold;"
          >
            {translations?.ui_close || 'CLOSE'}
          </button>
        </div>
      {/if}
    </div>
  {/if}

  {#if notification}
    <div class="notification notification-slide-in" style="position: fixed; top: 2vw; left: 50%; transform: translateX(-50%); background-image: url({weatheredPaper}); background-size: 100% 100%; background-position: center; border-radius: 0.3vw; padding: 1.2vw 0.8vw; color: white; font-size: 0.7vw; z-index: 1001; text-shadow: 1px 1px 2px rgba(0,0,0,0.7); font-weight: bold; width: 10vw; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 0.5vw;">
      <i class="fas {notification.icon} notification-icon-shake" style="font-size: 1.5vw; color: var(--status-good);"></i>
      <div>{notification.message}</div>
    </div>
  {/if}

</div>

