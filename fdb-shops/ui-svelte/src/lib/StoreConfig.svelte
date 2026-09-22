<script>
    let { store } = $props();

    // Define quais campos cada template deve exibir
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
        gunsmith: [
            { id: 'label', name: 'Armeiro', type: 'text' },
            { id: 'npc_model', name: 'Modelo NPC', type: 'text' },
            { id: 'permit_level', name: 'Nível de Permissão', type: 'number' }
        ],
        // Fallback genérico se o template não estiver mapeado acima
        default: [
            { id: 'label', name: 'Nome', type: 'text' },
            { id: 'npc_model', name: 'Modelo NPC', type: 'text' }
        ]
    };

    // Campos derivados baseados no template da loja
    let fields = $derived(templateConfig[store.template] || templateConfig.default);
</script>

<div class="store-card">
    <div class="store-header">
        <h2 class="store-title">{store.label || 'Loja Desconhecida'}</h2>
        <span class="store-badge">{store.template || 'Geral'}</span>
    </div>

    <div class="store-body">
        <p class="store-id">ID: {store.id}</p>

        <div class="form-grid">
            {#each fields as field}
                <div class="input-group">
                    <label for="{store.id}-{field.id}">{field.name}</label>
                    
                    {#if field.type === 'text'}
                        <input id="{store.id}-{field.id}" type="text" value={store[field.id] || ''} class="fdb-input" />
                    {:else if field.type === 'number'}
                        <input id="{store.id}-{field.id}" type="number" value={store[field.id] || 0} class="fdb-input" />
                    {:else if field.type === 'checkbox'}
                        <label class="checkbox-container">
                            <input id="{store.id}-{field.id}" type="checkbox" checked={store[field.id]} />
                            <span class="checkmark"></span>
                        </label>
                    {/if}
                </div>
            {/each}
        </div>
    </div>
    
    <div class="store-footer">
        <button class="fdb-btn">Salvar Alterações</button>
    </div>
</div>

<style>
    .store-card {
        background-color: var(--fdb-background-color, #1a1a1a);
        border: 2px solid var(--fdb-border-color-wood, #333);
        border-radius: var(--fdb-border-radius, 8px);
        width: 100%;
        max-width: 400px;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4);
    }

    .store-header {
        background-color: var(--fdb-background-wood, #222);
        padding: 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 2px solid var(--fdb-border-color-wood, #333);
    }

    .store-title {
        margin: 0;
        font-family: var(--fdb-font-display, serif);
        color: var(--fdb-accent-color, #ffaa00);
        font-size: 1.25rem;
    }

    .store-badge {
        background-color: var(--fdb-accent-color-dark, #cc8800);
        color: var(--fdb-text-primary, #fff);
        padding: 0.25rem 0.5rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-size: 0.75rem;
        font-weight: bold;
        text-transform: uppercase;
    }

    .store-body {
        padding: 1rem;
        flex: 1;
    }

    .store-id {
        color: var(--fdb-text-secondary, #999);
        font-size: 0.8rem;
        margin-top: 0;
        margin-bottom: 1rem;
    }

    .form-grid {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .input-group {
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
    }

    .input-group label {
        color: var(--fdb-text-secondary, #ccc);
        font-size: 0.85rem;
        font-weight: bold;
        font-family: var(--fdb-font-body, sans-serif);
    }

    .fdb-input {
        background-color: var(--fdb-background-paper, #2a2a2a);
        color: var(--fdb-text-primary, #fff);
        border: 1px solid var(--fdb-border-color, #444);
        padding: 0.5rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-family: var(--fdb-font-body, sans-serif);
        outline: none;
        transition: border-color 0.2s;
    }

    .fdb-input:focus {
        border-color: var(--fdb-accent-color, #ffaa00);
    }

    /* Checkbox simples e estilizado (opcional) */
    .checkbox-container {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
    }

    .store-footer {
        padding: 1rem;
        background-color: rgba(0, 0, 0, 0.2);
        border-top: 1px solid var(--fdb-border-color, #333);
        display: flex;
        justify-content: flex-end;
    }

    .fdb-btn {
        background-color: var(--fdb-background-wood, #333);
        color: var(--fdb-accent-color, #ffaa00);
        border: 1px solid var(--fdb-border-color-wood, #444);
        padding: 0.5rem 1rem;
        border-radius: var(--fdb-border-radius, 4px);
        font-family: var(--fdb-font-body, sans-serif);
        font-weight: bold;
        cursor: pointer;
        transition: all 0.2s;
    }

    .fdb-btn:hover {
        background-color: var(--fdb-accent-color, #ffaa00);
        color: var(--fdb-text-on-paper, #000);
    }
</style>
