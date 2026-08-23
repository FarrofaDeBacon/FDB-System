<script>
    let { 
        title = "Atenção", 
        message = "", 
        type = "alert", // "alert" ou "confirm"
        onConfirm = () => {},
        onCancel = () => {}
    } = $props();

    function handleConfirm() {
        onConfirm();
    }

    function handleCancel() {
        onCancel();
    }
</script>

<div class="modal-overlay">
    <div class="modal-content">
        <h3>{title}</h3>
        <p>{message}</p>
        
        <div class="modal-actions">
            {#if type === "confirm"}
                <button class="btn-cancel" onclick={handleCancel}>Cancelar</button>
            {/if}
            <button class="btn-confirm" onclick={handleConfirm}>OK</button>
        </div>
    </div>
</div>

<style>
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        backdrop-filter: blur(4px);
    }

    .modal-content {
        background: #1a1a1a;
        border: 1px solid #333;
        border-radius: 8px;
        padding: 24px;
        min-width: 320px;
        max-width: 400px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
        color: #eee;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    h3 {
        margin: 0 0 12px 0;
        font-size: 18px;
        color: #fff;
    }

    p {
        margin: 0 0 24px 0;
        font-size: 14px;
        color: #ccc;
        line-height: 1.5;
    }

    .modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
    }

    button {
        padding: 8px 16px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s;
    }

    .btn-cancel {
        background: #333;
        color: #ddd;
    }

    .btn-cancel:hover {
        background: #444;
    }

    .btn-confirm {
        background: #27ae60;
        color: white;
    }

    .btn-confirm:hover {
        background: #2ecc71;
    }
</style>
