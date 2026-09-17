# 🔊 Sistema de Banco de Voz e IDs de Som (PlayPain)

## Visão Geral

O sistema de doença do `fdb-survival` utiliza dois mecanismos para criar imersão sonora:

1. **Banco de Voz Ambiente** — Atribuído automaticamente ao ped do jogador ao entrar no servidor
2. **PlayPain** — Native que reproduz sons de dor/tosse/engasgo usando o banco de voz carregado

Sem o banco de voz ativo, o `PlayPain` **não emite nenhum som**. Ambos trabalham juntos.

---

## 1. Banco de Voz (`SetAmbientVoiceName`)

### O que é?

É uma native do RDR2 que define qual "perfil de voz" o ped usa para sons ambiente (grunhidos, tosses, dor, etc).

### Native

```lua
-- Hash: 0x6C8065A3B780185B
-- Assinatura: SetAmbientVoiceName(ped, voiceName)
Citizen.InvokeNative(0x6C8065A3B780185B, ped, voiceName)
```

### ⚠️ REGRA CRÍTICA

O segundo parâmetro **DEVE ser uma STRING**. **NUNCA** passe `GetHashKey()`:

```lua
-- ✅ CORRETO
Citizen.InvokeNative(0x6C8065A3B780185B, ped, '03F01C31')

-- ❌ ERRADO — CAUSA CRASH DO JOGO (Access Violation)
Citizen.InvokeNative(0x6C8065A3B780185B, ped, GetHashKey('03F01C31'))
```

### Vozes Disponíveis

| Voice Name | Gênero | Uso |
|-----------|--------|-----|
| `03F01C31` | Masculino | Voz padrão para peds MP masculinos |
| `02298EE3` | Feminino | Voz padrão para peds MP femininos |

### Onde é Inicializado

**Arquivo:** `fdb-core/client/events.lua`  
**Evento:** `FDBCore:Client:OnPlayerLoaded`

```lua
-- Initialize Voice Bank for MP Peds (required for PlayPain and ambient sounds)
SetTimeout(5000, function()
    local ped = PlayerPedId()
    if IsPedMale(ped) then
        Citizen.InvokeNative(0x6C8065A3B780185B, ped, '03F01C31')
    else
        Citizen.InvokeNative(0x6C8065A3B780185B, ped, '02298EE3')
    end
end)
```

O `SetTimeout(5000)` garante que o ped já esteja totalmente carregado antes de injetar a voz.

---

## 2. PlayPain — IDs de Som

### Native

```lua
PlayPain(ped, painId, volume, isLocal, isSynchronized)
```

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `ped` | Ped | O ped que vai emitir o som |
| `painId` | Integer | ID do som (0–255) |
| `volume` | Float | Volume do som (1 = normal) |
| `isLocal` | Boolean | Se `true`, só o jogador ouve |
| `isSynchronized` | Boolean | Se `true`, sincroniza com outros jogadores |

### Catálogo de IDs Testados

Os seguintes IDs foram testados em ambiente RedM online em 17/09/2026:

| ID | Tipo | Descrição | Ideal para |
|----|------|-----------|------------|
| 1 | Grito de dor | Grito forte e agudo | Dano severo, queda |
| 3 | **Tosse única** | Tosse seca, curta | ✅ **Sintoma de doença leve** |
| 4 | Engasgo/água | Som de afogamento ou beber | Afogamento, veneno |
| 6 | **Tosse única (variação)** | Tosse seca com timbre diferente | ✅ **Sintoma de doença leve** |
| 9 | Dor aguda | Som de dor curto | Dano moderado |
| 10 | Dor grave | Tom mais grave que o 9 | Dano moderado |
| 12 | **Tosse com catarro** | Tosse produtiva, com ruído | ✅ **Sintoma de doença avançada** |
| 23 | Afogamento/líquido | Barulho como bebendo água | Veneno, vômito, afogamento |

### IDs Não Testados (Possíveis)

O range completo vai de **0 a 255**. Muitos IDs podem estar sem mapeamento ou repetir sons.
Para descobrir novos sons, use o comando `/testallpain` (veja seção de Comandos de Teste).

---

## 3. Uso no Sistema de Doença

### Arquivo: `fdb-survival/client/illness.lua`

O `PlayPain` é chamado junto com a animação de tosse:

```lua
if HasAnimDictLoaded(dict) then
    TaskPlayAnim(ped, dict, animName, 8.0, -8.0, 2500, 31, 0, false, false, false)
    -- Som de dor associado à tosse (requer banco de voz ativo no ped)
    PlayPain(ped, 12, 1, true, true)
end
```

### Arquivo: `fdb-survival/config.lua`

As animações de tosse e vômito são configuráveis:

