<script>
    import { onMount } from 'svelte';
    import StoreConfig from './lib/StoreConfig.svelte';

    let visible = false;
    let theme = {};
    let stores = [];

    // Recebe mensagens do Lua
    onMount(() => {
        const handleMessage = (event) => {
            const data = event.data;
            if (data.action === 'openEditor') {
                theme = data.theme || {};
                stores = data.stores || [];
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
                fetch(`https://${window.GetParentResourceName()}/closeEditor`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }
        };

        window.addEventListener('message', handleMessage);
        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener('message', handleMessage);
            window.removeEventListener('keydown', handleKeyDown);
        };
    });
</script>

{#if visible}
    <div class="fdb-shops-app">
        <div class="header-bar">
            <h1>Gerenciador de Lojas</h1>
            <button class="close-btn" on:click={() => {
                fetch(`https://${window.GetParentResourceName()}/closeEditor`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }}>FECHAR (ESC)</button>
        </div>

        <div class="stores-container">
            {#if stores.length === 0}
                <p class="empty-state">Nenhuma loja encontrada.</p>
            {:else}
                <!-- Grid dinâmico que renderiza o componente reutilizável para cada loja recebida -->
                <div class="stores-grid">
                    {#each stores as store}
                        <StoreConfig {store} />
                    {/each}
                </div>
            {/if}
        </div>
    </div>
{/if}

<style>
    /* Reset do scroll global provocado por margin no body */
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
        flex-direction: column;
        background-color: rgba(0, 0, 0, 0.7); /* Fundo opaco para dar destaque */
        font-family: var(--fdb-font-body, sans-serif);
    }

    .header-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 1rem 2rem;
        background-color: var(--fdb-background-color, #1a1a1a);
        border-bottom: 2px solid var(--fdb-accent-color, #ffaa00);
        box-shadow: 0 4px 10px rgba(0,0,0,0.5);
    }

    .header-bar h1 {
        margin: 0;
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-accent-color, #ffaa00);
        font-size: 2rem;
    }

    .close-btn {
        background-color: var(--fdb-status-critical, #cc0000);
        color: white;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-family: var(--fdb-font-body, sans-serif);
        font-weight: bold;
        cursor: pointer;
        transition: opacity 0.2s;
    }

    .close-btn:hover {
        opacity: 0.8;
    }

    .stores-container {
        flex: 1;
        padding: 2rem;
        overflow-y: auto; /* Permite scroll VERTICAL apenas na área das lojas se tiver muitas */
    }

    .stores-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 2rem;
        justify-content: center;
        align-items: flex-start;
    }

    .empty-state {
        color: var(--fdb-text-secondary, #999);
        text-align: center;
        font-size: 1.2rem;
        margin-top: 4rem;
    }
</style>
