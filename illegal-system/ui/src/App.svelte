<script>
    import { onMount } from 'svelte';
    import './app.css';

    let isEditorOpen = false;
    let isPlacementMode = false;
    let currentTab = 'stores';
    let isCursorEnabled = true;

    let stores = [];
    
    // Store being edited
    let editingStoreId = null;
    let storeName = '';
    let currentCoords = null;
    let doorCoords = null;
    let registerCoords = null;
    let registerHeading = 0.0;
    let currentSpawns = [];
    
    // Select bindings
    let guardModel = 'A_M_M_ValTownfolk_01';
    let dogModel = 'A_C_DogHusky_01';
    let guardQuantity = 1;
    let dogQuantity = 1;

    function updateGhosts() {
        fetch(`https://${GetParentResourceName()}/updateEditorMarkers`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({
                store: currentCoords,
                door: doorCoords,
                register: registerCoords,
                spawns: currentSpawns
            })
        });
    }

    onMount(() => {
        window.addEventListener('message', (event) => {
            const data = event.data;
            if (data.action === "openEditor") {
                isEditorOpen = true;
                stores = data.stores || [];
                currentTab = 'stores';
            }
            if (data.action === "closeEditor") {
                isEditorOpen = false;
                fetch(`https://${GetParentResourceName()}/clearEditorGhosts`, { method: 'POST', body: '{}' });
            }
            if (data.action === "startPlacement") {
                isEditorOpen = false;
                isPlacementMode = true;
            }
            if (data.action === "stopPlacement") {
                isEditorOpen = true;
                isPlacementMode = false;
                if (data.result) {
                    if (data.spawnType === "store") {
                        currentCoords = data.result;
                    } else if (data.spawnType === "door") {
                        doorCoords = data.result;
                    } else if (data.spawnType === "register") {
                        registerCoords = data.result;
                        registerHeading = data.heading || 0.0;
                    } else {
                        currentSpawns = [...currentSpawns, {
                            type: data.spawnType,
                            model: data.model,
                            coords: data.result,
                            heading: data.heading || 0.0,
                            quantity: data.spawnType === "guard" ? guardQuantity : (data.spawnType === "dog" ? dogQuantity : 1)
                        }];
                    }
                }
                updateGhosts();
            }
        });
    });

    function post(endpoint, data = {}) {
        return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    function closeEditor() {
        isEditorOpen = false;
        fetch(`https://${GetParentResourceName()}/clearEditorGhosts`, { method: 'POST', body: '{}' });
        post('closeEditor');
    }

    function toggleLock() {
        isCursorEnabled = !isCursorEnabled;
        post('toggleCursor', { enabled: isCursorEnabled });
    }

    function editStore(store) {
        editingStoreId = store.id;
        storeName = store.name;
        currentCoords = store.coords;
        doorCoords = store.doorCoords;
        registerCoords = store.registerCoords;
        registerHeading = store.registerHeading || 0.0;
        currentSpawns = store.spawns || [];
        currentTab = 'editor';
        updateGhosts();
    }

    function createStore() {
        editingStoreId = null;
        storeName = '';
        currentCoords = null;
        doorCoords = null;
        registerCoords = null;
        registerHeading = 0.0;
        currentSpawns = [];
        currentTab = 'editor';
        updateGhosts();
    }

    function removeSpawn(index) {
        currentSpawns = currentSpawns.filter((_, i) => i !== index);
        updateGhosts();
    }

    function startSpawn(type) {
        let model = "";
        if (type === "guard") model = guardModel;
        if (type === "dog") model = dogModel;
        if (type === "store") model = "A_M_M_ValTownfolk_01";
        if (type === "door") model = "p_crate01x";
        if (type === "register") model = "p_crate01x";
        
        isEditorOpen = false;
        isPlacementMode = true;
        
        post('startPlacement', { type, model });
    }

    function saveStore() {
        if (!storeName.trim()) {
            console.log("Nome da loja vazio!");
            return;
        }

        post('saveStore', {
            id: editingStoreId,
            name: storeName.trim(),
            coords: currentCoords,
            doorCoords: doorCoords,
            registerCoords: registerCoords,
            registerHeading: registerHeading,
            spawns: currentSpawns
        }).then(() => {
            currentTab = 'stores';
            post('refreshStores'); // if you have a refresh endpoint or just close
            closeEditor();
        });
    }
</script>

{#if isEditorOpen}
<div id="admin-menu">
    <div class="admin-header">
        <div class="lock-icon" class:locked={!isCursorEnabled} class:unlocked={isCursorEnabled} on:click={toggleLock}></div>
        <h2>Editor de Assaltos</h2>
        <div class="close-icon" on:click={closeEditor}></div>
    </div>

    <div class="admin-tabs">
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div class="tab-label" class:active={currentTab === 'stores'} on:click={() => currentTab = 'stores'}>Lojas</div>
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div class="tab-label" class:active={currentTab === 'editor'} on:click={() => currentTab = 'editor'}>Configurar</div>
    </div>

    <div class="admin-content">
        {#if currentTab === 'stores'}
            <div id="tab-stores" class="tab-pane active">
                <button class="admin-button" on:click={createStore} style="margin-bottom: 15px; background: #3498db; color: white;">+ Nova Loja</button>
                <div class="list-container">
                    {#each stores as store}
                        <div class="zone-item">
                            <span style="font-weight: bold;">{store.name}</span>
                            <button class="admin-button" style="width: auto; margin-top: 0; padding: 5px 10px;" on:click={() => editStore(store)}>Editar</button>
                        </div>
                    {/each}
                </div>
            </div>
        {/if}

        {#if currentTab === 'editor'}
            <div id="tab-editor" class="tab-pane active">
                <div class="form-group">
                    <label>Nome da Loja</label>
                    <input type="text" bind:value={storeName} placeholder="Ex: Valentine General Store">
                </div>

                <div class="form-group" style="display: flex; gap: 10px;">
                    <div style="flex: 1;">
                        <label>Modelo do Guarda</label>
                        <select bind:value={guardModel} style="width: 100%; padding: 10px; background-color: #1a1a1a; border: 1px solid #333; color: #fff; border-radius: 4px; outline: none;">
                            <option value="A_M_M_ValTownfolk_01">Valentine Townfolk</option>
                            <option value="A_M_M_RHDTownfolk_01">Rhodes Townfolk</option>
                            <option value="A_M_M_SDTownfolk_01">Saint Denis Townfolk</option>
                            <option value="G_M_M_BountyHunters_01">Bounty Hunter</option>
                            <option value="U_M_M_BHT_BANDITOMINE">Bandito Mine</option>
                        </select>
                    </div>
                    <div style="flex: 0.3;">
                        <label>Qtd.</label>
                        <input type="number" bind:value={guardQuantity} min="1" max="5" style="width: 100%; padding: 10px; background-color: #1a1a1a; border: 1px solid #333; color: #fff; border-radius: 4px; outline: none;">
                    </div>
                    <div style="display: flex; align-items: flex-end;">
                        <button class="admin-button spawn-btn" style="margin: 0; height: 41px; padding: 0 15px;" on:click={() => startSpawn('guard')}>👮 Add</button>
                    </div>
                </div>

                <div class="form-group" style="display: flex; gap: 10px;">
                    <div style="flex: 1;">
                        <label>Modelo do Cachorro</label>
                        <select bind:value={dogModel} style="width: 100%; padding: 10px; background-color: #1a1a1a; border: 1px solid #333; color: #fff; border-radius: 4px; outline: none;">
                            <option value="A_C_DogHusky_01">Husky</option>
                            <option value="A_C_DogCollie_01">Collie</option>
                            <option value="A_C_DogHound_01">Hound</option>
                            <option value="A_C_DogRufus_01">Rufus</option>
                        </select>
                    </div>
                    <div style="flex: 0.3;">
                        <label>Qtd.</label>
                        <input type="number" bind:value={dogQuantity} min="1" max="5" style="width: 100%; padding: 10px; background-color: #1a1a1a; border: 1px solid #333; color: #fff; border-radius: 4px; outline: none;">
                    </div>
                    <div style="display: flex; align-items: flex-end;">
                        <button class="admin-button spawn-btn" style="margin: 0; height: 41px; padding: 0 15px;" on:click={() => startSpawn('dog')}>🐕 Add</button>
                    </div>
                </div>

                <div class="form-group">
                    <label>Posições Fixas</label>
                    <div class="spawn-buttons">
                        <button class="admin-button spawn-btn" on:click={() => startSpawn('store')}>📍 Centro da Loja</button>
                        <button class="admin-button spawn-btn" on:click={() => startSpawn('door')}>🚪 Porta Principal</button>
                        <button class="admin-button spawn-btn" on:click={() => startSpawn('register')}>💰 Registradora</button>
                    </div>
                </div>

                <div class="list-container" style="max-height: 150px;">
                    {#if currentCoords}
                    <div class="spawn-item"><span><b>LOJA</b> definida</span></div>
                    {/if}
                    {#if doorCoords}
                    <div class="spawn-item"><span><b>PORTA</b> definida</span></div>
                    {/if}
                    {#if registerCoords}
                    <div class="spawn-item"><span><b>CAIXA</b> definida</span></div>
                    {/if}

                    {#each currentSpawns as spawn, index}
                        <div class="spawn-item">
                            <span><b>{spawn.type.toUpperCase()}</b> x{spawn.quantity || 1}: {spawn.model || 'N/A'}</span>
                            <button class="admin-button" style="width: auto; margin-top: 0; padding: 2px 10px; background: #e74c3c;" on:click={() => removeSpawn(index)}>X</button>
                        </div>
                    {/each}
                </div>

                <button class="admin-button" style="margin-top: 20px; background: #3498db; color: white;" on:click={saveStore}>Salvar Loja</button>
                <button class="admin-button" style="margin-top: 5px; background: #555;" on:click={() => currentTab = 'stores'}>Voltar</button>
            </div>
        {/if}
    </div>
</div>
{/if}

{#if isPlacementMode}
<div class="noclip-hud noclip-hud--visible" aria-hidden="false">
    <div class="noclip-hud__inner">
        <div class="noclip-hud__head">
            <span class="noclip-hud__title" id="ph-title">Posicionamento</span>
            <span class="noclip-hud__speed" id="ph-speed">Normal</span>
        </div>
        <div class="noclip-hud__accent"></div>
        <ul class="noclip-hud__lines" id="ph-lines">
            <li class="noclip-hud__row">
                <div class="noclip-hud__keys">
                    <span class="noclip-hud__kbd">W</span><span class="noclip-hud__kbd">A</span><span class="noclip-hud__kbd">S</span><span class="noclip-hud__kbd">D</span>
                </div>
                <div class="noclip-hud__desc">Mover marcador</div>
            </li>
            <li class="noclip-hud__row">
                <div class="noclip-hud__keys">
                    <span class="noclip-hud__kbd">Q</span><span class="noclip-hud__kbd">E</span>
                </div>
                <div class="noclip-hud__desc">Subir / Descer</div>
            </li>
            <li class="noclip-hud__row">
                <div class="noclip-hud__keys">
                    <span class="noclip-hud__kbd">LAlt</span>
                </div>
                <div class="noclip-hud__desc">Grudar no chão</div>
            </li>
            <li class="noclip-hud__row">
                <div class="noclip-hud__keys">
                    <span class="noclip-hud__kbd">Scroll</span>
                </div>
                <div class="noclip-hud__desc">Girar fantasma</div>
            </li>
            <li class="noclip-hud__row">
                <div class="noclip-hud__keys">
                    <span class="noclip-hud__kbd">Enter</span>
                </div>
                <div class="noclip-hud__desc">Confirmar</div>
            </li>
            <li class="noclip-hud__row">
                <div class="noclip-hud__keys">
                    <span class="noclip-hud__kbd">Backspace</span>
                </div>
                <div class="noclip-hud__desc">Cancelar</div>
            </li>
        </ul>
    </div>
</div>
{/if}
