<script>
    export let title = '';
    export let id = '';
    export let width = '420px';
</script>

<div class="fdb-panel-card" style="width: {width};">
    <div class="fdb-panel-background"></div>
    <div class="fdb-panel-border-overlay"></div>

    <div class="fdb-panel-header">
        <h2 class="fdb-panel-title">{title}</h2>
        <div class="fdb-panel-divider"></div>
        {#if id}
            <p class="fdb-panel-subtitle">ID: {id}</p>
        {/if}
    </div>

    <div class="fdb-panel-tabs">
        <slot name="tabs"></slot>
    </div>

    <div class="fdb-panel-content">
        <slot></slot>
    </div>
</div>

<style>
    .fdb-panel-card {
        position: relative;
        background-color: var(--fdb-background-color);
        border: 1px solid var(--fdb-border-color);
        padding: 3.5vh;
        box-shadow: 0 10px 30px rgba(0,0,0,0.6);
        display: flex;
        flex-direction: column;
        gap: 2.5vh;
        overflow: hidden;
        z-index: 1;
        max-height: 90vh;
    }

    .fdb-panel-background {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-image: var(--fdb-bg-image-menu);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        z-index: -1;
        opacity: 0.95;
    }

    .fdb-panel-border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--fdb-accent-color);
        pointer-events: none;
        z-index: 2;
    }

    .fdb-panel-header {
        display: flex;
        flex-direction: column;
    }

    .fdb-panel-title {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-text-primary, #fff);
        font-size: 1.5rem;
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 1px;
        text-align: center;
    }

    .fdb-panel-divider {
        height: 1px;
        background-color: rgba(255, 255, 255, 0.15);
        margin-top: 1.5vh;
    }

    .fdb-panel-subtitle {
        color: var(--fdb-text-secondary, #ccc);
        margin: 0.5vh 0 0 0;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        text-align: center;
    }

    .fdb-panel-content {
        display: flex;
        flex-direction: column;
        gap: 2.7vh;
        max-height: 70vh;
        overflow-y: auto;
        padding-right: 1vh;
    }

    .fdb-panel-content::-webkit-scrollbar {
        width: 4px;
    }
    .fdb-panel-content::-webkit-scrollbar-thumb {
        background-color: rgba(255, 255, 255, 0.2);
        border-radius: 2px;
    }
</style>
