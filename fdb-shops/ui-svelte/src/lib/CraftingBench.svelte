<script>
    import { onMount } from 'svelte';

    let { craftData, onClose = () => {} } = $props();

    let shopId = $state(craftData.shopId || '');
    let stationId = $state(craftData.stationId || '');
    let stationLabel = $state(craftData.stationLabel || 'Bancada de Trabalho');
    let recipes = $state(craftData.recipes || []);
    let inventory = $state(craftData.inventory || {}); // Map of { [itemName]: count }

    let searchQuery = $state('');
    let selectedCategory = $state('all');
    let selectedRecipe = $state(recipes.length > 0 ? recipes[0] : null);
    let craftMultiplier = $state(1);

    // Crafting progress state
    let isCrafting = $state(false);
    let craftProgress = $state(0);
    let craftTimerInterval = null;
    let statusMessage = $state({ text: '', type: '' });

    // Categories derived
    let categories = $derived([
        'all',
        ...Array.from(new Set(recipes.map(r => r.category || 'artesanato'))).filter(Boolean)
    ]);

    // Filter recipes
    let filteredRecipes = $derived(
        recipes.filter(r => {
            const matchesCat = selectedCategory === 'all' || (r.category || 'artesanato') === selectedCategory;
            const q = searchQuery.trim().toLowerCase();
            const matchesSearch = !q || 
                (r.label && r.label.toLowerCase().includes(q)) || 
                (r.id && r.id.toLowerCase().includes(q)) || 
                (r.result && r.result.toLowerCase().includes(q));
            return matchesCat && matchesSearch;
        })
    );

    function getItemCount(itemName) {
        return inventory[itemName] || 0;
    }

    function hasAllIngredients(recipe, multiplier = 1) {
        if (!recipe || !recipe.ingredients) return false;
        for (const ing of recipe.ingredients) {
            const needed = (ing.amount || 1) * multiplier;
            if (getItemCount(ing.name) < needed) {
                return false;
            }
        }
        return true;
    }

    function getItemImageUrl(itemName) {
        return `nui://fdb-inventory/html/images/${itemName}.png`;
    }

    function selectRecipe(r) {
        if (isCrafting) return;
        selectedRecipe = r;
        craftMultiplier = 1;
        statusMessage = { text: '', type: '' };
    }

    async function startCrafting() {
        if (!selectedRecipe || isCrafting) return;
        if (!hasAllIngredients(selectedRecipe, craftMultiplier)) {
            statusMessage = { text: 'Materiais insuficientes para fabricação!', type: 'error' };
            return;
        }

        isCrafting = true;
        craftProgress = 0;
        statusMessage = { text: 'Preparando materiais e ferramentas...', type: 'info' };

        try {
            const res = await fetch(`https://${window.GetParentResourceName()}/startCraft`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: shopId,
                    stationId: stationId,
                    recipeId: selectedRecipe.id,
                    multiplier: craftMultiplier
                })
            });

            const data = await res.json();
            if (data && data.success) {
                const totalDuration = (selectedRecipe.time || 5000) * craftMultiplier;
                const updateStepMs = 100;
                const totalSteps = totalDuration / updateStepMs;
                let currentStep = 0;

                statusMessage = { text: 'Fabricando item na bancada...', type: 'info' };

                craftTimerInterval = setInterval(() => {
                    currentStep++;
                    craftProgress = Math.min(100, Math.round((currentStep / totalSteps) * 100));

                    if (currentStep >= totalSteps) {
                        clearInterval(craftTimerInterval);
                        finalizeCraft();
                    }
                }, updateStepMs);
            } else {
                statusMessage = { text: data.message || 'Não foi possível iniciar a fabricação.', type: 'error' };
                isCrafting = false;
            }
        } catch (err) {
            statusMessage = { text: 'Erro ao comunicar com a bancada.', type: 'error' };
            isCrafting = false;
        }
    }

    async function finalizeCraft() {
        try {
            const res = await fetch(`https://${window.GetParentResourceName()}/completeCraft`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: shopId,
                    stationId: stationId,
                    recipeId: selectedRecipe.id,
                    multiplier: craftMultiplier
                })
            });

            const data = await res.json();
            if (data && data.success) {
                statusMessage = { text: 'Item fabricado com sucesso!', type: 'success' };
                // Deduct ingredients locally
                if (selectedRecipe && selectedRecipe.ingredients) {
                    for (const ing of selectedRecipe.ingredients) {
                        const needed = (ing.amount || 1) * craftMultiplier;
                        inventory[ing.name] = Math.max(0, (inventory[ing.name] || 0) - needed);
                    }
                    inventory = { ...inventory };
                }
            } else {
                statusMessage = { text: data.message || 'Falha ao concluir fabricação.', type: 'error' };
            }
        } catch (err) {
            statusMessage = { text: 'Erro ao registrar item fabricado.', type: 'error' };
        } finally {
            isCrafting = false;
            craftProgress = 0;
        }
    }

    function cancelCraft() {
        if (craftTimerInterval) clearInterval(craftTimerInterval);
        isCrafting = false;
        craftProgress = 0;
        statusMessage = { text: 'Fabricação cancelada.', type: 'error' };
    }

    function closeBench() {
        if (isCrafting) {
            cancelCraft();
        }
        fetch(`https://${window.GetParentResourceName()}/closeCraftMenu`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(() => {});
        onClose();
    }

    function handleKeyDown(e) {
        if (e.key === 'Escape') {
            closeBench();
        }
    }

    onMount(() => {
        window.addEventListener('keydown', handleKeyDown);
        return () => {
            window.removeEventListener('keydown', handleKeyDown);
            if (craftTimerInterval) clearInterval(craftTimerInterval);
        };
    });
</script>

<div class="craft-container" role="dialog" aria-modal="true">
    <div class="craft-card">
        <div class="craft-background"></div>
        <div class="craft-border-overlay"></div>

        <!-- Header -->
        <div class="craft-header">
            <div class="craft-title-area">
                <span class="craft-badge">Oficina & Manufatura</span>
                <h1 class="craft-title">{stationLabel}</h1>
            </div>

            <button class="craft-close-btn" onclick={closeBench} type="button" title="Fechar (ESC)">✕</button>
        </div>

        <div class="craft-divider"></div>

        <!-- Main Body -->
        <div class="craft-body">
            <!-- Left Sidebar: Recipe List -->
            <div class="recipes-sidebar">
                <div class="recipes-toolbar">
                    <div class="recipes-search">
                        <span class="search-icon">🔍</span>
                        <input 
                            type="text" 
                            placeholder="Buscar receitas..." 
                            bind:value={searchQuery}
                            class="search-input"
                        />
                    </div>

                    <div class="cat-bar">
                        {#each categories as cat}
                            <button 
                                class="cat-pill" 
                                class:active={selectedCategory === cat}
                                onclick={() => selectedCategory = cat}
                                type="button"
                            >
                                {cat === 'all' ? 'Todas' : cat.toUpperCase()}
                            </button>
                        {/each}
                    </div>
                </div>

                <div class="recipes-list-scroll">
                    {#if filteredRecipes.length === 0}
                        <div class="empty-recipes">
                            <p>Nenhuma receita disponível nesta bancada.</p>
                        </div>
                    {:else}
                        <div class="recipes-list">
                            {#each filteredRecipes as recipe (recipe.id)}
                                {@const canCraft = hasAllIngredients(recipe, 1)}
                                <div 
                                    class="recipe-list-item" 
                                    class:selected={selectedRecipe && selectedRecipe.id === recipe.id}
                                    class:missing-materials={!canCraft}
                                    onclick={() => selectRecipe(recipe)}
                                    role="button"
                                    tabindex="0"
                                    onkeydown={(e) => { if (e.key === 'Enter') selectRecipe(recipe); }}
                                >
                                    <div class="recipe-thumb">
                                        <img 
                                            src={getItemImageUrl(recipe.result || recipe.id)} 
                                            alt={recipe.label}
                                            onerror={(e) => { e.currentTarget.style.display = 'none'; }}
                                        />
                                        <span class="fallback-icon">🔨</span>
                                    </div>

                                    <div class="recipe-item-info">
                                        <span class="recipe-label">{recipe.label || recipe.id}</span>
                                        <div class="recipe-meta-row">
                                            <span class="recipe-time">⏱️ {Math.round((recipe.time || 5000) / 1000)}s</span>
                                            <span class="recipe-yield">x{recipe.amount || 1}</span>
                                        </div>
                                    </div>

                                    <div class="recipe-status-indicator">
                                        {#if canCraft}
                                            <span class="badge-ready" title="Pronto para fabricar">✓</span>
                                        {:else}
                                            <span class="badge-missing" title="Faltam materiais">!</span>
                                        {/if}
                                    </div>
                                </div>
                            {/each}
                        </div>
                    {/if}
                </div>
            </div>

            <!-- Right Area: Selected Recipe Details & Crafting Action -->
            <div class="recipe-detail-panel">
                {#if selectedRecipe}
                    {@const canCraftCurrent = hasAllIngredients(selectedRecipe, craftMultiplier)}
                    
                    <div class="detail-content-scroll">
                        <!-- Product Showcase Header -->
                        <div class="product-showcase">
                            <div class="showcase-thumb">
                                <img 
                                    src={getItemImageUrl(selectedRecipe.result || selectedRecipe.id)} 
                                    alt={selectedRecipe.label}
                                    onerror={(e) => { e.currentTarget.style.display = 'none'; }}
                                />
                                <span class="showcase-fallback">🛠️</span>
                            </div>

                            <div class="showcase-info">
                                <span class="showcase-tag">Item Produzido</span>
                                <h2 class="showcase-title">{selectedRecipe.label || selectedRecipe.id}</h2>
                                {#if selectedRecipe.description}
                                    <p class="showcase-desc">{selectedRecipe.description}</p>
                                {/if}
                                <div class="showcase-stats">
                                    <span class="stat-item">Rendimento: <strong>x{(selectedRecipe.amount || 1) * craftMultiplier}</strong></span>
                                    <span class="stat-item">Tempo: <strong>{Math.round(((selectedRecipe.time || 5000) * craftMultiplier) / 1000)}s</strong></span>
                                </div>
                            </div>
                        </div>

                        <div class="detail-divider"></div>

                        <!-- Ingredients Section -->
                        <div class="ingredients-section">
                            <h3 class="section-title">Materiais Necessários</h3>
                            
                            <div class="ingredients-grid">
                                {#each selectedRecipe.ingredients || [] as ing (ing.name)}
                                    {@const available = getItemCount(ing.name)}
                                    {@const needed = (ing.amount || 1) * craftMultiplier}
                                    {@const hasEnough = available >= needed}

                                    <div class="ingredient-card" class:has-enough={hasEnough} class:missing={!hasEnough}>
                                        <div class="ing-thumb">
                                            <img 
                                                src={getItemImageUrl(ing.name)} 
                                                alt={ing.label || ing.name}
                                                onerror={(e) => { e.currentTarget.style.display = 'none'; }}
                                            />
                                            <span class="ing-fallback">📦</span>
                                        </div>

                                        <div class="ing-info">
                                            <span class="ing-name" title={ing.label || ing.name}>{ing.label || ing.name}</span>
                                            <div class="ing-count-row">
                                                <span class="ing-available" class:text-green={hasEnough} class:text-red={!hasEnough}>
                                                    {available}
                                                </span>
                                                <span class="ing-slash">/</span>
                                                <span class="ing-needed">{needed}</span>
                                            </div>
                                        </div>

                                        <div class="ing-progress-bg">
                                            <div 
                                                class="ing-progress-fill" 
                                                style="width: {Math.min(100, Math.round((available / needed) * 100))}%;"
                                                class:bg-green={hasEnough}
                                                class:bg-red={!hasEnough}
                                            ></div>
                                        </div>
                                    </div>
                                {/each}
                            </div>
                        </div>
                    </div>

                    <!-- Craft Action Bar & Multiplier -->
                    <div class="craft-action-panel">
                        {#if statusMessage.text}
                            <div class="status-msg {statusMessage.type}">
                                {statusMessage.text}
                            </div>
                        {/if}

                        {#if isCrafting}
                            <div class="crafting-progress-area">
                                <div class="progress-bar-wrap">
                                    <div class="progress-bar-fill" style="width: {craftProgress}%;"></div>
                                </div>
                                <div class="progress-meta">
                                    <span>Fabricando...</span>
                                    <span>{craftProgress}%</span>
                                </div>
                                <button class="btn-cancel-craft" onclick={cancelCraft} type="button">Cancelar Fabricação</button>
                            </div>
                        {:else}
                            <div class="craft-controls-row">
                                <div class="multiplier-box">
                                    <span class="multiplier-label">Quantidade:</span>
                                    <div class="multiplier-pills">
                                        {#each [1, 5, 10] as mult}
                                            <button 
                                                class="mult-pill" 
                                                class:active={craftMultiplier === mult}
                                                onclick={() => craftMultiplier = mult}
                                                type="button"
                                            >
                                                {mult}x
                                            </button>
                                        {/each}
                                    </div>
                                </div>

                                <button 
                                    class="btn-craft-submit" 
                                    disabled={!canCraftCurrent}
                                    onclick={startCrafting}
                                    type="button"
                                >
                                    {#if canCraftCurrent}
                                        Fabricar Item ({craftMultiplier}x)
                                    {:else}
                                        Materiais Insuficientes
                                    {/if}
                                </button>
                            </div>
                        {/if}
                    </div>
                {:else}
                    <div class="no-recipe-selected">
                        <span class="no-recipe-icon">🔨</span>
                        <p>Selecione uma receita na lista à esquerda para começar a fabricar.</p>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<style>
    .craft-container {
        position: fixed;
        top: 0; left: 0;
        width: 100vw; height: 100vh;
        background: rgba(0, 0, 0, 0.75);
        backdrop-filter: blur(5px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        font-family: var(--fdb-font-family, 'Outfit', 'Inter', sans-serif);
        user-select: none;
    }

    .craft-card {
        position: relative;
        width: 1050px;
        max-width: 95vw;
        height: 85vh;
        max-height: 850px;
        background-color: var(--fdb-background-color, #1a1512);
        border: 1px solid var(--fdb-border-color, #4a3828);
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.9);
        overflow: hidden;
        border-radius: 4px;
    }

    .craft-background {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: var(--fdb-bg-image-menu, none);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        opacity: 0.95;
        z-index: 0;
        pointer-events: none;
    }

    .craft-border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--fdb-accent-color, #d4a373);
        pointer-events: none;
        z-index: 1;
    }

    .craft-header {
        position: relative;
        z-index: 2;
        padding: 1.25rem 2rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .craft-title-area {
        display: flex;
        flex-direction: column;
        gap: 0.2rem;
    }

    .craft-badge {
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: var(--fdb-accent-color, #d4a373);
        font-weight: 600;
    }

    .craft-title {
        font-size: 1.6rem;
        font-weight: 800;
        color: var(--fdb-text-color, #f4ede4);
        margin: 0;
        letter-spacing: 0.04em;
    }

    .craft-close-btn {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        font-size: 1.35rem;
        cursor: pointer;
        padding: 0.3rem 0.6rem;
        transition: color 0.15s ease;
    }

    .craft-close-btn:hover {
        color: #ff6b6b;
    }

    .craft-divider {
        position: relative;
        z-index: 2;
        height: 1px;
        background: linear-gradient(90deg, transparent, var(--fdb-border-color, #4a3828) 20%, var(--fdb-border-color, #4a3828) 80%, transparent);
        margin: 0;
    }

    .craft-body {
        position: relative;
        z-index: 2;
        flex: 1;
        display: flex;
        overflow: hidden;
    }

    /* Left Sidebar: Recipes */
    .recipes-sidebar {
        width: 380px;
        display: flex;
        flex-direction: column;
        border-right: 1px solid var(--fdb-border-color, #4a3828);
        background: rgba(0, 0, 0, 0.2);
    }

    .recipes-toolbar {
        padding: 1rem 1.25rem;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        background: rgba(0, 0, 0, 0.2);
    }

    .recipes-search {
        display: flex;
        align-items: center;
        background: rgba(0, 0, 0, 0.4);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0 0.75rem;
    }

    .search-icon {
        opacity: 0.6;
        margin-right: 0.5rem;
    }

    .search-input {
        width: 100%;
        background: transparent;
        border: none;
        color: var(--fdb-text-color, #f4ede4);
        padding: 0.6rem 0;
        font-size: 0.9rem;
        outline: none;
    }

    .cat-bar {
        display: flex;
        gap: 0.4rem;
        overflow-x: auto;
    }

    .cat-pill {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: var(--fdb-text-secondary, #a89886);
        padding: 0.25rem 0.65rem;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.15s ease;
        white-space: nowrap;
    }

    .cat-pill.active, .cat-pill:hover {
        background: var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        border-color: var(--fdb-accent-color, #d4a373);
    }

    .recipes-list-scroll {
        flex: 1;
        overflow-y: auto;
        padding: 0.75rem 1rem;
    }

    .recipes-list-scroll::-webkit-scrollbar {
        width: 5px;
    }

    .recipes-list-scroll::-webkit-scrollbar-thumb {
        background: var(--fdb-border-color, #4a3828);
        border-radius: 3px;
    }

    .recipes-list {
        display: flex;
        flex-direction: column;
        gap: 0.65rem;
    }

    .recipe-list-item {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        background: rgba(0, 0, 0, 0.35);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0.65rem 0.85rem;
        cursor: pointer;
        transition: all 0.18s ease;
    }

    .recipe-list-item:hover {
        border-color: var(--fdb-accent-color, #d4a373);
        background: rgba(212, 163, 115, 0.08);
    }

    .recipe-list-item.selected {
        border-color: var(--fdb-accent-color, #d4a373);
        background: rgba(212, 163, 115, 0.15);
        box-shadow: 0 0 10px rgba(212, 163, 115, 0.2);
    }

    .recipe-list-item.missing-materials {
        opacity: 0.7;
    }

    .recipe-thumb {
        position: relative;
        width: 42px;
        height: 42px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, 0.35);
        border-radius: 4px;
        border: 1px solid rgba(255, 255, 255, 0.05);
        flex-shrink: 0;
    }

    .recipe-thumb img {
        max-width: 36px;
        max-height: 36px;
        object-fit: contain;
        position: relative;
        z-index: 2;
    }

    .fallback-icon {
        position: absolute;
        font-size: 1.2rem;
        opacity: 0.35;
        z-index: 1;
    }

    .recipe-item-info {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 0.2rem;
        overflow: hidden;
    }

    .recipe-label {
        font-size: 0.9rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .recipe-meta-row {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        font-size: 0.75rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .recipe-status-indicator {
        flex-shrink: 0;
    }

    .badge-ready {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 22px;
        height: 22px;
        background: rgba(16, 185, 129, 0.2);
        color: #10b981;
        border: 1px solid #10b981;
        border-radius: 50%;
        font-size: 0.8rem;
        font-weight: 800;
    }

    .badge-missing {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 22px;
        height: 22px;
        background: rgba(239, 68, 68, 0.2);
        color: #ef4444;
        border: 1px solid #ef4444;
        border-radius: 50%;
        font-size: 0.8rem;
        font-weight: 800;
    }

    /* Right Panel */
    .recipe-detail-panel {
        flex: 1;
        display: flex;
        flex-direction: column;
        overflow: hidden;
        background: rgba(0, 0, 0, 0.15);
    }

    .detail-content-scroll {
        flex: 1;
        overflow-y: auto;
        padding: 1.5rem 2rem;
        display: flex;
        flex-direction: column;
        gap: 1.5rem;
    }

    .product-showcase {
        display: flex;
        align-items: center;
        gap: 1.5rem;
    }

    .showcase-thumb {
        position: relative;
        width: 90px;
        height: 90px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, 0.4);
        border: 2px solid var(--fdb-accent-color, #d4a373);
        border-radius: 6px;
        flex-shrink: 0;
    }

    .showcase-thumb img {
        max-width: 76px;
        max-height: 76px;
        object-fit: contain;
        position: relative;
        z-index: 2;
    }

    .showcase-fallback {
        position: absolute;
        font-size: 2.2rem;
        opacity: 0.4;
        z-index: 1;
    }

    .showcase-info {
        display: flex;
        flex-direction: column;
        gap: 0.35rem;
    }

    .showcase-tag {
        font-size: 0.75rem;
        text-transform: uppercase;
        color: var(--fdb-accent-color, #d4a373);
        font-weight: 700;
    }

    .showcase-title {
        font-size: 1.5rem;
        font-weight: 800;
        color: var(--fdb-text-color, #f4ede4);
        margin: 0;
    }

    .showcase-desc {
        font-size: 0.85rem;
        color: var(--fdb-text-secondary, #a89886);
        margin: 0;
        line-height: 1.4;
    }

    .showcase-stats {
        display: flex;
        gap: 1.5rem;
        margin-top: 0.3rem;
    }

    .stat-item {
        font-size: 0.85rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .stat-item strong {
        color: var(--fdb-accent-color, #d4a373);
    }

    .detail-divider {
        height: 1px;
        background: rgba(255, 255, 255, 0.08);
        margin: 0;
    }

    .ingredients-section {
        display: flex;
        flex-direction: column;
        gap: 0.85rem;
    }

    .section-title {
        font-size: 1rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .ingredients-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        gap: 0.85rem;
    }

    .ingredient-card {
        position: relative;
        background: rgba(0, 0, 0, 0.35);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0.75rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        overflow: hidden;
    }

    .ingredient-card.missing {
        border-color: rgba(239, 68, 68, 0.5);
    }

    .ingredient-card.has-enough {
        border-color: rgba(16, 185, 129, 0.4);
    }

    .ing-thumb {
        position: relative;
        width: 38px;
        height: 38px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, 0.3);
        border-radius: 4px;
        flex-shrink: 0;
        z-index: 2;
    }

    .ing-thumb img {
        max-width: 32px;
        max-height: 32px;
        object-fit: contain;
        position: relative;
        z-index: 2;
    }

    .ing-fallback {
        position: absolute;
        font-size: 1rem;
        opacity: 0.35;
        z-index: 1;
    }

    .ing-info {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 0.15rem;
        z-index: 2;
    }

    .ing-name {
        font-size: 0.85rem;
        font-weight: 600;
        color: var(--fdb-text-color, #f4ede4);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .ing-count-row {
        display: flex;
        align-items: baseline;
        gap: 0.25rem;
        font-size: 0.85rem;
        font-weight: 700;
    }

    .text-green { color: #10b981; }
    .text-red { color: #ef4444; }
    .ing-slash { opacity: 0.5; color: var(--fdb-text-secondary, #a89886); }
    .ing-needed { color: var(--fdb-text-color, #f4ede4); }

    .ing-progress-bg {
        position: absolute;
        bottom: 0; left: 0;
        width: 100%; height: 3px;
        background: rgba(255, 255, 255, 0.08);
        z-index: 1;
    }

    .ing-progress-fill {
        height: 100%;
        transition: width 0.3s ease;
    }

    .bg-green { background: #10b981; }
    .bg-red { background: #ef4444; }

    /* Action Panel */
    .craft-action-panel {
        padding: 1.25rem 2rem;
        background: rgba(0, 0, 0, 0.35);
        border-top: 1px solid var(--fdb-border-color, #4a3828);
        display: flex;
        flex-direction: column;
        gap: 0.85rem;
    }

    .status-msg {
        padding: 0.5rem 0.75rem;
        border-radius: 4px;
        font-size: 0.85rem;
        font-weight: 600;
        text-align: center;
    }

    .status-msg.info { background: rgba(59, 130, 246, 0.2); color: #93c5fd; border: 1px solid #3b82f6; }
    .status-msg.success { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; border: 1px solid #10b981; }
    .status-msg.error { background: rgba(239, 68, 68, 0.2); color: #fca5a5; border: 1px solid #ef4444; }

    .crafting-progress-area {
        display: flex;
        flex-direction: column;
        gap: 0.6rem;
    }

    .progress-bar-wrap {
        width: 100%;
        height: 12px;
        background: rgba(0, 0, 0, 0.5);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 6px;
        overflow: hidden;
    }

    .progress-bar-fill {
        height: 100%;
        background: linear-gradient(90deg, #d4a373, #e5b98f);
        transition: width 0.1s linear;
        box-shadow: 0 0 10px rgba(212, 163, 115, 0.5);
    }

    .progress-meta {
        display: flex;
        justify-content: space-between;
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--fdb-accent-color, #d4a373);
    }

    .btn-cancel-craft {
        background: transparent;
        border: 1px solid #ef4444;
        color: #ef4444;
        padding: 0.45rem 1rem;
        border-radius: 4px;
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
        margin-top: 0.25rem;
    }

    .btn-cancel-craft:hover {
        background: rgba(239, 68, 68, 0.15);
    }

    .craft-controls-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1.5rem;
    }

    .multiplier-box {
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }

    .multiplier-label {
        font-size: 0.85rem;
        color: var(--fdb-text-secondary, #a89886);
        font-weight: 600;
    }

    .multiplier-pills {
        display: flex;
        gap: 0.35rem;
    }

    .mult-pill {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid var(--fdb-border-color, #4a3828);
        color: var(--fdb-text-secondary, #a89886);
        padding: 0.35rem 0.75rem;
        border-radius: 4px;
        font-size: 0.85rem;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .mult-pill.active, .mult-pill:hover {
        background: var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        border-color: var(--fdb-accent-color, #d4a373);
    }

    .btn-craft-submit {
        flex: 1;
        background: var(--fdb-accent-color, #d4a373);
        border: 1px solid var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        padding: 0.85rem 1.5rem;
        border-radius: 4px;
        font-size: 1rem;
        font-weight: 800;
        letter-spacing: 0.03em;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-craft-submit:hover:not(:disabled) {
        filter: brightness(1.15);
        box-shadow: 0 0 15px rgba(212, 163, 115, 0.4);
    }

    .btn-craft-submit:disabled {
        opacity: 0.4;
        cursor: not-allowed;
        background: #333;
        border-color: #444;
        color: #777;
    }

    .no-recipe-selected {
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
        padding: 3rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .no-recipe-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.4;
    }
</style>
