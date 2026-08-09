# Auditoria Técnica e Plano de Fusão: mega_doctorjob vs Ecossistema FDB (STEEL)

Este documento é o resultado de uma auditoria comparativa entre o antigo script **mega_doctorjob** e o robusto ecossistema já existente na base STEEL, composto pelo **fdb-medic** e **fdb-medical-core**.

O objetivo é mapear o que o `mega_doctorjob` tem a oferecer e planejar como extrair suas melhores funcionalidades para integrá-las nativamente à sua arquitetura avançada.

---

## 1. O Abismo Tecnológico (Análise de Arquitetura)

Após analisar a fundo os recursos em `D:\STEEL\Server\resources\[framework]`, fica claro que o seu sistema atual (**fdb-medic**) é vastamente superior ao `mega_doctorjob` original.

* **O seu ecossistema (STEEL):** Possui uma separação de responsabilidades profissional. O `fdb-medical-core` age como a *Fonte Única de Verdade Fisiológica*, gerenciando feridas, infecções, sangramentos e efeitos de ossos quebrados de forma autoritativa. O `fdb-medic` cuida da interface (Svelte), missões e itens.
* **O mega_doctorjob:** É um script monolítico (tudo misturado). Ele gerencia doenças localmente (`activeDiseases`), usa callbacks antigos e depende do cliente para calcular dano bruto (`SetEntityHealth`).

---

## 2. O que o mega_doctorjob tem de bom? (Features a Migrar)

Apesar de ser tecnicamente inferior, o `mega_doctorjob` possui lógicas e "features de Qualidade de Vida" (QoL) muito interessantes que valem a pena ser migradas para o seu `fdb-medic`:

### A. Central de Despacho Dinâmica e Raio de Busca (`/alertdoctor`)
- **O que faz:** Ao acionar `/alertdoctor`, o script localiza os médicos online e emite um Blip temporário com **raio de distância** (não exato), incentivando a busca, e permite aos médicos usar `/respond` e `/clearAlerts`.
- **Como integrar:** Podemos migrar essa lógica de "Blips Temporários de Área" e comandos de `/respond` direto para o `fdb-medic/server/medical_server.lua`.

### B. Autoatendimento NPC via Custo Monetário
- **O que faz:** Nas clínicas, se não houver médicos na cidade, NPCs (`ped_hospital_doc`) assumem o balcão. O jogador paga `$50` e é curado na hora. Se houver médico real, o NPC recusa atendimento.
- **Como integrar:** Isso seria excelente no `fdb-medic`. O script já monitora os jobs, basta adicionar a lógica de criação estática de NPCs e o menu de cobrança interligado ao `fdb-medical-core:server:ApplyTreatment`.

### C. Mapeamento SVG Direto na NUI
- **O que faz:** A NUI dele usa um SVG de corpo humano, pintando de vermelho (`fill="red" opacity="0.8"`) as exatas *Bones* (ossos) machucadas.
- **Como integrar:** O `fdb-medic` já usa Svelte, então é possível portar o SVG do `mega_doctorjob` para a interface do `fdb-medic` para deixar o `/inspect` ainda mais visceral visualmente.

---

## 3. O Plano Tático de Descarte e Fusão

Não usaremos NENHUM arquivo bruto do `mega_doctorjob`. O script em si pode ser descartado. Em vez disso, faremos **Transplantes Lógicos**:

1. **Rejeitar o Sistema de Dano:** Ignoraremos todo o código de `gameEventTriggered` do mega_doctorjob, pois o seu `fdb-medical-core:server:wounds` já faz isso com maestria.
2. **Absorver os Comandos de Despacho:** Criaremos um módulo leve dentro do `fdb-medic` para gerenciar chamados de emergência (`/alertdoctor`), lendo a rota de profissões nativa do seu core.
3. **Absorver os NPCs de Clínica:** Utilizaremos o sistema de NPCs (como `ox_target` ou Prompts) para instanciar os médicos de IA quando o turno estiver vazio.
4. **Respeito ao `medical-core`:** Toda cura que migrarmos passará obrigatoriamente pelos `exports['fdb-medical-core']`, garantindo que o núcleo não perca o controle fisiológico.
