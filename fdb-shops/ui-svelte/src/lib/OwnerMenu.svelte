<script>
    import { onMount } from 'svelte';

    let { 
        menuData,
        onClose = () => {} 
    } = $props();

    let shopId = $state(menuData.shopId || '');
    let stationId = $state(menuData.stationId || '');
    let shopData = $state(menuData.shopData || {});
    let permissions = $state(menuData.permissions || {});
    let stationModules = $state(menuData.stationModules || ['dashboard', 'finances', 'prices', 'employees']);

    let activeTab = $state('dashboard');
    let depositAmount = $state('');
    let withdrawAmount = $state('');
    let currentBalance = $state(Number(shopData.cashBalance || 0));
    let priceVariation = $state(Number(shopData.ownerPriceVariation || 0) * 100);
    let maxVariation = $state(Number(shopData.maxPriceVariation || 0.15) * 100);
    let statusMessage = $state({ text: '', type: '' });

    // Available tabs based on permissions and station modules
    let allowedTabs = $derived.by(() => {
        const tabs = [{ id: 'dashboard', label: 'Visão Geral', icon: '📊' }];
        const isOwnerOrAdmin = permissions.isOwner || permissions.isAdmin;

        if ((isOwnerOrAdmin || permissions.financeiro) && stationModules.includes('finances')) {
            tabs.push({ id: 'finances', label: 'Finanças', icon: '💰' });
        }
        if ((isOwnerOrAdmin || permissions.editar_precos) && stationModules.includes('prices')) {
            tabs.push({ id: 'prices', label: 'Preços', icon: '🏷️' });
        }
        return tabs;
    });

    function setStatus(text, type = 'info') {
        statusMessage = { text, type };
        setTimeout(() => {
            if (statusMessage.text === text) statusMessage = { text: '', type: '' };
        }, 4000);
    }

    async function handleDeposit() {
        const amt = parseFloat(depositAmount);
        if (isNaN(amt) || amt <= 0) {
            setStatus('Insira um valor válido para depósito.', 'error');
            return;
        }

        try {
            await fetch(`https://${window.GetParentResourceName()}/deposit`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: shopId,
                    stationId: stationId,
                    amount: amt
                })
            });
            currentBalance += amt;
            depositAmount = '';
            setStatus(`Depósito de $${amt.toFixed(2)} enviado!`, 'success');
        } catch (e) {
            setStatus('Erro ao comunicar com o servidor.', 'error');
        }
    }

    async function handleWithdraw() {
        const amt = parseFloat(withdrawAmount);
        if (isNaN(amt) || amt <= 0) {
            setStatus('Insira um valor válido para saque.', 'error');
            return;
        }
        if (amt > currentBalance) {
            setStatus('Saldo insuficiente no caixa da loja.', 'error');
            return;
        }

        try {
            await fetch(`https://${window.GetParentResourceName()}/withdraw`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: shopId,
                    stationId: stationId,
                    amount: amt
                })
            });
            currentBalance = Math.max(0, currentBalance - amt);
            withdrawAmount = '';
            setStatus(`Saque de $${amt.toFixed(2)} enviado!`, 'success');
        } catch (e) {
            setStatus('Erro ao comunicar com o servidor.', 'error');
        }
    }

    async function handleSaveVariation() {
        const varDecimal = Number(priceVariation) / 100;
        try {
            await fetch(`https://${window.GetParentResourceName()}/updateVariation`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    shopId: shopId,
                    stationId: stationId,
                    variation: varDecimal
                })
            });
            setStatus(`Variação salva: ${priceVariation > 0 ? '+' : ''}${priceVariation}%`, 'success');
        } catch (e) {
            setStatus('Erro ao atualizar preços.', 'error');
        }
    }

    function handleKeyDown(e) {
        if (e.key === 'Escape') {
            closeMenu();
        }
    }

    function closeMenu() {
        fetch(`https://${window.GetParentResourceName()}/close`, {
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

<div class="owner-menu-modal" role="dialog" aria-modal="true">
    <div class="owner-menu-card">
        <!-- Header -->
        <div class="owner-header">
            <div class="owner-header-left">
                <span class="owner-badge">PAINEL DE ADMINISTRAÇÃO</span>
                <h2 class="owner-title">{shopData.label || shopId}</h2>
                <span class="owner-sub">ID da Loja: <strong>{shopId}</strong> • Dono: <strong>{shopData.ownerId || 'Sem Dono (Público)'}</strong></span>
            </div>
            <button class="owner-close-btn" onclick={closeMenu} type="button" title="Fechar (ESC)">✕</button>
        </div>

        <!-- Status Message Banner -->
        {#if statusMessage.text}
            <div class="status-banner {statusMessage.type}">
                {statusMessage.text}
            </div>
        {/if}

        <!-- Navigation Tabs -->
        <div class="owner-tabs">
            {#each allowedTabs as tab}
                <button 
                    class="tab-btn" 
                    class:active={activeTab === tab.id}
                    onclick={() => activeTab = tab.id}
                    type="button"
                >
                    <span class="tab-icon">{tab.icon}</span>
                    <span>{tab.label}</span>
                </button>
            {/each}
        </div>

        <!-- Tab Content -->
        <div class="owner-body">
            {#if activeTab === 'dashboard'}
                <div class="dash-grid">
                    <div class="stat-card">
                        <span class="stat-label">Saldo em Caixa</span>
                        <span class="stat-value highlight">${currentBalance.toFixed(2)}</span>
                        <span class="stat-hint">Disponível no cofre para saques e compras</span>
                    </div>

                    <div class="stat-card">
                        <span class="stat-label">Ajuste de Preços Ativo</span>
                        <span class="stat-value">{priceVariation > 0 ? '+' : ''}{priceVariation}%</span>
                        <span class="stat-hint">Variação sobre o preço base dos produtos</span>
                    </div>

                    <div class="stat-card">
                        <span class="stat-label">Região / Cidade</span>
                        <span class="stat-value capitalize">{shopData.city || shopData.regionId || 'Geral'}</span>
                        <span class="stat-hint">Localização de registro mercantil</span>
                    </div>

                    <div class="stat-card">
                        <span class="stat-label">Permissões de Acesso</span>
                        <span class="stat-value badge-role">{permissions.isOwner ? 'Proprietário' : permissions.isAdmin ? 'Administrador' : 'Funcionário'}</span>
                        <span class="stat-hint">Nível de autorização concedido</span>
                    </div>
                </div>

            {:else if activeTab === 'finances'}
                <div class="finances-container">
                    <div class="vault-display">
                        <span class="vault-title">Cofre da Loja</span>
                        <span class="vault-amount">${currentBalance.toFixed(2)}</span>
                        <span class="vault-desc">O dinheiro do cofre é utilizado para receber pagamentos de vendas e custear operações.</span>
                    </div>

                    <div class="finances-actions-grid">
                        <!-- Deposit Box -->
                        <div class="action-box">
                            <h4>💵 Depositar no Caixa</h4>
                            <p class="action-desc">Transfira dinheiro de sua carteira para o cofre da loja.</p>
                            <div class="input-row">
                                <span class="currency-symbol">$</span>
                                <input 
                                    type="number" 
                                    min="1" 
                                    step="1" 
                                    placeholder="Valor do depósito" 
                                    bind:value={depositAmount} 
                                />
                            </div>
                            <button class="btn-action deposit-btn" onclick={handleDeposit} type="button">
                                Confirmar Depósito
                            </button>
                        </div>

                        <!-- Withdraw Box -->
                        <div class="action-box">
                            <h4>🏦 Sacar do Caixa</h4>
                            <p class="action-desc">Retire fundos acumulados das vendas diretamente para seu bolso.</p>
                            <div class="input-row">
                                <span class="currency-symbol">$</span>
                                <input 
                                    type="number" 
                                    min="1" 
                                    step="1" 
                                    placeholder="Valor do saque" 
                                    bind:value={withdrawAmount} 
                                />
                            </div>
                            <button class="btn-action withdraw-btn" onclick={handleWithdraw} type="button">
                                Confirmar Saque
                            </button>
                        </div>
                    </div>
                </div>

            {:else if activeTab === 'prices'}
                <div class="prices-container">
                    <div class="prices-card">
                        <div class="prices-header">
                            <div>
                                <h4>Margem de Lucro / Desconto</h4>
                                <p class="prices-desc">Defina a variação percentual que incidirá sobre o preço de todos os produtos do catálogo desta loja.</p>
                            </div>
                            <div class="variation-badge" class:positive={priceVariation > 0} class:negative={priceVariation < 0}>
                                {priceVariation > 0 ? '+' : ''}{priceVariation}%
                            </div>
                        </div>

                        <div class="slider-control">
                            <span class="range-bound">-{maxVariation}%</span>
                            <input 
                                type="range" 
                                min={-maxVariation} 
                                max={maxVariation} 
                                step="1" 
                                bind:value={priceVariation} 
                                class="variation-range"
                            />
                            <span class="range-bound">+{maxVariation}%</span>
                        </div>

                        <div class="prices-presets">
                            <button type="button" class="preset-btn" onclick={() => priceVariation = -10}>-10% (Promoção)</button>
                            <button type="button" class="preset-btn" onclick={() => priceVariation = -5}>-5% (Desconto)</button>
                            <button type="button" class="preset-btn" onclick={() => priceVariation = 0}>0% (Padrão)</button>
                            <button type="button" class="preset-btn" onclick={() => priceVariation = 5}>+5% (Margem)</button>
                            <button type="button" class="preset-btn" onclick={() => priceVariation = 10}>+10% (Alta)</button>
                        </div>

                        <div class="prices-save-row">
                            <button class="btn-save-prices" onclick={handleSaveVariation} type="button">
                                Salvar Nova Variação
                            </button>
                        </div>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>

<style>
    .owner-menu-modal {
        position: fixed;
        top: 0; left: 0;
        width: 100vw; height: 100vh;
        background: rgba(0, 0, 0, 0.75);
        backdrop-filter: blur(5px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    }

    .owner-menu-card {
        width: 820px;
        max-width: 95vw;
        background: var(--fdb-bg-panel, #12151b);
        border: 1px solid var(--fdb-border-panel, rgba(200, 160, 100, 0.25));
        border-radius: 8px;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.6);
        color: var(--fdb-text-main, #e8dfd3);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        animation: ownerFadeIn 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }

    @keyframes ownerFadeIn {
        from { opacity: 0; transform: scale(0.97) translateY(10px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }

    .owner-header {
        padding: 20px 24px;
        background: rgba(20, 24, 30, 0.95);
        border-bottom: 1px solid var(--fdb-border-panel, rgba(200, 160, 100, 0.2));
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
    }

    .owner-badge {
        display: inline-block;
        font-size: 0.68rem;
        font-weight: 700;
        letter-spacing: 1.5px;
        text-transform: uppercase;
        color: var(--fdb-accent-gold, #c8963e);
        margin-bottom: 4px;
    }

    .owner-title {
        margin: 0 0 4px 0;
        font-size: 1.45rem;
        font-family: var(--fdb-font-serif, "Cinzel", serif);
        color: var(--fdb-text-main, #f0e6d2);
    }

    .owner-sub {
        font-size: 0.82rem;
        color: var(--fdb-text-muted, #9a9488);
    }

    .owner-close-btn {
        background: transparent;
        border: 1px solid rgba(255, 255, 255, 0.15);
        color: var(--fdb-text-muted, #9a9488);
        border-radius: 50%;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .owner-close-btn:hover {
        border-color: #ff5252;
        color: #ff5252;
        background: rgba(255, 82, 82, 0.1);
    }

    .status-banner {
        padding: 10px 24px;
        font-size: 0.88rem;
        display: flex;
        align-items: center;
        font-weight: 500;
    }

    .status-banner.success { background: rgba(46, 125, 50, 0.25); color: #81c784; border-bottom: 1px solid #2e7d32; }
    .status-banner.error { background: rgba(198, 40, 40, 0.25); color: #e57373; border-bottom: 1px solid #c62828; }
    .status-banner.info { background: rgba(21, 101, 192, 0.25); color: #64b5f6; border-bottom: 1px solid #1565c0; }

    .owner-tabs {
        display: flex;
        gap: 8px;
        padding: 12px 24px;
        background: rgba(10, 12, 16, 0.6);
        border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    }

    .tab-btn {
        padding: 8px 16px;
        background: transparent;
        border: 1px solid transparent;
        border-radius: 4px;
        color: var(--fdb-text-muted, #9a9488);
        font-size: 0.88rem;
        font-weight: 600;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
        transition: all 0.15s ease;
    }

    .tab-btn:hover {
        color: var(--fdb-text-main, #e8dfd3);
        background: rgba(255, 255, 255, 0.04);
    }

    .tab-btn.active {
        color: var(--fdb-accent-gold, #c8963e);
        background: rgba(200, 150, 62, 0.12);
        border-color: rgba(200, 150, 62, 0.35);
    }

    .owner-body {
        padding: 24px;
        max-height: 70vh;
        overflow-y: auto;
    }

    /* Dashboard */
    .dash-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
    }

    .stat-card {
        background: rgba(25, 30, 38, 0.5);
        border: 1px solid rgba(255, 255, 255, 0.06);
        border-radius: 6px;
        padding: 18px 20px;
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .stat-label {
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        color: var(--fdb-text-muted, #9a9488);
    }

    .stat-value {
        font-size: 1.6rem;
        font-weight: 700;
        color: #ffffff;
    }

    .stat-value.highlight {
        color: #81c784;
        font-family: var(--fdb-font-serif, "Cinzel", serif);
    }

    .stat-hint {
        font-size: 0.75rem;
        color: var(--fdb-text-muted, #7e796e);
    }

    .badge-role {
        font-size: 1rem !important;
        color: var(--fdb-accent-gold, #c8963e) !important;
    }

    /* Finances */
    .vault-display {
        background: linear-gradient(135deg, rgba(200, 150, 62, 0.15), rgba(15, 20, 25, 0.8));
        border: 1px solid rgba(200, 150, 62, 0.3);
        border-radius: 8px;
        padding: 24px;
        text-align: center;
        margin-bottom: 24px;
    }

    .vault-title {
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        color: var(--fdb-accent-gold, #c8963e);
        display: block;
        margin-bottom: 6px;
    }

    .vault-amount {
        font-size: 2.6rem;
        font-weight: 700;
        color: #81c784;
        font-family: var(--fdb-font-serif, "Cinzel", serif);
        display: block;
        margin-bottom: 8px;
    }

    .vault-desc {
        font-size: 0.82rem;
        color: var(--fdb-text-muted, #9a9488);
        max-width: 550px;
        margin: 0 auto;
        display: block;
    }

    .finances-actions-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .action-box {
        background: rgba(25, 30, 38, 0.5);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 6px;
        padding: 20px;
        display: flex;
        flex-direction: column;
    }

    .action-box h4 {
        margin: 0 0 6px 0;
        font-size: 1.05rem;
        color: #ffffff;
    }

    .action-desc {
        font-size: 0.78rem;
        color: var(--fdb-text-muted, #8a8478);
        margin: 0 0 16px 0;
        min-height: 34px;
    }

    .input-row {
        position: relative;
        display: flex;
        align-items: center;
        margin-bottom: 14px;
    }

    .currency-symbol {
        position: absolute;
        left: 12px;
        color: var(--fdb-text-muted, #8a8478);
        font-weight: 700;
    }

    .input-row input {
        width: 100%;
        background: rgba(10, 12, 16, 0.8);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: 4px;
        padding: 10px 12px 10px 28px;
        color: #ffffff;
        font-size: 0.95rem;
        outline: none;
    }

    .input-row input:focus {
        border-color: var(--fdb-accent-gold, #c8963e);
    }

    .btn-action {
        padding: 10px 16px;
        border-radius: 4px;
        font-size: 0.88rem;
        font-weight: 700;
        cursor: pointer;
        border: none;
        transition: all 0.15s ease;
    }

    .deposit-btn {
        background: #2e7d32;
        color: #ffffff;
    }

    .deposit-btn:hover { background: #388e3c; }

    .withdraw-btn {
        background: #d84315;
        color: #ffffff;
    }

    .withdraw-btn:hover { background: #e64a19; }

    /* Prices */
    .prices-card {
        background: rgba(25, 30, 38, 0.5);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 6px;
        padding: 24px;
    }

    .prices-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
    }

    .prices-header h4 {
        margin: 0 0 6px 0;
        font-size: 1.15rem;
        color: #ffffff;
    }

    .prices-desc {
        font-size: 0.82rem;
        color: var(--fdb-text-muted, #9a9488);
        margin: 0;
        max-width: 480px;
    }

    .variation-badge {
        font-size: 1.4rem;
        font-weight: 700;
        padding: 8px 16px;
        border-radius: 6px;
        background: rgba(255, 255, 255, 0.06);
        color: #ffffff;
    }

    .variation-badge.positive { color: #81c784; background: rgba(76, 175, 80, 0.15); }
    .variation-badge.negative { color: #e57373; background: rgba(244, 67, 54, 0.15); }

    .slider-control {
        display: flex;
        align-items: center;
        gap: 16px;
        margin-bottom: 24px;
    }

    .range-bound {
        font-size: 0.85rem;
        color: var(--fdb-text-muted, #8a8478);
        font-weight: 600;
    }

    .variation-range {
        flex: 1;
        accent-color: var(--fdb-accent-gold, #c8963e);
        cursor: pointer;
    }

    .prices-presets {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
        margin-bottom: 24px;
    }

    .preset-btn {
        padding: 6px 12px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 4px;
        color: var(--fdb-text-muted, #9a9488);
        font-size: 0.8rem;
        cursor: pointer;
        transition: all 0.15s ease;
    }

    .preset-btn:hover {
        color: #ffffff;
        background: rgba(255, 255, 255, 0.1);
    }

    .prices-save-row {
        text-align: right;
    }

    .btn-save-prices {
        padding: 10px 24px;
        background: var(--fdb-accent-gold, #c8963e);
        color: #12151b;
        font-weight: 700;
        font-size: 0.9rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: opacity 0.15s ease;
    }

    .btn-save-prices:hover { opacity: 0.9; }

    .capitalize { text-transform: capitalize; }
</style>
