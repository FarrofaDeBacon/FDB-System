# FDB System - Catálogo do Ecossistema (Framework)

Este documento descreve o propósito de cada um dos scripts que compõem o ecossistema `fdb-*` (Framework FDB), permitindo entender como eles se interligam e a função de cada um na engrenagem do servidor.

## 🛠️ Núcleo e Bibliotecas Base
- **fdb-core**: O coração do servidor (antigo rsg-core). Gerencia o banco de dados (jogadores), funções globais, criação de itens, callbacks, pagamentos, permissões e sincronização básica de estado.
- **fdb-libs**: Biblioteca de funções e utilitários que vários outros scripts do ecossistema importam e usam nos bastidores.
- **fdb-configui**: Motor responsável por lidar com o KVP (armazenamento local) do cliente, salvando preferências e interfaces de configurações do jogador (ex: configurações da HUD).

## 👤 Personagem e Identidade
- **fdb-multicharacter**: A tela de seleção de personagem (lobby). Carrega os dados dos slots do jogador e exibe antes de entrar na cidade.
- **fdb-creator**: Interface de criação do personagem. Define rosto, corpo, voz, maquiagem na primeira vez que um personagem nasce. Substitui o obsoleto `fdb-appearance`.
- **fdb-spawn**: O mapa que aparece logo após escolher/criar o personagem, permitindo escolher em qual cidade (ou última localização) você vai "acordar".
- **fdb-clothing / fdb-wardrobe**: Lida com todas as roupas. Compra em lojas, sistema de guarda-roupa para salvar trajes (outfits) e troca rápida.
- **fdb-barbers**: Sistema das barbearias para modificar cabelo, barba e dentes de um personagem já criado.

## 🎒 Itens, Inventário e Consumo
- **fdb-inventory**: Sistema central do servidor (Apertar B / I). Lida com o inventário visual, slots, peso, baús, drops no chão, porta-luvas (ou alforjes), stashes e atalhos rápidos.
- **fdb-backpacks**: Expande a capacidade do inventário. Adiciona o item físico "mochila" que, ao ser equipada, dá mais espaço de peso/slots para o jogador.
- **fdb-consume**: Sistema vital de ingestão de comidas, bebidas e uso de itens diversos. Gerencia as animações ao dar uma mordida ou beber água de cantis e garrafas.

## ❤️ Saúde, Sobrevivência e Médicos
- **fdb-survival**: Controla as necessidades humanas. Sede, fome, estresse e higiene. Envia esses dados atualizados para a HUD constantemente e penaliza o jogador (dano aos cores) se ele não se cuidar.
- **fdb-water**: Interações com o mundo para necessidades de sobrevivência. Permite beber e se banhar em rios ou bombas d'água mecânicas nas cidades, linkando o ganho de atributos direto ao `fdb-survival`.
- **fdb-hudpremium**: A interface visual na tela (cores) que exibe as argolas e corações (vida, stamina, olho, saúde do cavalo, dinheiro no bolso e a bússola).
- **fdb-medical-core**: A "verdade absoluta" do corpo humano. Uma super API que intercepta danos tomados no jogo (tiros, quedas, socos), calcula ossos quebrados e cortes, e serve de base para todo o dano.
- **fdb-medic**: A profissão e o roleplay de medicina. Lida com a maca, reanimação (revive), itens hospitalares (bandagens, torniquetes, remédios), NPCs doutores e macas.

## 🐎 Animais e Montarias
- **fdb-horses**: Sistema massivo de cavalos. Comprar cavalo, encilhar, escovar, alimentar (recuperar núcleos na HUD) e assobiar para ele vir até você.
- **fdb-fishing**: Sistema de pescaria (vara, iscas, fisgar peixes e minigame na água).

## 🔫 Armas, Crime e Lei
- **fdb-weapons / fdb-weaponcomp / fdb-ammo**: Trilogia de scripts que gerenciam o uso de revólveres e rifles, seus componentes (miras, canos longos, enfeites) e o tipo de munição que cada arma exige.
- **fdb-lawman**: O trabalho do xerife. Permite algemar, arrastar (escort), colocar em veículos, revistar inventários e assumir serviço (on-duty).
- **fdb-prison**: Controle de jogadores encarcerados, tempo de pena, afazeres na prisão e liberação quando o tempo acaba.
- **fdb-mdt**: Tablet/Terminal (MDT) para os policiais registrarem Boletins de Ocorrência, adicionarem procurados (warrants) e verem o histórico criminal dos cidadãos.
- **fdb-lockpick**: O minigame (tipo "gazua") para arrombar portas trancadas, cofres ou carruagens.

## 💰 Economia, Trabalhos e Lojas
- **fdb-banking**: Caixas eletrônicos (ou telégrafos) e agências bancárias. Permite sacar, depositar e transferir dólares/ouro entre contas de jogadores.
- **fdb-shops**: Sistema de lojas espalhadas pelo mapa (Açougue, Armeiro, Mercearia). Baseado em NPCs onde você abre um menu de compra e venda de produtos.
- **fdb-multijob**: Sistema que permite que um jogador tenha mais de uma profissão (Job) salva, podendo alternar entre elas (ex: Policial à tarde e Lenhador de noite).
- **fdb-bossmenu / fdb-gangmenu**: Menus de chefia para donos de facções ou negócios. Permitem ao líder contratar/demitir membros, pagar bônus e sacar dinheiro do "cofre" da empresa (society money).

## 🧭 Interface e Interações Extra
- **fdb-radialmenu**: O menu em formato de pizza (anel circular) que se abre geralmente ao segurar Z ou F1, oferecendo ações rápidas como "Dar roupas", "Emotes", "Caminhar", etc.
- **fdb-target**: Sistema do tipo "olho de águia" onde você segura uma tecla (Alt) e olha para NPCs ou objetos no mundo para interagir diretamente com eles num menu.
- **fdb-telegram**: Os correios da época. Os jogadores enviam mensagens de texto uns para os outros indo num correio, funcionando de forma assíncrona (mesmo se o alvo estiver offline).
- **fdb-animations**: Biblioteca de centenas de animações em formato de comando ou menu (dançar, cruzar os braços, sentar no chão).
- **fdb-playerinfo**: O Scoreboard (Placar) que ao segurar um botão lista quem está conectado no servidor, qual seu ping e o ID, além da contagem de quantos policiais e médicos estão em serviço.
- **fdb-menubase**: Apenas uma base/framework UI (invisível pro jogador) que os desenvolvedores usam para criar e desenhar aqueles menus verticais no canto direito da tela de forma rápida (Antigo rsg-menu/qb-menu).
- **fdb-npcs**: Script de preenchimento do mundo (povoamento). Adiciona modelos estáticos de pedestres ou seguranças em cantos das cidades para dar vida e preencher cenários, com os quais o `fdb-target` pode interagir.
- **fdb-adminmenu**: Uma "mão invisível" para o Dono do Servidor. Permite voar (noclip), spawnar dinheiro, curar players, congelar arruaceiros, banir e mudar o clima.

---
> **Nota:** Scripts obsoletos como `fdb-canteen`, `fdb-bathing`, `fdb-essentials`, e o `fdb-appearance` original foram removidos do repositório/receita para evitar conflitos com os novos sistemas, ou por terem sido substituídos de forma nativa por scripts modulares (como a nova integração `fdb-water` + `fdb-survival`).
