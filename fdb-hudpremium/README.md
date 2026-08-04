# fdb-hudpremium

## Documentação do Contrato Lua -> Svelte (UI)

Este HUD foi construído em Svelte (Vite) e renderiza de forma condicional e autônoma, o que exige que o lado Lua seja explícito em *resetar* estados que não devem mais aparecer na tela.

**REGRA CRÍTICA DE RESET EXPLÍCITO:**
A renderização condicional de *todos* os campos (armadura, cavalo, oxigênio, urina, higiene, temperatura, veneno, doença e embriaguez) depende estritamente do `value` processado pela Store do Svelte. O Svelte *NÃO* esconde esses ícones automaticamente apenas porque o Lua "parou de enviá-los". 

Se o jogador curar um veneno, o lado Lua **DEVE OBRIGATORIAMENTE** enviar um evento com `poison = 0`.
Isso se aplica a tudo:
- `armor = 0` (quando o colete quebrar)
- `horseHealth = 0` (quando o jogador desmontar)
- `oxygen = 100` (quando respirar)
- `poison = 0` (quando tomar antídoto)
- `illness = 0` (quando curar doença)
- `drunkenness = 0` (quando passar o efeito do álcool)
- `coldResistance = 0 / heatResistance = 0` (quando o buff expirar)

Se você não enviar o valor de reset explicitamente, o ícone ficará preso eternamente na tela do jogador com o último valor recebido, gerando um "bug visual silencioso".

---

## Integração Lua NUI Callbacks

O componente `EditorPanel.svelte` (Modo Editor) possui interação bidirecional com o client Lua. Quando o jogador edita o HUD e clica em **Salvar & Fechar**, o Svelte dispara callbacks `fetch` para o client. 
O script Lua deste resource **precisa implementar** os seguintes handlers via `RegisterNUICallback`:

### 1. `saveSettings`
Chamado quando o jogador salva a edição de layout do HUD.
- **Payload (JSON):**
  ```json
  {
      "positions": { "PlayerCores": { "x": 10, "y": 20 }, ... },
      "scales": { "PlayerCores": 1.2, "Voice": 0.8, ... },
      "colors": {}
  }
  ```
- **Responsabilidade do Lua:** Salvar este JSON de forma persistente (ex: usando `SetResourceKvp` no lado client para evitar poluir o DB do servidor). Após salvar, deve enviar `{ status = 'ok' }` de volta na callback.

### 2. `closeEditor`
Chamado quando o painel de edição é fechado pela UI.
- **Payload (JSON):** `{}` (vazio).
- **Responsabilidade do Lua:** Desativar o foco de NUI do mouse (`SetNuiFocus(false, false)`) para devolver o controle do jogo ao jogador.

### Fluxo de Carregamento (Lua -> Svelte)
Ao entrar no servidor, o script Lua deve recuperar o JSON salvo no `GetResourceKvpString` e enviar para a UI via Svelte usando o action `loadSettings`:
```lua
SendNUIMessage({
    action = "loadSettings",
    positions = savedPositions,
    scales = savedScales,
    colors = savedColors
})
```
