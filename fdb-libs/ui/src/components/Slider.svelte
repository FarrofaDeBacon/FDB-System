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
        padding: 1.5vh 0;
        background: transparent;
        border: none;
    }

    .slider-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 1.5vh;
    }

    .label {
        font-size: 0.95rem;
        font-weight: 500;
        letter-spacing: 0.5px;
    }

    .number-input {
        width: 50px;
        background: transparent;
        border: none;
        border-bottom: 2px solid var(--fdb-accent-color);
        color: var(--fdb-text-primary);
        font-family: var(--fdb-font-display);
        border-radius: 0;
        padding: 0.3vh 0.5vh;
        text-align: center;
        font-size: 1rem;
        outline: none;
    }

    .number-input:focus {
        border-bottom-color: #fff;
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
        height: 3vh;
        padding: 0 1.5vh;
    }

    .range-input {
        -webkit-appearance: none;
        width: 100%;
        height: 6px;
        background-color: rgba(255, 255, 255, 0.15);
        border: none;
        border-radius: 2px;
        outline: none;
        margin: 0;
        position: relative;
    }

    .range-input::-webkit-slider-thumb {
        -webkit-appearance: none;
        appearance: none;
        width: 20px;
        height: 30px;
        border-radius: 0;
        background-color: var(--fdb-accent-color);
        -webkit-mask-image: url('/assets/tank_meter_marker.png');
        mask-image: url('/assets/tank_meter_marker.png');
        -webkit-mask-size: 100% 100%;
        mask-size: 100% 100%;
        -webkit-mask-repeat: no-repeat;
        mask-repeat: no-repeat;
        -webkit-mask-position: center;
        mask-position: center;
        cursor: pointer;
        transition: transform 0.1s ease;
        box-shadow: none;
        margin-top: -10px; /* Offset to center the thumb over the track */
    }
    
    .range-input::-webkit-slider-thumb:hover {
        transform: scale(1.1);
    }

    .range-input::-webkit-slider-thumb:active {
        transform: scale(0.9);
    }
</style>
