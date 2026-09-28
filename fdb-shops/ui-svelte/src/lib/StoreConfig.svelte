<script>
    import { onMount } from 'svelte';
    import Select from '../../../../fdb-libs/ui/src/components/Select.svelte';
    import Input from '../../../../fdb-libs/ui/src/components/Input.svelte';
    
    let { store, templates = [], onClose, onDeleted = () => {} } = $props();

    // Local reactive state for full Svelte 5 runes reactivity
    let storeId = $state(store.id || '');
    let storeLabel = $state(store.label || '');
    let initialTemplate = store.template || 'normal';
    let storeTemplate = $state(store.template || 'normal');
    let templateModalOpen = $state(false);
    let storeCity = $state(store.city || 'outros');
    let storeOwnerId = $state(store.owner_id || '');
    let storeConfig = $state(store.config ? JSON.parse(JSON.stringify(store.config)) : {});
    let stations = $state(store.stations ? JSON.parse(JSON.stringify(store.stations)) : []);

    const cityOptions = [
        { value: 'valentine', label: 'Valentine' },
        { value: 'saint_denis', label: 'Saint Denis' },
        { value: 'rhodes', label: 'Rhodes' },
        { value: 'blackwater', label: 'Blackwater' },
        { value: 'annesburg', label: 'Annesburg' },
        { value: 'armadillo', label: 'Armadillo' },
        { value: 'tumbleweed', label: 'Tumbleweed' },
        { value: 'van_horn', label: 'Van Horn' },
        { value: 'strawberry', label: 'Strawberry' },
        { value: 'outros', label: 'Outros' }
    ];

    let templateOptions = $derived(
        templates && templates.length > 0
            ? templates
            : [
                { value: 'normal', label: 'Armazém Geral (normal)' },
                { value: 'weapons', label: 'Armeiro (weapons)' },
                { value: 'saloon', label: 'Saloon (saloon)' },
                { value: 'armoury', label: 'Arsenal Policial (armoury)' },
                { value: 'medic', label: 'Farmácia (medic)' },
                { value: 'prison', label: 'Cantina Prisional (prison)' }
            ]
    );

    let activeTab = $state('geral');
    
    function switchTab(tab) {
        activeTab = tab;
    }
    
    let countReg = $derived(stations.filter(s => s.type === 'registradora').length);
    let countBau = $derived(stations.filter(s => s.type === 'bau').length);
    let countCraft = $derived(stations.filter(s => s.type === 'craft').length);
    let countNpc = $derived(stations.filter(s => s.type === 'npc').length);
    let countAdmin = $derived(stations.filter(s => s.type === 'admin_panel').length);

    const templateConfig = {
        normal: [
            { id: 'stock_limit', name: 'Limite de Estoque', type: 'number' }
        ],
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

    let fields = $derived(templateConfig[storeTemplate] || templateConfig.default);

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

    onMount(() => {
        const handleMsg = (event) => {
            const data = event.data;
            if (data.action === 'placementResult') {
                const st = stations.find(s => s.id === data.stationId);
                if (st) {
                    st.position = data.result;
                    st.heading = data.result.h;
                    stations = [...stations];
                }
            } else if (data.action === 'updateStationId') {
                const st = stations.find(s => s.id === data.oldId);
                if (st) {
                    st.id = data.newId;
                    stations = [...stations];
                }
            }
        };

        window.addEventListener('message', handleMsg);
        return () => window.removeEventListener('message', handleMsg);
    });

    function addStation(type) {
        const tempId = 'temp-' + Date.now() + '-' + Math.floor(Math.random() * 1000000);
        let defaultModel = '';
        if (type === 'npc') defaultModel = npcModels[0];
        if (type === 'registradora') defaultModel = registerModels[0];
        if (type === 'bau') defaultModel = chestModels[0];
        if (type === 'craft') defaultModel = craftModels[0];

        stations = [...stations, {
            id: tempId,
            type: type,
            npc_model: type === 'npc' ? defaultModel : undefined,
            prop_model: type !== 'npc' && type !== 'admin_panel' ? defaultModel : undefined,
            position: null,
            heading: 0,
            is_marker: false
        }];
        store.stations = stations;
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
                type: station.type, model: model, shopId: storeId, stationId: station.id, mode: mode
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
        stations = [...stations];
    }

    async function removeComponent(station) {
        if (typeof station.id === 'string' && station.id.startsWith('temp-')) {
            stations = stations.filter(s => s.id !== station.id);
            store.stations = stations;
            return;
        }

        let res = await fetch(`https://${window.GetParentResourceName()}/requestRemoval`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: station.type, shopId: storeId, stationId: station.id })
        });
        
        let confirmed = await res.json();
        if (confirmed) {
            stations = stations.filter(s => s.id !== station.id);
            store.stations = stations;
        }
    }

    async function deleteStore() {
        let res = await fetch(`https://${window.GetParentResourceName()}/deleteStore`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ shopId: storeId, label: storeLabel || storeId })
        });
        
        let confirmed = await res.json();
        if (confirmed) onDeleted(storeId);
    }

    function saveConfig(confirmed = false) {
        if (storeTemplate !== initialTemplate && !confirmed) {
            templateModalOpen = true;
            return;
        }
        templateModalOpen = false;
        const payload = {
            id: storeId,
            label: storeLabel,
            template: storeTemplate,
            city: storeCity,
            owner_id: storeOwnerId,
            config: storeConfig,
            stations: stations
        };
        Object.assign(store, payload);

        fetch(`https://${window.GetParentResourceName()}/saveStoreConfig`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ store: payload })
        }).then(() => onClose());
    }

    function flipHeading(station) {
        station.heading = Math.round(((station.heading || 0) + 180) % 360);
        stations = [...stations];
        if (station.position) {
            fetch(`https://${window.GetParentResourceName()}/flipStationHeading`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: storeId,
                    stationId: station.id,
                    type: station.type,
                    model: station.type === 'npc' ? station.npc_model : station.prop_model,
                    coords: station.position,
                    heading: station.heading
                })
            }).catch(() => {});
        }
    }
