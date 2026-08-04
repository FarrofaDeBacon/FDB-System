<script>
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher();

    export let config = {};
    export let parentPath = "";

    // Retorna se o valor é primitivo
    function isPrimitive(val) {
        return val !== Object(val);
    }

    // Trata a alteração de um valor
    function handleChange(key, val) {
        const fullPath = parentPath ? `${parentPath}.${key}` : key;
        dispatch('update', { path: fullPath, value: val });
    }

    // Repassa os eventos dos filhos para cima
    function handleChildUpdate(event) {
        dispatch('update', event.detail);
    }
</script>

<style>
    .config-block {
        margin-left: 20px;
        border-left: 1px solid #444;
        padding-left: 10px;
        margin-bottom: 5px;
    }
    .config-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 5px 0;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }
    .config-key {
        font-weight: 500;
        color: #ddd;
    }
    .group-title {
        font-weight: 700;
        color: #ffcc00;
        margin-top: 10px;
        margin-bottom: 5px;
        text-transform: uppercase;
        font-size: 0.9em;
    }
    input {
        background: #222;
        border: 1px solid #555;
        color: white;
        padding: 4px 8px;
        border-radius: 4px;
        outline: none;
    }
    input:focus {
        border-color: #ffcc00;
    }
    input[type="checkbox"] {
        width: 18px;
        height: 18px;
        cursor: pointer;
    }
</style>

<div class="config-block">
    {#each Object.entries(config) as [key, value]}
        {#if isPrimitive(value)}
            <div class="config-item">
                <span class="config-key">{key}</span>
                {#if typeof value === 'boolean'}
                    <input type="checkbox" checked={value} on:change={(e) => handleChange(key, e.target.checked)} />
                {:else if typeof value === 'number'}
                    <input type="number" step="any" value={value} on:blur={(e) => handleChange(key, parseFloat(e.target.value) || 0)} />
                {:else}
                    <input type="text" value={value} on:blur={(e) => handleChange(key, e.target.value)} />
                {/if}
            </div>
        {:else}
            <div class="group-title">{key}</div>
            <svelte:self config={value} parentPath={parentPath ? `${parentPath}.${key}` : key} on:update={handleChildUpdate} />
        {/if}
    {/each}
</div>
