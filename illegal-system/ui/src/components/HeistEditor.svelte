<script>
    import { SvelteFlow, Controls, Background } from '@xyflow/svelte';
    import '@xyflow/svelte/dist/style.css';
    import { writable } from 'svelte/store';

    export let isPlacementMode = false;
    
    const nodes = writable([]);
    const edges = writable([]);
    
    let nextId = 1;
    let heistId = "novo_assalto";
    let heistName = "Novo Assalto";
    
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

    let selectedNodeId = null;
    let selectedNodeData = null;

    function onDragStart(event, nodeType) {
        event.dataTransfer.setData('application/svelteflow', nodeType);
        event.dataTransfer.effectAllowed = 'move';
    }

    function onDrop(event) {
        event.preventDefault();
        const type = event.dataTransfer.getData('application/svelteflow');
        if (!type) return;

        const position = {
            x: event.clientX - 250, // offset do sidebar
            y: event.clientY - 50
        };

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
        
        // Salvamos o tipo original dentro dos dados pra podermos exportar depois
        newNode.data.realType = type;

        nodes.update(ns => [...ns, newNode]);
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

        const currentNodes = [];
        nodes.subscribe(v => currentNodes.push(...v))();
        
        const currentEdges = [];
        edges.subscribe(v => currentEdges.push(...v))();

        const graph = {
            nodes: {},
            edges: []
        };

        // Formata os nós pro padrão exato exigido nas Fases 1/2
        currentNodes.forEach(n => {
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
        currentEdges.forEach(e => {
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
                // Atualiza as coords do nó
                const nodeId = event.data.extra?.nodeId;
                if (nodeId) {
                    nodes.update(ns => {
                        return ns.map(n => {
                            if (n.id === nodeId) {
                                n.data = {
                                    ...n.data,
                                    coords: event.data.result,
                                    heading: event.data.heading || 0.0
                                };
                                if (selectedNodeId === nodeId) {
                                    selectedNodeData = n.data; // Atualiza sidebar
                                }
                            }
                            return n;
                        });
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
        <button class="admin-button" style="background: #27ae60;" on:click={saveHeist}>Salvar no Banco</button>

        <hr style="border-color: #333; margin: 20px 0;">

        <h3>Nós Disponíveis</h3>
        <p style="font-size: 12px; color: #888;">Arraste para o canvas:</p>
        <div class="nodes-palette">
            {#each nodeTypesList as node}
                <div 
                    class="palette-node" 
                    style="border-left: 4px solid {node.color}"
                    draggable={true} 
                    on:dragstart={(e) => onDragStart(e, node.type)}>
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
                    <input type="number" bind:value={selectedNodeData.minTime} on:input={() => nodes.update(ns => [...ns])} />
                </div>
                <div class="form-group">
                    <label>Texto do Alvo (Prompt)</label>
                    <input type="text" bind:value={selectedNodeData.prompt} on:input={() => nodes.update(ns => [...ns])} />
                </div>
                
                <div class="form-group">
                    <label>Coordenadas</label>
                    {#if selectedNodeData.coords}
                        <p style="font-size: 11px; color: #2ecc71;">Definidas!</p>
                    {:else}
                        <p style="font-size: 11px; color: #e74c3c;">Não definidas</p>
                    {/if}
                    <button class="admin-button" on:click={startPlacement}>Setar Posição 3D</button>
                </div>
            {/if}
            
            {#if selectedNodeData.realType === 'wait'}
                <div class="form-group">
                    <label>Duração (ms)</label>
                    <input type="number" bind:value={selectedNodeData.durationMs} on:input={() => nodes.update(ns => [...ns])} />
                </div>
            {/if}
        {/if}
    </div>

    <div class="canvas-area" on:drop={onDrop} on:dragover={onDragOver}>
        <SvelteFlow {nodes} {edges} on:nodeclick={selectNode} on:paneclick={onPaneClick}>
            <Controls />
            <Background />
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
