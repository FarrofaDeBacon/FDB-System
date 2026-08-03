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
| **Fase 4** | Inventário & Concorrência | ⏳ PRÓXIMA | Prevenção de duplicação/perda de itens e validações server-side. |
| **Fase 5** | Jobs, Gangs & Permissões | ⏳ PENDENTE | Hierarquias validadas com permissão de quem chama. |
| **Fase 6** | Performance & StateBags | ⏳ PENDENTE | Redução de broadcast e otimização de loops `Citizen.Wait`. |
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

---

## 🔒 Auditoria de Segurança — Resumo

Toda a camada de rede do core (`FDB-Core/server/events.lua`) foi auditada no arquivo [`FDB-Core/AUDIT.md`](file:///d:/BASE%20NOVA/FDB-Core/AUDIT.md). Todos os 14 eventos de servidor estão classificados entre `✅ OK` e `✅ RESOLVED`.

---

## 📝 Como Manter Este Documento Atualizado

1. **A cada PR mergeado**: Atualizar a tabela de Status Geral da respectiva fase e adicionar os detalhes das alterações sob "Mudanças por Módulo".
2. **Novos Módulos**: Registrar qualquer criação de tabelas ou alterações de arquitetura com a devida justificativa técnica.
