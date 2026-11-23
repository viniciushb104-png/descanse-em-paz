# Lote 2 - Arvores goticas autorais (primeira integracao)

Direcao visual: gótico lúdico e artesanal, formas assimétricas e retorcidas, copas lilás, raízes expressivas. A jogabilidade mantém leitura e interface inspiradas em simuladores de vida, sem replicar sua identidade visual.

## O que entrou na versão 0.7
Quatro PNGs isolados, oriundos das imagens originais aprovadas no chat, otimizados para a Web com transparência e paleta reduzida: `Arvore_01.png`, `Arvore_02.png`, `Arvore_06.png`, `Arvore_10.png`. Os PNGs originais em alta qualidade permanecem preservados no pacote de criação, para eventual refino das texturas.

As novas árvores substituem as três árvores genéricas do atlas antigo (a quarta cria diversidade). Posicionamento e colisão mínima de tronco definidos exclusivamente em `scripts/world/trees_layout.gd`. O script `trees_layer.gd` carrega os PNGs numa camada atrás dos edifícios; nenhuma copa funciona como barreira invisível.

## Próximos passos
Revisar visualmente escala e ocupação em navegador, ajustar colisões de tronco se necessário, então adicionar outras árvores (03, 04, 05, 07, 08 e 09). Preservar todos os personagens, covas, túmulos e sistemas do jogo. Não substituir outras artes sem aprovação específica.
