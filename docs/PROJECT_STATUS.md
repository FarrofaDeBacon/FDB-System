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

Nesta nova fase (04/08/2026), iniciamos a integração da base visual e estrutural que vai dar suporte ao sistema médico avançado. 

### 5.1 O Que Já Foi Feito (Fase 1 + Correções Emergenciais)
- ✅ **Inventário (`fdb-inventory`):** Substituído pela versão imaculada da source original (`STEEL`). A versão anterior estava com imagens corrompidas e arquivos Javascript deletados devido a um script de renomeação agressivo. Renomeamos as variáveis e dependências de forma cirúrgica, blindando os binários e arquivos web, além de fixarmos um bug crítico no `GetFDBPlayers`.
- ✅ **Mochilas (`fdb-backpacks`):** Adicionado ao ecossistema para resolver um gargalo do inventário que causava congelamento da interface quando tentava se conectar a esse recurso faltante.
- ✅ **Infraestrutura Transversal (`fdb-configui`):** Adicionado com sucesso. Este é o motor de KVP genérico que o ecossistema precisa. 
- ✅ **Permissões Base (`server.cfg`):** As permissões do Core foram devidamente renomeadas de `rsgcore.*` para `fdbcore.*` no servidor ao vivo, permitindo que administradores tenham acesso ao painel do `configui` in-game, e incluindo também os comandos de debug do sistema médico (`/addtreatment`, `/forceinfection`, etc.).

### 5.2 Próximos Passos (Fase 2 Revisada)
Antes de colocarmos o gigantesco sistema médico (`fdb-medic` + `fdb-medical-core`), validamos que ele quebraria sem suas duas âncoras fundamentais de mecânica:
1. **`fdb-hudpremium`:** Será adicionado primeiro, substituindo o antigo `fdb-hud`, pois é ele quem exibe os ícones vitais de sangramento e infecção.
2. **`fdb-consume`:** Será substituído pela sua build real de mais de 2.000 linhas, já que o sistema médico depende dele para aplicar ataduras e tônicos de saúde corretamente.

Após essas duas fundações visuais e de consumo estarem operantes, finalmente acoplaremos a joia da coroa: o ecossistema médico.

---
**ATENÇÃO - Nota Importante para o Claude:**
O repositório `FDB-System` não é apenas um "RSG renomeado". O FDB-Core foi substancialmente reescrito seguindo o documento de arquitetura inegociável, e agora os principais módulos (Inventário, ConfigUI, Backpacks) também já foram adaptados e unificados sob a flag `fdb`. Estamos no meio da migração estrutural para suportar o novo sistema médico! Sempre consulte os `fxmanifest.lua` mais recentes. (`D:\SERVIDOR\server`).
