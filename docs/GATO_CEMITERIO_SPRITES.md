# Gato do Cemitério — integração dos sprites

## Estado
O NPC já existe em `scripts/world/cemetery_cat.gd`, aparece no mapa externo, anda em área segura, mia ao interagir e permite carinho pelo comando E/botão Interagir. A rotina de animações foi adicionada ao script.

## Instalação dos PNGs
Copiar a pasta `assets/cat/` do pacote `gato_santa_mortalha_sprites.zip` para a raiz do repositório, mantendo os nomes. São 43 PNGs 112x112 com transparência e apoio consistente, organizados em: `idle` (4), `sit` (5), `walk_right` (8), `walk_left` (8), `meow` (4), `pet` (6), `purr` (4), `sleep` (4).

Se os PNGs ainda não estiverem instalados, o gato continua aparecendo com arte provisória procedural; o jogo não deve quebrar. A lógica do jogo **não** altera dinheiro, missão, estoque ou reputação.

## Estados
- Idle: parado, antes de repousar
- Walk: esquerda/direita conforme deslocamento
- Sit: parado por mais de 6 segundos
- Sleep: parado por mais de 16 segundos
- Meow: quando interagir
- Pet: após escolher 'Fazer carinho'
- Purr: último trecho do carinho

## Validação após instalar
Executar a Godot e confirmar se os 43 quadros estão importados, sem partes cortadas e com filtragem nearest. Verificar as ações no mouse/teclado e no toque, aproximação do gato, portas, salvamento e colisões. Não substitua as fachadas, as cenas do mapa nem o menu.

Os PNGs do pacote são separados da folha autoral, que tem dimensões irregulares por personagem; não usar um atlas com grid uniforme diretamente.
