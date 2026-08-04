<script>
    import { editorState } from '../store/hudStore';

    let isEditing = false;
    let positions = {};
    let configs = {};
    let global = {};

    let modalX = 50;
    let modalY = 50;
    let isDragging = false;
    let dragStartX = 0;
    let dragStartY = 0;
    let initialModalX = 0;
    let initialModalY = 0;

    function onDragStart(e) {
        if (e.button !== 0) return; // apenas botão esquerdo
        // Evita iniciar o arrasto se clicar no botão de fechar
        if (e.target.closest('.btn-close')) return;
        
        isDragging = true;
        dragStartX = e.clientX;
        dragStartY = e.clientY;
        initialModalX = modalX;
        initialModalY = modalY;
        
        window.addEventListener('mousemove', onDragMove);
        window.addEventListener('mouseup', onDragEnd);
    }

    function onDragMove(e) {
        if (!isDragging) return;
        const dx = e.clientX - dragStartX;
        const dy = e.clientY - dragStartY;
        modalX = initialModalX + dx;
        modalY = initialModalY + dy;
    }

    function onDragEnd() {
        isDragging = false;
        window.removeEventListener('mousemove', onDragMove);
        window.removeEventListener('mouseup', onDragEnd);
    }

    const unsubscribe = editorState.subscribe(state => {
        isEditing = state.isEditing;
        positions = state.positions;
        configs = state.configs;
        global = state.global || {};
    });

    // Categories mapping
    const categories = [
        { id: 'GlobalSettings', name: 'Global Settings', type: 'global' },
        { id: 'PlayerCores', name: 'Player Cores', type: 'elements', items: ['health', 'stamina', 'food', 'water', 'bladder', 'stress', 'cleanliness', 'poison', 'illness', 'drunkenness', 'temperature', 'armor', 'oxygen'] },
        { id: 'HorseCores', name: 'Horse Cores', type: 'elements', items: ['horseHealth', 'horseStamina', 'horseAgitation', 'horseBonding', 'horseFood', 'horseWater'] },
        { id: 'OtherCores', name: 'Other Cores', type: 'elements', items: ['population', 'telegram', 'voice', 'primaryAmmo', 'secondaryAmmo'] },
        { id: 'Buffs', name: 'Buffs', type: 'elements', items: ['coldResistance', 'heatResistance'] },
        { id: 'Extras', name: 'Extras', type: 'elements', items: ['logo', 'money', 'gold', 'job', 'id', 'time', 'pvp'] },
    ];

    let activeCategory = categories[0];
    let selectedElementId = null;

    function selectCategory(cat) {
        activeCategory = cat;
        selectedElementId = null; // reset selected element
    }

    function selectElement(id) {
        selectedElementId = id;
    }

    // State updaters
    function updateGlobal(key, val) {
        editorState.update(s => ({
            ...s,
            global: { ...(s.global || {}), [key]: val }
        }));
    }

    function updateConfig(id, key, val) {
        editorState.update(s => ({
            ...s,
            configs: { 
                ...s.configs, 
                [id]: { ...s.configs[id], [key]: val }
            }
        }));
    }

    function updateBadgeConfig(id, key, val) {
        editorState.update(s => ({
            ...s,
            configs: { 
                ...s.configs, 
                [id]: { 
                    ...s.configs[id], 
                    badge: { ...s.configs[id].badge, [key]: val } 
                }
            }
        }));
    }

    function saveSettings() {
        const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'fdb-hudpremium';
        
        let current;
        editorState.subscribe(s => current = s)();

        fetch(`https://${resourceName}/saveSettings`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                positions: current.positions,
                configs: current.configs,
                global: current.global
            })
        }).catch(err => console.error('[fdb-hudpremium] NUI save erro:', err));

        editorState.update(s => ({ ...s, isEditing: false }));
        fetch(`https://${resourceName}/closeEditor`, { method: 'POST', body: '{}' }).catch(()=>{});
    }

    function resetSettings() {
        // Skipping hard reset of KVP data in UI for now
    }

    function resetPositions() {
        editorState.update(s => ({ ...s, positions: {} }));
    }
