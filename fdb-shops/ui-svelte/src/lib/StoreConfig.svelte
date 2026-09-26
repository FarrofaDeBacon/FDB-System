<script>
    import Select from '../../../../fdb-libs/ui/src/components/Select.svelte';
    import Input from '../../../../fdb-libs/ui/src/components/Input.svelte';
    import Panel from '../../../../fdb-libs/ui/src/components/Panel.svelte';
    
    let { store, onClose, onDeleted = () => {} } = $props();

    if (!store.stations) store.stations = [];
    if (!store.config) store.config = {};

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

<Panel title={store.label || store.id} id={store.id} width="450px">
    <div class="fdb-form">
        
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

        {#if fields.length > 0}
            <div class="fdb-divider"></div>
            <h4 class="fdb-subtitle">Configurações Gerais da Loja</h4>
        {/if}

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

        <div class="fdb-divider"></div>
        <h4 class="fdb-subtitle">Componentes da Loja</h4>
        
        <!-- Registradoras -->
        <div class="fdb-group">
            <label>Registradoras</label>
            {#each store.stations.filter(s => s.type === 'registradora') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={registerModels} disabled={station.is_marker} /></div>
                        <button class="fdb-btn-primary" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <label class="fdb-check"><input type="checkbox" bind:checked={station.is_marker} /> Somente Marcador (Invisível)</label>
                </div>
            {/each}
            <button class="fdb-btn-outline" onclick={() => addStation('registradora')}>+ Adicionar Registradora</button>
        </div>

        <!-- Baús -->
        <div class="fdb-group">
            <label>Baús de Estoque</label>
            {#each store.stations.filter(s => s.type === 'bau') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={chestModels} disabled={station.is_marker} /></div>
                        <button class="fdb-btn-primary" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <label class="fdb-check"><input type="checkbox" bind:checked={station.is_marker} /> Somente Marcador (Invisível)</label>
                </div>
            {/each}
            <button class="fdb-btn-outline" onclick={() => addStation('bau')}>+ Adicionar Baú</button>
        </div>

        <!-- Craft -->
        <div class="fdb-group">
            <label>Bancadas de Craft</label>
            {#each store.stations.filter(s => s.type === 'craft') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={craftModels} disabled={station.is_marker} /></div>
                        <button class="fdb-btn-primary" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                        <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                    </div>
                    <label class="fdb-check"><input type="checkbox" bind:checked={station.is_marker} /> Somente Marcador (Invisível)</label>
                </div>
            {/each}
            <button class="fdb-btn-outline" onclick={() => addStation('craft')}>+ Adicionar Bancada</button>
        </div>

        <!-- NPCs Extras -->
        <div class="fdb-group">
            <label>NPCs Extras</label>
            {#each store.stations.filter(s => s.type === 'npc') as station (station.id)}
                <div class="fdb-row">
                    <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.npc_model} options={npcModels} /></div>
                    <button class="fdb-btn-primary" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                    <button class="fdb-btn-danger" style="padding: 0 1vh;" onclick={() => removeComponent(station)}>X</button>
                </div>
            {/each}
            <button class="fdb-btn-outline" onclick={() => addStation('npc')}>+ Adicionar NPC</button>
        </div>

        <!-- Admin -->
        <div class="fdb-group">
            <label>Pontos de Acesso Admin</label>
            <p style="font-size: 0.8rem; color: var(--fdb-text-secondary); margin: 0;">Onde o dono acessa o painel da loja.</p>
            {#each store.stations.filter(s => s.type === 'admin_panel') as station (station.id)}
                <div class="fdb-card">
                    <div class="fdb-row">
                        <button class="fdb-btn-primary" style="flex: 1;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar Posição" : "Marcar Posição"}</button>
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
            <button class="fdb-btn-outline" onclick={() => addStation('admin_panel')}>+ Adicionar Painel Admin</button>
        </div>

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
        background-color: rgba(255,255,255,0.03);
        border: 1px solid rgba(255,255,255,0.05);
        border-radius: var(--fdb-border-radius, 4px);
        padding: 1vh;
        display: flex;
        flex-direction: column;
        gap: 0.8vh;
    }

    .fdb-check {
        display: flex;
        align-items: center;
        gap: 0.5vh;
        font-size: 0.85rem;
        color: var(--fdb-text-secondary);
        cursor: pointer;
    }

    .fdb-divider {
        height: 1px;
        background-color: rgba(255, 255, 255, 0.1);
        margin: 1vh 0;
    }

    .fdb-subtitle {
        margin: 0;
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-text-primary, #fff);
        font-size: 1.1rem;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    /* Botoes usando VH do fdb-libs */
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
