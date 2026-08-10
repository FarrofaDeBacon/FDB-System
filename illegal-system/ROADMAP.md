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

## Próximas etapas (não entregues ainda — ordem sugerida)

| Etapa | Conteúdo | Depende de |
|---|---|---|
| 3 | Roubo de túmulos | Core, loot tables |
| 4 | Roubo de casas (múltiplos pontos, arrombamento, barulho) | Core, sistema de loot |
| 5 | Loot tables + itens roubados (`stolen = true`) + receptadores | Core |
| 6 | Evidências físicas completas (não só o roll — objeto no mundo, perícia) | Fase 1 (hook já existe) |
| 7 | Integração com polícia (evento com descrição, não identidade) | Testemunha/evidência completos |
| 8 | Carroças, lojas, diligências | Core, loot |
| 9 | Contrabando + mercado negro + contratos | Receptadores, reputação |
| 10 | Trem, banco | Tudo acima |
| 11 | Gangues, território | Endgame — só depois do resto estável |

## Pendências de decisão antes da Etapa 3

- **Target system**: o `client/core.lua` está escrito de forma agnóstica (função
  `Bridge.RegisterTargetEntity` no bridge), mas você precisa me dizer se o servidor do
  cliente usa `ox_target`, `rsg-target` ou outro — isso vai direto no `rsg_bridge.lua`.
- **Inventário**: hoje o roubo de NPC só dá dinheiro (`AddMoney`). Pra dar item precisa
  saber se é `ox_inventory` ou `rsg-inventory` (nomes de export diferem).
- **oxmysql**: assumi que a base usa `oxmysql` (padrão atual do RSG-Core) pro `sql/install.sql`
  e pro insert de histórico. Se for `ghmattimysql` ou outro, é só trocar o wrapper em `core.lua`.
