extends Node2D
## Chao nao-animado: camada fixa, desenhada apenas quando necessario.
const TILES = preload("res://scripts/world/ground_tiles.gd")

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    TILES.paint(self)
