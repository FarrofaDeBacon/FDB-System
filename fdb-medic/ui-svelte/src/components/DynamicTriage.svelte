<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import bodyFleshImg from '../assets/imgs/anatomy_v2/body_flesh.svg';
  import bodySkeletonImg from '../assets/imgs/anatomy_v2/body_skeleton.svg';
  
  export let wounds: any = {};
  export let treatments: any = [];
  export let bodyParts: any = {};
  export let inspectedBones: Set<string> = new Set();
  
  const dispatch = createEventDispatcher();
  
  let viewMode: 'flesh' | 'skeleton' = 'flesh';

  function toggleViewMode() {
    viewMode = viewMode === 'flesh' ? 'skeleton' : 'flesh';
  }

  // Modo de desenvolvedor para ajustar hitboxes
  let devMode = false;
  let selectedDevPartId: string | null = null;

  // Listas de partes do corpo interativas separadas por modo de visualização
  let fleshZones = [
    { id: 'head', label: 'Cabeça', top: 1, left: 40, width: 20, height: 16 },
    { id: 'upper', label: 'Peito', top: 18, left: 35, width: 29, height: 20 },
    { id: 'lower', label: 'Abdômen', top: 38, left: 36, width: 28, height: 10 },
    { id: 'rarm', label: 'Braço Dir.', top: 18, left: 17, width: 17, height: 30 },
    { id: 'larm', label: 'Braço Esq.', top: 18, left: 65, width: 17, height: 30 },
    { id: 'rhand', label: 'Mão Dir.', top: 49, left: 11, width: 14, height: 11 },
    { id: 'lhand', label: 'Mão Esq.', top: 49, left: 75, width: 14, height: 11 },
    { id: 'rleg', label: 'Perna Dir.', top: 47, left: 33, width: 17, height: 44 },
    { id: 'lleg', label: 'Perna Esq.', top: 47, left: 50, width: 17, height: 44 },
    { id: 'rfoot', label: 'Pé Dir.', top: 92, left: 35, width: 13, height: 8 },
    { id: 'lfoot', label: 'Pé Esq.', top: 92, left: 53, width: 13, height: 8 }
  ];

  let skeletonZones = [
    { id: 'head', label: 'Cabeça', top: 1, left: 41, width: 18, height: 14 },
    { id: 'upper', label: 'Peito', top: 19, left: 36, width: 28, height: 18 },
    { id: 'rarm', label: 'Braço Dir.', top: 19, left: 19, width: 16, height: 29 },
    { id: 'larm', label: 'Braço Esq.', top: 19, left: 65, width: 16, height: 29 },
    { id: 'rhand', label: 'Mão Dir.', top: 49, left: 12, width: 14, height: 11 },
    { id: 'lhand', label: 'Mão Esq.', top: 49, left: 74, width: 14, height: 11 },
    { id: 'rleg', label: 'Perna Dir.', top: 48, left: 35, width: 13, height: 40 },
    { id: 'lleg', label: 'Perna Esq.', top: 48, left: 53, width: 13, height: 40 },
    { id: 'rfoot', label: 'Pé Dir.', top: 89, left: 35, width: 13, height: 10 },
    { id: 'lfoot', label: 'Pé Esq.', top: 89, left: 52, width: 13, height: 10 },
    { id: 'spine', label: 'Coluna', top: 18, left: 45, width: 10, height: 26 }
  ];

  // Tentar carregar do LocalStorage
  import { onMount } from 'svelte';
  onMount(() => {
    try {
      // FORÇAR LIMPEZA UMA VEZ PARA RESOLVER O BUG DA MÃO ESQUERDA
      if (!localStorage.getItem('fdb_cache_cleared_v2')) {
        localStorage.removeItem('fdb_fleshZones');
        localStorage.removeItem('fdb_skeletonZones');
        localStorage.setItem('fdb_cache_cleared_v2', 'true');
        console.log("CACHE LIMPO AUTOMATICAMENTE");
      } else {
        const savedFlesh = localStorage.getItem('fdb_fleshZones');
        const savedSkeleton = localStorage.getItem('fdb_skeletonZones');
        if (savedFlesh) fleshZones = JSON.parse(savedFlesh);
        if (savedSkeleton) skeletonZones = JSON.parse(savedSkeleton);
      }
    } catch (e) { console.error("Error loading dev config", e); }
  });

  function saveDevConfigToLocal() {
    localStorage.setItem('fdb_fleshZones', JSON.stringify(fleshZones));
    localStorage.setItem('fdb_skeletonZones', JSON.stringify(skeletonZones));
    alert("Progresso salvo provisoriamente (no LocalStorage do seu jogo)!");
  }

  function resetDevConfig() {
    localStorage.removeItem('fdb_fleshZones');
    localStorage.removeItem('fdb_skeletonZones');
    alert("Configurações resetadas! Feche o painel e abra novamente para ver o padrão.");
  }

  // Referência computada para as zonas ativas no momento
  $: activeZones = viewMode === 'flesh' ? fleshZones : skeletonZones;

  // Logic for dragging in dev mode
  let draggingPartId: string | null = null;
  let startX = 0;
  let startY = 0;
  let startLeft = 0;
  let startTop = 0;

  function handlePointerDown(event: PointerEvent, partId: string) {
    if (!devMode) return;
    event.stopPropagation();
    
    // Ignorar se estiver clicando na borda direita/inferior (área de resize)
    const rect = (event.target as HTMLElement).getBoundingClientRect();
    if (event.clientX > rect.right - 15 || event.clientY > rect.bottom - 15) return;

    draggingPartId = partId;
    startX = event.clientX;
    startY = event.clientY;
    
    const part = activeZones.find(p => p.id === partId);
    if (part) {
      startLeft = part.left;
      startTop = part.top;
    }
    
    // Captura os eventos do mouse fora do elemento
    window.addEventListener('pointermove', handlePointerMove);
    window.addEventListener('pointerup', handlePointerUp);
  }

  function handlePointerMove(event: PointerEvent) {
    if (!devMode || !draggingPartId) return;
    
    // Converter o movimento do pixel do mouse em porcentagem (baseado no container)
    const container = document.querySelector('.body-silhouette-bg') as HTMLElement;
    if (!container) return;
    
    const rect = container.getBoundingClientRect();
    const percentX = ((event.clientX - startX) / rect.width) * 100;
    const percentY = ((event.clientY - startY) / rect.height) * 100;
    
    const updatedMap = (zones) => zones.map(part => {
      if (part.id === draggingPartId) {
        return {
          ...part,
          left: Math.round(startLeft + percentX),
          top: Math.round(startTop + percentY)
        };
      }
      return part;
    });

    if (viewMode === 'flesh') fleshZones = updatedMap(fleshZones);
    else skeletonZones = updatedMap(skeletonZones);
  }

  function handlePointerUp() {
    draggingPartId = null;
    window.removeEventListener('pointermove', handlePointerMove);
    window.removeEventListener('pointerup', handlePointerUp);
  }

  function generateConfigOutput() {
    const mapper = (p) => ({
      id: p.id,
      label: p.label,
      top: `${p.top}%`,
      left: `${p.left}%`,
      width: `${p.width}%`,
      height: `${p.height}%`
    });
    
    return "FLESH ZONES:\n" + JSON.stringify(fleshZones.map(mapper), null, 2) + 
           "\n\nSKELETON ZONES:\n" + JSON.stringify(skeletonZones.map(mapper), null, 2);
  }

  function getPartStatus(partId: string) {
    let status = { hasWound: false, isBleeding: false, isCritical: false, hasFracture: false };
    const partWound = wounds[partId];
    if (partWound) {
      status.hasWound = true;
      status.isBleeding = partWound.bleeding > 0;
      status.isCritical = partWound.bleeding >= 60 || partWound.severity >= 75;
      
      // Checa se há fratura
      if (partWound.boneIntegrity && partWound.boneIntegrity !== 'Intact') {
        status.hasFracture = true;
      }
    }
    return status;
  }

  function handlePartClick(partId: string) {
    if (devMode) {
      selectedDevPartId = partId; // Seleciona para redimensionar
      return; 
    }
    dispatch('selectPart', partId);
  }
  
  function getPairedPart(partId: string) {
    if (partId.startsWith('l')) return 'r' + partId.substring(1);
    if (partId.startsWith('r')) return 'l' + partId.substring(1);
    return null;
  }

  function resizeDevPart(axis: 'width' | 'height', amount: number) {
    if (!selectedDevPartId) return;
    const pairedId = getPairedPart(selectedDevPartId);
    
    // Calcula o novo valor baseado na peça selecionada
    let newValue = 1;
    const currentList = viewMode === 'flesh' ? fleshZones : skeletonZones;
    const selectedPart = currentList.find(p => p.id === selectedDevPartId);
    if (selectedPart) {
      newValue = Math.max(1, selectedPart[axis] + amount);
    }

    const updatedMap = (zones) => zones.map(part => {
      // Aplica na selecionada E na pareada (simetria)
      if (part.id === selectedDevPartId || part.id === pairedId) {
        return {
          ...part,
          [axis]: newValue
        };
      }
      return part;
    });

    if (viewMode === 'flesh') fleshZones = updatedMap(fleshZones);
    else skeletonZones = updatedMap(skeletonZones);
  }

  function removeDevPart() {
    if (!selectedDevPartId) return;
    if (viewMode === 'flesh') {
      fleshZones = fleshZones.filter(p => p.id !== selectedDevPartId);
    } else {
      skeletonZones = skeletonZones.filter(p => p.id !== selectedDevPartId);
    }
    selectedDevPartId = null;
  }

  function moveDevPart(axis: 'top' | 'left', amount: number) {
    if (!selectedDevPartId) return;
    
    const updatedMap = (zones) => zones.map(part => {
      if (part.id === selectedDevPartId) {
        return {
          ...part,
          [axis]: part[axis] + amount
        };
      }
      return part;
    });

    if (viewMode === 'flesh') fleshZones = updatedMap(fleshZones);
    else skeletonZones = updatedMap(skeletonZones);
  }
