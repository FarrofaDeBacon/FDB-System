<script>
    let { 
        stores = [], 
        searchQuery = $bindable(''), 
        filterCity = $bindable('all'), 
        filterTemplate = $bindable('all'), 
        filterOwner = $bindable('all'), 
        onSelectStore = () => {}, 
        onCreateStore = () => {}, 
        onClose = () => {} 
    } = $props();

    const cityLabels = {
        'valentine': 'Valentine',
        'saint_denis': 'Saint Denis',
        'rhodes': 'Rhodes',
        'blackwater': 'Blackwater',
        'annesburg': 'Annesburg',
        'armadillo': 'Armadillo',
        'tumbleweed': 'Tumbleweed',
        'van_horn': 'Van Horn',
        'strawberry': 'Strawberry',
        'outros': 'Outros'
    };

    const templateLabels = {
        'normal': 'Armazém Geral',
        'weapons': 'Armeiro',
        'saloon': 'Saloon',
        'armoury': 'Arsenal Policial',
        'medic': 'Farmácia',
        'prison': 'Cantina Prisional',
        'general': 'Armazém Geral'
    };

    function formatCity(c) {
        return cityLabels[c] || c || 'Outros';
    }

    function formatTemplate(t) {
        return templateLabels[t] || t || 'Geral';
    }

    function formatStations(stations) {
        if (!stations || stations.length === 0) return 'Nenhum componente';
        const reg = stations.filter(s => s.type === 'registradora').length;
        const bau = stations.filter(s => s.type === 'bau').length;
        const craft = stations.filter(s => s.type === 'craft').length;
        const npc = stations.filter(s => s.type === 'npc').length;

        const parts = [];
        if (reg > 0) parts.push(`${reg} Caixa${reg > 1 ? 's' : ''}`);
        if (bau > 0) parts.push(`${bau} Baú${bau > 1 ? 's' : ''}`);
        if (craft > 0) parts.push(`${craft} Craft`);
        if (npc > 0) parts.push(`${npc} NPC${npc > 1 ? 's' : ''}`);

        return parts.length > 0 ? parts.join(' • ') : `${stations.length} comp.`;
    }

    function resetFilters() {
        searchQuery = '';
        filterCity = 'all';
        filterTemplate = 'all';
        filterOwner = 'all';
    }

    let filteredStores = $derived(
        stores.filter(store => {
            // Text search
            if (searchQuery.trim() !== '') {
                const q = searchQuery.toLowerCase().trim();
                const matchLabel = (store.label || '').toLowerCase().includes(q);
                const matchId = (store.id || '').toLowerCase().includes(q);
                const matchOwner = (store.owner_id || '').toLowerCase().includes(q);
                if (!matchLabel && !matchId && !matchOwner) return false;
            }

            // City filter
            if (filterCity !== 'all') {
                const storeCity = store.city || 'outros';
                if (storeCity !== filterCity) return false;
            }

            // Category / Template filter
            if (filterTemplate !== 'all') {
                const storeTpl = store.template || 'normal';
                if (storeTpl !== filterTemplate) return false;
            }

            // Owner filter
            if (filterOwner === 'owned') {
                if (!store.owner_id || store.owner_id === '') return false;
            } else if (filterOwner === 'unowned') {
                if (store.owner_id && store.owner_id !== '') return false;
            }

            return true;
        })
    );
</script>

