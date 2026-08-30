<script lang="ts">
  import { onMount, onDestroy } from 'svelte';

  export let message: string = '';
  export let seconds: number = 0;
  export let canRespawn: boolean = false;
  export let medicsOnDuty: number = 0;
  export let translations: Record<string, string> = {};

  let timeLeft = seconds;
  let canDisableFocus = false;

  $: {
    timeLeft = seconds;
  }

  $: time = formatTime(timeLeft);

  function formatTime(totalSeconds: number) {
    const minutes = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return {
      minuteFirst: Math.floor(minutes / 10),
      minuteSecond: minutes % 10,
      secondFirst: Math.floor(secs / 10),
      secondSecond: secs % 10
    };
  }

  function handleRightClick(e: MouseEvent) {
    if (e.button === 2 && canDisableFocus) {
      e.preventDefault();
      fetch(`https://${(window as any).GetParentResourceName?.() || 'fdb-medic'}/disable-nui-focus`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      }).catch(() => {});
    }
  }

  let timerInterval: any;
  let focusDelayTimer: any;

  onMount(() => {
    focusDelayTimer = setTimeout(() => {
      canDisableFocus = true;
    }, 1000);

    document.addEventListener('contextmenu', handleRightClick);

    timerInterval = setInterval(() => {
      if (timeLeft > 0) {
        timeLeft -= 1;
        if (timeLeft === 0) {
          fetch(`https://${(window as any).GetParentResourceName?.() || 'fdb-medic'}/death-timer-finished`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
          }).catch(() => {});
        }
      }
    }, 1000);
  });

  onDestroy(() => {
    clearTimeout(focusDelayTimer);
    clearInterval(timerInterval);
    document.removeEventListener('contextmenu', handleRightClick);
  });

  function handleRespawn() {
    fetch(`https://${(window as any).GetParentResourceName?.() || 'fdb-medic'}/death-respawn`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch(() => {});
  }

  function handleCallMedic() {
    fetch(`https://${(window as any).GetParentResourceName?.() || 'fdb-medic'}/death-call-medic`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch(() => {});
  }
</script>

<div id="deathscreen">
  <div id="countdown">
    <!-- Skull Icon -->
    <div style="display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
      <svg xmlns="http://www.w3.org/2000/svg" width="31" height="36" viewBox="0 0 31 36" fill="none" style="opacity: 0.8">
        <path d="M15.529 0C6.04979 0 -1.98684 9.38916 0.436145 18.6019C1.02587 20.8462 1.64746 22.9057 2.37038 24.7478C1.22602 26.0266 1.7205 28.4958 2.80936 29.6878C3.47714 30.4182 4.96917 31.6742 6.22094 32.1854C7.23353 32.0364 10.1957 31.8686 10.0124 35.0197C10.3558 35.1601 10.7153 35.2818 11.0859 35.392V34.146H11.5324V35.5147C12.1325 35.6684 12.7602 35.7876 13.4143 35.8672V34.146H13.8594V35.9111C14.4656 35.9687 15.0872 36 15.7256 36C15.731 36 15.7367 36 15.7421 36V34.1453H16.1879V35.9914C16.8231 35.9777 17.4461 35.9388 18.0455 35.8657V34.1453H18.4923V35.8013C19.115 35.7088 19.7129 35.5824 20.2823 35.419V34.146H20.728V35.2804C20.984 35.1954 21.2333 35.1058 21.4749 35.005C20.9769 31.0673 24.9345 31.7268 25.4967 31.8395C26.791 31.4028 28.4327 30.028 29.1428 29.2518C30.2753 28.0141 30.7701 25.389 29.4417 24.1625C29.397 24.1211 29.3451 24.0923 29.2982 24.052C29.7916 22.6084 30.2273 21.0272 30.6323 19.305C32.8089 10.0303 25.0079 0 15.529 0ZM11.8951 23.6189C10.2663 24.8054 8.49676 27.0918 6.32513 25.7652C4.15279 24.4386 4.10266 19.5696 5.37735 17.6375C6.47194 15.9768 12.7469 16.3786 13.5551 17.7721C14.3635 19.1653 13.5235 22.4323 11.8951 23.6189ZM17.6856 29.4689C17.4858 30.0733 16.2434 29.2781 15.6869 28.885C15.1312 29.2781 13.888 30.0737 13.6879 29.4689C13.4287 28.6859 15.0492 23.8046 15.2444 23.4104C15.3024 23.2931 15.3894 23.1926 15.4821 23.1196C15.5287 23.0425 15.5953 23.0119 15.6726 23.0195C15.678 23.0184 15.6819 23.0202 15.6873 23.0195C15.6923 23.0202 15.6966 23.0184 15.702 23.0195C15.7793 23.0119 15.8459 23.0429 15.8928 23.1199C15.9859 23.1923 16.0726 23.2927 16.1295 23.4104C16.3236 23.8043 17.9452 28.6862 17.6856 29.4689ZM25.4129 25.3768C23.3333 26.8452 21.4162 24.6816 19.7129 23.6081C18.0086 22.5346 16.9552 19.3295 17.6706 17.8848C18.3845 16.4408 24.6194 15.6197 25.8214 17.2026C27.2196 19.0458 27.491 23.9069 25.4129 25.3768Z" fill="#dc3545"/>
      </svg>
    </div>
    
    <!-- Status Text -->
    <div style="margin-bottom: 30px; text-align: center;">
      <h4 style="font-size: 48px; color: #dc3545; text-shadow: none; margin: 0 0 15px 0;">
        {translations?.cl_death_disabled || 'Disabled'}
      </h4>
      <h4 style="color: #52575c; font-size: 16px; margin: 0;">
        {#if medicsOnDuty > 0}
          {translations?.cl_death_wait_medic || "Wait to call medic"}
        {:else}
          {translations?.cl_death_no_medics || "No medics on duty"}
        {/if}
      </h4>
    </div>

    <!-- Timer Numbers -->
    <div style="display: flex; align-items: center; justify-content: center; gap: 15px; margin-bottom: 15px;">
      <div class="countdiv"><h4>{time.minuteFirst}</h4></div>
      <div class="countdiv"><h4>{time.minuteSecond}</h4></div>
      <div class="countdiv" style="background: transparent; width: 5%;"><h4>:</h4></div>
      <div class="countdiv"><h4>{time.secondFirst}</h4></div>
      <div class="countdiv"><h4>{time.secondSecond}</h4></div>
    </div>

    <!-- Action buttons -->
    <div style="display: flex; gap: 15px; align-items: center; justify-content: center; margin-top: 10px;">
      {#if medicsOnDuty > 0 && timeLeft === 0}
        <button on:click={handleCallMedic} class="death-button">
          {translations?.cl_death_call_medic_btn || 'Call Medic'} ({medicsOnDuty} {translations?.cl_death_available || 'Available'})
        </button>
      {/if}

      {#if canRespawn || timeLeft === 0}
        <button on:click={handleRespawn} class="death-button">
          {timeLeft === 0 ? (translations?.cl_death_respawn_btn || 'Respawn') : (translations?.cl_death_giveup_btn || 'Give Up')}
        </button>
      {/if}
    </div>
  </div>
</div>
