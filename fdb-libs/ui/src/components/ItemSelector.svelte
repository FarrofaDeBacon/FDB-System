<script>
    import { createEventDispatcher } from 'svelte';

    export let title = 'Selecionar Itens do Registro';
    export let items = []; // Array of { name, label, image, description, type, weight }
    export let alreadySelected = []; // Array of string item names already in catalog
    export let multiSelect = true;
    export let onConfirm = () => {};
    export let onCancel = () => {};

    const dispatch = createEventDispatcher();

    let searchQuery = '';
    let selectedType = 'all';
    
    // Set of currently selected item names in this modal
    let localSelected = new Set();

    // Initialize with items that were not already selected or keep tracking
    $: itemTypes = ['all', ...Array.from(new Set(items.map(i => i.type || 'item'))).filter(Boolean)];

    $: filteredItems = items.filter(item => {
        const matchesType = selectedType === 'all' || item.type === selectedType;
        const q = searchQuery.trim().toLowerCase();
        const matchesSearch = !q || 
            (item.label && item.label.toLowerCase().includes(q)) || 
            (item.name && item.name.toLowerCase().includes(q));
        return matchesType && matchesSearch;
    });

    function toggleItem(item) {
        if (!multiSelect) {
            localSelected.clear();
            localSelected.add(item.name);
            localSelected = new Set(localSelected);
            return;
        }

        if (localSelected.has(item.name)) {
            localSelected.delete(item.name);
        } else {
            localSelected.add(item.name);
        }
        localSelected = new Set(localSelected);
    }

    function selectAllVisible() {
        filteredItems.forEach(item => {
            if (!alreadySelected.includes(item.name)) {
                localSelected.add(item.name);
            }
        });
        localSelected = new Set(localSelected);
    }

    function clearSelection() {
        localSelected.clear();
        localSelected = new Set(localSelected);
    }

    function confirm() {
        const chosenItems = items.filter(i => localSelected.has(i.name));
        if (onConfirm) onConfirm(chosenItems);
        dispatch('confirm', chosenItems);
    }

    function cancel() {
        if (onCancel) onCancel();
        dispatch('cancel');
    }

    function getItemImageUrl(item) {
        if (item.image) {
            // Standard path to fdb-inventory images or direct image string
            return `nui://fdb-inventory/html/images/${item.image}`;
        }
        return `nui://fdb-inventory/html/images/${item.name}.png`;
    }
</script>

