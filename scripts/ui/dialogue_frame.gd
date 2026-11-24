extends Control
## Moldura de dialogo inspirada no sistema de Jack: janela de retrato,
## placa do nome, corpo da fala e respostas em areas separadas.
## Cada personagem tem paleta, metal e brasao definidos em dialogue_characters.gd.
const INK := Color("#180f20")
const PAPER := Color("#f7e8d0")
var accent: Color = Color("#caa574")
var shade: Color = Color("#4d314e")
var motif: String = "book"
var show_portrait: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_identity(character: Dictionary) -> void:
    show_portrait = not character.is_empty()
    accent = Color(str(character.get("accent","#caa574")))
    shade = Color(str(character.get("shade","#4d314e")))
    motif = str(character.get("motif","book"))
    queue_redraw()

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    if w <= 100.0 or h <= 100.0:
        return
    draw_rect(Rect2(Vector2.ZERO,size),Color("#140e1a"),true)
    draw_rect(Rect2(6,6,w-12,h-12),INK.lerp(shade,0.33),true)
    draw_rect(Rect2(6,6,w-12,h-12),accent,false,4.0)
    draw_rect(Rect2(13,13,w-26,h-26),accent.darkened(0.52),false,2.0)
    # Moldura de nome, painel de fala e painel das escolhas.
    var left: float = 178.0 if show_portrait else 22.0
    var name_width: float = w-left-20.0
    _panel(Rect2(left,17,name_width,43),shade,accent,3.0)
    _panel(Rect2(left,76,name_width,149),Color("#251b2a"),accent.darkened(0.43),2.0)
    _panel(Rect2(21,241,w-42,h-258),Color("#281c2f"),accent.darkened(0.25),2.0)
    # Ornamentos em arabescos, inspirados em livro antigo.
    for x in [20.0,w-20.0]:
        var y: float = 19.0
        draw_arc(Vector2(x,y),9.0,0.0,TAU,18,accent,2.0)
        draw_circle(Vector2(x,y),3.0,accent.lightened(0.35))
    for x in [31.0,w-31.0]:
        draw_arc(Vector2(x,h-31.0),11.0,0.0,TAU,16,accent,2.0)
    draw_line(Vector2(39,h-13.0),Vector2(w-39,h-13.0),accent.darkened(0.22),2.0)
    draw_line(Vector2(left+14,68),Vector2(w-25,68),accent.darkened(0.1),2.0)
    if show_portrait:
        # Janela do retrato: margem interna para que a pessoa NAO cubra a moldura.
        _panel(Rect2(22,74,143,154),shade.darkened(0.4),accent,3.0)
        draw_rect(Rect2(29,81,129,140),Color("#1b1828"),true)
        draw_rect(Rect2(29,81,129,140),accent.darkened(0.33),false,2.0)
        draw_arc(Vector2(93,82),50.0,PI,TAU,22,accent,2.0)
        _sigil(Vector2(93,242),motif,accent,8.0)
    else:
        _sigil(Vector2(36,39),"book",accent,11.0)
    _sigil(Vector2(w-38,38),motif,accent,10.0)

func _panel(rect: Rect2, fill_color: Color, trim: Color, thickness: float) -> void:
    draw_rect(rect,fill_color,true)
    draw_rect(rect,trim,false,thickness)
    draw_circle(rect.position+Vector2(5,5),2.0,trim)
    draw_circle(rect.position+Vector2(rect.size.x-5,5),2.0,trim)

func _sigil(p: Vector2, symbol: String, tone: Color, scale_value: float) -> void:
    var r: float = scale_value
    match symbol:
        "moon":
            draw_arc(p,r,-PI*0.6,PI*0.62,21,tone,2.5)
            draw_circle(p+Vector2(r*0.42,-r*0.34),2.0,tone)
        "scales":
            draw_line(p+Vector2(0,-r),p+Vector2(0,r),tone,2.0)
            draw_line(p+Vector2(-r,-r*0.3),p+Vector2(r,-r*0.3),tone,2.0)
            draw_line(p+Vector2(-r,-r*0.3),p+Vector2(-r,r*0.45),tone,1.5)
            draw_line(p+Vector2(r,-r*0.3),p+Vector2(r,r*0.45),tone,1.5)
            draw_arc(p+Vector2(-r,r*0.35),r*0.45,0,PI,10,tone,1.5)
            draw_arc(p+Vector2(r,r*0.35),r*0.45,0,PI,10,tone,1.5)
        "clock","wheel":
            draw_arc(p,r,0,TAU,22,tone,2.0)
            draw_line(p,p+Vector2(0,-r*0.65),tone,2.0)
            draw_line(p,p+Vector2(r*0.55,r*0.23),tone,2.0)
        "book","ledger":
            draw_rect(Rect2(p-Vector2(r,r*0.7),Vector2(2*r,1.4*r)),tone,false,2.0)
            draw_line(p+Vector2(0,-r*0.65),p+Vector2(0,r*0.65),tone,2.0)
        "key":
            draw_arc(p+Vector2(0,-r*0.45),r*0.5,0,TAU,16,tone,2.0)
            draw_line(p,p+Vector2(0,r),tone,2.0)
            draw_line(p+Vector2(0,r*0.7),p+Vector2(r*0.5,r*0.7),tone,2.0)
        "flower","rose","leaf":
            for i in range(5):
                var angle: float = TAU*float(i)/5.0
                draw_circle(p+Vector2(cos(angle),sin(angle))*r*0.53,r*0.33,tone.darkened(0.2))
            draw_circle(p,r*0.30,tone.lightened(0.3))
        "cross":
            draw_line(p+Vector2(0,-r),p+Vector2(0,r),tone,3.0)
            draw_line(p+Vector2(-r*0.6,-r*0.22),p+Vector2(r*0.6,-r*0.22),tone,3.0)
        "flame","candle":
            draw_colored_polygon(PackedVector2Array([
                p+Vector2(0,-r),p+Vector2(r*0.55,r*0.2),
                p+Vector2(0,r),p+Vector2(-r*0.55,r*0.2)]),tone)
        "pumpkin":
            for i in [-1,0,1]:
                draw_arc(p+Vector2(i*r*0.25,0),r*0.62,-PI*0.5,PI*0.5,16,tone,2.0)
        "spade":
            draw_colored_polygon(PackedVector2Array([
                p+Vector2(0,-r),p+Vector2(r*0.85,0),p+Vector2(0,r*0.55),p+Vector2(-r*0.85,0)]),tone)
            draw_line(p+Vector2(0,r*0.45),p+Vector2(0,r),tone,2.0)
        _:
            var pts := PackedVector2Array()
            for i in range(10):
                var angle: float = -PI*0.5 + float(i)*PI/5.0
                var length: float = r if i%2==0 else r*0.43
                pts.append(p+Vector2(cos(angle),sin(angle))*length)
            draw_colored_polygon(pts,tone)
