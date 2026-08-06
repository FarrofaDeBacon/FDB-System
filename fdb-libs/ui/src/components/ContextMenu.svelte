<script>
    import { onMount, onDestroy } from 'svelte';
    
    export let visible = false;
    export let title = "Opções";
    export let options = [];
    export let position = "mouse"; // "mouse" ou "center"
    
    let x = 0;
    let y = 0;
    let menuEl;

    // Escuta eventos globais
    function handleMessage(event) {
        const item = event.data;
        if (item.action === "OPEN_CONTEXT_MENU") {
            title = item.data.title;
            options = item.data.options;
            position = item.data.position;
            visible = true;
            
            if (position === "mouse") {
                // Posiciona o menu no cursor atual
            }
        } else if (item.action === "CLOSE_CONTEXT_MENU") {
            visible = false;
        }
    }
    
    function trackMouse(event) {
        // Grava as coordenadas atuais do cursor para posicionar se o menu for aberto via mouse
        if (!visible) {
            x = event.clientX;
            y = event.clientY;
        }
    }

    onMount(() => {
        window.addEventListener('message', handleMessage);
        window.addEventListener('mousemove', trackMouse);
        window.addEventListener('keydown', handleKeyDown);
    });

    onDestroy(() => {
        window.removeEventListener('message', handleMessage);
        window.removeEventListener('mousemove', trackMouse);
        window.removeEventListener('keydown', handleKeyDown);
    });

    function handleKeyDown(event) {
        if (visible && (event.key === "Escape" || event.key === "Backspace")) {
            closeMenu();
        }
    }

    function selectOption(index, disabled) {
        if (disabled) return;
        fetch(`https://${GetParentResourceName()}/contextClick`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ index: index })
        });
        visible = false;
    }

    function closeMenu() {
        fetch(`https://${GetParentResourceName()}/closeContext`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        visible = false;
    }

    // Calcula a posição na tela para evitar que o menu saia das bordas
    $: menuStyle = position === "mouse" 
        ? `position: absolute; left: ${Math.min(x, window.innerWidth - 260)}px; top: ${Math.min(y, window.innerHeight - 300)}px;`
        : `position: absolute; left: 50%; top: 50%; transform: translate(-50%, -50%);`;
</script>

{#if visible}
    <!-- Fundo invisível para detectar clique fora e fechar -->
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <div class="context-overlay" on:click={closeMenu}>
        <div 
            class="context-menu" 
            style={menuStyle} 
            bind:this={menuEl}
            on:click|stopPropagation
        >
            {#if title}
                <div class="context-header">{title}</div>
            {/if}
            
            <div class="context-options">
                {#each options as opt, i}
                    <!-- svelte-ignore a11y-click-events-have-key-events -->
                    <div 
                        class="context-option" 
                        class:disabled={opt.disabled}
                        on:click={() => selectOption(i + 1, opt.disabled)}
                    >
                        {#if opt.icon}
                            <span class="option-icon">
                                <i class="fas fa-{opt.icon}"></i>
                            </span>
                        {/if}
                        <div class="option-content">
                            <span class="option-label">{opt.label}</span>
                            {#if opt.description}
                                <span class="option-desc">{opt.description}</span>
                            {/if}
                        </div>
                    </div>
                {/each}
            </div>
        </div>
    </div>
{/if}

<style>
    .context-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        z-index: 9999;
        background: transparent;
    }

    .context-menu {
        width: 250px;
        background-color: var(--fdb-background-color, rgba(15, 15, 15, 0.96));
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        border-left: 3px solid var(--fdb-accent-color, #c9a15a);
        border-radius: var(--fdb-border-radius, 4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
        font-family: var(--fdb-font-body, 'Roboto Condensed', sans-serif);
        overflow: hidden;
        animation: fadeIn 0.12s ease-out;
    }

    .context-header {
        padding: 10px 15px;
        background-color: rgba(255, 255, 255, 0.02);
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        color: var(--fdb-text-primary, #d4c5b0);
        font-family: var(--fdb-font-display, 'Playfair Display', serif);
        font-size: 14px;
        font-weight: bold;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .context-options {
        padding: 5px 0;
    }

    .context-option {
        display: flex;
        align-items: center;
        padding: 8px 15px;
        color: var(--fdb-text-secondary, #a89878);
        cursor: pointer;
        transition: all 0.1s ease;
    }

    .context-option:hover:not(.disabled) {
        background-color: rgba(201, 161, 90, 0.08);
        color: var(--fdb-accent-color, #c9a15a);
        padding-left: 18px;
    }

    .context-option.disabled {
        opacity: 0.4;
        cursor: not-allowed;
    }

    .option-icon {
        margin-right: 12px;
        font-size: 13px;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 16px;
    }

    .option-content {
        display: flex;
        flex-direction: column;
    }

    .option-label {
        font-size: 13px;
        font-weight: 500;
    }

    .option-desc {
        font-size: 10px;
        color: rgba(255, 255, 255, 0.35);
        margin-top: 1px;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: scale(0.96);
        }
        to {
            opacity: 1;
            transform: scale(1);
        }
    }
</style>
