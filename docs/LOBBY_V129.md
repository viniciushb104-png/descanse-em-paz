# Lobby 1.2.9 — Jardim do Ultimo Suspiro

## Objetivo
Melhorar visualmente o patio principal, ponto de encontro entre o jogador,
Seu Osvaldo, Baltazar, gato e as rotas do cemiterio. Atmosfera gotica fofa 16-bit.
Nao modificar as fachadas aprovadas do escritorio ou do galpao de manutencao.

## Implementacao
- Nova camada LobbyBeauty, entre o piso e as fachadas, com geometria ornamental.
- Rotunda octogonal com rosa dos ventos e ampulheta, em frente a Osvaldo.
- Frisos nos caminhos, canteiros floridos e placas de direcao.
- Luzes amarelo-ambar animadas nas quatro lanternas preexistentes.
- Vaga-lumes de baixa intensidade, mais visiveis ao cair da tarde.
- Atualizacao da camada a cada 0,14 s (~7 FPS); sem recalcular o mapa.
- Tudo decorativo: nenhuma colisao, menu ou requisito de gameplay adicional.
- O interior esconde LobbyBeauty ao entrar e restaura ao sair.

## Pontos preservados
- Spawn (748,714), NPCs, jazigo B-13, gato, portoes e acessos do distrito.
- Fila de sepultamento, 20 casos, salvares antigos e minigames existentes.
- Compatibilidade com controle touch e camera do Godot 4.7.2.

## Validacao
Teste headless: tests/lobby_smoke.gd
Revisao visual ainda necessaria no navegador e em um celular de verdade.
Futuros lotes: PNGs individuais transparentes para placas, canteiros e vitrais;
revisao do HUD sem sobrepor joystick ou escolhas.
