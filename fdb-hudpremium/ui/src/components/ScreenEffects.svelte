<script>
    import { coreStatus, survivalEngines } from '../store/hudStore';

    $: stress = $coreStatus.stress;
    $: poison = $survivalEngines.poison;
    $: drunkenness = $survivalEngines.drunkenness;

    // Calcular valores de efeitos com clamp
    $: safePoison = Math.min(100, poison);
    $: safeDrunk = Math.min(100, drunkenness);

    $: blurAmount = safePoison > 0 ? (safePoison / 100) * 10 : 0; // Até 10px de blur
    $: tiltDeg = safeDrunk > 0 ? (safeDrunk / 100) * 5 : 0; // Até 5 graus de inclinação
    $: isStressed = stress > 80;
    $: isDrunk = safeDrunk > 0;
</script>

<div class="screen-effects-container">
    <!-- Camada de Blur (Estática para salvar GPU no RedM CEF) -->
    {#if safePoison > 0 || safeDrunk > 0}
        <div 
            class="effect-layer static-filters"
            style="
                --blur-amt: {blurAmount}px;
                --sepia-amt: {safeDrunk/100};
            "
        ></div>
    {/if}

    <!-- Camada de Inclinação (Bebedeira) -->
    <div 
        class="effect-layer" 
        class:drunk-sway={isDrunk}
        style="
            --tilt-deg: {tiltDeg}deg;
            --tilt-deg-neg: -{tiltDeg}deg;
        "
    >
        <!-- Camada de Trepidação (Estresse) -->
        <div class="effect-layer" class:stress-shake={isStressed}>
            
            <!-- Sobreposição visual para embriaguez -->
            {#if safeDrunk > 0}
                <div class="drunk-overlay" style="opacity: {safeDrunk / 200}"></div>
            {/if}

            <!-- Sobreposição pulsante vermelha para estresse extremo -->
            {#if isStressed}
                <div class="stress-overlay"></div>
            {/if}

        </div>
    </div>
</div>

<style>
    .screen-effects-container {
        position: fixed;
        top: -10%;
        left: -10%;
        width: 120%;
        height: 120%;
        pointer-events: none;
        z-index: 9999;
    }

    .effect-layer {
        position: absolute;
        inset: 0;
        pointer-events: none;
        will-change: transform;
    }

    .static-filters {
        transition: backdrop-filter 0.5s ease;
        will-change: backdrop-filter;
    }

    /* Animação CSS para a bebedeira (tilt lento) */
    @keyframes drunkSwayAnim {
        0% { transform: rotate(var(--tilt-deg-neg)) scale(1.05); }
        50% { transform: rotate(var(--tilt-deg)) scale(1.05); }
        100% { transform: rotate(var(--tilt-deg-neg)) scale(1.05); }
    }

    :global(.drunk-sway) {
        animation: drunkSwayAnim 4s infinite ease-in-out;
    }

    /* Animação de tremor de estresse */
    @keyframes stressShakeAnim {
        0% { transform: translate(0, 0) scale(1.02); }
        25% { transform: translate(3px, -3px) scale(1.02); }
        50% { transform: translate(-3px, 3px) scale(1.02); }
        75% { transform: translate(-3px, -3px) scale(1.02); }
        100% { transform: translate(3px, 3px) scale(1.02); }
    }

    :global(.stress-shake) {
        animation: stressShakeAnim 0.1s infinite cubic-bezier(.36,.07,.19,.97);
    }

    .drunk-overlay {
        position: absolute;
        inset: 0;
        background: radial-gradient(circle, transparent 40%, rgba(200, 100, 0, 0.4) 100%);
    }

    .stress-overlay {
        position: absolute;
        inset: 0;
        background: radial-gradient(circle, transparent 60%, rgba(255, 0, 0, 0.15) 100%);
        animation: pulseStress 1s infinite alternate ease-in-out;
    }

    @keyframes pulseStress {
        from { opacity: 0.5; }
        to { opacity: 1; }
    }
</style>
