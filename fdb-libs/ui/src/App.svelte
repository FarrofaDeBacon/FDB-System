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
    :global(html, body) {
        margin: 0;
        padding: 0;
        width: 100vw;
        height: 100vh;
        overflow: hidden;
        user-select: none;
        /* Default generic fallbacks if theme isn't set */
        --fdb-accent-color: #c9a15a;
        --fdb-background-color: rgba(10, 10, 10, 0.85);
        --fdb-border-radius: 8px;
        --fdb-border-width: 1px;
        --fdb-border-color: rgba(255, 255, 255, 0.1);
        --fdb-font: 'Roboto Condensed', sans-serif;
        --fdb-blur-amount: 12px;
        
        font-family: var(--fdb-font);
        background: transparent;
    }
</style>
