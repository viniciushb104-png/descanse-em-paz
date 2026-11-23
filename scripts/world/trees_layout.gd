extends RefCounted
## Lote 2 - quatro arvores goticas autorais, cada PNG isolado com alpha.
## pos representa o canto superior esquerdo em coordenadas do mapa (1536x960).
## hit abrange apenas o tronco e as raizes, nunca a copa inteira.
const ITEMS = [
    {"id":"Arvore_01", "texture":preload("res://assets/trees/Arvore_01.png"), "pos":Vector2(57,101), "size":Vector2(160,197), "hit":Rect2(119,280,34,17)},
    {"id":"Arvore_02", "texture":preload("res://assets/trees/Arvore_02.png"), "pos":Vector2(833,105), "size":Vector2(112,230), "hit":Rect2(874,314,30,21)},
    {"id":"Arvore_06", "texture":preload("res://assets/trees/Arvore_06.png"), "pos":Vector2(1334,682), "size":Vector2(144,190), "hit":Rect2(1390,853,33,20)},
    {"id":"Arvore_10", "texture":preload("res://assets/trees/Arvore_10.png"), "pos":Vector2(676,103), "size":Vector2(151,205), "hit":Rect2(738,288,32,19)}
]
static func is_blocked(world_position: Vector2) -> bool:
    for item in ITEMS:
        var region: Rect2 = item["hit"]
        if region.has_point(world_position):
            return true
    return false
