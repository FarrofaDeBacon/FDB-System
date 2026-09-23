<script>
    let { store, onClose } = $props();

    const templateConfig = {
        general: [
            { id: 'label', name: 'Nome da Loja', type: 'text' },
            { id: 'npc_model', name: 'Modelo do NPC', type: 'text' },
            { id: 'stock_limit', name: 'Limite de Estoque', type: 'number' }
        ],
        saloon: [
            { id: 'label', name: 'Nome do Saloon', type: 'text' },
            { id: 'npc_model', name: 'Bartender', type: 'text' },
            { id: 'drinks_license', name: 'Licença de Bebidas', type: 'checkbox' }
        ],
        weapons: [
            { id: 'label', name: 'Armeiro', type: 'text' },
            { id: 'npc_model', name: 'Modelo NPC', type: 'text' },
            { id: 'permit_level', name: 'Nível de Permissão', type: 'number' }
        ],
        default: [
            { id: 'label', name: 'Nome', type: 'text' },
            { id: 'npc_model', name: 'Modelo NPC', type: 'text' }
        ]
    };

    let fields = $derived(templateConfig[store.template] || templateConfig.default);

    function placeObject(field) {
        if (!store.id || !store[field.id]) {
            alert("Preencha o modelo antes de posicionar!");
            return;
        }
        
        fetch(`https://${window.GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                type: field.id === 'npc_model' ? 'npc' : 'prop',
                model: store[field.id],
                shopId: store.id
            })
        });
    }

    function saveConfig() {
        fetch(`https://${window.GetParentResourceName()}/saveStoreConfig`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ store })
        }).then(() => {
            onClose();
        });
    }
</script>

<div class="theme-test-card">
    <div class="header">
        <h1>{store.label || store.id}</h1>
        <p>Editando Template: {store.template}</p>
    </div>

    <div class="form-grid">
        <div class="input-group">
            <label>ID da Loja (Somente Leitura)</label>
            <input type="text" value={store.id} disabled class="fdb-input disabled" />
        </div>

        {#each fields as field}
            <div class="input-group">
                <label for="{store.id}-{field.id}">{field.name}</label>
                
                {#if field.type === 'text'}
                    <div style="display: flex; gap: 0.5rem; width: 100%;">
                        <input id="{store.id}-{field.id}" type="text" value={store[field.id] || ''} on:input={(e) => store[field.id] = e.target.value} class="fdb-input" style="flex: 1;" />
                        {#if field.id === 'npc_model' || field.id === 'register_model'}
                            <button class="test-button submit" style="padding: 0.5rem 1rem; font-size: 0.9rem;" on:click={() => placeObject(field)}>
                                Posicionar
                            </button>
                        {/if}
                    </div>
                {:else if field.type === 'number'}
                    <input id="{store.id}-{field.id}" type="number" value={store[field.id] || 0} on:input={(e) => store[field.id] = parseFloat(e.target.value)} class="fdb-input" />
                {:else if field.type === 'checkbox'}
                    <label class="checkbox-container">
                        <input id="{store.id}-{field.id}" type="checkbox" checked={store[field.id]} on:change={(e) => store[field.id] = e.target.checked} />
                        <span class="checkmark">Sim / Ativo</span>
                    </label>
                {/if}
            </div>
        {/each}
    </div>

    <div class="footer">
        <button class="test-button submit" on:click={saveConfig}>Salvar Alterações</button>
        <button class="test-button cancel" on:click={onClose}>Fechar (ESC)</button>
    </div>
</div>

<style>
    /* Usando exatamente o CSS do Theme Test original */
    .theme-test-card {
        background-color: var(--fdb-background-color, #1a1a1a);
        color: var(--fdb-text-primary, #ffffff);
        padding: 2rem;
        border: 2px solid var(--fdb-border-color-wood, #555);
        border-radius: var(--fdb-border-radius, 8px);
        width: 500px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    }

    .header {
        text-align: center;
        margin-bottom: 2rem;
    }

    h1 {
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-accent-color, #ffaa00);
        margin-top: 0;
        margin-bottom: 0.5rem;
    }

    p {
        color: var(--fdb-text-secondary, #ccc);
        margin: 0;
        font-size: 0.9rem;
    }

    .form-grid {
        display: flex;
        flex-direction: column;
        gap: 1.5rem;
        margin-bottom: 2rem;
    }

    .input-group {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        text-align: left;
    }

    .input-group label {
        color: var(--fdb-text-secondary, #ccc);
        font-size: 0.85rem;
        font-weight: bold;
    }

    .fdb-input {
        background-color: rgba(0, 0, 0, 0.2);
        color: var(--fdb-text-primary, #fff);
        border: 1px solid var(--fdb-border-color-wood, #444);
        padding: 0.75rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-family: var(--fdb-font-body, sans-serif);
        outline: none;
        transition: border-color 0.2s;
    }

    .fdb-input:focus {
        border-color: var(--fdb-accent-color, #ffaa00);
    }

    .fdb-input.disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .checkbox-container {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
        color: var(--fdb-text-primary, #fff);
    }

    .footer {
        display: flex;
        justify-content: center;
        gap: 1rem;
    }

    .test-button {
        padding: 0.75rem 1.5rem;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        font-family: var(--fdb-font-display, serif);
        font-size: 1.1rem;
        transition: all 0.2s;
        border: 1px solid transparent;
    }

    .test-button.submit {
        background-color: var(--fdb-accent-color-dark, #cc8800);
        color: var(--fdb-text-primary, #fff);
        border-color: var(--fdb-accent-color, #ffaa00);
    }

    .test-button.submit:hover {
        background-color: var(--fdb-accent-color, #ffaa00);
    }

    .test-button.cancel {
        background-color: transparent;
        color: var(--fdb-status-critical, #cc0000);
        border-color: var(--fdb-status-critical, #cc0000);
    }

    .test-button.cancel:hover {
        background-color: var(--fdb-status-critical, #cc0000);
        color: #fff;
    }
</style>
