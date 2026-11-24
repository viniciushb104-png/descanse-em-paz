extends Node2D
## Objetos reais extraidos do atlas da oficina, como PNGs separados.
## Balcao e NPCs acessiveis; detalhes sem colisao escondida.
const PROPS = [
    {"id":"Vitral","texture":preload("res://assets/interiors/maintenance/window.png"),"position":Vector2(559,151),"scale":1.46},
    {"id":"PainelFerramentas","texture":preload("res://assets/interiors/maintenance/toolrack.png"),"position":Vector2(72,215),"scale":1.43},
    {"id":"Prateleiras","texture":preload("res://assets/interiors/maintenance/shelves.png"),"position":Vector2(920,185),"scale":1.26},
    {"id":"Bancada","texture":preload("res://assets/interiors/maintenance/workbench.png"),"position":Vector2(421,356),"scale":1.55},
    {"id":"Carrinho","texture":preload("res://assets/interiors/maintenance/wheelbarrow.png"),"position":Vector2(753,451),"scale":1.37},
    {"id":"Porta","texture":preload("res://assets/interiors/maintenance/door.png"),"position":Vector2(528,468),"scale":1.55}
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
