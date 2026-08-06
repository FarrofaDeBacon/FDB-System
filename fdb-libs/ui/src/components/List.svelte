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
        <button class="arrow-btn left" on:click={() => changeIndex(-1)}></button>
        <span class="value-display">{values[current - 1] || '---'}</span>
        <button class="arrow-btn right" on:click={() => changeIndex(1)}></button>
    </div>
</div>

<style>
    .list-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
        padding: 1.5vh;
        background-color: transparent;
        position: relative;
        border: none;
        margin-bottom: 5px;
    }

    .list-container::before {
        content: "";
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: url('/assets/selection_box_bg_1d.png');
        background-size: 100% 100%;
        filter: invert(75%);
        z-index: -1;
        opacity: 0.6;
        transition: opacity 0.2s;
    }

    .list-container:hover::before {
        opacity: 0.9;
    }

    .list-container:hover::after {
        content: "";
        position: absolute;
        top: -3px; bottom: -3px; left: 0px; right: 0px;
        border-image-source: url('/assets/hover.png');
        border-image-slice: 10 10 10 10 fill;
        border-image-repeat: round;
        border-style: solid;
        border-width: 8px;
        border-color: var(--fdb-accent-color);
        opacity: 1;
        pointer-events: none;
        z-index: 10;
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
        z-index: 5;
    }

    .controls {
        display: flex;
        align-items: center;
        gap: 10px;
        z-index: 5;
    }

    .arrow-btn {
        background: transparent;
        border: none;
        cursor: pointer;
        width: 15px;
        height: 15px;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
        font-size: 0; /* hide text */
        transition: transform 0.1s;
        filter: invert(1);
    }
    
    .arrow-btn.left { background-image: url('/assets/selection_arrow_left.png'); }
    .arrow-btn.right { background-image: url('/assets/selection_arrow_right.png'); }

    .arrow-btn:hover {
        transform: scale(1.3);
    }

    .arrow-btn:active {
        transform: scale(0.9);
    }

    .value-display {
        min-width: 80px;
        text-align: center;
        font-size: 0.9rem;
        font-family: var(--fdb-font-display);
        color: var(--fdb-text-primary);
    }
</style>
