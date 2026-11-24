extends Node2D
## Os PNGs abaixo vieram do kit gótico aprovado; nao redesenhar fachadas.
## Cada movel e um Sprite2D com textura, posicao e escala individuais.
const PROPS = [
    {"id":"Tapete","texture":preload("res://assets/interiors/office/rug.png"),"position":Vector2(466,504),"scale":1.50},
    {"id":"Vitral","texture":preload("res://assets/interiors/office/window.png"),"position":Vector2(565,151),"scale":1.45},
    {"id":"Estante","texture":preload("res://assets/interiors/office/bookshelf.png"),"position":Vector2(72,318),"scale":1.42},
    {"id":"Arquivo","texture":preload("res://assets/interiors/office/cabinet.png"),"position":Vector2(1004,393),"scale":1.18},
    {"id":"Mesa","texture":preload("res://assets/interiors/office/desk.png"),"position":Vector2(421,349),"scale":1.46},
    {"id":"Porta","texture":preload("res://assets/interiors/office/door.png"),"position":Vector2(528,465),"scale":1.55}
]
func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for item in PROPS:
        var sprite := Sprite2D.new()
        sprite.name = str(item["id"])
        sprite.texture = item["texture"]
        sprite.position = item["position"]
        sprite.scale = Vector2.ONE * float(item["scale"])
        sprite.centered = false
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(sprite)
