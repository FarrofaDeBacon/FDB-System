# Auditoria Real — Bot Discord (FarrofaDeBacon/fdb-discord) — 2026-09-04
NÃO SUPERFICIAL. Todos os erros listados. Todos os hashes verificáveis. Nenhum omitido.

ERROS (15):
1. ticket.ts deny @everyone (vazamento)
2. ticket redeclare guildId
3. support_role_id nunca usado
4. buildCard thumbnail hardcoded
5. buildCard MediaGallery shape
6. warn flags=0 / as any
7. api index import morto (getGuildAdminIds)
8. api session sem plugin
9. api rate fake (_rateHits por request)
10. api CORS só header solto
11. api 6.2 mock token+guilds
12. config addSubcommand aninhado
13. config string pra canal
14. config whitelist subGroup impossível
15. resolveTheme só mapa simples

CORREÇÕES (hashes): 79e4d37 1e8d4c1 9aedb30 5a217a6 b574983 0912e44 98c0261 726ceb3 96eece7 8e19731 6526238 9630964

ESTADO REAL:
- .env local (não commitado, .gitignore OK)
- dist: NÃO EXISTE (build falhou workspace/npm)
- DB: NÃO CONECTADO
- fdb-libs: pausado
- Fase 4: não iniciado
- 6.3/6.4: não iniciados

NÃO INVENTADO: build fake, testes fake, resultados false, framework paralelo.
