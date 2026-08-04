<script>
  import { onMount } from 'svelte';
  import { fetchNui } from './utils/fetchNui';
  import RecursiveConfig from './components/RecursiveConfig.svelte';

  let visible = false;
  let resourceName = "";
  let configData = {};
  let supportedScripts = [];
  let toastMsg = "";
  let toastType = "success";

  onMount(() => {
      window.addEventListener('message', (event) => {
          const item = event.data;
          if (item.action === 'openConfigPanel') {
              resourceName = item.resource || "";
              configData = item.config || {};
              supportedScripts = item.supportedScripts || [];
              visible = true;
          }
      });

      window.addEventListener('keydown', (e) => {
          if (e.key === 'Escape' && visible) {
              closePanel();
          }
      });
  });

  async function selectScript(event) {
      const selected = event.target.value;
      if (!selected) return;
      resourceName = selected;
      const res = await fetchNui('fetchConfig', { resource: selected });
      if (res && res.config) {
          configData = res.config;
      } else {
          showToast(`Erro ao carregar config de ${selected}`, "error");
          resourceName = "";
      }
  }

  async function closePanel() {
      visible = false;
      await fetchNui('closePanel');
  }

  function showToast(msg, type = "success") {
      toastMsg = msg;
      toastType = type;
      setTimeout(() => { toastMsg = ""; }, 3000);
  }

  async function handleUpdate(event) {
      const { path, value } = event.detail;
      console.log(`Atualizando ${path} para`, value);
      
      const success = await fetchNui('saveConfig', {
          resource: resourceName,
          path: path,
          value: value
      });

      if (success) {
          showToast(`Configuração ${path} salva!`, "success");
      } else {
          showToast(`Erro ao salvar ${path}. Verifique o console ou a tipagem.`, "error");
      }
  }

  async function handleReset() {
      if (!confirm("Tem certeza que deseja restaurar as configurações de fábrica deste resource?")) return;
      
      const success = await fetchNui('resetConfig', {
          resource: resourceName
      });

      if (success) {
          showToast("Configurações restauradas com sucesso!", "success");
          closePanel();
      } else {
          showToast("Erro ao restaurar configurações.", "error");
      }
  }
</script>

<style>
  :global(body) {
      margin: 0;
      padding: 0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      overflow: hidden;
      background: transparent;
  }

  .backdrop {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.7);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 1000;
  }

  .panel {
      background: #1a1a1a;
      width: 600px;
      max-height: 80vh;
      border-radius: 8px;
      border: 1px solid #333;
      display: flex;
      flex-direction: column;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
  }

  .header {
      padding: 15px 20px;
      background: #252525;
      border-bottom: 1px solid #333;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-top-left-radius: 8px;
      border-top-right-radius: 8px;
  }

  .header h2 {
      margin: 0;
      color: #fff;
      font-size: 1.2em;
  }

  .header span {
      color: #888;
      font-size: 0.9em;
  }

  .content {
      padding: 20px;
      overflow-y: auto;
      flex: 1;
  }

  .footer {
      padding: 15px 20px;
      background: #252525;
      border-top: 1px solid #333;
      display: flex;
      justify-content: space-between;
      border-bottom-left-radius: 8px;
      border-bottom-right-radius: 8px;
  }

  button {
      background: #333;
      color: white;
      border: 1px solid #555;
      padding: 8px 16px;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.2s;
  }

  button:hover {
      background: #444;
  }

  .btn-primary {
      background: #0066cc;
      border-color: #005bb5;
  }
  .btn-primary:hover {
      background: #0077ee;
  }

  .btn-danger {
      background: #cc0000;
      border-color: #b50000;
  }
  .btn-danger:hover {
      background: #ee0000;
  }

  .toast {
      position: absolute;
      top: 20px;
      right: 20px;
      padding: 10px 20px;
      border-radius: 4px;
      color: white;
      font-weight: 500;
      z-index: 2000;
      animation: slideIn 0.3s ease-out;
  }
  .toast.success { background: #28a745; }
  .toast.error { background: #dc3545; }

  @keyframes slideIn {
      from { transform: translateX(100%); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
  }

  /* Scrollbar estilizda */
  ::-webkit-scrollbar { width: 8px; }
  ::-webkit-scrollbar-track { background: #1a1a1a; }
  ::-webkit-scrollbar-thumb { background: #444; border-radius: 4px; }
  ::-webkit-scrollbar-thumb:hover { background: #555; }

  .script-selector {
      display: flex;
      flex-direction: column;
      gap: 10px;
      padding: 20px;
  }
  .script-selector label {
      color: #ccc;
      font-weight: 500;
  }
  .script-selector select {
      background: #222;
      color: white;
      border: 1px solid #444;
      padding: 10px;
      border-radius: 4px;
      font-size: 16px;
      outline: none;
  }
  .script-selector select:focus {
      border-color: #0066cc;
  }
</style>

{#if visible}
  <div class="backdrop" on:click|self={closePanel}>
      <div class="panel">
          <div class="header">
              <h2>Editor de Configuração</h2>
              <span>{resourceName || "Selecione um script"}</span>
          </div>
          
          <div class="content">
              {#if !resourceName && supportedScripts.length > 0}
                  <div class="script-selector">
                      <label for="script-select">Escolha o script para configurar:</label>
                      <select id="script-select" on:change={selectScript}>
                          <option value="">-- Selecione --</option>
                          {#each supportedScripts as script}
                              <option value={script}>{script}</option>
                          {/each}
                      </select>
                  </div>
              {:else if resourceName && Object.keys(configData).length > 0}
                  <RecursiveConfig config={configData} on:update={handleUpdate} />
              {:else if resourceName}
                  <p style="color: #888; text-align: center;">Nenhuma configuração disponível ou erro ao carregar.</p>
              {/if}
          </div>

          <div class="footer">
              <button class="btn-danger" on:click={handleReset}>Restaurar Padrões</button>
              <button class="btn-primary" on:click={closePanel}>Fechar</button>
          </div>
      </div>
  </div>
{/if}

{#if toastMsg}
  <div class="toast {toastType}">
      {toastMsg}
  </div>
{/if}
