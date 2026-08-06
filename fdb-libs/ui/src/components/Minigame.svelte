<script>
    import { onMount, onDestroy, createEventDispatcher } from 'svelte';
    
    export let active = false;
    export let duration = 2000; // Tempo de varredura do ponteiro em ms
    export let targetWidth = 15; // Largura do alvo em porcentagem do círculo
    export let rounds = 3; // Total de rodadas de acerto necessárias

    const dispatch = createEventDispatcher();

    let currentRound = 1;
    let needleRotation = 0; // 0 a 360 graus
    let targetStart = 0; // angulo em graus
    let targetEnd = 0; // angulo em graus
    
    let isRunning = false;
    let animationFrameId = null;
    let startTime = null;
    
    let resultSent = false;

    // Helper functions para desenhar o arco SVG do alvo
    function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
        const angleInRadians = (angleInDegrees * Math.PI) / 180.0;
        return {
            x: centerX + radius * Math.cos(angleInRadians),
            y: centerY + radius * Math.sin(angleInRadians)
        };
    }

    function describeArc(x, y, radius, startAngle, endAngle) {
        const start = polarToCartesian(x, y, radius, endAngle);
        const end = polarToCartesian(x, y, radius, startAngle);
        const largeArcFlag = endAngle - startAngle <= 180 ? "0" : "1";
        return [
            "M", start.x, start.y, 
            "A", radius, radius, 0, largeArcFlag, 0, end.x, end.y
        ].join(" ");
    }

    // Configura e inicia uma rodada
    function setupRound() {
        // Alvo aleatório entre 80 e 280 graus (para evitar início/fim imediato)
        const minAngle = 80;
        const maxAngle = 280;
        targetStart = minAngle + Math.random() * (maxAngle - minAngle);
        // converte a largura de porcentagem para graus (1% = 3.6 graus)
        const widthInDegrees = targetWidth * 3.6;
        targetEnd = targetStart + widthInDegrees;
        
        needleRotation = 0;
        startTime = Date.now();
        isRunning = true;
        animateNeedle();
    }

    function animateNeedle() {
        if (!isRunning) return;
        const elapsed = Date.now() - startTime;
        
        needleRotation = (elapsed / duration) * 360;
        
        if (needleRotation >= 360) {
            // Estourou o tempo da rodada
            handleFail();
            return;
        }
        
        animationFrameId = requestAnimationFrame(animateNeedle);
    }

    function handleKeyPress(e) {
        if (!active || !isRunning) return;
        
        if (e.key === ' ' || e.key === 'Spacebar') {
            e.preventDefault();
            
            // Verifica se o ponteiro está na zona de sucesso
            if (needleRotation >= targetStart && needleRotation <= targetEnd) {
                handleSuccess();
            } else {
                handleFail();
            }
        }
    }

    function handleSuccess() {
        isRunning = false;
        cancelAnimationFrame(animationFrameId);
        
        if (currentRound < rounds) {
            currentRound += 1;
            setTimeout(setupRound, 400); // Pequena pausa entre as rodadas
        } else {
            sendResult(true);
        }
    }

    function handleFail() {
        isRunning = false;
        cancelAnimationFrame(animationFrameId);
        sendResult(false);
    }

    function sendResult(success) {
        if (resultSent) return;
        resultSent = true;
        dispatch('result', { success });
    }

    onMount(() => {
        window.addEventListener('keydown', handleKeyPress);
        if (active) {
            currentRound = 1;
            resultSent = false;
            setupRound();
        }
    });

    onDestroy(() => {
        window.removeEventListener('keydown', handleKeyPress);
        cancelAnimationFrame(animationFrameId);
    });

    $: if (active) {
        currentRound = 1;
        resultSent = false;
        setupRound();
    } else {
        isRunning = false;
        cancelAnimationFrame(animationFrameId);
    }
</script>

