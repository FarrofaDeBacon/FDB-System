<script>
  import ItemDetails from './ItemDetails.svelte';
  import ItemSlot from './ItemSlot.svelte';

  let {
    inventoryType = 'player',
    inventoryLabel,
    inventoryWeight,
    inventoryMaxWeight,
    inventorySlots,
    isShopInventory = false,
    shouldCenterInventory = false,
    t,
    playerName = '',
    playerId = null,
    playerMoney = 0,
    getItemInSlot,
    useItem,
    handleMouseDown,
    showItemInfo,
    hideItemInfo,
    selectedItem,
    showContextMenu,
    errorSlot,
    backpack = null,
    unequipBackpack = null,
    equipmentSlots = null,
    handleEquipmentClick = null,
    hotbarOffset = null,
    hotbarMaxSlots = null,
    hasOtherInventory = false
  } = $props();

  const equipmentIcons = {
    backpack: 'fa-suitcase',
    satchel: 'fa-shopping-bag',
    wallet: 'fa-wallet',
    holster: 'fa-crosshairs'
  };
</script>

<div 
  class="{inventoryType}-inventory-bg" 
  class:centered-player-inventory-bg={inventoryType === 'player' && shouldCenterInventory}
  style={['satchel', 'backpack', 'wallet', 'holster'].includes(inventoryType) ? `height: calc(10vh + ${Math.ceil(inventorySlots / (['satchel', 'wallet', 'holster'].includes(inventoryType) ? 4 : 5))} * 5.0vw);` : ''}
></div>

<div class="{inventoryType}-inventory-header" class:centered-inventory-header={inventoryType === 'player' && shouldCenterInventory}>
  <div class="header-main-row">
    <div class="inventory-label">
      <p>{inventoryLabel}</p>
    </div>
    <div class="current-weight">
      <img class="weight-icon" src="assets/weight.png" alt={t.weight} />
      <p>{(inventoryWeight / 1000).toFixed(1)} / {(inventoryMaxWeight / 1000).toFixed(1)}</p>
    </div>
  </div>
  {#if inventoryType === 'player'}
    <div class="header-sub-row">
      <div class="current-id">
        <img class="id-icon" src="assets/id.png" alt={t.id} />
        <p>{playerName || playerId || ''}</p>
      </div>
      <div class="current-money">
        <img class="money-icon" src="assets/cash.png" alt={t.cash} />
        <p>${(playerMoney / 100).toFixed(2)}</p>
      </div>
      {#if backpack && backpack.isEquipped && unequipBackpack}
        <div style="display: flex; align-items: center; gap: 8px; margin-left: auto;">
          <div style="display: flex; flex-direction: column; width: 70px;">
            <div style="display: flex; justify-content: space-between; font-size: 9px; color: #ebdcb9; margin-bottom: 2px; font-family: Open Sans, sans-serif; font-weight: bold; text-shadow: 1px 1px 1px black;">
              <span>{backpack.model && backpack.model.includes('satchel') ? 'Bolsa' : 'Mochila'}</span>
              <span>{backpack.durability || 100}%</span>
            </div>
            <div style="width: 100%; height: 5px; background: rgba(0,0,0,0.5); border-radius: 2px; overflow: hidden; border: 1px solid rgba(194,176,128,0.25);">
              <div style="width: {backpack.durability || 100}%; height: 100%; transition: width 0.3s; background: {(backpack.durability || 100) > 50 ? '#55c05a' : ((backpack.durability || 100) > 20 ? '#e08b1a' : '#c93c3c')};"></div>
            </div>
          </div>
          {#if backpack.model && !backpack.model.includes('satchel')}
            <button class="equipped-backpack-header-btn" onclick={unequipBackpack} title="Colocar Mochila no Chão" style="margin-left: 0;">
              <i class="fas fa-suitcase"></i>
            </button>
          {/if}
        </div>
      {/if}
    </div>
  {/if}
</div>

<div 
  class="{inventoryType}-inventory" 
  class:centered-player-inventory={inventoryType === 'player' && shouldCenterInventory}
>
  <div class="divider above-grid"></div>

  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div class="item-grid">
    {#each Array(inventorySlots) as _, idx}
      {@const slot = idx + 1}
      {@const item = getItemInSlot(slot, inventoryType)}
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <ItemSlot
        item={item}
        slot={slot}
        inventoryType={inventoryType}
        showSlotKey={inventoryType === 'player' ? (slot <= 2) : (hotbarOffset !== null && slot <= hotbarMaxSlots)}
        slotKey={inventoryType === 'player' ? slot : (hotbarOffset !== null ? slot + hotbarOffset : null)}
        enableDoubleClickUse={true}
        showShopPrice={isShopInventory}
        errorSlot={errorSlot}
        t={t}
        onMouseDown={handleMouseDown}
        onMouseEnter={showItemInfo}
        onMouseLeave={hideItemInfo}
        onDoubleClick={useItem}
      />
    {/each}
  </div>
  <div class="divider below-grid"></div>

  {#if inventoryType === 'player'}
    <div class="equipment-inventory">
      <div class="item-grid equipment-grid">
        {#each ['backpack', 'satchel', 'wallet', 'holster'] as equipType}
          {@const item = equipmentSlots?.[equipType] || null}
          <ItemSlot
            item={item}
            slot={equipType}
            inventoryType="equipment"
            placeholderIcon={equipmentIcons[equipType]}
            t={t}
            onMouseDown={handleMouseDown}
            onMouseEnter={showItemInfo}
            onMouseLeave={hideItemInfo}
            onClick={() => handleEquipmentClick && handleEquipmentClick(equipType)}
          />
        {/each}
      </div>

    </div>
  {/if}
</div>

<!-- Static Item Details in the empty lower area of the Satchel -->
{#if selectedItem && !showContextMenu}
  {#if inventoryType === 'player' && (selectedItem.inventory === 'player' || selectedItem.inventory === 'satchel' || selectedItem.inventory === 'backpack')}
    <div class="satchel-item-details player-details" class:centered-details={shouldCenterInventory}>
      <ItemDetails {selectedItem} />
    </div>
  {:else if inventoryType === 'other' && selectedItem.inventory === 'other'}
    <div class="satchel-item-details other-details">
      <ItemDetails {selectedItem} />
    </div>
  {/if}
{/if}
