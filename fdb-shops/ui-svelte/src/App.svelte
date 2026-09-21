<script>
  import { onMount } from 'svelte';
  import './app.css';

  let visible = $state(false);
  let stores = $state([]);
  let selectedStore = $state(null);

  onMount(() => {
    window.addEventListener('message', (event) => {
      const data = event.data;
      if (data.action === 'openEditor') {
        stores = data.stores || [];
        visible = true;
      } else if (data.action === 'closeEditor') {
        visible = false;
      } else if (data.action === 'startPlacement') {
        visible = false; // Hide UI during freecam placement
      } else if (data.action === 'stopPlacement') {
        visible = true; // Show UI again after placing
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && visible) {
        close();
      }
    });
  });

  function close() {
    visible = false;
    fetch(`https://${window.GetParentResourceName()}/closeEditor`, {
      method: 'POST',
      body: JSON.stringify({})
    });
  }

  function startPlacement(type) {
    if (!selectedStore) return;
    let model = 'p_cashregister01x'; // Default for registradora
    if (type === 'npc') model = selectedStore.npc_model || 'u_m_m_valgeneralstoreowner_01';
    if (type === 'bau') model = 'p_chest01x';
    if (type === 'craft') model = 'p_cs_table_01x';

    fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
      method: 'POST',
      body: JSON.stringify({
        shopId: selectedStore.id,
        type: type,
        model: model
      })
    });
  }

  function selectStore(store) {
    selectedStore = store;
  }
</script>

{#if visible}
<main class="w-screen h-screen flex items-center justify-center p-10 font-crock select-none relative" style="background-color: rgba(0,0,0,0.5);">
  <div class="w-full max-w-6xl h-full flex shadow-2xl rounded-lg overflow-hidden border border-orange-900 bg-black/90 text-white">
    
    <!-- Sidebar (Store List) -->
    <div class="w-1/3 bg-[#111] border-r border-orange-900 flex flex-col relative" style="background-image: url('./assets/bg-leather-panel.png'); background-size: cover;">
      <div class="p-4 text-center border-b border-orange-900/50 bg-black/50">
        <h1 class="text-3xl text-orange-400 font-chinese drop-shadow-md tracking-wider">FDB Shops Editor</h1>
        <p class="text-sm text-gray-400">Gerenciamento de Lojas</p>
      </div>

      <div class="flex-1 overflow-y-auto p-4 space-y-2 relative z-10">
        {#each stores as store}
          <button 
            class="w-full text-left p-3 rounded-md transition duration-200 border {selectedStore?.id === store.id ? 'bg-orange-900/40 border-orange-500' : 'bg-black/40 border-transparent hover:border-orange-700/50 hover:bg-black/60'}"
            on:click={() => selectStore(store)}
          >
            <div class="font-bold text-lg text-orange-200">{store.label}</div>
            <div class="text-xs text-gray-400 uppercase tracking-widest">{store.id}</div>
          </button>
        {/each}
        {#if stores.length === 0}
          <div class="text-center text-gray-500 mt-10">Nenhuma loja carregada.</div>
        {/if}
      </div>
    </div>

    <!-- Main Panel -->
    <div class="w-2/3 flex flex-col relative" style="background-image: url('./assets/bg-bag-texture.png'); background-size: cover; background-blend-mode: multiply; background-color: #0f0f0f;">
      <div class="absolute inset-0 bg-gradient-to-b from-black/80 to-transparent pointer-events-none"></div>
      
      {#if selectedStore}
        <div class="p-8 relative z-10 flex flex-col h-full">
          <div class="flex justify-between items-start mb-6 border-b border-orange-900/50 pb-4">
            <div>
              <h2 class="text-4xl text-orange-400 font-chinese tracking-wide">{selectedStore.label}</h2>
              <span class="px-2 py-1 bg-orange-900/50 text-orange-200 text-xs rounded border border-orange-700/50">ID: {selectedStore.id}</span>
              <span class="px-2 py-1 bg-blue-900/50 text-blue-200 text-xs rounded border border-blue-700/50 ml-2">Catálogo: {selectedStore.template}</span>
            </div>
            <button class="text-red-400 hover:text-red-300 font-bold px-3 py-1 bg-black/50 rounded" on:click={close}>X FECHAR</button>
          </div>

          <div class="flex-1 grid grid-cols-2 gap-6">
            <!-- Placement Tools -->
            <div class="bg-black/60 border border-orange-900/50 p-6 rounded-lg backdrop-blur-sm">
              <h3 class="text-xl text-orange-300 mb-4 border-b border-orange-900/50 pb-2">Posicionamento de Bancadas</h3>
              <p class="text-sm text-gray-400 mb-6">Utilize a Câmera Livre (Drone) para posicionar exatamente onde as bancadas e o NPC da loja ficarão.</p>
              
              <div class="space-y-3">
                <button class="w-full bg-orange-800/80 hover:bg-orange-700 text-white p-3 rounded flex items-center justify-between border border-orange-600 transition" on:click={() => startPlacement('npc')}>
                  <span>👨‍💼 Posicionar NPC (Balconista)</span>
                  <span class="text-xs bg-black/50 px-2 py-1 rounded">Drone</span>
                </button>
                <button class="w-full bg-[#1e293b]/80 hover:bg-[#334155] text-white p-3 rounded flex items-center justify-between border border-[#475569] transition" on:click={() => startPlacement('registradora')}>
                  <span>🧾 Posicionar Registradora</span>
                  <span class="text-xs bg-black/50 px-2 py-1 rounded">Drone</span>
                </button>
                <button class="w-full bg-[#3f6212]/80 hover:bg-[#4d7c0f] text-white p-3 rounded flex items-center justify-between border border-[#65a30d] transition" on:click={() => startPlacement('bau')}>
                  <span>📦 Posicionar Baú de Estoque</span>
                  <span class="text-xs bg-black/50 px-2 py-1 rounded">Drone</span>
                </button>
                <button class="w-full bg-[#701a75]/80 hover:bg-[#86198f] text-white p-3 rounded flex items-center justify-between border border-[#a21caf] transition" on:click={() => startPlacement('craft')}>
                  <span>🔨 Posicionar Mesa de Craft</span>
                  <span class="text-xs bg-black/50 px-2 py-1 rounded">Drone</span>
                </button>
              </div>
            </div>

            <!-- Coming Soon / Additional Configs -->
            <div class="bg-black/60 border border-orange-900/50 p-6 rounded-lg backdrop-blur-sm flex flex-col items-center justify-center text-center">
              <h3 class="text-xl text-orange-300 mb-2">Catálogo de Produtos</h3>
              <p class="text-sm text-gray-400 mb-4">Esta loja utiliza o catálogo base: <strong class="text-orange-200">{selectedStore.template}</strong></p>
              <div class="p-4 bg-black/50 border border-dashed border-gray-600 rounded text-gray-500 text-sm w-full">
                Os itens disponíveis e preços são baseados na região e no tipo da loja. A edição do catálogo específico via interface será liberada em breve!
              </div>
            </div>
          </div>
        </div>
      {:else}
        <div class="m-auto flex flex-col items-center justify-center text-center opacity-50 relative z-10">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-24 w-24 text-orange-900 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 002-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
          </svg>
          <h2 class="text-2xl font-chinese text-orange-600">Nenhuma Loja Selecionada</h2>
          <p class="text-gray-400 text-sm">Selecione uma loja no menu à esquerda para configurar as bancadas e NPCs.</p>
        </div>
      {/if}
    </div>
  </div>
</main>
{/if}
