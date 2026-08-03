# MODIFICATIONS.md — Diferenças do FDB-Core em relação ao RSG-Core original

Este documento registra todas as alterações estruturais, correções de segurança, otimizações de banco de dados e decisões de arquitetura aplicadas ao **FDB-Core** (fork do RSG-Core). Serve como registro histórico e fonte de verdade para a equipe e assistentes de IA.

---

## 📊 Status Geral de Execução

| Fase | Descrição | Status | Detalhes / PR |
| :--- | :--- | :--- | :--- |
| **Fase 1** | Segurança & Auditoria Base | ✅ APROVADA | Remediação de privilégios em `SetMetaData` e `DebugSomething`. Matriz em `AUDIT.md`. |
| **Fase 1.5** | Auditoria de Recursos Companheiros | 📅 AGENDADA | Escopo para `rsg-inventory`, `rsg-banking` e lojas. |
| **Fase 2** | Camada de Banco de Dados (`oxmysql`) | ✅ APROVADA | Runner de migração com `pcall`, DDL idempotente, índices em `players`. |
| **Fase 3** | Eventos, Exports & Rebrand | ✅ APROVADA | Rebrand literal RSG→FDB em todo o repo. Exports nativos preservados. |
| **Fase 4** | Inventário & Concorrência | ✅ APROVADA | Prevenção de duplicação/perda de estado, travas anti-NaN/infinito e lock coalescente de I/O em `Player.Save`. |
| **Fase 5** | Jobs, Gangs & Permissões | ✅ APROVADA | Validação de target online, auditoria via `fdb-log`, permissão `'god'` para `addpermission`/`removepermission` e `'admin'` para `/setjob`/`/setgang`. (Commit: `30a6cb92d16d4eb381edbc652da4b10ef2936bfd`) |
| **Fase 6** | Performance & StateBags | ⏳ PRÓXIMA | Redução de broadcast e otimização de loops `Citizen.Wait`. |
| **Fase 7** | Documentação Final & Wiki | ⏳ PENDENTE | READMEs por módulo e Wiki central de exports. |

---

## 🛠️ Mudanças por Módulo

### 1. Módulo de Segurança (`FDB-Core/server/`)
- **`server/events.lua:162` (`SetMetaData`)**:
  - Implementada a whitelist `AllowedClientMetaData` (`hunger`, `thirst`).
  - Adicionada validação estrita de tipo (`type(data) == 'number'`) e limite numérico (`0` a `100`). Tentativas de alteração de metadados protegidos (`isdead`, `job`, `money`) via client são descartadas no servidor.
- **`server/debug.lua:28` (`DebugSomething`)**:
  - Adicionada restrição `RSGCore.Functions.HasPermission(src, 'admin')` para invocações de rede por clientes sem nível admin.

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
  - Renomeados todos os identificadores globais: `RSGCore` ➔ `FDBCore`, `RSGShared` ➔ `FDBShared`, `RSGConfig` ➔ `FDBConfig`.
  - Atualizado o prefixo de eventos: `RSG:` / `RSGCore:` ➔ `FDB:` / `FDBCore:`.
  - Atualizado o nome do recurso base: `rsg-core` ➔ `fdb-core`.
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

---

## 🔒 Auditoria de Segurança — Resumo

Toda a camada de rede do core (`FDB-Core/server/events.lua`) foi auditada no arquivo [`FDB-Core/AUDIT.md`](file:///d:/BASE%20NOVA/FDB-Core/AUDIT.md). Todos os 14 eventos de servidor estão classificados entre `✅ OK` e `✅ RESOLVED`.

---

## 📝 Como Manter Este Documento Atualizado

1. **A cada PR mergeado**: Atualizar a tabela de Status Geral da respectiva fase e adicionar os detalhes das alterações sob "Mudanças por Módulo".
2. **Novos Módulos**: Registrar qualquer criação de tabelas ou alterações de arquitetura com a devida justificativa técnica.
