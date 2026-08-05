<script>
    import { createEventDispatcher } from 'svelte';
    
    export let id = '';
    export let label = 'Slider';
    export let min = 0;
    export let max = 100;
    export let step = 1;
    export let value = 0;

    const dispatch = createEventDispatcher();

    // Calculate the percentage for the progress track
    $: percentage = ((value - min) / (max - min)) * 100;

    function handleChange(event) {
        let newVal = parseFloat(event.target.value);
        if (newVal < min) newVal = min;
        if (newVal > max) newVal = max;
        value = newVal;
        
        dispatch('change', { value });
    }
</script>

<div class="slider-container">
    <div class="slider-header">
        <span class="label">{label}</span>
        <input 
            type="number" 
            class="number-input" 
            {min} {max} {step}
            bind:value 
            on:input={handleChange}
        />
    </div>
    
    <div class="track-wrapper">
        <input 
            type="range" 
            class="range-input" 
            {min} {max} {step} 
            bind:value 
            on:input={handleChange}
            style="--progress: {percentage}%"
        />
    </div>
</div>

<style>
    .slider-container {
        display: flex;
        flex-direction: column;
        gap: 0.8vh;
        width: 100%;
        padding: 1.5vh;
        background: rgba(0, 0, 0, 0.2);
        border: 1px solid var(--fdb-border-color);
        border-radius: calc(var(--fdb-border-radius) / 2);
    }

    .slider-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
    }

    .number-input {
        width: 50px;
        background: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        color: var(--fdb-accent-color);
        border-radius: 4px;
        padding: 0.3vh 0.5vh;
        text-align: center;
        font-family: inherit;
        font-size: 0.9rem;
        outline: none;
        transition: border-color 0.2s;
    }

    .number-input:focus {
        border-color: var(--fdb-accent-color);
    }

    .number-input::-webkit-inner-spin-button,
    .number-input::-webkit-outer-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    .track-wrapper {
        position: relative;
        width: 100%;
        display: flex;
        align-items: center;
        height: 2vh;
    }

    .range-input {
        -webkit-appearance: none;
        width: 100%;
        height: 6px;
        background: linear-gradient(to right, var(--fdb-accent-color) var(--progress), rgba(255, 255, 255, 0.1) var(--progress));
        border-radius: 3px;
        outline: none;
        margin: 0;
    }

    .range-input::-webkit-slider-thumb {
        -webkit-appearance: none;
        appearance: none;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        background-color: transparent;
        background-image: var(--fdb-thumb-image);
        background-size: 100%;
        background-position: center;
        background-repeat: no-repeat;
        cursor: pointer;
        transition: transform 0.1s ease;
        margin-top: -12px; /* Center it vertically since thumb is larger than track */
    }
    
    .range-input::-webkit-slider-thumb:hover {
        transform: scale(1.1);
    }

    .range-input::-webkit-slider-thumb:active {
        transform: scale(1.05);
    }
</style>
