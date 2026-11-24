extends Node2D
## Ornamentacao do lobby do Jardim do Ultimo Suspiro.
## Sem colisoes, sem botoes e sem alterar fachadas / sprites aprovados.
## Desenha acima do piso e abaixo dos personagens e dos edificios.

const INK := Color("#241d2e")
const WOOD := Color("#4b3445")
const GOLD := Color("#d7b47a")
const CREAM := Color("#f2dfb7")
const STONE := Color("#69586b")
const STONE_LIGHT := Color("#827085")
const MOSS := Color("#3b5443")
const LILAC := Color("#b9a1cc")
const PLAZA := Vector2(769.0, 747.0)

# As chamas acompanham lanternas que JA existem em map_art.gd.
const LANTERN_FLAMES := [
    Vector2(636, 551), Vector2(866, 554),
    Vector2(1095, 553), Vector2(1255, 556)
]
# Posições no gramado; placas nao interceptam entradas nem capturam toque.
const SIGNS := [
    {"at": Vector2(522, 639), "name":"ESCRITORIO", "side":-1},
    {"at": Vector2(874, 392), "name":"CAPELA", "side":0},
    {"at": Vector2(1090, 587), "name":"OFICINA", "side":1},
    {"at": Vector2(1017, 903), "name":"QUADRA B", "side":1},
    {"at": Vector2(1264, 932), "name":"DISTRITO", "side":1}
]
const FLOWER_SPOTS := [
    Vector2(632, 691), Vector2(935, 672), Vector2(604, 828),
    Vector2(985, 839), Vector2(446, 603), Vector2(1040, 764)
]
var seconds: float = 0.0
var redraw_accumulator: float = 0.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    queue_redraw()

func _process(delta: float) -> void:
    if not visible:
        return
    seconds += delta
    redraw_accumulator += delta
    # 7 FPS apenas nesta camada. Piso, edificios e NPCs nao sao redesenhados.
    if redraw_accumulator >= 0.14:
        redraw_accumulator = 0.0
        queue_redraw()

func current_darkness() -> float:
    var minutes := float(get_parent().get("clock_minutes"))
    return clampf((minutes - 875.0) / 205.0, 0.0, 1.0)

func _draw() -> void:
    _plaza_paving()
    _border_mosaics()
    _flowerbeds()
    _signposts()
    _lantern_glow()
    _fireflies()

func _plaza_paving() -> void:
    # Rotunda octogonal acessivel, ornamento SOB o protagonista e Osvaldo.
    # A geometria e apenas visual; o movimento continua livre.
    var outer := PackedVector2Array([
        PLAZA+Vector2(-78,-116), PLAZA+Vector2(78,-116),
        PLAZA+Vector2(122,-72), PLAZA+Vector2(122,72),
        PLAZA+Vector2(78,116), PLAZA+Vector2(-78,116),
        PLAZA+Vector2(-122,72), PLAZA+Vector2(-122,-72)
    ])
    draw_colored_polygon(outer, INK)
    var mid := PackedVector2Array([
        PLAZA+Vector2(-70,-108), PLAZA+Vector2(70,-108),
        PLAZA+Vector2(114,-64), PLAZA+Vector2(114,64),
        PLAZA+Vector2(70,108), PLAZA+Vector2(-70,108),
        PLAZA+Vector2(-114,64), PLAZA+Vector2(-114,-64)
    ])
    draw_colored_polygon(mid, STONE)
    var inner := PackedVector2Array([
        PLAZA+Vector2(-57,-92), PLAZA+Vector2(57,-92),
        PLAZA+Vector2(98,-54), PLAZA+Vector2(98,54),
        PLAZA+Vector2(57,92), PLAZA+Vector2(-57,92),
        PLAZA+Vector2(-98,54), PLAZA+Vector2(-98,-54),
        PLAZA+Vector2(-57,-92)
    ])
    draw_polyline(inner, Color("#9d8494"), 3.0)
    # Pedras desencontradas: o visual de 16-bit nao fica liso ou generico.
    for i in range(14):
        var y := -86.0 + float(i)*13.0
        var span := 91.0 if absf(y)<56.0 else 61.0
        var x := -span + float((i*17)%23)
        while x < span:
            var width := minf(24.0+float((i*13+int(x)+115)%15), span-x)
            draw_rect(Rect2(PLAZA+Vector2(x,y), Vector2(width,2)), Color("#372b3e",0.30))
            x += width + 7.0
    # Rosa dos ventos e ampulheta: tempo, escolhas e ultima viagem.
    var diamond := PackedVector2Array([
        PLAZA+Vector2(0,-53),PLAZA+Vector2(48,0),
        PLAZA+Vector2(0,53),PLAZA+Vector2(-48,0),PLAZA+Vector2(0,-53)
    ])
    draw_polyline(diamond, Color("#c5a67c",0.75), 3.0)
    draw_line(PLAZA+Vector2(-27,-28),PLAZA+Vector2(27,-28),GOLD,4.0)
    draw_line(PLAZA+Vector2(-27,28),PLAZA+Vector2(27,28),GOLD,4.0)
    draw_line(PLAZA+Vector2(-22,-26),PLAZA+Vector2(22,26),CREAM,3.0)
    draw_line(PLAZA+Vector2(22,-26),PLAZA+Vector2(-22,26),CREAM,3.0)
    draw_colored_polygon(PackedVector2Array([
        PLAZA+Vector2(-15,-20),PLAZA+Vector2(15,-20),
        PLAZA+Vector2(0,-3)
    ]), Color("#c7a56f",0.65))
    draw_colored_polygon(PackedVector2Array([
        PLAZA+Vector2(0,5),PLAZA+Vector2(16,22),
        PLAZA+Vector2(-16,22)
    ]), Color("#c7a56f",0.65))
    for offset in [Vector2(0,-98),Vector2(0,98),Vector2(-102,0),Vector2(102,0)]:
        draw_circle(PLAZA+offset,4.0,GOLD)
        draw_circle(PLAZA+offset,2.0,CREAM)

