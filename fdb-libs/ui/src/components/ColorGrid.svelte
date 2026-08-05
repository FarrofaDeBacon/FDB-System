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
                    {item}
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
        width: 28px;
        height: 28px;
        display: flex;
        justify-content: center;
        align-items: center;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 2px;
        font-size: 0.75rem;
        color: var(--fdb-text-primary);
        cursor: pointer;
        transition: all 0.1s;
    }

    .grid-item:hover {
        border-color: var(--fdb-accent-color);
        transform: scale(1.1);
    }

    .grid-item.active {
        background: var(--fdb-accent-color);
        border-color: var(--fdb-accent-color);
        color: var(--fdb-background-color);
        font-weight: bold;
    }
</style>
