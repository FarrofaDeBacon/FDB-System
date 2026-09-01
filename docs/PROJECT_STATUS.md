# Status Atual do Projeto: FDB-System (RedM)

Este documento resume o que planejamos, o que já foi executado e os problemas recentemente resolvidos na nossa jornada de conversão e estruturação da base **FDB-System** (um framework próprio baseado no RSG Core para RedM).

## 1. O Plano Original
Nosso objetivo principal é criar uma base sólida e independente chamada **FDB-System**, re-estruturando as fundações do RSG Core. O plano envolveu:
- **Renomeação Global (Rebranding):** Substituir todas as referências de `rsg-core`, `rsgcore`, `rsg_locale` e `rsg-` para o novo padrão `fdb-core`, `fdbcore`, `fdb_locale` e `fdb-`.
- **txAdmin Recipe Customizada:** Criar uma receita de instalação automatizada (`txAdminRecipe`) para facilitar o deploy do servidor do zero, puxando diretamente do repositório oficial no GitHub (`Rexshack-RedM/txAdminRecipe` adaptado para o ecossistema FDB).
- **Banco de Dados Unificado:** Consolidar e corrigir as tabelas do banco de dados no arquivo `fdbcore.sql`, garantindo que todas as tabelas e colunas necessárias para os scripts vitais existam e estejam com a nomenclatura correta (ex: uso do prefixo `player_` ou tabelas sem o prefixo antigo).
- **Módulos Essenciais:** Converter, testar e estabilizar módulos cruciais como Inventário (`fdb-inventory`), Criação de Personagens (`fdb-appearance`), Multicharacter (`fdb-multicharacter`), Sistema de Spawn (`fdb-spawn`) e Sistema de Cavalos (`fdb-horses`).

## 2. O Que Já Fizemos (Executado)
- **Estruturação do Repositório GitHub:** O repositório `FDB-System` (branch `fix/companion-inventory-audit`) está ativo e recebendo todos os commits de correções.
- **Conversão de Scripts Base:** A grande maioria dos scripts já foi convertida via script PowerShell para usar as nomenclaturas `fdb`.
- **Deploy via txAdmin:** A receita foi testada. Apesar de alguns percalços com diretórios (`txData` vs `D:\SERVIDOR\server`), o servidor ativo está sendo manipulado na pasta real.
- **Correção da Tabela de Cavalos:** Descobrimos um erro no script `fdb-horses`. Ele procurava pela tabela `fdb_horses`, mas o nome correto no banco de dados era `player_horses`. Corrigimos isso no código fonte em Lua.
- **Correção do Schema SQL:** O loop de metabolismo dos cavalos exigia uma coluna `metadata` que não existia na tabela original do RSG. Nós alteramos o `fdbcore.sql` para adicionar essa coluna automaticamente.
- **Limpeza de Version Checkers:** Removemos arquivos como `versionchecker.lua` dos scripts clonados para evitar mensagens de erro no console.

## 3. Desafios Recentes e Como Foram Resolvidos (O "Incidente dos Arquivos Binários")
Durante a renomeação global (substituindo textos de `rsg` para `fdb` via PowerShell), o script abriu e "re-salvou" arquivos binários como se fossem texto. Isso corrompeu **fontes (.ttf, .otf)** e **imagens (.png, .jpg)** das interfaces gráficas (NUI).

- **O Problema do Multicharacter (Tela de Erro Vermelha):** 
  - O NUI do `fdb-multicharacter` apresentava falhas de carregamento de fonte (`Failed to decode downloaded font`).
  - **Solução:** Baixamos os arquivos `.ttf` e `.otf` originais diretamente do repositório do RSG, comitamos no `FDB-System` e injetamos na pasta do servidor ativo. O erro vermelho sumiu e as fontes de faroeste voltaram a funcionar.
- **O Problema da Tela de Spawn (Tela Preta / Spawn na Sala de Criação):**
  - O script de spawn não abria a interface porque suas imagens (`valentine.jpg`, `saintdenis.jpg`) estavam corrompidas. Ao criar um personagem novo, o jogador ficava preso na sala de criação, e a posição salva no banco de dados tornava o "erro" permanente para aquele personagem específico.
  - **Solução:** Clonamos novamente o `rsg-spawn` original, fizemos a conversão de textos excluindo arquivos binários para protegê-los, e atualizamos o servidor. Ao criar um personagem novo (slot vazio), o spawn voltou a funcionar.
