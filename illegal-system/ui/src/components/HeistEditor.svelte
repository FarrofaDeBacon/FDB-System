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
        { type: 'crime_reward_and_cooldown', label: 'Crime Reward & CD', color: '#c0392b' }
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
            initialData.model = "prop_ld_rub_money_01";
            initialData.offsetZ = -1.0;
            initialData.offsetForward = 0.5;
        }
        if (type === 'crime_reward_and_cooldown') {
            initialData.crimeType = "grave_robbery";
            initialData.cooldownPrefix = "grave";
            initialData.successMessage = "Você encontrou algo!";
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

    // Exportador de JSON para salvar no banco
    function saveHeist() {
        if (!heistId.trim() || !heistName.trim()) {
            console.log("ID ou Nome vazio");
            alert("Preencha o ID e o Nome do assalto antes de salvar!");
            return;
        }

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
        }).then(() => {
            loadHeists(); // Refresh list after saving
            selectedSavedHeist = heistId; // Seleciona o recém-salvo
        }).catch(err => console.error("Error sending NUI message:", err));
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
            }
        };
        window.addEventListener('message', listener);
        return () => window.removeEventListener('message', listener);
    });

</script>

<div class="heist-editor-container">
    <div class="sidebar">
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
            <button class="admin-button" style="background: #27ae60; flex: 1;" onclick={saveHeist}>Salvar no Banco</button>
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
            {/if}
            
            {#if selectedNodeData.realType === 'spawn_prop'}
                <div class="form-group">
                    <label>Prop Model</label>
                    <input type="text" bind:value={selectedNodeData.model} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Offset Z</label>
                    <input type="number" step="0.1" bind:value={selectedNodeData.offsetZ} oninput={() => nodes = [...nodes]} />
                </div>
                <div class="form-group">
                    <label>Offset Forward</label>
                    <input type="number" step="0.1" bind:value={selectedNodeData.offsetForward} oninput={() => nodes = [...nodes]} />
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
            
            <hr style="border-color: #444; margin: 15px 0;">
            <button class="admin-button" style="background-color: #e74c3c; width: 100%; color: white;" onclick={deleteSelectedNode}>🗑️ Deletar Nó</button>
        {/if}
        
        {#if selectedEdgeId}
            <hr style="border-color: #333; margin: 20px 0;">
            <h3>Ligação Selecionada</h3>
            <button class="admin-button" style="background-color: #e74c3c; width: 100%; color: white;" onclick={deleteSelectedEdge}>🗑️ Deletar Ligação</button>
        {/if}
    </div>

    <div class="canvas-area" ondrop={onDrop} ondragover={onDragOver}>
        <SvelteFlow bind:nodes={nodes} bind:edges={edges} onconnect={onConnect} onnodeclick={selectNode} onedgeclick={onEdgeClick} onpaneclick={onPaneClick}>
            <Controls />
            <Background variant={BackgroundVariant.Dots} />
        </SvelteFlow>
    </div>
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
        border-right: 1px solid #333;
        padding: 15px;
        overflow-y: auto;
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
