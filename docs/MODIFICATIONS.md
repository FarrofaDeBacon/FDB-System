# MODIFICATIONS.md — Diferenças do FDB-Core em relação ao fdb-core original

Este documento registra todas as alterações estruturais, correções de segurança, otimizações de banco de dados e decisões de arquitetura aplicadas ao **FDB-Core** (fork do fdb-core). Serve como registro histórico e fonte de verdade para a equipe e assistentes de IA.

---

## 📊 Status Geral de Execução

| Fase | Descrição | Status | Detalhes / PR |
| :--- | :--- | :--- | :--- |
| **Fase 1** | Segurança & Auditoria Base | ✅ APROVADA | Remediação de privilégios em `SetMetaData` e `DebugSomething`. Matriz em `AUDIT.md`. |
| **Fase 1.5** | Auditoria de Recursos Companheiros (`fdb-inventory`) | 🔄 EM EXECUÇÃO | Checklist formal aberto. Nenhuma alteração aprovada sem evidência de código real. (Commit: `0acfb5fc4edd832c49ca438d1df73d7870a63b0e`) |
| **Fase 2** | Camada de Banco de Dados (`oxmysql`) | ✅ APROVADA | Runner de migração com `pcall`, DDL idempotente, índices em `players`. |
| **Fase 3** | Eventos, Exports & Rebrand | ✅ APROVADA | Rebrand literal RSG→FDB em todo o repo. Exports nativos preservados. |
| **Fase 4** | Inventário & Concorrência | ✅ APROVADA | Prevenção de duplicação/perda de estado, travas anti-NaN/infinito e lock coalescente de I/O em `Player.Save`. |
| **Fase 5** | Jobs, Gangs & Permissões | ✅ APROVADA | Validação de target online, auditoria via `fdb-log`, permissão `'god'` para `addpermission`/`removepermission` e `'admin'` para `/setjob`/`/setgang`. (Commit: `30a6cb92d16d4eb381edbc652da4b10ef2936bfd`) |
| **Fase 6** | Performance & StateBags | ✅ APROVADA | Eliminação de polling inativo no PVP, cache de handle em `ShowMe3D`, zero queries MySQL em tick e direcionamento estrito de broadcast. (Commit: `baf45263fbdbd69471a57587970585e4fa036a06`) |
| **Fase 7** | Documentação Final & Wiki | ✅ APROVADA | Criação de `WIKI.md`, READMEs em `server/` e `client/` e consolidação final do estado do fork. |
| **Fase 8** | Biblioteca Central de UI (`fdb-libs`) | 🔄 EM EXECUÇÃO | Desenvolvimento da UI rústica compilada em Svelte+Vite, integração de texturas RDR2 e quebra de cache CEF. |

---

## 🛠️ Mudanças por Módulo

### 1. Módulo de Segurança (`FDB-Core/server/`)
- **`server/events.lua:162` (`SetMetaData`)**:
  - Implementada a whitelist `AllowedClientMetaData` (`hunger`, `thirst`).
  - Adicionada validação estrita de tipo (`type(data) == 'number'`) e limite numérico (`0` a `100`). Tentativas de alteração de metadados protegidos (`isdead`, `job`, `money`) via client são descartadas no servidor.
- **`server/debug.lua:28` (`DebugSomething`)**:
  - Adicionada restrição `FDBCore.Functions.HasPermission(src, 'admin')` para invocações de rede por clientes sem nível admin.

### 1.5 Módulo Companheiro de Inventário & Recursos Base (`fdb-inventory`, `fdb-multicharacter`, `fdb-spawn`, `fdb-horses`)
- **Status**: 🔄 **EM EXECUÇÃO** (Abertura: `0acfb5fc4edd832c49ca438d1df73d7870a63b0e`) — Checklist formal expandido:
  - [x] **Rebrand Literal de Recursos e Exports**: Renomeação da pasta `fdb-inventory` ➔ `fdb-inventory`, manifest (`description 'fdb-inventory'`) e substituição de `exports['fdb-core']` por `exports['fdb-core']`. (Commit: `30e71edd18873d25a02641417e6b03bf694e874b`).
  - [x] **Padronização de Eventos de Rede (`fdb-inventory`)**: Renomeados todos os net events server/client de `fdb-inventory:...` ➔ `fdb-inventory:...` em 27 arquivos Lua e chamadas NUI/JS (`https://fdb-core/validateCSRF`). (Commit: `925d82c72c418e5b4a2754f9da419d69abc37263`).
  - [x] **Adaptação e Versionamento dos Recursos Base**: Recursos `fdb-multicharacter`, `fdb-spawn` e `fdb-horses` adaptados com rebrand completo de `exports['fdb-core']`, eventos de rede e integrados diretamente ao repositório. (Commit: `fe1167533e96f831121c9f5c410ef58612d35dee`).
  - [ ] **Lock de Concorrência e Antidupe Unificado (Bloqueante)**: Substituição do rate-limit simples por temporizador em `SetInventoryData`, `giveItem`, `createDrop` e `addTradeItem` por trava autoritativa estrita `inv_busy`, impedindo corridas de mutação de estado.
  - [ ] **Validação de Distância Server-Side (Bloqueante)**: Garantir validação server-side de coordenadas em trocas, drops, vasculhamento de players e abertura de baús (`openStash` / `SetInventoryData`).
  - [ ] **StateBags Compartilhados**: Sincronização e unicidade da flag `Player(src).state.inv_busy` entre `fdb-inventory` e `fdb-core/server/moneyitems.lua`.
  - [ ] **Banco de Dados & Índices**: Criação de índice na coluna `identifier` da tabela `inventories` e validação da chave `citizenid` na tabela `player_weapons`.

