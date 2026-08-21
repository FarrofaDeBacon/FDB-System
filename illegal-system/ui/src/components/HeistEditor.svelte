<script>
    import { SvelteFlow, Controls, Background } from '@xyflow/svelte';
    import '@xyflow/svelte/dist/style.css';

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
        { type: 'player_notification', label: 'Notification (Feedback)', color: '#f1c40f' }
    ];

    let selectedNodeId = $state(null);
    let selectedNodeData = $state(null);

    function onDragStart(event, nodeType) {
        event.dataTransfer.setData('application/svelteflow', nodeType);
        event.dataTransfer.effectAllowed = 'move';
    }

    function addNode(type, position = { x: 250, y: 150 }) {
        const config = nodeTypesList.find(n => n.type === type);
        
        let initialData = { label: config.label };
        if (['open_door', 'lockpick_door', 'crack_register', 'minigame'].includes(type)) {
            initialData.coords = null;
            initialData.minTime = 5;
            initialData.prompt = "Interagir";
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

    function selectNode(event) {
        const node = event.detail.node;
        selectedNodeId = node.id;
        selectedNodeData = node.data;
    }
    
    function onPaneClick() {
        selectedNodeId = null;
        selectedNodeData = null;
    }

    function startPlacement() {
        if (!selectedNodeId) return;
        isPlacementMode = true;
        // Pede pra NUI iniciar a camera no client
        fetch(`https://${GetParentResourceName()}/startPlacement`, {
            method: 'POST',
            body: JSON.stringify({
                type: 'door', // Usamos door como um proxy visual pro ghost prop p_crate01x
                model: 'p_crate01x',
                callbackAction: 'stopPlacementNode',
                extraData: { nodeId: selectedNodeId }
            })
        });
    }

    // Exportador de JSON para salvar no banco
    function saveHeist() {
        if (!heistId.trim() || !heistName.trim()) {
            console.log("ID ou Nome vazio");
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
            
            // Copia as propriedades (removendo label e realType que são exclusivos do UI)
            for (const [k, v] of Object.entries(n.data)) {
                if (k !== 'label' && k !== 'realType') {
                    nodeExport.data[k] = v;
                }
            }
            
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
            body: JSON.stringify({
                id: heistId,
                name: heistName,
                graph: graph
            })
        });
    }
    
    // Escutador global caso voltemos do placement
    import { onMount } from 'svelte';
    onMount(() => {
        const listener = (event) => {
            if (event.data.action === "stopPlacementNode") {
                isPlacementMode = false;
                // Atualiza as coords do nó
                const nodeId = event.data.extra?.nodeId;
                if (nodeId) {
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
        <h3>Propriedades do Assalto</h3>
        <div class="form-group">
            <label>ID Único (ex: store_valentine)</label>
            <input type="text" bind:value={heistId} />
        </div>
        <div class="form-group">
            <label>Nome Visível</label>
            <input type="text" bind:value={heistName} />
        </div>
        <button class="admin-button" style="background: #27ae60;" onclick={saveHeist}>Salvar no Banco</button>

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
        {/if}
    </div>

    <div class="canvas-area" ondrop={onDrop} ondragover={onDragOver}>
        <SvelteFlow bind:nodes={nodes} bind:edges={edges} onnodeclick={selectNode} onpaneclick={onPaneClick}>
            <Controls />
            <Background variant="dots" gap={12} size={1} />
        </SvelteFlow>
    </div>
</div>

<style>
    .heist-editor-container {
        display: flex;
        width: 100%;
        height: 100%;
        background: #111;
        color: #fff;
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
        position: relative;
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