</script>

<style>
  .triage-container {
    position: relative;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
  }

  .toggle-btn {
    position: absolute;
    top: 20px;
    right: 20px;
    background: rgba(20, 20, 20, 0.8);
    border: 1px solid var(--leather-stitch);
    color: var(--text-color);
    padding: 10px 20px;
    font-family: 'Western', serif;
    cursor: pointer;
    z-index: 10;
    transition: all 0.2s;
  }
  .toggle-btn:hover {
    background: rgba(226,199,146, 0.2);
  }

  .dev-btn {
    position: absolute;
    top: 60px;
    right: 20px;
    background: rgba(180, 0, 0, 0.8);
    border: 1px solid white;
    color: white;
    padding: 10px 20px;
    font-family: sans-serif;
    font-weight: bold;
    cursor: pointer;
    z-index: 10;
  }

  .dev-save-btn {
    position: absolute;
    top: 100px;
    right: 20px;
    background: rgba(0, 150, 0, 0.8);
    border: 1px solid white;
    color: white;
    padding: 10px 20px;
    font-family: sans-serif;
    font-weight: bold;
    cursor: pointer;
    z-index: 10;
  }

  .dev-reset-btn {
    position: absolute;
    top: 150px;
    right: 20px;
    background: rgba(150, 0, 0, 0.8);
    border: 1px solid white;
    color: white;
    padding: 10px 20px;
    font-family: sans-serif;
    font-weight: bold;
    cursor: pointer;
    z-index: 10;
  }

  .dev-output {
    position: absolute;
    bottom: 20px;
    right: 20px;
    background: rgba(0,0,0,0.9);
    color: #0f0;
    padding: 15px;
    font-family: monospace;
    font-size: 12px;
    z-index: 10;
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid #0f0;
    white-space: pre-wrap;
    user-select: all;
  }

  .body-silhouette-bg {
    position: relative;
    height: 90%;
    width: 45vh; /* approximate 1:2 ratio */
    background-size: contain;
    background-position: center;
    background-repeat: no-repeat;
    /* Remover bordas placeholder agora que temos imagens */
  }

  .hitbox {
    position: absolute;
    cursor: pointer;
    border: 1px solid rgba(0, 255, 0, 0.4); /* DEIXEI VERDE PARA AJUDAR NO ALINHAMENTO */
    transition: background-color 0.2s ease, border 0.2s ease, box-shadow 0.2s ease;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .hitbox.dev-mode {
    border: 2px dashed #0f0 !important;
    background-color: rgba(0, 255, 0, 0.1);
    z-index: 100;
  }

  .hitbox.dev-mode.dev-selected {
    background-color: rgba(255, 0, 0, 0.3) !important;
    border: 2px solid #f00 !important;
  }

  .hitbox:hover {
    background-color: rgba(0, 255, 0, 0.2);
    border: 1px solid rgba(0, 255, 0, 0.8);
  }

  /* Modos visuais dependendo da view */
  .hitbox.bleeding {
    background-color: rgba(180, 0, 0, 0.2);
    box-shadow: inset 0 0 15px rgba(180, 0, 0, 0.4);
    border: 1px solid rgba(180, 0, 0, 0.5);
  }

  .hitbox.critical {
    background-color: rgba(220, 0, 0, 0.4);
    box-shadow: inset 0 0 20px rgba(220, 0, 0, 0.6);
    border: 2px solid rgba(220, 0, 0, 0.8);
    animation: pulse-critical 1.5s infinite;
  }

  .hitbox.fracture {
    background-color: rgba(255, 200, 0, 0.3);
    box-shadow: inset 0 0 20px rgba(255, 200, 0, 0.5);
    border: 2px solid rgba(255, 200, 0, 0.8);
    animation: pulse-fracture 1s infinite;
  }

  @keyframes pulse-critical {
    0% { opacity: 0.7; }
    50% { opacity: 1; }
    100% { opacity: 0.7; }
  }

  @keyframes pulse-fracture {
    0% { opacity: 0.5; box-shadow: inset 0 0 10px rgba(255,200,0,0.3); }
    50% { opacity: 1; box-shadow: inset 0 0 25px rgba(255,200,0,0.7); }
    100% { opacity: 0.5; box-shadow: inset 0 0 10px rgba(255,200,0,0.3); }
  }

</style>

<div class="triage-container">
  
  <button class="toggle-btn" on:click={toggleViewMode}>
    {viewMode === 'flesh' ? 'Ativar Raio-X' : 'Modo Carne'}
  </button>

  <button class="dev-btn" on:click={() => devMode = !devMode}>
    {devMode ? 'SALVAR E SAIR (DEV)' : 'MODO ALINHAMENTO (DEV)'}
  </button>

  {#if devMode}
    <button class="dev-save-btn" on:click={saveDevConfigToLocal}>
      SALVAR PROVISÓRIO (LOCAL)
    </button>
    <button class="dev-reset-btn" on:click={resetDevConfig}>
      RESETAR PARA PADRÃO
    </button>
    <div class="dev-output">
      {#if selectedDevPartId}
        {@const sp = activeZones.find(p => p.id === selectedDevPartId)}
        <div style="margin-bottom: 15px; padding: 10px; background: rgba(255,255,255,0.1); border: 1px solid white; display: flex; flex-direction: column; gap: 15px;">
          <strong>EDITANDO: {sp?.label}</strong>
          
          <div style="display: flex; justify-content: space-between; gap: 20px;">
            <!-- Controles de Mover -->
            <div style="text-align: center;">
              <strong>MOVER</strong><br/>
              <button style="padding: 5px 15px; margin-bottom: 5px;" on:click={() => moveDevPart('top', -1)}>⬆️</button><br/>
              <button style="padding: 5px 15px;" on:click={() => moveDevPart('left', -1)}>⬅️</button>
              <button style="padding: 5px 15px;" on:click={() => moveDevPart('left', 1)}>➡️</button><br/>
              <button style="padding: 5px 15px; margin-top: 5px;" on:click={() => moveDevPart('top', 1)}>⬇️</button>
            </div>

            <!-- Controles de Tamanho -->
            <div style="text-align: center;">
              <strong>TAMANHO (Simétrico)</strong><br/>
              <div style="display: flex; gap: 10px; margin-top: 10px;">
                <div>
                  LARGURA:<br/>
                  <button style="padding: 5px 15px; margin-top: 5px;" on:click={() => resizeDevPart('width', -1)}>-</button>
                  <button style="padding: 5px 15px; margin-top: 5px;" on:click={() => resizeDevPart('width', 1)}>+</button>
                </div>
                <div>
                  ALTURA:<br/>
                  <button style="padding: 5px 15px; margin-top: 5px;" on:click={() => resizeDevPart('height', -1)}>-</button>
                  <button style="padding: 5px 15px; margin-top: 5px;" on:click={() => resizeDevPart('height', 1)}>+</button>
                </div>
              </div>
            </div>
            
            <!-- Botão de Deletar -->
            <div style="display: flex; align-items: center;">
              <button style="background: red; color: white; padding: 15px; font-weight: bold; border: 2px solid white; cursor: pointer;" on:click={removeDevPart}>
                🗑️ EXCLUIR<br/>ESTA CAIXA
              </button>
            </div>
          </div>
        </div>
      {:else}
        <div style="margin-bottom: 15px; color: yellow;">CLIQUE EM UMA CAIXA PARA REDIMENSIONAR</div>
      {/if}

      COPIE ISSO E MANDE PRO ANTIGRAVITY:<br/><br/>
      {generateConfigOutput()}
    </div>
  {/if}

  <div class="body-silhouette-bg" style="background-image: url({viewMode === 'flesh' ? bodyFleshImg : bodySkeletonImg});">
    <!-- Overlay hitboxes for interaction -->
    {#each activeZones as part}
      {@const status = getPartStatus(part.id)}
      
      <!-- Lógica: Mostrar sangramento no modo Carne, mostrar Fratura no modo Esqueleto -->
      {@const isGlowingFracture = viewMode === 'skeleton' && status.hasFracture && !devMode}
      {@const isGlowingBlood = viewMode === 'flesh' && status.isBleeding && !devMode}
      {@const isGlowingCritical = viewMode === 'flesh' && status.isCritical && !devMode}

      <div 
        class="hitbox {isGlowingCritical ? 'critical' : ''} {isGlowingBlood && !isGlowingCritical ? 'bleeding' : ''} {isGlowingFracture ? 'fracture' : ''} {devMode ? 'dev-mode' : ''} {devMode && selectedDevPartId === part.id ? 'dev-selected' : ''}"
        style="top: {part.top}%; left: {part.left}%; width: {part.width}%; height: {part.height}%; touch-action: none;"
        on:click={() => handlePartClick(part.id)}
        on:pointerdown={(e) => handlePointerDown(e, part.id)}
        title={part.label}
      >
        <!-- Texto visível temporariamente para ajudar a alinhar -->
        <div style="color: rgba(255,255,255,0.8); font-size: 1.2vh; font-weight: bold; text-align: center; pointer-events: none; text-shadow: 1px 1px 2px black;">
          {part.label}
          {#if devMode}<br/><span style="font-size: 0.8vh; color: #0f0;">Mover / Escalar</span>{/if}
        </div>
      </div>
    {/each}
  </div>
</div>
