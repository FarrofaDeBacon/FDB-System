<script>
    import { onMount } from 'svelte';

    // Estados reativos usando as Runas do Svelte 5
    let isOpen = $state(false);
    let pedSex = $state('male'); // 'male' ou 'female'
    let activeTab = $state('genetics'); // 'genetics', 'face', 'hair', 'clothing'

    // Estado inicial padrão dos controles
    let creatorCache = $state({
        // Genética
        head: 1,
        skin_tone: 1,
        ageing: 1,
        ageing_op: 0,
        
        // Feições
        head_width: 0,
        face_width: 0,
        face_depth: 0,
        forehead_size: 0,
        eyebrow_height: 0,
        eyebrow_width: 0,
        eyebrow_depth: 0,
        eyes_depth: 0,
        eyes_angle: 0,
        eyes_distance: 0,
        eyes_height: 0,
        nose_width: 0,
        nose_size: 0,
        nose_height: 0,
        nose_angle: 0,
        nose_curvature: 0,
        nostrils_distance: 0,
        mouth_width: 0,
        mouth_depth: 0,
        mouth_y_pos: 0,
        mouth_x_pos: 0,
        chin_height: 0,
        chin_width: 0,
        chin_depth: 0,
        jaw_height: 0,
        jaw_width: 0,
        jaw_depth: 0,
        cheekbones_height: 0,
        cheekbones_width: 0,
        cheekbones_depth: 0,
        ears_width: 0,
        ears_angle: 0,
        ears_height: 0,
        ears_size: 0,
        height: 100,

        // Cabelo & Barba
        hair: 1,
        hair_color: 0,
        beard: 0,
        beard_color: 0,
        beard_op: 100,
        eyebrows_id: 1,
        eyebrows_c1: 0,
        eyebrows_op: 100,

        // Sobrancelha / Opacidade
        eyebrows_t: 1,

        // Batom e Maquiagens
        lipsticks_t: 1,
        lipsticks_id: 0,
        lipsticks_op: 0,
        shadows_t: 1,
        shadows_id: 0,
        shadows_op: 0,

        // Roupas iniciais
        shirt: 1,
        vest: 0,
        pants: 1,
        boots: 1,
        hat: 0
    });

    let pedRotation = $state(0); // -180 a 180

    // Paleta de cores para cabelos e barbas baseada em RDR2
    const hairColors = [
        '#111111', '#1a1412', '#2b1a10', '#3b2211', '#4d2d14', '#5e3818', '#70431b', '#855122',
        '#9e642b', '#b37636', '#c48944', '#a16538', '#804823', '#613114', '#47210b', '#3b1c09',
        '#d9a752', '#ebd278', '#635e4e', '#8a8370', '#b0aaa2', '#ffffff', '#bf4326', '#e05831',
        '#f56e42', '#a63a1c', '#752109', '#4d1003'
    ];

    onMount(() => {
        // Envia handshake inicial de que a NUI está pronta
        fetch(`https://fdb-appearance/nuiReady`, {
            method: 'POST',
            body: JSON.stringify({})
        }).catch(() => {});

        window.addEventListener('message', (event) => {
            const data = event.data;
            if (data.action === 'openCreator') {
                pedSex = data.sex || 'male';
                if (data.cache) {
                    creatorCache = { ...creatorCache, ...data.cache };
                }
                isOpen = true;
                setCamera('full');
            } else if (data.action === 'closeCreator') {
                isOpen = false;
            }
        });
    });

    function setTab(tab) {
        activeTab = tab;
        // Ajusta a câmera inteligente conforme a aba
        if (tab === 'genetics' || tab === 'face') {
            setCamera('face');
        } else if (tab === 'hair') {
            setCamera('face');
        } else if (tab === 'clothing') {
            setCamera('torso');
        }
    }

    function handleChange(key, value) {
        creatorCache[key] = value;
        
        // Determina a categoria da mudança
        let type = 'feature';
        if (['hair', 'beard', 'eyebrows_id', 'eyebrows_t', 'eyebrows_op', 'beard_op', 'hair_color', 'beard_color', 'eyebrows_c1', 'lipsticks_t', 'lipsticks_id', 'lipsticks_op', 'shadows_t', 'shadows_id', 'shadows_op', 'ageing', 'ageing_op'].includes(key)) {
            type = 'overlay';
        } else if (['shirt', 'vest', 'pants', 'boots', 'hat'].includes(key)) {
            type = 'clothing';
        } else if (['head', 'skin_tone'].includes(key)) {
            type = 'genetics';
        }

        fetch(`https://fdb-appearance/onChange`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type, key, value })
        }).catch(() => {});
    }

    function setCamera(cam) {
        fetch(`https://fdb-appearance/changeCamera`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ camera: cam })
        }).catch(() => {});
    }

    function handleRotation(e) {
        pedRotation = parseFloat(e.target.value);
        fetch(`https://fdb-appearance/rotatePed`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ rotation: pedRotation })
        }).catch(() => {});
    }

    function saveCharacter() {
        fetch(`https://fdb-appearance/saveCreator`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(creatorCache)
        }).catch(() => {});
        isOpen = false;
    }
