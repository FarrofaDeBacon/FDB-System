# FDB-LIBS (Documentação e Auditoria Técnica)

Este repositório contém a biblioteca central de UI (`fdb-libs`) projetada para o ecossistema RedM (FDB-System). O objetivo principal é fornecer componentes de UI altamente performáticos, reutilizáveis e nativamente integrados à estética rústica (estilo Red Dead Redemption 2).

## Arquitetura Base
- **Backend/Ponte LUA:** Fornece as exports globais (`fdb.menu.open`, `fdb.menu.close`) e gerencia os callbacks do NUI.
- **Frontend Svelte + Vite:** A interface gráfica foi construída inteiramente utilizando o framework Svelte compilado através do Vite.

## Histórico de Problemas Críticos e Resoluções (Auditoria)

Durante o desenvolvimento do frontend Svelte para o NUI do FiveM/RedM, enfrentamos e superamos as seguintes barreiras técnicas:

### 1. Bloqueio de Segurança (CORS) no CEF do FiveM
**O Problema:** O Vite compila scripts JS utilizando `<script type="module" crossorigin>`. O navegador embutido do FiveM (CEF) trata o protocolo local `nui://` com políticas estritas de segurança. A presença da tag `crossorigin` fazia com que o Chromium bloqueasse a execução do script instantaneamente (resultando em uma tela preta vazia).
**A Solução:** Foi necessário intervir no processo de build e no arquivo `index.html` para remover manualmente a tag `crossorigin`, permitindo que o `nui://` executasse o módulo JS sem esbarrar no bloqueio do CORS.

### 2. Cache Agressivo do NUI (FiveM)
**O Problema:** Ao rebuildar o projeto Svelte na pasta padrão `dist/`, o NUI do FiveM cacheava ferozmente a rota `ui/dist/index.html`. Comandos como `restart fdb-libs` não eram suficientes para forçar os clientes a baixarem a nova versão da UI, mantendo interfaces antigas na tela.
**A Solução:** Modificamos o `vite.config.js` para compilar o código de saída para a pasta `build/` (ao invés de `dist`). Atualizamos o `fxmanifest.lua` para apontar para `ui/build/index.html`. A mudança na URL forçou a quebra permanente do cache antigo.

### 3. Integração de Texturas Rústicas (Aesthetic RDR2)
O visual padrão de "app moderno" foi substituído por uma imersão completa:
- Fundos de pergaminho/papel envelhecido (`background.png`).
- Divisórias texturizadas para Sliders e ColorGrids (`tank_meter_marker`, `swatch_box`).
- Ocultação de elementos Unicode (ex: `✓`, `<`) e substituição direta por assets extraídos via CSS (`tick.png`, setas estilizadas).

## Próximos Passos (Foco Contínuo no FDB-LIBS)
Antes de integrarmos esta biblioteca em outros scripts (como o `fdb-appearance`), o objetivo atual é:
1. **Polimento Visual:** Ajustar preenchimentos, bordas marginais de texturas e proporções dos elementos Svelte (Menu, Sliders e Checkboxes) para que o encaixe não pareça deslocado ou "esticado".
2. **Re-build Final:** Após o polimento, todo o CSS será re-compilado via Vite e sincronizado com o servidor.

*Nota para Claude/IA Assistente: Todas as alterações visuais devem ser focadas exclusivamente nos arquivos em `fdb-libs/ui/src/components/*.svelte` e passadas pelo processo de build via `npm run build` na pasta `ui`.*
