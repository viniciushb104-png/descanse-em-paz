extends Node2D
const CATALOG = preload("res://scripts/world/interior_catalog.gd")
const OFFICE = preload("res://scenes/interiors/office.tscn")
const MAINTENANCE = preload("res://scenes/interiors/maintenance.tscn")
const INK := Color("#241a2b")
const GOLD := Color("#d8b882")
const PAPER := Color("#eadfd0")
var room: String = ""
var room_art: Node2D = null
var customer_name: String = "VISITANTE"
var customer_profile: String = "calmo"

func set_customer(name: String, profile: String) -> void:
    customer_name = name
    customer_profile = profile
    queue_redraw()

func set_room(key: String) -> void:
    room = key
    visible = not key.is_empty()
    if is_instance_valid(room_art):
        remove_child(room_art)
        room_art.queue_free()
        room_art = null
    match key:
        "office":
            room_art = OFFICE.instantiate() as Node2D
        "maintenance":
            room_art = MAINTENANCE.instantiate() as Node2D
    if room_art != null:
        room_art.name = "RoomArtwork"
        add_child(room_art)
    queue_redraw()

func _draw() -> void:
    if not CATALOG.ROOMS.has(room):
        return
    var info: Dictionary = CATALOG.ROOMS[room]
    var style: String = str(info["theme"])
    var wall := Color("#6d5972")
    var floor_col := Color("#55475e")
    match style:
        "hospital": wall=Color("#7a8f95"); floor_col=Color("#667a80")
        "lab": wall=Color("#627b85"); floor_col=Color("#4f5e69")
        "garage": wall=Color("#625867"); floor_col=Color("#4e4a56")
        "crematory": wall=Color("#816774"); floor_col=Color("#58444c")
        "parlor": wall=Color("#75536d"); floor_col=Color("#553c50")
        "supply": wall=Color("#85715e"); floor_col=Color("#645246")
        "archive": wall=Color("#575274"); floor_col=Color("#45415a")
        "maintenance": wall=Color("#756073"); floor_col=Color("#625052")
        "inspection": wall=Color("#666476"); floor_col=Color("#4c465b")
    draw_rect(Rect2(0,0,1152,648),INK)
    draw_rect(Rect2(24,22,1104,570),wall)
    draw_rect(Rect2(43,161,1066,425),floor_col)
    for cx in range(43,1108,42):
        for cy in range(161,582,42):
            if (int(cx/42)+int(cy/42))%2 == 0:
                draw_rect(Rect2(cx,cy,41,41),floor_col.lightened(0.048))
    draw_rect(Rect2(44,153,1065,12),INK)
    draw_rect(Rect2(44,578,1065,9),INK)
    draw_rect(Rect2(522,570,112,78),Color("#322936"))
    draw_line(Vector2(522,570),Vector2(522,648),GOLD,3)
    draw_line(Vector2(634,570),Vector2(634,648),GOLD,3)
    _text(Vector2(70,78),str(info["title"]),26,PAPER)
    _text(Vector2(70,113),str(info["description"]),16,PAPER)
    if room not in ["office","maintenance"]:
        for n in range(5):
            var x: float = 764.0+float(n)*59.0
            draw_rect(Rect2(x,184,47,111),Color("#302935"))
            for k in range(4):
                var col := Color("#b69a7d")
                if style in ["hospital","lab","inspection"]: col=Color("#acbfcd")
                draw_rect(Rect2(x+6,190+float(k)*25.0,35,19),col.darkened(float((k+n)%3)*0.09))
    for lamp_x in [447.0,680.0]:
        draw_line(Vector2(lamp_x,73),Vector2(lamp_x,125),INK,4)
        draw_circle(Vector2(lamp_x,144),15,GOLD)
    if room not in ["office","maintenance"]:
        _decor(style)
        draw_rect(Rect2(215,270,184,35),Color("#654656"))
        draw_rect(Rect2(871,298,190,39),Color("#674b52"))
    _npc(Vector2(294,326),Color("#d9b5a0"),Color("#403245"),"ATENDENTE")
    var coat := Color("#584051")
    match customer_profile:
        "sofredor": coat=Color("#5d647a")
        "suspeito": coat=Color("#383948")
        "estranho": coat=Color("#956481")
        "apressado": coat=Color("#916552")
        "economico": coat=Color("#6c725c")
        "confuso": coat=Color("#5d7a7a")
    _npc(Vector2(818,325),Color("#b9a5b8"),coat,customer_name)
    draw_rect(Rect2(180,182,72,44),Color("#322635"))
    draw_rect(Rect2(188,187,56,31),Color("#baa27e"))
    _text(Vector2(176,174),"CASOS",15,PAPER)
    _text(Vector2(524,614),"SAIDA [E]",19,GOLD)

func _text(p: Vector2,value: String,font_px: int,tone: Color) -> void:
    draw_string(ThemeDB.fallback_font,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_px,tone)

func _npc(p: Vector2,skin: Color,coat: Color,label: String) -> void:
    draw_circle(p,18,skin)
    draw_rect(Rect2(p.x-21,p.y+16,42,41),coat)
    draw_circle(p+Vector2(-6,-2),2,INK)
    draw_circle(p+Vector2(6,-2),2,INK)
    _text(p+Vector2(-37,-34),label,15,PAPER)

func _decor(style: String) -> void:
    match style:
        "supply":
            for x in [77.0,941.0]:
                draw_rect(Rect2(x,415,140,76),Color("#916c52"))
                draw_rect(Rect2(x+13,427,111,12),GOLD)
        "parlor":
            for x in [86.0,1031.0]:
                draw_circle(Vector2(x,451),30,Color("#974f79"))
                draw_circle(Vector2(x-12,441),8,Color("#d1a8c3"))
        "garage":
            for x in [71.0,928.0]:
                draw_rect(Rect2(x,449,135,43),Color("#292833"))
                draw_circle(Vector2(x+28,498),15,INK)
                draw_circle(Vector2(x+103,498),15,INK)
        "hospital","lab":
            for x in [63.0,981.0]:
                draw_rect(Rect2(x,443,116,49),Color("#b5cbd1"))
                draw_rect(Rect2(x+8,437,97,13),PAPER)
        "crematory":
            draw_rect(Rect2(82,418,175,77),Color("#30303a"))
            for n in range(3):
                draw_circle(Vector2(112+float(n)*51,443),10,GOLD)
        _:
            draw_rect(Rect2(75,438,136,50),Color("#42384e"))
