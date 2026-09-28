<script>
    export let id = '';
    export let type = 'text';
    export let placeholder = '';
    export let value = '';
    export let min = undefined;
    export let max = undefined;
    export let step = undefined;
    export let disabled = false;
</script>

<input 
    {id}
    {type} 
    class="fdb-input-text {disabled ? 'disabled' : ''}" 
    {placeholder} 
    {min}
    {max}
    {step}
    {disabled}
    bind:value 
/>

<style>
    .fdb-input-text {
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: var(--fdb-border-radius);
        padding: 1.2vh 1.5vh;
        color: var(--fdb-text-primary);
        font-family: var(--fdb-font-body);
        font-size: 0.95rem;
        outline: none;
        transition: border-color 0.2s, background-color 0.2s;
        width: 100%;
        box-sizing: border-box;
    }

    .fdb-input-text:focus {
        border-color: var(--fdb-accent-color);
        background-color: rgba(255, 255, 255, 0.02);
    }
    
    .fdb-input-text.disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
</style>