- **O Problema do Background do Multicharacter (NUI sem bg):**
  - O usuário relatou que a interface do `fdb-multicharacter` continuava "sem fundo". Foi descoberto que as texturas de papel, pergaminho e enfeites (`inkroller_1a.png`, `menu_header_1a.png`, etc.) dentro da pasta `html/assets/` também haviam sido corrompidas pelo script de texto agressivo.
  - **Solução:** Baixamos a pasta `assets` intacta do repositório original do `rsg-multicharacter`, enviamos para o GitHub, e injetamos as imagens restauradas diretamente no servidor em tempo real, corrigindo completamente o visual.

## 5. Integração do Ecossistema Customizado e Migração

Nesta fase madura do projeto (Final de Agosto / Setembro 2026), alcançamos a consolidação total do núcleo de sobrevivência, medicina e consumo.

### 5.1 O Que Já Foi Feito e Validado em Produção
- ✅ **Infraestrutura Transversal (`fdb-configui`):** Adicionado com sucesso. Motor de KVP genérico que o ecossistema precisa. 
- ✅ **Inventário & Mochilas (`fdb-inventory` / `fdb-backpacks`):** Restaurados e imaculados. Bug de `GetFDBPlayers` resolvido.
- ✅ **Fundação Visual (`fdb-hudpremium`):** Compilado com sucesso via Vite+Svelte, integrado perfeitamente aos vitais.
- ✅ **Consumo (`fdb-consume`):** Build completa adicionada. Bug de garrafas/itens fantasmas nas mãos resolvido com cleanup global via `StopInteractiveConsumable`.
- ✅ **Sobrevivência & Água (`fdb-survival` e `fdb-water`):** O `fdb-water` foi integrado nativamente ao `fdb-survival`, substituindo sistemas antigos de banho e consumo. Cooldowns aplicados para evitar abusos na bomba d'água.
- ✅ **O Sistema Médico Supremo (`fdb-medical-core` e `fdb-medic`):** **CONCLUÍDO!** A pausa foi removida. O sistema agora é a fonte absoluta de verdade para a vida do jogador (ancorada em 600 HP, quebrando o cap nativo de 150 do motor do jogo). Foram eliminados eventos duplicados, erros fantasmas no console e hit-kills nativos, mantendo perfeita sincronia com a HUD.
- ✅ **Substituição de Criação de Personagem:** O antigo `fdb-appearance` foi removido e substituído em definitivo pelo **`fdb-creator`** na receita oficial do servidor.
- ✅ **Limpeza de Scripts Obsoletos:** Para garantir estabilidade, deletamos definitivamente os scripts `fdb-canteen`, `fdb-bathing` e `fdb-essentials`, cujos sistemas entravam em conflito com o novo motor de sobrevivência/água.
- ✅ **Atualização da Receita (txAdmin):** Os arquivos `fdbcore.yaml` foram limpos (remoção de doorlocks obsoletos e scripts antigos) e preenchidos com as novas dependências corretas (incluindo `fdb-libs`).

### 5.2 Próximos Passos
- Refinar detalhes de UI e economia.
- Expansão contínua de conteúdo agora que os 4 pilares principais (Core, Inventário, Sobrevivência e Médico) estão estáveis e rodando perfeitamente integrados.

---
**ATENÇÃO - Nota Importante para o Claude / IAs Auxiliares:**
O repositório `FDB-System` evoluiu massivamente e os sistemas principais foram concluídos. Neste momento, os seguintes módulos já são builds altamente customizadas, higienizadas e integradas nativamente à arquitetura do FDB-Core:
- `fdb-core` e `fdb-libs` (Fonte de verdade absoluta)
- `fdb-inventory` e `fdb-backpacks`
- `fdb-hudpremium` e `fdb-configui`
- `fdb-consume` (Totalmente limpo de conflitos)
- `fdb-survival` e `fdb-water` (Motor de atributos vitais e interações)
- `fdb-medical-core` e `fdb-medic` (Motor de danos, ferimentos e tratamento finalizado)
- `fdb-creator` (Responsável exclusivo pela criação visual do personagem)
- `fdb-horses` e `fdb-ammo`

> Consulte sempre o documento `docs/FDB_ECOSYSTEM.md` para entender a visão geral atualizada de cada script, pois o servidor atingiu seu status de integração core principal.
