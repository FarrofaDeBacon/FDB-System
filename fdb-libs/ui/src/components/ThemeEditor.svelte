<script>
    import { onMount, onDestroy } from 'svelte';
    
    export let visible = false;
    
    // Configurações padrão iniciais (Western Gold)
    let theme = {
        fontBody: "'RDR Lino Regular', 'Roboto Condensed', serif",
        fontDisplay: "'RDR Lino Regular', 'Playfair Display', serif",
        textPrimary: '#d4c5b0',
        textSecondary: '#a89878',
        textOnPaper: '#2b1d14',
        accentColor: '#c9a15a',
        accentColorDark: '#8a6a35',
        backgroundColor: 'rgba(10, 10, 10, 0.88)',
        backgroundPaper: '#d8c9a3',
        backgroundWood: '#2b1d14',
        borderColor: 'rgba(255, 255, 255, 0.1)',
        borderColorWood: '#4a2e1a',
        borderRadius: '4px',
        statusGood: '#27ae60',
        statusWarning: '#c98a3a',
        statusCritical: '#c0392b',
        statusInfo: '#2980b9',
    };

    let activeTab = 'geral';
    let exportCode = '';

    // Carrega o tema atual do CSS :root ao abrir
    function loadCurrentTheme() {
        const root = document.documentElement;
        const computedStyle = getComputedStyle(root);
        
        // Mapeamento das variáveis CSS para a nossa tabela do tema
        for (const key of Object.keys(theme)) {
            const cssVar = `--fdb-${key.replace(/([A-Z])/g, "-$1").toLowerCase()}`;
            const val = computedStyle.getPropertyValue(cssVar).trim();
            if (val) {
                theme[key] = val;
            }
        }
        updateExportCode();
    }

    // Atualiza o CSS do :root na hora (Live Preview)
    function updateThemeVar(key, value) {
        theme[key] = value;
        const cssVar = `--fdb-${key.replace(/([A-Z])/g, "-$1").toLowerCase()}`;
        document.documentElement.style.setProperty(cssVar, value);
        updateExportCode();
    }

    // Atualiza o código Lua para exportação
    function updateExportCode() {
        exportCode = `Config.ThemePresets.custom = {\n` +
            `    fontBody = "${theme.fontBody}",\n` +
            `    fontDisplay = "${theme.fontDisplay}",\n` +
            `    textPrimary = "${theme.textPrimary}",\n` +
            `    textSecondary = "${theme.textSecondary}",\n` +
            `    textOnPaper = "${theme.textOnPaper}",\n` +
            `    accentColor = "${theme.accentColor}",\n` +
            `    accentColorDark = "${theme.accentColorDark}",\n` +
            `    backgroundColor = "${theme.backgroundColor}",\n` +
            `    backgroundPaper = "${theme.backgroundPaper}",\n` +
            `    backgroundWood = "${theme.backgroundWood}",\n` +
            `    borderColor = "${theme.borderColor}",\n` +
            `    borderColorWood = "${theme.borderColorWood}",\n` +
            `    borderRadius = "${theme.borderRadius}",\n` +
            `    statusGood = "${theme.statusGood}",\n` +
            `    statusWarning = "${theme.statusWarning}",\n` +
            `    statusCritical = "${theme.statusCritical}",\n` +
            `    statusInfo = "${theme.statusInfo}",\n` +
            `}`;
    }

    function handleMessage(event) {
        if (event.data.action === "OPEN_THEME_EDITOR") {
            loadCurrentTheme();
            visible = true;
        } else if (event.data.action === "CLOSE_THEME_EDITOR") {
            visible = false;
        }
    }

    function handleKeyDown(event) {
        if (visible && (event.key === "Escape" || event.key === "Backspace")) {
            closeEditor();
        }
    }

    onMount(() => {
        window.addEventListener('message', handleMessage);
        window.addEventListener('keydown', handleKeyDown);
    });

    onDestroy(() => {
        window.removeEventListener('message', handleMessage);
        window.removeEventListener('keydown', handleKeyDown);
    });

    function saveTheme() {
        fetch(`https://${GetParentResourceName()}/saveThemeEditor`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ theme: theme })
        });
        visible = false;
    }

    function resetTheme() {
        fetch(`https://${GetParentResourceName()}/resetThemeEditor`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        visible = false;
    }

    function closeEditor() {
        fetch(`https://${GetParentResourceName()}/closeThemeEditor`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        visible = false;
    }
</script>

{#if visible}
    <div class="editor-overlay">
        <div class="editor-container">
            <!-- PAINEL ESQUERDO: CONTROLES -->
            <div class="editor-controls">
                <div class="editor-header">
                    <h2>Editor de Temas</h2>
                    <span class="editor-subtitle">Customização Visual fdb-libs</span>
                </div>

                <!-- Abas -->
                <div class="editor-tabs">
                    <button class="tab-btn" class:active={activeTab === 'geral'} on:click={() => activeTab = 'geral'}>Geral</button>
                    <button class="tab-btn" class:active={activeTab === 'cores'} on:click={() => activeTab = 'cores'}>Cores</button>
                    <button class="tab-btn" class:active={activeTab === 'status'} on:click={() => activeTab = 'status'}>Status</button>
                    <button class="tab-btn" class:active={activeTab === 'exportar'} on:click={() => activeTab = 'exportar'}>Exportar</button>
                </div>

                <!-- Conteúdo das Abas -->
                <div class="tab-content">
                    {#if activeTab === 'geral'}
                        <div class="input-group">
                            <label for="fontBody">Fonte de Texto (Body)</label>
                            <input id="fontBody" type="text" value={theme.fontBody} on:input={(e) => updateThemeVar('fontBody', e.target.value)} />
                        </div>
                        <div class="input-group">
                            <label for="fontDisplay">Fonte de Título (Display)</label>
                            <input id="fontDisplay" type="text" value={theme.fontDisplay} on:input={(e) => updateThemeVar('fontDisplay', e.target.value)} />
                        </div>
                        <div class="input-group">
                            <label for="borderRadius">Arredondamento das Bordas</label>
                            <input id="borderRadius" type="text" value={theme.borderRadius} on:input={(e) => updateThemeVar('borderRadius', e.target.value)} />
                        </div>
                        <div class="input-group">
                            <label for="backgroundColor">Cor de Fundo Sólida (Containers)</label>
                            <div class="color-picker-wrapper">
                                <input id="backgroundColor" type="color" value={theme.backgroundColor.startsWith('rgba') ? '#0f0f0f' : theme.backgroundColor} on:input={(e) => updateThemeVar('backgroundColor', e.target.value)} />
                                <input type="text" value={theme.backgroundColor} on:input={(e) => updateThemeVar('backgroundColor', e.target.value)} />
                            </div>
                        </div>
                    {/if}

                    {#if activeTab === 'cores'}
                        <div class="input-group">
                            <label for="accentColor">Cor de Destaque (Accent)</label>
                            <div class="color-picker-wrapper">
                                <input id="accentColor" type="color" value={theme.accentColor} on:input={(e) => updateThemeVar('accentColor', e.target.value)} />
                                <input type="text" value={theme.accentColor} on:input={(e) => updateThemeVar('accentColor', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="accentColorDark">Cor de Destaque Escura</label>
                            <div class="color-picker-wrapper">
                                <input id="accentColorDark" type="color" value={theme.accentColorDark} on:input={(e) => updateThemeVar('accentColorDark', e.target.value)} />
                                <input type="text" value={theme.accentColorDark} on:input={(e) => updateThemeVar('accentColorDark', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="textPrimary">Texto Principal</label>
                            <div class="color-picker-wrapper">
                                <input id="textPrimary" type="color" value={theme.textPrimary} on:input={(e) => updateThemeVar('textPrimary', e.target.value)} />
                                <input type="text" value={theme.textPrimary} on:input={(e) => updateThemeVar('textPrimary', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="textSecondary">Texto Secundário</label>
                            <div class="color-picker-wrapper">
                                <input id="textSecondary" type="color" value={theme.textSecondary} on:input={(e) => updateThemeVar('textSecondary', e.target.value)} />
                                <input type="text" value={theme.textSecondary} on:input={(e) => updateThemeVar('textSecondary', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="borderColor">Cor da Borda</label>
                            <div class="color-picker-wrapper">
                                <input id="borderColor" type="color" value={theme.borderColor.startsWith('rgba') ? '#2b2b2b' : theme.borderColor} on:input={(e) => updateThemeVar('borderColor', e.target.value)} />
                                <input type="text" value={theme.borderColor} on:input={(e) => updateThemeVar('borderColor', e.target.value)} />
                            </div>
                        </div>
                    {/if}

                    {#if activeTab === 'status'}
                        <div class="input-group">
                            <label for="statusGood">Status Sucesso (Good)</label>
                            <div class="color-picker-wrapper">
                                <input id="statusGood" type="color" value={theme.statusGood} on:input={(e) => updateThemeVar('statusGood', e.target.value)} />
                                <input type="text" value={theme.statusGood} on:input={(e) => updateThemeVar('statusGood', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="statusWarning">Status Alerta (Warning)</label>
                            <div class="color-picker-wrapper">
                                <input id="statusWarning" type="color" value={theme.statusWarning} on:input={(e) => updateThemeVar('statusWarning', e.target.value)} />
                                <input type="text" value={theme.statusWarning} on:input={(e) => updateThemeVar('statusWarning', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="statusCritical">Status Erro (Critical)</label>
                            <div class="color-picker-wrapper">
                                <input id="statusCritical" type="color" value={theme.statusCritical} on:input={(e) => updateThemeVar('statusCritical', e.target.value)} />
                                <input type="text" value={theme.statusCritical} on:input={(e) => updateThemeVar('statusCritical', e.target.value)} />
                            </div>
                        </div>
                        <div class="input-group">
                            <label for="statusInfo">Status Informação (Info)</label>
                            <div class="color-picker-wrapper">
                                <input id="statusInfo" type="color" value={theme.statusInfo} on:input={(e) => updateThemeVar('statusInfo', e.target.value)} />
                                <input type="text" value={theme.statusInfo} on:input={(e) => updateThemeVar('statusInfo', e.target.value)} />
                            </div>
                        </div>
                    {/if}

                    {#if activeTab === 'exportar'}
                        <div class="export-section">
                            <span class="export-info">Copie o código abaixo e cole nas predefinições de tema do seu <strong>config.lua</strong>:</span>
                            <textarea readonly value={exportCode} on:focus={(e) => e.target.select()}></textarea>
                        </div>
                    {/if}
                </div>

                <!-- Rodapé de Ações -->
                <div class="editor-actions">
                    <button class="btn btn-secondary" on:click={resetTheme}>Resetar</button>
                    <button class="btn btn-cancel" on:click={closeEditor}>Cancelar</button>
                    <button class="btn btn-primary" on:click={saveTheme}>Salvar Tema</button>
                </div>
            </div>

            <!-- PAINEL DIREITO: LIVE PREVIEW -->
            <div class="editor-preview">
                <h3>Preview em Tempo Real</h3>
                <span class="preview-subtitle">Veja como os componentes ficam na tela</span>

                <div class="preview-showcase">
                    <!-- Simulador de Menu -->
                    <div class="simulated-menu">
                        <div class="sim-header">Menu de Testes</div>
                        <div class="sim-content">
                            <div class="sim-item active">
                                <span>Opção Selecionada</span>
                                <span class="sim-badge">></span>
                            </div>
                            <div class="sim-item">
                                <span>Opção Desmarcada</span>
                                <span class="sim-box"></span>
                            </div>
                            <div class="sim-slider">
                                <span>Volume</span>
                                <div class="sim-bar">
                                    <div class="sim-fill" style="width: 60%"></div>
                                    <div class="sim-marker" style="left: 60%"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Simulador de Notificação -->
                    <div class="simulated-notify">
                        <span class="sim-icon">★</span>
                        <div class="sim-notify-text">
                            <span class="title">Notificação de Informação</span>
                            <span class="desc">Isso é um aviso dinâmico da fdb-libs!</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
{/if}

<style>
    .editor-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(0, 0, 0, 0.7);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        font-family: var(--fdb-font-body, 'Roboto Condensed', sans-serif);
    }

    .editor-container {
        display: flex;
        width: 850px;
        height: 520px;
        background-color: var(--fdb-background-color, rgba(15, 15, 15, 0.96));
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        border-radius: var(--fdb-border-radius, 4px);
        overflow: hidden;
        box-shadow: 0 20px 40px rgba(0,0,0,0.6);
    }

    /* PAINEL DE CONTROLES (ESQUERDO) */
    .editor-controls {
        width: 50%;
        display: flex;
        flex-direction: column;
        padding: 25px;
        border-right: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
    }

    .editor-header h2 {
        margin: 0;
        color: var(--fdb-text-primary, #d4c5b0);
        font-family: var(--fdb-font-display, 'Playfair Display', serif);
        font-size: 22px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .editor-subtitle {
        font-size: 11px;
        color: var(--fdb-text-secondary, #a89878);
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .editor-tabs {
        display: flex;
        margin-top: 20px;
        border-bottom: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
    }

    .tab-btn {
        flex: 1;
        background: transparent;
        border: none;
        color: var(--fdb-text-secondary, #a89878);
        padding: 8px 0;
        font-family: inherit;
        font-size: 12px;
        font-weight: bold;
        text-transform: uppercase;
        cursor: pointer;
        transition: all 0.2s;
    }

    .tab-btn:hover {
        color: var(--fdb-text-primary, #d4c5b0);
    }

    .tab-btn.active {
        color: var(--fdb-accent-color, #c9a15a);
        border-bottom: 2px solid var(--fdb-accent-color, #c9a15a);
    }

    .tab-content {
        flex: 1;
        margin-top: 15px;
        overflow-y: auto;
        padding-right: 5px;
    }

    .input-group {
        display: flex;
        flex-direction: column;
        margin-bottom: 12px;
    }

    .input-group label {
        font-size: 11px;
        color: var(--fdb-text-secondary, #a89878);
        text-transform: uppercase;
        margin-bottom: 4px;
        letter-spacing: 0.5px;
    }

    .input-group input[type="text"] {
        background-color: rgba(255, 255, 255, 0.03);
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        color: var(--fdb-text-primary, #d4c5b0);
        padding: 6px 10px;
        font-family: inherit;
        font-size: 12px;
        border-radius: var(--fdb-border-radius, 4px);
    }

    .color-picker-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .color-picker-wrapper input[type="color"] {
        width: 32px;
        height: 26px;
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        background: transparent;
        cursor: pointer;
        padding: 0;
    }

    .color-picker-wrapper input[type="text"] {
        flex: 1;
    }

    .export-section {
        display: flex;
        flex-direction: column;
        height: 100%;
    }

    .export-info {
        font-size: 12px;
        color: var(--fdb-text-secondary, #a89878);
        margin-bottom: 10px;
    }

    .export-section textarea {
        flex: 1;
        background-color: rgba(0, 0, 0, 0.3);
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        color: #7fdba0;
        font-family: 'Courier New', Courier, monospace;
        font-size: 11px;
        padding: 10px;
        resize: none;
        border-radius: var(--fdb-border-radius, 4px);
    }

    .editor-actions {
        display: flex;
        gap: 10px;
        margin-top: 15px;
        border-top: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        padding-top: 15px;
    }

    .btn {
        padding: 8px 16px;
        font-family: inherit;
        font-size: 12px;
        font-weight: bold;
        text-transform: uppercase;
        border: none;
        border-radius: var(--fdb-border-radius, 4px);
        cursor: pointer;
        transition: all 0.15s;
    }

    .btn-primary {
        background-color: var(--fdb-accent-color, #c9a15a);
        color: var(--fdb-background-wood, #2b1d14);
        flex: 1;
    }

    .btn-primary:hover {
        background-color: var(--fdb-accent-color-dark, #8a6a35);
    }

    .btn-secondary {
        background-color: rgba(255, 255, 255, 0.03);
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.08));
        color: var(--fdb-text-secondary, #a89878);
    }

    .btn-secondary:hover {
        background-color: rgba(255, 255, 255, 0.08);
        color: var(--fdb-text-primary, #d4c5b0);
    }

    .btn-cancel {
        background-color: transparent;
        color: var(--fdb-text-secondary, #a89878);
    }

    .btn-cancel:hover {
        color: var(--fdb-text-primary, #d4c5b0);
    }

    /* PAINEL DE PREVIEW (DIREITO) */
    .editor-preview {
        width: 50%;
        background-color: rgba(0, 0, 0, 0.2);
        padding: 25px;
        display: flex;
        flex-direction: column;
    }

    .editor-preview h3 {
        margin: 0;
        color: var(--fdb-text-primary, #d4c5b0);
        font-family: var(--fdb-font-display, 'Playfair Display', serif);
        font-size: 18px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .preview-subtitle {
        font-size: 11px;
        color: var(--fdb-text-secondary, #a89878);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 20px;
    }

    .preview-showcase {
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: center;
        gap: 25px;
        align-items: center;
    }

    /* SIMULADOR DE MENU */
    .simulated-menu {
        width: 280px;
        background-color: var(--fdb-background-color, rgba(10, 10, 10, 0.88));
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.1));
        border-radius: var(--fdb-border-radius, 4px);
        overflow: hidden;
        box-shadow: 0 10px 20px rgba(0,0,0,0.4);
    }

    .sim-header {
        padding: 8px 12px;
        background-color: var(--fdb-accent-color, #c9a15a);
        color: var(--fdb-background-wood, #2b1d14);
        font-family: var(--fdb-font-display, 'Playfair Display', serif);
        font-weight: bold;
        font-size: 13px;
        text-transform: uppercase;
    }

    .sim-content {
        padding: 5px 0;
    }

    .sim-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 6px 12px;
        font-size: 12px;
        color: var(--fdb-text-secondary, #a89878);
    }

    .sim-item.active {
        background-color: rgba(201, 161, 90, 0.08);
        color: var(--fdb-accent-color, #c9a15a);
        font-weight: bold;
    }

    .sim-badge {
        font-size: 11px;
    }

    .sim-box {
        width: 10px;
        height: 10px;
        border: 1px solid var(--fdb-accent-color, #c9a15a);
    }

    .sim-slider {
        padding: 6px 12px;
        font-size: 12px;
        color: var(--fdb-text-secondary, #a89878);
    }

    .sim-bar {
        position: relative;
        height: 3px;
        background-color: rgba(255, 255, 255, 0.15);
        margin-top: 5px;
        border-radius: 1px;
    }

    .sim-fill {
        height: 100%;
        background-color: var(--fdb-accent-color, #c9a15a);
    }

    .sim-marker {
        position: absolute;
        width: 7px;
        height: 7px;
        background-color: var(--fdb-accent-color, #c9a15a);
        top: 50%;
        transform: translate(-50%, -50%) rotate(45deg);
    }

    /* SIMULADOR DE NOTIFY */
    .simulated-notify {
        display: flex;
        align-items: center;
        gap: 12px;
        background-color: var(--fdb-background-color, rgba(10, 10, 10, 0.88));
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.1));
        border-left: 3px solid var(--fdb-status-info, #2980b9);
        border-radius: var(--fdb-border-radius, 4px);
        padding: 10px 15px;
        width: 280px;
        box-shadow: 0 10px 20px rgba(0,0,0,0.4);
    }

    .sim-icon {
        color: var(--fdb-status-info, #2980b9);
        font-size: 16px;
    }

    .sim-notify-text {
        display: flex;
        flex-direction: column;
    }

    .sim-notify-text .title {
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        color: var(--fdb-text-primary, #d4c5b0);
    }

    .sim-notify-text .desc {
        font-size: 9px;
        color: var(--fdb-text-secondary, #a89878);
        margin-top: 1px;
    }
</style>
