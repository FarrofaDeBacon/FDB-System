<script>
    import { onMount } from 'svelte';
    import StoreConfig from './lib/StoreConfig.svelte';

    let visible = false;
    let theme = {};
    let stores = [];
    let selectedStore = null;

    // Recebe mensagens do Lua
    onMount(() => {
        const handleMessage = (event) => {
            const data = event.data;
            if (data.action === 'openEditor') {
                theme = data.theme || {};
                stores = data.stores || [];
                selectedStore = stores.length > 0 ? stores[0] : null;
                visible = true;
                
                // Aplica variáveis do tema na raiz
                if (theme) {
                    const root = document.documentElement;
                    Object.entries(theme).forEach(([key, value]) => {
                        const cssKey = '--fdb-' + key.replace(/([A-Z])/g, "-$1").toLowerCase();
                        root.style.setProperty(cssKey, value);
                    });
                }
            } else if (data.action === 'closeEditor') {
                visible = false;
            }
        };

        const handleKeyDown = (e) => {
            if (visible && e.key === 'Escape') {
                closeUI();
            }
        };

        window.addEventListener('message', handleMessage);
        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener('message', handleMessage);
            window.removeEventListener('keydown', handleKeyDown);
        };
    });

    function closeUI() {
        fetch(`https://${window.GetParentResourceName()}/closeEditor`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    function selectStore(store) {
        selectedStore = store;
    }
</script>

{#if visible}
    <div class="fdb-shops-app">
        <!-- Sidebar -->
        <div class="sidebar">
            <h2 class="sidebar-title">Lojas ({stores.length})</h2>
            <div class="store-list">
                {#each stores as store}
                    <button 
                        class="sidebar-item {selectedStore?.id === store.id ? 'active' : ''}"
                        on:click={() => selectStore(store)}
                    >
                        {store.label || store.id}
                        <span class="badge">{store.template || 'general'}</span>
                    </button>
                {/each}
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            {#if selectedStore}
                <StoreConfig store={selectedStore} onClose={closeUI} />
            {:else}
                <div class="empty-state">
                    <p>Selecione uma loja na lateral para editar.</p>
                </div>
            {/if}
        </div>
    </div>
{/if}

<style>
    :global(body), :global(html) {
        margin: 0;
        padding: 0;
        overflow: hidden;
        width: 100vw;
        height: 100vh;
    }

    .fdb-shops-app {
        width: 100vw;
        height: 100vh;
        display: flex;
        background-color: transparent; /* Removemos o fundo preto opaco gigante */
        font-family: var(--fdb-font-body, sans-serif);
        padding: 4rem;
        box-sizing: border-box;
    }

    .sidebar {
        width: 300px;
        background-color: var(--fdb-background-color, #1a1a1a);
        border: 2px solid var(--fdb-border-color-wood, #555);
        border-radius: var(--fdb-border-radius, 8px);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        margin-right: 2rem;
    }

    .sidebar-title {
        background-color: rgba(0, 0, 0, 0.3);
        margin: 0;
        padding: 1rem;
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-accent-color, #ffaa00);
        font-size: 1.2rem;
        border-bottom: 2px solid var(--fdb-border-color-wood, #555);
        text-align: center;
    }

    .store-list {
        flex: 1;
        overflow-y: auto;
        padding: 0.5rem;
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
    }

    .sidebar-item {
        background: transparent;
        border: 1px solid transparent;
        color: var(--fdb-text-primary, #fff);
        padding: 0.75rem;
        text-align: left;
        border-radius: 4px;
        cursor: pointer;
        font-family: var(--fdb-font-body, sans-serif);
        font-size: 0.9rem;
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
        transition: all 0.2s;
    }

    .sidebar-item:hover {
        background-color: rgba(255, 255, 255, 0.05);
    }

    .sidebar-item.active {
        background-color: rgba(0, 0, 0, 0.2);
        border: 1px solid var(--fdb-accent-color, #ffaa00);
        color: var(--fdb-accent-color, #ffaa00);
    }

    .badge {
        font-size: 0.7rem;
        color: var(--fdb-text-secondary, #999);
        text-transform: uppercase;
    }

    .main-content {
        flex: 1;
        display: flex;
        align-items: flex-start;
        justify-content: flex-start;
    }

    .empty-state {
        background-color: var(--fdb-background-color, #1a1a1a);
        border: 2px solid var(--fdb-border-color-wood, #555);
        border-radius: var(--fdb-border-radius, 8px);
        padding: 2rem;
        color: var(--fdb-text-secondary, #999);
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }
</style>