### 1.6 Integração do Ecossistema Customizado FDB (Fases 1, 2A e 2B)
- **Status**: ✅ **APROVADA E CONCLUÍDA**
- **Arquitetura Base**: Todo o ecossistema customizado migrado nestas fases foi unificado sob a arquitetura do `fdb-core` (Fonte Única de Verdade), eliminando a dependência do `rsg-core`. As permissões no `server.cfg` também refletem o novo prefixo `fdbcore.*`.
- **fdb-configui (Infraestrutura Transversal)**:
  - Adicionado para servir como motor de KVP Genérico para todo o ecossistema FDB.
  - O Core foi ajustado para permitir a sincronização das configurações de UI entre clientes.
- **fdb-inventory & fdb-backpacks**:
  - Inventário corrompido por scripts de *text-replacement* no passado foi substituído pela versão intacta originária da base de desenvolvimento (`STEEL`).
  - Imagens UI blindadas e o bug da chamada inválida de `GetRSGPlayers()` resolvido cirurgicamente para `GetFDBPlayers()`.
  - Inclusão formal de `fdb-backpacks` para impedir congelamento de tela no inventário devido a recursos faltantes.
- **fdb-hudpremium**:
  - O antigo recurso `fdb-hud` foi permanentemente **deletado**.
  - O `fdb-hudpremium` foi implementado em seu lugar (UI robusta compilada em Vite+Svelte).
  - O hud opera inteiramente passivo, varrendo estados unificados (metadados como `thirst`, `hunger`) do `fdb-core`, sem necessidade de disparar *triggers* pesados via rede, otimizando performance.
- **fdb-consume**:
  - A versão "stock" de 7 arquivos (490 linhas) foi **deletada**.
  - O ecossistema agora roda sobre a versão integral de `fdb-consume` (20 arquivos, 2.184 linhas), que suporta as lógicas avançadas que o sistema médico exigirá (ataduras e tônicos).
  - Removidos e higienizados todos os antigos exports `rsg` remanescentes, trocando `RSGCore` por `FDBCore`.
- **fdb-survival**:
  - Adicionado e inserido estrategicamente *antes* do sistema médico (antiga Fase 3, puxado para Fase 2B) por decisão arquitetural do projeto: o Maestro de sobrevivência alimenta a Engine e o HUD, por isso devia ser estabelecido primeiro.
  - Higienização de `rsg` executada rigorosamente.
  - Dependência declarada (`dependencies { 'fdb-core' }`) fixada no `fxmanifest.lua`.
- **Fase 2C (Sistema Médico - `fdb-medic` / `fdb-medical-core`)**: Intencionalmente pausada aguardando avaliação e testes in-game.

### 2. Camada de Banco de Dados (`FDB-Core/database/` & `FDB-Core/server/`)
- **Automatic Migration Runner (`FDB-Core/server/migrations.lua`)**:
  - Criado runner automático que executa no `MySQL.ready`, cria/verifica a tabela `schema_migrations` e aplica sequencialmente arquivos em `database/migrations/`.
  - Implementado tratamento de erro via `pcall` em cada etapa com parada imediata em falhas.
  - Adicionado log explícito para arquivos de migração ausentes ou vazios.
  - Implementado parser de arquivos multi-statement (divisão por `;`).
  - Adicionada tolerância a erros `1061 / ER_DUP_KEYNAME` do MySQL para suporte à idempotência em DDL de índices.
