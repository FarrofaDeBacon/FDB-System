<script>
    import Select from '../../../../fdb-libs/ui/src/components/Select.svelte';
    let { store, onClose, onDeleted = () => {} } = $props();

    // Migrate old flat structure to new stations array if needed
    if (!store.stations) {
        store.stations = [];
    }

    const registerModels = [
        'p_cashregister01x', 'p_cashregister02x', 'p_cashregister03x', 
        'p_cashregister04x', 'p_cashregister05x', 'p_cashregister06x'
    ];
    
    const chestModels = [
        'p_trunk01x', 'p_trunk02x', 'p_chest01x', 
        'p_chest02x', 'p_chest03x', 'p_strongbox01x'
    ];
    
    const craftModels = [
        'p_worktable01x', 'p_cs_tooltable01x', 'p_anvil01x', 'p_cs_workbench01x'
    ];
    
    const npcModels = [
        'u_m_o_blwbartender_01', 'u_f_o_blwbartender_01', 
        'u_m_m_valbartender_01', 'u_m_m_valgunsmith_01', 
        'u_m_m_valgenstoreowner_01', 'u_f_m_valtownfolk_01',
        'u_m_m_bht_bartender', 'u_m_m_bwm_bartender_01',
        'u_m_m_sdobartender_01'
    ];

    function addStation(type) {
        const tempId = 'temp-' + crypto.randomUUID();
        let defaultModel = '';
        if (type === 'registradora') defaultModel = registerModels[0];
        if (type === 'bau') defaultModel = chestModels[0];
        if (type === 'craft') defaultModel = craftModels[0];
        if (type === 'npc') defaultModel = npcModels[0];
        
        let newStation = {
            id: tempId,
            type: type,
            is_marker: type === 'admin_panel' ? true : false,
            position: null
        };
        
        if (type === 'npc') {
            newStation.npc_model = defaultModel;
        } else {
            newStation.prop_model = defaultModel;
        }

        store.stations = [...store.stations, newStation];
    }

    function placeComponent(station) {
        if (!station.is_marker && station.type !== 'admin_panel') {
            let model = station.type === 'npc' ? station.npc_model : station.prop_model;
            if (!model) {
                fetch(`https://${window.GetParentResourceName()}/notify`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: "Selecione o modelo antes de posicionar!", type: 'error' })
                });
                return;
            }
        }

        let mode = station.position ? 'adjust' : 'ghost';
        if (station.is_marker || station.type === 'admin_panel') {
            mode = 'marker';
        }

        fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type: station.type,
                model: station.type === 'npc' ? station.npc_model : station.prop_model,
                shopId: store.id,
                stationId: station.id,
                mode: mode
            })
        });
    }

    async function removeComponent(station) {
        if (typeof station.id === 'string' && station.id.startsWith('temp-')) {
            // Unsaved station, just remove from UI array
            store.stations = store.stations.filter(s => s.id !== station.id);
            return;
        }

        let res = await fetch(`https://${window.GetParentResourceName()}/requestRemoval`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ shopId: store.id, stationId: station.id })
        });
        
        let confirmed = await res.json();
        if (confirmed) {
            store.stations = store.stations.filter(s => s.id !== station.id);
        }
    }

    async function deleteStore() {
        let res = await fetch(`https://${window.GetParentResourceName()}/deleteStore`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ shopId: store.id, label: store.label || store.id })
        });
        
        let confirmed = await res.json();
        if (confirmed) {
            onDeleted(store.id);
        }
    }

    function saveConfig() {
        fetch(`https://${window.GetParentResourceName()}/saveStoreConfig`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ store })
        }).then(() => {
            onClose();
        });
    }
</script>

