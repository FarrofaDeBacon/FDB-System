# Plano de Migração: Ecossistema Customizado → FDB-System

**Branch alvo:** `fix/companion-inventory-audit` (ou branch nova dedicada, ver Fase 0)
**Repositório fonte:** `FarrofaDeBacon/RDR2` (branch `dev`) + `D:\STEEL\Server\resources\[framework]`
**Repositório destino:** `FarrofaDeBacon/FDB-System`
**Data da análise:** 04/08/2026
**Metodologia:** comparação direta de árvore de arquivos e contagem de linhas entre os dois repositórios (não é estimativa — dados extraídos dos tarballs reais de ambos os repos).

---

## 1. Diagnóstico (raio-x atual)

| Recurso | Status no FDB-System | Ação |
|---|---|---|
| `fdb-horses` | ✅ Já é a build customizada (28 arq / ~9.380 linhas, diff mínimo) | Manter, revalidar após integração |
| `fdb-inventory` | ✅ Já é a build customizada (925 arq / ~5.310 linhas) | Manter, revalidar após integração |
| `fdb-ammo` | ✅ Já é a build customizada (18 arq, idêntico) | Manter |
| `fdb-consume` | ⚠️ Apenas `rsg-consume` renomeado (490 linhas / 7 arq vs. 2.184 linhas / 20 arq da build real) | **Substituir** |
| `fdb-medic` | ⚠️ Apenas `rsg-medic` renomeado (1.220 linhas / 18 arq vs. 8.910 linhas / 111 arq da build real) | **Substituir** |
| `fdb-hud` | ⚠️ Nome e base antigos (1.097 linhas / 25 arq) — o sucessor real é o `fdb-hudpremium` | **Substituir por `fdb-hudpremium`, remover `fdb-hud`** |
| `fdb-survival` | ❌ Ausente | **Adicionar** |
| `fdb-water` | ❌ Ausente | **Adicionar** |
| `fdb-propeditor` | ❌ Ausente (~17.400 linhas / 5 arq) | **Adicionar** |
| `fdb-medical-core` | ❌ Ausente (segunda metade do sistema médico) | **Adicionar** |
| `fdb-hudpremium` | ❌ Ausente | **Adicionar** |
| `fdb-configui` | ❌ Ausente — motor de KVP genérico, dependência transversal | **Adicionar primeiro** |

Fora do escopo deste plano (existem na fonte mas não fazem parte do roteiro atual): `fdb-compass`, `fdb-mapmenu`. Ficam de fora a menos que você decida incluir.

---

## 2. Ordem de execução

A ordem segue a cadeia de dependências: primeiro a infraestrutura transversal, depois os recursos que a consomem, por último a revalidação do que já estava certo.

### Fase 0 — Preparação
- [x] Criar branch dedicada a partir de `fix/companion-inventory-audit` (ex: `feat/ecosystem-integration`) para isolar essa migração de outras correções em andamento
- [x] Congelar mudanças em `fdb-horses` e `fdb-inventory` durante a migração (já estão corretos, não mexer)
- [x] Fazer backup/tag do estado atual do FDB-System antes de remover qualquer coisa

### Fase 1 — Infraestrutura transversal (CONCLUÍDO)
- [x] Adicionar `fdb-configui` (motor de KVP) — nenhum outro recurso novo deve subir sem essa base
- [x] Validar `fxmanifest.lua` do `fdb-core` para garantir que expõe os exports que `fdb-configui` e os demais esperam
- [x] **Adendo:** Adicionado `fdb-backpacks` e restaurado inventário limpo da base original, além de corrigir o bug crítico de rename no inventário.

### Fase 2A — Fundações Visuais e Consumo (CONCLUÍDO)
- [x] Remover `fdb-hud` (nome antigo/stock) → adicionar `fdb-hudpremium` (Vite+Svelte)
  - [x] Atualizar qualquer referência cruzada a `fdb-hud` em outros resources (fxmanifest `dependencies`, exports chamados)
- [x] Remover `fdb-consume` (stock) → adicionar `fdb-consume` (build real, 2.184 linhas)