- **Migrações e Índices**:
  - `001_create_migrations_table_and_core_indexes.sql`: Tabela `schema_migrations` + índice `idx_players_license` (`license`).
  - `002_add_player_indices.sql`: Índice composto `idx_players_citizenid_cid` (`citizenid`, `cid`) para otimização de consultas por slot de personagem.
- **Correção em `server/events.lua:44`**:
  - Convertidas queries DDL `ALTER TABLE` de interpolação de string vulnerável para formatação estritamente sanitizada (`tonumber()`).

### 3. Core & Convenções de Rebrand (`FDB-Core/`)
- **Rebrand Literal RSG → FDB**:
  - Renomeados todos os identificadores globais: `FDBCore` ➔ `FDBCore`, `RSGShared` ➔ `FDBShared`, `RSGConfig` ➔ `FDBConfig`.
  - Atualizado o prefixo de eventos: `RSG:` / `FDBCore:` ➔ `FDB:` / `FDBCore:`.
  - Atualizado o nome do recurso base: `fdb-core` ➔ `fdb-core`.
  - **Preservação de Exports Nativos**: Todos os exports públicos que não continham `RSG` no nome original (`AddJob`, `AddItem`, `RemoveJob`, `SetMethod`, `SetField`, `ExploitBan`, `GetCoreObject`, `DrawText`, `createPrompt`, etc.) foram mantidos idênticos sem alteração ou criação de namespace hierárquico.

### 4. Estado do Player, Dinheiro & Concorrência de I/O (`FDB-Core/server/player.lua`)
- **Lock Coalescente em `FDBCore.Player.Save`**:
  - As flags `saveInProgress` e `savePending` são inicializadas como `false` em `CreatePlayer`.
  - Se um novo pedido de save ocorrer enquanto uma query de I/O já estiver em andamento, o estado marca `savePending = true` e evita queries simultâneas no pool `oxmysql`.
  - No término do callback, o runner verifica se o player ainda existe em memória e, se `savePending` for verdadeiro, auto-dispara a nova gravação com o snapshot mais recente.
  - O fluxo no `playerDropped` (disconnect) passa exatamente pelo mesmo `Player.Functions.Save()` -> `FDBCore.Player.Save(source)`, ficando totalmente coberto pela trava de coalescimento.
- **Validações Sanitizadas Anti-NaN e Anti-Infinito**:
  - Adicionadas checagens de `not amount or amount ~= amount or amount == math.huge or amount == -math.huge or amount < 0` em `AddMoney`, `RemoveMoney`, `SetMoney`, `AddRep` e `RemoveRep`.
  - Proteção de saldo mínimo em `AddRep` impedindo reputações negativas (`math.max(0, currentRep + addAmount)`).

### 5. Jobs, Gangs & Permissões (`FDB-Core/server/commands.lua` & `functions.lua`)
- **Comandos de Permissão (`addpermission` / `removepermission`)**:
  - Restritos estritamente ao nível de acesso **`god`** (`FDBCore.Commands.Add(..., 'god')`).
  - Adicionada validação de target online (`targetId <= 0` ou `Player == nil`).
  - Integrado log de auditoria em `fdb-log:server:CreateLog` registrando concessões (verde) e revogações (vermelho), tratando `source == 0` como `'Console'`.
- **Comandos de Atribuição de Job e Gangue (`setjob` / `setgang`)**:
  - Restritos estritamente ao nível de acesso **`admin`** (`FDBCore.Commands.Add('setjob', ..., 'admin')` / `FDBCore.Commands.Add('setgang', ..., 'admin')`).
  - Validação de existência de Job/Gangue (`FDBCore.Shared.Jobs[job]` / `FDBCore.Shared.Gangs[gang]`).
  - Fallback automático seguro para `level = 0` ('No Grades') em `Player.Functions.SetJob`/`SetGang` caso a grade informada não exista no dicionário.
  - *Nota de Arquitetura*: Os comandos `/setjob` e `/setgang` utilizam permissão genérica de administração (`'admin'`), sem hierarquia por facção individual no core. O gerenciamento de hierarquias de chefia e contratações in-game (ex.: chefe de polícia promovendo subordinados) é intencionalmente delegado aos recursos companheiros de bossmenu. (Commit hash: `30a6cb92d16d4eb381edbc652da4b10ef2936bfd`).

### 6. Otimização de Performance & StateBags (`FDB-Core/client/`)
- **Otimização do Loop de PVP (`FDB-Core/client/pvp.lua:8-10`)**:
  - Corrigido o consumo inútil de CPU por tick (`Wait(0)`) quando o PVP do servidor está desativado. Quando `FDBCore.Config.Server.PVP` for `false`, o thread entra em repouso com `Wait(1000)`.
