<script>
  import { onMount } from 'svelte';
  import { characters, maxCharacters, selectedSlot, selectedCharData, showCreateForm, showDeleteConfirm } from '../stores/multicharacter.js';
  import { fetchNui } from '../utils/nui.js';
  import CharInfo from './CharInfo.svelte';

  let visibleSlots = $derived.by(() => {
    const s = $selectedSlot || 1;
    const max = $maxCharacters || 5;
    if (s === 1) {
      return [1, 2, 3].filter(x => x <= max);
    }
    if (s === max) {
      return [max - 2, max - 1, max].filter(x => x >= 1);
    }
    return [s - 1, s, s + 1];
  });

  function getCharForSlot(slot) {
    return $characters.find(c => c.cid === slot) || null;
  }

  function handleSlotClick(slot) {
    const char = getCharForSlot(slot);
    selectedSlot.set(slot);
    selectedCharData.set(char);
    fetchNui('cDataPed', { cData: char });
  }

  function scrollUp() {
    const s = $selectedSlot || 1;
    if (s > 1) {
      handleSlotClick(s - 1);
    }
  }

  function scrollDown() {
    const s = $selectedSlot || 1;
    const max = $maxCharacters || 5;
    if (s < max) {
      handleSlotClick(s + 1);
    }
  }

  function handlePlay() {
    const char = $selectedCharData;
    if (char) {
      fetchNui('selectCharacter', { cData: char });
    } else {
      showCreateForm.set(true);
    }
  }

  function handleDelete() {
    showDeleteConfirm.set(true);
  }

  function handleDisconnect() {
    fetchNui('closeUI');
    fetchNui('disconnectButton');
  }

  function handleKeyDown(e) {
    if (e.key === 'ArrowUp' || e.key === 'w' || e.key === 'W') {
      scrollUp();
    } else if (e.key === 'ArrowDown' || e.key === 's' || e.key === 'S') {
      scrollDown();
    } else if (e.key === 'Enter') {
      handlePlay();
    }
  }

  onMount(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  });
</script>

<div class="char-select">
  <div class="panel-left">
    <div class="carousel-container">
      <button 
        class="arrow-btn" 
        disabled={$selectedSlot === 1} 
        onclick={scrollUp}
      >
        ▲
      </button>

      <div class="carousel-list">
        {#each visibleSlots as slot}
          {@const char = getCharForSlot(slot)}
          {@const isItemSelect = $selectedSlot === slot}
          <div 
            class="carousel-item" 
            class:selected={isItemSelect}
            onclick={() => handleSlotClick(slot)}
          >
            {#if isItemSelect}
              <span class="selection-arrow">►</span>
            {/if}
            <span class="char-name">
              {#if char}
                {char.charinfo.firstname} {char.charinfo.lastname}
              {:else}
                Slot Vazio
              {/if}
            </span>
          </div>
        {/each}
      </div>

      <button 
        class="arrow-btn" 
        disabled={$selectedSlot === $maxCharacters} 
        onclick={scrollDown}
      >
        ▼
      </button>
    </div>

    <button class="btn-disconnect" onclick={handleDisconnect}>
      Disconnect
    </button>
  </div>

  <div class="panel-right">
    <CharInfo />
    <div class="action-bar-left">
      <button class="btn-play" onclick={handlePlay}>
        {$selectedCharData ? 'Play' : 'Create'}
      </button>
      {#if $selectedCharData}
        <button class="btn-delete" onclick={handleDelete}>
          Delete
        </button>
      {/if}
    </div>
  </div>
</div>

<style>
  .char-select {
    display: flex;
    gap: 40px;
    position: absolute;
    left: 8vw;
    top: 8vh;
    bottom: 8vh;
    width: 680px;
    animation: fadeIn 0.5s ease-out;
  }

  .panel-left {
    width: 320px;
    background: transparent;
    border: none;
    box-shadow: none;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    padding: 10px 0;
  }

  .carousel-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 15px;
    width: 100%;
    margin-top: auto;
    margin-bottom: auto;
  }

  .carousel-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
    align-items: center;
    justify-content: center;
    width: 100%;
  }

  .carousel-item {
    font-family: var(--rdr-font-handwritten);
    font-size: 24px;
    color: #2b2015;
    opacity: 0.55;
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: center;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    white-space: normal;
  }

  .char-name {
    display: inline-block;
    padding: 2px 4px;
  }

  .carousel-item:hover {
    opacity: 0.85;
  }

  .carousel-item.selected {
    font-size: 32px;
    transform: scale(1.08);
    color: #8c0507;
    opacity: 1;
    font-weight: bold;
    text-shadow: 1px 1px 1px rgba(255, 255, 255, 0.4);
  }

  .selection-arrow {
    color: #8c0507;
    margin-right: 6px;
    font-size: 16px;
    animation: pulse 1s infinite;
  }

  .arrow-btn {
    background: transparent;
    border: none;
    color: #2b2015;
    opacity: 0.7;
    font-size: 20px;
    cursor: pointer;
    padding: 5px;
    transition: all 0.2s ease;
  }

  .arrow-btn:hover:not(:disabled) {
    color: #8c0507;
    opacity: 1;
    transform: scale(1.2);
  }

  .arrow-btn:disabled {
    opacity: 0.15;
    cursor: not-allowed;
  }

  .btn-disconnect {
    margin-top: 15px;
    padding: 8px;
    background: transparent;
    border: 2px solid rgba(43, 32, 21, 0.25);
    border-radius: 4px;
    color: #2b2015;
    font-family: var(--rdr-font-display);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.2s ease;
    width: 70%;
  }

  .btn-disconnect:hover {
    border-color: #8c0507;
    color: #8c0507;
  }

  .panel-right {
    width: 320px;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .action-bar-left {
    margin-top: 16px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .btn-play, .btn-delete {
    padding: 12px;
    border-radius: 4px;
    font-family: var(--rdr-font-display);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.2s ease;
    width: 100%;
  }

  .btn-play {
    background: #000000;
    color: #ffffff;
    border: 2px solid #000000;
  }

  .btn-play:hover {
    background: #8c0507;
    color: var(--rdr-white);
    border-color: #8c0507;
  }

  .btn-delete {
    background: transparent;
    color: #000000;
    border: 2px solid rgba(0, 0, 0, 0.4);
  }

  .btn-delete:hover {
    background: #8a0608;
    color: #ffffff;
    border-color: #8a0608;
  }
</style>
