<script>
    import { SvelteFlow, Controls, Background, BackgroundVariant, addEdge } from '@xyflow/svelte';
    import '@xyflow/svelte/dist/style.css';
    import Modal from './Modal.svelte';

    let { isPlacementMode = $bindable(false) } = $props();
    
    let nodes = $state([]);
    let edges = $state([]);
    
    let nextId = 1;
    let heistId = $state("novo_assalto");
    let heistName = $state("Novo Assalto");
    
    // Lista de tipos permitidos na diretiva
    const nodeTypesList = [
        { type: 'start', label: 'Start (Lógica)', color: '#7f8c8d' },
        { type: 'wait', label: 'Wait (Lógica)', color: '#7f8c8d' },
        { type: 'end', label: 'End (Lógica)', color: '#7f8c8d' },
        { type: 'lockpick_door', label: 'Lockpick Door (Target)', color: '#2980b9' },
        { type: 'open_door', label: 'Open Door (Target)', color: '#2980b9' },
        { type: 'crack_register', label: 'Loot / Roubar (Target)', color: '#2980b9' },
        { type: 'minigame', label: 'Minigame (Ação)', color: '#e67e22' },
        { type: 'spawn_ped', label: 'Spawn Ped (Ação)', color: '#e67e22' },
        { type: 'dispatch', label: 'Dispatch (Ação)', color: '#e67e22' },
        { type: 'player_notification', label: 'Notification (Feedback)', color: '#f1c40f' },
        { type: 'trigger_model', label: 'Trigger Model (Start)', color: '#8e44ad' },
        { type: 'check_requirements', label: 'Check Req (Validação)', color: '#16a085' },
        { type: 'minigame_action', label: 'Minigame Action (Ação)', color: '#e67e22' },
        { type: 'spawn_prop', label: 'Spawn Prop (Ação)', color: '#e67e22' },
        { type: 'crime_reward_and_cooldown', label: 'Crime Reward & CD', color: '#c0392b' },
        { type: 'risk_session', label: 'Risk Session (Ação)', color: '#d35400' },
        { type: 'play_animation', label: 'Play Anim (Fluxo)', color: '#8e44ad' }
    ];

    let selectedNodeId = $state(null);
    let selectedNodeData = $state(null);
    let selectedEdgeId = $state(null);

    function onDragStart(event, nodeType) {
        event.dataTransfer.setData('application/svelteflow', nodeType);
        event.dataTransfer.effectAllowed = 'move';
    }

    function addNode(type, position = { x: 250, y: 150 }) {
        if (position.x === 250 && position.y === 150) {
            position.x = 250 + (nodes.length * 20);
            position.y = 150 + (nodes.length * 20);
        }
        
        const config = nodeTypesList.find(n => n.type === type);
        
        let initialData = { label: config.label };
        if (['open_door', 'lockpick_door', 'crack_register', 'minigame'].includes(type)) {
            initialData.coords = null;
            initialData.minTime = 5;
            initialData.prompt = "Interagir";
        }
        if (type === 'trigger_model') {
            initialData.models = "p_crate01x";
            initialData.distance = 3.5;
            initialData.prompt = "Interagir";
            initialData.icon = "fas fa-hand";
        }
        if (type === 'minigame_action') {
            initialData.minigameType = "tierbar";
            initialData.minigameDuration = 5000;
        }
        if (type === 'check_requirements') {
            initialData.item = "shovel";
            initialData.amount = 1;
            initialData.failMessage = "Você precisa de uma pá.";
        }
        if (type === 'minigame_action') {
            initialData.minTime = 5;
            initialData.animDict = "amb@medic@standing@kneel@base";
            initialData.animName = "base";
            initialData.propModel = "prop_tool_shovel";
            initialData.boneName = "SKEL_R_Hand";
            initialData.minigameType = "tierbar";
            initialData.minigameDuration = 5000;
        }
        if (type === 'spawn_prop') {
            initialData.model = "p_crate01x";
            initialData.offsetX = 0.0;
            initialData.offsetY = 1.0;
            initialData.offsetZ = -1.0;
            initialData.heading = 0.0;
        }
        if (type === 'crime_reward_and_cooldown') {
            initialData.crimeType = "grave_robbery";
            initialData.cooldownPrefix = "grave";
            initialData.successMessage = "Você encontrou algo!";
        }
        if (type === 'risk_session') {
            initialData.title = "RISCO";
            initialData.criticalText = "CUIDADO";
            initialData.checkInterval = 500;
            initialData.sprintThreshold = 6.0;
            initialData.runThreshold = 2.0;
            initialData.sprintIncrease = 15.0;
            initialData.runIncrease = 5.0;
            initialData.idleDecay = 2.0;
            initialData.maxChance = 100.0;
            initialData.duration = 10000;
            initialData.failMessage = "Você fez muito barulho!";
        }
        if (type === 'play_animation') {
            initialData.animDict = "amb@medic@standing@kneel@base";
            initialData.animName = "base";
            initialData.propModel = "";
            initialData.durationMs = 1000;
        }
        
        const newNode = {
            id: `node_${nextId++}`,
            type: 'default',
            position,
            data: initialData,
            style: `background: ${config.color}; color: white; border: none; border-radius: 4px; padding: 10px; min-width: 120px; text-align: center;`
        };
        
        newNode.data.realType = type;
        nodes = [...nodes, newNode];
    }

    function onDrop(event) {
        event.preventDefault();
        const type = event.dataTransfer.getData('application/svelteflow');
        if (!type) return;

        const position = {
            x: event.clientX - 300, // offset do sidebar aproximado
            y: event.clientY - 50
        };

        addNode(type, position);
    }

    function onDragOver(event) {
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
    }

    function selectNode(event, node) {
        if (!node) node = event.node || event.detail?.node;
        if (node) {
            selectedNodeId = node.id;
            selectedNodeData = node.data;
        }
        selectedEdgeId = null;
    }
    
    function onEdgeClick(event, edge) {
        if (!edge) edge = event.edge || event.detail?.edge;
        if (edge) selectedEdgeId = edge.id;
        selectedNodeId = null;
        selectedNodeData = null;
    }
    
    const onConnect = (connection) => {
        edges = addEdge(connection, edges.filter(e => e.source !== connection.source));
    };
    
    function onPaneClick() {
        selectedNodeId = null;
        selectedNodeData = null;
        selectedEdgeId = null;
    }

    function deleteSelectedNode() {
        if (selectedNodeId) {
            nodes = nodes.filter(n => n.id !== selectedNodeId);
            edges = edges.filter(e => e.source !== selectedNodeId && e.target !== selectedNodeId);
            selectedNodeId = null;
            selectedNodeData = null;
        }
    }

    function deleteSelectedEdge() {
        if (selectedEdgeId) {
            edges = edges.filter(e => e.id !== selectedEdgeId);
            selectedEdgeId = null;
        }
    }

    function startPlacement() {
        if (!selectedNodeId) return;
        isPlacementMode = true;
        // Pede pra NUI iniciar a camera no client
        fetch(`https://${GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({
                type: 'point', // Tipo generico para pegar só a coordenada
                model: '',     // Vazio para não carregar prop nenhum (apenas o marker)
                callbackAction: 'stopPlacementNode',
                extraData: { nodeId: selectedNodeId }
            })
        }).catch(err => console.error(err));
    }

    function startPlacementItem(listType, index, model) {
        if (!selectedNodeId) return;
        isPlacementMode = true;
        
        let pType = listType === 'peds' ? 'guard' : 'point';
        if (listType === 'props') {
            pType = 'prop'; // This will trigger SpawnGhost for objects
        }

        fetch(`https://${GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({
                type: pType,
                model: model || '',
                callbackAction: 'stopPlacementListItem',
                extraData: { nodeId: selectedNodeId, index: index, type: listType }
            })
        }).catch(err => console.error(err));
    }

    let isSaving = $state(false);

    // Exportador de JSON para salvar no banco
    function saveHeist() {
        if (!heistId.trim() || !heistName.trim()) {
            console.log("ID ou Nome vazio");
            alert("Preencha o ID e o Nome do assalto antes de salvar!");
            return;
        }

        isSaving = true;

        const graph = {
            nodes: {},
            edges: []
        };

        // Formata os nós pro padrão exato exigido nas Fases 1/2
        nodes.forEach(n => {
            const nodeExport = {
                type: n.data.realType,
                data: {}
            };
            
            for (const [k, v] of Object.entries(n.data)) {
                if (k !== 'label' && k !== 'realType') {
                    nodeExport.data[k] = v;
                }
            }
            nodeExport.data.uiPosition = n.position;
            
            graph.nodes[n.id] = nodeExport;
        });

        // Formata as arestas
        edges.forEach(e => {
            graph.edges.push({
                source: e.source,
                target: e.target
            });
        });

        fetch(`https://${GetParentResourceName()}/saveHeistGraph`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({
                id: heistId,
                name: heistName,
                graph: graph
            })
        }).then(resp => resp.json()).then(resp => {
            isSaving = false;
            loadHeists();
            selectedSavedHeist = heistId;
        }).catch(err => {
            console.error(err);
            isSaving = false;
        });
    }

    let showModal = $state(false);
    let modalConfig = $state({
        title: "",
        message: "",
        type: "alert",
        onConfirm: () => {},
        onCancel: () => {}
    });

    function deleteHeist() {
        if (!heistId.trim()) return;
        
        modalConfig = {
            title: "Deletar Assalto",
            message: `Tem certeza que deseja deletar o assalto '${heistName}'? Esta ação não pode ser desfeita.`,
            type: "confirm",
            onConfirm: () => {
                showModal = false;
                executeDelete();
            },
            onCancel: () => {
                showModal = false;
            }
        };
        showModal = true;
    }
    
    function executeDelete() {
        fetch(`https://${GetParentResourceName()}/deleteHeist`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ id: heistId })
        }).then(res => res.json()).then(data => {
            if (data.success) {
                nodes = [];
                edges = [];
                heistId = "novo_assalto";
                heistName = "Novo Assalto";
                selectedSavedHeist = "";
                loadHeists();
                
                modalConfig = {
                    title: "Sucesso",
                    message: "Assalto deletado com sucesso!",
                    type: "alert",
                    onConfirm: () => { showModal = false; },
                    onCancel: () => {}
                };
                showModal = true;
            } else {
                modalConfig = {
                    title: "Erro",
                    message: data.message || "Erro ao deletar.",
                    type: "alert",
                    onConfirm: () => { showModal = false; },
                    onCancel: () => {}
                };
                showModal = true;
            }
        }).catch(err => console.error("Error deleting:", err));
    }

    let savedHeists = $state([]);
    let selectedSavedHeist = $state("");

    function loadHeists() {
        fetch(`https://${GetParentResourceName()}/getHeists`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        }).then(res => res.json()).then(data => {
            savedHeists = data || [];
        }).catch(err => console.error("Error fetching heists:", err));
    }

    function applyHeist() {
        if (!selectedSavedHeist) return;
        const heist = savedHeists.find(h => h.id === selectedSavedHeist);
        if (heist) {
            heistId = heist.id;
            heistName = heist.name;
            
            // Reconstruct nodes
            const newNodes = [];
            let maxId = 0;
            for (const [idStr, nodeData] of Object.entries(heist.graph.nodes)) {
                const idNum = parseInt(idStr) || parseInt(idStr.replace('node_', ''));
                if (idNum > maxId) maxId = idNum;
                
                const config = nodeTypesList.find(n => n.type === nodeData.type) || { label: nodeData.type, color: '#333' };
                
                newNodes.push({
                    id: idStr,
                    type: 'default',
                    position: nodeData.data.uiPosition || { x: Math.random() * 200, y: Math.random() * 200 },
                    style: `background: ${config.color}; color: white; border: none; border-radius: 4px; padding: 10px; min-width: 120px; text-align: center;`,
                    data: {
                        ...nodeData.data,
                        label: config.label,
                        realType: nodeData.type
                    }
                });
            }
            nodes = newNodes;
            nextId = maxId + 1;
            
            // Reconstruct edges
            edges = heist.graph.edges.map(e => ({
                id: `e-${e.source}-${e.target}`,
                source: e.source,
                target: e.target
            }));
        }
    }
    
    // Escutador global caso voltemos do placement
    import { onMount } from 'svelte';
    onMount(() => {
        loadHeists();
        const listener = (event) => {
            if (event.data.action === "stopPlacementNode") {
                isPlacementMode = false;
                // Atualiza as coords do nó
                const nodeId = event.data.extra?.nodeId;
                if (nodeId && event.data.result) {
                    nodes = nodes.map(n => {
                        if (n.id === nodeId) {
                            n.data = {
                                ...n.data,
                                coords: event.data.result,
                                heading: event.data.result.h || 0.0
                            };
                            if (selectedNodeId === nodeId) {
                                selectedNodeData = n.data; // Atualiza sidebar
                            }
                        }
                        return n;
                    });
                }
            } else if (event.data.action === "stopPlacementListItem") {
                isPlacementMode = false;
                const { nodeId, index, type } = event.data.extra || {};
                const res = event.data.result;
                if (nodeId && res && typeof index === 'number') {
                    nodes = nodes.map(n => {
                        if (n.id === nodeId) {
                            if (type === 'props' && n.data.props) {
                                n.data.props[index].coords = { x: res.x, y: res.y, z: res.z };
                                n.data.props[index].heading = res.h;
                            } else if (type === 'peds' && n.data.peds) {
                                n.data.peds[index].coords = { x: res.x, y: res.y, z: res.z };
                                n.data.peds[index].heading = res.h;
                            }
                            if (selectedNodeId === nodeId) {
                                selectedNodeData = n.data; 
                            }
                        }
                        return n;
                    });
                }
            }
        };
        window.addEventListener('message', listener);
        return () => window.removeEventListener('message', listener);
    });

