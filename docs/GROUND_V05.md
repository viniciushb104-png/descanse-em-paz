# Lote do chao — versao 0.5

Implementacao isolada de terreno, antes de refazer capela, oficina ou personagens.

## Sistema de piso
- Mapa logico: **48 x 30** celulas de **32 x 32 pixels**, total **1536 x 960 px**.
- Tres materiais: grama musgo, terra exposta e lajes de pedra roxa com juntas desencontradas.
- Detalhes de folhas e flores pequenos, deterministas; nao repetir pedacos recortados do atlas, evitando marcas quadradas.
- Bordas somente entre materiais diferentes. Caminhos ligados ao portao, escritorio, oficina, quadra B e jardins.
- A geometria fica em `scripts/world/ground_tiles.gd`. `GroundLayer` desenha terreno uma unica vez.
- `PropsLayer` conserva os edificios, tumulos e NPCs atuais.

## Grade dos corredores
| Zona | Coordenadas tiles (x,y,w,h) |
|---|---|
| Alameda central | 22,13,4,16 |
| Cruzamento | 5,17,39,3 |
| Administracao | 12,12,4,5 |
| Oficina | 38,11,4,6 |
| Quadra B-13 | 32,19,6,3 |
| Jardins | 13,22,9,3 |
| Area oeste | 7,19,5,4 |

## Critérios de aceite
Sem emendas quadriculadas de grass, caminhos conectados por BFS, camada de chão separada dos objetos, personagem e progresso preservados. A etapa seguinte sera revisar os prédios como assets transparentes.