{#if active}
    <div class="minigame-container">
        <div class="minigame-box">
            <div class="border-overlay"></div>
            
            <span class="minigame-title">PRESSIONE <span class="key-highlight">ESPAÇO</span> NO ALVO</span>
            
            <div class="radial-gauge-container">
                <svg width="180" height="180" viewBox="0 0 180 180" class="svg-gauge">
                    <circle cx="90" cy="90" r="70" class="gauge-track" />
                    
                    {#if isRunning}
                        <path 
                            d={describeArc(90, 90, 70, targetStart, targetEnd)} 
                            class="gauge-target" 
                        />
                    {/if}
                    
                    <line 
                        x1="90" y1="90" 
                        x2="90" y2="20" 
                        class="gauge-needle"
                        transform="rotate({needleRotation} 90 90)"
                    />
                    
                    <circle cx="90" cy="90" r="22" class="gauge-center" />
                </svg>
                
                <div class="gauge-core-icon"></div>
            </div>

            <!-- Bolinhas indicadoras de rodada -->
            <div class="rounds-container">
                {#each Array(rounds) as _, i}
                    <div class="round-dot {i < currentRound - 1 ? 'completed' : i === currentRound - 1 && isRunning ? 'active' : ''}"></div>
                {/each}
            </div>
        </div>
    </div>
{/if}

<style>
    .minigame-container {
        position: absolute;
        top: 0; left: 0;
        width: 100vw; height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 9980;
        pointer-events: none;
    }

    .minigame-box {
        position: relative;
        background-color: var(--fdb-background-color);
        border: 1px solid var(--fdb-border-color);
        padding: 3vh 4vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 2.5vh;
        box-shadow: 0 8px 30px rgba(0,0,0,0.6);
        border-radius: var(--fdb-border-radius);
        pointer-events: auto;
        overflow: hidden;
    }

    .minigame-box::before {
        content: "";
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        background-image: var(--fdb-bg-image-card);
        background-size: 100% 100%;
        opacity: 0.05;
        z-index: 0;
        pointer-events: none;
    }

    .border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-top: 4px solid var(--fdb-accent-color);
        pointer-events: none;
        z-index: 2;
    }

    .minigame-title {
        font-family: var(--fdb-font-display);
        color: var(--fdb-text-primary);
        font-size: 0.95rem;
        font-weight: bold;
        letter-spacing: 1px;
        text-transform: uppercase;
        text-shadow: 0 1px 3px rgba(0,0,0,0.8);
    }

    .key-highlight {
        color: var(--fdb-accent-color);
        border: 1px solid var(--fdb-accent-color);
        padding: 2px 6px;
        border-radius: 3px;
        margin: 0 4px;
        background-color: rgba(201, 161, 90, 0.15);
    }

    .radial-gauge-container {
        position: relative;
        width: 180px;
        height: 180px;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .svg-gauge {
        transform: rotate(-90deg); /* Rotaciona para iniciar a agulha no topo */
    }

    .gauge-track {
        fill: none;
        stroke: rgba(255, 255, 255, 0.1);
        stroke-width: 8px;
    }

    .gauge-target {
        fill: none;
        stroke: var(--fdb-accent-color);
        stroke-width: 10px;
        stroke-linecap: round;
        filter: drop-shadow(0 0 4px var(--fdb-accent-color));
    }

    .gauge-needle {
        stroke: #c0392b;
        stroke-width: 4px;
        stroke-linecap: round;
        filter: drop-shadow(0 0 2px rgba(192, 57, 43, 0.8));
    }

    .gauge-center {
        fill: #222;
        stroke: var(--fdb-border-color);
        stroke-width: 1px;
    }

    .gauge-core-icon {
        position: absolute;
        width: 24px;
        height: 24px;
        background-image: var(--fdb-bg-image-lock, url('/assets/lock.png'));
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
        opacity: 0.8;
        filter: brightness(0.85) sepia(0.2);
    }

    .rounds-container {
        display: flex;
        gap: 1vh;
    }

    .round-dot {
        width: 10px;
        height: 10px;
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 50%;
        background-color: rgba(255, 255, 255, 0.05);
        transition: background-color 0.2s, border-color 0.2s;
    }

    .round-dot.completed {
        background-color: var(--fdb-accent-color);
        border-color: var(--fdb-accent-color);
        box-shadow: 0 0 5px var(--fdb-accent-color);
    }

    .round-dot.active {
        border-color: #c0392b;
        background-color: rgba(192, 57, 43, 0.2);
    }
</style>
