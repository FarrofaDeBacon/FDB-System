<script>
  let { slot, char = null, isSelected = false, onclick } = $props();
</script>

<div
  class="char-slot"
  class:selected={isSelected}
  class:occupied={char !== null}
  onclick={onclick}
>
  <div class="slot-number">Slot {slot}</div>
  <div class="slot-content">
    {#if char}
      <span class="slot-name">{char.charinfo.firstname} {char.charinfo.lastname}</span>
      <span class="slot-cid">{char.citizenid}</span>
    {:else}
      <span class="slot-empty">Empty Slot</span>
    {/if}
  </div>
</div>

<style>
  .char-slot {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 16px;
    border-bottom: 1px solid var(--rdr-slot-border);
    cursor: pointer;
    transition: all 0.2s ease;
    border-radius: 4px;
  }

  .char-slot:hover {
    background: var(--rdr-slot-hover);
  }

  .char-slot.selected {
    background: var(--rdr-red);
    border-color: var(--rdr-white);
  }

  .slot-number {
    font-family: var(--rdr-font-mono);
    font-size: 11px;
    color: var(--rdr-red);
    opacity: 0.8;
    min-width: 36px;
  }

  .slot-content {
    flex: 1;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .slot-name {
    font-family: var(--rdr-font-display);
    font-size: 14px;
    color: var(--rdr-white);
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .slot-cid {
    font-family: var(--rdr-font-mono);
    font-size: 10px;
    color: var(--rdr-red);
    opacity: 0.7;
  }

  .slot-empty {
    font-family: var(--rdr-font-display);
    font-size: 13px;
    color: var(--rdr-white);
    opacity: 0.5;
    font-style: italic;
  }
</style>
