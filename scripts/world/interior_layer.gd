extends Node2D
const WAKE = preload("res://scripts/systems/wake_ceremony.gd")
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
    if room=="chapel":
        _paint_chapel()
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

func _paint_chapel() -> void:
    var order: Dictionary = get_parent().burial_queue.pending()
    var state: Dictionary = WAKE.state(order)
    var choices: Dictionary = state["choices"]
    draw_rect(Rect2(0,0,1152,648),INK)
    draw_rect(Rect2(40,40,1072,545),Color("#514152"))
    draw_rect(Rect2(64,164,1024,412),Color("#69545b"))
    for x in range(64,1088,64):
        for y in range(164,576,32):
            draw_rect(Rect2(x,y,62,30),Color("#765e65"))
    draw_rect(Rect2(520,170,110,405),Color("#704052"))
    _text(Vector2(70,80),"CAPELA DO ULTIMO ADEUS",28,GOLD)
    _text(Vector2(70,115),"Organize a despedida conforme os pedidos da familia.",17,PAPER)
    for x in [200.0,520.0,840.0]:
        draw_rect(Rect2(x,45,90,100),Color("#302739"))
        draw_rect(Rect2(x+8,55,74,82),Color("#8b679b"))
    var coffin := PackedVector2Array([Vector2(548,255),Vector2(602,255),Vector2(630,286),Vector2(606,366),Vector2(544,366),Vector2(520,286)])
    draw_colored_polygon(coffin,Color("#583c35"))
    var outline := coffin.duplicate()
    outline.append(coffin[0])
    draw_polyline(outline,GOLD,3.0)
    var flower_colors := [Color("#eee4cd"),Color("#bb5368"),Color("#e9ca73"),Color("#a781cc")]
    var flower: int = int(choices.get("flowers",-1))
    for p in [Vector2(275,245),Vector2(460,310),Vector2(690,310)]:
        draw_rect(Rect2(p-Vector2(11,0),Vector2(22,27)),Color("#674d42"))
        if flower>=0:
            for i in range(7):
                draw_circle(p+Vector2.from_angle(float(i)*2.4)*15,8,flower_colors[flower])
    var lighting := int(choices.get("light",-1))
    for p in [Vector2(875,245),Vector2(490,240),Vector2(660,240)]:
        draw_rect(Rect2(p-Vector2(4,0),Vector2(8,28)),GOLD)
        if lighting>=0:
            draw_circle(p-Vector2(0,4),9,Color("#ffe3a0") if lighting<2 else Color("#e4d7ee"))
            draw_circle(p,30,Color(1.0,0.76,0.35,0.11))
    var arrangement := int(choices.get("chairs",0))
    for i in range(6 if arrangement==2 else 12):
        var p := Vector2(300+float(i%3)*62+0.0,392+float(floori(float(i)/6.0))*68)
        if i%6>=3:
            p.x+=405
        if arrangement==1:
            p=Vector2(575,335)+Vector2.from_angle(0.2+float(i)*0.245)*Vector2(275,160)
        draw_rect(Rect2(p-Vector2(22,12),Vector2(44,27)),Color("#4c3433"))
        draw_rect(Rect2(p-Vector2(22,17),Vector2(44,8)),Color("#a57c5d"))
    draw_rect(Rect2(940,400,65,45),Color("#44303b"))
    _text(Vector2(937,397),"MUSICA",15,GOLD)
    if int(choices.get("music",-1))>=0:
        _text(Vector2(920,470),str(WAKE.OPTIONS["music"][int(choices["music"])]),16,PAPER)
    draw_rect(Rect2(548,191,54,29),Color("#5f403c"))
    if int(choices.get("tribute",-1))>=0:
        _text(Vector2(510,184),str(WAKE.OPTIONS["tribute"][int(choices["tribute"])]),14,PAPER)
    _chapel_npc("anselmo",Vector2(155,365),"ANSELMO")
    if order.is_empty() or WAKE.done(order):
        _chapel_npc("eudoxia",Vector2(800,465),"EUDOXIA")
    else:
        _npc(Vector2(800,465),Color("#d9b5a0"),Color("#50465d"),"FAMILIA")
    if bool(state["received"]):
        _npc(Vector2(452,355),Color("#c6a38e"),Color("#655468"),"")
        _npc(Vector2(700,355),Color("#d1baa8"),Color("#534f67"),"")
    _text(Vector2(525,610),"SAIDA [E]",19,GOLD)

func _chapel_npc(id: String, p: Vector2, label: String) -> void:
    var direction := "front"
    if id=="anselmo":
        var delta: Vector2 = get_parent().player.global_position - (p+Vector2(0,36))
        if delta.length()<160.0:
            if absf(delta.x)>absf(delta.y):
                direction = "right" if delta.x>0.0 else "left"
            else:
                direction = "front" if delta.y>=0.0 else "back"
    var path := "res://assets/sprites/chapel_npcs/"+id+"_"+direction+".png"
    if ResourceLoader.exists(path):
        var tex := load(path) as Texture2D
        if tex != null:
            var h := 78.0
            var w := h*float(tex.get_width())/maxf(1.0,float(tex.get_height()))
            draw_texture_rect(tex,Rect2(p.x-w/2,p.y-32,w,h),false)
            _text(p+Vector2(-40,-38),label,15,PAPER)
            return
    # Distinct provisional costumes until the approved transparent PNGs arrive.
    draw_circle(p,18,Color("#d9b5a0"))
    if id=="anselmo":
        draw_rect(Rect2(p.x-14,p.y-18,28,8),Color("#c1bacb"))
        draw_rect(Rect2(p.x-16,p.y+16,32,43),Color("#593b70"))
        draw_line(p+Vector2(0,18),p+Vector2(0,48),GOLD,2.0)
        for dx in [-7.0,7.0]:
            draw_arc(p+Vector2(dx,0),5,0,TAU,12,GOLD,2.0)
    else:
        draw_rect(Rect2(p.x-21,p.y-22,42,10),Color("#422945"))
        draw_circle(p+Vector2(12,-22),7,Color("#af78ba"))
        draw_colored_polygon(PackedVector2Array([p+Vector2(-14,15),p+Vector2(14,15),p+Vector2(27,57),p+Vector2(-27,57)]),Color("#4b345c"))
        for i in range(5):
            draw_circle(p+Vector2(13,27)+Vector2.from_angle(float(i)*1.26)*7,5,Color("#c38fce"))
    _text(p+Vector2(-40,-38),label,15,PAPER)

func _process(_delta: float) -> void:
    if room=="chapel":
        queue_redraw()
