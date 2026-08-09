# Status Atual do Projeto: FDB-System (RedM)

Este documento resume o que planejamos, o que já foi executado e os problemas recentemente resolvidos na nossa jornada de conversão e estruturação da base **FDB-System** (um framework próprio baseado no RSG Core para RedM).

## 1. O Plano Original
Nosso objetivo principal é criar uma base sólida e independente chamada **FDB-System**, re-estruturando as fundações do RSG Core. O plano envolveu:
- **Renomeação Global (Rebranding):** Substituir todas as referências de `rsg-core`, `rsgcore`, `rsg_locale` e `rsg-` para o novo padrão `fdb-core`, `fdbcore`, `fdb_locale` e `fdb-`.
- **txAdmin Recipe Customizada:** Criar uma receita de instalação automatizada (`txAdminRecipe`) para facilitar o deploy do servidor do zero, puxando diretamente do repositório oficial no GitHub (`Rexshack-RedM/txAdminRecipe` adaptado para o ecossistema FDB).
- **Banco de Dados Unificado:** Consolidar e corrigir as tabelas do banco de dados no arquivo `fdbcore.sql`, garantindo que todas as tabelas e colunas necessárias para os scripts vitais existam e estejam com a nomenclatura correta (ex: uso do prefixo `player_` ou tabelas sem o prefixo antigo).
- **Módulos Essenciais:** Converter, testar e estabilizar módulos cruciais como Inventário (`fdb-inventory`), Criação de Personagens (`fdb-appearance`), Multicharacter (`fdb-multicharacter`), Sistema de Spawn (`fdb-spawn`) e Sistema de Cavalos (`fdb-horses`).

## 2. O Que Já Fizemos (Executado)
- **Estruturação do Repositório GitHub:** O repositório `FDB-System` (branch `fix/companion-inventory-audit`) está ativo e recebendo todos os commits de correções.
- **Conversão de Scripts Base:** A grande maioria dos scripts já foi convertida via script PowerShell para usar as nomenclaturas `fdb`.
- **Deploy via txAdmin:** A receita foi testada. Apesar de alguns percalços com diretórios (`txData` vs `D:\SERVIDOR\server`), o servidor ativo está sendo manipulado na pasta real.
- **Correção da Tabela de Cavalos:** Descobrimos um erro no script `fdb-horses`. Ele procurava pela tabela `fdb_horses`, mas o nome correto no banco de dados era `player_horses`. Corrigimos isso no código fonte em Lua.
- **Correção do Schema SQL:** O loop de metabolismo dos cavalos exigia uma coluna `metadata` que não existia na tabela original do RSG. Nós alteramos o `fdbcore.sql` para adicionar essa coluna automaticamente.
- **Limpeza de Version Checkers:** Removemos arquivos como `versionchecker.lua` dos scripts clonados para evitar mensagens de erro no console.

## 3. Desafios Recentes e Como Foram Resolvidos (O "Incidente dos Arquivos Binários")
Durante a renomeação global (substituindo textos de `rsg` para `fdb` via PowerShell), o script abriu e "re-salvou" arquivos binários como se fossem texto. Isso corrompeu **fontes (.ttf, .otf)** e **imagens (.png, .jpg)** das interfaces gráficas (NUI).

- **O Problema do Multicharacter (Tela de Erro Vermelha):** 
  - O NUI do `fdb-multicharacter` apresentava falhas de carregamento de fonte (`Failed to decode downloaded font`).
  - **Solução:** Baixamos os arquivos `.ttf` e `.otf` originais diretamente do repositório do RSG, comitamos no `FDB-System` e injetamos na pasta do servidor ativo. O erro vermelho sumiu e as fontes de faroeste voltaram a funcionar.
- **O Problema da Tela de Spawn (Tela Preta / Spawn na Sala de Criação):**
  - O script de spawn não abria a interface porque suas imagens (`valentine.jpg`, `saintdenis.jpg`) estavam corrompidas. Ao criar um personagem novo, o jogador ficava preso na sala de criação, e a posição salva no banco de dados tornava o "erro" permanente para aquele personagem específico.
  - **Solução:** Clonamos novamente o `rsg-spawn` original, fizemos a conversão de textos excluindo arquivos binários para protegê-los, e atualizamos o servidor. Ao criar um personagem novo (slot vazio), o spawn voltou a funcionar.
- **O Problema do Background do Multicharacter (NUI sem bg):**
  - O usuário relatou que a interface do `fdb-multicharacter` continuava "sem fundo". Foi descoberto que as texturas de papel, pergaminho e enfeites (`inkroller_1a.png`, `menu_header_1a.png`, etc.) dentro da pasta `html/assets/` também haviam sido corrompidas pelo script de texto agressivo.
  - **Solução:** Baixamos a pasta `assets` intacta do repositório original do `rsg-multicharacter`, enviamos para o GitHub, e injetamos as imagens restauradas diretamente no servidor em tempo real, corrigindo completamente o visual.

## 5. Integração do Ecossistema Customizado e Migração

