<script>
    import Select from '../../../../fdb-libs/ui/src/components/Select.svelte';
    import Input from '../../../../fdb-libs/ui/src/components/Input.svelte';
    import Panel from '../../../../fdb-libs/ui/src/components/Panel.svelte';
    
    let { store, onClose, onDeleted = () => {} } = $props();

    if (!store.stations) store.stations = [];
    if (!store.config) store.config = {};

    let activeTab = $state('geral');
    
    function switchTab(tab) {
        activeTab = tab;
    }
    
    let countReg = $derived(store.stations.filter(s => s.type === 'registradora').length);
    let countBau = $derived(store.stations.filter(s => s.type === 'bau').length);
    let countCraft = $derived(store.stations.filter(s => s.type === 'craft').length);
    let countNpc = $derived(store.stations.filter(s => s.type === 'npc').length);
    let countAdmin = $derived(store.stations.filter(s => s.type === 'admin_panel').length);

    const templateConfig = {
        general: [
            { id: 'stock_limit', name: 'Limite de Estoque', type: 'number' }
        ],
        saloon: [
            { id: 'drinks_license', name: 'Licença de Bebidas', type: 'checkbox' }
        ],
        weapons: [
            { id: 'weapon_license', name: 'Licença de Armas', type: 'checkbox' }
        ],
        default: []
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

    function getOptionsForField(fieldOptionsString) {
        if (fieldOptionsString === 'npcModels') return npcModels;
        return [];
    }

    function placeObject(field) {
        if (!store.id || !store[field.id]) return;
        let mode = 'ghost';
        let spawnType = field.id === 'npc_model' ? 'npc' : 'prop';

        fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: spawnType, model: store[field.id], shopId: store.id, mode: mode })
        });
    }

    function addStation(type) {
        const tempId = 'temp-' + crypto.randomUUID();
        let defaultModel = '';
        if (type === 'npc') defaultModel = npcModels[0];
        if (type === 'registradora') defaultModel = registerModels[0];
        if (type === 'bau') defaultModel = chestModels[0];
        if (type === 'craft') defaultModel = craftModels[0];

        store.stations = [...store.stations, {
            id: tempId, type: type,
            npc_model: type === 'npc' ? defaultModel : undefined,
            prop_model: type !== 'npc' && type !== 'admin_panel' ? defaultModel : undefined,
            position: null, heading: 0, is_marker: false
        }];
    }

    function placeComponent(station) {
        let model = null;
        let mode = 'ghost';

        if (station.type === 'admin_panel') {
            mode = 'marker';
        } else {
            if (station.is_marker) {
                mode = 'marker';
            } else {
                model = station.type === 'npc' ? station.npc_model : station.prop_model;
                if (!model) return;
                if (station.position) mode = 'adjust';
            }
        }

        fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type: station.type, model: model, shopId: store.id, stationId: station.id, mode: mode
            })
        });
    }

    function updateModule(station, moduleName, isChecked) {
        if (!station.metadata) station.metadata = {};
        if (!station.metadata.modules) station.metadata.modules = ["dashboard"];
        
        if (isChecked && !station.metadata.modules.includes(moduleName)) {
            station.metadata.modules = [...station.metadata.modules, moduleName];
        } else if (!isChecked) {
            station.metadata.modules = station.metadata.modules.filter(m => m !== moduleName);
        }
    }

    async function removeComponent(station) {
        if (typeof station.id === 'string' && station.id.startsWith('temp-')) {
            store.stations = store.stations.filter(s => s.id !== station.id);
            return;
        }

        let res = await fetch(`https://${window.GetParentResourceName()}/requestRemoval`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: station.type, shopId: store.id, stationId: station.id })
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
        if (confirmed) onDeleted(store.id);
    }

    function saveConfig() {
        fetch(`https://${window.GetParentResourceName()}/saveStoreConfig`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ store })
        }).then(() => onClose());
    }
</script>

