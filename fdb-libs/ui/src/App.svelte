<script>
    import { onMount } from 'svelte';
    import Menu from './components/Menu.svelte';
    import Notify from './components/Notify.svelte';
    import ProgressBar from './components/ProgressBar.svelte';
    import InputDialog from './components/InputDialog.svelte';
    import Minigame from './components/Minigame.svelte';
    import TierBar from './components/TierBar.svelte';
    import ContextMenu from './components/ContextMenu.svelte';
    import ThemeEditor from './components/ThemeEditor.svelte';
    import NoiseBar from './components/NoiseBar.svelte';

    let menuData = null;
    let isOpen = false;
    let notifications = [];

    // Estado do minigame
    let isMinigameActive = false;
    let activeMinigameType = 'lockpick';
    let minigameDuration = 2000;
    let minigameTargetWidth = 15;
    let minigameRounds = 3;
    let minigameImages = {};
    let minigameZones = {};

    // Estado do input dialog
    let isInputOpen = false;
    let inputTitle = 'Diálogo';
    let inputFields = [];

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

    function submitInput(valuesArray) {
        isInputOpen = false;
        fetch(`https://${GetParentResourceName()}/submitInput`, {
            method: 'POST',
            body: JSON.stringify({ values: valuesArray })
        }).catch(() => {});
    }

    function cancelInput() {
        isInputOpen = false;
        fetch(`https://${GetParentResourceName()}/submitInput`, {
            method: 'POST',
            body: JSON.stringify({ values: false })
        }).catch(() => {});
    }

    function submitMinigame(success, tier = null) {
        isMinigameActive = false;
        fetch(`https://${GetParentResourceName()}/minigameResult`, {
            method: 'POST',
            body: JSON.stringify({ success: success, tier: tier })
        }).catch(() => {});
    }

    function handleMenuItemChange(event) {
        fetch(`https://${GetParentResourceName()}/onMenuChange`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(event.detail)
        }).catch(() => {});
    }

    onMount(() => {
        const handleMessage = (event) => {
            const data = event.data;
            console.log("[fdb-libs NUI] Action:", data.action, data);
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
            } else if (data.action === 'OPEN_INPUT') {
                inputTitle = data.title || 'Diálogo';
                inputFields = data.fields || [];
                isInputOpen = true;
            } else if (data.action === 'CLOSE_INPUT') {
                isInputOpen = false;
            } else if (data.action === 'START_MINIGAME') {
                activeMinigameType = data.minigameType || 'lockpick';

                if (activeMinigameType === 'tierbar') {
                    minigameDuration = data.duration || 5.0;
                    minigameImages = data.images || {};
                    minigameZones = data.zones || {
                        common: { start: 10, end: 35 },
                        uncommon: { start: 50, end: 65 },
                        rare: { start: 80, end: 88 }
                    };
                } else {
                    minigameDuration = data.duration || 2000;
                    minigameTargetWidth = data.targetWidth || 15;
                    minigameRounds = data.rounds || 3;
                }

                isMinigameActive = true;
            } else if (data.action === 'CANCEL_MINIGAME') {
                isMinigameActive = false;
            }
        };

        window.addEventListener('message', handleMessage);

        // Escape handling
        const handleKey = (e) => {
            if (e.key === 'Escape' || e.key === 'Backspace') {
                // Se um campo de input de texto estiver focado, ignora o backspace para não fechar
                const activeEl = document.activeElement;
                const isInputField = activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA');
                
                if (isInputField && e.key === 'Backspace') {
                    return; // Permite apagar texto normalmente
                }

                if (isOpen) {
                    fetch(`https://${GetParentResourceName()}/closeMenu`, {
                        method: 'POST',
                        body: JSON.stringify({})
                    });
                    isOpen = false;
                } else if (isInputOpen) {
                    cancelInput();
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
    <NoiseBar />
    {#if isOpen && menuData}
        <Menu {menuData} on:itemChange={handleMenuItemChange} />
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

    {#if isInputOpen}
        <InputDialog 
            title={inputTitle} 
            fields={inputFields} 
            on:submit={(e) => submitInput(e.detail)} 
            on:cancel={cancelInput}
        />
    {/if}

    {#if isMinigameActive && activeMinigameType === 'lockpick'}
        <Minigame 
            active={isMinigameActive} 
            duration={minigameDuration} 
            targetWidth={minigameTargetWidth} 
            rounds={minigameRounds} 
            on:result={(e) => submitMinigame(e.detail.success)}
        />
    {:else if isMinigameActive && activeMinigameType === 'tierbar'}
        <TierBar
            active={isMinigameActive}
            duration={minigameDuration}
            images={minigameImages}
            zones={minigameZones}
            on:result={(e) => submitMinigame(e.detail.success, e.detail.tier)}
        />
    {/if}

    <ContextMenu />
    <ThemeEditor />
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

        /* Imagens de Fundo Customizáveis (Definidas como none para usar o padrão uniforme de cores sólidas) */
        --fdb-bg-image-menu: none;
        --fdb-bg-image-header: none;
        --fdb-bg-image-card: none;
        --fdb-bg-image-hover: none;
        --fdb-bg-image-arrow-left: url('/assets/selection_arrow_left.png');
        --fdb-bg-image-arrow-right: url('/assets/selection_arrow_right.png');
        --fdb-bg-image-tick-box: url('/assets/tick_box.png');
        --fdb-bg-image-tick: url('/assets/tick.png');
        --fdb-bg-image-swatch-box: url('/assets/swatch_box.png');
        --fdb-bg-image-lock: url('/assets/lock.png');
        --fdb-bg-image-slider-marker: url('/assets/tank_meter_marker.png');
        --fdb-bg-image-color-square: url('/assets/selection_box_square.png');
        --fdb-bg-image-notify-success: url('/assets/tick.png');
        --fdb-bg-image-notify-error: url('/assets/cross.png');
        --fdb-bg-image-notify-warning: url('/assets/warning.png');
        --fdb-bg-image-notify-info: url('/assets/star.png');
        
        font-family: var(--fdb-font-body);
        color: var(--fdb-text-primary);
        background: transparent;
    }
</style>
