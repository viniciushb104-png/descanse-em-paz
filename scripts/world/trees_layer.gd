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

func _process(_delta: float) -> void:
    if not visible:
        return
    var foot: Vector2 = get_parent().get_node("Player").global_position
    for item in TREE_DATA.ITEMS:
        var sprite: Sprite2D = get_node(str(item["id"]))
        var hit: Rect2 = item["hit"]
        sprite.z_as_relative = false
        sprite.z_index = 18 if foot.y<=hit.end.y else -5