</script>

<div class="heist-editor-container">
    <div class="sidebar left-sidebar">
        <h3>Meus Assaltos</h3>
        <div class="form-group">
            <select class="admin-select" bind:value={selectedSavedHeist} onchange={applyHeist} style="width: 100%; padding: 10px; background: #1a1a1a; color: #fff; border: 1px solid #333; border-radius: 4px;">
                <option value="">-- Novo Assalto --</option>
                {#each savedHeists as heist}
                    <option value={heist.id}>{heist.name} ({heist.id})</option>
                {/each}
            </select>
        </div>
        
        <hr style="border-color: #333; margin: 20px 0;">

        <h3>Propriedades do Assalto</h3>
        <div class="form-group">
            <label>ID Único (ex: store_valentine)</label>
            <input type="text" bind:value={heistId} />
        </div>
        <div class="form-group">
            <label>Nome Visível</label>
            <input type="text" bind:value={heistName} />
        </div>
        <div class="form-group" style="display: flex; gap: 5px;">
            <button class="admin-button" style="background: {isSaving ? '#555' : '#27ae60'}; flex: 1;" onclick={saveHeist} disabled={isSaving}>{isSaving ? 'Salvando...' : 'Salvar no Banco'}</button>
            {#if savedHeists.some(h => h.id === heistId)}
                <button class="admin-button" style="background: #c0392b; flex: 1;" onclick={deleteHeist}>Deletar</button>
            {/if}
        </div>

        <hr style="border-color: #333; margin: 20px 0;">

        <h3>Nós Disponíveis</h3>
        <p style="font-size: 12px; color: #888;">Clique para adicionar ao canvas:</p>
        <div class="nodes-palette">
            {#each nodeTypesList as node}
                <div 
                    class="palette-node" 
                    style="border-left: 4px solid {node.color}"
                    draggable={true} 
                    ondragstart={(e) => onDragStart(e, node.type)}
                    onclick={() => addNode(node.type)}>
                    {node.label}
                </div>
            {/each}
        </div>
    </div>

    <div class="canvas-area" ondrop={onDrop} ondragover={onDragOver}>
        <SvelteFlow bind:nodes={nodes} bind:edges={edges} onconnect={onConnect} onnodeclick={selectNode} onedgeclick={onEdgeClick} onpaneclick={onPaneClick}>
            <Controls />
            <Background variant={BackgroundVariant.Dots} />
        </SvelteFlow>
    </div>

    {#if selectedNodeId || selectedEdgeId}
        <div class="sidebar right-sidebar">
            {#if selectedNodeId}
            <hr style="border-color: #333; margin: 20px 0;">
            <h3>Configurar Nó</h3>
            <p style="font-size: 12px; color: #ccc;">ID: {selectedNodeId} ({selectedNodeData.realType})</p>
            
            {#if ['open_door', 'lockpick_door', 'crack_register', 'minigame'].includes(selectedNodeData.realType)}
                <div class="form-group">
                    <label>Tempo Mínimo (s)</label>
                    <input type="number" bind:value={selectedNodeData.minTime} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Texto do Alvo (Prompt)</label>
                    <input type="text" bind:value={selectedNodeData.prompt} oninput={() => nodes = [...nodes]} />
                </div>
                
                <div class="form-group">
                    <label>Coordenadas</label>
                    {#if selectedNodeData.coords}
                        <p style="font-size: 11px; color: #2ecc71;">Definidas!</p>
                    {:else}
                        <p style="font-size: 11px; color: #e74c3c;">Não definidas</p>
                    {/if}
                    <button class="admin-button" onclick={startPlacement}>Setar Posição 3D</button>
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'wait'}
                <div class="form-group">
                    <label>Duração (ms)</label>
                    <input type="number" bind:value={selectedNodeData.durationMs} oninput={() => nodes = [...nodes]} />
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'trigger_model'}
                <div class="form-group">
                    <label>Modelos (separados por vírgula)</label>
                    <input type="text" bind:value={selectedNodeData.models} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Prompt</label>
                    <input type="text" bind:value={selectedNodeData.prompt} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Distância Máx</label>
                    <input type="number" step="0.1" bind:value={selectedNodeData.distance} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Ícone (FontAwesome)</label>
                    <input type="text" bind:value={selectedNodeData.icon} oninput={() => nodes = [...nodes]} />
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'check_requirements'}
                <div class="form-group">
                    <label>Item</label>
                    <input type="text" bind:value={selectedNodeData.item} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Quantidade</label>
                    <input type="number" bind:value={selectedNodeData.amount} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Msg de Erro</label>
                    <input type="text" bind:value={selectedNodeData.failMessage} oninput={() => nodes = [...nodes]} />
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'minigame_action'}
                <div class="form-group">
                    <label>Minigame Type (none/tierbar)</label>
                    <input type="text" bind:value={selectedNodeData.minigameType} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Duração (ms)</label>
                    <input type="number" bind:value={selectedNodeData.minigameDuration} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Min Time Seguro (s)</label>
                    <input type="number" bind:value={selectedNodeData.minTime} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Anim Dict</label>
                    <input type="text" bind:value={selectedNodeData.animDict} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Anim Name</label>
                    <input type="text" bind:value={selectedNodeData.animName} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Prop Model</label>
                    <input type="text" bind:value={selectedNodeData.propModel} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Msg de Falha (Erro)</label>
                    <input type="text" bind:value={selectedNodeData.failMessage} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Prop Offset (X, Y, Z)</label>
                    <div style="display: flex; gap: 5px;">
                        <input type="number" step="0.001" placeholder="X" bind:value={selectedNodeData.attachOffsetX} oninput={() => nodes = [...nodes]} style="flex:1;" />
                        <input type="number" step="0.001" placeholder="Y" bind:value={selectedNodeData.attachOffsetY} oninput={() => nodes = [...nodes]} style="flex:1;" />
                        <input type="number" step="0.001" placeholder="Z" bind:value={selectedNodeData.attachOffsetZ} oninput={() => nodes = [...nodes]} style="flex:1;" />
                    </div>
                </div>
                <div class="form-group">
                    <label>Prop Rotation (X, Y, Z)</label>
                    <div style="display: flex; gap: 5px;">
                        <input type="number" step="0.01" placeholder="X" bind:value={selectedNodeData.attachRotX} oninput={() => nodes = [...nodes]} style="flex:1;" />
                        <input type="number" step="0.01" placeholder="Y" bind:value={selectedNodeData.attachRotY} oninput={() => nodes = [...nodes]} style="flex:1;" />
                        <input type="number" step="0.01" placeholder="Z" bind:value={selectedNodeData.attachRotZ} oninput={() => nodes = [...nodes]} style="flex:1;" />
                    </div>
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'spawn_prop'}
                <div class="form-group">
                    <label>Props List</label>
                    {#if !selectedNodeData.props}
                        <button class="admin-button" onclick={() => {
                            selectedNodeData.props = [{ 
                                model: selectedNodeData.model || "", 
                                offsetZ: selectedNodeData.offsetZ || 0, 
                                offsetForward: selectedNodeData.offsetForward || 0 
                            }];
                            delete selectedNodeData.model;
                            delete selectedNodeData.offsetZ;
                            delete selectedNodeData.offsetForward;
                            nodes = [...nodes];
                        }}>Migrar para Formato de Lista</button>
                        
                        <div style="border: 1px dashed #666; padding: 10px; margin-top: 10px;">
                            <label>Prop Model (Legacy)</label>
                            <input type="text" bind:value={selectedNodeData.model} oninput={() => nodes = [...nodes]} />
                            <label>Offset Z (Legacy)</label>
                            <input type="number" step="0.1" bind:value={selectedNodeData.offsetZ} oninput={() => nodes = [...nodes]} />
                            <label>Offset Forward (Legacy)</label>
                            <input type="number" step="0.1" bind:value={selectedNodeData.offsetForward} oninput={() => nodes = [...nodes]} />
                        </div>
                    {:else}
                        {#each selectedNodeData.props as prop, index}
                            <div style="border: 1px solid #444; padding: 10px; margin-bottom: 8px; border-radius: 4px; background: #222;">
                                <strong>Prop {index + 1}</strong>
                                <button class="admin-button" style="background: #e74c3c; padding: 2px 8px; font-size: 11px; float: right;" onclick={() => {
                                    selectedNodeData.props.splice(index, 1);
                                    nodes = [...nodes];
                                }}>Remover</button>
                                <div style="clear: both; margin-bottom: 5px;"></div>
                                
                                <label>Model</label>
                                <input type="text" bind:value={prop.model} oninput={() => nodes = [...nodes]} />
                                
                                <div style="display: flex; gap: 5px; margin-top: 5px;">
                                    <div style="flex: 1;">
                                        <label>Coordenadas (3D)</label>
                                        {#if prop.coords}
                                            <span style="font-size: 11px; color: #2ecc71;">X:{prop.coords.x.toFixed(1)} Y:{prop.coords.y.toFixed(1)} Z:{prop.coords.z.toFixed(1)}</span>
                                        {:else}
                                            <span style="font-size: 11px; color: #e74c3c;">Não definidas</span>
                                        {/if}
                                    </div>
                                    <div style="flex: 1;">
                                        <label>Heading</label>
                                        <input type="number" step="1.0" bind:value={prop.heading} oninput={() => nodes = [...nodes]} />
                                    </div>
                                </div>
                                <button class="admin-button" style="background: #3498db; width: 100%; margin-top: 10px;" onclick={() => startPlacementItem('props', index, prop.model)}>📍 Setar no Mundo (3D)</button>
                            </div>
                        {/each}
                        <button class="admin-button" style="background: #27ae60; width: 100%;" onclick={() => {
                            selectedNodeData.props.push({ model: "p_crate01x", coords: null, heading: 0 });
                            nodes = [...nodes];
                        }}>+ Adicionar Prop</button>
                    {/if}
                </div>
            {/if}

            {#if selectedNodeData.realType === 'spawn_ped'}
                <div class="form-group">
                    <label>Peds List</label>
                    {#if !selectedNodeData.peds}
                        <button class="admin-button" onclick={() => {
                            selectedNodeData.peds = [{ 
                                pedModel: selectedNodeData.pedModel || "", 
                                taskType: selectedNodeData.taskType || "", 
                                distance: selectedNodeData.distance || 0,
                                animDict: selectedNodeData.animDict || "",
                                animName: selectedNodeData.animName || ""
                            }];
                            delete selectedNodeData.pedModel;
                            delete selectedNodeData.taskType;
                            nodes = [...nodes];
                        }}>Migrar para Formato de Lista</button>

                        <div style="border: 1px dashed #666; padding: 10px; margin-top: 10px;">
                            <label>Ped Model (Legacy)</label>
                            <input type="text" bind:value={selectedNodeData.pedModel} oninput={() => nodes = [...nodes]} />
                            <label>Task Type (Legacy)</label>
                            <input type="text" bind:value={selectedNodeData.taskType} oninput={() => nodes = [...nodes]} />
                        </div>
                    {:else}
                        {#each selectedNodeData.peds as ped, index}
                            <div style="border: 1px solid #444; padding: 10px; margin-bottom: 8px; border-radius: 4px; background: #222;">
                                <strong>Ped {index + 1}</strong>
                                <button class="admin-button" style="background: #e74c3c; padding: 2px 8px; font-size: 11px; float: right;" onclick={() => {
                                    selectedNodeData.peds.splice(index, 1);
                                    nodes = [...nodes];
                                }}>Remover</button>
                                <div style="clear: both; margin-bottom: 5px;"></div>
                                
                                <label>Model</label>
                                <select bind:value={ped.pedModel} onchange={() => nodes = [...nodes]}>
                                    <optgroup label="Cidadãos">
                                        <option value="a_m_m_valtownfolk_01">Cidadão Valentine 1</option>
                                        <option value="a_m_m_valtownfolk_02">Cidadão Valentine 2</option>
                                        <option value="a_m_y_valtownfolk_01">Jovem Valentine</option>
                                        <option value="a_f_m_valtownfolk_01">Mulher Valentine</option>
                                        <option value="a_m_m_sdtownfolk_01">Cidadão St. Denis 1</option>
                                        <option value="a_m_m_sdtownfolk_02">Cidadão St. Denis 2</option>
                                        <option value="a_f_m_sdtownfolk_01">Mulher St. Denis</option>
                                    </optgroup>
                                    <optgroup label="Trabalhadores">
                                        <option value="u_m_m_valbarkeep_01">Bartender Valentine</option>
                                        <option value="u_m_m_valgunsmith_01">Armeiro Valentine</option>
                                        <option value="u_m_m_valdoctor_01">Médico Valentine</option>
                                        <option value="u_m_m_valsheriff_01">Xerife Valentine</option>
                                        <option value="a_m_m_rancher_01">Fazendeiro</option>
                                        <option value="a_m_m_blwrangler_01">Vaqueiro</option>
                                    </optgroup>
                                    <optgroup label="Viajantes / Vagabundos">
                                        <option value="a_m_m_bivroughtravelers_01">Viajante Bivrough</option>
                                        <option value="a_m_m_ranchertravelers_01">Fazendeiro Viajante</option>
                                        <option value="a_m_m_trapper_01">Caçador Trapper</option>
                                        <option value="u_m_m_yourknownhorse_01">Mendigo</option>
                                    </optgroup>
                                    <optgroup label="Lei / Segurança">
                                        <option value="s_m_m_law_01">Homem da Lei</option>
                                        <option value="s_m_m_bankguard_01">Guarda do Banco</option>
                                        <option value="s_m_m_army_01">Soldado</option>
                                    </optgroup>
                                    <optgroup label="Bandidos / Inimigos">
                                        <option value="g_m_m_bountyhunters_01">Caçador de Recompensas</option>
                                        <option value="g_m_m_uniduster_01">Bandido Duster</option>
                                        <option value="g_m_m_unigunslinger_01">Pistoleiro</option>
                                        <option value="g_m_m_unirancher_01">Bandido Rancher</option>
                                    </optgroup>
                                </select>

                                <label>Comportamento</label>
                                <select bind:value={ped.taskType} onchange={() => nodes = [...nodes]}>
                                    <option value="idle">Parado (Idle Natural)</option>
                                    <option value="guard">Guardar Posição</option>
                                    <option value="attack">Atacar Jogador Imediatamente</option>
                                    <option value="flee">Fugir do Jogador</option>
                                    <option value="wander">Vagar pela Área</option>
                                    <option value="scenario">Cenário Ambiental</option>
                                    <option value="animation">Animação Personalizada</option>
                                    <option value="frozen">Congelado (Estátua)</option>
                                </select>

                                {#if ped.taskType === 'scenario'}
                                    <label>Cenário</label>
                                    <select bind:value={ped.scenario} onchange={() => nodes = [...nodes]}>
                                        <option value="WORLD_HUMAN_SMOKING">Fumando</option>
                                        <option value="WORLD_HUMAN_DRINKING">Bebendo</option>
                                        <option value="WORLD_HUMAN_GUARD_STAND">Guardando (em pé)</option>
                                        <option value="WORLD_HUMAN_LEAN_WALL">Encostado na Parede</option>
                                        <option value="WORLD_HUMAN_SIT_GROUND">Sentado no Chão</option>
                                        <option value="WORLD_HUMAN_SWEEPING">Varrendo</option>
                                        <option value="PROP_HUMAN_SEAT_BENCH">Sentado no Banco</option>
                                        <option value="WORLD_HUMAN_MUSICIAN_GUITAR">Tocando Violão</option>
                                        <option value="WORLD_HUMAN_FIRE_TEND">Cuidando da Fogueira</option>
                                    </select>
                                {/if}

                                {#if ped.taskType === 'animation'}
                                    <label>Anim Dict</label>
                                    <input type="text" bind:value={ped.animDict} oninput={() => nodes = [...nodes]} placeholder="ex: amb@medic@standing@kneel@base" />
                                    <label>Anim Name</label>
                                    <input type="text" bind:value={ped.animName} oninput={() => nodes = [...nodes]} placeholder="ex: base" />
                                {/if}

                                {#if ped.taskType === 'guard' || ped.taskType === 'attack'}
                                    <label>Arma</label>
                                    <select bind:value={ped.weapon} onchange={() => nodes = [...nodes]}>
                                        <option value="WEAPON_UNARMED">Desarmado</option>
                                        <option value="WEAPON_REVOLVER_CATTLEMAN">Revólver Cattleman</option>
                                        <option value="WEAPON_REVOLVER_DOUBLEACTION">Revólver Double Action</option>
                                        <option value="WEAPON_REVOLVER_SCHOFIELD">Revólver Schofield</option>
                                        <option value="WEAPON_PISTOL_VOLCANIC">Pistola Volcanic</option>
                                        <option value="WEAPON_REPEATER_CARBINE">Carabina Repetidora</option>
                                        <option value="WEAPON_RIFLE_SPRINGFIELD">Rifle Springfield</option>
                                        <option value="WEAPON_SHOTGUN_DOUBLEBARREL">Escopeta Dupla</option>
                                        <option value="WEAPON_KNIFE">Faca</option>
                                        <option value="WEAPON_MACHETE">Facão</option>
                                    </select>
                                    <label>Distância de Detecção</label>
                                    <input type="number" step="1.0" bind:value={ped.detectDistance} oninput={() => nodes = [...nodes]} placeholder="15" />
                                {/if}

                                {#if ped.taskType === 'wander'}
                                    <label>Raio de Vagar (metros)</label>
                                    <input type="number" step="1.0" bind:value={ped.wanderRadius} oninput={() => nodes = [...nodes]} placeholder="10" />
                                {/if}
                                
                                <div style="display: flex; gap: 5px; margin-top: 5px;">
                                    <div style="flex: 1;">
                                        <label>Coordenadas (3D)</label>
                                        {#if ped.coords}
                                            <span style="font-size: 11px; color: #2ecc71;">X:{ped.coords.x.toFixed(1)} Y:{ped.coords.y.toFixed(1)} Z:{ped.coords.z.toFixed(1)}</span>
                                        {:else}
                                            <span style="font-size: 11px; color: #e74c3c;">Não definidas</span>
                                        {/if}
                                    </div>
                                    <div style="flex: 1;">
                                        <label>Heading</label>
                                        <input type="number" step="1.0" bind:value={ped.heading} oninput={() => nodes = [...nodes]} />
                                    </div>
                                </div>
                                <button class="admin-button" style="background: #3498db; width: 100%; margin-top: 10px;" onclick={() => startPlacementItem('peds', index, ped.pedModel)}>📍 Setar no Mundo (3D)</button>
                            </div>
                        {/each}
                        <button class="admin-button" style="background: #27ae60; width: 100%;" onclick={() => {
                            selectedNodeData.peds.push({ pedModel: "g_m_m_bountyhunters_01", taskType: "idle", weapon: "WEAPON_UNARMED", coords: null, heading: 0 });
                            nodes = [...nodes];
                        }}>+ Adicionar Ped</button>
                    {/if}
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'crime_reward_and_cooldown'}
                <div class="form-group">
                    <label>Tipo de Crime (Config.Crimes)</label>
                    <input type="text" bind:value={selectedNodeData.crimeType} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Prefixo Cooldown</label>
                    <input type="text" bind:value={selectedNodeData.cooldownPrefix} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Msg de Sucesso</label>
                    <input type="text" bind:value={selectedNodeData.successMessage} oninput={() => nodes = [...nodes]} />
                </div>
            {/if}

            {#if selectedNodeData.realType === 'risk_session'}
                <div class="form-group">
                    <label>Título UI</label>
                    <input type="text" bind:value={selectedNodeData.title} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Texto Crítico UI</label>
                    <input type="text" bind:value={selectedNodeData.criticalText} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group" style="display: flex; gap: 5px;">
                    <div style="flex: 1;">
                        <label>Threshold Sprint</label>
                        <input type="number" step="0.1" bind:value={selectedNodeData.sprintThreshold} oninput={() => nodes = [...nodes]} />
                    </div>
                    <div style="flex: 1;">
                        <label>Increase Sprint</label>
                        <input type="number" step="0.1" bind:value={selectedNodeData.sprintIncrease} oninput={() => nodes = [...nodes]} />
                    </div>
                </div>
                <div class="form-group" style="display: flex; gap: 5px;">
                    <div style="flex: 1;">
                        <label>Threshold Run</label>
                        <input type="number" step="0.1" bind:value={selectedNodeData.runThreshold} oninput={() => nodes = [...nodes]} />
                    </div>
                    <div style="flex: 1;">
                        <label>Increase Run</label>
                        <input type="number" step="0.1" bind:value={selectedNodeData.runIncrease} oninput={() => nodes = [...nodes]} />
                    </div>
                </div>
                <div class="form-group" style="display: flex; gap: 5px;">
                    <div style="flex: 1;">
                        <label>Idle Decay (Queda)</label>
                        <input type="number" step="0.1" bind:value={selectedNodeData.idleDecay} oninput={() => nodes = [...nodes]} />
                    </div>
                    <div style="flex: 1;">
                        <label>Max Chance</label>
                        <input type="number" step="1.0" bind:value={selectedNodeData.maxChance} oninput={() => nodes = [...nodes]} />
                    </div>
                </div>
                <div class="form-group">
                    <label>Duração Total (ms)</label>
                    <input type="number" bind:value={selectedNodeData.duration} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Check Interval (ms)</label>
                    <input type="number" bind:value={selectedNodeData.checkInterval} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Fail Message</label>
                    <input type="text" bind:value={selectedNodeData.failMessage} oninput={() => nodes = [...nodes]} />
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'play_animation'}
                <div class="form-group">
                    <label>Anim Dict</label>
                    <input type="text" bind:value={selectedNodeData.animDict} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Anim Name</label>
                    <input type="text" bind:value={selectedNodeData.animName} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Prop Model (Opcional)</label>
                    <input type="text" bind:value={selectedNodeData.propModel} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Duração (ms)</label>
                    <input type="number" bind:value={selectedNodeData.durationMs} oninput={() => nodes = [...nodes]} />
                </div>
            {/if}
            
            <hr style="border-color: #444; margin: 15px 0;">
            <button class="admin-button" style="background-color: #e74c3c; width: 100%; color: white;" onclick={deleteSelectedNode}>🗑️ Deletar Nó</button>
            {/if}

            {#if selectedEdgeId}
            <hr style="border-color: #333; margin: 20px 0;">
            <h3>Ligação Selecionada</h3>
            <button class="admin-button" style="background-color: #e74c3c; width: 100%; color: white;" onclick={deleteSelectedEdge}>🗑️ Deletar Ligação</button>
            {/if}
        </div>
    {/if}
</div>

{#if showModal}
    <Modal 
        title={modalConfig.title} 
        message={modalConfig.message} 
        type={modalConfig.type} 
        onConfirm={modalConfig.onConfirm} 
        onCancel={modalConfig.onCancel} 
    />
{/if}

<style>
    .heist-editor-container {
        display: flex;
        width: 100%;
        height: 100%;
        background: #111;
        color: #fff;
    }
    :global(.svelte-flow__node) {
        color: #111 !important;
        font-weight: 500;
    }
    .sidebar {
        width: 300px;
        background: #1a1a1a;
        padding: 15px;
        overflow-y: auto;
    }
    .left-sidebar {
        border-right: 1px solid #333;
    }
    .right-sidebar {
        border-left: 1px solid #333;
    }
    .canvas-area {
        flex: 1;
        height: 100%;
        position: relative;
        overflow: hidden;
    }
    .palette-node {
        background: #2a2a2a;
        padding: 10px;
        margin-bottom: 8px;
        border-radius: 4px;
        cursor: grab;
        font-size: 13px;
        user-select: none;
    }
    .palette-node:active {
        cursor: grabbing;
    }
</style>

