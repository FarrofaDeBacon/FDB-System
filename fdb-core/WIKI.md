# 📚 FDB-Core Wiki — Exports & Network Events

Esta documentação serve como referência centralizada para a API do **FDB-Core**. Todos os métodos e eventos foram extraídos e validados diretamente a partir do código fonte.

---

## 🛠️ 1. Core & Public Exports

### `GetCoreObject` (Client & Server)
Retorna a instância global autoritativa `FDBCore`.

- **Sintaxe**: `exports['fdb-core']:GetCoreObject()`
- **Retorno**: `table` (`FDBCore`)
- **Exemplo**:
```lua
local FDBCore = exports['fdb-core']:GetCoreObject()
```

---

## 🖥️ 2. Server-Side Exports (`FDB-Core/server/exports.lua`)

| Export | Parâmetros | Retorno | Descrição |
| :--- | :--- | :--- | :--- |
| `GetCoreObject` | *Nenhum* | `table` | Retorna o objeto principal `FDBCore`. |
| `GetCoreVersion` | *Nenhum* | `string` | Retorna a versão atual do recurso `fdb-core`. |
| `SetMethod` | `methodName: string`, `handler: function` | `boolean, string` | Adiciona/Sobrescreve uma função em `FDBCore.Functions`. |
| `SetField` | `fieldName: string`, `data: any` | `boolean, string` | Adiciona/Sobrescreve um campo na tabela global `FDBCore`. |
| `AddJob` | `jobName: string`, `job: table` | `boolean, string` | Registra uma nova profissão em tempo de execução. |
| `AddJobs` | `jobs: table` | `boolean, string` | Registra múltiplas profissões de uma só vez. |
| `RemoveJob` | `jobName: string` | `boolean, string` | Remove uma profissão cadastrada. |
| `UpdateJob` | `jobName: string`, `job: table` | `boolean, string` | Atualiza a definição/cargos de uma profissão. |
| `AddItem` | `itemName: string`, `item: table` | `boolean, string` | Registra um novo item compartilhado. |
| `AddItems` | `items: table` | `boolean, string` | Registra múltiplos itens de uma só vez. |
| `RemoveItem` | `itemName: string` | `boolean, string` | Remove um item do catálogo global. |
| `UpdateItem` | `itemName: string`, `item: table` | `boolean, string` | Atualiza a definição de um item. |
| `AddGang` | `gangName: string`, `gang: table` | `boolean, string` | Registra uma nova gangue/facção. |
| `AddGangs` | `gangs: table` | `boolean, string` | Registra múltiplas gangues de uma só vez. |
| `RemoveGang` | `gangName: string` | `boolean, string` | Remove uma gangue. |
| `UpdateGang` | `gangName: string`, `gang: table` | `boolean, string` | Atualiza a estrutura de uma gangue. |
| `ExploitBan` | `source: number`, `reason: string` | *Void* | Bane um jogador por tentativa de exploit no servidor. |

#### Exemplo de Uso (`AddItem`):
```lua
local success, err = exports['fdb-core']:AddItem('custom_bread', {
    name = 'custom_bread',
    label = 'Pão Artesanal',
    weight = 100,
    type = 'item',
    image = 'custom_bread.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Um delicioso pão recém assado.'
})
```

---

## 💻 3. Client-Side Exports (`FDB-Core/client/`)

### DrawText Interface (`FDB-Core/client/drawtext.lua`)

| Export | Parâmetros | Retorno | Descrição |
| :--- | :--- | :--- | :--- |
| `DrawText` | `text: string`, `position: string` | *Void* | Exibe um texto de interface/HUD na tela. |
| `ChangeText` | `text: string`, `position: string` | *Void* | Atualiza o conteúdo do texto visível. |
| `HideText` | *Nenhum* | *Void* | Oculta o texto na tela. |
| `KeyPressed` | *Nenhum* | *Void* | Notifica o pressionamento da tecla de ação do texto. |

### Prompts Native Interface (`FDB-Core/client/prompts.lua`)

| Export | Parâmetros | Retorno | Descrição |
| :--- | :--- | :--- | :--- |
| `createPrompt` | `name: string`, `key: string`, `label: string`, `holdTime: number`, `options: table` | `table` | Cria um prompt de interação RDR2 individual. |
| `createPromptGroup` | `name: string`, `coords: vector3`, `label: string`, `prompts: table` | `table` | Cria um grupo contextual de prompts por coordenada. |
| `deletePrompt` | `name: string` | *Void* | Deleta um prompt criado. |
| `deletePromptGroup` | `name: string` | *Void* | Deleta um grupo de prompts criado. |

### Security / Utility

| Export | Parâmetros | Retorno | Descrição |
| :--- | :--- | :--- | :--- |
| `GenerateCSRFToken` | *Nenhum* | `string` | Gera/Obtém o token CSRF local de segurança. |

---

## 📡 4. Matriz de Eventos de Rede Auditados

| Nome do Evento | Direção | Payload Esperado | Descrição / Restrições de Segurança |
| :--- | :--- | :--- | :--- |
| `FDBCore:Server:SetMetaData` | Client ➔ Server | `meta: string, data: number` | Atualiza metadados. Restrito à whitelist (`hunger`, `thirst`) e limite `0-100`. |
| `FDBCore:Server:ToggleDuty` | Client ➔ Server | *Nenhum* | Alterna estado de serviço (`onduty`). `src = source` amarrado. |
| `FDBCore:Server:PlayerDropped` | Server ➔ Server | `Player: table` | Disparado na desconexão de um jogador. |
| `FDBCore:Client:OnJobUpdate` | Server ➔ Client | `job: table` | Notifica o cliente da alteração da sua profissão (Individual por `source`). |
| `FDBCore:Client:OnGangUpdate` | Server ➔ Client | `gang: table` | Notifica o cliente da alteração da sua gangue (Individual por `source`). |
| `FDBCore:Client:OnMoneyChange` | Server ➔ Client | `type: string, amount: number, mode: string, reason: string` | Notifica alterações de saldo. |
| `FDBCore:Client:OnSharedUpdate` | Server ➔ Client (-1) | `tableName: string, key: string, value: table` | Replicador global de novas jobs/itens em runtime. |
