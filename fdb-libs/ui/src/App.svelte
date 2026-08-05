<script>
    import { onMount } from 'svelte';
    import Menu from './components/Menu.svelte';

    let menuData = null;
    let isOpen = false;

    // Apply theme to the :root element
    function applyTheme(themeObj) {
        if (!themeObj) return;
        const root = document.documentElement;
        for (const [key, value] of Object.entries(themeObj)) {
            // Converts camelCase (accentColor) to kebab-case (--fdb-accent-color)
            const cssVar = `--fdb-${key.replace(/([A-Z])/g, "-$1").toLowerCase()}`;
            root.style.setProperty(cssVar, value);
        }
    }

    onMount(() => {
        const handleMessage = (event) => {
            const data = event.data;
            if (data.action === 'SET_THEME' || data.action === 'SET_THEME_OVERRIDE') {
                applyTheme(data.theme);
            } else if (data.action === 'OPEN_MENU') {
                menuData = data.menuData;
                isOpen = true;
            } else if (data.action === 'CLOSE_MENU') {
                isOpen = false;
            }
        };

        window.addEventListener('message', handleMessage);

        // Escape handling
        const handleKey = (e) => {
            if (e.key === 'Escape' || e.key === 'Backspace') {
                if (isOpen) {
                    fetch(`https://${GetParentResourceName()}/closeMenu`, {
                        method: 'POST',
                        body: JSON.stringify({})
                    });
                    isOpen = false;
                }
            }
        };
        window.addEventListener('keydown', handleKey);

        return () => {
            window.removeEventListener('message', handleMessage);
            window.removeEventListener('keydown', handleKey);
        };
    });
</script>

<main>
    {#if isOpen && menuData}
        <Menu {menuData} />
    {/if}
</main>

<style>
    @font-face {
        font-family: Crock;
        src: url(./assets/crock.ttf) format("truetype");
    }

    :global(html, body) {
        margin: 0;
        padding: 0;
        width: 100vw;
        height: 100vh;
        overflow: hidden;
        user-select: none;
        
        /* New Rustic/ox_lib consistent semantic palette fallbacks */
        --fdb-font-body: 'RDR Lino Regular', 'Roboto Condensed', serif;
        --fdb-font-display: 'RDR Lino Regular', 'Playfair Display', serif;
        --fdb-text-primary: #d4c5b0;
        --fdb-text-secondary: #a89878;
        --fdb-text-on-paper: #2b1d14;
        
        --fdb-accent-color: #c9a15a;
        --fdb-accent-color-dark: #8a6a35;
        
        --fdb-background-color: rgba(10, 10, 10, 0.88);
        --fdb-background-paper: #d8c9a3;
        --fdb-background-wood: #2b1d14;
        
        --fdb-border-color: rgba(255, 255, 255, 0.1);
        --fdb-border-color-wood: #4a2e1a;
        --fdb-border-radius: 4px;

        --fdb-status-good: #27ae60;
        --fdb-status-warning: #c98a3a;
        --fdb-status-critical: #c0392b;
        --fdb-status-info: #2980b9;
        
        font-family: var(--fdb-font-body);
        color: var(--fdb-text-primary);
        background: transparent;
    }
</style>
