extends Control
## Retrato modular temporario de cada pessoa, antes dos PNGs definitivos.
## Silhueta e expressao respondem a um perfil de atendimento.
var actor_name: String = "VISITANTE"
var profile: String = "calmo"
var palette := {
    "calmo":Color("#6a526b"),"sofredor":Color("#5b6580"),
    "estranho":Color("#875b86"),"suspeito":Color("#444253"),
    "apressado":Color("#86634e"),"confuso":Color("#668284"),
    "economico":Color("#5d795d"),"reservado":Color("#575576"),
    "fiscal":Color("#607b7b"),"profissional":Color("#6c6b74"),
    "fornecedor":Color("#7c6559"),"curioso":Color("#69749a")
}

func set_actor(name: String, mood: String) -> void:
    actor_name = name
    profile = mood
    queue_redraw()

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    var ink := Color("#241826")
    var clothes: Color = palette.get(profile,Color("#65506b"))
    draw_rect(Rect2(0,0,w,h),Color("#44334d"))
    draw_rect(Rect2(4,4,w-8,h-8),Color("#65536c"))
    draw_rect(Rect2(8,8,w-16,h-16),Color("#332839"))
    # Silhueta modular. Cada nome muda ligeiramente detalhes do cabelo.
    var variant: int = posmod(actor_name.hash(),3)
    draw_colored_polygon(PackedVector2Array([
        Vector2(10,h-4),Vector2(26,h-57),Vector2(42,h-64),
        Vector2(w-42,h-64),Vector2(w-26,h-57),Vector2(w-10,h-4)
    ]),clothes)
    draw_rect(Rect2(30,h-45,w-60,6),clothes.lightened(0.22))
    draw_rect(Rect2(w*0.5-13,h-58,26,12),Color("#d2a997"))
    draw_circle(Vector2(w*0.5,h-86),28,Color("#c8a294"))
    var hair: Color = Color("#342a37") if variant==0 else Color("#6a4852") if variant==1 else Color("#4b4344")
    draw_colored_polygon(PackedVector2Array([
        Vector2(w*0.5-29,h-94),Vector2(w*0.5-25,h-117),
        Vector2(w*0.5+15,h-125),Vector2(w*0.5+29,h-99),
        Vector2(w*0.5+22,h-110),Vector2(w*0.5-19,h-105)
    ]),hair)
    var eye_y: float = h-85
    draw_rect(Rect2(w*0.5-15,eye_y,7,4),ink)
    draw_rect(Rect2(w*0.5+8,eye_y,7,4),ink)
    if profile=="sofredor":
        draw_rect(Rect2(w*0.5+11,eye_y+5,3,12),Color("#9fb7d2"))
    elif profile=="suspeito" or profile=="reservado":
        draw_line(Vector2(w*0.5-16,eye_y-4),Vector2(w*0.5-8,eye_y-8),ink,3)
        draw_line(Vector2(w*0.5+8,eye_y-8),Vector2(w*0.5+16,eye_y-4),ink,3)
    elif profile=="estranho" or profile=="curioso":
        draw_arc(Vector2(w*0.5-11,eye_y+3),11,0.0,TAU,24,Color("#d4ba79"),2.0)
        draw_arc(Vector2(w*0.5+11,eye_y+3),11,0.0,TAU,24,Color("#d4ba79"),2.0)
    var smile: bool = profile in ["calmo","estranho","curioso","profissional","fornecedor"]
    var mouth_y: float = h-67
    if smile:
        draw_arc(Vector2(w*0.5,mouth_y),7,0.05,PI-0.05,8,ink,2.0)
    else:
        draw_line(Vector2(w*0.5-6,mouth_y),Vector2(w*0.5+6,mouth_y-1),ink,2.0)
    draw_rect(Rect2(0,0,w,h),Color("#d8b882"),false,3)
