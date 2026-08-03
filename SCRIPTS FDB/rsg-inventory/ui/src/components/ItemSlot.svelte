<script>
  let {
    item = null,
    slot,
    inventoryType,
    showSlotKey = false,
    slotKey = null,
    enableDoubleClickUse = false,
    showShopPrice = false,
    errorSlot = null,
    placeholderIcon = '',
    t = {},
    onMouseDown = null,
    onMouseEnter = null,
    onMouseLeave = null,
    onDoubleClick = null,
    onClick = null
  } = $props();
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div 
  id="{inventoryType}-slot-{slot}"
  class="item-slot" 
  data-slot={slot} 
  class:invalid-slot-highlight={errorSlot === slot}
  onclick={(event) => {
    if (onClick) onClick(event);
  }}
  ondblclick={() => {
    if (item && onDoubleClick) {
      onDoubleClick(item);
    }
  }}
  onmousedown={(event) => onMouseDown && onMouseDown(event, slot, inventoryType)}
  onmouseenter={() => item && onMouseEnter && onMouseEnter(item, inventoryType)}
  onmouseleave={onMouseLeave}
  ondragover={(event) => event.preventDefault()}
>
  {#if showSlotKey}
    <div class="item-slot-key">
      <p>{slotKey !== null ? slotKey : slot}</p>
    </div>
  {/if}

  {#if item}
    <div class="item-slot-img">
      <img src="images/{item.image}" alt="" />
    </div>
    
    <!-- Only show amount if amount > 1 or it's not an equipment slot -->
    {#if item.amount !== undefined && (inventoryType !== 'equipment' || item.amount > 1)}
      <div class="item-slot-amount">
        <p>x{item.amount}</p>
      </div>
    {/if}

    {#if showShopPrice && item.price}
      <div class="item-price">
        <p>${Number(item.price).toFixed(2)}</p>
      </div>
    {/if}
    {#if showShopPrice && item.buyPrice}
      <div class="item-sell-price">
        <p>{t.sell || 'Vender'}: ${Number(item.buyPrice).toFixed(2)}</p>
      </div>
    {/if}

    {#if slot !== 'wallet' && item.info && typeof item.info === 'object' && 'quality' in item.info}
      <div class="item-slot-durability">
        <div 
          class="item-slot-durability-fill"
          style="width: {item.info.quality}%"
          class:high={item.info.quality > 75}
          class:medium={item.info.quality <= 75 && item.info.quality > 25}
          class:low={item.info.quality <= 25}
        ></div>
      </div>
    {/if}
  {:else if placeholderIcon}
    <div class="equipment-placeholder">
      <i class="fas {placeholderIcon}"></i>
    </div>
  {/if}
</div>
