<script>
    import { onMount, onDestroy } from 'svelte';
    import { fly } from 'svelte/transition';

    let visible = false;
    let value = 0;
    
    // Configurações padrão (podem ser sobrescritas no ShowRiskBar)
    let config = {
        title: "Risco",
        criticalText: "P E R I G O !",
        stages: [33, 66],
        colors: {
            low: "linear-gradient(90deg, #11998e, #38ef7d)",
            medium: "linear-gradient(90deg, #f09819, #edde5d)",
            high: "linear-gradient(90deg, #ff416c, #ff4b2b)"
        }
    };

    $: isCritical = value >= 100;

    $: barColor = value > config.stages[1] ? config.colors.high :
                  value > config.stages[0] ? config.colors.medium :
                                             config.colors.low;

    $: glowColor = value > config.stages[1] ? 'rgba(255, 65, 108, 0.6)' :
                   value > config.stages[0] ? 'rgba(240, 152, 25, 0.6)' :
                                              'rgba(17, 153, 142, 0.6)';

    function handleMessage(event) {
        if (event.data.action === 'showRiskBar') {
            if (event.data.config) {
                config = { ...config, ...event.data.config };
            }
            visible = true;
            value = 0;
        } else if (event.data.action === 'updateRiskBar') {
            value = Math.min(100, Math.max(0, event.data.value));
        } else if (event.data.action === 'hideRiskBar') {
            visible = false;
        }
    }

    onMount(() => {
        window.addEventListener('message', handleMessage);
    });

    onDestroy(() => {
        window.removeEventListener('message', handleMessage);
    });
</script>

{#if visible}
    <div class="noisebar-wrapper" transition:fly="{{ y: 20, duration: 400 }}">
        <div class="noisebar-glass">
            <div class="noisebar-header">
                <div class="title-container" class:danger={isCritical}>
                    <i class="{config.icon} {isCritical ? 'pulse' : ''}"></i>
                    <span class="title-text">{isCritical ? config.criticalText : config.title}</span>
                </div>
                <span class="percentage" class:danger={isCritical}>{Math.round(value)}%</span>
            </div>
            
            <div class="noisebar-track-wrapper">
                <div class="noisebar-track">
                    {#each config.stages as stage}
                        <div class="noisebar-marker" style="left: {stage}%;"></div>
                    {/each}
                    <div 
                        class="noisebar-fill" 
                        style="width: {value}%; background: {barColor}; box-shadow: 0 0 10px {glowColor};"
                    ></div>
                </div>
            </div>
        </div>
    </div>
{/if}

<style>
    .noisebar-wrapper {
        position: fixed;
        bottom: 8%;
        left: 50%;
        transform: translateX(-50%);
        width: 320px;
        z-index: 9996;
        font-family: 'Inter', 'Roboto', sans-serif;
    }

    .noisebar-glass {
        background: rgba(15, 15, 20, 0.65);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 12px 16px;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    }

    .noisebar-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 10px;
        color: rgba(255, 255, 255, 0.85);
    }

    .noisebar-icon {
        width: 18px;
        height: 18px;
        opacity: 0.8;
    }
    
    .noisebar-icon svg {
        width: 100%;
        height: 100%;
    }

    .noisebar-icon.pulse {
        animation: pulse-icon 0.8s infinite alternate;
        color: #e74c3c;
    }

    .noisebar-title {
        flex-grow: 1;
        text-align: center;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 2px;
        transition: color 0.3s;
    }

    .noisebar-percent {
        font-size: 12px;
        font-weight: 600;
        font-variant-numeric: tabular-nums;
        width: 35px;
        text-align: right;
        opacity: 0.7;
    }

    .text-danger {
        color: #e74c3c;
        text-shadow: 0 0 8px rgba(231, 76, 60, 0.5);
    }

    .noisebar-track-wrapper {
        background: rgba(0, 0, 0, 0.4);
        border-radius: 8px;
        padding: 3px;
        box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.6);
    }

    .noisebar-track {
        width: 100%;
        height: 14px;
        background: rgba(255, 255, 255, 0.03);
        border-radius: 5px;
        position: relative;
        overflow: hidden;
    }

    .noisebar-fill {
        height: 100%;
        border-radius: 5px;
        transition: width 0.4s cubic-bezier(0.2, 0.8, 0.2, 1), background-color 0.4s;
        position: relative;
    }

    .noisebar-fill::after {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(180deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0) 100%);
        border-radius: 5px;
    }

    /* Marcações dos Estágios */
    .noisebar-marker {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 2px;
        background: rgba(255, 255, 255, 0.5);
        box-shadow: 0 0 4px rgba(0, 0, 0, 0.8);
        z-index: 10;
    }

    @keyframes pulse-icon {
        0% { transform: scale(1); opacity: 0.7; }
        100% { transform: scale(1.2); opacity: 1; }
    }
</style>
