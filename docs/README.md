# 📚 FDB-System Documentation Hub

Bem-vindo à documentação central do ecossistema **FDB-System**. 
Aqui consolidamos todos os registros de arquitetura, auditorias de segurança e o histórico de evolução (fork) a partir do RSG-Core original.

## 📖 Índice de Documentos

Abaixo estão os links diretos para cada documento no GitHub e a explicação do seu propósito na engenharia do servidor. Compartilhe este arquivo com o Claude para que ele entenda exatamente o ecossistema.

### 1. [Manual de Regras e Visão (ARCHITECTURE.md)](./ARCHITECTURE.md)
* **O que é:** O documento fundamental (blueprint) que define a filosofia de engenharia do FDB-Core.
* **O que contém:**
  * As 5 regras inegociáveis do projeto (ex: Design Autoritativo do Servidor, queries assíncronas obrigatórias no MySQL).
  * Padrões de nomenclatura (ex: `FDB:<Module>:<Action>`).
  * A estrutura de pastas e o modelo de contribuição.
* **Propósito:** É a **Lei** do projeto. Define *como as coisas DEVEM ser feitas* daqui pra frente. O Claude deve focar aqui ao criar scripts novos do zero.

### 2. [Relatório de Inspeção e Segurança (AUDIT.md)](./AUDIT.md)
* **O que é:** Uma matriz de segurança tática, focada inicialmente nos Eventos de Rede (NetEvents) do Core.
* **O que contém:**
  * Auditoria linha a linha dos eventos mais críticos.
  * Tabela de status mostrando vulnerabilidades mitigadas (impedindo clientes de injetar itens, dinheiro ou metadados de forma maliciosa).
  * Roadmap para a auditoria contínua de recursos externos (Inventário, Banco, etc.).
* **Propósito:** É a **Polícia** do projeto. Define *o que foi verificado e é considerado seguro*. Age como prova de que a fundação de rede não possui backdoors antigos.

### 3. [Diário de Bordo e Histórico (MODIFICATIONS.md)](./MODIFICATIONS.md)
* **O que é:** O registro contínuo (changelog) que detalha todas as diferenças práticas entre o FDB-Core e o RSG-Core original.
* **O que contém:**
  * O status de execução das Fases do projeto (desde a Segurança Básica até Otimizações de Banco e StateBags).
  * Detalhamento técnico de como problemas complexos foram resolvidos (ex: Runner de Migração de DB, Lock Coalescente de I/O em salvamentos, Whitelist de metadados).
* **Propósito:** É o **Cartório** do projeto. Define *o que já FOI feito na prática*, sendo a fonte da verdade sobre quais otimizações estão ativas no código-fonte. O Claude deve ler isso para não desfazer ou sobrescrever proteções que já injetamos.

### 4. [Status Recente do Projeto (PROJECT_STATUS.md)](./PROJECT_STATUS.md)
* **O que é:** Um resumo atualizado focado nas mais recentes adequações do ecossistema e dos scripts companheiros (`fdb-multicharacter`, `fdb-spawn`, `fdb-horses`).
* **O que contém:**
  * O plano de rebranding, a receita do txAdmin e os desafios resolvidos durante a migração (como o "Incidente dos Arquivos Binários" que afetou interfaces NUI e fontes).
  * Os próximos passos para testes in-game.
* **Propósito:** É um **Snapshot/Fotografia** atual. Excelente para contextualizar novos desenvolvedores (ou IAs como o Claude) sobre em que pé o servidor se encontra no momento exato de hoje.

### 5. [Plano de Migração de Ecossistema (PLANO_MIGRACAO.md)](./PLANO_MIGRACAO.md)
* **O que é:** O roteiro exato de integração do ecossistema médico/customizado para dentro da base FDB-System.
* **O que contém:**
  * Diagnóstico completo de recursos (fdb-medic, fdb-survival, fdb-consume, etc).
  * Cronograma dividido em Fases de substituição e testes.
* **Propósito:** É o **Mapa da Mina** que o Claude deverá seguir rigorosamente na próxima etapa para importar os módulos customizados para o novo namespace `fdb-core` sem quebrar o que já estabilizamos.