</script>

{#if isEditing}
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div class="editor-modal" style="left: {modalX}px; top: {modalY}px;">
    <div class="header" on:mousedown={onDragStart}>
        <h2>HUD Editor</h2>
        <button class="btn-close" on:click={() => editorState.update(s => ({ ...s, isEditing: false }))}>✕</button>
    </div>
    
    <div class="sidebar-layout">
        <!-- Navigation Tabs -->
        <div class="nav-tabs">
            {#each categories as cat}
                <button 
                    class="tab-btn {activeCategory.id === cat.id ? 'active' : ''}"
                    on:click={() => selectCategory(cat)}
                >
                    {cat.name}
                </button>
            {/each}
            
            <div class="nav-spacer"></div>
            <button class="btn-reset" on:click={resetPositions}>Resetar Posições</button>
            <button class="btn-save" on:click={saveSettings}>Salvar & Fechar</button>
        </div>

        <!-- Content Area -->
        <div class="content-area">
            
            {#if activeCategory.type === 'global'}
                <div class="panel global-settings">
                    <h3>Global Settings</h3>
                    
                    <div class="control-group">
                        <label>
                            Grid Size (px)
                            <span class="val">{global.gridSize ?? 10}</span>
                        </label>
                        <input type="range" min="5" max="50" step="1" 
                            value={global.gridSize ?? 10} 
                            on:input={(e) => updateGlobal('gridSize', parseInt(e.target.value))} 
                        />
                    </div>
                    
                    <div class="control-group row-checkbox">
                        <label for="chk-darkbg">Show Dark Background (Editor)</label>
                        <input id="chk-darkbg" type="checkbox" 
                            checked={global.showDarkBg ?? false}
                            on:change={(e) => updateGlobal('showDarkBg', e.target.checked)}
                        />
                    </div>

                    <div class="control-group">
                        <label>Minimap Layout</label>
                        <select 
                            value={global.minimap ?? 'Regular'}
                            on:change={(e) => updateGlobal('minimap', e.target.value)}
                        >
                            <option value="Off">Off</option>
                            <option value="Regular">Regular</option>
                            <option value="Expanded">Expanded</option>
                            <option value="Compass">Compass</option>
                        </select>
                    </div>
                </div>

            {:else if activeCategory.type === 'elements'}
                
                {#if !selectedElementId}
                    <!-- Master View: List of elements -->
                    <div class="panel master-view">
                        <h3>{activeCategory.name}</h3>
                        <p class="subtitle">Select an element to customize.</p>
                        <div class="element-grid">
                            {#each activeCategory.items as itemId}
                                {#if configs[itemId]}
                                    <!-- svelte-ignore a11y-click-events-have-key-events -->
                                    <div class="element-card" on:click={() => selectElement(itemId)}>
                                        <div class="element-name">{itemId}</div>
                                        <div class="status {configs[itemId].visible ? 'on' : 'off'}">
                                            {configs[itemId].visible ? 'Visible' : 'Hidden'}
                                        </div>
                                    </div>
                                {/if}
                            {/each}
                        </div>
                    </div>
                {:else}
                    <!-- Detail View -->
                    <div class="panel detail-view">
                        <div class="detail-header">
                            <button class="btn-back" on:click={() => { selectedElementId = null; }}>← Back</button>
                            <h3>{selectedElementId}</h3>
                        </div>

                        {#if configs[selectedElementId]}
                            {@const cfg = configs[selectedElementId]}
                            
                            <!-- Visibility -->
                            <div class="control-group row-checkbox">
                                <label for="chk-vis">Visible</label>
                                <input id="chk-vis" type="checkbox" 
                                    checked={cfg.visible}
                                    on:change={(e) => updateConfig(selectedElementId, 'visible', e.target.checked)}
                                />
                            </div>

                            <!-- Scale -->
                            <div class="control-group">
                                <label>
                                    Individual Scale 
                                    <span class="val">{cfg.scale.toFixed(2)}x</span>
                                </label>
                                <input type="range" min="0.5" max="2.0" step="0.05" 
                                    value={cfg.scale} 
                                    on:input={(e) => updateConfig(selectedElementId, 'scale', parseFloat(e.target.value))} 
                                />
                            </div>

                            <hr>

                            <!-- Colors -->
                            <h4>Colors</h4>
                            <div class="color-grid">
                                <div class="color-picker">
                                    <label>Outer Color</label>
                                    <input type="color" value={cfg.outerColor} on:input={(e) => updateConfig(selectedElementId, 'outerColor', e.target.value)} />
                                </div>
                                <div class="color-picker">
                                    <label>Outer Damage</label>
                                    <input type="color" value={cfg.outerDamageColor} on:input={(e) => updateConfig(selectedElementId, 'outerDamageColor', e.target.value)} />
                                </div>
                                <div class="color-picker">
                                    <label>Gold Color</label>
                                    <input type="color" value={cfg.goldColor} on:input={(e) => updateConfig(selectedElementId, 'goldColor', e.target.value)} />
                                </div>
                                <div class="color-picker">
                                    <label>Max Outer</label>
                                    <input type="color" value={cfg.maxOuterColor} on:input={(e) => updateConfig(selectedElementId, 'maxOuterColor', e.target.value)} />
                                </div>
                                <div class="color-picker">
                                    <label>Inner Color</label>
                                    <input type="color" value={cfg.innerColor} on:input={(e) => updateConfig(selectedElementId, 'innerColor', e.target.value)} />
                                </div>
                                <div class="color-picker">
                                    <label>Track Color</label>
                                    <input type="color" value={cfg.trackColor || '#000000'} on:input={(e) => updateConfig(selectedElementId, 'trackColor', e.target.value)} />
                                </div>
                            </div>

                            <hr>

                            <!-- Segments -->
                            <h4>Segments</h4>
                            <div class="control-group row-checkbox">
                                <label for="chk-seg">Show Segments</label>
                                <input id="chk-seg" type="checkbox" 
                                    checked={cfg.showSegments}
                                    on:change={(e) => updateConfig(selectedElementId, 'showSegments', e.target.checked)}
                                />
                            </div>
                            {#if cfg.showSegments}
                                <div class="control-group">
                                    <label>
                                        Segments Count 
                                        <span class="val">{cfg.segmentsCount}</span>
                                    </label>
                                    <input type="range" min="2" max="20" step="1" 
                                        value={cfg.segmentsCount} 
                                        on:input={(e) => updateConfig(selectedElementId, 'segmentsCount', parseInt(e.target.value))} 
                                    />
                                </div>
                            {/if}

                            <hr>

                            <!-- Badges -->
                            <h4>Badge / Tip Settings</h4>
                            <div class="control-group row-checkbox">
                                <label for="chk-bval">Show Value Text</label>
                                <input id="chk-bval" type="checkbox" 
                                    checked={cfg.badge.showValue}
                                    on:change={(e) => updateBadgeConfig(selectedElementId, 'showValue', e.target.checked)}
                                />
                            </div>
                            <div class="control-group row-checkbox">
                                <label for="chk-bbg">Show Background</label>
                                <input id="chk-bbg" type="checkbox" 
                                    checked={cfg.badge.showBackground}
                                    on:change={(e) => updateBadgeConfig(selectedElementId, 'showBackground', e.target.checked)}
                                />
                            </div>
                            <div class="color-picker">
                                <label>Text Color</label>
                                <input type="color" value={cfg.badge.textColor} on:input={(e) => updateBadgeConfig(selectedElementId, 'textColor', e.target.value)} />
                            </div>
                            <div class="control-group">
                                <label>
                                    Font Size (px)
                                    <span class="val">{cfg.badge.fontSize}</span>
                                </label>
                                <input type="range" min="8" max="24" step="1" 
                                    value={cfg.badge.fontSize} 
                                    on:input={(e) => updateBadgeConfig(selectedElementId, 'fontSize', parseInt(e.target.value))} 
                                />
                            </div>
                            <div class="control-group">
                                <label>
                                    Badge Scale
                                    <span class="val">{cfg.badge.badgeScale.toFixed(2)}x</span>
                                </label>
                                <input type="range" min="0.5" max="2.0" step="0.1" 
                                    value={cfg.badge.badgeScale} 
                                    on:input={(e) => updateBadgeConfig(selectedElementId, 'badgeScale', parseFloat(e.target.value))} 
                                />
                            </div>
                            <div class="control-group">
                                <label>Position</label>
                                <select 
                                    value={cfg.badge.position}
                                    on:change={(e) => updateBadgeConfig(selectedElementId, 'position', e.target.value)}
                                >
                                    <option value="top">Top</option>
                                    <option value="bottom">Bottom</option>
                                    <option value="left">Left</option>
                                    <option value="right">Right</option>
                                </select>
                            </div>

                        {/if}
                    </div>
                {/if}
            {/if}

        </div>
    </div>
</div>

<!-- Global Editor Dark Background Preview -->
{#if global.showDarkBg}
    <div class="editor-dark-bg"></div>
{/if}
{/if}

<style>
    .editor-modal {
        position: absolute;
        width: 550px;
        height: 550px;
        background: rgba(15, 15, 18, 0.95);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 8px;
        color: #eee;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        display: flex;
        flex-direction: column;
        z-index: 10000;
        pointer-events: auto;
        box-shadow: 10px 10px 30px rgba(0,0,0,0.5);
        overflow: hidden;
    }

    .editor-dark-bg {
        position: absolute;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(0,0,0,0.6);
        z-index: 9999;
        pointer-events: none;
    }

    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px 20px;
        background: rgba(255, 255, 255, 0.05);
        border-bottom: 1px solid rgba(255,255,255,0.1);
        cursor: grab;
    }

    .header:active {
        cursor: grabbing;
    }

    .header h2 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .btn-close {
        background: none;
        border: none;
        color: #aaa;
        font-size: 20px;
        cursor: pointer;
        transition: color 0.2s;
    }

    .btn-close:hover {
        color: #ff4500;
    }

    .sidebar-layout {
        display: flex;
        flex: 1;
        overflow: hidden;
    }

    .nav-tabs {
        width: 200px;
        background: rgba(0, 0, 0, 0.2);
        display: flex;
        flex-direction: column;
        border-right: 1px solid rgba(255,255,255,0.05);
        padding: 10px 0;
    }

    .tab-btn {
        background: transparent;
        border: none;
        color: #aaa;
        text-align: left;
        padding: 15px 20px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        border-left: 3px solid transparent;
    }

    .tab-btn:hover {
        background: rgba(255,255,255,0.05);
        color: #fff;
    }

    .tab-btn.active {
        background: rgba(255, 255, 255, 0.1);
        color: #fff;
        border-left-color: #2e8b57;
    }

    .nav-spacer {
        flex: 1;
    }

    .btn-reset {
        margin: 15px 15px 0 15px;
        padding: 12px;
        background: #b22222;
        color: white;
        border: none;
        border-radius: 6px;
        font-weight: bold;
        cursor: pointer;
        transition: background 0.2s;
    }

    .btn-reset:hover {
        background: #cd5c5c;
    }

    .btn-save {
        margin: 15px;
        padding: 12px;
        background: #2e8b57;
        color: white;
        border: none;
        border-radius: 6px;
        font-weight: bold;
        cursor: pointer;
        transition: background 0.2s;
    }

    .btn-save:hover {
        background: #3cb371;
    }

    .content-area {
        flex: 1;
        padding: 20px;
        overflow-y: auto;
    }

    .panel {
        animation: fadeIn 0.3s ease;
    }

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(5px); }
        to { opacity: 1; transform: translateY(0); }
    }

    h3 {
        margin-top: 0;
        margin-bottom: 5px;
        font-size: 18px;
        color: #fff;
    }

    .subtitle {
        color: #888;
        font-size: 13px;
        margin-bottom: 20px;
    }

    h4 {
        margin-top: 20px;
        margin-bottom: 15px;
        color: #bbb;
        font-size: 14px;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    hr {
        border: none;
        border-top: 1px solid rgba(255,255,255,0.1);
        margin: 25px 0;
    }

    /* Master View Grid */
    .element-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 10px;
    }

    .element-card {
        background: rgba(255,255,255,0.05);
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 6px;
        padding: 15px;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

    .element-card:hover {
        background: rgba(255,255,255,0.1);
        border-color: rgba(255,255,255,0.3);
        transform: translateY(-2px);
    }

    .element-name {
        font-weight: bold;
        font-size: 14px;
        margin-bottom: 8px;
        text-transform: capitalize;
    }

    .status {
        font-size: 11px;
        font-weight: bold;
        padding: 3px 6px;
        border-radius: 4px;
        align-self: flex-start;
    }

    .status.on {
        background: rgba(46, 139, 87, 0.2);
        color: #3cb371;
    }
    .status.off {
        background: rgba(255, 69, 0, 0.2);
        color: #ff4500;
    }

    /* Detail View */
    .detail-header {
        display: flex;
        align-items: center;
        gap: 15px;
        margin-bottom: 25px;
    }

    .btn-back {
        background: rgba(255,255,255,0.1);
        border: none;
        color: #fff;
        padding: 6px 12px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
        font-weight: bold;
        transition: background 0.2s;
    }

    .btn-back:hover {
        background: rgba(255,255,255,0.2);
    }

    /* Form Controls */
    .control-group {
        display: flex;
        flex-direction: column;
        margin-bottom: 20px;
    }

    .control-group.row-checkbox {
        flex-direction: row-reverse;
        justify-content: flex-end;
        align-items: center;
        gap: 10px;
        margin-bottom: 15px;
    }

    .control-group label {
        display: flex;
        justify-content: space-between;
        font-size: 13px;
        color: #ccc;
        margin-bottom: 8px;
    }

    .control-group .val {
        color: #4da6ff;
        font-weight: bold;
    }

    input[type="range"] {
        width: 100%;
        accent-color: #2e8b57;
        cursor: pointer;
    }

    select {
        background: rgba(0,0,0,0.3);
        border: 1px solid rgba(255,255,255,0.2);
        color: white;
        padding: 8px;
        border-radius: 4px;
        outline: none;
        cursor: pointer;
        font-family: inherit;
    }
    select:focus {
        border-color: #2e8b57;
    }

    /* Color Grid */
    .color-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 15px;
    }

    .color-picker {
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: rgba(0,0,0,0.2);
        padding: 8px 12px;
        border-radius: 6px;
        border: 1px solid rgba(255,255,255,0.05);
    }

    .color-picker label {
        font-size: 12px;
        color: #ccc;
    }

    input[type="color"] {
        -webkit-appearance: none;
        border: none;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        cursor: pointer;
        padding: 0;
        background: none;
    }
    input[type="color"]::-webkit-color-swatch-wrapper {
        padding: 0;
    }
    input[type="color"]::-webkit-color-swatch {
        border: 1px solid rgba(255,255,255,0.3);
        border-radius: 50%;
    }

    /* Custom Checkbox */
    input[type="checkbox"] {
        appearance: none;
        width: 40px;
        height: 20px;
        background: rgba(255,255,255,0.1);
        border-radius: 10px;
        position: relative;
        cursor: pointer;
        transition: background 0.3s;
        outline: none;
    }
    input[type="checkbox"]::after {
        content: '';
        position: absolute;
        top: 2px;
        left: 2px;
        width: 16px;
        height: 16px;
        background: #888;
        border-radius: 50%;
        transition: transform 0.3s, background 0.3s;
    }
    input[type="checkbox"]:checked {
        background: rgba(46, 139, 87, 0.5);
    }
    input[type="checkbox"]:checked::after {
        transform: translateX(20px);
        background: #2e8b57;
    }
</style>
