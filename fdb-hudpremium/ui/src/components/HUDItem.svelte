<script>
    import alcohol from '../../public/assets/alcohol.svg?raw';
    import armor from '../../public/assets/armor.svg?raw';
    import buff_cold from '../../public/assets/buff_cold.svg?raw';
    import buff_heat from '../../public/assets/buff_heat.svg?raw';
    import food from '../../public/assets/food.svg?raw';
    import health from '../../public/assets/health.svg?raw';
    import horse_health from '../../public/assets/horse_health.svg?raw';
    import horse_stamina from '../../public/assets/horse_stamina.svg?raw';
    import hygiene from '../../public/assets/hygiene.svg?raw';
    import illness from '../../public/assets/illness.svg?raw';
    import oxygen from '../../public/assets/oxygen.svg?raw';
    import poison from '../../public/assets/poison.svg?raw';
    import stamina from '../../public/assets/stamina.svg?raw';
    import stress from '../../public/assets/stress.svg?raw';
    import temp_cold from '../../public/assets/temp_cold.svg?raw';
    import temp_hot from '../../public/assets/temp_hot.svg?raw';
    import urine from '../../public/assets/urine.svg?raw';
    import voice from '../../public/assets/voice.svg?raw';
    import water from '../../public/assets/water.svg?raw';

    import { editorState } from '../store/hudStore';

    const svgMap = {
        'alcohol.svg': alcohol,
        'armor.svg': armor,
        'buff_cold.svg': buff_cold,
        'buff_heat.svg': buff_heat,
        'food.svg': food,
        'health.svg': health,
        'horse_health.svg': horse_health,
        'horse_stamina.svg': horse_stamina,
        'hygiene.svg': hygiene,
        'illness.svg': illness,
        'oxygen.svg': oxygen,
        'poison.svg': poison,
        'stamina.svg': stamina,
        'stress.svg': stress,
        'temp_cold.svg': temp_cold,
        'temp_hot.svg': temp_hot,
        'urine.svg': urine,
        'voice.svg': voice,
        'water.svg': water,
    };

    export let itemId = 'unknown'; // injected by StatusCores
    export let value = 100;      // Outer ring value
    export let innerValue = 100; // Inner core fill value (0-100)
    export let icon = '';        
    export let outerColor = '#ffffff'; // Fallback
    export let innerColor = '#ffffff'; // Controlled by StatusCores
    export let trackColor = null;      // Custom background track color
    export let isFlashing = false;

    // Retrieve configs
    $: cfg = $editorState.configs[itemId] || null;

    // Core Properties
    $: visible = cfg ? cfg.visible : true;
    $: scale = cfg ? cfg.scale : 1.0;
    
    // Outer Color Logic: Gold (>100) -> Max (==100) -> Damage (isFlashing) -> OuterColor
    $: actualOuterColor = cfg ? (
        value > 100 ? cfg.goldColor :
        value === 100 ? cfg.maxOuterColor :
        isFlashing ? cfg.outerDamageColor :
        cfg.outerColor
    ) : outerColor;

    // SVG Math
    const radius = 22;
    const circumference = 2 * Math.PI * radius;
    $: fillPercent = Math.min(100, Math.max(0, value)) / 100;
    $: strokeDashoffset = circumference - (fillPercent * circumference);

    // Segments Math (via Mask)
    $: showSegments = cfg ? cfg.showSegments : false;
    $: segmentsCount = cfg ? cfg.segmentsCount : 10;
    const gapPx = 3;
    $: segmentLength = showSegments ? (circumference / segmentsCount) - gapPx : circumference;
    $: gapLength = showSegments ? gapPx : 0;
    $: maskDashArray = `${segmentLength} ${gapLength}`;
    
    // Unique ID for SVG Mask to avoid conflicts between instances
    const maskId = `mask-${itemId}-${Math.random().toString(36).substr(2, 9)}`;

    $: clipHeight = Math.max(0, Math.min(100, innerValue));
    $: iconName = icon ? icon.split('/').pop() : '';
    $: svgMarkup = svgMap[iconName] || '';
</script>

