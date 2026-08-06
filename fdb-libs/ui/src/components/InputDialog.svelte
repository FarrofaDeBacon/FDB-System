<script>
    import { createEventDispatcher } from 'svelte';
    export let title = 'Diálogo de Entrada';
    export let fields = []; // Array of { type, label, placeholder, min, max, step, options, default }

    const dispatch = createEventDispatcher();

    // Map fields to their initial values
    let fieldValues = fields.map(field => {
        if (field.type === 'checkbox') return field.default || false;
        if (field.type === 'select') return field.default || (field.options && field.options[0]) || '';
        return field.default !== undefined ? field.default : '';
    });

    function handleSelectChange(index, direction) {
        const field = fields[index];
        if (!field.options || field.options.length === 0) return;
        
        let currentIndex = field.options.indexOf(fieldValues[index]);
        if (currentIndex === -1) currentIndex = 0;
        
        let nextIndex = currentIndex + direction;
        if (nextIndex < 0) nextIndex = field.options.length - 1;
        if (nextIndex >= field.options.length) nextIndex = 0;
        
        fieldValues[index] = field.options[nextIndex];
        fieldValues = [...fieldValues];
    }

    function submit() {
        dispatch('submit', fieldValues);
    }

    function cancel() {
        dispatch('cancel');
    }
</script>

