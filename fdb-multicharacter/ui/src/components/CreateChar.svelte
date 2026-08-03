<script>
  import { showCreateForm, selectedSlot } from '../stores/multicharacter.js';
  import { fetchNui } from '../utils/nui.js';

  function handleCreate() {
    const cid = $selectedSlot;
    if (cid !== null) {
      fetchNui('createNewCharacter', { cid });
      showCreateForm.set(false);
    }
  }

  function handleClose() {
    showCreateForm.set(false);
  }
</script>

<div class="modal-overlay" onclick={handleClose}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <div class="modal-header">
      <h2>Create New Character</h2>
      <button class="modal-close" onclick={handleClose}>✕</button>
    </div>
    <div class="modal-body">
      <p class="modal-text">
        You are about to create a new character in Slot {$selectedSlot}.
        Press Confirm to proceed to the character creator.
      </p>
    </div>
    <div class="modal-footer">
      <button class="btn-cancel" onclick={handleClose}>Cancel</button>
      <button class="btn-confirm" onclick={handleCreate}>Confirm</button>
    </div>
  </div>
</div>

<style>
  .modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    animation: fadeIn 0.2s ease-out;
  }

  .modal {
    background: var(--rdr-panel-bg);
    border: 2px solid var(--rdr-slot-border);
    border-radius: 8px;
    padding: 0;
    width: 400px;
    box-shadow: 0 16px 48px var(--rdr-shadow);
    animation: slideInUp 0.3s ease-out;
    position: relative;
  }

  .modal::before {
    content: '';
    position: absolute;
    inset: 3px;
    border: 1px solid rgba(198, 11, 13, 0.05);
    border-radius: 5px;
    pointer-events: none;
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px 12px;
    border-bottom: 1px solid var(--rdr-slot-border);
  }

  .modal-header h2 {
    font-family: var(--rdr-font-display);
    font-size: 16px;
    color: var(--rdr-red);
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  .modal-close {
    background: transparent;
    border: 2px solid var(--rdr-red);
    color: var(--rdr-white);
    width: 28px;
    height: 28px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    transition: all 0.2s ease;
  }

  .modal-close:hover {
    background: var(--rdr-red);
  }

  .modal-body {
    padding: 24px;
  }

  .modal-text {
    font-family: var(--rdr-font-body);
    font-size: 14px;
    color: var(--rdr-white);
    line-height: 1.6;
    opacity: 0.9;
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding: 12px 24px 20px;
  }

  .btn-cancel, .btn-confirm {
    padding: 10px 24px;
    border-radius: 4px;
    font-family: var(--rdr-font-display);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-cancel {
    background: transparent;
    border: 2px solid var(--rdr-slot-border);
    color: var(--rdr-white);
  }

  .btn-cancel:hover {
    background: rgba(255, 255, 255, 0.05);
  }

  .btn-confirm {
    background: var(--rdr-white);
    color: var(--rdr-black);
    border: 2px solid var(--rdr-white);
  }

  .btn-confirm:hover {
    background: var(--rdr-red);
    color: var(--rdr-white);
    border-color: var(--rdr-red);
  }
</style>
