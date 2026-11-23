extends Node2D
## Grupo independente das arvores: nenhum PNG e recortado de atlas.
const TREE_DATA = preload("res://scripts/world/trees_layout.gd")

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for item in TREE_DATA.ITEMS:
        var sprite := Sprite2D.new()
        sprite.name = str(item["id"])
        sprite.texture = item["texture"]
        sprite.centered = false
        sprite.position = item["pos"]
        var bounds: Vector2 = item["size"]
        var source_size: Vector2 = sprite.texture.get_size()
        sprite.scale = Vector2(bounds.x / source_size.x, bounds.y / source_size.y)
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(sprite)
