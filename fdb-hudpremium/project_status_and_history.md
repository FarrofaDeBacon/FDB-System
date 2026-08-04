# Especificação Técnica e Planejamento — fdb-hudpremium

Este documento registra o histórico de desenvolvimento do HUD, a especificação técnica dos recursos a serem desenvolvidos e o planejamento de melhorias para a nossa interface do usuário (NUI).

---

## 1. Status Atual do Desenvolvimento (Fase 1 e LUA-1 Concluídas)

### Interface do Usuário (Svelte + Vite)
- **Base Transparente e Otimizada:** Substituição do CSS padrão por uma folha de estilo limpa (`app.css`) focada em HUD (`background: transparent !important` no `#app` e `body`). A tela não bloqueia cliques in-game por padrão (`pointer-events: none`).
- **Resolução de Caminhos:** Configurado o build do Vite com caminhos relativos (`base: './'`) e atualizadas as chamadas dos SVGs em `StatusCores.svelte` para garantir que o Chromium do RedM localize as imagens sob o protocolo `nui://`.
- **Minificação de Vetores (SVGO):** Todos os 18 ícones de status foram minificados em lote usando SVGO, limpando metadados redundantes e reduzindo drasticamente o tamanho final do build.
- **Mecanismo de Ícone (Compatibilidade CEF):** Como o CEF legado do RedM não resolve bem caminhos dentro de propriedades customizadas de CSS (`mask-image`), implementamos uma tag `<img>` nativa com filtros de cores (`filter: brightness(0) invert(1)`) e uma div de mascaramento controlada por altura (`clip-path` dinâmico).

### Backend (Lua Client)
- **fxmanifest.lua:** Configurado o manifesto do zero apontando para a build do Vite (`ui/dist/index.html`), declarando os assets e o script de client.
- **Salvar Configurações (`saveSettings`):** Callback NUI que recebe as posições, escalas e cores customizadas em JSON e as armazena no cliente via `SetResourceKvp("fdb-hudpremium:settings", json.encode(data))`.
- **Fechar Menu (`closeEditor`):** Callback NUI que desativa o foco do mouse e teclado do jogo usando `SetNuiFocus(false, false)`.
- **Carregar Configurações (`loadSettings`):** Executado em `onResourceStart` e no callback `uiReady`, enviando as configurações salvas no KVP de volta para o Svelte via `SendNUIMessage`.
- **Comando `/hud`:** Registrado no Lua client para forçar o foco NUI (`SetNuiFocus(true, true)`) e mandar a action `toggleEditor` (com `value = true`) para abrir o painel de edição visual do HUD.

---

## 2. Especificação da Nova Interface Premium (Melhorias Planejadas)

Abaixo está o mapeamento dos novos recursos que iremos implementar para expandir as capacidades da nossa interface do usuário:

### 2.1. Painel de Customização Avançada (Editor lateral)
Planejamos criar uma interface de controle completa à direita da tela, dividida nas seguintes categorias:
- **Global Settings:**
  - *Grid Size:* Ajuste de grade magnética (snap grid) para alinhamento fino dos núcleos.
  - *Show Dark Background:* Opção para alternar fundo escuro translúcido ou totalmente invisível durante a edição.
  - *Minimap Layouts:* Ajuste de posicionamento rápido para diferentes modos de radar (Off / Regular / Expanded / Compass).
- **Player Cores / Horse Cores / Other Cores:** Ajustes detalhados de cada indicador individualmente.
- **Extras:** Habilitar/desabilitar displays de topo (Logo, Dinheiro, Ouro, Cargo, ID, Hora).

### 2.2. Opções de Customização por Elemento
Cada indicador na tela poderá ser customizado através do painel com os seguintes controles:
- **Visibilidade:** Checkbox para ocultar ou exibir o elemento.
- **Tamanho:** Slider de ajuste em pixels para redimensionar o elemento individualmente.
- **Cores Customizadas (Seletor RGB/Hex):**
  - *Outer Color:* Cor do anel de progresso ativo.
  - *Outer Damage Color:* Cor do anel em situações críticas ou de dano.
  - *Gold Color:* Cor especial para estados bonificados (golden cores).
  - *Max Outer Color:* Cor de fundo da trilha do anel (capacidade máxima).
  - *Inner Color:* Cor padrão de preenchimento do ícone.
- **Anel Segmentado:** Opção para exibir o anel de progresso dividido em blocos individuais (segmentos configuráveis de 1 a 12), assim como no design nativo do RDR2.
- **Rótulos / Badges Individuais:**
  - Exibir valor numérico (porcentagem ou texto) flutuante acima/abaixo do círculo.
  - Ajuste fino da posição vertical e tamanho da fonte do rótulo.

### 2.3. Elementos Adicionais na Tela
- **Logo do Servidor:** Exibição de logo customizado com link direto (URL de imagem), escala e opacidade configuráveis via editor.
- **Contadores de Munição:** Exibição de contagem de balas principal e secundária separadas com cores de texto e ícones independentes.
- **Display de Status (Canto Superior):** Bloco para exibição do Cargo/Job atual, Dinheiro, Ouro e ID do jogador.

---

## 3. Cronograma de Desenvolvimento Proposto

### Fase 1: Lua-2 (Dados em Tempo Real)
- Desativar a exibição dos núcleos nativos do RDR2.
- Desenvolver o loop de ticks que captura Vida, Stamina e os estados do Cavalo, transmitindo em tempo real para a NUI.
- Integrar as lógicas básicas de degradação passiva de fome, sede, e urina.

### Fase 2: Upgrade do Editor (UI Studio)
- Substituir o nosso painel básico pelo menu lateral completo com navegação por categorias.
- Desenvolver os seletores de cores em tempo real (Color Pickers) e sliders de tamanho específicos.
- Criar a mecânica de foco centralizado (Preview ampliado do elemento selecionado).

### Fase 3: Renderização Avançada (Segmentos e Badges)
- Atualizar o componente de anel para suportar renderização em segmentos recortados via SVG.
- Adicionar os rótulos de texto flutuantes posicionáveis para cada núcleo de status.
