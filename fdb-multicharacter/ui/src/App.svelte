<script>
  import { onMount } from 'svelte';
  import { isOpen, isLoading, characters, maxCharacters, selectedSlot, selectedCharData, showCreateForm, showDeleteConfirm, resetAll } from './stores/multicharacter.js';
  import { fetchNui } from './utils/nui.js';
  import LoadingSplash from './components/LoadingSplash.svelte';
  import CharSelect from './components/CharSelect.svelte';
  import CreateChar from './components/CreateChar.svelte';
  import DeleteConfirm from './components/DeleteConfirm.svelte';

  const isNui = typeof window.invokeNative !== 'undefined';

  function handleNuiMessage(event) {
    const data = event.data;
    switch (data.action) {
      case 'ui':
        if (data.toggle) {
          maxCharacters.set(data.nChar || 5);
          isOpen.set(true);
          isLoading.set(true);
          setTimeout(() => {
            fetchNui('setupCharacters');
          }, 100);
          setTimeout(() => {
            isLoading.set(false);
          }, 4000);
        } else {
          resetAll();
        }
        break;
      case 'setupCharacters':
        const chars = data.characters || [];
        characters.set(chars);
        selectedSlot.set(1);
        const initialChar = chars.find(c => c.cid === 1) || null;
        selectedCharData.set(initialChar);
        fetchNui('cDataPed', { cData: initialChar });
        break;
    }
  }

  function injectMockData() {
    maxCharacters.set(5);
    isOpen.set(true);
    isLoading.set(true);
    setTimeout(() => {
      characters.set([
        {
          cid: 1,
          citizenid: 'STEEL12345',
          charinfo: {
            firstname: 'Arthur',
            lastname: 'Morgan',
            birthdate: '1863-06-15',
            gender: 0,
            nationality: 'American'
          },
          job: { label: 'Outlaw' },
          money: { cash: 842 }
        },
        {
          cid: 3,
          citizenid: 'STEEL67890',
          charinfo: {
            firstname: 'Sadie',
            lastname: 'Adler',
            birthdate: '1871-12-05',
            gender: 1,
            nationality: 'American'
          },
          job: { label: 'Bounty Hunter' },
          money: { cash: 1250 }
        }
      ]);
      isLoading.set(false);
    }, 3500);
  }

  function handleKeyDown(e) {
    if (e.key === 'Escape') {
      if (showCreateForm) {
        showCreateForm.set(false);
      } else if (showDeleteConfirm) {
        showDeleteConfirm.set(false);
      }
    }
  }

  function handleContextMenu(e) {
    e.preventDefault();
  }

  onMount(() => {
    window.addEventListener('message', handleNuiMessage);
    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('contextmenu', handleContextMenu);
    if (!isNui) injectMockData();
    return () => {
      window.removeEventListener('message', handleNuiMessage);
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('contextmenu', handleContextMenu);
    };
  });
</script>

<div class="char-screen" class:open={$isOpen}>
  {#if $isOpen}
    {#if $isLoading}
      <LoadingSplash />
    {:else}
      <CharSelect />
    {/if}

    {#if $showCreateForm}
      <CreateChar />
    {/if}

    {#if $showDeleteConfirm}
      <DeleteConfirm />
    {/if}
  {/if}
</div>

<style>
  .char-screen {
    display: none;
    width: 100%;
    height: 100%;
    position: relative;
    background-image: url('../red_overlay.png');
    background-size: 100% 100%;
    background-repeat: no-repeat;
  }

  .char-screen.open {
    display: block;
    animation: fadeIn 0.3s ease-out;
  }
</style>
