<script>
    import Slider from './Slider.svelte';
    import List from './List.svelte';

    export let menuData = {};

    function handleItemChange(event, item) {
        // Send the change to the Lua side
        fetch(`https://${GetParentResourceName()}/onMenuChange`, {
            method: 'POST',
            body: JSON.stringify({
                menuId: menuData.id,
                itemId: item.id,
                value: event.detail.value
            })
        });
    }
</script>

<div class="menu-container">
    <div class="background-layer"></div>
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
                {:else}
                    <!-- Fallback generic button -->
                    <button class="generic-btn">
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
        background-color: var(--fdb-background-color);
        border: var(--fdb-border-width) solid var(--fdb-border-color);
        border-radius: var(--fdb-border-radius);
        backdrop-filter: blur(var(--fdb-blur-amount));
        color: white;
        overflow: hidden;
    }

    .background-layer {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: -1;
        background-image: var(--fdb-background-image);
        background-size: 100% 100%;
        background-repeat: no-repeat;
        filter: invert(100%);
    }

    .header {
        padding: 2vh;
        border-bottom: var(--fdb-border-width) solid var(--fdb-border-color);
        text-align: center;
        background-image: var(--fdb-header-image);
        background-size: cover;
        background-repeat: no-repeat;
        min-height: 108px;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }

    .title {
        margin: 0;
        font-size: 1.5rem;
        font-weight: 700;
        letter-spacing: 2px;
        text-transform: uppercase;
    }

    .subtitle {
        margin: 0.5vh 0 0 0;
        font-size: 0.9rem;
        color: var(--fdb-accent-color);
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
        color: white;
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
