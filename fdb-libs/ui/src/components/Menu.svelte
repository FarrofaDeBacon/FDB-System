<script>
    import { createEventDispatcher } from 'svelte';
    import Slider from './Slider.svelte';
    import List from './List.svelte';
    import ColorGrid from './ColorGrid.svelte';
    import Checkbox from './Checkbox.svelte';
    import Separator from './Separator.svelte';

    export let menuData = {};

    const dispatch = createEventDispatcher();

    function handleItemChange(event, item) {
        // Dispara evento para o componente pai (App.svelte)
        dispatch('itemChange', {
            menuId: menuData.id,
            itemId: item.id,
            value: event.detail.value
        });
    }

    // Validação reativa de tipos de itens no menu
    $: {
        if (menuData && menuData.items) {
            const validTypes = ['slider', 'list', 'color', 'checkbox', 'separator', 'button'];
            menuData.items.forEach(item => {
                if (item.type && !validTypes.includes(item.type)) {
                    console.warn(`[fdb-libs] Tipo de item inválido/desconhecido: "${item.type}" no item "${item.id || item.label}"`);
                }
            });
        }
    }
</script>

<div class="menu-container">
    <div class="header">
        <h1 class="title">{menuData.title || 'FDB LIBS'}</h1>
        {#if menuData.subtitle}
            <h2 class="subtitle">{menuData.subtitle}</h2>
        {/if}
    </div>
    
    <div class="content">
        {#each (menuData.items || []) as item}
            <div class="item-wrapper">
                {#if item.type === 'slider'}
                    <Slider 
                        {...item} 
                        on:change={(e) => handleItemChange(e, item)}
                    />
                {:else if item.type === 'list'}
                    <List 
                        {...item}
                        on:change={(e) => handleItemChange(e, item)}
                    />
                {:else if item.type === 'color'}
                    <ColorGrid 
                        {...item}
                        on:change={(e) => handleItemChange(e, item)}
                    />
                {:else if item.type === 'checkbox'}
                    <Checkbox 
                        {...item}
                        on:change={(e) => handleItemChange(e, item)}
                    />
                {:else if item.type === 'separator'}
                    <Separator {...item} />
                {:else if item.type === 'button'}
                    <button class="generic-btn" on:click={() => handleItemChange({detail: {value: true}}, item)}>
                        {item.label}
                    </button>
                {/if}
            </div>
        {/each}
    </div>
</div>

<style>
    .menu-container {
        position: absolute;
        top: 5vh;
        left: 3vw;
        width: 540px;
        max-height: 90vh;
        display: flex;
        flex-direction: column;
        color: var(--fdb-text-primary);
        /* Removendo a cor de fundo sólida para usar a textura de papel rasgado abaixo */
    }

    /* O Fundo de Papel Amassado do RDR2 */
    .menu-container::before {
        content: "";
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-image: url('/assets/background.png');
        filter: invert(100%);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        z-index: -1;
        opacity: 0.95;
    }

    .header {
        background-image: url('/assets/menu_header.png');
        background-repeat: no-repeat;
        background-size: 100% 100%;
        width: 100%;
        height: 108px;
        min-height: 108px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
        margin-bottom: 5px;
    }

    .title {
        margin: 0;
        font-size: 1.8rem;
        font-weight: 700;
        letter-spacing: 2px;
        text-transform: uppercase;
        font-family: var(--fdb-font-display);
        color: var(--fdb-accent-color);
    }

    .subtitle {
        margin: 0.5vh 0 0 0;
        font-size: 0.9rem;
        color: var(--fdb-text-secondary);
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .content {
        flex: 1;
        overflow-y: auto;
        padding: 1.5vh;
        display: flex;
        flex-direction: column;
        gap: 1.5vh;
    }

    .content::-webkit-scrollbar {
        width: 4px;
    }
    .content::-webkit-scrollbar-thumb {
        background: var(--fdb-accent-color);
        border-radius: 4px;
    }

    .item-wrapper {
        width: 100%;
    }

    .generic-btn {
        width: 100%;
        padding: 1.5vh;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid var(--fdb-border-color);
        border-radius: calc(var(--fdb-border-radius) / 2);
        color: var(--fdb-text-primary);
        font-family: inherit;
        font-size: 1rem;
        cursor: pointer;
        transition: all 0.2s ease;
        text-align: left;
    }
    
    .generic-btn:hover {
        background: rgba(255, 255, 255, 0.1);
        border-color: var(--fdb-accent-color);
    }
</style>
