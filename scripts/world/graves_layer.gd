extends Node2D
## 10 PNGs individuais, transparentes, carregados e posicionados por ID.
## Esta camada NAO redesenha edificios, caminhos ou os NPCs.
const LAYOUT = preload("res://scripts/world/graves_layout.gd")
var b13_frame: Line2D
var b13_status_label: Label
var last_reserved: bool = false
var last_buried: bool = false
var b13_final_tomb: Sprite2D

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for item in LAYOUT.ITEMS:
        var sprite := Sprite2D.new()
        sprite.name = str(item["id"])
        sprite.texture = item["texture"]
        sprite.centered = false
        sprite.position = item["pos"]
        sprite.scale = Vector2.ONE * float(item["scale"])
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(sprite)
    # O jazigo finalizado substitui visualmente a cova inicial.
    # Reutiliza uma arte ja aprovada, sem editar suas fachadas ou o mapa.
    b13_final_tomb = Sprite2D.new()
    b13_final_tomb.name = "B13SepulturaConcluida"
    b13_final_tomb.texture = preload("res://assets/props/tumulos/Tumulo_01.png")
    b13_final_tomb.centered = false
    b13_final_tomb.position = Vector2(1093, 652)
    b13_final_tomb.scale = Vector2.ONE * 0.82
    b13_final_tomb.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(b13_final_tomb)
    # Identificador B-13 e borda pertencem ao JOGO, nao ao PNG.
    b13_frame = Line2D.new()
    b13_frame.name = "B13Highlight"
    b13_frame.width = 3.0
    b13_frame.antialiased = false
    b13_frame.points = PackedVector2Array([
        Vector2(1095,655),Vector2(1185,655),
        Vector2(1185,743),Vector2(1095,743),
        Vector2(1095,655)
    ])
    add_child(b13_frame)
    b13_status_label = Label.new()
    b13_status_label.name = "B13Label"
    b13_status_label.text = "B-13"
    b13_status_label.position = Vector2(1116,623)
    b13_status_label.add_theme_font_size_override("font_size",18)
    b13_status_label.add_theme_color_override("font_color",Color("#f6ddaa"))
    b13_status_label.add_theme_color_override("font_shadow_color",Color("#17131a"))
    b13_status_label.add_theme_constant_override("shadow_offset_x",1)
    b13_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(b13_status_label)
    _update_highlight()

func _process(_delta: float) -> void:
    var level: Node = get_parent()
    var now_reserved: bool = bool(level.get("reserved_plot"))
    var now_buried: bool = bool(level.call("is_b13_buried"))
    if now_reserved != last_reserved or now_buried != last_buried:
        _update_highlight()

func _update_highlight() -> void:
    last_reserved = bool(get_parent().get("reserved_plot"))
    last_buried = bool(get_parent().call("is_b13_buried"))
    b13_frame.default_color = Color("#9bdcba") if last_buried else (Color("#f8d06c") if last_reserved else Color("#83ccd0"))
    b13_status_label.text = "B-13  CONCLUIDO" if last_buried else "B-13"
    if is_instance_valid(b13_final_tomb):
        b13_final_tomb.visible = last_buried
    var original := get_node_or_null("Cova_01") as Sprite2D
    if original != null:
        original.visible = not last_buried