{#if visible}
<div class="hud-item-wrapper" style="transform: scale({scale});">
    <div class="hud-item" class:flashing={isFlashing}>
        
        <!-- Outer Ring (SVG Progress) -->
        <svg class="outer-ring" width="56" height="56" viewBox="0 0 56 56">
            <defs>
                <!-- Mask for segments -->
                <mask id="{maskId}">
                    <circle
                        cx="28" cy="28" r="{radius}"
                        stroke-width="4"
                        fill="none"
                        stroke="white"
                        stroke-dasharray="{maskDashArray}"
                    />
                </mask>
            </defs>

            <!-- G layer applies the mask to both track and fill -->
            <g mask="url(#{maskId})">
                <circle
                    class="ring-track"
                    cx="28" cy="28" r="{radius}"
                    stroke-width="4"
                    fill="none"
                    stroke="{trackColor || ''}"
                />
                <circle
                    class="ring-fill"
                    cx="28" cy="28" r="{radius}"
                    stroke-width="4"
                    fill="none"
                    stroke="{actualOuterColor}"
                    stroke-dasharray="{circumference}"
                    stroke-dashoffset="{strokeDashoffset}"
                />
            </g>
        </svg>

        <!-- Inner Core Icon -->
        {#if svgMarkup}
        <div class="inner-core">
            <div class="icon-wrapper" style="--fill-h: {clipHeight}%">
                <div class="icon-ghost" style="color: {innerColor}">
                    {@html svgMarkup}
                </div>
                <div class="icon-fill-clip" style="height: {clipHeight}%">
                    <div class="icon-filled" style="color: {innerColor}">
                        {@html svgMarkup}
                    </div>
                </div>
            </div>
        </div>
        {/if}

        <!-- Badge / Tip Numérica -->
        {#if cfg && cfg.badge && cfg.badge.showValue}
            <div 
                class="badge-tip pos-{cfg.badge.position}" 
                class:has-bg={cfg.badge.showBackground}
                style="
                    color: {cfg.badge.textColor};
                    font-size: {cfg.badge.fontSize}px;
                    transform: scale({cfg.badge.badgeScale});
                "
            >
                {Math.round(value)}
            </div>
        {/if}
    </div>
</div>
{/if}

<style>
    .hud-item-wrapper {
        display: flex;
        justify-content: center;
        align-items: center;
        /* A transição permite visualizar a escala de forma suave no painel */
        transition: transform 0.2s cubic-bezier(0.2, 0, 0, 1); 
    }

    .hud-item {
        position: relative;
        width: 56px;
        height: 56px;
        display: flex;
        justify-content: center;
        align-items: center;
        margin: 4px;
        transition: transform 0.2s ease-out;
    }

    .outer-ring {
        position: absolute;
        top: 0;
        left: 0;
        z-index: 2;
        transform: rotate(-90deg); /* Inicia progresso a partir do topo */
    }

    .ring-track {
        stroke: rgba(0, 0, 0, 0.5);
    }

    .ring-fill {
        transition: stroke-dashoffset 0.3s ease-out, stroke 0.3s ease-out;
        stroke-linecap: round;
    }

    .inner-core {
        position: absolute;
        width: 30px;
        height: 30px;
        z-index: 3;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .icon-wrapper {
        position: relative;
        width: 100%;
        height: 100%;
    }

    .icon-wrapper :global(svg) {
        width: 100%;
        height: 100%;
        display: block;
    }
    
    .icon-wrapper :global(svg path),
    .icon-wrapper :global(svg circle),
    .icon-wrapper :global(svg rect),
    .icon-wrapper :global(svg polygon),
    .icon-wrapper :global(svg ellipse) {
        fill: currentColor !important;
    }

    .icon-ghost {
        position: absolute;
        top: 0; left: 0;
        width: 100%;
        height: 100%;
        opacity: 0.25;
    }

    .icon-fill-clip {
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        overflow: hidden;
        transition: height 0.3s ease-out;
    }

    .icon-filled {
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 30px;
    }

    @keyframes flash {
        0%   { transform: scale(1);   filter: brightness(1); }
        50%  { transform: scale(1.1); filter: brightness(1.8); }
        100% { transform: scale(1);   filter: brightness(1); }
    }

    .flashing {
        animation: flash 1s infinite ease-in-out;
    }

    /* === BADGES === */
    .badge-tip {
        position: absolute;
        z-index: 10;
        font-family: 'Segoe UI', sans-serif;
        font-weight: 900;
        text-shadow: 0 1px 3px rgba(0,0,0,0.8), 0 0 2px rgba(0,0,0,1);
        white-space: nowrap;
        pointer-events: none;
        transition: all 0.2s ease;
    }

    .badge-tip.has-bg {
        background: rgba(0,0,0,0.7);
        padding: 2px 6px;
        border-radius: 12px;
        border: 1px solid rgba(255,255,255,0.2);
        box-shadow: 0 2px 5px rgba(0,0,0,0.5);
        text-shadow: none; /* if bg, we don't need heavy text shadow */
    }

    /* posições */
    .pos-top {
        bottom: calc(100% + 5px); /* ancorado no topo (bottom away from hud-item center) */
    }
    .pos-bottom {
        top: calc(100% + 5px);
    }
    .pos-left {
        right: calc(100% + 5px);
    }
    .pos-right {
        left: calc(100% + 5px);
    }
</style>
