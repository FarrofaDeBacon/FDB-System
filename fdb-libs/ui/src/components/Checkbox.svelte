<script>
    import { createEventDispatcher } from 'svelte';
    
    export let label = 'Toggle';
    export let checked = false;

    const dispatch = createEventDispatcher();

    function toggle() {
        checked = !checked;
        dispatch('change', { value: checked });
    }
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div class="checkbox-container" on:click={toggle}>
    <span class="label">{label}</span>
    
    <div class="box {checked ? 'checked' : ''}">
        {#if checked}
            <span class="checkmark">✓</span>
        {/if}
    </div>
</div>

<style>
    .checkbox-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
        padding: 1.5vh;
        background: rgba(0, 0, 0, 0.2);
        border: 1px solid var(--fdb-border-color);
        border-radius: calc(var(--fdb-border-radius) / 2);
        cursor: pointer;
        transition: background 0.1s;
    }

    .checkbox-container:hover {
        background: rgba(255, 255, 255, 0.05);
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
    }

    .box {
        width: 24px;
        height: 24px;
        border: 2px solid rgba(255, 255, 255, 0.3);
        border-radius: 4px;
        display: flex;
        justify-content: center;
        align-items: center;
        transition: all 0.2s;
    }

    .box.checked {
        border-color: var(--fdb-accent-color);
        background: var(--fdb-accent-color);
    }

    .checkmark {
        color: var(--fdb-background-color);
        font-size: 1rem;
        font-weight: bold;
    }
</style>
