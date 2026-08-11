# Roadmap de Implementação — Sistema de Ilegal (RSG-Core)

Ajustado a partir do roteiro de 35 fases, com duas mudanças deliberadas:

1. **Bridge desde o início.** Nada no Crime Core chama `RSGCore.Functions.*` diretamente —
   tudo passa por `bridge/interface.lua`. Isso mantém o sistema portável (inclusive pro
   FDB-Core no futuro, se fizer sentido) sem custo de performance real.
2. **Testemunha/evidência entram na Etapa 1, não na Etapa 6.** O Crime Core já nasce com os
   hooks (`RollWitness`, `RollEvidence`) chamados por todo crime, mesmo que hoje só
   registrem "sem testemunha". Adicionar isso depois exigiria tocar em cada crime já
   implementado — nascer com o hook custa quase nada agora.

## Etapa 1 — Crime Core (entregue neste pacote)

- [x] `bridge/interface.lua` — contrato do framework (GetPlayer, AddMoney, HasItem, Notify, etc.)
- [x] `bridge/rsg_bridge.lua` — implementação do contrato pra RSG-Core vanilla
- [x] `server/core.lua` — registro de crimes, cooldown, Heat, XP, roll de testemunha/evidência,
      histórico (server-autoritativo: toda decisão de sucesso/falha e recompensa é resolvida
      no servidor, o client só recebe o resultado)
- [x] `sql/install.sql` — tabelas base (`crime_history`, `player_criminal`)
- [x] `config.lua` — formato de configuração por crime (igual ao proposto na Fase 32)

## Etapa 2 — Primeiro crime jogável (entregue neste pacote)

- [x] `server/crimes/npc_robbery.lua` — Roubo de NPC usando o Crime Core
- [x] `client/core.lua` — interação com NPC via bridge (target-agnostic, ver nota abaixo)

Isso testa a arquitetura ponta a ponta: registro → cooldown → roll de sucesso →
Heat/XP → possível testemunha → histórico. Se esse fluxo estiver sólido, os próximos
crimes (túmulo, casa, loja...) são só configuração + um arquivo de crime específico,
sem tocar no Core.

## Etapa 3 — Roubo de Túmulos (entregue neste pacote)

- [x] `client/crimes/grave_robbery.lua` — Client do roubo a túmulos (sistema de ox_target global com distância ajustada).
- [x] `server/crimes/grave_robbery.lua` — Servidor do roubo a túmulos, controlando Loot Dinâmico, Integração ao Crime Core, e Segurança Anti-Exploit.
- [x] Minigame de precisão (`circle_shake`).
- [x] Mecanismo de Cooldown do Túmulo com banco de dados persistente (dias no jogo).
- [x] Animações completas com pá e feedback visual de montes de terra na lápide (dirt pile).

## Próximas etapas (não entregues ainda — ordem sugerida)

| Etapa | Conteúdo | Depende de |
|---|---|---|
| 4 | Roubo de Lojas (Hold-up em NPCs, arrombamento de caixas) | Core, sistema de loot |
| 5 | Roubo de casas (múltiplos pontos, arrombamento, barulho) | Core, sistema de loot |
| 6 | Loot tables + itens roubados (`stolen = true`) + receptadores | Core |
| 7 | Evidências físicas completas (não só o roll — objeto no mundo, perícia) | Fase 1 (hook já existe) |
| 8 | Integração com polícia (evento com descrição, não identidade) | Testemunha/evidência completos |
| 9 | Carroças, diligências | Core, loot |
| 10 | Contrabando + mercado negro + contratos | Receptadores, reputação |
| 11 | Trem, banco | Tudo acima |
| 12 | Gangues, território | Endgame — só depois do resto estável |

## Pendências resolvidas na arquitetura base

- **Target system**: O sistema usa `ox_target` para props/peds. Foi criada uma Bridge transparente (`fdb_bridge_client.lua` e `rsg_bridge_client.lua`) que trata o registro do `ox_target` independentemente da base.
- **Minigames**: Utilização robusta da `fdb-libs`.
- **Inventário**: Funções `HasItem`, `AddItem` centralizadas via Bridge.
- **Banco de Dados**: Usamos `oxmysql` via comandos diretos no `CrimeCore`. Módulo totalmente plug-and-play.