<div class="theme-test-card">
    <div class="header">
        <h1>{store.label || store.id}</h1>
        <p>ID: {store.id}</p>
    </div>

    <div class="form-grid">
        <div class="input-group">
            <label for="{store.id}-label">Nome da Loja</label>
            <input id="{store.id}-label" type="text" bind:value={store.label} class="fdb-input" />
        </div>

        <div class="input-group">
            <label for="{store.id}-owner_id">Dono da Loja (Citizen ID)</label>
            <input id="{store.id}-owner_id" type="text" bind:value={store.owner_id} class="fdb-input" placeholder="Ex: RBM12345 (opcional)" />
        </div>
    </div>

    <div class="header" style="margin-top: 1.5rem; margin-bottom: 1rem;">
        <h2 style="font-size: 1.2rem; color: var(--fdb-text-muted);">Estações da Loja</h2>
    </div>
    
    <div class="form-grid" style="gap: 1rem; max-height: 400px; overflow-y: auto; padding-right: 0.5rem;">
        {#each store.stations as station (station.id)}
            <div class="input-group" style="background: rgba(255,255,255,0.05); padding: 1rem; border-radius: 6px; border: 1px solid var(--fdb-border-color-wood, #444);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                    <label style="margin: 0; color: var(--fdb-accent-color); font-size: 1rem;">
                        {station.type.toUpperCase()} 
                        {#if station.id && typeof station.id === 'number'}
                            <span style="font-size: 0.75rem; color: var(--fdb-text-muted);">[ID: {station.id}]</span>
                        {/if}
                    </label>
                    <button class="test-button cancel" style="padding: 0.3rem 0.5rem; font-size: 0.8rem; border: none;" title="Remover Estação" onclick={() => removeComponent(station)}>
                        ❌ Remover
                    </button>
                </div>
                
                <div style="display: flex; flex-direction: column; gap: 0.5rem; width: 100%;">
                    {#if station.type !== 'admin_panel'}
                        <div style="display: flex; gap: 0.5rem; width: 100%;">
                            <div style="flex: 1;">
                                {#if station.type === 'npc'}
                                    <Select id="model-{station.id}" bind:value={station.npc_model} options={npcModels} />
                                {:else if station.type === 'registradora'}
                                    <Select id="model-{station.id}" bind:value={station.prop_model} options={registerModels} disabled={station.is_marker} />
                                {:else if station.type === 'bau'}
                                    <Select id="model-{station.id}" bind:value={station.prop_model} options={chestModels} disabled={station.is_marker} />
                                {:else if station.type === 'craft'}
                                    <Select id="model-{station.id}" bind:value={station.prop_model} options={craftModels} disabled={station.is_marker} />
                                {/if}
                            </div>
                        </div>
                    {/if}
                    
                    <button class="test-button submit" style="padding: 0.5rem 1rem; font-size: 0.9rem;" onclick={() => placeComponent(station)}>
                        {station.position ? "Ajustar Posição" : "Marcar Posição"}
                    </button>

                    {#if station.type !== 'admin_panel' && station.type !== 'npc'}
                        <label class="checkbox-container" style="margin-top: 0.2rem;">
                            <input type="checkbox" bind:checked={station.is_marker} />
                            <span class="checkmark">Só Marcador (Sem objeto físico)</span>
                        </label>
                    {/if}
                </div>
            </div>
        {/each}

        {#if store.stations.length === 0}
            <p style="text-align: center; color: var(--fdb-text-muted);">Nenhuma estação adicionada.</p>
        {/if}
    </div>

    <!-- Barra de Adicionar Nova Estação -->
    <div style="display: flex; gap: 0.5rem; margin-top: 1rem; flex-wrap: wrap;">
        <button class="test-button" style="flex: 1; font-size: 0.8rem; padding: 0.5rem; border: 1px solid #444;" onclick={() => addStation('npc')}>+ NPC</button>
        <button class="test-button" style="flex: 1; font-size: 0.8rem; padding: 0.5rem; border: 1px solid #444;" onclick={() => addStation('registradora')}>+ Registradora</button>
        <button class="test-button" style="flex: 1; font-size: 0.8rem; padding: 0.5rem; border: 1px solid #444;" onclick={() => addStation('bau')}>+ Baú</button>
        <button class="test-button" style="flex: 1; font-size: 0.8rem; padding: 0.5rem; border: 1px solid #444;" onclick={() => addStation('craft')}>+ Craft</button>
        <button class="test-button" style="flex: 1; font-size: 0.8rem; padding: 0.5rem; border: 1px solid #444;" onclick={() => addStation('admin_panel')}>+ Painel Admin</button>
    </div>

    <div class="footer" style="justify-content: space-between; margin-top: 2rem;">
        <button class="test-button cancel" style="background-color: rgba(170, 51, 51, 0.7);" onclick={deleteStore}>Excluir Loja</button>
        <div style="display: flex; gap: 0.5rem;">
            <button class="test-button submit" onclick={saveConfig}>Salvar Alterações</button>
            <button class="test-button cancel" onclick={onClose}>Fechar (ESC)</button>
        </div>
    </div>
</div>

<style>
    .theme-test-card {
        background-color: var(--fdb-background-color, #1a1a1a);
        color: var(--fdb-text-primary, #ffffff);
        padding: 2rem;
        border: 2px solid var(--fdb-border-color-wood, #555);
        border-radius: var(--fdb-border-radius, 8px);
        width: 600px;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    .header {
        text-align: center;
        margin-bottom: 1rem;
    }

    h1 {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-accent-color, #ffaa00);
        margin-top: 0;
        margin-bottom: 0.5rem;
    }

    p {
        color: var(--fdb-text-secondary, #ccc);
        margin: 0;
        font-size: 0.9rem;
    }

    .form-grid {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .input-group {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        text-align: left;
    }

    .input-group label {
        color: var(--fdb-text-secondary, #ccc);
        font-size: 0.85rem;
        font-weight: bold;
    }

    .fdb-input {
        background-color: rgba(0, 0, 0, 0.2);
        color: var(--fdb-text-primary, #fff);
        border: 1px solid var(--fdb-border-color-wood, #444);
        padding: 0.75rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-family: var(--fdb-font-body, sans-serif);
        outline: none;
        transition: border-color 0.2s;
    }

    .fdb-input:focus {
        border-color: var(--fdb-accent-color, #ffaa00);
    }

    .fdb-input.disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .checkbox-container {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
        color: var(--fdb-text-primary, #fff);
        font-size: 0.85rem;
    }

    .footer {
        display: flex;
        justify-content: center;
        gap: 1rem;
    }

    .test-button {
        padding: 0.75rem 1.5rem;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        font-family: var(--fdb-font-display, serif);
        font-size: 1.1rem;
        transition: all 0.2s;
        border: 1px solid transparent;
        background: transparent;
        color: #fff;
    }
    
    .test-button:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }

    .test-button.submit {
        background-color: var(--fdb-accent-color-dark, #cc8800);
        color: var(--fdb-text-primary, #fff);
        border-color: var(--fdb-accent-color, #ffaa00);
    }

    .test-button.submit:hover {
        background-color: var(--fdb-accent-color, #ffaa00);
    }

    .test-button.cancel {
        background-color: transparent;
        color: var(--fdb-status-critical, #cc0000);
        border-color: var(--fdb-status-critical, #cc0000);
    }

    .test-button.cancel:hover {
        background-color: var(--fdb-status-critical, #cc0000);
        color: #fff;
    }
    
    /* Scrollbar for stations list */
    .form-grid::-webkit-scrollbar {
        width: 8px;
    }
    .form-grid::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.2);
        border-radius: 4px;
    }
    .form-grid::-webkit-scrollbar-thumb {
        background: var(--fdb-border-color-wood, #555);
        border-radius: 4px;
    }
    .form-grid::-webkit-scrollbar-thumb:hover {
        background: var(--fdb-accent-color, #ffaa00);
    }
</style>
