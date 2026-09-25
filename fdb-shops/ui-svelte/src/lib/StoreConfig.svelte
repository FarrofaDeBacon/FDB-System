<script>
    import Select from '../../../../fdb-libs/ui/src/components/Select.svelte';
    let { store, onClose, onDeleted = () => {} } = $props();

    const templateConfig = {
        general: [
            { id: 'label', name: 'Nome da Loja', type: 'text' },
            { id: 'npc_model', name: 'Modelo do NPC', type: 'text' },
            { id: 'stock_limit', name: 'Limite de Estoque', type: 'number' }
        ],
        saloon: [
            { id: 'label', name: 'Nome do Saloon', type: 'text' },
            { id: 'npc_model', name: 'Bartender', type: 'text' },
            { id: 'drinks_license', name: 'Licença de Bebidas', type: 'checkbox' }
        ],
        weapons: [
            { id: 'label', name: 'Armeiro', type: 'text' },
            { id: 'npc_model', name: 'Modelo NPC', type: 'text' }
        ],
        default: [
            { id: 'label', name: 'Nome', type: 'text' },
            { id: 'npc_model', name: 'Modelo NPC', type: 'text' }
        ]
    };

    let fields = $derived(templateConfig[store.template] || templateConfig.default);

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

    function placeObject(field) {
        if (!store.id || !store[field.id]) {
            fetch(`https://${window.GetParentResourceName()}/notify`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: "Preencha o modelo antes de posicionar!", type: 'error' })
            });
            return;
        }
        
        let mode = 'ghost';
        let spawnType = field.id === 'npc_model' ? 'npc' : 'prop';

        fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type: spawnType,
                model: store[field.id],
                shopId: store.id,
                mode: mode
            })
        });
    }

    function placeComponent(type) {
        let model = null;
        let mode = 'ghost';

        if (type === 'admin_panel') {
            mode = 'marker';
        } else {
            let modelKey = type + '_model';
            let coordsKey = type + '_coords';
            let markerKey = type + '_is_marker';

            if (store[markerKey]) {
                mode = 'marker';
                model = null;
            } else {
                if (!store[modelKey]) {
                    fetch(`https://${window.GetParentResourceName()}/notify`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ message: "Selecione o modelo antes de posicionar!", type: 'error' })
                    });
                    return;
                }
                model = store[modelKey];
                
                if (store[coordsKey]) {
                    mode = 'adjust';
                }
            }
        }

        fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type: type,
                model: model,
                shopId: store.id,
                mode: mode
            })
        });
    }

    async function removeComponent(type, label) {
        let res = await fetch(`https://${window.GetParentResourceName()}/requestRemoval`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: type, shopId: store.id, label: label })
        });
        
        let confirmed = await res.json();
        if (confirmed) {
            store[type + '_coords'] = null;
            store[type + '_is_marker'] = false;
            store[type + '_model'] = '';
            
            // For admin panel
            if (type === 'admin_panel') {
                store.admin_panel_coords = null;
            }
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
        <p>Editando Template: {store.template}</p>
    </div>

    <div class="form-grid">
        <div class="input-group">
            <label>ID da Loja (Somente Leitura)</label>
            <input type="text" value={store.id} disabled class="fdb-input disabled" />
        </div>

        <div class="input-group">
            <label for="{store.id}-owner_id">Dono da Loja (Citizen ID)</label>
            <input id="{store.id}-owner_id" type="text" bind:value={store.owner_id} class="fdb-input" placeholder="Ex: RBM12345 (opcional)" />
        </div>

        {#each fields as field}
            <div class="input-group">
                <label for="{store.id}-{field.id}">{field.name}</label>
                
                {#if field.type === 'text'}
                    <div style="display: flex; flex-direction: column; gap: 0.5rem; width: 100%;">
                        <div style="display: flex; gap: 0.5rem; width: 100%;">
                            {#if field.id === 'npc_model'}
                                <div style="flex: 1;">
                                    <Select id="{store.id}-{field.id}" bind:value={store[field.id]} options={npcModels} />
                                </div>
                            {:else}
                                <input id="{store.id}-{field.id}" type="text" bind:value={store[field.id]} class="fdb-input" style="flex: 1;" />
                            {/if}
                            
                            {#if field.id === 'npc_model' || field.id === 'register_model'}
                                <button class="test-button submit" style="padding: 0.5rem 1rem; font-size: 0.9rem;" onclick={() => placeObject(field)}>
                                    Posicionar
                                </button>
                            {/if}
                        </div>
                    </div>
                {:else if field.type === 'number'}
                    <input id="{store.id}-{field.id}" type="number" value={store[field.id] || 0} oninput={(e) => store[field.id] = parseFloat(e.target.value)} class="fdb-input" />
                {:else if field.type === 'checkbox'}
                    <label class="checkbox-container">
                        <input id="{store.id}-{field.id}" type="checkbox" checked={store[field.id]} onchange={(e) => store[field.id] = e.target.checked} />
                        <span class="checkmark">Sim / Ativo</span>
                    </label>
                {/if}
            </div>
        {/each}
    </div>

    <!-- Seção de Componentes Físicos/Abstratos -->
    <div class="header" style="margin-top: 1.5rem;">
        <h2 style="font-size: 1.2rem; color: var(--fdb-text-muted);">Componentes da Loja</h2>
    </div>
    
    <div class="form-grid">
        <!-- Registradora -->
        <div class="input-group">
            <label for="{store.id}-registradora_model">Registradora</label>
            <div style="display: flex; flex-direction: column; gap: 0.5rem; width: 100%;">
                <div style="display: flex; gap: 0.5rem; width: 100%;">
                    <div style="flex: 1;">
                        <Select id="{store.id}-registradora_model" bind:value={store.registradora_model} options={registerModels} disabled={store.registradora_is_marker} />
                    </div>
                    <button class="test-button submit" style="padding: 0.5rem 1rem; font-size: 0.9rem;" onclick={() => placeComponent('registradora')}>
                        {store.registradora_coords ? "Ajustar Posição" : "Adicionar Registradora"}
                    </button>
                    {#if store.registradora_coords}
                        <button class="test-button cancel" style="padding: 0.5rem 0.8rem; font-size: 0.9rem; background-color: rgba(170, 51, 51, 0.7);" title="Remover Registradora" onclick={() => removeComponent('registradora', 'Registradora')}>
                            ❌
                        </button>
                    {/if}
                </div>
                <label class="checkbox-container" style="margin-top: 0.2rem;">
                    <input type="checkbox" bind:checked={store.registradora_is_marker} />
                    <span class="checkmark">Só Marcador (Sem objeto físico)</span>
                </label>
            </div>
        </div>

        <!-- Baú de Estoque -->
        <div class="input-group">
            <label for="{store.id}-bau_model">Baú de Estoque</label>
            <div style="display: flex; flex-direction: column; gap: 0.5rem; width: 100%;">
                <div style="display: flex; gap: 0.5rem; width: 100%;">
                    <div style="flex: 1;">
                        <Select id="{store.id}-bau_model" bind:value={store.bau_model} options={chestModels} disabled={store.bau_is_marker} />
                    </div>
                    <button class="test-button submit" style="padding: 0.5rem 1rem; font-size: 0.9rem;" onclick={() => placeComponent('bau')}>
                        {store.bau_coords ? "Ajustar Posição" : "Adicionar Baú"}
                    </button>
                    {#if store.bau_coords}
                        <button class="test-button cancel" style="padding: 0.5rem 0.8rem; font-size: 0.9rem; background-color: rgba(170, 51, 51, 0.7);" title="Remover Baú" onclick={() => removeComponent('bau', 'Baú de Estoque')}>
                            ❌
                        </button>
                    {/if}
                </div>
                <label class="checkbox-container" style="margin-top: 0.2rem;">
                    <input type="checkbox" bind:checked={store.bau_is_marker} />
                    <span class="checkmark">Só Marcador (Sem objeto físico)</span>
                </label>
            </div>
        </div>

        <!-- Bancada de Craft -->
        <div class="input-group">
            <label for="{store.id}-craft_model">Bancada de Craft</label>
            <div style="display: flex; flex-direction: column; gap: 0.5rem; width: 100%;">
                <div style="display: flex; gap: 0.5rem; width: 100%;">
                    <div style="flex: 1;">
                        <Select id="{store.id}-craft_model" bind:value={store.craft_model} options={craftModels} disabled={store.craft_is_marker} />
                    </div>
                    <button class="test-button submit" style="padding: 0.5rem 1rem; font-size: 0.9rem;" onclick={() => placeComponent('craft')}>
                        {store.craft_coords ? "Ajustar Posição" : "Adicionar Bancada"}
                    </button>
                    {#if store.craft_coords}
                        <button class="test-button cancel" style="padding: 0.5rem 0.8rem; font-size: 0.9rem; background-color: rgba(170, 51, 51, 0.7);" title="Remover Bancada" onclick={() => removeComponent('craft', 'Bancada de Craft')}>
                            ❌
                        </button>
                    {/if}
                </div>
                <label class="checkbox-container" style="margin-top: 0.2rem;">
                    <input type="checkbox" bind:checked={store.craft_is_marker} />
                    <span class="checkmark">Só Marcador (Sem objeto físico)</span>
                </label>
            </div>
        </div>

        <!-- Painel Admin -->
        <div class="input-group">
            <label>Ponto de Acesso Admin</label>
            <div style="display: flex; gap: 0.5rem; width: 100%;">
                <button class="test-button submit" style="flex: 1;" onclick={() => placeComponent('admin_panel')}>
                    {store.admin_panel_coords ? "Ajustar Posição do Painel" : "Marcar Posição do Painel"}
                </button>
                {#if store.admin_panel_coords}
                    <button class="test-button cancel" style="padding: 0.5rem 0.8rem; font-size: 0.9rem; background-color: rgba(170, 51, 51, 0.7);" title="Remover Painel Admin" onclick={() => removeComponent('admin_panel', 'Painel Admin')}>
                        ❌
                    </button>
                {/if}
            </div>
            <span style="font-size: 0.8rem; color: var(--fdb-text-muted); margin-top: 0.3rem;">Define o gatilho para acessar as configurações desta loja.</span>
        </div>
    </div>

    <div class="footer" style="justify-content: space-between;">
        <button class="test-button cancel" style="background-color: rgba(170, 51, 51, 0.7);" onclick={deleteStore}>Excluir Loja</button>
        <div style="display: flex; gap: 0.5rem;">
            <button class="test-button submit" onclick={saveConfig}>Salvar Alterações</button>
            <button class="test-button cancel" onclick={onClose}>Fechar (ESC)</button>
        </div>
    </div>
</div>

<style>
    /* Usando exatamente o CSS do Theme Test original */
    .theme-test-card {
        background-color: var(--fdb-background-color, #1a1a1a);
        color: var(--fdb-text-primary, #ffffff);
        padding: 2rem;
        border: 2px solid var(--fdb-border-color-wood, #555);
        border-radius: var(--fdb-border-radius, 8px);
        width: 500px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    .header {
        text-align: center;
        margin-bottom: 2rem;
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
        gap: 1.5rem;
        margin-bottom: 2rem;
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
</style>
