<script>
    import { editorState } from '../store/hudStore';
    import { onDestroy } from 'svelte';

    export let id; // ex: 'PlayerCores', 'HorseCores'
    export let defaultX = 0;
    export let defaultY = 0;

    let isEditing = false;
    let localX = defaultX;
    let localY = defaultY;
    let scale = 1.0;

    let dragging = false;
    let startMouseX = 0;
    let startMouseY = 0;
    let initialX = 0;
    let initialY = 0;

    const unsubscribe = editorState.subscribe(state => {
        isEditing = state.isEditing;
        if (!dragging) {
            localX = state.positions[id]?.x ?? defaultX;
            localY = state.positions[id]?.y ?? defaultY;
        }
        scale = state.configs[id]?.scale ?? 1.0;
    });

    onDestroy(() => {
        unsubscribe();
    });

    function onMouseDown(e) {
        if (!isEditing) return;
        dragging = true;
        startMouseX = e.clientX;
        startMouseY = e.clientY;
        initialX = localX;
        initialY = localY;

        window.addEventListener('mousemove', onMouseMove);
        window.addEventListener('mouseup', onMouseUp);
    }

    function onMouseMove(e) {
        if (!dragging) return;
        const dx = e.clientX - startMouseX;
        const dy = e.clientY - startMouseY;
        localX = initialX + dx;
        localY = initialY + dy;
    }

    function onMouseUp() {
        if (!dragging) return;
        dragging = false;
        window.removeEventListener('mousemove', onMouseMove);
        window.removeEventListener('mouseup', onMouseUp);

        // Salvar a nova posição na store
        editorState.update(s => {
            const newPositions = { ...s.positions, [id]: { x: localX, y: localY } };
            return { ...s, positions: newPositions };
        });
    }
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div 
    class="draggable-wrapper"
    class:editing={isEditing}
    style="transform: translate({localX}px, {localY}px) scale({scale});"
    on:mousedown={onMouseDown}
>
    <!-- Slot onde o conteúdo do grupo (StatusCores, Buffs, etc) será injetado -->
    <slot></slot>

    {#if isEditing}
        <div class="edit-overlay">
            <span class="label">{id}</span>
        </div>
    {/if}
</div>

<style>
    .draggable-wrapper {
        position: absolute;
        top: 0;
        left: 0;
        /* O referencial x/y agora é absoluto a partir da origem do container pai. */
        transition: border 0.2s ease, background 0.2s ease;
        transform-origin: center; /* Ponto de escala */
        pointer-events: none;
    }

    .editing {
        cursor: grab;
        border: 2px dashed rgba(255, 255, 255, 0.4);
        background: rgba(0, 0, 0, 0.2);
        padding: 5px;
        border-radius: 8px;
        pointer-events: auto; /* Só captura mouse quando editando */
    }

    .editing:active {
        cursor: grabbing;
    }

    .edit-overlay {
        position: absolute;
        top: -20px;
        left: 0;
        background: rgba(0,0,0,0.7);
        color: white;
        font-size: 10px;
        padding: 2px 6px;
        border-radius: 4px;
        pointer-events: none;
    }
</style>
