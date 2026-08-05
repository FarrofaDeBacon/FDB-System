<script>
    export let label = '';
</script>

<div class="separator-container">
    <div class="line"></div>
    {#if label}
        <span class="label">{label}</span>
        <div class="line"></div>
    {/if}
</div>

<style>
    .separator-container {
        display: flex;
        align-items: center;
        width: 100%;
        margin: 1vh 0;
        gap: 1.5vh;
    }

    .line {
        flex: 1;
        height: 1px;
        background: linear-gradient(90deg, transparent, var(--fdb-border-color), transparent);
    }

    .label {
        font-family: var(--fdb-font-display);
        color: var(--fdb-accent-color);
        font-size: 1.1rem;
        text-transform: uppercase;
        letter-spacing: 2px;
        white-space: nowrap;
    }
</style>
