<script>
  import { slide } from 'svelte/transition';
  import ItemSlot from './ItemSlot.svelte';

  let {
    backpack,
    isOpen,
    toggleDrawer,
    getItemInSlot,
    handleMouseDown,
    showItemInfo,
    hideItemInfo,
    unequipBackpack,
    t = {}
  } = $props();

  const isSatchel = $derived(
    backpack && backpack.model && (
      backpack.model.includes('satchel') || 
      backpack.model.startsWith('satchel_')
    )
  );

  function handleSlotMouseDown(event, slot) {
    handleMouseDown(event, slot, 'backpack');
  }

  function handleSlotMouseEnter(item) {
    if (item) {
      showItemInfo(item, 'backpack');
    }
  }
</script>

<div class="backpack-drawer-container" class:drawer-open={isOpen}>
  <!-- Clickable leather strap handle -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div class="backpack-strap-handle" onclick={toggleDrawer} class:active={isOpen}>
    <div class="strap-buckle"></div>
    <div class="strap-text">{isSatchel ? (t.satchel || 'BOLSA') : 'MOCHILA'}</div>
  </div>

  {#if isOpen}
    <div class="backpack-drawer-content" transition:slide={{ axis: 'x', duration: 300 }}>
      <div class="backpack-drawer-inner-border">
        <div class="backpack-header">
          <h3>{isSatchel ? (t.satchel || 'BOLSA') : 'MOCHILA'}</h3>
          <p class="backpack-weight">
            {((backpack.items ? Object.values(backpack.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0) : 0) / 1000).toFixed(1)} / {(backpack.maxweight / 1000).toFixed(1)} Kg
          </p>
        </div>
        
        <div class="item-grid backpack-grid">
          {#each Array(backpack.slots) as _, idx}
            {@const slot = idx + 1}
            {@const item = backpack.items[slot] || null}
            <ItemSlot
              item={item}
              slot={slot}
              inventoryType="backpack"
              t={t}
              onMouseDown={handleSlotMouseDown}
              onMouseEnter={handleSlotMouseEnter}
              onMouseLeave={hideItemInfo}
            />
          {/each}
        </div>
        {#if backpack.durability !== undefined}
          <div class="backpack-durability-container" style="margin: 10px 15px; text-align: left;">
            <div style="display: flex; justify-content: space-between; font-size: 11px; color: #ccc; margin-bottom: 4px;">
              <span>Integridade</span>
              <span>{backpack.durability}%</span>
            </div>
            <div style="width: 100%; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; border: 1px solid rgba(0,0,0,0.5);">
              <div style="width: {backpack.durability}%; height: 100%; transition: width 0.3s; background: {backpack.durability > 50 ? '#55c05a' : (backpack.durability > 20 ? '#e08b1a' : '#c93c3c')};"></div>
            </div>
          </div>
        {/if}
        <button class="unequip-btn" onclick={unequipBackpack}>DESEQUIPAR</button>
      </div>
    </div>
  {/if}
</div>