</script>

<div class="fdb-panel-card">
    <div class="fdb-panel-background"></div>
    <div class="fdb-panel-border-overlay"></div>

    <div class="fdb-panel-top-nav">
        <button class="fdb-btn-back" onclick={onClose} type="button">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
                <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
            </svg>
            Voltar para Lista
        </button>
    </div>

    <div class="fdb-panel-header">
        <h2 class="fdb-panel-title">{storeLabel || storeId}</h2>
        <div class="fdb-panel-divider"></div>
        {#if storeId}
            <p class="fdb-panel-subtitle">ID: {storeId}</p>
        {/if}
    </div>

    <div class="fdb-panel-tabs fdb-tabs-container">
        <button class="fdb-tab {activeTab === 'geral' ? 'active' : ''}" onclick={() => switchTab('geral')}>Geral</button>
        <button class="fdb-tab {activeTab === 'registradora' ? 'active' : ''}" onclick={() => switchTab('registradora')}>Registradoras {#if countReg > 0}({countReg}){/if}</button>
        <button class="fdb-tab {activeTab === 'bau' ? 'active' : ''}" onclick={() => switchTab('bau')}>Baús {#if countBau > 0}({countBau}){/if}</button>
        <button class="fdb-tab {activeTab === 'craft' ? 'active' : ''}" onclick={() => switchTab('craft')}>Craft {#if countCraft > 0}({countCraft}){/if}</button>
        <button class="fdb-tab {activeTab === 'npc' ? 'active' : ''}" onclick={() => switchTab('npc')}>NPCs {#if countNpc > 0}({countNpc}){/if}</button>
        <button class="fdb-tab {activeTab === 'admin_panel' ? 'active' : ''}" onclick={() => switchTab('admin_panel')}>Admin {#if countAdmin > 0}({countAdmin}){/if}</button>
    </div>

    <div class="fdb-panel-content">
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
                    <Input id="store-id-input" type="text" bind:value={storeId} disabled={true} />
                    <span class="fdb-field-hint">O identificador da loja não pode ser alterado após a criação.</span>
                </div>

                <div class="fdb-group">
                    <label>Nome da Loja</label>
                    <Input id="store-label-input" type="text" bind:value={storeLabel} />
                </div>

                <div class="fdb-group">
                    <label>Categoria / Template</label>
                    <Select id="store-template-select" bind:value={storeTemplate} options={templateOptions} />
                    {#if storeTemplate !== initialTemplate}
                        <span class="fdb-field-hint" style="color: #f59e0b;">
                            ⚠️ Atenção: Ao salvar com um novo template, os catálogos de itens e receitas serão resetados para o padrão.
                        </span>
                    {/if}
                </div>

                <div class="fdb-group">
                    <label>Cidade / Localidade</label>
                    <Select id="store-city-select" bind:value={storeCity} options={cityOptions} />
                </div>

                <div class="fdb-group">
                    <label>Dono da Loja (Citizen ID)</label>
                    <Input id="store-owner-input" type="text" bind:value={storeOwnerId} />
                </div>

                {#each fields as field}
                    <div class="fdb-group">
                        <label>{field.name}</label>
                        {#if field.type === 'text'}
                            <Input id="field-{field.id}" type="text" bind:value={storeConfig[field.id]} />
                        {:else if field.type === 'number'}
                            <Input id="field-{field.id}" type="number" bind:value={storeConfig[field.id]} />
                        {:else if field.type === 'select'}
                            <div class="fdb-row">
                                <div style="flex: 1;">
                                    <Select id="field-{field.id}" bind:value={storeConfig[field.id]} options={getOptionsForField(field.options)} />
                                </div>
                            </div>
                        {:else if field.type === 'checkbox'}
                            <label class="fdb-check">
                                <input type="checkbox" bind:checked={storeConfig[field.id]} /> Sim / Ativo
                            </label>
                        {/if}
                    </div>
                {/each}
            {/if}

            {#if activeTab === 'registradora'}
                {#each stations.filter(s => s.type === 'registradora') as station (station.id)}
                    <div class="fdb-card">
                        <div class="fdb-row">
                            <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={registerModels} disabled={station.is_marker} /></div>
                            <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                            {#if station.position}
                                <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => flipHeading(station)} title="Girar 180°">🔄 180°</button>
                            {/if}
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
                {#each stations.filter(s => s.type === 'bau') as station (station.id)}
                    <div class="fdb-card">
                        <div class="fdb-row">
                            <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={chestModels} disabled={station.is_marker} /></div>
                            <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                            {#if station.position}
                                <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => flipHeading(station)} title="Girar 180°">🔄 180°</button>
                            {/if}
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
                {#each stations.filter(s => s.type === 'craft') as station (station.id)}
                    <div class="fdb-card">
                        <div class="fdb-row">
                            <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.prop_model} options={craftModels} disabled={station.is_marker} /></div>
                            <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                            {#if station.position}
                                <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => flipHeading(station)} title="Girar 180°">🔄 180°</button>
                            {/if}
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
                {#each stations.filter(s => s.type === 'npc') as station (station.id)}
                    <div class="fdb-card">
                        <div class="fdb-row">
                            <div style="flex: 1;"><Select id="m-{station.id}" bind:value={station.npc_model} options={npcModels} /></div>
                            <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => placeComponent(station)}>{station.position ? "Ajustar" : "Posicionar"}</button>
                            {#if station.position}
                                <button class="fdb-btn-outline" style="padding: 0 1vh;" onclick={() => flipHeading(station)} title="Girar 180°">🔄 180°</button>
                            {/if}
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
                {#each stations.filter(s => s.type === 'admin_panel') as station (station.id)}
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
                <button class="fdb-btn-primary" onclick={() => saveConfig(false)}>Salvar</button>
            </div>
        </div>
    </div>

    {#if templateModalOpen}
        <div class="fdb-modal-backdrop">
            <div class="fdb-modal-card">
                <h4 style="color: #f59e0b; margin: 0 0 1.2vh 0; font-size: 1.15rem; display: flex; align-items: center; gap: 0.5rem;">
                    ⚠️ Confirmar Troca de Template
                </h4>
                <p style="color: var(--fdb-text-primary); font-size: 0.95rem; line-height: 1.5; margin: 0 0 2vh 0;">
                    Você está alterando o template de <strong>{initialTemplate}</strong> para <strong>{storeTemplate}</strong>.<br/><br/>
                    Esta alteração irá <strong>redefinir os catálogos de itens e receitas</strong> para os padrões do novo template. As customizações manuais do dono serão redefinidas.<br/><br/>
                    Deseja prosseguir e salvar?
                </p>
                <div style="display: flex; justify-content: flex-end; gap: 1vh;">
                    <button type="button" class="fdb-btn-secondary" onclick={() => templateModalOpen = false}>Cancelar</button>
                    <button type="button" class="fdb-btn-primary" style="background: #d97706; border-color: #f59e0b;" onclick={() => saveConfig(true)}>Sim, Redefinir e Salvar</button>
                </div>
            </div>
        </div>
    {/if}
</div>

<style>
    .fdb-panel-top-nav {
        display: flex;
        align-items: center;
        margin-bottom: -1vh;
    }

    .fdb-btn-back {
        display: inline-flex;
        align-items: center;
        gap: 0.8vh;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.15);
        color: var(--fdb-text-secondary, #ccc);
        font-family: inherit;
        font-size: 0.85rem;
        padding: 0.7vh 1.4vh;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .fdb-btn-back:hover {
        background: rgba(220, 170, 100, 0.15);
        border-color: var(--fdb-accent-color, #dcaa64);
        color: var(--fdb-text-primary, #fff);
        transform: translateX(-2px);
    }

    /* Panel System */
    .fdb-panel-card {
        position: relative;
        background-color: var(--fdb-background-color, #1a1a1a);
        border: 1px solid var(--fdb-border-color, #444);
        padding: 3.5vh;
        box-shadow: 0 10px 30px rgba(0,0,0,0.6);
        display: flex;
        flex-direction: column;
        gap: 2.5vh;
        overflow: hidden;
        z-index: 1;
        max-height: 90vh;
        width: clamp(320px, 65vw, 800px);
    }

    .fdb-panel-background {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-image: var(--fdb-bg-image-menu, none);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        z-index: -1;
        opacity: 0.95;
    }

    .fdb-panel-border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--fdb-accent-color, #ffaa00);
        pointer-events: none;
        z-index: 2;
    }

    .fdb-panel-header {
        display: flex;
        flex-direction: column;
    }

    .fdb-panel-title {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-text-primary, #fff);
        font-size: 1.5rem;
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 1px;
        text-align: center;
    }

    .fdb-panel-divider {
        height: 1px;
        background-color: rgba(255, 255, 255, 0.15);
        margin-top: 1.5vh;
    }

    .fdb-panel-subtitle {
        color: var(--fdb-text-secondary, #ccc);
        margin: 0.5vh 0 0 0;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        text-align: center;
    }

    .fdb-panel-content {
        display: flex;
        flex-direction: column;
        gap: 2.7vh;
        max-height: 70vh;
        overflow-y: auto;
        padding-right: 1vh;
    }

    .fdb-panel-content::-webkit-scrollbar {
        width: 4px;
    }
    .fdb-panel-content::-webkit-scrollbar-thumb {
        background-color: rgba(255, 255, 255, 0.2);
        border-radius: 2px;
    }

    /* Tabs System */
    .fdb-tabs-container {
        display: flex;
        border-bottom: 1px solid var(--fdb-border-color, #444);
        gap: 1vh;
    }

    .fdb-tab {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #ccc);
        padding: 1vh 1.5vh;
        font-size: 0.9rem;
        font-weight: bold;
        text-transform: uppercase;
        cursor: pointer;
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

    .fdb-field-hint {
        font-size: 0.72rem;
        color: var(--fdb-text-secondary, #aaa);
        opacity: 0.75;
        margin-top: 0.2vh;
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

    .fdb-modal-backdrop {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.75);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 999;
        padding: 2vh;
    }

    .fdb-modal-card {
        background: #1e1e1e;
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: var(--fdb-border-radius, 6px);
        padding: 2.5vh;
        max-width: 480px;
        width: 100%;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.8);
    }
</style>
