extends Control
## Lápide ou caixão horizontal desenhado atrás de um Button real.
## Mouse, teclado e toque são tratados pelo Button do menu.

@export_enum("Lápide", "Caixão") var shape_kind: int = 0:
    set(value):
        shape_kind = value
        queue_redraw()

var highlighted: bool = false:
    set(value):
        highlighted = value
        queue_redraw()

var disabled_visual: bool = false:
    set(value):
        disabled_visual = value
        queue_redraw()

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
    if size.x < 20.0 or size.y < 20.0:
        return
    var w: float = size.x
    var h: float = size.y
    var silhouette: PackedVector2Array
    if shape_kind == 1:
        # Caixão horizontal: cabeceira inclinada e laterais afuniladas.
        silhouette = PackedVector2Array([
            Vector2(14, 3), Vector2(w - 14, 3),
            Vector2(w - 3, 21), Vector2(w - 8, h - 4),
            Vector2(8, h - 4), Vector2(3, 21)
        ])
    else:
        # Lápide de pedra com topo arqueado.
        silhouette = PackedVector2Array([
            Vector2(6, h - 4), Vector2(6, 28),
            Vector2(12, 14), Vector2(33, 4),
            Vector2(w - 33, 4), Vector2(w - 12, 14),
            Vector2(w - 6, 28), Vector2(w - 6, h - 4)
        ])

    var shadow := PackedVector2Array()
    for p in silhouette:
        shadow.append(p + Vector2(2, 5))
    draw_colored_polygon(shadow, Color(0.05, 0.025, 0.08, 0.55))

    var fill_color := Color("#59372d") if shape_kind == 1 else Color("#3b3343")
    var edge_color := Color("#e6b875") if highlighted else Color("#b79b83")
    if disabled_visual:
        fill_color = Color("#29252e")
        edge_color = Color("#665e68")
    draw_colored_polygon(silhouette, fill_color)
    var closed := silhouette.duplicate()
    closed.append(silhouette[0])
    if highlighted and not disabled_visual:
        draw_polyline(closed, Color(0.98, 0.78, 0.45, 0.24), 7.0, false)
    draw_polyline(closed, edge_color, 3.0, false)
    draw_line(Vector2(19, h - 14), Vector2(w - 19, h - 14), edge_color.darkened(0.38), 1.0, false)
    draw_circle(Vector2(18, h * 0.5), 2.0, edge_color)
    draw_circle(Vector2(w - 18, h * 0.5), 2.0, edge_color)
    if highlighted and not disabled_visual:
        draw_circle(Vector2(w - 28, 15), 3.0, Color("#fff0b7"))
