<script>
    import { onMount } from 'svelte';

    let visible = false;
    let theme = {};

    // Recebe mensagens do Lua
    onMount(() => {
        const handleMessage = (event) => {
            const data = event.data;
            if (data.action === 'openEditor') {
                theme = data.theme || {};
                visible = true;
                
                // Aplica variáveis do tema na raiz (document.documentElement ou no próprio App)
                if (theme) {
                    const root = document.documentElement;
                    Object.entries(theme).forEach(([key, value]) => {
                        // Exemplo: converte "accentColor" para "--fdb-accent-color"
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
        <div class="theme-test-card">
            <h1>FDB-Shops: Theme Test</h1>
            <p>Se você consegue ler isso e as cores batem com o fdb-libs, o tema global está funcionando!</p>
            <div class="status-grid">
                <div class="status-box" style="background-color: var(--fdb-status-good)">Good</div>
                <div class="status-box" style="background-color: var(--fdb-status-warning)">Warning</div>
                <div class="status-box" style="background-color: var(--fdb-status-critical)">Critical</div>
                <div class="status-box" style="background-color: var(--fdb-status-info)">Info</div>
            </div>
            <button class="test-button" on:click={() => {
                fetch(`https://${window.GetParentResourceName()}/closeEditor`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }}>
                Fechar (ou aperte ESC)
            </button>
        </div>
    </div>
{/if}

<style>
    .fdb-shops-app {
        width: 100vw;
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        /* Usando a fonte do tema como default pro container */
        font-family: var(--fdb-font-body, sans-serif);
    }

    .theme-test-card {
        background-color: var(--fdb-background-color, #1a1a1a);
        color: var(--fdb-text-primary, #ffffff);
        padding: 2rem;
        border: 2px solid var(--fdb-border-color-wood, #555);
        border-radius: var(--fdb-border-radius, 8px);
        max-width: 500px;
        text-align: center;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    h1 {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-accent-color, #ffaa00);
        margin-top: 0;
    }

    p {
        color: var(--fdb-text-secondary, #ccc);
        margin-bottom: 2rem;
    }

    .status-grid {
        display: flex;
        gap: 10px;
        justify-content: center;
        margin-bottom: 2rem;
    }

    .status-box {
        padding: 0.5rem 1rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-weight: bold;
        color: #fff;
        text-shadow: 1px 1px 2px rgba(0,0,0,0.8);
    }

    .test-button {
        background-color: var(--fdb-accent-color-dark, #cc8800);
        color: var(--fdb-text-primary, #fff);
        border: 1px solid var(--fdb-accent-color, #ffaa00);
        padding: 0.75rem 1.5rem;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        font-family: var(--fdb-font-display, serif);
        font-size: 1.1rem;
        transition: all 0.2s;
    }

    .test-button:hover {
        background-color: var(--fdb-accent-color, #ffaa00);
    }
</style>
