<script>
  import { showDeleteConfirm, selectedCharData } from '../stores/multicharacter.js';
  import { fetchNui } from '../utils/nui.js';

  function handleDelete() {
    const char = $selectedCharData;
    if (char?.citizenid) {
      fetchNui('removeCharacter', { citizenid: char.citizenid });
      showDeleteConfirm.set(false);
    }
  }

  function handleCancel() {
    showDeleteConfirm.set(false);
  }
</script>

<div class="modal-overlay" onclick={handleCancel}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <div class="modal-header">
      <h2>Delete Character</h2>
    </div>
    <div class="modal-body">
      <p class="modal-text">
        Are you sure you want to delete your character
        <strong>{$selectedCharData?.charinfo?.firstname} {$selectedCharData?.charinfo?.lastname}</strong>?
      </p>
      <p class="modal-warning">This action cannot be undone.</p>
    </div>
    <div class="modal-footer">
      <button class="btn-cancel" onclick={handleCancel}>Return</button>
      <button class="btn-delete" onclick={handleDelete}>Confirm</button>
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

  .modal-body {
    padding: 24px;
  }

  .modal-text {
    font-family: var(--rdr-font-body);
    font-size: 14px;
    color: var(--rdr-white);
    line-height: 1.6;
  }

  .modal-text strong {
    color: var(--rdr-red);
    font-family: var(--rdr-font-display);
  }

  .modal-warning {
    margin-top: 12px;
    font-family: var(--rdr-font-display);
    font-size: 12px;
    color: #e74c3c;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding: 12px 24px 20px;
  }

  .btn-cancel, .btn-delete {
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

  .btn-delete {
    background: transparent;
    color: var(--rdr-white);
    border: 2px solid var(--rdr-red);
  }

  .btn-delete:hover {
    background: var(--rdr-red);
  }
</style>
