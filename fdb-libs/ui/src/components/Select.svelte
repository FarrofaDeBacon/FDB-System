<script>
    export let value = "";
    export let options = []; // Array of strings or {value, label}
    export let disabled = false;
    export let id = '';
    
    $: parsedOptions = options.map(opt => typeof opt === 'string' ? { value: opt, label: opt } : opt);
    
    let currentIndex = 0;
    
    // Sync current index when value changes from outside
    $: {
        if (value !== undefined && value !== null) {
            let idx = parsedOptions.findIndex(o => o.value === value);
            if (idx !== -1) {
                currentIndex = idx;
            } else if (parsedOptions.length > 0) {
                // If the value doesn't match and we have options, select the first one automatically
                currentIndex = 0;
                value = parsedOptions[0].value;
            }
        }
    }
    
    function changeSelection(dir) {
        if (disabled) return;
        if (parsedOptions.length === 0) return;
        
        currentIndex += dir;
        if (currentIndex < 0) currentIndex = parsedOptions.length - 1;
        if (currentIndex >= parsedOptions.length) currentIndex = 0;
        
        value = parsedOptions[currentIndex].value;
    }
    
    $: currentLabel = parsedOptions.length > 0 && parsedOptions[currentIndex] ? parsedOptions[currentIndex].label : '-- Selecione --';
</script>

<div class="select-carousel {disabled ? 'disabled' : ''}" {id}>
    <button class="arrow-btn left" on:click={() => changeSelection(-1)} {disabled}>
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg>
    </button>
    <span class="select-value">{currentLabel}</span>
    <button class="arrow-btn right" on:click={() => changeSelection(1)} {disabled}>
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18l6-6-6-6"/></svg>
    </button>
</div>

<style>
    .select-carousel {
        display: flex;
        align-items: center;
        justify-content: space-between;
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: var(--fdb-border-radius, 4px);
        padding: 0.8vh 1vh;
        width: 100%;
        box-sizing: border-box;
        transition: border-color 0.2s;
    }

    .select-carousel:hover {
        border-color: rgba(255, 255, 255, 0.3);
    }

    .select-carousel.disabled {
        opacity: 0.5;
        pointer-events: none;
    }

    .select-value {
        font-family: var(--fdb-font-body, sans-serif);
        color: var(--fdb-text-primary, #fff);
        font-size: 0.95rem;
        font-weight: bold;
        flex: 1;
        text-align: center;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        user-select: none;
    }

    .arrow-btn {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        background-color: transparent;
        color: var(--fdb-text-primary, #fff);
        border: none;
        cursor: pointer;
        opacity: 0.6;
        transition: opacity 0.2s, transform 0.1s;
        padding: 0;
    }

    .arrow-btn:hover:not(:disabled) {
        opacity: 1.0;
        transform: scale(1.1);
    }

    .arrow-btn:active:not(:disabled) {
        transform: scale(0.9);
    }

    .arrow-btn:disabled {
        opacity: 0.2;
        cursor: not-allowed;
    }

    /* Fallback to image if variable exists in theme */
    .arrow-btn.left {
        background-image: var(--fdb-bg-image-arrow-left, none);
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
    }
    .arrow-btn.right {
        background-image: var(--fdb-bg-image-arrow-right, none);
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
    }
</style>
