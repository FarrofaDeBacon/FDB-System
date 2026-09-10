PROMPT CLAUDE - Sessao d--BASE-NOVA / FDB-System

JAH FEITO: revive (fdb-medic/core), HUDItem debug removido/bundle, fdb-consume beer=-5+protecao, servidores sincronizados. Commits 43ec0ea/c85be8a/7d4da63.

PROBLEMA ABERTO: jogador morre ao primeiro gole de cerveja (beer). fdb-consume corrigido e protegido; morte persiste apos restart.

SUSPEITA: outro recurso aplica ApplyDamage (fdb-survival alc intox, outro framework consume). Analise fdb-consume/client/medical.lua, fdb-survival/server/main.lua (alcohol/death), e qualquer outro evento de useItem.