### Fase 2B — Sobrevivência (CONCLUÍDO)
- [x] Adicionar `fdb-survival` (Maestro / sistema de movimento) — **Nota:** A ordem original foi alterada. O Survival foi migrado ANTES do sistema médico por decisão arquitetural, pois o HUD e o Medical Core dependem do Maestro para orquestrar batimentos cardíacos, higiene e temperatura.

### Fase 2C — Sistema Médico (PAUSADA)
- [ ] Remover `fdb-medic` (stock) → adicionar `fdb-medic` (build real, 8.910 linhas) **+** `fdb-medical-core` (novo, não existia antes)
  - ⚠️ **Status:** PAUSADO aguardando testes in-game das Fases 2A e 2B.

### Fase 3 — Adições puras (não existiam antes)
- [ ] Adicionar `fdb-water` (consumo de água)
- [ ] Adicionar `fdb-propeditor`

### Fase 4 — Correção de dependências
Cada `fxmanifest.lua` migrado precisa ser auditado individualmente porque muitos ainda apontam para `Rexshack-RedM/rsg-core` ou similar em vez de `fdb-core`. Checklist por recurso:
- [ ] `dependencies { 'fdb-core' }` (não `rsg-core`)
- [ ] Nenhuma referência a `rsg-` remanescente em `shared_scripts`, `client_scripts`, `server_scripts`
- [ ] Exports/eventos chamados entre recursos (ex: `fdb-survival` → Maestro, `fdb-medic` → `fdb-medical-core`) resolvidos com os nomes corretos
- [ ] Nenhum comentário/crédito de terceiros restante (regra já estabelecida: tudo é `FarrofaDeBacon`)

### Fase 5 — Revalidação
- [ ] Testar `fdb-horses` e `fdb-inventory` in-game após toda a integração, para garantir que nada quebrou com a chegada do `fdb-core`, `fdb-configui` e do resto do ecossistema
- [ ] Testar especificamente o bug conhecido: nativa de stamina do cavalo retornando `0.0`

---

## 3. Atualização dos documentos MD

Depois da migração de código, os documentos vivos precisam refletir o novo estado real do projeto — hoje ambos descrevem uma foto que fica desatualizada assim que a Fase 2/3 acontece.

### 3.1 `docs/PROJECT_STATUS.md` (no repo FDB-System)
- [ ] Atualizar a seção **"2. O Que Já Fizemos"** para incluir a integração do ecossistema customizado como concluída (hoje ainda está listada em "Próximos Passos")
- [ ] Mover a nota de atenção ao Claude no rodapé — ela descreve um estado transitório ("o único recurso profundamente modificado é o fdb-core") que deixa de ser verdade após esta migração; substituir por um resumo atualizado do que é stock vs. customizado
- [ ] Adicionar uma nova seção **"5. Integração do Ecossistema Customizado"** documentando: quais recursos foram substituídos (consume, medic+medical-core, hud→hudpremium), quais foram adicionados (survival, water, propeditor, configui), e quais já estavam corretos (horses, inventory, ammo)
- [ ] Atualizar a seção de "Próximos Passos" para refletir o que sobra depois desta migração (validação de NUI, testes in-game, etc.)

### 3.2 `AUDITORIA-E-ROTEIRO-v2-fdb-ecossistema.md` (documento vivo da auditoria)
- [ ] Adicionar referência cruzada explicando a relação entre este documento (arquitetura do ecossistema) e o `PROJECT_STATUS.md` do FDB-System (estado da migração/infra)
- [ ] Registrar a mudança de fundação: o ecossistema deixou de rodar sobre RSG Core puro e passou a rodar sobre `fdb-core` (linhagem RSG renomeada e corrigida via FDB-System)
- [ ] Marcar `fdb-configui` como dependência transversal formalmente reconhecida, se ainda não estiver descrita lá

### 3.3 Novo documento (opcional, recomendado)
- [ ] Considerar um `MIGRATION_LOG.md` simples no FDB-System, registrando data/commit de cada substituição — útil caso algo quebre e seja preciso rastrear qual recurso mudou quando

---

## 4. Observação de risco

`fdb-propeditor` tem ~17.400 linhas concentradas em apenas 5 arquivos — é o recurso mais denso de todos, então merece atenção redobrada na Fase 3 (arquivos grandes e monolíticos são mais propensos a conflito silencioso ao integrar com um `fdb-core` diferente do original).
