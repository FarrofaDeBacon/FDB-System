<script>
    import { onMount } from 'svelte';
    import StoreConfig from './lib/StoreConfig.svelte';

    let visible = false;
    let theme = {};
    let stores = [];
    let selectedStore = null;
    let isPlacementMode = false;

    // Recebe mensagens do Lua
    onMount(() => {
        const handleMessage = (event) => {
            const data = event.data;
            if (data.action === 'openEditor') {
                theme = data.theme || {};
                stores = data.stores || [];
                selectedStore = stores.length > 0 ? stores[0] : null;
                visible = true;
                isPlacementMode = false;
                
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
                isPlacementMode = false;
            } else if (data.action === 'hideUI') {
                isPlacementMode = true;
            } else if (data.action === 'showUI') {
                isPlacementMode = false;
            } else if (data.action === 'placementResult') {
                // The backend handles the coords, but we could show a toast here if we had one
                console.log("Placement success for shopId:", data.shopId);
            }
        };

        const handleKeyDown = (e) => {
            if (visible && !isPlacementMode && e.key === 'Escape') {
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

    function handleStoreDeleted(shopId) {
        stores = stores.filter(s => s.id !== shopId);
        selectedStore = null;
    }
</script>

{#if visible}
    {#if !isPlacementMode}
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
                <StoreConfig store={selectedStore} onClose={closeUI} onDeleted={handleStoreDeleted} />
            {:else}
                <div class="empty-state">
                    <p>Selecione uma loja na lateral para editar.</p>
                </div>
            {/if}
        </div>
    </div>
    {/if}

    {#if isPlacementMode}
    <div class="noclip-hud noclip-hud--visible" aria-hidden="false">
        <div class="noclip-hud__inner">
            <div class="noclip-hud__head">
                <span class="noclip-hud__title" id="ph-title">Posicionamento</span>
                <span class="noclip-hud__speed" id="ph-speed">Normal</span>
            </div>
            <div class="noclip-hud__accent"></div>
            <ul class="noclip-hud__lines" id="ph-lines">
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">W</span><span class="noclip-hud__kbd">A</span><span class="noclip-hud__kbd">S</span><span class="noclip-hud__kbd">D</span>
                    </div>
                    <div class="noclip-hud__desc">Mover marcador</div>
                </li>
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">Q</span><span class="noclip-hud__kbd">E</span>
                    </div>
                    <div class="noclip-hud__desc">Subir / Descer</div>
                </li>
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">LAlt</span>
                    </div>
                    <div class="noclip-hud__desc">Grudar no chão</div>
                </li>
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">Scroll</span>
                    </div>
                    <div class="noclip-hud__desc">Afastar/Aproximar</div>
                </li>
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">←</span> <span class="noclip-hud__kbd">→</span>
                    </div>
                    <div class="noclip-hud__desc">Girar fantasma</div>
                </li>
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">Enter</span>
                    </div>
                    <div class="noclip-hud__desc">Confirmar</div>
                </li>
                <li class="noclip-hud__row">
                    <div class="noclip-hud__keys">
                        <span class="noclip-hud__kbd">Backspace</span>
                    </div>
                    <div class="noclip-hud__desc">Cancelar</div>
                </li>
            </ul>
        </div>
    </div>
    {/if}
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

    /* HUD CSS */
    .noclip-hud { z-index: 25000; pointer-events: none; opacity: 0; max-width: min(300px, 100vw - 40px); transition: opacity 0.2s, transform 0.2s; position: fixed; bottom: 20px; right: 20px; transform: translateY(6px); }
    .noclip-hud.noclip-hud--visible { opacity: 1; transform: translateY(0); }
    .noclip-hud__inner { background: linear-gradient(#1c1c1c, #111); border: 1px solid #333; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.8); }
    .noclip-hud__head { background: #000; border-bottom: 1px solid #333; justify-content: space-between; align-items: center; gap: 10px; padding: 8px 12px; display: flex; }
    .noclip-hud__title { letter-spacing: 0.04em; color: #fff; font-size: 14px; font-weight: 600; }
    .noclip-hud__speed { color: #888; white-space: nowrap; font-size: 12px; }
    .noclip-hud__accent { background: #3498db; height: 2px; }
    .noclip-hud__lines { color: #888; margin: 0; padding: 8px 12px 10px; font-size: 12px; line-height: 1.45; list-style: none; }
    .noclip-hud__row { border-bottom: 1px solid rgba(255,255,255,0.06); justify-content: space-between; align-items: center; gap: 10px; padding: 5px 0; display: flex; }
    .noclip-hud__row:last-child { border-bottom: none; padding-bottom: 2px; }
    .noclip-hud__keys { flex-shrink: 0; align-items: center; gap: 5px; display: flex; }
    .noclip-hud__kbd { letter-spacing: 0.03em; color: #3498db; text-align: center; background: linear-gradient(#2e2e36, #202026); border: 1px solid #3d3d48; border-radius: 5px; min-width: 1.35em; padding: 4px 8px; font-family: system-ui, Segoe UI, sans-serif; font-size: 10px; font-weight: 700; line-height: 1.2; box-shadow: 0 2px rgba(0,0,0,0.4), inset 0 1px rgba(255,255,255,0.07); }
    .noclip-hud__desc { color: #fff; opacity: 0.88; text-align: right; font-size: 11px; }
</style>
