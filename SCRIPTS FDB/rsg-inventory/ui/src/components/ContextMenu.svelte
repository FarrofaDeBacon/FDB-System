<script>
  let { 
    contextMenuItem, 
    contextMenuPosition, 
    isTradeActive, 
    t, 
    useItem, 
    addItemToTrade, 
    addItemToTradeWithPrompt, 
    giveItem, 
    dropItem, 
    splitAndPlaceItem, 
    copySerial,
    searchBackpack,
    unequipItem,
    dropEquipmentItem
  } = $props();

  let showSubmenu = $state(null); // 'trade' | 'give' | 'drop' | 'split' | null
  const itemName = $derived(contextMenuItem ? (contextMenuItem.name || contextMenuItem.itemName || '') : '');
</script>

<ul class="context-menu" style="top: {contextMenuPosition.top}; left: {contextMenuPosition.left}">
  {#if (itemName.startsWith("satchel_") || itemName.startsWith("wallet_") || itemName.startsWith("holster_")) && contextMenuItem.inventory === 'equipment' && contextMenuItem.info && (contextMenuItem.info.uid || contextMenuItem.info.stashId)}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li onclick={() => searchBackpack(contextMenuItem)}>{t.search_backpack || 'Vasculhar'}</li>
  {/if}

  {#if contextMenuItem.inventory === 'equipment'}
    {#if itemName.startsWith("backpack_") || itemName.startsWith("satchel_")}
      <!-- svelte-ignore a11y_click_events_have_key_events -->
      <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
      <li onclick={() => dropEquipmentItem(contextMenuItem)}>{t.drop_to_ground || 'Colocar no Chão'}</li>
    {/if}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li onclick={() => unequipItem(contextMenuItem)}>{t.unequip || 'Desequipar'}</li>
  {/if}

  {#if contextMenuItem.useable}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li onclick={() => useItem(contextMenuItem)}>{t.use}</li>
  {/if}

  {#if isTradeActive}
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li 
      onmouseenter={() => showSubmenu = 'trade'} 
      onmouseleave={() => showSubmenu = null}
    >
      {t.trade}
      {#if showSubmenu === 'trade'}
        <ul class="submenu">
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => addItemToTrade(contextMenuItem, 1)}>{t.single}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => addItemToTrade(contextMenuItem, Math.ceil(contextMenuItem.amount / 2))}>{t.half}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => addItemToTrade(contextMenuItem, contextMenuItem.amount)}>{t.all}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => addItemToTradeWithPrompt(contextMenuItem)}>{t.amount}</li>
        </ul>
      {/if}
    </li>
  {/if}

  {#if contextMenuItem.inventory !== 'equipment'}
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li 
      onmouseenter={() => showSubmenu = 'give'} 
      onmouseleave={() => showSubmenu = null}
    >
      {t.give}
      {#if showSubmenu === 'give'}
        <ul class="submenu">
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => giveItem(contextMenuItem, 1)}>{t.single}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => giveItem(contextMenuItem, 'half')}>{t.half}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => giveItem(contextMenuItem, 'all')}>{t.all}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => giveItem(contextMenuItem, 'enteramount')}>{t.amount}</li>
        </ul>
      {/if}
    </li>

    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li 
      onmouseenter={() => showSubmenu = 'drop'} 
      onmouseleave={() => showSubmenu = null}
    >
      {t.drop}
      {#if showSubmenu === 'drop'}
        <ul class="submenu">
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => dropItem(contextMenuItem, 1)}>{t.single}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => dropItem(contextMenuItem, 'half')}>{t.half}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => dropItem(contextMenuItem, 'all')}>{t.all}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => dropItem(contextMenuItem, 'enteramount')}>{t.amount}</li>
        </ul>
      {/if}
    </li>

    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li 
      onmouseenter={() => showSubmenu = 'split'} 
      onmouseleave={() => showSubmenu = null}
    >
      {t.split || 'Split'}
      {#if showSubmenu === 'split'}
        <ul class="submenu">
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => splitAndPlaceItem(contextMenuItem, 'player', 1)}>{t.single}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => splitAndPlaceItem(contextMenuItem, 'player', 'half')}>{t.half}</li>
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <li onclick={() => splitAndPlaceItem(contextMenuItem, 'player', 'enteramount')}>{t.amount}</li>
        </ul>
      {/if}
    </li>
  {:else}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li onclick={() => giveItem(contextMenuItem, 1)}>{t.give}</li>
  {/if}

  {#if contextMenuItem.name && contextMenuItem.name.includes('weapon_')}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <li onclick={() => copySerial(contextMenuItem)}>{t.copy_serial}</li>
  {/if}
</ul>