</script>

{#if isOpen}
    <div class="creator-wrapper">
        <!-- Painel Lateral Translúcido de Customização -->
        <div class="sidebar">
            <div class="header">
                <h2>Criação de Personagem</h2>
                <p>Ajuste sua feição física e roupas iniciais</p>
            </div>

            <!-- Navegação de Abas -->
            <div class="tabs">
                <button class:active={activeTab === 'genetics'} on:click={() => setTab('genetics')}>Genética</button>
                <button class:active={activeTab === 'face'} on:click={() => setTab('face')}>Rosto</button>
                <button class:active={activeTab === 'hair'} on:click={() => setTab('hair')}>Cabelos</button>
                <button class:active={activeTab === 'clothing'} on:click={() => setTab('clothing')}>Vestuário</button>
            </div>

            <!-- Conteúdo da Aba Ativa -->
            <div class="tab-content">
                {#if activeTab === 'genetics'}
                    <div class="section-title">Aparência Base</div>
                    
                    <div class="control-group">
                        <label for="base-head">Cabeça Base ({creatorCache.head})</label>
                        <input id="base-head" type="range" min="1" max="6" step="1" value={creatorCache.head} on:input={(e) => handleChange('head', parseInt(e.target.value))} />
                    </div>

                    <div class="control-group">
                        <label for="skin-tone">Tom de Pele ({creatorCache.skin_tone})</label>
                        <input id="skin-tone" type="range" min="1" max="6" step="1" value={creatorCache.skin_tone} on:input={(e) => handleChange('skin_tone', parseInt(e.target.value))} />
                    </div>

                    <div class="control-group">
                        <label for="ageing">Envelhecimento ({creatorCache.ageing})</label>
                        <input id="ageing" type="range" min="1" max="20" step="1" value={creatorCache.ageing} on:input={(e) => handleChange('ageing', parseInt(e.target.value))} />
                    </div>

                    <div class="control-group">
                        <label for="ageing-op">Opacidade Envelhecimento ({Math.round(creatorCache.ageing_op * 100)}%)</label>
                        <input id="ageing-op" type="range" min="0" max="1" step="0.05" value={creatorCache.ageing_op} on:input={(e) => handleChange('ageing_op', parseFloat(e.target.value))} />
                    </div>
                {/if}

                {#if activeTab === 'face'}
                    <div class="section-title">Feições Faciais</div>

                    <div class="scroll-area">
                        <div class="control-group">
                            <label for="face-width">Largura do Rosto ({creatorCache.face_width})</label>
                            <input id="face-width" type="range" min="-100" max="100" step="5" value={creatorCache.face_width} on:input={(e) => handleChange('face_width', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="face-depth">Profundidade do Rosto ({creatorCache.face_depth})</label>
                            <input id="face-depth" type="range" min="-100" max="100" step="5" value={creatorCache.face_depth} on:input={(e) => handleChange('face_depth', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="forehead-size">Tamanho da Testa ({creatorCache.forehead_size})</label>
                            <input id="forehead-size" type="range" min="-100" max="100" step="5" value={creatorCache.forehead_size} on:input={(e) => handleChange('forehead_size', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="eyes-distance">Distância dos Olhos ({creatorCache.eyes_distance})</label>
                            <input id="eyes-distance" type="range" min="-100" max="100" step="5" value={creatorCache.eyes_distance} on:input={(e) => handleChange('eyes_distance', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="eyes-height">Altura dos Olhos ({creatorCache.eyes_height})</label>
                            <input id="eyes-height" type="range" min="-100" max="100" step="5" value={creatorCache.eyes_height} on:input={(e) => handleChange('eyes_height', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="nose-size">Tamanho do Nariz ({creatorCache.nose_size})</label>
                            <input id="nose-size" type="range" min="-100" max="100" step="5" value={creatorCache.nose_size} on:input={(e) => handleChange('nose_size', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="nose-curvature">Curvatura do Nariz ({creatorCache.nose_curvature})</label>
                            <input id="nose-curvature" type="range" min="-100" max="100" step="5" value={creatorCache.nose_curvature} on:input={(e) => handleChange('nose_curvature', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="mouth-width">Largura da Boca ({creatorCache.mouth_width})</label>
                            <input id="mouth-width" type="range" min="-100" max="100" step="5" value={creatorCache.mouth_width} on:input={(e) => handleChange('mouth_width', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="jaw-width">Largura do Maxilar ({creatorCache.jaw_width})</label>
                            <input id="jaw-width" type="range" min="-100" max="100" step="5" value={creatorCache.jaw_width} on:input={(e) => handleChange('jaw_width', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="chin-height">Altura do Queixo ({creatorCache.chin_height})</label>
                            <input id="chin-height" type="range" min="-100" max="100" step="5" value={creatorCache.chin_height} on:input={(e) => handleChange('chin_height', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="height">Altura do Personagem ({creatorCache.height}%)</label>
                            <input id="height" type="range" min="90" max="110" step="1" value={creatorCache.height} on:input={(e) => handleChange('height', parseInt(e.target.value))} />
                        </div>
                    </div>
                {/if}

                {#if activeTab === 'hair'}
                    <div class="section-title">Cabelos & Barbas</div>
                    <div class="scroll-area">
                        <div class="control-group">
                            <label for="hair-style">Estilo de Cabelo ({creatorCache.hair})</label>
                            <input id="hair-style" type="range" min="1" max="50" step="1" value={creatorCache.hair} on:input={(e) => handleChange('hair', parseInt(e.target.value))} />
                        </div>

                        <div class="color-picker-title">Cor do Cabelo</div>
                        <div class="color-grid">
                            {#each hairColors as color, index}
                                <button 
                                    class="color-btn" 
                                    class:selected={creatorCache.hair_color === index} 
                                    style="background-color: {color}" 
                                    on:click={() => handleChange('hair_color', index)}
                                    aria-label="Selecionar cor {index}"
                                ></button>
                            {/each}
                        </div>

                        {#if pedSex === 'male'}
                            <div class="control-group" style="margin-top: 20px;">
                                <label for="beard-style">Estilo de Barba ({creatorCache.beard})</label>
                                <input id="beard-style" type="range" min="0" max="30" step="1" value={creatorCache.beard} on:input={(e) => handleChange('beard', parseInt(e.target.value))} />
                            </div>

                            <div class="control-group">
                                <label for="beard-op">Opacidade da Barba ({creatorCache.beard_op}%)</label>
                                <input id="beard-op" type="range" min="0" max="100" step="5" value={creatorCache.beard_op} on:input={(e) => handleChange('beard_op', parseInt(e.target.value))} />
                            </div>

                            <div class="color-picker-title">Cor da Barba</div>
                            <div class="color-grid">
                                {#each hairColors as color, index}
                                    <button 
                                        class="color-btn" 
                                        class:selected={creatorCache.beard_color === index} 
                                        style="background-color: {color}" 
                                        on:click={() => handleChange('beard_color', index)}
                                        aria-label="Selecionar cor barba {index}"
                                    ></button>
                                {/each}
                            </div>
                        {/if}
                    </div>
                {/if}

                {#if activeTab === 'clothing'}
                    <div class="section-title">Vestuário Inicial</div>
                    <div class="scroll-area">
                        <div class="control-group">
                            <label for="shirt">Camisa ({creatorCache.shirt})</label>
                            <input id="shirt" type="range" min="1" max="10" step="1" value={creatorCache.shirt} on:input={(e) => handleChange('shirt', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="vest">Colete ({creatorCache.vest})</label>
                            <input id="vest" type="range" min="0" max="8" step="1" value={creatorCache.vest} on:input={(e) => handleChange('vest', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="pants">Calça ({creatorCache.pants})</label>
                            <input id="pants" type="range" min="1" max="10" step="1" value={creatorCache.pants} on:input={(e) => handleChange('pants', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="boots">Botas ({creatorCache.boots})</label>
                            <input id="boots" type="range" min="1" max="10" step="1" value={creatorCache.boots} on:input={(e) => handleChange('boots', parseInt(e.target.value))} />
                        </div>

                        <div class="control-group">
                            <label for="hat">Chapéu ({creatorCache.hat})</label>
                            <input id="hat" type="range" min="0" max="6" step="1" value={creatorCache.hat} on:input={(e) => handleChange('hat', parseInt(e.target.value))} />
                        </div>
                    </div>
                {/if}
            </div>

            <!-- Rodapé e Ações -->
            <div class="footer">
                <button class="save-btn" on:click={saveCharacter}>Confirmar Personagem</button>
            </div>
        </div>

        <!-- Controles Flutuantes da Câmera (Canto Direito) -->
        <div class="camera-controls">
            <div class="cam-title">Câmera</div>
            <button on:click={() => setCamera('face')}>Rosto</button>
            <button on:click={() => setCamera('torso')}>Corpo</button>
            <button on:click={() => setCamera('legs')}>Pernas</button>
            <button on:click={() => setCamera('full')}>Geral</button>
        </div>

        <!-- Controle de Rotação do Personagem (Parte Inferior Central) -->
        <div class="rotation-control">
            <label for="rotation">Girar Personagem</label>
            <input id="rotation" type="range" min="-180" max="180" step="2" value={pedRotation} on:input={handleRotation} />
        </div>
    </div>
{/if}

<style>
    .creator-wrapper {
        position: absolute;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        display: flex;
        align-items: center;
        font-family: var(--fdb-font-body, 'Roboto Condensed', sans-serif);
        color: var(--fdb-text-primary, #d4c5b0);
        pointer-events: none; /* Deixa o fundo livre para cliques de câmera se necessário */
    }

    .sidebar {
        pointer-events: auto; /* Reativa cliques no menu lateral */
        width: 380px;
        height: 90vh;
        margin-left: 50px;
        background: var(--fdb-background-color, rgba(10, 10, 10, 0.88));
        backdrop-filter: blur(12px);
        border: 1px solid var(--fdb-border-color, rgba(255, 255, 255, 0.1));
        border-top: 3px solid var(--fdb-accent-color, #c9a15a);
        border-bottom: 3px solid var(--fdb-accent-color, #c9a15a);
        border-radius: var(--fdb-border-radius, 4px);
        display: flex;
        flex-direction: column;
        padding: 25px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    }

    .header h2 {
        font-family: var(--fdb-font-display, 'Playfair Display', serif);
        color: var(--fdb-accent-color, #c9a15a);
        font-size: 24px;
        margin: 0 0 5px 0;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .header p {
        font-size: 13px;
        color: var(--fdb-text-secondary, #a89878);
        margin: 0;
    }

    .tabs {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 5px;
        margin: 20px 0;
    }

    .tabs button {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        color: var(--fdb-text-secondary, #a89878);
        padding: 8px 0;
        font-size: 11px;
        cursor: pointer;
        text-transform: uppercase;
        border-radius: 2px;
        transition: all 0.2s ease;
    }

    .tabs button:hover {
        background: rgba(255, 255, 255, 0.08);
        color: var(--fdb-text-primary, #d4c5b0);
    }

    .tabs button.active {
        background: var(--fdb-accent-color, #c9a15a);
        color: var(--fdb-background-wood, #2b1d14);
        border-color: var(--fdb-accent-color, #c9a15a);
        font-weight: bold;
    }

    .tab-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }

    .scroll-area {
        flex: 1;
        overflow-y: auto;
        padding-right: 8px;
    }

    /* Custom Scrollbar */
    .scroll-area::-webkit-scrollbar {
        width: 4px;
    }
    .scroll-area::-webkit-scrollbar-thumb {
        background: var(--fdb-accent-color, #c9a15a);
        border-radius: 2px;
    }

    .section-title {
        font-size: 14px;
        text-transform: uppercase;
        color: var(--fdb-accent-color, #c9a15a);
        margin-bottom: 15px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        padding-bottom: 5px;
    }

    .control-group {
        display: flex;
        flex-direction: column;
        margin-bottom: 18px;
    }

    .control-group label {
        font-size: 12px;
        margin-bottom: 6px;
        color: var(--fdb-text-primary, #d4c5b0);
    }

    .control-group input[type="range"] {
        -webkit-appearance: none;
        width: 100%;
        height: 4px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 2px;
        outline: none;
    }

    .control-group input[type="range"]::-webkit-slider-thumb {
        -webkit-appearance: none;
        width: 12px;
        height: 12px;
        background: var(--fdb-accent-color, #c9a15a);
        border-radius: 50%;
        cursor: pointer;
        transition: transform 0.1s ease;
    }

    .control-group input[type="range"]::-webkit-slider-thumb:hover {
        transform: scale(1.2);
    }

    .color-picker-title {
        font-size: 12px;
        margin: 15px 0 8px 0;
    }

    .color-grid {
        display: grid;
        grid-template-columns: repeat(8, 1fr);
        gap: 5px;
        margin-bottom: 15px;
    }

    .color-btn {
        width: 100%;
        aspect-ratio: 1;
        border: 2px solid transparent;
        cursor: pointer;
        border-radius: 2px;
        box-sizing: border-box;
    }

    .color-btn.selected {
        border-color: #ffffff;
        box-shadow: 0 0 5px var(--fdb-accent-color, #c9a15a);
    }

    .footer {
        margin-top: 20px;
    }

    .save-btn {
        width: 100%;
        background: var(--fdb-accent-color, #c9a15a);
        border: 1px solid var(--fdb-accent-color, #c9a15a);
        color: var(--fdb-background-wood, #2b1d14);
        padding: 12px 0;
        font-weight: bold;
        cursor: pointer;
        text-transform: uppercase;
        border-radius: var(--fdb-border-radius, 4px);
        transition: all 0.2s ease;
    }

    .save-btn:hover {
        background: var(--fdb-accent-color-dark, #8a6a35);
        border-color: var(--fdb-accent-color-dark, #8a6a35);
        color: var(--fdb-text-primary, #d4c5b0);
    }

    /* Câmeras */
    .camera-controls {
        pointer-events: auto;
        position: absolute;
        top: 50px;
        right: 50px;
        background: rgba(10, 10, 10, 0.75);
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 4px;
        padding: 15px;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .cam-title {
        font-size: 11px;
        text-transform: uppercase;
        color: var(--fdb-accent-color, #c9a15a);
        text-align: center;
        margin-bottom: 5px;
    }

    .camera-controls button {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        color: #ffffff;
        padding: 6px 12px;
        font-size: 11px;
        cursor: pointer;
        border-radius: 2px;
        transition: all 0.2s ease;
    }

    .camera-controls button:hover {
        background: var(--fdb-accent-color, #c9a15a);
        color: #000000;
        border-color: var(--fdb-accent-color, #c9a15a);
    }

    /* Rotação */
    .rotation-control {
        pointer-events: auto;
        position: absolute;
        bottom: 50px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(10, 10, 10, 0.75);
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 4px;
        padding: 10px 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 6px;
        width: 300px;
    }

    .rotation-control label {
        font-size: 11px;
        text-transform: uppercase;
        color: var(--fdb-accent-color, #c9a15a);
    }

    .rotation-control input[type="range"] {
        -webkit-appearance: none;
        width: 100%;
        height: 4px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 2px;
        outline: none;
    }

    .rotation-control input[type="range"]::-webkit-slider-thumb {
        -webkit-appearance: none;
        width: 10px;
        height: 10px;
        background: var(--fdb-accent-color, #c9a15a);
        border-radius: 50%;
        cursor: pointer;
    }
</style>
