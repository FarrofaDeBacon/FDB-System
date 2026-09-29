<script>
    import { onMount } from 'svelte';

    let { shopData, onClose = () => {} } = $props();

    let shopId = $state(shopData.shopId || '');
    let shopLabel = $state(shopData.shopLabel || 'Armazém');
    let catalog = $state(shopData.catalog || []);
    let playerMoney = $state(shopData.playerMoney || { cash: 0, bank: 0 });

    let searchQuery = $state('');
    let selectedCategory = $state('all');
    let paymentMethod = $state('cash'); // 'cash' | 'bank'
    let isProcessing = $state(false);
    let checkoutMessage = $state({ text: '', type: '' });

    // Cart: array of { item_name, label, image, price, amount }
    let cart = $state([]);

    // Extract categories
    let categories = $derived([
        'all',
        ...Array.from(new Set(catalog.map(i => i.type || i.category || 'produtos'))).filter(Boolean)
    ]);

    // Filter catalog
    let filteredCatalog = $derived(
        catalog.filter(item => {
            const matchesCat = selectedCategory === 'all' || (item.type || item.category || 'produtos') === selectedCategory;
            const q = searchQuery.trim().toLowerCase();
            const matchesSearch = !q || 
                (item.label && item.label.toLowerCase().includes(q)) || 
                (item.item_name && item.item_name.toLowerCase().includes(q));
            return matchesCat && matchesSearch;
        })
    );

    // Cart calculations
    let totalItemsCount = $derived(cart.reduce((sum, item) => sum + item.amount, 0));
    let totalCartPrice = $derived(cart.reduce((sum, item) => sum + (item.price * item.amount), 0));
    
    let canAfford = $derived(
        paymentMethod === 'cash' 
            ? playerMoney.cash >= totalCartPrice 
            : playerMoney.bank >= totalCartPrice
    );

    function getItemImageUrl(item) {
        if (item.image) {
            return `nui://fdb-inventory/html/images/${item.image}`;
        }
        return `nui://fdb-inventory/html/images/${item.item_name || item.name}.png`;
    }

    function addToCart(item, amount = 1) {
        const existing = cart.find(c => c.item_name === (item.item_name || item.name));
        if (existing) {
            existing.amount += amount;
            cart = [...cart];
        } else {
            cart.push({
                item_name: item.item_name || item.name,
                label: item.label || item.item_name || item.name,
                image: item.image,
                price: Number(item.price) || 0,
                amount: amount
            });
            cart = [...cart];
        }
    }

    function updateCartAmount(itemName, delta) {
        const item = cart.find(c => c.item_name === itemName);
        if (!item) return;
        
        item.amount += delta;
        if (item.amount <= 0) {
            cart = cart.filter(c => c.item_name !== itemName);
        } else {
            cart = [...cart];
        }
    }

    function removeFromCart(itemName) {
        cart = cart.filter(c => c.item_name !== itemName);
    }

    function clearCart() {
        cart = [];
    }

    async function handleCheckout() {
        if (cart.length === 0 || isProcessing) return;
        if (!canAfford) {
            checkoutMessage = { 
                text: paymentMethod === 'cash' ? 'Dinheiro em mãos insuficiente!' : 'Saldo bancário insuficiente!', 
                type: 'error' 
            };
            return;
        }

        isProcessing = true;
        checkoutMessage = { text: 'Processando compra...', type: 'info' };

        try {
            const res = await fetch(`https://${window.GetParentResourceName()}/checkoutCustomerShop`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: shopId,
                    paymentMethod: paymentMethod,
                    cart: cart
                })
            });

            const data = await res.json();
            if (data && data.success) {
                checkoutMessage = { text: 'Compra realizada com sucesso!', type: 'success' };
                // Update local money
                if (paymentMethod === 'cash') {
                    playerMoney.cash = Math.max(0, playerMoney.cash - totalCartPrice);
                } else {
                    playerMoney.bank = Math.max(0, playerMoney.bank - totalCartPrice);
                }
                cart = [];
                setTimeout(() => {
                    checkoutMessage = { text: '', type: '' };
                }, 3000);
            } else {
                checkoutMessage = { text: data.message || 'Falha ao processar pagamento.', type: 'error' };
            }
        } catch (err) {
            checkoutMessage = { text: 'Erro na comunicação com o servidor.', type: 'error' };
        } finally {
            isProcessing = false;
        }
    }

    function handleKeyDown(e) {
        if (e.key === 'Escape') {
            closeShop();
        }
    }

    function closeShop() {
        fetch(`https://${window.GetParentResourceName()}/closeCustomerShop`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(() => {});
        onClose();
    }

    onMount(() => {
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });
</script>

<div class="storefront-container" role="dialog" aria-modal="true">
    <div class="storefront-card">
        <div class="storefront-background"></div>
        <div class="storefront-border-overlay"></div>

        <!-- Top Header Bar -->
        <div class="storefront-header">
            <div class="storefront-title-area">
                <span class="storefront-badge">Estabelecimento Comercial</span>
                <h1 class="storefront-title">{shopLabel}</h1>
            </div>

            <!-- Player Wallet Status -->
            <div class="player-wallet-bar">
                <div class="wallet-pill cash-pill" class:active={paymentMethod === 'cash'} onclick={() => paymentMethod = 'cash'}>
                    <span class="wallet-icon">💵</span>
                    <div class="wallet-info">
                        <span class="wallet-label">Em mãos</span>
                        <span class="wallet-value">${playerMoney.cash.toFixed(2)}</span>
                    </div>
                </div>

                <div class="wallet-pill bank-pill" class:active={paymentMethod === 'bank'} onclick={() => paymentMethod = 'bank'}>
                    <span class="wallet-icon">🏦</span>
                    <div class="wallet-info">
                        <span class="wallet-label">Banco</span>
                        <span class="wallet-value">${playerMoney.bank.toFixed(2)}</span>
                    </div>
                </div>

                <button class="storefront-close-btn" onclick={closeShop} type="button" title="Fechar (ESC)">✕</button>
            </div>
        </div>

        <div class="storefront-divider"></div>

        <!-- Main Body: Catalog & Cart -->
        <div class="storefront-body">
            <!-- Catalog Section (Left / Center) -->
            <div class="catalog-section">
                <!-- Search & Filters -->
                <div class="catalog-toolbar">
                    <div class="catalog-search-box">
                        <span class="search-icon">🔍</span>
                        <input 
                            type="text" 
                            placeholder="Buscar produtos na loja..." 
                            bind:value={searchQuery}
                            class="catalog-search-input"
                        />
                        {#if searchQuery}
                            <button class="clear-btn" onclick={() => searchQuery = ''} type="button">✕</button>
                        {/if}
                    </div>

                    <div class="categories-bar">
                        {#each categories as cat}
                            <button 
                                class="cat-pill" 
                                class:active={selectedCategory === cat}
                                onclick={() => selectedCategory = cat}
                                type="button"
                            >
                                {cat === 'all' ? 'Todos os Produtos' : cat.toUpperCase()}
                            </button>
                        {/each}
                    </div>
                </div>

                <!-- Products Grid -->
                <div class="products-grid-scroll">
                    {#if filteredCatalog.length === 0}
                        <div class="empty-catalog">
                            <p class="empty-title">Nenhum produto à venda no momento</p>
                            <p class="empty-subtitle">Verifique com os responsáveis da loja ou tente novamente mais tarde.</p>
                        </div>
                    {:else}
                        <div class="products-grid">
                            {#each filteredCatalog as item (item.item_name || item.name)}
                                {@const isInCart = cart.find(c => c.item_name === (item.item_name || item.name))}
                                <div class="product-card">
                                    <div class="product-thumb">
                                        <img 
                                            src={getItemImageUrl(item)} 
                                            alt={item.label || item.item_name}
                                            onerror={(e) => { e.currentTarget.style.display = 'none'; }}
                                        />
                                        <span class="product-fallback-icon">📦</span>
                                    </div>

                                    <div class="product-info">
                                        <span class="product-name" title={item.label || item.item_name}>{item.label || item.item_name}</span>
                                        {#if item.description}
                                            <span class="product-desc" title={item.description}>{item.description}</span>
                                        {/if}
                                        <div class="product-price-row">
                                            <span class="product-price">${Number(item.price).toFixed(2)}</span>
                                            {#if item.weight}
                                                <span class="product-weight">{(item.weight / 1000).toFixed(1)}kg</span>
                                            {/if}
                                        </div>
                                    </div>

                                    <div class="product-action-row">
                                        {#if isInCart}
                                            <div class="item-stepper">
                                                <button class="stepper-btn" onclick={() => updateCartAmount(isInCart.item_name, -1)} type="button">-</button>
                                                <span class="stepper-val">{isInCart.amount}</span>
                                                <button class="stepper-btn" onclick={() => updateCartAmount(isInCart.item_name, 1)} type="button">+</button>
                                            </div>
                                        {:else}
                                            <button 
                                                class="btn-add-cart" 
                                                onclick={() => addToCart(item, 1)} 
                                                type="button"
                                            >
                                                + Adicionar
                                            </button>
                                        {/if}
                                    </div>
                                </div>
                            {/each}
                        </div>
                    {/if}
                </div>
            </div>

            <!-- Shopping Cart Sidebar (Right) -->
            <div class="cart-sidebar">
                <div class="cart-header">
                    <div class="cart-header-title">
                        <span class="cart-icon">🛒</span>
                        <h3>Carrinho de Compras</h3>
                    </div>
                    {#if cart.length > 0}
                        <button class="clear-cart-btn" onclick={clearCart} type="button">Limpar</button>
                    {/if}
                </div>

                <div class="cart-divider"></div>

                <!-- Cart Items List -->
                <div class="cart-items-scroll">
                    {#if cart.length === 0}
                        <div class="empty-cart-state">
                            <span class="empty-cart-icon">🛍️</span>
                            <p class="empty-cart-text">Seu carrinho está vazio</p>
                            <span class="empty-cart-sub">Selecione produtos do catálogo ao lado para adicionar ao pedido.</span>
                        </div>
                    {:else}
                        <div class="cart-items-list">
                            {#each cart as item (item.item_name)}
                                <div class="cart-item-row">
                                    <div class="cart-item-thumb">
                                        <img 
                                            src={getItemImageUrl(item)} 
                                            alt={item.label}
                                            onerror={(e) => { e.currentTarget.style.display = 'none'; }}
                                        />
                                        <span class="fallback-mini">📦</span>
                                    </div>

                                    <div class="cart-item-details">
                                        <span class="cart-item-name">{item.label}</span>
                                        <span class="cart-item-unit">${item.price.toFixed(2)} un.</span>
                                    </div>

                                    <div class="cart-stepper">
                                        <button class="cart-btn-step" onclick={() => updateCartAmount(item.item_name, -1)} type="button">-</button>
                                        <span class="cart-step-val">{item.amount}</span>
                                        <button class="cart-btn-step" onclick={() => updateCartAmount(item.item_name, 1)} type="button">+</button>
                                    </div>

                                    <span class="cart-item-subtotal">${(item.price * item.amount).toFixed(2)}</span>

                                    <button class="cart-btn-remove" onclick={() => removeFromCart(item.item_name)} type="button" title="Remover item">✕</button>
                                </div>
                            {/each}
                        </div>
                    {/if}
                </div>

                <div class="cart-divider"></div>

                <!-- Cart Footer & Checkout -->
                <div class="cart-footer">
                    {#if checkoutMessage.text}
                        <div class="checkout-msg {checkoutMessage.type}">
                            {checkoutMessage.text}
                        </div>
                    {/if}

                    <div class="cart-summary-row">
                        <span class="summary-label">Itens no Pedido:</span>
                        <span class="summary-val">{totalItemsCount}</span>
                    </div>

                    <div class="payment-method-selector">
                        <span class="payment-title">Método de Pagamento:</span>
                        <div class="payment-options">
                            <label class="payment-radio" class:selected={paymentMethod === 'cash'}>
                                <input type="radio" name="payment" value="cash" bind:group={paymentMethod} />
                                <span>💵 Dinheiro</span>
                            </label>
                            <label class="payment-radio" class:selected={paymentMethod === 'bank'}>
                                <input type="radio" name="payment" value="bank" bind:group={paymentMethod} />
                                <span>🏦 Banco</span>
                            </label>
                        </div>
                    </div>

                    <div class="cart-total-row">
                        <span class="total-label">Total a Pagar:</span>
                        <span class="total-value" class:insufficient={!canAfford && totalCartPrice > 0}>
                            ${totalCartPrice.toFixed(2)}
                        </span>
                    </div>

                    {#if !canAfford && totalCartPrice > 0}
                        <span class="insufficient-warning">
                            ⚠️ Saldo insuficiente ({paymentMethod === 'cash' ? 'Dinheiro' : 'Banco'}).
                        </span>
                    {/if}

                    <button 
                        class="btn-checkout" 
                        disabled={cart.length === 0 || !canAfford || isProcessing}
                        onclick={handleCheckout}
                        type="button"
                    >
                        {#if isProcessing}
                            Processando...
                        {:else}
                            Finalizar Compra (${totalCartPrice.toFixed(2)})
                        {/if}
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .storefront-container {
        position: fixed;
        top: 0; left: 0;
        width: 100vw; height: 100vh;
        background: rgba(0, 0, 0, 0.72);
        backdrop-filter: blur(5px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        font-family: var(--fdb-font-family, 'Outfit', 'Inter', sans-serif);
        user-select: none;
    }

    .storefront-card {
        position: relative;
        width: 1200px;
        max-width: 95vw;
        height: 88vh;
        max-height: 900px;
        background-color: var(--fdb-background-color, #1a1512);
        border: 1px solid var(--fdb-border-color, #4a3828);
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.9);
        overflow: hidden;
        border-radius: 4px;
    }

    .storefront-background {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: var(--fdb-bg-image-menu, none);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        opacity: 0.95;
        z-index: 0;
        pointer-events: none;
    }

    .storefront-border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--fdb-accent-color, #d4a373);
        pointer-events: none;
        z-index: 1;
    }

    .storefront-header {
        position: relative;
        z-index: 2;
        padding: 1.25rem 2rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .storefront-title-area {
        display: flex;
        flex-direction: column;
        gap: 0.2rem;
    }

    .storefront-badge {
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: var(--fdb-accent-color, #d4a373);
        font-weight: 600;
    }

    .storefront-title {
        font-size: 1.6rem;
        font-weight: 800;
        color: var(--fdb-text-color, #f4ede4);
        margin: 0;
        letter-spacing: 0.04em;
    }

    .player-wallet-bar {
        display: flex;
        align-items: center;
        gap: 1rem;
    }

    .wallet-pill {
        display: flex;
        align-items: center;
        gap: 0.6rem;
        background: rgba(0, 0, 0, 0.4);
        border: 1px solid var(--fdb-border-color, #4a3828);
        padding: 0.4rem 0.85rem;
        border-radius: 4px;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .wallet-pill:hover, .wallet-pill.active {
        border-color: var(--fdb-accent-color, #d4a373);
        background: rgba(212, 163, 115, 0.1);
    }

    .wallet-icon {
        font-size: 1.2rem;
    }

    .wallet-info {
        display: flex;
        flex-direction: column;
    }

    .wallet-label {
        font-size: 0.65rem;
        text-transform: uppercase;
        color: var(--fdb-text-secondary, #a89886);
        font-weight: 600;
    }

    .wallet-value {
        font-size: 0.95rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
    }

    .storefront-close-btn {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        font-size: 1.35rem;
        cursor: pointer;
        padding: 0.3rem 0.6rem;
        transition: color 0.15s ease;
    }

    .storefront-close-btn:hover {
        color: #ff6b6b;
    }

    .storefront-divider {
        position: relative;
        z-index: 2;
        height: 1px;
        background: linear-gradient(90deg, transparent, var(--fdb-border-color, #4a3828) 20%, var(--fdb-border-color, #4a3828) 80%, transparent);
        margin: 0;
    }

    .storefront-body {
        position: relative;
        z-index: 2;
        flex: 1;
        display: flex;
        overflow: hidden;
    }

    /* Catalog Section */
    .catalog-section {
        flex: 1;
        display: flex;
        flex-direction: column;
        border-right: 1px solid var(--fdb-border-color, #4a3828);
        overflow: hidden;
    }

    .catalog-toolbar {
        padding: 1rem 1.5rem;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        background: rgba(0, 0, 0, 0.2);
    }

    .catalog-search-box {
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

    .catalog-search-input {
        width: 100%;
        background: transparent;
        border: none;
        color: var(--fdb-text-color, #f4ede4);
        padding: 0.65rem 0;
        font-size: 0.95rem;
        outline: none;
    }

    .clear-btn {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        cursor: pointer;
    }

    .categories-bar {
        display: flex;
        gap: 0.4rem;
        overflow-x: auto;
    }

    .cat-pill {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: var(--fdb-text-secondary, #a89886);
        padding: 0.25rem 0.75rem;
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

    .products-grid-scroll {
        flex: 1;
        overflow-y: auto;
        padding: 1.25rem 1.5rem;
    }

    .products-grid-scroll::-webkit-scrollbar {
        width: 6px;
    }

    .products-grid-scroll::-webkit-scrollbar-thumb {
        background: var(--fdb-border-color, #4a3828);
        border-radius: 3px;
    }

    .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 1rem;
    }

    .product-card {
        background: rgba(0, 0, 0, 0.35);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 1rem;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: 0.65rem;
        transition: all 0.18s ease;
    }

    .product-card:hover {
        border-color: var(--fdb-accent-color, #d4a373);
        transform: translateY(-2px);
        box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4);
    }

    .product-thumb {
        position: relative;
        width: 64px;
        height: 64px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, 0.3);
        border-radius: 4px;
        border: 1px solid rgba(255, 255, 255, 0.05);
    }

    .product-thumb img {
        max-width: 54px;
        max-height: 54px;
        object-fit: contain;
        position: relative;
        z-index: 2;
    }

    .product-fallback-icon {
        position: absolute;
        font-size: 1.8rem;
        opacity: 0.35;
        z-index: 1;
    }

    .product-info {
        display: flex;
        flex-direction: column;
        gap: 0.2rem;
        width: 100%;
        overflow: hidden;
    }

    .product-name {
        font-size: 0.95rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .product-desc {
        font-size: 0.75rem;
        color: var(--fdb-text-secondary, #a89886);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .product-price-row {
        display: flex;
        justify-content: center;
        align-items: baseline;
        gap: 0.5rem;
        margin-top: 0.25rem;
    }

    .product-price {
        font-size: 1.15rem;
        font-weight: 800;
        color: var(--fdb-accent-color, #d4a373);
    }

    .product-weight {
        font-size: 0.75rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .product-action-row {
        width: 100%;
        margin-top: auto;
    }

    .btn-add-cart {
        width: 100%;
        background: rgba(212, 163, 115, 0.15);
        border: 1px solid var(--fdb-accent-color, #d4a373);
        color: var(--fdb-accent-color, #d4a373);
        padding: 0.5rem 0;
        border-radius: 4px;
        font-size: 0.85rem;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-add-cart:hover {
        background: var(--fdb-accent-color, #d4a373);
        color: #1a1512;
    }

    .item-stepper {
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: rgba(0, 0, 0, 0.5);
        border: 1px solid var(--fdb-accent-color, #d4a373);
        border-radius: 4px;
        overflow: hidden;
    }

    .stepper-btn {
        background: rgba(212, 163, 115, 0.2);
        border: none;
        color: var(--fdb-accent-color, #d4a373);
        font-weight: 700;
        width: 32px;
        height: 28px;
        cursor: pointer;
        font-size: 1rem;
    }

    .stepper-btn:hover {
        background: var(--fdb-accent-color, #d4a373);
        color: #1a1512;
    }

    .stepper-val {
        font-size: 0.9rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
    }

    /* Cart Sidebar */
    .cart-sidebar {
        width: 360px;
        display: flex;
        flex-direction: column;
        background: rgba(0, 0, 0, 0.25);
    }

    .cart-header {
        padding: 1.25rem 1.5rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .cart-header-title {
        display: flex;
        align-items: center;
        gap: 0.6rem;
    }

    .cart-icon {
        font-size: 1.15rem;
    }

    .cart-header h3 {
        margin: 0;
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
    }

    .clear-cart-btn {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        font-size: 0.8rem;
        cursor: pointer;
        text-decoration: underline;
    }

    .clear-cart-btn:hover {
        color: #ff6b6b;
    }

    .cart-divider {
        height: 1px;
        background: rgba(255, 255, 255, 0.08);
        margin: 0;
    }

    .cart-items-scroll {
        flex: 1;
        overflow-y: auto;
        padding: 1rem 1.25rem;
    }

    .cart-items-scroll::-webkit-scrollbar {
        width: 5px;
    }

    .cart-items-scroll::-webkit-scrollbar-thumb {
        background: var(--fdb-border-color, #4a3828);
        border-radius: 3px;
    }

    .empty-cart-state {
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
        padding: 2rem 1rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .empty-cart-icon {
        font-size: 2.5rem;
        margin-bottom: 0.75rem;
        opacity: 0.5;
    }

    .empty-cart-text {
        font-size: 1.05rem;
        font-weight: 600;
        color: var(--fdb-text-color, #f4ede4);
        margin-bottom: 0.25rem;
    }

    .empty-cart-sub {
        font-size: 0.8rem;
        opacity: 0.7;
        line-height: 1.4;
    }

    .cart-items-list {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
    }

    .cart-item-row {
        display: flex;
        align-items: center;
        gap: 0.6rem;
        background: rgba(0, 0, 0, 0.35);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0.6rem;
    }

    .cart-item-thumb {
        position: relative;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0, 0, 0, 0.4);
        border-radius: 3px;
        flex-shrink: 0;
    }

    .cart-item-thumb img {
        max-width: 26px;
        max-height: 26px;
        object-fit: contain;
        position: relative;
        z-index: 2;
    }

    .fallback-mini {
        position: absolute;
        font-size: 0.9rem;
        opacity: 0.3;
        z-index: 1;
    }

    .cart-item-details {
        display: flex;
        flex-direction: column;
        flex: 1;
        overflow: hidden;
    }

    .cart-item-name {
        font-size: 0.85rem;
        font-weight: 600;
        color: var(--fdb-text-color, #f4ede4);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .cart-item-unit {
        font-size: 0.7rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .cart-stepper {
        display: flex;
        align-items: center;
        background: rgba(0, 0, 0, 0.5);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 3px;
    }

    .cart-btn-step {
        background: transparent;
        border: none;
        color: var(--fdb-text-color, #f4ede4);
        padding: 0.1rem 0.4rem;
        cursor: pointer;
        font-size: 0.75rem;
    }

    .cart-step-val {
        font-size: 0.75rem;
        font-weight: 700;
        padding: 0 0.3rem;
        color: var(--fdb-accent-color, #d4a373);
    }

    .cart-item-subtotal {
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--fdb-accent-color, #d4a373);
        min-width: 50px;
        text-align: right;
    }

    .cart-btn-remove {
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89886);
        cursor: pointer;
        padding: 0.2rem;
        font-size: 0.75rem;
    }

    .cart-btn-remove:hover {
        color: #ff6b6b;
    }

    .cart-footer {
        padding: 1.25rem 1.5rem;
        display: flex;
        flex-direction: column;
        gap: 0.85rem;
        background: rgba(0, 0, 0, 0.35);
    }

    .checkout-msg {
        padding: 0.5rem 0.75rem;
        border-radius: 4px;
        font-size: 0.8rem;
        font-weight: 600;
        text-align: center;
    }

    .checkout-msg.info { background: rgba(59, 130, 246, 0.2); color: #93c5fd; border: 1px solid #3b82f6; }
    .checkout-msg.success { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; border: 1px solid #10b981; }
    .checkout-msg.error { background: rgba(239, 68, 68, 0.2); color: #fca5a5; border: 1px solid #ef4444; }

    .cart-summary-row {
        display: flex;
        justify-content: space-between;
        font-size: 0.85rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .payment-method-selector {
        display: flex;
        flex-direction: column;
        gap: 0.4rem;
    }

    .payment-title {
        font-size: 0.75rem;
        text-transform: uppercase;
        color: var(--fdb-text-secondary, #a89886);
        font-weight: 600;
    }

    .payment-options {
        display: flex;
        gap: 0.5rem;
    }

    .payment-radio {
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.4rem;
        background: rgba(0, 0, 0, 0.4);
        border: 1px solid var(--fdb-border-color, #4a3828);
        border-radius: 4px;
        padding: 0.45rem 0;
        font-size: 0.8rem;
        font-weight: 600;
        color: var(--fdb-text-secondary, #a89886);
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .payment-radio input {
        display: none;
    }

    .payment-radio.selected {
        background: rgba(212, 163, 115, 0.15);
        border-color: var(--fdb-accent-color, #d4a373);
        color: var(--fdb-accent-color, #d4a373);
    }

    .cart-total-row {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        padding-top: 0.5rem;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
    }

    .total-label {
        font-size: 1rem;
        font-weight: 700;
        color: var(--fdb-text-color, #f4ede4);
    }

    .total-value {
        font-size: 1.45rem;
        font-weight: 800;
        color: var(--fdb-accent-color, #d4a373);
    }

    .total-value.insufficient {
        color: #ff6b6b;
    }

    .insufficient-warning {
        font-size: 0.75rem;
        color: #ff6b6b;
        text-align: center;
    }

    .btn-checkout {
        width: 100%;
        background: var(--fdb-accent-color, #d4a373);
        border: 1px solid var(--fdb-accent-color, #d4a373);
        color: #1a1512;
        padding: 0.85rem 0;
        border-radius: 4px;
        font-size: 0.95rem;
        font-weight: 800;
        letter-spacing: 0.03em;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .btn-checkout:hover:not(:disabled) {
        filter: brightness(1.15);
        box-shadow: 0 0 15px rgba(212, 163, 115, 0.4);
    }

    .btn-checkout:disabled {
        opacity: 0.4;
        cursor: not-allowed;
    }

    .empty-catalog {
        text-align: center;
        padding: 4rem 1rem;
        color: var(--fdb-text-secondary, #a89886);
    }

    .empty-title {
        font-size: 1.15rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
    }

    .empty-subtitle {
        font-size: 0.85rem;
        opacity: 0.7;
    }
</style>
