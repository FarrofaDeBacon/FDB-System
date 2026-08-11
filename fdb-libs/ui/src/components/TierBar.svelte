<script>
    import { onDestroy, createEventDispatcher } from 'svelte';

    export let active = false;
    export let duration = 5.0; // segundos
    export let images = {}; // { common, uncommon, rare }
    export let zones = {
        common: { start: 10, end: 35 },
        uncommon: { start: 50, end: 65 },
        rare: { start: 80, end: 88 }
    };

    const dispatch = createEventDispatcher();

    let cursorX = 0;
    let cursorDirection = 1;
    let cursorSpeed = 1.2;
    let timeRemaining = duration;
    let totalTime = duration;
    let activeZone = null;
    let gameLoopId = null;
    let resultSent = false;

    $: if (active) {
        startGame();
    }

    function getHitZone(x) {
        if (x >= zones.common.start && x <= zones.common.end) return 'common';
        if (x >= zones.uncommon.start && x <= zones.uncommon.end) return 'uncommon';
        if (x >= zones.rare.start && x <= zones.rare.end) return 'rare';
        return null;
    }

    function startGame() {
        cursorX = 0;
        cursorDirection = 1;
        cursorSpeed = 1.0 + Math.random() * 0.5;
        timeRemaining = duration;
        totalTime = duration;
        activeZone = null;
        resultSent = false;

        let lastTime = performance.now();

        function loop(now) {
            const delta = (now - lastTime) / 1000;
            lastTime = now;

            // cursorSpeed é calibrado em "% por frame de 16ms" (como o script original),
            // então convertemos pra "% por segundo" multiplicando por ~60 antes de aplicar o delta real.
            cursorX += cursorSpeed * cursorDirection * (delta * 60);
            if (cursorX >= 100) {
                cursorX = 100;
                cursorDirection = -1;
            } else if (cursorX <= 0) {
                cursorX = 0;
                cursorDirection = 1;
            }

            activeZone = getHitZone(cursorX);

            timeRemaining -= delta;
            if (timeRemaining <= 0) {
                timeRemaining = 0;
                finish(false, null);
                return;
            }

            gameLoopId = requestAnimationFrame(loop);
        }

        gameLoopId = requestAnimationFrame(loop);
    }

    function handleKeydown(event) {
        if (!active || resultSent) return;

        if (event.code === 'Space') {
            event.preventDefault();
            const hit = getHitZone(cursorX);
            finish(hit !== null, hit);
        } else if (event.code === 'Escape' || event.code === 'Backspace') {
            event.preventDefault();
            finish(false, null);
        }
    }

    function finish(success, tier) {
        if (resultSent) return;
        resultSent = true;

        if (gameLoopId) {
            cancelAnimationFrame(gameLoopId);
            gameLoopId = null;
        }

        // Pequeno delay pra jogador ver onde o cursor parou, igual ao original
        setTimeout(() => {
            dispatch('result', { success, tier });
        }, 400);
    }

    onDestroy(() => {
        if (gameLoopId) cancelAnimationFrame(gameLoopId);
    });
</script>

<svelte:window on:keydown={handleKeydown} />

{#if active}
    <div class="tierbar-container">
        <div class="tierbar-header">Tempo Restante</div>

        <div class="tierbar-timebar-track">
            <div
                class="tierbar-timebar-fill"
                style="width: {(timeRemaining / totalTime) * 100}%;"
            ></div>
        </div>

        <div class="tierbar-items">
            {#each ['common', 'uncommon', 'rare'] as tier}
                <div class="tierbar-item tierbar-item-{tier}" class:active={activeZone === tier}>
                    {#if images[tier]}
                        <img src={images[tier]} alt={tier} />
                    {/if}
                </div>
            {/each}
        </div>

        <div class="tierbar-track">
            {#each ['common', 'uncommon', 'rare'] as tier}
                <div
                    class="tierbar-zone tierbar-zone-{tier}"
                    style="left: {zones[tier].start}%; width: {zones[tier].end - zones[tier].start}%;"
                ></div>
            {/each}
            <div class="tierbar-cursor" style="left: {cursorX}%;"></div>
        </div>

        <div class="tierbar-hint">Aperte <span class="key">ESPAÇO</span> para pegar um item</div>
    </div>
{/if}

<style>
    .tierbar-container {
        position: fixed;
        bottom: 12%;
        left: 50%;
        transform: translateX(-50%);
        width: 480px;
        background: var(--fdb-background-color, rgba(15, 15, 15, 0.92));
        border: 1px solid var(--fdb-border-color, rgba(201, 161, 90, 0.4));
        border-radius: 6px;
        padding: 16px 20px;
        z-index: 9997;
        font-family: var(--fdb-font-family, 'Rye', serif);
        color: var(--fdb-text-color, #e8dcc8);
    }

    .tierbar-header {
        font-size: 13px;
        letter-spacing: 1px;
        text-transform: uppercase;
        opacity: 0.8;
        margin-bottom: 6px;
    }

    .tierbar-timebar-track {
        width: 100%;
        height: 4px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 2px;
        overflow: hidden;
        margin-bottom: 16px;
    }

    .tierbar-timebar-fill {
        height: 100%;
        background: var(--fdb-accent-color, #4caf50);
        transition: width 0.1s linear;
    }

    .tierbar-items {
        display: flex;
        gap: 12px;
        margin-bottom: 12px;
    }

    .tierbar-item {
        flex: 1;
        aspect-ratio: 1;
        border: 2px solid rgba(255, 255, 255, 0.15);
        border-radius: 4px;
        background: rgba(0, 0, 0, 0.3);
        display: flex;
        align-items: center;
        justify-content: center;
        transition: border-color 0.1s, box-shadow 0.1s;
    }

    .tierbar-item img {
        width: 70%;
        height: 70%;
        object-fit: contain;
    }

    .tierbar-item-common.active { border-color: #d9d9d9; box-shadow: 0 0 12px rgba(217,217,217,0.5); }
    .tierbar-item-uncommon.active { border-color: #d4af37; box-shadow: 0 0 12px rgba(212,175,55,0.5); }
    .tierbar-item-rare.active { border-color: #3aa0d4; box-shadow: 0 0 12px rgba(58,160,212,0.5); }

    .tierbar-track {
        position: relative;
        width: 100%;
        height: 10px;
        background: rgba(255, 255, 255, 0.08);
        border-radius: 5px;
        margin-bottom: 14px;
    }

    .tierbar-zone {
        position: absolute;
        top: 0;
        height: 100%;
        border-radius: 5px;
    }

    .tierbar-zone-common { background: rgba(217, 217, 217, 0.6); }
    .tierbar-zone-uncommon { background: rgba(212, 175, 55, 0.6); }
    .tierbar-zone-rare { background: rgba(58, 160, 212, 0.6); }

    .tierbar-cursor {
        position: absolute;
        top: -3px;
        width: 3px;
        height: 16px;
        background: #fff;
        transform: translateX(-50%);
        box-shadow: 0 0 4px rgba(255,255,255,0.8);
    }

    .tierbar-hint {
        text-align: center;
        font-size: 13px;
        opacity: 0.85;
    }

    .key {
        background: rgba(255, 255, 255, 0.15);
        padding: 2px 8px;
        border-radius: 3px;
        font-weight: bold;
    }
</style>
