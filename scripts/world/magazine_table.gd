extends Node2D
## Mesa de leitura reutilizavel; os livros usam as capas existentes.
const SKIN = preload("res://scripts/ui/funeral_magazine_skin.gd")
const URN_COVER = preload("res://assets/ui/funeral_magazine/urn_cover.svg")
const INK := Color("#2b1c2d")
const GOLD := Color("#d6af72")
var coffin_cover: Texture2D

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    coffin_cover = SKIN.texture("cover")
    queue_redraw()

func _draw() -> void:
    # Madeira escura, pernas torneadas e puxador de bronze.
    draw_rect(Rect2(3,49,114,13),Color("#21192a",0.46))
    for x in [10.0,98.0]:
        draw_rect(Rect2(x,34,12,28),INK)
        draw_rect(Rect2(x+3,34,6,25),Color("#805247"))
        draw_rect(Rect2(x-2,57,16,5),Color("#4c3034"))
    draw_rect(Rect2(6,18,108,30),INK)
    draw_rect(Rect2(10,22,100,24),Color("#633d3b"))
    draw_rect(Rect2(18,27,84,14),Color("#89594a"))
    draw_rect(Rect2(18,27,84,14),Color("#be9366"),false,1)
    draw_rect(Rect2(53,31,14,3),GOLD)
    draw_rect(Rect2(0,0,120,29),INK)
    draw_rect(Rect2(3,3,114,23),Color("#8b5a48"))
    draw_rect(Rect2(6,5,108,18),Color("#b18160"),false,1)
    draw_rect(Rect2(15,4,90,20),Color("#56334d"))
    # Dois exemplares fisicos, reconheciveis pelas capas e cores.
    if coffin_cover != null:
        draw_texture_rect(coffin_cover,Rect2(29,2,27,24),false)
    draw_texture_rect(URN_COVER,Rect2(65,2,24,24),false)
    draw_line(Vector2(4,27),Vector2(116,27),GOLD,2)
    draw_string(ThemeDB.fallback_font,Vector2(0,-7),"REVISTAS • E",HORIZONTAL_ALIGNMENT_CENTER,120,13,Color("#f4dfaf"))
