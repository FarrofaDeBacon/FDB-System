<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import DeathScreen from './components/DeathScreen.svelte';
  import MedicalPanel from './components/MedicalPanel.svelte';
  import InspectionPanel from './components/InspectionPanel.svelte';

  let currentView = 'hidden';
  let deathScreenData: any = { message: '', seconds: 0, canRespawn: false, medicsOnDuty: 0, translations: {} };
  let medicalData: any = { wounds: {}, treatments: [], infections: {}, bodyPartHealth: {}, injuryStates: {}, infectionStages: {}, bodyParts: {}, uiColors: {}, inventory: {}, bandageTypes: {}, isSelfExamination: false, translations: {} };
  let inspectionData: any = { playerName: '', vitals: {}, injuries: [], treatments: [], inventory: {}, translations: {} };
  let globalConfigData: any = { bandageTypes: {}, tourniquetTypes: {}, medicineTypes: {}, injectionTypes: {}, bodyParts: {} };
  
  let currentTheme = 'light';
  let scale = 1;

  function handleResize() {
    const ratio = window.innerWidth / window.innerHeight;
    if (ratio > 1.78) {
      scale = (window.innerHeight * 1.777) / window.innerWidth;
    } else {
      scale = 1;
    }
  }

  function handleMessage(event: MessageEvent) {
    const { type, data } = event.data;
    
    // Support direct string actions or type-based actions
    const action = data?.action || event.data.action || type;
    
    switch (action) {
      case 'show-death-screen':
        currentView = 'death-screen';
        deathScreenData = data || {};
        break;
      case 'update-death-timer':
        deathScreenData = { ...deathScreenData, ...(data || {}) };
        break;
      case 'hide-death-screen':
        currentView = 'hidden';
        break;
      case 'show-medical-panel':
        currentView = 'medical-panel';
        medicalData = data || {};
        break;
      case 'show-inspection-panel':
        currentView = 'inspection-panel';
        inspectionData = data || {};
        break;
      case 'update-medical-data':
        medicalData = { ...medicalData, ...data };
        break;
      case 'hide-all':
        currentView = 'hidden';
        break;
      case 'medical-config-data':
        globalConfigData = {
          bandageTypes: data?.bandageTypes || event.data.bandageTypes || {},
          tourniquetTypes: data?.tourniquetTypes || event.data.tourniquetTypes || {},
          medicineTypes: data?.medicineTypes || event.data.medicineTypes || {},
          injectionTypes: data?.injectionTypes || event.data.injectionTypes || {},
          bodyParts: data?.bodyParts || event.data.bodyParts || {}
        };
        break;
      case 'setTheme':
        currentTheme = data?.theme || event.data.theme || 'light';
        break;
    }
  }

  onMount(() => {
    window.addEventListener('resize', handleResize);
    handleResize();

    window.addEventListener('message', handleMessage);

    if (import.meta.env.DEV) {
      document.body.style.display = 'block';
      // development helpers
      (window as any).medical = {
        showDeathScreen: (data: any) => {
          window.postMessage({ type: 'show-death-screen', data }, '*');
        },
        showMedicalPanel: (data: any) => {
          window.postMessage({ type: 'show-medical-panel', data }, '*');
        },
        showInspectionPanel: (data: any) => {
          window.postMessage({ type: 'show-inspection-panel', data }, '*');
        },
        hideAll: () => {
          window.postMessage({ type: 'hide-all' }, '*');
        },
        setTheme: (theme: string) => {
          window.postMessage({ type: 'setTheme', data: { theme } }, '*');
        }
      };
    }
  });

  onDestroy(() => {
    window.removeEventListener('resize', handleResize);
    window.removeEventListener('message', handleMessage);
  });

  function hideAll() {
    const wasInspection = currentView === 'inspection-panel';
    currentView = 'hidden';
    
    try {
      fetch(`https://${(window as any).GetParentResourceName?.() || 'fdb-medic'}/close-medical-panel`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      }).catch(() => {});
      
      if (wasInspection) {
        fetch(`https://${(window as any).GetParentResourceName?.() || 'fdb-medic'}/closeInspectionPanel`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({})
        }).catch(() => {});
      }
    } catch (error) {
      console.log('Would close panels');
    }
  }
</script>

<div class="App" data-theme={currentTheme} style="width: 100vw; height: 100vh; position: fixed; top: 0; left: 0; display: flex; justify-content: center; align-items: center;">
  <div style="width: 100vw; height: 100vh; transform: scale({scale}); transform-origin: center center; position: relative;">
    
    {#if import.meta.env.DEV}
      <div style="position: fixed; top: 0; left: 0; background: rgba(0,0,0,0.8); color: white; padding: 5px; z-index: 9999; font-size: 12px;">
        Current View: {currentView}
      </div>
    {/if}

    {#if currentView === 'death-screen'}
      <DeathScreen 
        message={deathScreenData.message}
        seconds={deathScreenData.seconds}
        canRespawn={deathScreenData.canRespawn}
        medicsOnDuty={deathScreenData.medicsOnDuty}
        translations={deathScreenData.translations}
      />
    {/if}

    {#if currentView === 'medical-panel'}
      <MedicalPanel
        wounds={medicalData.wounds}
        treatments={medicalData.treatments}
        infections={medicalData.infections}
        bodyPartHealth={medicalData.bodyPartHealth}
        injuryStates={medicalData.injuryStates}
        infectionStages={medicalData.infectionStages}
        bodyParts={medicalData.bodyParts}
        uiColors={medicalData.uiColors}
        inventory={medicalData.inventory}
        bandageTypes={medicalData.bandageTypes}
        isSelfExamination={medicalData.isSelfExamination}
        translations={medicalData.translations}
        onClose={hideAll}
      />
    {/if}

    {#if currentView === 'inspection-panel'}
      <InspectionPanel
        data={inspectionData}
        translations={inspectionData.translations}
        configData={globalConfigData}
        onClose={hideAll}
      />
    {/if}
  </div>
</div>
