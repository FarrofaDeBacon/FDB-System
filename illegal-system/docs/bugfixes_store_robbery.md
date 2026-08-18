# Resumo de Correções Recentes: Roubo a Lojas (Store Robbery)

Este documento sumariza as principais alterações e correções de estabilidade feitas no sistema de arrombamento de lojas (`illegal-system/client/crimes/store_robbery.lua`) para resolver inconsistências de IA e físicas do RedM.

## Comportamento Atual (Validado)

Para alinhar o que está atualmente no código:

1. **Cachorro (`A_C_DogCollie_01`):**
   - **Ele APENAS late.** A mordida foi completamente removida. O loop atual consiste em `PlayAmbientSpeech1(dogPed, "BARK", "SPEECH_PARAMS_FORCE_SHOUTED", 1)` e, após o término da duração, ele vai embora usando `TaskWanderStandard`. 
   - Se o cachorro estiver atacando ou fugindo em vez de latir, é porque ele não está recebendo a nossa `TaskTurnPedToFaceEntity`, ou alguma mecânica padrão do RedM para animais assustados está sobrepondo a task do script.

2. **NPC Armado (`A_M_M_ValTownfolk_01`):**
   - **Ele NÃO pode fugir e SEMPRE ataca.** As properties setadas são `SetPedFleeAttributes(armedPed, 0, false)`, `SetPedCombatAttributes(armedPed, 46, true)` (AlwaysFight) e `SetBlockingOfNonTemporaryEvents(armedPed, true)`.
   - Se o NPC fugir, isso contradiz diretamente as flags impostas nele.
   - O ataque é garantido pela `TaskCombatPed(armedPed, playerPed, 0, 16)`.

## Problemas Resolvidos e Como Foram Corrigidos

Abaixo está o log do que foi testado e corrigido durante os testes de spawn e combate (desde o commit `09a291a`):

### 1. Problema: Cachorro não nascia ou NPC nascia do lado de fora (Offsets e Zs manuais)
**Sintoma:** O NPC nascia do lado de fora atirando, enquanto o cachorro caía no limbo ou nascia no telhado invisível. Tentamos usar `PlaceEntityOnGroundProperly` somado a `doorCoords.z + 1.0`, o que fez o cachorro spawnar a `119.47` (no telhado da varanda).
**Correção Aplicada:** 
- Abandonamos a `doorCoords` como base de spawn para esses Peds, pois ela gerava resultados imprevisíveis dependendo da colisão da loja.
- **Solução:** O NPC e o Cachorro agora são gerados dinamicamente **exatamente 2 metros atrás do jogador** (`GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -2.0, 0.0)`), usando o exato `Z` (altura) do jogador.
- Como o jogador está agachado na frente do cofre/registradora, 2 metros para trás garantem que os Peds spawnam dentro da loja, num chão totalmente válido, eliminando a chance de clipping ou teto falso.

### 2. Problema: NPC fugia do próprio tiro
**Sintoma:** Civis no RedM fogem ao ouvir disparos. Quando o nosso NPC atirava, a própria IA dele cancelava o `TaskCombatPed` e iniciava uma fuga instintiva de pânico, ignorando o `BF_AlwaysFight`.
**Correção Aplicada:** 
- Adicionado `SetBlockingOfNonTemporaryEvents(armedPed, true)`. Isso "blinda" (ensurdece) o NPC para eventos de mundo, fazendo-o focar exclusivamente na tarefa que lhe foi dada (`TaskCombatPed`), impedindo o instinto de pânico.

### 3. Problema: NPC totalmente paralisado
**Sintoma:** Numa tentativa de forçar o NPC a nunca fugir, testamos flags agressivas (`SetPedCombatAbility(armedPed, 2)` / Profissional, `HATES_PLAYER` e `SetPedCombatMovement`). Resultado: como ele é da classe "Civil", aplicar estilos de combate militares fez com que a IA dele entrasse em curto (ausência de animações corretas) e ele não atirasse de forma alguma.
**Correção Aplicada:** 
- Revertemos essas 3 propriedades extras militares. Deixamos ele com a IA civil, mas forçado a atacar via `TaskCombatPed` blindado com `SetBlockingOfNonTemporaryEvents(armedPed, true)`. Com isso, ele ataca como civil, mas não se assusta.

### 4. Problema: Jogador preso infinitamente na animação após cancelar Lockpick
**Sintoma:** Ao cancelar ou falhar no minigame `fdb-lockpick` na registradora, o jogador permanecia agachado (`WORLD_HUMAN_CROUCH_INSPECT`) para sempre.
**Correção Aplicada:** 
- **fdb-lockpick:** O NUI Callback `exit` não estava acionando a promisse/callback pro client, deixando o script preso. Foi corrigido no `fdb-lockpick` para sempre retornar `false` (cancelamento) no `exit`.
- **illegal-system:** `ClearPedTasks` (que é fraco para interromper cenários contínuos no RedM) foi substituído por `ClearPedTasksImmediately(ped)`, garantindo que o jogador levante independente do que aconteça.

---
**Nota para depuração:** Todos os spawns de teste estão usando `print` no F8 mostrando as coordenadas finais absolutas onde a Entidade foi renderizada para acompanhamento (`[illegal-system] Cachorro criado em: X, Y, Z`).
