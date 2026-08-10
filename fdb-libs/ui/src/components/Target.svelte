<script>
    import { onMount, onDestroy } from 'svelte';

    export let visible = false;
    export let options = [];
    export let isMouseFree = false;

    // Escuta eventos globais
    function handleMessage(event) {
        const item = event.data;
        if (item.action === "SET_TARGET_EYE") {
            visible = item.data.visible;
            if (!visible) {
                options = [];
                isMouseFree = false;
            }
        } else if (item.action === "SET_TARGET_OPTIONS") {
            options = item.data.options || [];
        } else if (item.action === "SET_TARGET_MOUSE") {
            isMouseFree = item.data.free;
        }
    }

    onMount(() => {
        window.addEventListener('message', handleMessage);
    });

    onDestroy(() => {
        window.removeEventListener('message', handleMessage);
    });

    function selectOption(index) {
        if (!isMouseFree) return; // Só clica se o mouse estiver liberado
        fetch(`https://${GetParentResourceName()}/targetSelectOption`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ index: index })
        });
        // Esconde tudo após clicar
        visible = false;
        options = [];
        isMouseFree = false;
    }
</script>

{#if visible}
    <div class="target-container" class:mouse-free={isMouseFree}>
        
        <!-- O Olho Central (Sempre no meio da tela) -->
        <div class="target-eye" class:has-options={options.length > 0}>
            {#if options.length > 0}
                <i class="fa-solid fa-eye"></i>
            {:else}
                <i class="fa-solid fa-circle"></i>
            {/if}
        </div>

        <!-- A Lista de Opções (Fica ao lado do Olho) -->
        {#if options.length > 0}
            <div class="target-options">
                {#each options as opt, i}
                    <!-- svelte-ignore a11y-click-events-have-key-events -->
                    <div class="target-option" on:click={() => selectOption(i + 1)}>
                        {#if opt.icon}
                            <i class="{opt.icon} option-icon"></i>
                        {/if}
                        <span class="option-label">{opt.label}</span>
                    </div>
                {/each}
            </div>
        {/if}

    </div>
{/if}

<style>
    .target-container {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        z-index: 9999;
        pointer-events: none; /* Deixa o mouse passar direto se nao estiver livre */
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .target-container.mouse-free {
        pointer-events: auto; /* Habilita cliques quando o mouse esta livre */
        background: rgba(0, 0, 0, 0.1); /* Um fundinho bem sutil pra saber que pausou */
    }

    .target-eye {
        position: absolute;
        color: rgba(255, 255, 255, 0.5);
        font-size: 8px;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        text-shadow: 0 0 2px rgba(0,0,0,0.8);
    }

    .target-eye.has-options {
        color: var(--fdb-accent-color, #c9a15a);
        font-size: 16px;
        transform: scale(1.2);
    }

    .target-options {
        position: absolute;
        left: 50%;
        top: 50%;
        transform: translate(30px, -50%); /* Desloca pra direita do olho */
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .target-option {
        background: rgba(15, 15, 15, 0.85);
        border: 1px solid rgba(255,255,255, 0.1);
        border-left: 3px solid var(--fdb-accent-color, #c9a15a);
        padding: 6px 12px;
        border-radius: 3px;
        display: flex;
        align-items: center;
        gap: 8px;
        color: #d4c5b0;
        font-family: 'Roboto Condensed', sans-serif;
        font-size: 13px;
        cursor: pointer;
        transition: all 0.1s ease;
        pointer-events: auto; /* Sempre clicável se mouse-free */
        box-shadow: 0 4px 10px rgba(0,0,0,0.5);
    }

    .target-container.mouse-free .target-option:hover {
        background: rgba(201, 161, 90, 0.2);
        color: #fff;
        padding-left: 16px;
    }

    .option-icon {
        font-size: 14px;
        color: var(--fdb-accent-color, #c9a15a);
    }
</style>
