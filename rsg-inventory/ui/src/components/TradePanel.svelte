<script>
  let { 
    tradePartnerName, 
    myTradeOffers, 
    theirTradeOffers, 
    myTradeAccepted, 
    theirTradeAccepted, 
    t, 
    confirmTrade, 
    cancelTrade, 
    removeItemFromTrade 
  } = $props();
</script>

<div class="trade-container">
  <div class="trade-bg"></div>
  <div class="trade-header">
    <div class="trade-header-title">{t.trade} {tradePartnerName ? 'with ' + tradePartnerName : ''}</div>
  </div>
  <div class="trade-panels">
    <div class="trade-panel my-offer">
      <div class="trade-panel-title">
        {t.your_offer}
        {#if myTradeAccepted}
          <span class="trade-accepted-badge">{t.accepted}</span>
        {/if}
      </div>
      <!-- svelte-ignore a11y_no_static_element_interactions -->
      <div class="trade-items">
        {#each Object.entries(myTradeOffers) as [slot, item] (slot)}
          {#if item}
            <!-- svelte-ignore a11y_click_events_have_key_events -->
            <div class="trade-item-slot" onclick={() => removeItemFromTrade(slot)}>
              <div class="trade-item-img">
                <img src="images/{item.image}" alt="" />
              </div>
              <div class="trade-item-amount">x{item.amount}</div>
              <div class="trade-item-label">{item.label}</div>
            </div>
          {/if}
        {/each}
        {#if Object.keys(myTradeOffers).length === 0}
          <div class="trade-empty">{t.no_items_offered}</div>
        {/if}
      </div>
    </div>
    <div class="trade-panel their-offer">
      <div class="trade-panel-title">
        {t.their_offer}
        {#if theirTradeAccepted}
          <span class="trade-accepted-badge">{t.accepted}</span>
        {/if}
      </div>
      <div class="trade-items">
        {#each Object.entries(theirTradeOffers) as [slot, item] (slot)}
          {#if item}
            <div class="trade-item-slot">
              <div class="trade-item-img">
                <img src="images/{item.image}" alt="" />
              </div>
              <div class="trade-item-amount">x{item.amount}</div>
              <div class="trade-item-label">{item.label}</div>
            </div>
          {/if}
        {/each}
        {#if Object.keys(theirTradeOffers).length === 0}
          <div class="trade-empty">{t.no_items_offered}</div>
        {/if}
      </div>
    </div>
  </div>
  <div class="trade-buttons">
    <button class="trade-confirm-btn" onclick={confirmTrade} disabled={myTradeAccepted}>
      {myTradeAccepted ? t.waiting : t.accept}
    </button>
    <button class="trade-cancel-btn" onclick={cancelTrade}>{t.cancel}</button>
  </div>
</div>
