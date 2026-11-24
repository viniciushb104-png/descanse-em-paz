# Menu v1.2.4 — Logo proporcional no canto superior esquerdo

A imagem de referencia enviada em 23/11/2026 mostrou que o logo oficial estava cobrindo personagens e interferindo na leitura dos botoes. A correcao preserva o PNG RGBA e sua animacao pendurada, mas limita o tamanho visual a 312 unidades de largura no menu de 1152 x 648 (aprox. 27% da largura), com altura calculada pela proporcao real da textura e posicao (20, 6).

O TextureRect usa `STRETCH_SCALE`, para obedecer as dimensoes definidas pelo layout e impedir a apresentacao em tamanho nativo. O pivô continua no topo da placa, com oscilacao senoidal de apenas 1,5 grau. A frase humorada fica abaixo, em (30,190), sem disputar o espaco com os botoes a direita.

As fachadas, personagens, fundo e demais scripts permanecem sem alteracao. A smoke test impede o retorno de logos com mais de 340 unidades, fora do canto ou ultrapassando a regiao superior reservada. Em celular horizontal, o escalonamento de 1152x648 e mantido pelo projeto.
