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
            <span class="checkmark"></span>
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
        background: transparent;
        position: relative;
        cursor: pointer;
        margin-bottom: 5px;
    }

    .checkbox-container::before {
        content: "";
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: var(--fdb-bg-image-card);
        background-size: 100% 100%;
        filter: invert(75%);
        z-index: -1;
        opacity: 0.3;
        transition: opacity 0.2s;
    }

    .checkbox-container:hover::before {
        opacity: 0.6;
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
        z-index: 5;
    }

    .box {
        width: 32px;
        height: 32px;
        background-image: url('/assets/tick_box.png');
        background-size: contain;
        background-position: center;
        background-repeat: no-repeat;
        display: flex;
        justify-content: center;
        align-items: center;
        transition: all 0.2s;
        z-index: 5;
        filter: brightness(1.2);
    }

    .checkmark {
        width: 24px;
        height: 24px;
        background-image: url('/assets/tick.png');
        background-size: contain;
        background-position: center;
        background-repeat: no-repeat;
        /* Tick preto escuro natural para contrastar com a caixa branca/dourada */
        filter: brightness(0);
    }
</style>