<div class="input-dialog-overlay">
    <div class="input-dialog-box">
        <div class="background"></div>
        <div class="border-overlay"></div>
        
        <div class="header">
            <h2 class="dialog-title">{title}</h2>
            <div class="header-divider"></div>
        </div>

        <div class="fields-container">
            {#each fields as field, index}
                <div class="field-row">
                    <label class="field-label" for="field-{index}">{field.label}</label>
                    
                    {#if field.type === 'text'}
                        <input 
                            id="field-{index}"
                            type="text" 
                            class="input-text" 
                            placeholder={field.placeholder || ''} 
                            bind:value={fieldValues[index]} 
                        />
                    {:else if field.type === 'password'}
                        <input 
                            id="field-{index}"
                            type="password" 
                            class="input-text" 
                            placeholder={field.placeholder || ''} 
                            bind:value={fieldValues[index]} 
                        />
                    {:else if field.type === 'number'}
                        <input 
                            id="field-{index}"
                            type="number" 
                            class="input-text" 
                            min={field.min} 
                            max={field.max} 
                            step={field.step || 1}
                            bind:value={fieldValues[index]} 
                        />
                    {:else if field.type === 'select'}
                        <div class="select-carousel" id="field-{index}">
                            <button class="arrow-btn left" on:click={() => handleSelectChange(index, -1)}></button>
                            <span class="select-value">{fieldValues[index]}</span>
                            <button class="arrow-btn right" on:click={() => handleSelectChange(index, 1)}></button>
                        </div>
                    {:else if field.type === 'checkbox'}
                        <!-- svelte-ignore a11y-click-events-have-key-events -->
                        <!-- svelte-ignore a11y-no-static-element-interactions -->
                        <div class="checkbox-wrapper" id="field-{index}" on:click={() => { fieldValues[index] = !fieldValues[index]; fieldValues = [...fieldValues]; }}>
                            <div class="checkbox-box {fieldValues[index] ? 'checked' : ''}"></div>
                        </div>
                    {/if}
                </div>
            {/each}
        </div>

        <div class="actions">
            <button class="btn btn-submit" on:click={submit}>CONFIRMAR</button>
            <button class="btn btn-cancel" on:click={cancel}>CANCELAR</button>
        </div>
    </div>
</div>

<style>
    .input-dialog-overlay {
        position: absolute;
        top: 0; left: 0;
        width: 100vw; height: 100vh;
        background-color: rgba(0, 0, 0, 0.4);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 9990;
    }

    .input-dialog-box {
        position: relative;
        width: 420px;
        background-color: var(--fdb-background-color);
        border: 1px solid var(--fdb-border-color);
        padding: 3.5vh;
        box-shadow: 0 10px 30px rgba(0,0,0,0.6);
        display: flex;
        flex-direction: column;
        gap: 2.5vh;
        overflow: hidden;
        z-index: 1;
    }

    .background {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: 0;
        background-image: var(--fdb-bg-image-menu);
        background-repeat: no-repeat;
        background-size: 100% 100%;
        z-index: -1;
        opacity: 0.95;
    }

    .border-overlay {
        position: absolute;
        top: 0; left: 0; width: 100%; height: 100%;
        border-left: 4px solid var(--fdb-accent-color);
        pointer-events: none;
        z-index: 2;
    }

    .dialog-title {
        font-family: var(--fdb-font-display);
        color: var(--fdb-text-primary);
        font-size: 1.3rem;
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .header-divider {
        height: 1px;
        background-color: rgba(255, 255, 255, 0.15);
        margin-top: 1vh;
    }

    .fields-container {
        display: flex;
        flex-direction: column;
        gap: 2.7vh;
        max-height: 45vh;
        overflow-y: auto;
        padding-right: 1vh;
    }

    .fields-container::-webkit-scrollbar {
        width: 4px;
    }
    .fields-container::-webkit-scrollbar-thumb {
        background-color: rgba(255, 255, 255, 0.2);
        border-radius: 2px;
    }

    .field-row {
        display: flex;
        flex-direction: column;
        gap: 0.8vh;
    }

    .field-label {
        font-family: var(--fdb-font-body);
        color: var(--fdb-text-secondary);
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .input-text {
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: var(--fdb-border-radius);
        padding: 1.2vh 1.5vh;
        color: var(--fdb-text-primary);
        font-family: var(--fdb-font-body);
        font-size: 0.95rem;
        outline: none;
        transition: border-color 0.2s, background-color 0.2s;
    }

    .input-text:focus {
        border-color: var(--fdb-accent-color);
        background-color: rgba(255, 255, 255, 0.02);
    }

    .select-carousel {
        display: flex;
        align-items: center;
        justify-content: space-between;
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: var(--fdb-border-radius);
        padding: 0.8vh 1vh;
    }

    .select-value {
        font-family: var(--fdb-font-body);
        color: var(--fdb-text-primary);
        font-size: 0.95rem;
        font-weight: bold;
    }

    .arrow-btn {
        width: 24px;
        height: 24px;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
        background-color: transparent;
        border: none;
        cursor: pointer;
        opacity: 0.6;
        transition: opacity 0.2s;
    }

    .arrow-btn:hover {
        opacity: 1.0;
    }

    .arrow-btn.left {
        background-image: var(--fdb-bg-image-arrow-left, url('/assets/selection_arrow_left.png'));
    }
    .arrow-btn.right {
        background-image: var(--fdb-bg-image-arrow-right, url('/assets/selection_arrow_right.png'));
    }

    .checkbox-wrapper {
        display: flex;
        align-items: center;
        height: 4.5vh;
        cursor: pointer;
    }

    .checkbox-box {
        width: 20px;
        height: 20px;
        background-image: var(--fdb-bg-image-tick-box, url('/assets/tick_box.png'));
        background-size: 100% 100%;
        position: relative;
    }

    .checkbox-box.checked::after {
        content: "";
        position: absolute;
        top: 2px; left: 2px;
        width: 16px; height: 16px;
        background-image: var(--fdb-bg-image-tick, url('/assets/tick.png'));
        background-size: 100% 100%;
    }

    .actions {
        display: flex;
        gap: 1.5vh;
        margin-top: 1vh;
    }

    .btn {
        flex: 1;
        padding: 1.4vh;
        font-family: var(--fdb-font-display);
        font-size: 0.9rem;
        font-weight: bold;
        border-radius: var(--fdb-border-radius);
        cursor: pointer;
        outline: none;
        transition: background-color 0.2s, color 0.2s;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .btn-submit {
        background-color: var(--fdb-accent-color);
        border: 1px solid var(--fdb-accent-color);
        color: white;
    }

    .btn-submit:hover {
        background-color: var(--fdb-accent-color-dark);
    }

    .btn-cancel {
        background-color: transparent;
        border: 1px solid rgba(255, 255, 255, 0.15);
        color: var(--fdb-text-secondary);
    }

    .btn-cancel:hover {
        background-color: rgba(255, 255, 255, 0.05);
        color: var(--fdb-text-primary);
    }
</style>