func _border_mosaics() -> void:
    # Frisos pequenos no caminho, preservando o desenho do piso original.
    for y in range(558, 898, 38):
        for x in [699.0, 837.0]:
            if Vector2(x,float(y)).distance_to(PLAZA) < 128.0:
                continue
            draw_rect(Rect2(x,float(y),6,10),Color("#bf9f77",0.55))
            draw_rect(Rect2(x+2,float(y)+2,2,6),Color("#f0d39a",0.55))
    for x in range(192, 1392, 57):
        if x > 660 and x < 894:
            continue
        for y in [557.0, 603.0]:
            draw_rect(Rect2(float(x),y,9,3),Color("#b09274",0.40))

func _flowerbeds() -> void:
    for spot_value in FLOWER_SPOTS:
        var spot: Vector2 = spot_value
        draw_rect(Rect2(spot.x-33,spot.y-4,67,13),Color("#242833",0.24))
        for i in range(9):
            var theta := float(i)*TAU/9.0
            var offset := Vector2(cos(theta)*21.0,sin(theta)*8.0)
            var p: Vector2 = spot+offset
            draw_rect(Rect2(p.x-4,p.y-9,8,13),MOSS)
            draw_rect(Rect2(p.x-2,p.y-16,5,6),LILAC if i%3==0 else Color("#d4a4ae"))
            draw_rect(Rect2(p.x-1,p.y-14,2,2),Color("#f3dbc0"))
        draw_rect(Rect2(spot.x-31,spot.y+8,63,3),Color("#6c5c61"))

func _signposts() -> void:
    for item in SIGNS:
        var p: Vector2 = item["at"]
        var name: String = str(item["name"])
        var side: int = int(item["side"])
        draw_rect(Rect2(p.x-16,p.y-1,32,6),Color("#181622",0.22))
        draw_rect(Rect2(p.x-5,p.y-47,10,48),WOOD)
        draw_rect(Rect2(p.x-4,p.y-43,3,38),Color("#725367"))
        var plaque := Rect2(p.x-66,p.y-78,132,31)
        draw_rect(plaque, INK)
        draw_rect(plaque, GOLD, false, 2.0)
        draw_rect(Rect2(p.x-59,p.y-73,118,20),Color("#493447"))
        draw_circle(Vector2(p.x-59,p.y-62),2,CREAM)
        draw_circle(Vector2(p.x+59,p.y-62),2,CREAM)
        draw_string(ThemeDB.fallback_font,p+Vector2(-48,-57),name,HORIZONTAL_ALIGNMENT_LEFT,-1,13,CREAM)
        # Flechas simples: esquerda, norte, direita.
        var apex := p + (Vector2(-54,-61) if side<0 else (Vector2(54,-61) if side>0 else Vector2(48,-71)))
        if side == 0:
            draw_line(apex+Vector2(-5,6),apex,GOLD,2)
            draw_line(apex+Vector2(5,6),apex,GOLD,2)
        elif side < 0:
            draw_line(apex+Vector2(6,-5),apex,GOLD,2)
            draw_line(apex+Vector2(6,5),apex,GOLD,2)
        else:
            draw_line(apex+Vector2(-6,-5),apex,GOLD,2)
            draw_line(apex+Vector2(-6,5),apex,GOLD,2)

func _lantern_glow() -> void:
    var darkness := current_darkness()
    for i in range(LANTERN_FLAMES.size()):
        var p: Vector2 = LANTERN_FLAMES[i]
        var shimmer := 0.86 + sin(seconds*4.0+float(i)*2.1)*0.14
        draw_circle(p,49.0,Color(0.95,0.66,0.35,(0.045+darkness*0.06)*shimmer))
        draw_circle(p,28.0,Color(0.98,0.74,0.42,(0.07+darkness*0.09)*shimmer))
        draw_circle(p,10.0,Color(1.0,0.84,0.53,(0.13+darkness*0.13)*shimmer))
        draw_rect(Rect2(p.x-2,p.y-2,4,5),Color(1.0,0.89,0.57,0.80*shimmer))

func _fireflies() -> void:
    var brightness := 0.20 + current_darkness()*0.68
    for i in range(22):
        var x := 192.0+float((i*131+35)%1187)
        var y := 415.0+float((i*73+11)%468)
        var phase := seconds*(0.33+float(i%4)*0.08)+float(i)*2.41
        var p := Vector2(x+sin(phase)*8.0,y+cos(phase*1.2)*6.0)
        var pulse := 0.25+0.75*absf(sin(seconds*1.4+float(i)*1.8))
        var alpha := brightness*pulse
        draw_rect(Rect2(p-Vector2(1.5,1.5),Vector2(3,3)),Color(0.98,0.82,0.53,alpha))
        if i%4==0:
            draw_rect(Rect2(p-Vector2(3.5,0.5),Vector2(7,1)),Color(0.98,0.83,0.55,alpha*0.45))
