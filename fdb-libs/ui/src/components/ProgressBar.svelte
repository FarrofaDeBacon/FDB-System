<script>
    export let active = false;
    export let label = 'PROGREDINDO...';
    export let percent = 0;
    export let icon = '';
</script>

{#if active}
    <div class="progress-container">
        <div class="label-container">
            {#if icon}
                <img src="./assets/{icon}.png" alt="icon" class="progress-icon" />
            {/if}
            <span class="progress-label">{label}</span>
        </div>
        
        <div class="progress-track">
            <div class="progress-fill" style="width: {percent}%"></div>
        </div>
    </div>
{/if}

<style>
    .progress-container {
        position: absolute;
        bottom: 12vh;
        left: 50%;
        transform: translateX(-50%);
        width: 380px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 0.8vh;
        padding: 1.5vh 2.5vh;
        background-color: var(--fdb-background-color);
        border: 1px solid var(--fdb-border-color);
        border-radius: var(--fdb-border-radius);
        box-shadow: 0 4px 20px rgba(0,0,0,0.5);
        z-index: 9998;
    }

    .progress-container::before {
        content: "";
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: url('/assets/selection_box_bg_1d.png');
        background-size: 100% 100%;
        opacity: 0.05;
        z-index: -1;
        pointer-events: none;
    }

    .label-container {
        display: flex;
        align-items: center;
        gap: 1vh;
    }

    .progress-icon {
        width: 20px;
        height: 20px;
        object-fit: contain;
    }

    .progress-label {
        font-family: var(--fdb-font-display);
        color: var(--fdb-text-primary);
        font-size: 0.95rem;
        font-weight: bold;
        letter-spacing: 1px;
        text-transform: uppercase;
        text-shadow: 0 1px 3px rgba(0,0,0,0.8);
    }

    .progress-track {
        width: 100%;
        height: 6px;
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 2px;
        overflow: hidden;
        position: relative;
    }

    .progress-fill {
        height: 100%;
        background-color: var(--fdb-accent-color);
        box-shadow: 0 0 8px var(--fdb-accent-color);
        transition: width 0.05s linear;
        border-radius: 2px;
    }
</style>
