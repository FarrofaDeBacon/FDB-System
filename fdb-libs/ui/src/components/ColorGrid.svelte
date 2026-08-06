<script>
    import { createEventDispatcher } from 'svelte';
    
    export let label = 'Color Picker';
    export let min = 1;
    export let max = 64;
    export let value = 1;
    // Optional: array of hex colors mapping to indices. If not provided, we show numbered boxes.
    export let colors = []; 

    const dispatch = createEventDispatcher();

    function selectValue(idx) {
        value = idx;
        dispatch('change', { value });
    }

    // Generate array from min to max
    $: items = Array.from({ length: (max - min) + 1 }, (_, i) => min + i);
</script>

<div class="colorgrid-container">
    <div class="header">
        <span class="label">{label}</span>
        <span class="current-val">{value} / {max}</span>
    </div>
    
    <div class="grid">
        {#each items as item}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <div 
                class="grid-item {value === item ? 'active' : ''}" 
                style={colors[item] ? `background-color: ${colors[item]}` : ''}
                on:click={() => selectValue(item)}
            >
                {#if !colors[item]}
                    <span>{item}</span>
                {/if}
            </div>
        {/each}
    </div>
</div>

<style>
    .colorgrid-container {
        display: flex;
        flex-direction: column;
        width: 100%;
        padding: 1.5vh;
        background: rgba(0, 0, 0, 0.2);
        border: 1px solid var(--fdb-border-color);
        border-radius: calc(var(--fdb-border-radius) / 2);
        gap: 1vh;
    }

    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
    }

    .current-val {
        font-size: 0.85rem;
        color: var(--fdb-text-secondary);
        background: rgba(255, 255, 255, 0.05);
        padding: 0.2vh 0.8vh;
        border-radius: 2px;
    }

    .grid {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        max-height: 120px;
        overflow-y: auto;
        padding-right: 4px;
    }

    .grid::-webkit-scrollbar {
        width: 4px;
    }
    .grid::-webkit-scrollbar-thumb {
        background: var(--fdb-accent-color);
        border-radius: 4px;
    }

    .grid-item {
        position: relative;
        width: 37px;
        height: 37px;
        display: flex;
        justify-content: center;
        align-items: center;
        background: transparent;
        border: none;
        font-size: 0.85rem;
        color: var(--fdb-text-primary);
        cursor: pointer;
        transition: all 0.1s;
        margin-bottom: 5px;
    }

    .grid-item::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-image: url('/assets/swatch_box.png');
        background-size: cover;
        background-position: center;
        z-index: 1;
        opacity: 0.8;
    }

    .grid-item:hover::before {
        opacity: 1;
        transform: scale(1.1);
    }

    .grid-item span {
        position: relative;
        z-index: 2;
        font-family: var(--fdb-font-display);
    }

    .grid-item.active span {
        color: var(--fdb-background-color);
        font-weight: bold;
    }

    .grid-item.active::after {
        content: "";
        position: absolute;
        top: -8px;
        left: -7px;
        width: calc(100% + 14px);
        height: calc(100% + 14px);
        background-color: var(--fdb-accent-color);
        -webkit-mask-image: url('/assets/selection_box_square.png');
        mask-image: url('/assets/selection_box_square.png');
        -webkit-mask-size: 100%;
        mask-size: 100%;
        -webkit-mask-repeat: no-repeat;
        mask-repeat: no-repeat;
        -webkit-mask-position: center;
        mask-position: center;
        z-index: 0;
    }
</style>
