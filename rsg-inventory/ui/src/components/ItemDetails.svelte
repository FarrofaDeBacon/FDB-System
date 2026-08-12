<script>
  let { selectedItem } = $props();
</script>

<div class="desc-divider"></div>
<div class="desc-header">
  <h2 class="desc-title">{selectedItem.label || ''}</h2>
  <p class="desc-subtitle">
    {selectedItem.info && typeof selectedItem.info === 'object' && selectedItem.info.description 
      ? selectedItem.info.description 
      : (selectedItem.description ? selectedItem.description : '')}
  </p>
</div>
<div class="desc-body">
  <div class="desc-row">
    <span class="desc-label">Quantidade</span>
    <span class="desc-dots">................................................................................................................................................</span>
    <span class="desc-value">{selectedItem.amount || 0} unidade(s)</span>
  </div>
  <div class="desc-row">
    <span class="desc-label">Peso Unitário</span>
    <span class="desc-dots">................................................................................................................................................</span>
    <span class="desc-value">{selectedItem.weight != null ? (selectedItem.weight / 1000).toFixed(2) : "0.00"} Kg</span>
  </div>
  <div class="desc-row">
    <span class="desc-label">Peso Total</span>
    <span class="desc-dots">................................................................................................................................................</span>
    <span class="desc-value">{selectedItem.weight != null ? ((selectedItem.weight * (selectedItem.amount || 1)) / 1000).toFixed(2) : "0.00"} Kg</span>
  </div>
  {#if selectedItem.info && typeof selectedItem.info === 'object' && 'quality' in selectedItem.info}
    <div class="desc-row">
      <span class="desc-label">Conservação</span>
      <span class="desc-dots">................................................................................................................................................</span>
      <div class="desc-bar-container">
        <div class="desc-bar-fill" style="width: {selectedItem.info.quality}%"></div>
      </div>
    </div>
  {/if}
</div>
