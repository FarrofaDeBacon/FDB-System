<script>
    import { onMount, createEventDispatcher } from 'svelte';

    export let id;
    export let type = 'info'; // 'info', 'success', 'error', 'warning'
    export let icon = ''; // Nome do ícone customizado (opcional, ex: 'dollar', 'toast_horse_bond')
    export let title = '';
    export let message = '';
    export let duration = 5000;
    export let customBg = ''; // Override de cor de fundo (opcional)
    export let customBorder = ''; // Override de cor da borda/linha de progresso (opcional)

    const dispatch = createEventDispatcher();

    let progress = 100;
    let timer;
    let progressInterval;

    onMount(() => {
        const startTime = Date.now();
        
        progressInterval = setInterval(() => {
            const elapsed = Date.now() - startTime;
            progress = Math.max(0, 100 - (elapsed / duration) * 100);
        }, 30);

        timer = setTimeout(() => {
            closeNotification();
        }, duration);

        return () => {
            clearTimeout(timer);
            clearInterval(progressInterval);
        };
    });

    function closeNotification() {
        dispatch('close');
    }
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div 
    class="notification-box {type}" 
    on:click={closeNotification}
    style="{customBg ? `background-color: ${customBg};` : ''} {customBorder ? `--border-color: ${customBorder};` : ''}"
>
    <div class="border-overlay"></div>
    <div class="icon-container">
        {#if icon}
            <img src="./assets/{icon}.png" alt={type} class="icon-img" />
        {:else}
            <div class="icon-img icon-fallback {type}"></div>
        {/if}
    </div>
    
    <div class="text-container">
        {#if title}
            <h4 class="title">{title}</h4>
        {/if}
        <p class="message">{message}</p>
    </div>

    <div class="progress-bar" style="width: {progress}%"></div>
</div>

<style>
    .notification-box {
        position: relative;
        display: flex;
        align-items: center;
        width: 320px;
        min-height: 60px;
        background: var(--fdb-background-color);
        color: var(--fdb-text-primary);
        border: 1px solid var(--fdb-border-color);
        padding: 1.5vh 2vh;
        gap: 1.5vh;
        pointer-events: auto;
        cursor: pointer;
        animation: slideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4);
        margin-bottom: 10px;
        overflow: hidden;
        border-radius: var(--fdb-border-radius);
    }

    .notification-box::before {
        content: "";
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: var(--fdb-bg-image-card);
        background-size: 100% 100%;
        opacity: 0.05;
        z-index: 0;
        pointer-events: none;
    }

    .border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--border-color, var(--fdb-accent-color));
        pointer-events: none;
        z-index: 2;
    }

    .success {
        --border-color: var(--fdb-status-good);
        --icon-color: var(--fdb-status-good);
    }
    .error {
        --border-color: var(--fdb-status-critical);
        --icon-color: var(--fdb-status-critical);
    }
    .warning {
        --border-color: var(--fdb-status-warning);
        --icon-color: var(--fdb-status-warning);
    }
    .info {
        --border-color: var(--fdb-accent-color);
        --icon-color: var(--fdb-accent-color);
    }

    .icon-container {
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--icon-color);
        z-index: 1;
    }

    .icon-img {
        width: 32px;
        height: 32px;
        object-fit: contain;
        z-index: 1;
    }

    .icon-img.icon-fallback {
        background-size: 100% 100%;
        background-repeat: no-repeat;
        background-position: center;
    }

    .icon-img.icon-fallback.success {
        background-image: var(--fdb-bg-image-notify-success);
    }

    .icon-img.icon-fallback.error {
        background-image: var(--fdb-bg-image-notify-error);
    }

    .icon-img.icon-fallback.warning {
        background-image: var(--fdb-bg-image-notify-warning);
    }

    .icon-img.icon-fallback.info {
        background-image: var(--fdb-bg-image-notify-info);
    }

    .text-container {
        display: flex;
        flex-direction: column;
        flex: 1;
        z-index: 1;
    }

    .title {
        margin: 0 0 0.2vh 0;
        font-family: var(--fdb-font-display);
        font-size: 0.95rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: var(--border-color);
    }

    .message {
        margin: 0;
        font-size: 0.85rem;
        line-height: 1.3;
        font-weight: 400;
        color: var(--fdb-text-primary);
    }

    .progress-bar {
        position: absolute;
        bottom: 0;
        left: 0;
        height: 3px;
        background: var(--border-color);
        opacity: 0.8;
        z-index: 2;
        transition: width 0.03s linear;
    }

    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
</style>
