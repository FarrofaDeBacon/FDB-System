<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import '../assets/css/medpanel.css';
  import DynamicTriage from './DynamicTriage.svelte';
  
  export let wounds: any = {};
  export let treatments: any = [];
  export let infections: any = {};
  export let bodyPartHealth: any = {};
  export let injuryStates: any = {};
  export let infectionStages: any = {};
  export let bodyParts: any = {};
  export let uiColors: any = {};
  export let inventory: any = {};
  export let bandageTypes: any = {};
  export let isSelfExamination: boolean = false;
  export let translations: any = {};
  export let onClose: () => void;

  function handleKeyDown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      onClose();
    }
  }

  onMount(() => {
    window.addEventListener('keydown', handleKeyDown);
  });

  onDestroy(() => {
    window.removeEventListener('keydown', handleKeyDown);
  });

  function handlePartSelection(event: CustomEvent<string>) {
    const selectedPart = event.detail;
    console.log("Membro clicado:", selectedPart);
    // Aqui no futuro vamos abrir o ActionWheel/Context Menu!
    // alert("Clicou no membro: " + selectedPart);
  }
</script>

<style>
  .medical-panel-wrapper {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 80vw;
    height: 85vh;
    background: rgba(10, 10, 10, 0.95);
    border: 2px solid var(--leather-stitch);
    box-shadow: 0 0 50px rgba(0,0,0,1);
    display: flex;
    overflow: hidden;
  }
</style>

<div class="medical-panel-wrapper">
  <!-- Toda a UI antiga de abas foi removida para dar espaço ao novo corpo! -->
  <DynamicTriage 
    {wounds}
    {treatments}
    {bodyParts}
    on:selectPart={handlePartSelection}
  />
</div>
