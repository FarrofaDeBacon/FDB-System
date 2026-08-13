# Etapa 4 — Roubo de Lojas Concluído!

A implementação da **Etapa 4 (Roubo de Lojas Noturno)** foi finalizada conforme as diretrizes do prompt. Aqui está o resumo técnico das alterações:

## 1. Desacoplamento do Cooldown (CrimeCore)
- Removi as chamadas de `CrimeCore.AttemptCrime` e `CrimeCore.FinishCrime` do evento `attemptBurglary` no servidor.
- Agora, o cooldown da registradora é **100% isolado por loja** utilizando a tabela persistente `storeRespawnTimes[storeName]`. Arrombar a porta não interfere no cooldown da registradora e vice-versa.
- A registradora agora entrega dinheiro via `Bridge.AddMoney` usando o min/max do `registerCash` definido na loja.

## 2. Mecânica de Risco (Cachorro, Testemunha e NPC)
- O fluxo de interação com a registradora foi refatorado. O cliente agora dispara `illegal-system:server:startRegisterBurglary` *antes* do minigame começar.
- **Toda a lógica e RNG estão centralizados no servidor:**
  - **Cachorro**: Se sorteado, o servidor avisa o cliente (`spawnDogRisk`), que spawna o modelo `A_C_DogCollie_01`, toca o áudio de latido (usando `PlayAmbientSpeech1`) e o cachorro foge após o `barkDuration`.
  - **Testemunha**: Logo após o latido, o servidor avalia se há policiais (LEO on-duty). Se houverem num raio configurado, emite o alerta chamando a trigger já existente `fdb-lawman:client:lawmanAlert` diretamente para eles (sem modificar o script original do lawman).
  - **NPC Armado**: Se não houver policiais, e a flag `onlyIfNoCopsOnline` permitir, um NPC é sorteado após um delay. O servidor avisa o cliente (`armedNpcRisk`), que encena o NPC sacando um revólver.
  - **Nocaute**: O servidor já rola o desfecho caso o jogador seja pego. A prisão (`jail`) já está esquematizada no if/else condicional aguardando a futura função policial, deixando atualmente apenas o ragdoll inofensivo.

## 3. Destrancamento Permanente das Portas Noturnas (Opção 2)
Implementado exatamente conforme solicitado:
- No boot do resource (após 2 segundos para garantir o load), o `illegal-system` usa a export `exports.wasvendel_doorlock:GetLocks()` para varrer as portas registradas. Ele cruza a distância da `store.doorCoords` (margem de 5 metros) para descobrir sozinho o `lockId` de cada loja, **sem precisar cadastrar hardcode**.
- Foi criado um loop independente de 5 segundos que escuta o `GetClockHours()`. Assim que bater exatamente a `closeHour` (ex: 22h), ele dispara um `exports.wasvendel_doorlock:SetLockState(lockId, true)`.
- Adicionei a verificação `lastLockedDay[store.name] = day` para garantir que o disparo ocorra apenas uma única vez no dia em questão.
- O resultado é que se a porta for arrombada de noite, ela ficará eternamente destrancada, virando o dia até bater 22h novamente, quando se re-trancará sozinha. Tudo isso **sem alterar nem 1 byte do `wasvendel_doorlock`**.

## 4. Configuração e ROADMAP
- O grande bloco `burglary = { ... }` foi adicionado em `Config.Crimes['store_robbery']` no `config.lua`, permitindo habilitar, desabilitar e regular as chances de cada camada da mecânica de risco perfeitamente.
- A tabela em `ROADMAP.md` foi limpa, atualizada e devidamente documentada.

---
> [!TIP]
> Para testar em tempo real: altere a hora do jogo para as 23:00, use um `lockpick` e observe a reação em cadeia da mecânica de risco na registradora!
