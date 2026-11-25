extends RefCounted
## Lote 1 — mapa exclusivo das 10 covas/tumulos.
## Um arquivo PNG verdadeiro por sprite; nada de atlas recortado.
## As posicoes sao o CANTO SUPERIOR ESQUERDO no mundo de 1536x960.
## A colisao usa o pe da lapide, ou a superficie da cova.
const ITEMS = [
    {"id":"Tumulo_01", "texture":preload("res://assets/props/tumulos/Tumulo_01.png"), "pos":Vector2(879,397), "scale":0.82, "hit":Rect2(894,470,48,22)},
    {"id":"Tumulo_02", "texture":preload("res://assets/props/tumulos/Tumulo_02.png"), "pos":Vector2(966,397), "scale":0.82, "hit":Rect2(981,470,48,22)},
    {"id":"Tumulo_03", "texture":preload("res://assets/props/tumulos/Tumulo_03.png"), "pos":Vector2(1053,397), "scale":0.82, "hit":Rect2(1068,470,48,22)},
    {"id":"Tumulo_04", "texture":preload("res://assets/props/tumulos/Tumulo_04.png"), "pos":Vector2(1140,397), "scale":0.82, "hit":Rect2(1155,470,48,22)},
    {"id":"Tumulo_05", "texture":preload("res://assets/props/tumulos/Tumulo_05.png"), "pos":Vector2(970,651), "scale":0.80, "hit":Rect2(990,724,62,24)},
    {"id":"Tumulo_06", "texture":preload("res://assets/props/tumulos/Tumulo_06.png"), "pos":Vector2(970,768), "scale":0.80, "hit":Rect2(990,841,62,24)},
    {"id":"Cova_01", "texture":preload("res://assets/props/covas/Cova_01.png"), "pos":Vector2(1093,651), "scale":1.00, "hit":Rect2(1105,668,72,73), "slot":"B-13"},
    {"id":"Cova_02", "texture":preload("res://assets/props/covas/Cova_02.png"), "pos":Vector2(1209,651), "scale":1.00, "hit":Rect2(1221,668,72,73)},
    {"id":"Cova_03", "texture":preload("res://assets/props/covas/Cova_03.png"), "pos":Vector2(1093,768), "scale":1.00, "hit":Rect2(1105,784,72,74)},
    {"id":"Cova_04", "texture":preload("res://assets/props/covas/Cova_04.png"), "pos":Vector2(1209,768), "scale":1.00, "hit":Rect2(1221,784,72,74)}
]

static func is_blocked(world_position: Vector2) -> bool:
    for item in ITEMS:
        var region: Rect2 = item["hit"]
        if region.has_point(world_position):
            return true
    return false

static func item_by_id(identifier: String) -> Dictionary:
    for item in ITEMS:
        if str(item["id"]) == identifier:
            return item
    return {}
