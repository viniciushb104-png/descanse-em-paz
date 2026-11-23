extends Node2D
## Decoracao e personagens fixos, desenhados por cima do terreno.
const ART = preload("res://scripts/map_art.gd")

func _draw() -> void:
    var level: Node = get_parent()
    ART.paint(self, bool(level.get("reserved_plot")),float(level.get("clock_minutes")))