<Panel title={store.label || store.id} id={store.id} width="clamp(320px, 65vw, 800px)">
    <div slot="tabs" class="fdb-tabs-container">
        <button class="fdb-tab {activeTab === 'geral' ? 'active' : ''}" onclick={() => switchTab('geral')}>Geral</button>
        <button class="fdb-tab {activeTab === 'registradora' ? 'active' : ''}" onclick={() => switchTab('registradora')}>Registradoras {#if countReg > 0}({countReg}){/if}</button>
        <button class="fdb-tab {activeTab === 'bau' ? 'active' : ''}" onclick={() => switchTab('bau')}>Baús {#if countBau > 0}({countBau}){/if}</button>
        <button class="fdb-tab {activeTab === 'craft' ? 'active' : ''}" onclick={() => switchTab('craft')}>Craft {#if countCraft > 0}({countCraft}){/if}</button>
        <button class="fdb-tab {activeTab === 'npc' ? 'active' : ''}" onclick={() => switchTab('npc')}>NPCs {#if countNpc > 0}({countNpc}){/if}</button>
        <button class="fdb-tab {activeTab === 'admin_panel' ? 'active' : ''}" onclick={() => switchTab('admin_panel')}>Admin {#if countAdmin > 0}({countAdmin}){/if}</button>
    </div>

    <div class="fdb-form">
        <h3 class="fdb-tab-title">
            {#if activeTab === 'geral'} Configurações Gerais
            {:else if activeTab === 'registradora'} Registradoras
            {:else if activeTab === 'bau'} Baús de Estoque
            {:else if activeTab === 'craft'} Bancadas de Craft
            {:else if activeTab === 'npc'} NPCs Extras
            {:else if activeTab === 'admin_panel'} Pontos de Acesso Admin
            {/if}
        </h3>
        
        {#if activeTab === 'geral'}
            <div class="fdb-group">
                <label>ID da Loja</label>
                <Input id="store-id-ro" type="text" value={store.id} disabled={true} />
            </div>

            <div class="fdb-group">
                <label>Dono da Loja (Citizen ID)</label>
                <Input id="{store.id}-owner_id" type="text" bind:value={store.owner_id} />
            </div>

            <div class="fdb-group">
                <label>Nome da Loja</label>
                <Input id="{store.id}-label" type="text" bind:value={store.label} />
            </div>

            {#each fields as field}
                <div class="fdb-group">
                    <label>{field.name}</label>
                    {#if field.type === 'text'}
                        <Input id="{store.id}-{field.id}" type="text" bind:value={store.config[field.id]} />
                    {:else if field.type === 'number'}
                        <Input id="{store.id}-{field.id}" type="number" bind:value={store.config[field.id]} />
                    {:else if field.type === 'select'}
                        <div class="fdb-row">
                            <div style="flex: 1;">
                                <Select id="{store.id}-{field.id}" bind:value={store.config[field.id]} options={getOptionsForField(field.options)} />
                            </div>
                        </div>
                    {:else if field.type === 'checkbox'}
                        <label class="fdb-check">
                            <input type="checkbox" bind:checked={store.config[field.id]} /> Sim / Ativo
                        </label>
                    {/if}
                </div>
            {/each}
        {/if}

        {#if activeTab === 'registradora'}
            {#each store.stations.filter(s => s.type === 'registradora') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={registerModels} disabled={station.is_marker} /></div>
                        <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <label class="fdb-check"><input type="checkbox" bind:checked={station.is_marker} /> Somente Marcador (Invisível)</label>
                </div>
            {/each}
            {#if countReg === 0}
                <div class="fdb-empty-state">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><path d="M4 10h16"></path></svg>
                    <p>Nenhuma registradora adicionada.</p>
                </div>
            {/if}
            <button class="fdb-btn-outline" onclick={() => addStation('registradora')}>+ Adicionar Registradora</button>
        {/if}

        {#if activeTab === 'bau'}
            {#each store.stations.filter(s => s.type === 'bau') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={chestModels} disabled={station.is_marker} /></div>
                        <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <label class="fdb-check"><input type="checkbox" bind:checked={station.is_marker} /> Somente Marcador (Invisível)</label>
                </div>
            {/each}
            {#if countBau === 0}
                <div class="fdb-empty-state">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                    <p>Nenhum baú adicionado.</p>
                </div>
            {/if}
            <button class="fdb-btn-outline" onclick={() => addStation('bau')}>+ Adicionar Baú</button>
        {/if}

        {#if activeTab === 'craft'}
            {#each store.stations.filter(s => s.type === 'craft') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={craftModels} disabled={station.is_marker} /></div>
                        <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <label class="fdb-check"><input type="checkbox" bind:checked={station.is_marker} /> Somente Marcador (Invisível)</label>
                </div>
            {/each}
            {#if countCraft === 0}
                <div class="fdb-empty-state">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path></svg>
                    <p>Nenhuma bancada de craft adicionada.</p>
                </div>
            {/if}
            <button class="fdb-btn-outline" onclick={() => addStation('craft')}>+ Adicionar Bancada</button>
        {/if}

        {#if activeTab === 'npc'}
            {#each store.stations.filter(s => s.type === 'npc') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.npc_model} options={npcModels} /></div>
                        <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                </div>
            {/each}
            {#if countNpc === 0}
                <div class="fdb-empty-state">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="7" r="4"></circle><path d="M5.5 21v-2a4 4 0 0 1 4-4h5a4 4 0 0 1 4 4v2"></path></svg>
                    <p>Nenhum NPC extra adicionado.</p>
                </div>
            {/if}
            <button class="fdb-btn-outline" onclick={() => addStation('npc')}>+ Adicionar NPC</button>
        {/if}

        {#if activeTab === 'admin_panel'}
            {#each store.stations.filter(s => s.type === 'admin_panel') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <button class="fdb-btn-outline" style="flex: 1;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar Posição" : "Marcar Posição"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <div style="margin-top: 1vh; display: flex; flex-direction: column; gap: 0.5vh;">
                        <label style="font-size: 0.8rem; color: var(--fdb-text-secondary); text-transform: uppercase;">Módulos Ativos:</label>
                        <label class="fdb-check">
                            <input type="checkbox" checked={true} disabled /> Dashboard (Padrão)
                        </label>
                        <label class="fdb-check">
                            <input type="checkbox" checked={station.metadata?.modules?.includes('finances')} onchange={(e) => updateModule(station, 'finances', e.target.checked)} /> Financeiro
                        </label>
                        <label class="fdb-check">
                            <input type="checkbox" checked={station.metadata?.modules?.includes('prices')} onchange={(e) => updateModule(station, 'prices', e.target.checked)} /> Preços
                        </label>
                        <label class="fdb-check">
                            <input type="checkbox" checked={station.metadata?.modules?.includes('employees')} onchange={(e) => updateModule(station, 'employees', e.target.checked)} /> Funcionários
                        </label>
                    </div>
                </div>
            {/each}
            {#if countAdmin === 0}
                <div class="fdb-empty-state">
                    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                    <p>Nenhum ponto de admin configurado.</p>
                </div>
            {/if}
            <button class="fdb-btn-outline" onclick={() => addStation('admin_panel')}>+ Adicionar Painel Admin</button>
        {/if}
    </div>

    <div class="fdb-actions">
        <button class="fdb-btn-danger-outline" onclick={deleteStore}>Excluir Loja</button>
        <div class="fdb-row" style="width: auto;">
            <button class="fdb-btn-secondary" onclick={onClose}>Cancelar</button>
            <button class="fdb-btn-primary" onclick={saveConfig}>Salvar</button>
        </div>
    </div>
</Panel>

<style>
    /* Tabs System */
    .fdb-tabs-container {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        margin-bottom: 1vh;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        padding-bottom: 1vh;
    }

    .fdb-tab {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #999);
        font-family: var(--fdb-font-body, sans-serif);
        font-size: 0.9rem;
        font-weight: bold;
        text-transform: uppercase;
        padding: 0.5rem 1rem;
        cursor: pointer;
        transition: color 0.2s, border-bottom 0.2s;
        border-bottom: 2px solid transparent;
        border-radius: 4px 4px 0 0;
    }

    .fdb-tab:hover {
        color: var(--fdb-text-primary, #fff);
        background-color: rgba(255,255,255,0.02);
    }

    .fdb-tab.active {
        color: var(--fdb-accent-color, #ffaa00);
        border-bottom: 2px solid var(--fdb-accent-color, #ffaa00);
    }

    .fdb-tab-title {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-text-primary, #fff);
        font-size: 1.3rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin: 0 0 1.5vh 0;
        padding-bottom: 1vh;
        border-bottom: 1px solid var(--fdb-accent-color, #ffaa00);
    }

    .fdb-form {
        display: flex;
        flex-direction: column;
        gap: 1.5vh;
    }
    
    .fdb-group {
        display: flex;
        flex-direction: column;
        gap: 0.5vh;
    }

    .fdb-group label {
        font-family: var(--fdb-font-body, sans-serif);
        color: var(--fdb-text-secondary, #ccc);
        font-size: 0.85rem;
        font-weight: bold;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .fdb-row {
        display: flex;
        gap: 0.8vh;
        width: 100%;
    }

    .fdb-card {
        background-color: rgba(255,255,255,0.02);
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: var(--fdb-border-radius, 4px);
        padding: 1.5vh;
        display: flex;
        flex-direction: column;
        gap: 0.8vh;
        box-shadow: inset 0 1px 3px rgba(0,0,0,0.4);
    }

    .fdb-check {
        display: flex;
        align-items: center;
        gap: 0.5vh;
        font-size: 0.85rem;
        color: var(--fdb-text-secondary);
        cursor: pointer;
    }

    .fdb-empty-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 4vh;
        color: var(--fdb-text-muted, rgba(255,255,255,0.3));
        gap: 1.5vh;
        text-align: center;
        font-size: 0.95rem;
    }

    /* Buttons */
    button {
        font-family: var(--fdb-font-body, sans-serif);
        font-size: 0.9rem;
        font-weight: bold;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        transition: all 0.2s;
        border: none;
        padding: 1.2vh;
    }

    .fdb-btn-primary {
        background-color: var(--fdb-accent-color);
        color: white;
    }
    .fdb-btn-primary:hover {
        background-color: var(--fdb-accent-color-dark);
    }

    .fdb-btn-danger {
        background-color: rgba(200, 50, 50, 0.2);
        color: rgb(220, 80, 80);
        border: 1px solid rgba(200, 50, 50, 0.4);
    }
    .fdb-btn-danger:hover {
        background-color: rgba(200, 50, 50, 0.4);
    }

    .fdb-btn-danger-outline {
        background-color: transparent;
        color: rgb(220, 80, 80);
        border: 1px solid rgba(200, 50, 50, 0.4);
    }
    .fdb-btn-danger-outline:hover {
        background-color: rgba(200, 50, 50, 0.15);
    }

    .fdb-btn-outline {
        background-color: transparent;
        border: 1px dashed rgba(255, 255, 255, 0.2);
        color: var(--fdb-text-secondary);
        padding: 1vh;
    }
    .fdb-btn-outline:hover {
        border-color: rgba(255, 255, 255, 0.4);
        color: white;
        background-color: rgba(255,255,255,0.05);
    }

    .fdb-btn-secondary {
        background-color: rgba(255, 255, 255, 0.1);
        color: white;
    }
    .fdb-btn-secondary:hover {
        background-color: rgba(255, 255, 255, 0.2);
    }

    .fdb-actions {
        display: flex;
        justify-content: space-between;
        margin-top: 1vh;
        padding-top: 1.5vh;
        border-top: 1px solid rgba(255,255,255,0.1);
    }
</style>
