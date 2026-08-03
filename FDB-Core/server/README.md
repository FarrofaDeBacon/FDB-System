# 📁 FDB-Core Server Module

Este módulo contém toda a lógica autoritativa de servidor do **FDB-Core**, responsável pelo gerenciamento de jogadores, banco de dados, permissões, comandos administrativos e sincronização de rede.

---

## 🛠️ Estrutura de Arquivos

- **[`main.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/main.lua)**: Inicialização do core no lado do servidor e export nativo `GetCoreObject`.
- **[`player.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/player.lua)**: Instanciação de objetos Player, gestão de saldos (`AddMoney`, `RemoveMoney`), reputação, cargos (`SetJob`, `SetGang`) e o salvamento em banco via `FDBCore.Player.Save` (com trava coalescente de I/O).
- **[`events.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/events.lua)**: Handlers de rede seguros (Whitelisted `SetMetaData`, `playerDropped`, `ToggleDuty`).
- **[`commands.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/commands.lua)**: Registro de comandos administrativos (`addpermission`, `removepermission`, `setjob`, `setgang`, `tp`, `givemoney`).
- **[`functions.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/functions.lua)**: Utilitários globais de servidor, manipulação de Ace Permissions (`AddPermission`, `RemovePermission`, `HasPermission`), callbacks e kicks.
- **[`exports.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/exports.lua)**: Interface de API pública exportada para outros recursos (`AddJob`, `AddItem`, `AddGang`, `ExploitBan`).
- **[`migrations.lua`](file:///d:/BASE%20NOVA/FDB-Core/server/migrations.lua)**: Runner automático de migrações de banco de dados no `MySQL.ready` com isolamento `pcall`.

---

## 🔒 Regras Principais de Arquitetura

1. **Server-Authoritative**: O servidor nunca confia em inputs não sanitizados do cliente.
2. **Sem I/O em Ticks**: Gravações no MySQL ocorrem por evento ou intervalos sob demanda com trava coalescente.
3. **Docs & Referência**: Para a API completa de exports e eventos, consulte o [`WIKI.md`](file:///d:/BASE%20NOVA/FDB-Core/WIKI.md) e o [`MODIFICATIONS.md`](file:///d:/BASE%20NOVA/MODIFICATIONS.md).