- **Cache de Handle de Entidade no `/me` 3D (`FDB-Core/client/events.lua:186-193`)**:
  - Movida a resolução do ped `targetPed = GetPlayerPed(sender)` para fora da estrutura de repetição do renderizador 3D, reduzindo 1 chamada nativa por frame durante os 10 segundos de exibição do texto 3D.
- **Validação de StateBags & Broadcast**:
  - Confirmado que todas as alterações de StateBag pelo client (`isLoggedIn`) possuem parâmetro `replicated = false`.
  - Confirmado que zero queries MySQL executam em ticks/loops de repetição e que eventos de atualização de dados do jogador usam o `source` específico. (Commit hash: `baf45263fbdbd69471a57587970585e4fa036a06`).

### 7. Documentação Final & Wiki (`FDB-Core/`)
- **Central WIKI (`FDB-Core/WIKI.md`)**:
  - Criada a documentação central da API de exports (Server & Client) e matriz de eventos de rede com payloads e restrições.
### 8. Biblioteca Central de UI (`fdb-libs/`)
- **Arquitetura Base**:
  - **Backend/Ponte LUA**: Fornece as exports globais (`fdb.menu.open`, `fdb.menu.close`) e gerencia os callbacks do NUI.
  - **Frontend Svelte + Vite**: A interface gráfica foi construída inteiramente utilizando o framework Svelte compilado através do Vite.
- **Histórico de Problemas Críticos e Resoluções**:
  - **Bloqueio de Segurança (CORS) no CEF do FiveM**: O Vite compila scripts JS utilizando `<script type="module" crossorigin>`. O CEF do FiveM trata o protocolo local `nui://` com políticas estritas de segurança, bloqueando a execução do script com o atributo `crossorigin`. A solução foi intervir no processo de build e no arquivo `index.html` para remover manualmente a tag `crossorigin`, permitindo que o `nui://` executasse o módulo JS sem bloqueios.
  - **Cache Agressivo do NUI (FiveM)**: Ao rebuildar o projeto Svelte na pasta padrão `dist/`, o NUI do FiveM cacheava a rota `ui/dist/index.html`. Comandos de restart não forçavam os clientes a baixarem a nova versão da UI. A solução foi alterar o `vite.config.js` para compilar o código de saída para a pasta `build/` e atualizar o `fxmanifest.lua` para apontar para `ui/build/index.html`, forçando a quebra de cache.
  - **Integração de Texturas Rústicas (Aesthetic RDR2)**: O visual padrão de "app moderno" foi substituído por uma imersão completa: fundos de pergaminho/papel envelhecido (`background.png`), divisórias texturizadas para Sliders e ColorGrids (`tank_meter_marker`, `swatch_box`) e ocultação de elementos Unicode substituídos por assets de imagens (`tick.png`, setas estilizadas).

---

## 🔒 Auditoria de Segurança — Resumo

Toda a camada de rede do core (`FDB-Core/server/events.lua`) foi auditada no arquivo [`FDB-Core/AUDIT.md`](file:///d:/BASE%20NOVA/FDB-Core/AUDIT.md). Todos os 14 eventos de servidor estão classificados entre `✅ OK` e `✅ RESOLVED`.

---

## 🏛️ Estado Atual do Fork & Artefatos de Referência

O **FDB-Core** encontra-se 100% estabilizado e auditado. Para consultar tópicos específicos da arquitetura:
- 📖 **API de Exports & Eventos**: [`FDB-Core/WIKI.md`](file:///d:/BASE%20NOVA/FDB-Core/WIKI.md)
- 🛡️ **Matriz de Auditoria de Rede**: [`FDB-Core/AUDIT.md`](file:///d:/BASE%20NOVA/FDB-Core/AUDIT.md)
- 🗄️ **Banco de Dados & Migrações**: [`FDB-Core/DATABASE.md`](file:///d:/BASE%20NOVA/FDB-Core/DATABASE.md)
- 📐 **Arquitetura Geral**: [`FDB-Core/ARCHITECTURE.md`](file:///d:/BASE%20NOVA/FDB-Core/ARCHITECTURE.md)

---

## 📝 Como Manter Este Documento Atualizado

1. **A cada PR mergeado**: Atualizar a tabela de Status Geral da respectiva fase e adicionar os detalhes das alterações sob "Mudanças por Módulo".
2. **Novos Módulos**: Registrar qualquer criação de tabelas ou alterações de arquitetura com a devida justificativa técnica.
