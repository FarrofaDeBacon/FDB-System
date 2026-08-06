<script>
    import { onMount } from 'svelte';
    import Menu from './components/Menu.svelte';
    import Notify from './components/Notify.svelte';
    import ProgressBar from './components/ProgressBar.svelte';

    let menuData = null;
    let isOpen = false;
    let notifications = [];

    // Estado da barra de progresso
    let progressActive = false;
    let progressLabel = 'PROGREDINDO...';
    let progressPercent = 0;
    let progressIcon = '';
    let progressDuration = 0;
    let progressStartTime = 0;
    let progressInterval = null;

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

    function removeNotification(id) {
        notifications = notifications.filter(n => n.id !== id);
    }

    function startProgress() {
        clearInterval(progressInterval);
        progressStartTime = Date.now();
        progressInterval = setInterval(() => {
            const elapsed = Date.now() - progressStartTime;
            progressPercent = Math.min(100, (elapsed / progressDuration) * 100);
            if (progressPercent >= 100) {
                clearInterval(progressInterval);
                finishProgress();
            }
        }, 16);
    }

    function finishProgress() {
        progressActive = false;
        fetch(`https://${GetParentResourceName()}/progressComplete`, {
            method: 'POST',
            body: JSON.stringify({})
        }).catch(() => {});
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
            } else if (data.action === 'SEND_NOTIFICATION') {
                notifications = [...notifications, {
                    id: Date.now() + Math.random(),
                    type: data.type || 'info',
                    title: data.title || '',
                    message: data.message || '',
                    duration: data.duration || 5000,
                    icon: data.icon || '',
                    customBg: data.customBg || '',
                    customBorder: data.customBorder || ''
                }];
            } else if (data.action === 'START_PROGRESS') {
                progressActive = true;
                progressLabel = data.label || 'PROGREDINDO...';
                progressDuration = data.duration || 3000;
                progressIcon = data.icon || '';
                progressPercent = 0;
                startProgress();
            } else if (data.action === 'CANCEL_PROGRESS') {
                clearInterval(progressInterval);
                progressActive = false;
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

        // Let Lua know NUI is ready to receive theme
        if (window.GetParentResourceName) {
            fetch(`https://${GetParentResourceName()}/nuiReady`, {
                method: 'POST',
                body: JSON.stringify({})
            }).catch(() => {});
        }

        return () => {
            window.removeEventListener('message', handleMessage);
            window.removeEventListener('keydown', handleKey);
            clearInterval(progressInterval);
        };
    });
</script>

<main>
    {#if isOpen && menuData}
        <Menu {menuData} />
    {/if}

    <div class="notifications-layer">
        {#each notifications as notification (notification.id)}
            <Notify 
                {...notification} 
                on:close={() => removeNotification(notification.id)} 
            />
        {/each}
    </div>

    <ProgressBar 
        active={progressActive} 
        label={progressLabel} 
        percent={progressPercent} 
        icon={progressIcon}
    />
</main>

<style>
    .notifications-layer {
        position: absolute;
        top: 3vh;
        right: 2vw;
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        pointer-events: none;
        z-index: 9999;
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
