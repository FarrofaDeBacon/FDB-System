# Documentação: Spawn de Props no Node Engine

O Node Engine possui dois modos distintos para o spawn de props e objetos durante a execução de um assalto (Heist). A arquitetura é inteligente e define automaticamente qual modo usar com base na presença de coordenadas absolutas salvas no banco de dados.

## 1. Modo Absoluto (Via Editor Visual)

Quando um assalto é criado ou editado pela ferramenta visual (`/editillegal`):
- O desenvolvedor adiciona um "Spawn Prop" e utiliza o botão **"Setar no Mundo" (Ferramenta 3D)**.
- O editor captura e salva as coordenadas `x, y, z` e a rotação absoluta (`heading` / `pitch` / `roll`) do local exato escolhido.
- **Comportamento em Jogo:** Ao rodar este nó, o sistema percebe que existem coordenadas definidas (`spawnCoords`) e entra no **Modo Absoluto**. O prop irá spawnar *exatamente* no mesmo local fixo do mundo definido no editor, ignorando a posição do jogador ou qualquer objeto com que ele tenha interagido.

## 2. Modo Fallback Relacional (Ex: Roubo de Túmulos)

Para assaltos criados dinamicamente ou sem uso de posição absoluta (como o roubo de túmulos gerado via script/banco de dados manual):
- O JSON gerado *não possui* as coordenadas absolutas (vetor de spawn vazio).
- **Comportamento em Jogo:** Ao rodar este nó e notar a ausência de coordenadas fixas, o sistema ativa o **Modo Fallback Relacional**.
- **Matemática do Offset:** 
  - O sistema captura a entidade alvo (ex: a lápide interagida), suas coordenadas e a sua **rotação (heading)**.
  - Ele calcula um vetor direcional frontal a partir desse *heading* (usando a fórmula `-math.sin(rad), math.cos(rad)`).
  - O prop (ex: monte de terra) nasce respeitando a orientação frontal da lápide, independentemente da direção cardinal no mapa mundial.
  - O Z (altura) é fixado corretamente utilizando `GetGroundZFor_3dCoord` sobre a nova coordenada projetada, impedindo que o objeto fique flutuando ou invisível debaixo da terra.

---

### Extensão Futura

Atualmente, o editor 3D sempre salva as posições em formato Absoluto. Se no futuro houver necessidade de desenhar offsets pelo editor visual (ex: fazer com que uma caixa spawne a "2 metros na frente do cofre", não importando onde o cofre esteja), será necessário adicionar um controle no Front-End do editor para selecionar **"Coordenada Fixa"** vs **"Offset Relativo"** e salvar o tipo de spawn no JSON. Até lá, o Fallback Relacional atende perfeitamente os sistemas dinâmicos injetados por script.
