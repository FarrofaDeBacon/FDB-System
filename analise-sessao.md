---
name: analise-sessao-fdb
---

# Análise da Sessão — FDB-System (RedM)

## O que foi feito

| Área | Arquivo | Correção |
|---|---|---|
| Revive / Health | `fdb-medical-core/server/api.lua` | Removida duplicata quebrada (linha 153); `FullHeal` sincroniza `health = 600` |
| Revive / Health | `fdb-medical-core/server/vitals.lua` | Criado `ResetPlayerVitals` (statebag + metadata) |
| Revive / Health | `fdb-medic/server/server.lua` | `ConfirmRevived` força `SetMetaData('health', 600)` |
| HUD | `fdb-hudpremium/ui/src/components/HUDItem.svelte` | Debug `console.log` removido |
| HUD | `fdb-hudpremium/client/main.lua` | Debug `PLAYER STAMINA DEBUG` removido |
| HUD | `fdb-hudpremium/ui/dist/assets/index-CnJIB4DL.js` | Bundle rebuildado (0 hits de debug) |
| Consumo | `fdb-consume/config/drinks.lua` | `beer` corrigido: `health = -5` (antes `+5` = morte) |
| Consumo | `fdb-consume/server.lua` | Proteção: só aplica cura se `stats.health < 0` |

## Commits
- `43ec0ea` — fix(fdb-medical): FullHeal + ResetPlayerVitals
- `c85be8a` — fix(fdb-medical): adiciona ResetPlayerVitals
- `7d4da63` — fix(fdb-consume): beer + proteção

## O que funciona
- `revive` via admin (`/revive`) → `ConfirmRevived` → `FullHeal`
- HUD `health` aparece `100` (`#ffffff`) após revive (`FIRST TICK: health=600`)
- Stamina recupera (`111.99 → 100`)

## Problema aberto
- **Morte ao primeiro gole de `beer` persiste** mesmo após `/restart fdb-consume`
- `beer` config = `-5`, `server.lua` protegido, bundle limpo
- **Causa provável:** outro recurso aplica `ApplyDamage` (não `fdb-consume`)
- Suspeitos: `fdb-survival` (alcohol intox), outro framework de consumo, `ox_inventory` evento

## Arquivos para analisar se quiser prosseguir
- `fdb-consume/client/medical.lua`
- `fdb-survival/server/main.lua` (linha ~220 `AddAlcohol`, ~306 intox)
- `fdb-medical-core/server/bleedout.lua`, `infection.lua`
- Qualquer outro `useItem` / `consume` no `[framework]`