```lua
Config.Biological = {
    -- ...
    
    -- Animações de Tosse (sorteio aleatório entre as ativas)
    CoughAnimations = {
        { dict = 'amb_misc@world_human_coughing@male_a@wip_base', anim = 'wip_base' },
        { dict = 'amb_wander@code_human_coughing_hacking@male_a@wip_base', anim = 'wip_base' },
        { dict = 'mech_loco_m@character@arthur@fidgets@sick@normal@unarmed', anim = 'cough_f' }
    },
    
    -- Animações de Vômito (sorteio aleatório entre as ativas)
    VomitAnimations = {
        { dict = 'amb_misc@world_human_vomit@male_a@idle_a', anim = 'idle_a' },
        { dict = 'amb_misc@world_human_vomit_kneel@male_a@idle_a', anim = 'idle_a' },
        { dict = 'amb_rest_drunk@world_human_drunk_brace_wall@vomit@male_a@idle_a', anim = 'idle_a' }
    }
}
```

### Descrição das Animações de Tosse

| # | Dict | Descrição Visual |
|---|------|-----------------|
| 1 | `amb_misc@world_human_coughing@male_a@wip_base` | Tosse forte, personagem se curva pra frente com mãos nas pernas |
| 2 | `amb_wander@code_human_coughing_hacking@male_a@wip_base` | Tosse engasgada/forte, praticamente igual à #1 |
| 3 | `mech_loco_m@character@arthur@fidgets@sick@normal@unarmed` | Tosse leve em pé, cobre a boca com a mão |

### Descrição das Animações de Vômito

| # | Dict | Descrição Visual |
|---|------|-----------------|
| 1 | `amb_misc@world_human_vomit@male_a@idle_a` | Vômito em pé, curvado pra frente |
| 2 | `amb_misc@world_human_vomit_kneel@male_a@idle_a` | Vômito ajoelhado no chão |
| 3 | `amb_rest_drunk@world_human_drunk_brace_wall@vomit@male_a@idle_a` | Vômito apoiado (posição de bêbado) |

---

## 4. Comandos de Teste

### Recurso: `fdb-test-anims`

Este recurso temporário serve para testar animações e sons no jogo.

| Comando | Descrição |
|---------|-----------|
| `/testcough A` | Tosse forte (curva o corpo) |
| `/testcough B` | Tosse engasgada (curva o corpo) |
| `/testcough C` | Tosse leve (em pé, mão na boca) |
| `/testvomit A` | Vômito em pé |
| `/testvomit B` | Vômito ajoelhado |
| `/testvomit C` | Vômito apoiado |
| `/testsound [ID]` | Toca um som de PlayPain pelo ID (0-255) |
| `/testallpain [inicio] [fim]` | Loop automático de sons do ID início ao fim, com 1.2s entre cada |
| `/setvoice` | Injeta manualmente o banco de voz no ped atual |
| `/teststop` | Cancela qualquer animação em andamento |

### Exemplo de uso do testallpain:

```
/testallpain 0 30     → Toca IDs de 0 a 30
/testallpain 100 150  → Toca IDs de 100 a 150
/testallpain          → Toca TODOS os IDs de 0 a 255
```

---

## 5. Troubleshooting

### Sem som nenhum ao tossir
- **Causa:** O banco de voz não foi carregado no ped.
- **Solução:** Verifique se o `fdb-core` está rodando e se o evento `OnPlayerLoaded` está sendo chamado. Use `/setvoice` para injetar manualmente.

### Jogo fecha / crash ao setar voz
- **Causa:** `GetHashKey()` sendo usado no `SetAmbientVoiceName`.
- **Solução:** Passar a string direta (`'03F01C31'`), **nunca** hasheada.

### Som muito fraco
- **Causa:** O ID do `PlayPain` escolhido pode ter volume baixo por padrão.
- **Solução:** Teste outros IDs com `/testsound [ID]`. Os IDs 3 e 6 são tosses mais audíveis.

### Animação trava o jogador
- **Causa:** Flag de animação errada ou falta do `ClearPedTasks`.
- **Solução:** O sistema já tem um `SetTimeout` de segurança que limpa a animação. Use `/teststop` em caso de emergência.

---

## 6. Arquivos Relacionados

| Arquivo | Função |
|---------|--------|
| `fdb-core/client/events.lua` | Inicialização do banco de voz no `OnPlayerLoaded` |
| `fdb-survival/config.lua` | Configuração das animações de tosse e vômito |
| `fdb-survival/client/illness.lua` | Lógica de sintomas (tosse, vômito, moscas, drenagem) |

---

*Documentação criada em 17/09/2026. Última atualização: 17/09/2026.*