<div class="fdb-table-panel">
    <div class="fdb-panel-background"></div>
    <div class="fdb-panel-border-overlay"></div>

    <!-- Header -->
    <div class="fdb-table-header">
        <div class="fdb-header-left">
            <h2 class="fdb-table-title">Gerenciador de Lojas</h2>
            <span class="fdb-table-count">{filteredStores.length} de {stores.length} lojas</span>
        </div>
        <button class="fdb-btn-close" onclick={onClose} title="Fechar (ESC)">✕</button>
    </div>

    <!-- Control Bar: Search + Filters + Create Button -->
    <div class="fdb-control-bar">
        <div class="fdb-search-box">
            <svg class="search-icon" viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
                <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
            </svg>
            <input 
                type="text" 
                placeholder="Buscar por nome, ID ou dono..." 
                bind:value={searchQuery}
                class="fdb-search-input"
            />
            {#if searchQuery}
                <button class="search-clear" onclick={() => searchQuery = ''}>✕</button>
            {/if}
        </div>

        <div class="fdb-filters-group">
            <!-- City Filter -->
            <select bind:value={filterCity} class="fdb-filter-select">
                <option value="all">📍 Todas as Cidades</option>
                <option value="valentine">Valentine</option>
                <option value="saint_denis">Saint Denis</option>
                <option value="rhodes">Rhodes</option>
                <option value="blackwater">Blackwater</option>
                <option value="annesburg">Annesburg</option>
                <option value="armadillo">Armadillo</option>
                <option value="tumbleweed">Tumbleweed</option>
                <option value="van_horn">Van Horn</option>
                <option value="strawberry">Strawberry</option>
                <option value="outros">Outros</option>
            </select>

            <!-- Template Filter -->
            <select bind:value={filterTemplate} class="fdb-filter-select">
                <option value="all">🏷️ Todas as Categorias</option>
                <option value="normal">Armazém Geral</option>
                <option value="weapons">Armeiro</option>
                <option value="saloon">Saloon</option>
                <option value="armoury">Arsenal Policial</option>
                <option value="medic">Farmácia</option>
                <option value="prison">Cantina Prisional</option>
            </select>

            <!-- Owner Filter -->
            <select bind:value={filterOwner} class="fdb-filter-select">
                <option value="all">👤 Todos os Donos</option>
                <option value="owned">Com Dono (Privada)</option>
                <option value="unowned">Sem Dono (Prefeitura)</option>
            </select>
        </div>

        <button class="fdb-btn-create" onclick={onCreateStore}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            Nova Loja
        </button>
    </div>

    <!-- Data Table Container -->
    <div class="fdb-table-scroll">
        <table class="fdb-data-table">
            <thead>
                <tr>
                    <th style="width: 28%;">Loja & Identificador</th>
                    <th style="width: 15%;">Cidade</th>
                    <th style="width: 16%;">Categoria</th>
                    <th style="width: 15%;">Dono</th>
                    <th style="width: 16%;">Componentes</th>
                    <th style="width: 10%; text-align: center;">Ação</th>
                </tr>
            </thead>
            <tbody>
                {#each filteredStores as store (store.id)}
                    <tr class="fdb-table-row" onclick={() => onSelectStore(store)}>
                        <td class="cell-store">
                            <span class="store-name">{store.label || store.id}</span>
                            <span class="store-id">{store.id}</span>
                        </td>
                        <td class="cell-city">
                            <span class="city-badge">📍 {formatCity(store.city)}</span>
                        </td>
                        <td class="cell-template">
                            <span class="template-badge" data-template={store.template || 'normal'}>
                                {formatTemplate(store.template)}
                            </span>
                        </td>
                        <td class="cell-owner">
                            {#if store.owner_id && store.owner_id !== ''}
                                <span class="owner-pill owned" title="Citizen ID: {store.owner_id}">
                                    👤 {store.owner_id}
                                </span>
                            {:else}
                                <span class="owner-pill unowned">
                                    🏛️ Sem Dono
                                </span>
                            {/if}
                        </td>
                        <td class="cell-stations">
                            <span class="stations-text">{formatStations(store.stations)}</span>
                        </td>
                        <td class="cell-action" style="text-align: center;">
                            <button 
                                class="fdb-btn-row-edit" 
                                onclick={(e) => { e.stopPropagation(); onSelectStore(store); }}
                            >
                                Editar
                            </button>
                        </td>
                    </tr>
                {/each}

                {#if filteredStores.length === 0}
                    <tr>
                        <td colspan="6" class="fdb-table-empty">
                            <div class="empty-wrap">
                                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                                    <polyline points="9 22 9 12 15 12 15 22"></polyline>
                                </svg>
                                <p>Nenhuma loja encontrada para os filtros selecionados.</p>
                                <button class="fdb-btn-reset-filters" onclick={resetFilters}>Limpar Filtros</button>
                            </div>
                        </td>
                    </tr>
                {/if}
            </tbody>
        </table>
    </div>
</div>

<style>
    .fdb-table-panel {
        position: relative;
        background-color: var(--fdb-background-color, #141210);
        border: 1px solid var(--fdb-border-color, #383028);
        padding: 3vh 3.5vh;
        box-shadow: 0 12px 35px rgba(0, 0, 0, 0.7);
        display: flex;
        flex-direction: column;
        gap: 2vh;
        overflow: hidden;
        z-index: 1;
        width: clamp(800px, 85vw, 1150px);
        max-height: 85vh;
        box-sizing: border-box;
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
        top: 0; 
        left: 0; 
        width: 100%; 
        height: 100%;
        border-left: 4px solid var(--fdb-accent-color, #dcaa64);
        pointer-events: none;
        z-index: 2;
    }

    /* Header */
    .fdb-table-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding-bottom: 1.5vh;
        border-bottom: 1px solid rgba(255, 255, 255, 0.12);
    }

    .fdb-header-left {
        display: flex;
        align-items: baseline;
        gap: 1.5vh;
    }

    .fdb-table-title {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-text-primary, #fff);
        font-size: 1.5rem;
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 1.5px;
    }

    .fdb-table-count {
        font-size: 0.85rem;
        color: var(--fdb-accent-color, #dcaa64);
        background: rgba(220, 170, 100, 0.1);
        padding: 0.3vh 1vh;
        border-radius: 12px;
        border: 1px solid rgba(220, 170, 100, 0.25);
    }

    .fdb-btn-close {
        background: transparent;
        border: 1px solid rgba(255, 255, 255, 0.15);
        color: var(--fdb-text-secondary, #aaa);
        font-size: 1rem;
        width: 32px;
        height: 32px;
        border-radius: 4px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s;
    }

    .fdb-btn-close:hover {
        background: rgba(220, 60, 60, 0.25);
        border-color: #dc3545;
        color: #fff;
    }

    /* Control Bar */
    .fdb-control-bar {
        display: flex;
        align-items: center;
        gap: 1.2vh;
        flex-wrap: wrap;
    }

    .fdb-search-box {
        position: relative;
        flex: 1;
        min-width: 220px;
        display: flex;
        align-items: center;
    }

    .search-icon {
        position: absolute;
        left: 10px;
        color: rgba(255, 255, 255, 0.4);
        pointer-events: none;
    }

    .fdb-search-input {
        width: 100%;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: var(--fdb-border-radius, 4px);
        padding: 0.9vh 30px 0.9vh 34px;
        color: var(--fdb-text-primary, #fff);
        font-size: 0.85rem;
        font-family: inherit;
        outline: none;
        transition: border-color 0.2s, background-color 0.2s;
        box-sizing: border-box;
    }

    .fdb-search-input:focus {
        border-color: var(--fdb-accent-color, #dcaa64);
        background: rgba(255, 255, 255, 0.08);
    }

    .search-clear {
        position: absolute;
        right: 8px;
        background: transparent;
        border: none;
        color: rgba(255, 255, 255, 0.4);
        cursor: pointer;
        font-size: 0.8rem;
    }

    .search-clear:hover {
        color: #fff;
    }

    .fdb-filters-group {
        display: flex;
        gap: 1vh;
        flex-wrap: wrap;
    }

    .fdb-filter-select {
        background: rgba(255, 255, 255, 0.06);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: var(--fdb-border-radius, 4px);
        color: var(--fdb-text-primary, #e0e0e0);
        padding: 0.9vh 1.2vh;
        font-size: 0.85rem;
        font-family: inherit;
        outline: none;
        cursor: pointer;
        transition: border-color 0.2s;
    }

    .fdb-filter-select option {
        background: #1a1614;
        color: #fff;
    }

    .fdb-filter-select:focus, .fdb-filter-select:hover {
        border-color: var(--fdb-accent-color, #dcaa64);
    }

    .fdb-btn-create {
        display: inline-flex;
        align-items: center;
        gap: 0.6vh;
        background: rgba(220, 170, 100, 0.15);
        border: 1px solid var(--fdb-accent-color, #dcaa64);
        color: var(--fdb-accent-color, #dcaa64);
        font-family: inherit;
        font-weight: 600;
        font-size: 0.85rem;
        padding: 0.9vh 1.6vh;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        transition: all 0.2s;
        white-space: nowrap;
    }

    .fdb-btn-create:hover {
        background: var(--fdb-accent-color, #dcaa64);
        color: #1a1410;
        box-shadow: 0 4px 12px rgba(220, 170, 100, 0.3);
    }

    /* Table Scroll & Structure */
    .fdb-table-scroll {
        overflow-y: auto;
        overflow-x: hidden;
        max-height: 56vh;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: var(--fdb-border-radius, 4px);
        background: rgba(0, 0, 0, 0.2);
    }

    .fdb-table-scroll::-webkit-scrollbar {
        width: 6px;
    }

    .fdb-table-scroll::-webkit-scrollbar-thumb {
        background: rgba(220, 170, 100, 0.3);
        border-radius: 3px;
    }

    .fdb-table-scroll::-webkit-scrollbar-thumb:hover {
        background: var(--fdb-accent-color, #dcaa64);
    }

    .fdb-data-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
        font-size: 0.88rem;
    }

    .fdb-data-table thead th {
        position: sticky;
        top: 0;
        background: #1e1a17;
        color: var(--fdb-accent-color, #dcaa64);
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        padding: 1.2vh 1.4vh;
        border-bottom: 2px solid rgba(220, 170, 100, 0.3);
        z-index: 3;
    }

    .fdb-table-row {
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        cursor: pointer;
        transition: background-color 0.15s ease;
    }

    .fdb-table-row:nth-child(even) {
        background-color: rgba(255, 255, 255, 0.015);
    }

    .fdb-table-row:hover {
        background-color: rgba(220, 170, 100, 0.08);
    }

    .fdb-data-table td {
        padding: 1.1vh 1.4vh;
        vertical-align: middle;
    }

    /* Cells */
    .cell-store {
        display: flex;
        flex-direction: column;
        gap: 0.2vh;
    }

    .store-name {
        color: var(--fdb-text-primary, #fff);
        font-weight: 600;
        font-size: 0.92rem;
    }

    .store-id {
        color: var(--fdb-text-secondary, #888);
        font-family: monospace;
        font-size: 0.75rem;
        opacity: 0.75;
    }

    .city-badge {
        font-size: 0.82rem;
        color: #d8c2aa;
        background: rgba(255, 255, 255, 0.04);
        padding: 0.3vh 0.8vh;
        border-radius: 4px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        white-space: nowrap;
    }

    .template-badge {
        display: inline-block;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 0.3vh 0.9vh;
        border-radius: 3px;
        white-space: nowrap;
    }

    .template-badge[data-template="saloon"] {
        color: #e5a752;
        background: rgba(229, 167, 82, 0.15);
        border: 1px solid rgba(229, 167, 82, 0.3);
    }

    .template-badge[data-template="weapons"] {
        color: #e56552;
        background: rgba(229, 101, 82, 0.15);
        border: 1px solid rgba(229, 101, 82, 0.3);
    }

    .template-badge[data-template="normal"],
    .template-badge[data-template="general"] {
        color: #62b6e5;
        background: rgba(98, 182, 229, 0.15);
        border: 1px solid rgba(98, 182, 229, 0.3);
    }

    .template-badge[data-template="armoury"] {
        color: #a8b8c8;
        background: rgba(168, 184, 200, 0.15);
        border: 1px solid rgba(168, 184, 200, 0.3);
    }

    .template-badge[data-template="medic"] {
        color: #62e59a;
        background: rgba(98, 229, 154, 0.15);
        border: 1px solid rgba(98, 229, 154, 0.3);
    }

    .template-badge[data-template="prison"] {
        color: #d182e5;
        background: rgba(209, 130, 229, 0.15);
        border: 1px solid rgba(209, 130, 229, 0.3);
    }

    .owner-pill {
        font-size: 0.8rem;
        white-space: nowrap;
    }

    .owner-pill.owned {
        color: #8be58b;
        font-family: monospace;
    }

    .owner-pill.unowned {
        color: rgba(255, 255, 255, 0.4);
        font-style: italic;
    }

    .stations-text {
        font-size: 0.8rem;
        color: var(--fdb-text-secondary, #aaa);
    }

    .fdb-btn-row-edit {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.15);
        color: var(--fdb-text-primary, #fff);
        padding: 0.5vh 1.2vh;
        border-radius: var(--fdb-border-radius, 4px);
        font-size: 0.8rem;
        cursor: pointer;
        transition: all 0.2s;
    }

    .fdb-btn-row-edit:hover {
        background: var(--fdb-accent-color, #dcaa64);
        border-color: var(--fdb-accent-color, #dcaa64);
        color: #1a1410;
        font-weight: 600;
    }

    /* Empty state */
    .fdb-table-empty {
        text-align: center;
        padding: 6vh 2vh;
    }

    .empty-wrap {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1.2vh;
        color: rgba(255, 255, 255, 0.4);
    }

    .empty-wrap p {
        margin: 0;
        font-size: 0.95rem;
    }

    .fdb-btn-reset-filters {
        background: rgba(220, 170, 100, 0.15);
        border: 1px solid var(--fdb-accent-color, #dcaa64);
        color: var(--fdb-accent-color, #dcaa64);
        padding: 0.6vh 1.4vh;
        border-radius: 4px;
        font-size: 0.82rem;
        cursor: pointer;
        transition: all 0.2s;
    }

    .fdb-btn-reset-filters:hover {
        background: var(--fdb-accent-color, #dcaa64);
        color: #1a1410;
    }
</style>