<div class="item-selector-overlay" role="dialog" aria-modal="true">
    <div class="item-selector-card">
        <div class="card-background"></div>
        <div class="card-border-overlay"></div>

        <!-- Header -->
        <div class="card-header">
            <div class="header-left">
                <h2 class="card-title">{title}</h2>
                <span class="selection-count">
                    {localSelected.size} selecionado{localSelected.size === 1 ? '' : 's'}
                </span>
            </div>
            <button class="close-btn" onclick={cancel} type="button" title="Fechar">✕</button>
        </div>

        <div class="card-divider"></div>

        <!-- Search & Filter Controls -->
        <div class="controls-bar">
            <div class="search-box">
                <span class="search-icon">🔍</span>
                <input 
                    type="text" 
                    placeholder="Buscar por nome ou identificador..." 
                    bind:value={searchQuery}
                    class="search-input"
                />
                {#if searchQuery}
                    <button class="clear-search" onclick={() => searchQuery = ''} type="button">✕</button>
                {/if}
            </div>

            {#if itemTypes.length > 2}
                <div class="type-filter">
                    {#each itemTypes as type}
                        <button 
                            class="type-pill" 
                            class:active={selectedType === type}
                            onclick={() => selectedType = type}
                            type="button"
                        >
                            {type === 'all' ? 'Todos' : type.toUpperCase()}
                        </button>
                    {/each}
                </div>
            {/if}
        </div>

        <!-- Action hints / Bulk selectors -->
        <div class="batch-bar">
            <span class="results-text">
                Mostrando {filteredItems.length} {filteredItems.length === 1 ? 'item' : 'itens'}
            </span>
            <div class="batch-actions">
                {#if multiSelect && filteredItems.length > 0}
                    <button class="batch-btn" onclick={selectAllVisible} type="button">Selecionar Visíveis</button>
                {/if}
                {#if localSelected.size > 0}
                    <button class="batch-btn text-muted" onclick={clearSelection} type="button">Limpar Seleção</button>
                {/if}
            </div>
        </div>

        <!-- Items Grid -->
        <div class="items-grid-container">
            {#if filteredItems.length === 0}
                <div class="empty-state">
                    <p class="empty-title">Nenhum item encontrado</p>
                    <p class="empty-sub">Tente ajustar o termo da busca ou categoria.</p>
                </div>
            {:else}
                <div class="items-grid">
                    {#each filteredItems as item (item.name)}
                        {@const isSelected = localSelected.has(item.name)}
                        {@const isAlready = alreadySelected.includes(item.name)}
                        
                        <div 
                            class="item-card" 
                            class:selected={isSelected}
                            class:already-in-catalog={isAlready}
                            role="button"
                            tabindex="0"
                            onclick={() => { if (!isAlready) toggleItem(item); }}
                            onkeydown={(e) => { if (e.key === 'Enter' && !isAlready) toggleItem(item); }}
                        >
                            <div class="item-img-wrap">
                                <img 
                                    src={getItemImageUrl(item)} 
                                    alt={item.label}
                                    onerror={(e) => { e.currentTarget.style.display = 'none'; }}
                                    class="item-img"
                                />
                                <span class="item-fallback-icon">📦</span>
                            </div>

                            <div class="item-info">
                                <span class="item-label" title={item.label}>{item.label}</span>
                                <span class="item-tech-name">{item.name}</span>
                            </div>

                            {#if isAlready}
                                <span class="badge-already" title="Já adicionado ao catálogo desta loja">No Catálogo</span>
                            {:else if isSelected}
                                <span class="badge-check">✓</span>
                            {/if}
                        </div>
                    {/each}
                </div>
            {/if}
        </div>

        <div class="card-divider"></div>

        <!-- Footer -->
        <div class="card-footer">
            <button class="btn-cancel" onclick={cancel} type="button">Cancelar</button>
            <button 
                class="btn-confirm" 
                onclick={confirm} 
                disabled={localSelected.size === 0}
                type="button"
            >
                Adicionar ao Catálogo ({localSelected.size})
            </button>
        </div>
    </div>
</div>

<style>
    .item-selector-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(0, 0, 0, 0.78);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        font-family: var(--fdb-font-family, 'Outfit', 'Inter', sans-serif);
        user-select: none;
    }

    .item-selector-card {
        position: relative;
        width: 780px;
        max-width: 92vw;
        height: 82vh;
        max-height: 850px;
        background-color: var(--fdb-background-color, #1a1512);
        border: 1px solid var(--fdb-border-color, #4a3828);
        display: flex;
        flex-direction: column;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.85);
        overflow: hidden;
        border-radius: 4px;
    }

    .card-background {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: var(--fdb-bg-image-menu, none);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        opacity: 0.95;
        z-index: 0;
        pointer-events: none;
    }

    .card-border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--fdb-accent-color, #d4a373);
        pointer-events: none;
        z-index: 1;
    }

    .card-header {
        position: relative;
        z-index: 2;
        padding: 1.5rem 1.75rem 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .header-left {
        display: flex;
        align-items: baseline;
        gap: 1rem;
    }

    .card-title {
        font-size: 1.35rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
        margin: 0;
        letter-spacing: 0.05em;
        text-transform: uppercase;
    }

    .selection-count {
        font-size: 0.85rem;
        color: var(--fdb-accent-color, #d4a373);
        background: rgba(212, 163, 115, 0.12);
        padding: 0.2rem 0.6rem;
        border-radius: 12px;
        border: 1px solid rgba(212, 163, 115, 0.3);
    }

    .close-btn {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        font-size: 1.25rem;
        cursor: pointer;
        transition: color 0.15s ease;
        padding: 0.25rem 0.5rem;
    }

    .close-btn:hover {
        color: #ff6b6b;
    }

    .card-divider {
        position: relative;
        z-index: 2;
        height: 1px;
        background: linear-gradient(90deg, transparent, var(--fdb-border-color, #4a3828) 20%, var(--fdb-border-color, #4a3828) 80%, transparent);
        margin: 0;
    }

    .controls-bar {
        position: relative;
        z-index: 2;
        padding: 1rem 1.75rem 0.5rem;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
    }

    .search-box {
        position: relative;
        display: flex;
        align-items: center;
        background: rgba(0, 0, 0, 0.35);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0 0.75rem;
    }

    .search-icon {
        font-size: 0.9rem;
        opacity: 0.6;
        margin-right: 0.5rem;
    }

    .search-input {
        width: 100%;
        background: transparent;
        border: none;
        outline: none;
        color: var(--fdb-text-color, #f4ede4);
        padding: 0.6rem 0;
        font-size: 0.95rem;
    }

    .clear-search {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        cursor: pointer;
        padding: 0.2rem 0.4rem;
        font-size: 0.85rem;
    }

    .type-filter {
        display: flex;
        gap: 0.4rem;
        overflow-x: auto;
        padding-bottom: 0.25rem;
    }

    .type-pill {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: var(--fdb-text-secondary, #a89886);
        padding: 0.25rem 0.75rem;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .type-pill.active, .type-pill:hover {
        background: var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        border-color: var(--fdb-accent-color, #d4a373);
    }

    .batch-bar {
        position: relative;
        z-index: 2;
        padding: 0.4rem 1.75rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: rgba(0, 0, 0, 0.2);
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    .results-text {
        font-size: 0.8rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .batch-actions {
        display: flex;
        gap: 0.75rem;
    }

    .batch-btn {
        background: transparent;
        border: none;
        color: var(--fdb-accent-color, #d4a373);
        font-size: 0.8rem;
        font-weight: 600;
        cursor: pointer;
        text-decoration: underline;
        padding: 0;
    }

    .batch-btn.text-muted {
        color: var(--fdb-text-secondary, #a89886);
        text-decoration: none;
    }

    .batch-btn:hover {
        opacity: 0.8;
    }

    .items-grid-container {
        position: relative;
        z-index: 2;
        flex: 1;
        overflow-y: auto;
        padding: 1rem 1.75rem;
    }

    .items-grid-container::-webkit-scrollbar {
        width: 6px;
    }

    .items-grid-container::-webkit-scrollbar-thumb {
        background: var(--fdb-border-color, #4a3828);
        border-radius: 3px;
    }

    .items-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
        gap: 0.85rem;
    }

    .item-card {
        position: relative;
        background: rgba(0, 0, 0, 0.4);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0.75rem;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: 0.5rem;
        cursor: pointer;
        transition: all 0.18s ease;
    }

    .item-card:hover {
        background: rgba(212, 163, 115, 0.08);
        border-color: var(--fdb-accent-color, #d4a373);
        transform: translateY(-2px);
    }

    .item-card.selected {
        background: rgba(212, 163, 115, 0.15);
        border-color: var(--fdb-accent-color, #d4a373);
        box-shadow: 0 0 12px rgba(212, 163, 115, 0.25);
    }

    .item-card.already-in-catalog {
        opacity: 0.5;
        cursor: not-allowed;
        border-color: rgba(255, 255, 255, 0.1);
    }

    .item-card.already-in-catalog:hover {
        transform: none;
        background: rgba(0, 0, 0, 0.4);
        border-color: rgba(255, 255, 255, 0.1);
    }

    .item-img-wrap {
        position: relative;
        width: 52px;
        height: 52px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, 0.35);
        border-radius: 4px;
        border: 1px solid rgba(255, 255, 255, 0.05);
    }

    .item-img {
        max-width: 44px;
        max-height: 44px;
        object-fit: contain;
        position: relative;
        z-index: 2;
    }

    .item-fallback-icon {
        position: absolute;
        font-size: 1.5rem;
        opacity: 0.35;
        z-index: 1;
    }

    .item-info {
        display: flex;
        flex-direction: column;
        gap: 0.15rem;
        width: 100%;
        overflow: hidden;
    }

    .item-label {
        font-size: 0.85rem;
        font-weight: 600;
        color: var(--fdb-text-color, #f4ede4);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: block;
    }

    .item-tech-name {
        font-size: 0.7rem;
        color: var(--fdb-text-secondary, #a89886);
        font-family: monospace;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: block;
    }

    .badge-check {
        position: absolute;
        top: 6px;
        right: 6px;
        width: 20px;
        height: 20px;
        background: var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        border-radius: 50%;
        font-size: 0.75rem;
        font-weight: 900;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .badge-already {
        position: absolute;
        top: 6px;
        right: 6px;
        background: rgba(0, 0, 0, 0.6);
        color: var(--fdb-text-secondary, #a89886);
        font-size: 0.65rem;
        padding: 0.15rem 0.4rem;
        border-radius: 3px;
        border: 1px solid rgba(255, 255, 255, 0.1);
    }

    .empty-state {
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: var(--fdb-text-secondary, #a89886);
        text-align: center;
        padding: 3rem 1rem;
    }

    .empty-title {
        font-size: 1.1rem;
        font-weight: 600;
        margin-bottom: 0.35rem;
    }

    .empty-sub {
        font-size: 0.85rem;
        opacity: 0.7;
    }

    .card-footer {
        position: relative;
        z-index: 2;
        padding: 1.25rem 1.75rem;
        display: flex;
        justify-content: flex-end;
        gap: 1rem;
        background: rgba(0, 0, 0, 0.3);
    }

    .btn-cancel {
        background: transparent;
        border: 1px solid var(--fdb-border-color, #4a3828);
        color: var(--fdb-text-secondary, #a89886);
        padding: 0.65rem 1.25rem;
        border-radius: 4px;
        font-size: 0.9rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-cancel:hover {
        background: rgba(255, 255, 255, 0.05);
        color: var(--fdb-text-color, #f4ede4);
    }

    .btn-confirm {
        background: var(--fdb-accent-color, #d4a373);
        border: 1px solid var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        padding: 0.65rem 1.5rem;
        border-radius: 4px;
        font-size: 0.9rem;
        font-weight: 700;
        letter-spacing: 0.03em;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-confirm:hover:not(:disabled) {
        filter: brightness(1.15);
        box-shadow: 0 0 15px rgba(212, 163, 115, 0.4);
    }

    .btn-confirm:disabled {
        opacity: 0.4;
        cursor: not-allowed;
        box-shadow: none;
    }
</style>
