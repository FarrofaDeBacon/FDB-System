# Documentação Geral e Auditoria — fdb-hudpremium

Este documento descreve detalhadamente a estrutura de arquivos do script, o funcionamento interno de cada componente, a auditoria de tudo que foi realizado e o planejamento das próximas etapas.

---

## 1. Estrutura de Arquivos e Explicação de Código

### 📁 Pasta Raiz (`/`)

#### 📄 [fxmanifest.lua](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/fxmanifest.lua)
Manifesto do recurso RedM.
- **Função:** Declara a compatibilidade com a build `adamant` do RDR3, ativa o interpretador `lua54`, registra o script de cliente (`client/main.lua`), define a página principal da interface (`ui/dist/index.html`) e exporta todos os arquivos do build do Vite (`ui/dist/assets/*.*`) para que sejam acessíveis pelo cliente do jogo via protocolo `nui://`.

#### 📄 [project_status_and_history.md](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/project_status_and_history.md)
Documento de log técnico e histórico de decisões tomadas durante as sessões de desenvolvimento.

---

### 📁 Pasta `/client`

#### 📄 [client/main.lua](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/client/main.lua)
Controlador principal em Lua.
- **Ocultação de HUD Nativo:** Loop dedicado de 1000ms que chama a native `_UITUTORIAL_SET_RPG_ICON_VISIBILITY` (`0xC116E6DF68DCE667`) para esconder permanentemente os núcleos originais do jogador e do cavalo.
- **Sincronização de Status (Lua-2):** Coleta a saúde e fôlego reais do ped do jogador, além da fome, sede, estresse, bexiga (urine) e álcool vindos dos metadados do **RSGCore**.
- **Mount Tracker:** Monitora se o jogador montou em um cavalo e envia os status do animal à UI. Limpa os valores ao desmontar.
- **NUI Callbacks:**
  - `uiReady`: Dispara o carregamento do layout quando a tela do jogo termina de montar o DOM.
  - `saveSettings`: Grava as customizações no cliente usando `SetResourceKvp` em formato JSON.
  - `closeEditor`: Desativa o foco do cursor (`SetNuiFocus`).
- **Comando `/hud`:** Abre o estúdio de edição.

---

### 📁 Pasta `/ui/src` (Código-Fonte da Interface)

#### 📄 [ui/src/main.js](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/main.js)
Ponto de entrada do Svelte que monta o componente `<App />` no elemento principal `#app` do HTML.

#### 📄 [ui/src/app.css](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/app.css)
Folha de estilo global da interface.
- **Função:** Limpa todas as margens do template, define o fundo como totalmente invisível e remove interações de ponteiro padrão (`pointer-events: none`) para que a interface não bloqueie as teclas e cliques no jogo.

#### 📄 [ui/src/App.svelte](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/App.svelte)
Componente raiz que decide quando exibir o painel de edição (`EditorPanel.svelte`) e gerencia a árvore do HUD principal.

---

### 📁 Pasta `/ui/src/store`

#### 📄 [ui/src/store/hudStore.js](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/store/hudStore.js)
Gerenciador de estado global baseado em Svelte Stores.
- **Diferencial Técnico (Batching via RAF):** Para evitar que ticks de alta frequência do RedM sobrecarreguem a renderização da tela, os valores são acumulados e aplicados no DOM de uma só vez no próximo frame de renderização usando `requestAnimationFrame`.
- **Stores Declaradas:**
  - `coreStatus`: Saúde, stamina, comida, água, estresse, armadura, oxigênio.
  - `horseStatus`: Vida e fôlego do cavalo.
  - `survivalEngines`: Bexiga, temperatura, veneno, doença, álcool, higiene.
  - `editorState`: posições arrastadas, cores customizadas e escalas salvas.

---

### 📁 Pasta `/ui/src/components`

#### 📄 [ui/src/components/HUDItem.svelte](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/components/HUDItem.svelte)
Renderizador individual de cada círculo de status.
- **Vite Raw Imports:** Importa o conteúdo XML de todos os SVGs como strings puras na build (`?raw`).
- **Resolução Basename:** Extrai o final do caminho do ícone para bater com o mapa local de ícones (`health.svg`), garantindo robustez de caminhos relativos ou absolutos do CEF.
- **Injeção de SVG Dinâmico:** Renderiza o SVG diretamente no DOM usando `{@html svgMarkup}` com um wrapper de corte (`clip-path`) para preenchimento.
- **Controle de Cores:** Graças ao SVG inline, as folhas de estilo aplicam `fill: currentColor !important`, herdando a cor do wrapper definida pela prop `innerColor`.

#### 📄 [ui/src/components/StatusCores.svelte](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/components/StatusCores.svelte)
Organizador estrutural do HUD. Declara a fileira de núcleos e injeta os valores recebidos dos loops do client Lua.

#### 📄 [ui/src/components/DraggableModule.svelte](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/components/DraggableModule.svelte)
Wrapper de arrasto que adiciona eventos de mouse para mover os grupos de núcleos e atualiza o estado de posição global.

#### 📄 [ui/src/components/EditorPanel.svelte](file:///D:/STEEL/Server/resources/%5Bframework%5D/fdb-hudpremium/ui/src/components/EditorPanel.svelte)
Painel básico que exibe sliders de escala e botões para Salvar e Resetar o HUD.

---

## 2. Auditoria de Progresso (O que foi feito)

| Recurso | Status | Notas |
|---|---|---|
| **SVGs Minificados** | ✅ Concluído | Todos os 18 ícones otimizados via SVGO. Reduzimos **47.174 linhas** de lixo de Illustrator. |
| **Correção de Cores (`innerColor`)** | ✅ Concluído | Substituição de `<img>` por SVGs Inline (`{@html}`) com controle de cores `fill: currentColor`. |
| **Resolução de Caminhos NUI** | ✅ Concluído | Build configurada para caminhos relativos (`./assets`) e mapeamento por *basename*. |
| **Hiding de Cores Nativos** | ✅ Concluído | Loop Lua rodando `_UITUTORIAL_SET_RPG_ICON_VISIBILITY` no cliente. |
| **Loop de Atualização (Lua-2)** | ✅ Concluído | Coleta periódica de dados nativos do Ped e metadados do RSGCore. |
| **Persistência KVP** | ✅ Concluído | Salvamento e re-injeção do JSON de layout entre relogs. |

---

## 3. Próximos Passos (O que falta fazer)

### Fase 2: Upgrade do Editor (UI Studio) — **Próxima Etapa**
- Reestruturar o `EditorPanel.svelte` para a lateral esquerda contendo o menu em abas.
- Desenvolver os Color Pickers em tempo real para as cores individuais (`outerColor`, `innerColor`, etc.).
- Desenvolver o sistema de **Preview Centralizado** (elemento selecionado clona para o meio da tela em tamanho grande (100px) com borda pontilhada).

### Fase 3: Renderização Avançada (Segmentos e Badges)
- Fatiar dinamicamente os anéis de progresso via SVG (`stroke-dasharray` e `stroke-dashoffset` recortados).
- Adicionar os textos e badges flutuantes acima ou abaixo de cada núcleo de status (tamanho da fonte e deslocamento vertical editáveis).

### Fase 4: Indicadores Extras
- Contador de munição flutuante independente.
- Indicador de PVP, Job/Cargo atual, Dinheiro, Ouro e ID no canto superior esquerdo.
