# Direcao artistica — Jardim do Ultimo Suspiro

Referencia: concept pixel art do cemiterio Santa Mortalha e sprites criados em novembro de 2026. Esta entrega adapta a composicao para **componentes SVG independentes**, posicionados no mapa em `scripts/map_art.gd`.

## Posicoes e mapa
- Terreno modular de 64 x 64; caminhos em lajes roxas.
- Capela administrativa: (204,120), tamanho 485x344; acesso na frente, interacao (430,490).
- Quadra B: seis jazigos por fileira em tres fileiras; o B-13 usa sprite realcado e interacao proxima a (1110,365).
- Oficina: (1116,628) tamanho 324x225; interacao na porta (1255,870).
- Portao principal: (650,792), tamanho 250x171.
- Seu Osvaldo: (725,670); Baltazar: (365,560).
- Fonte, estatua de anjo, dois jazigos familiares, arvores lilases, postes e aboboras.

## Resolucao e performance
Godot 4.7.2, viewport 1152x648, mundo 1536x960, arte 2D sem iluminacao fisica. SVGs separados para substituicao futura por PNGs pixel art de alta fidelidade; renderizacao GL Compatibility para navegador.

## Animacao
Protagonista com 4 direcoes x 2 frames de caminhada; Seu Osvaldo e Baltazar com 4 direcoes x 2 frames estruturados em assets. O mapa usa poses frontais dos NPCs nesta versao; as animacoes completas ficarao para as proximas etapas.

## Regras narrativas
Comedia com burocracia e personagens, nunca com a dor das familias. Valores do jogo sao ficticios e regras profissionais requerem validacao especifica.
