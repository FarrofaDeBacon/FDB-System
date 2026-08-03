<script>
  let progressText = $state('Retrieving player data');
  let dots = $state(0);

  const messages = [
    'Retrieving player data',
    'Validating player data',
    'Retrieving characters',
    'Validating characters'
  ];

  let step = $state(0);

  const interval = setInterval(() => {
    dots = (dots + 1) % 4;
    if (dots === 0) {
      step = Math.min(step + 1, messages.length - 1);
      progressText = messages[step];
    }
  }, 500);
</script>

<div class="loading-overlay">
  <div class="loading-content">
    <div class="spinner-ring">
      <div></div><div></div><div></div><div></div>
    </div>
    <p class="loading-text">{progressText}{'.'.repeat(dots)}</p>
  </div>
</div>

<style>
  .loading-overlay {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    animation: fadeIn 0.5s ease-out;
  }

  .loading-content {
    text-align: center;
  }

  .loading-text {
    font-family: var(--rdr-font-display);
    font-size: 18px;
    color: var(--rdr-white);
    text-shadow: 1px 1px 3px rgba(0,0,0,0.8);
    margin-top: 16px;
    letter-spacing: 0.5px;
  }

  .spinner-ring {
    display: inline-block;
    position: relative;
    width: 80px;
    height: 80px;
  }

  .spinner-ring div {
    box-sizing: border-box;
    display: block;
    position: absolute;
    width: 64px;
    height: 64px;
    margin: 8px;
    border: 6px solid var(--rdr-red);
    border-radius: 50%;
    animation: spin 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
    border-color: var(--rdr-red) transparent transparent transparent;
  }

  .spinner-ring div:nth-child(1) { animation-delay: -0.45s; }
  .spinner-ring div:nth-child(2) { animation-delay: -0.3s; }
  .spinner-ring div:nth-child(3) { animation-delay: -0.15s; }
</style>
