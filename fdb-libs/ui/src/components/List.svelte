<script>
    import { createEventDispatcher } from 'svelte';
    
    export let id = '';
    export let label = 'List';
    export let values = [];
    export let current = 1;

    const dispatch = createEventDispatcher();

    function changeIndex(delta) {
        if (!values || values.length === 0) return;
        
        let newIdx = current + delta;
        if (newIdx < 1) newIdx = values.length;
        if (newIdx > values.length) newIdx = 1;
        
        current = newIdx;
        dispatch('change', { value: values[current - 1] });
    }
</script>

<div class="list-container">
    <span class="label">{label}</span>
    
    <div class="controls">
        <button class="arrow-btn" on:click={() => changeIndex(-1)}>&#9664;</button>
        <span class="value-display">{values[current - 1] || '---'}</span>
        <button class="arrow-btn" on:click={() => changeIndex(1)}>&#9654;</button>
    </div>
</div>

<style>
    .list-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
        padding: 1.5vh;
        background: rgba(0, 0, 0, 0.2);
        border: 1px solid var(--fdb-border-color);
        border-radius: calc(var(--fdb-border-radius) / 2);
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
    }

    .controls {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .arrow-btn {
        background: transparent;
        border: none;
        color: var(--fdb-accent-color);
        cursor: pointer;
        font-size: 1rem;
        transition: transform 0.1s;
    }

    .arrow-btn:hover {
        transform: scale(1.2);
    }

    .arrow-btn:active {
        transform: scale(0.9);
    }

    .value-display {
        min-width: 80px;
        text-align: center;
        font-size: 0.9rem;
        color: white;
    }
</style>
