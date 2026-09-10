# 💻 FDB-Core Client Module

Este módulo gerencia a lógica client-side do **FDB-Core**, incluindo renderização de interface, controle de prompts nativos de RedM, exibição de textos 3D e loops de sincronização com o servidor.

---

## 🛠️ Estrutura de Arquivos

- **[`main.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/main.lua)**: Inicialização do client e export `GetCoreObject`.
- **[`events.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/events.lua)**: Handlers de resposta de rede do servidor (`OnPlayerLoaded`, `OnPlayerUnload`, `ShowMe3D`, `OnJobUpdate`).
- **[`functions.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/functions.lua)**: Utilitários client-side, gestão de peds, veículos e notificações `ox_lib`.
- **[`prompts.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/prompts.lua)**: Gerenciador de prompts contextuais nativos de RedM com wait dinâmico e cache `ox_lib`.
- **[`drawtext.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/drawtext.lua)**: Interface gráfica e exports para exibição de mensagens e HUD de tela (`DrawText`, `HideText`).
- **[`loops.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/loops.lua)**: Loop de sincronização periódica de estado a cada 5 minutos.
- **[`pvp.lua`](file:///d:/BASE%20NOVA/FDB-Core/client/pvp.lua)**: Gerenciador de modo PVP e relacionamento entre grupos com repouso inativo (`Wait(1000)` em idle).

---

## ⚡ Diretrizes de Performance

- **Zero Wait(0) Ocioso**: Loops entram em sleep quando fora de contexto.
- **Cache de Entidades**: Utilização de `cache.ped` do `ox_lib` para minimizar chamadas à native `PlayerPedId()`.
- **StateBags Não-Replicados**: Estados de login locais usam `replicated = false`.