Nesta nova fase (04/08/2026), iniciamos a integração da base visual e estrutural que vai dar suporte ao sistema médico avançado.

### 5.1 O Que Já Foi Feito (Fases 1, 2A e 2B Concluídas e Validadas)
- ✅ **Infraestrutura Transversal (`fdb-configui`):** Adicionado com sucesso. Motor de KVP genérico que o ecossistema precisa. 
- ✅ **Inventário & Mochilas (`fdb-inventory` / `fdb-backpacks`):** Restaurados pela versão imaculada da source original (`STEEL`). Bug crítico de `GetFDBPlayers` resolvido.
- ✅ **Fundação Visual (`fdb-hudpremium`):** O antigo `fdb-hud` foi deletado do repositório e completamente substituído pelo novo `fdb-hudpremium`. Compilado com sucesso via Vite+Svelte.
- ✅ **Fundações de Consumo (`fdb-consume` & `fdb-canteen`):** A versão provisória foi deletada. Build completa (2.184 linhas) adicionada. **Validação:** Corrigido bug de interrupção de animações (StopInteractiveConsumable) na última mordida/gole e refeito a ponte de sede do `fdb-canteen` para o novo motor.
- ✅ **Sobrevivência (`fdb-survival`):** Migrado e injetado antes do sistema médico. **Validação:** Descoberto e corrigido o "Hash" secreto das fossas para urinar, resolvido erro crítico de parsing (UTF-8 BOM), e chaves de tradução adicionadas em todos os notifies.
- ✅ **Permissões Base (`server.cfg`):** As permissões do Core foram devidamente renomeadas de `rsgcore.*` para `fdbcore.*` no servidor ao vivo.

### 5.2 Próximos Passos (Fase 2C - PAUSADA)
A próxima grande fase seria a integração da joia da coroa: **`fdb-medic` + `fdb-medical-core`**.
⚠️ **Status atual:** Esta fase está **intencionalmente pausada** por decisão do usuário. Não iniciaremos a migração do sistema médico até recebermos autorização expressa.

---
- `fdb-canteen` (Integrado à sede)
- `fdb-appearance` (Refatoração em andamento, transição de UI)

### 5.3 O Nascimento do `fdb-creator` (Centralização de Aparência)
Recentemente, resolvemos um enorme gargalo arquitetural criando o **`fdb-creator`**. 
Antes, módulos como o `fdb-clothing` e o `fdb-barbers` possuíam códigos redundantes para manipulação avançada de memória (`dataview.lua`), cálculos de câmera orbital (`camera.lua`) e aplicação de overlays (maquiagem/sujeira). 
**O que mudou:** Nós **arrancamos** essa lógica desses scripts individuais e as centralizamos no `fdb-creator`. Agora ele age como a verdadeira *Engine Visual* do personagem. O `fdb-clothing` e o `fdb-barbers` foram emagrecidos e agora dependem diretamente das rotinas do `fdb-creator` para funcionar (e futuramente essas bibliotecas bases vão morar no `fdb-libs`).

---
**ATENÇÃO - Nota Importante para o Claude / IAs Auxiliares:**
O repositório `FDB-System` evoluiu massivamente. Não presuma mais que "apenas o fdb-core foi modificado". Neste momento, os seguintes módulos já são builds altamente customizadas, higienizadas e integradas nativamente à arquitetura do FDB-Core:
- `fdb-core` (Fonte de verdade absoluta)
- `fdb-inventory` e `fdb-backpacks`
- `fdb-configui`
- `fdb-hudpremium`
- `fdb-consume` (Totalmente interativo)
- `fdb-survival` (Motor base de atributos vitais)
- `fdb-horses` e `fdb-ammo`
- `fdb-canteen` (Integrado à sede)
- `fdb-creator` (Engine central de customização: Câmeras, DataView e Overlays. Ele absorveu as funções complexas do antigo `fdb-clothing` e `fdb-barbers`!)

### 5.3 Refatoração do `fdb-appearance` e o Dilema da Interface (Atualizado)
Iniciamos a reescrita estrutural do criador de personagens (`fdb-appearance`) para abandonar menus defasados.
- **O Problema:** A interface genérica fornecida pelo `jo_libs` (menus de opções em lista) funciona bem para lojas, mas é demasiadamente rústica ("bruta") para um Character Creator moderno, onde precisamos de sliders visuais finos, paletas de cor intuitivas e um design premium ("delicado"). 
- **O que sugerimos / Próximo Passo Proposto:** Decidimos explorar um pivô arquitetural. Em vez de depender do `jo_libs` para a interface de criação de personagens, a proposta é construir um NUI dedicado em **Svelte + Vite** exclusivamente para o `fdb-appearance`. Isso nos dará controle total do visual (glassmorphism, sliders reais) mantendo intacta toda a poderosa lógica de cache e persistência (Lua) já construída no back-end.

Sempre consulte os manifestos e códigos-fonte desses recursos antes de inferir o comportamento deles. O ecossistema está ganhando vida de forma estruturada.
