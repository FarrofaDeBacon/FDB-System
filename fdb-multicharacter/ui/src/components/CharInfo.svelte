<script>
  import { selectedCharData } from '../stores/multicharacter.js';
</script>

{#if $selectedCharData}
  <div class="char-info">
    <div class="stamp-seal">APPROVED</div>
    <div class="info-title">Registro de Cidadão</div>
    <div class="info-body">
      <div class="info-row">
        <span class="info-label">Nome Completo:</span>
        <span class="info-value">{$selectedCharData.charinfo.firstname} {$selectedCharData.charinfo.lastname}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Nascimento:</span>
        <span class="info-value">{$selectedCharData.charinfo.birthdate}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Nacionalidade:</span>
        <span class="info-value">{$selectedCharData.charinfo.nationality}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Gênero:</span>
        <span class="info-value">{$selectedCharData.charinfo.gender === 0 ? 'Masculino' : 'Feminino'}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Conta Bancária:</span>
        <span class="info-value-cash">${$selectedCharData.bank}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Dinheiro em Mão:</span>
        <span class="info-value-cash">${$selectedCharData.cash}</span>
      </div>
    </div>
  </div>
{:else}
  <div class="char-info empty-doc">
    <div class="info-empty">
      Selecione um cidadão da lista para ver o registro oficial de identidade.
    </div>
  </div>
{/if}

<style>
  .char-info {
    background: #eedcb3; /* Aged cream paper */
    background-image: 
      radial-gradient(circle at 70% 30%, rgba(255, 255, 255, 0.2) 0%, transparent 60%),
      linear-gradient(135deg, rgba(0, 0, 0, 0.03) 0%, rgba(0, 0, 0, 0.08) 100%);
    border: 1px solid #bba573;
    border-radius: 1px;
    padding: 30px 24px;
    box-shadow: 6px 8px 24px rgba(0, 0, 0, 0.45);
    position: relative;
    font-family: 'Playfair Display', serif;
    color: #2e2316;
    transform: rotate(-1.5deg); /* Vintage tilted paper effect */
    animation: paperFade 0.5s ease-out;
  }

  .char-info::after {
    content: '';
    position: absolute;
    inset: 0;
    border: 1px dashed rgba(43, 32, 21, 0.15);
    margin: 4px;
    pointer-events: none;
  }

  @keyframes paperFade {
    from {
      opacity: 0;
      transform: translateY(10px) rotate(0deg);
    }
    to {
      opacity: 1;
      transform: translateY(0) rotate(-1.5deg);
    }
  }

  .stamp-seal {
    position: absolute;
    top: 20px;
    right: 20px;
    border: 3px double rgba(140, 5, 7, 0.35);
    color: rgba(140, 5, 7, 0.35);
    font-size: 11px;
    font-weight: 900;
    padding: 4px 8px;
    text-transform: uppercase;
    transform: rotate(15deg);
    font-family: 'Playfair Display', serif;
    letter-spacing: 1px;
    border-radius: 3px;
    pointer-events: none;
  }

  .info-title {
    font-family: 'Playfair Display', serif;
    font-size: 20px;
    font-weight: bold;
    color: #2b2015;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-align: center;
    padding-bottom: 12px;
    border-bottom: 2px solid #bba573;
    margin-bottom: 20px;
    font-style: italic;
  }

  .info-body {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .info-row {
    display: flex;
    flex-direction: column;
    gap: 2px;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(43, 32, 21, 0.08);
  }

  .info-label {
    font-size: 11px;
    color: #5a4b3c;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: bold;
    opacity: 0.85;
  }

  .info-value {
    font-family: var(--rdr-font-handwritten);
    font-size: 20px;
    color: #1a0f05;
    padding-left: 5px;
    line-height: 1.2;
  }

  .info-value-cash {
    font-family: var(--rdr-font-handwritten);
    font-size: 22px;
    color: #1a5c1a; /* Dark ink green for cash */
    padding-left: 5px;
    line-height: 1.2;
  }

  .empty-doc {
    background: rgba(0, 0, 0, 0.25);
    border: 1px dashed rgba(255, 255, 255, 0.15);
    color: #ffffff;
    box-shadow: none;
    transform: none;
  }

  .info-empty {
    font-family: 'Playfair Display', serif;
    font-size: 14px;
    color: #cccccc;
    text-align: center;
    padding: 60px 20px;
    font-style: italic;
    line-height: 1.6;
  }
</style>
