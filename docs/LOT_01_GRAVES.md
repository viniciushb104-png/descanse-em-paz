# Lote 1 — Covas e tumulos: 10 PNGs individuais

A integracao usa **arquivos PNG individuais com alpha**, diretamente em uma camada propria `GravesLayer` da Godot, sem recortar o atlas anterior. As artes sao copias otimizadas de 32 cores para Web, preservando a perspectiva e o tamanho de cada imagem; os originais estao no pacote de artes disponibilizado no chat.

## Cadastro e mapeamento
A lista de itens, coordenadas, escalas e hitboxes fica em `scripts/world/graves_layout.gd`; cada arquivo esta em `assets/props/covas/` ou `assets/props/tumulos/`. A camada que carrega os sprites e `scripts/world/graves_layer.gd`.

## Itens
| ID | Uso | Observacao |
|---|---|---|
| Cova_01 | Cova aberta | Identifica o jazigo B-13; contorno e rótulo dinamicos |
| Cova_02 | Cova com terra ao lado | Area de sepultamento |
| Cova_03 | Cova parcialmente preenchida | Area de sepultamento |
| Cova_04 | Terra de cova fechada | Area de sepultamento |
| Tumulo_01 | Lapide arqueada simples | Quadra principal |
| Tumulo_02 | Lapide com cruz | Quadra principal |
| Tumulo_03 | Lapide gotica | Quadra principal |
| Tumulo_04 | Lapide envelhecida | Quadra principal |
| Tumulo_05 | Monumento funerario | Setor inferior |
| Tumulo_06 | Lapide com flores | Setor inferior |

## Regras de producão
- Sempre **um objeto por arquivo**, com fundo transparente.
- O desenho inteiro deve caber no PNG; evitar recortes de uma prancha decorativa.
- A origem da imagem e o canto superior esquerdo; coordenadas dos itens nao sao geradas aleatoriamente.
- Hitboxes nao sao a dimensao visual completa: sepulturas bloqueiam a superficie e lapides bloqueiam apenas a base.
- A missão e a economia de B-13 continuam ligadas ao mesmo ponto (1125, 630).
- Na expansao do mapa, editar apenas `graves_layout.gd`, nunca alterar os PNGs para mudar posicao.
