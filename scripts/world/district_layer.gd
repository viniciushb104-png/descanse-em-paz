extends Node2D
## Arquitetura gotica provisoria, sem arquivos de arte recortados.
## Futuras construcoes ganharao PNGs individuais como as arvores.
const BOUNDARIES = preload("res://scripts/world/boundary_art.gd")
const INK := Color("#251b2c")
const GOLD := Color("#dec18f")
const BLUE := Color("#9fbdca")
const STONE := Color("#8b8092")

const HOSPITAL_ART_PATH := "res://assets/sprites/hospital_santa_ultima_hora.png"
var hospital_art: Texture2D
const CREMATORIUM_ART_PATH := "res://assets/sprites/crematorio_cinzas_e_cia.png"
var crematorium_art: Texture2D

func _ready() -> void:
    if ResourceLoader.exists(HOSPITAL_ART_PATH, "Texture2D"):
        hospital_art = load(HOSPITAL_ART_PATH) as Texture2D
    if ResourceLoader.exists(CREMATORIUM_ART_PATH, "Texture2D"):
        crematorium_art = load(CREMATORIUM_ART_PATH) as Texture2D
    queue_redraw()

func _draw() -> void:
    BOUNDARIES.paint_district(self)
    _paint_hospital()
    _building(Vector2(1609,758),Vector2(337,233),"SALA DE CONSERVACAO",Color("#81778e"),Color("#684960"),false)
    _paint_crematorium()
    _building(Vector2(1655,1151),Vector2(410,215),"GARAGEM FUNERARIA",Color("#71647a"),Color("#463348"),false)
    if crematorium_art == null:
        _rect(Rect2(2304,683,46,79),Color("#7c6b75"))
        _rect(Rect2(2311,664,32,22),Color("#afa2ad"))
    _hearse(Vector2(2083,459),1.0)
    _hearse(Vector2(2110,1194),0.9)
    _building(Vector2(2464,151),Vector2(288,260),"CASA FUNERARIA UMBRA",Color("#997d8d"),Color("#543b5b"),false)
    _building(Vector2(2785,153),Vector2(255,258),"EMPORIO DE URNAS",Color("#9b866f"),Color("#634854"),false)
    _text(Vector2(2518,449),"ATENDIMENTO",18,GOLD)
    _text(Vector2(2812,449),"SUPRIMENTOS",18,GOLD)
    _sign(Rect2(1551,695,139,69),"ARQUIVO","LEGAL")
    _building(Vector2(2700,850),Vector2(280,190),"FISCALIZACAO",Color("#938895"),Color("#52435e"),false)
    _sign(Rect2(2720,1098,240,54),"POSTO DE","FISCALIZACAO")
    _text(Vector2(1556,530),"DISTRITO DOS ETERNOS",24,GOLD)
    _text(Vector2(1853,624),"RUA DA ULTIMA VIAGEM",18,GOLD)
    _text(Vector2(1692,426),"Dra. Penelope Alvorada",18,GOLD)
    _text(Vector2(1674,1016),"Dona Clotilde",18,GOLD)
    _text(Vector2(2112,1025),"Seu Cinerio Brasa",18,GOLD)
    _text(Vector2(1762,1410),"Arquimedes Ossario",18,GOLD)

func _paint_hospital() -> void:
    if hospital_art == null:
        _building(Vector2(1654,148),Vector2(353,254),"HOSPITAL SANTA ULTIMA HORA",Color("#9a8a9e"),Color("#604e70"),true)
        return
    var footprint := Rect2(1654,148,353,254)
    var scale_factor := minf(footprint.size.x / float(hospital_art.get_width()), footprint.size.y / float(hospital_art.get_height()))
    var art_size := hospital_art.get_size() * scale_factor
    var art_pos := Vector2(footprint.get_center().x - art_size.x / 2.0, footprint.end.y - art_size.y)
    draw_texture_rect(hospital_art, Rect2(art_pos, art_size), false)

func _paint_crematorium() -> void:
    if crematorium_art == null:
        _building(Vector2(2039,754),Vector2(337,246),"CREMATORIO CINZAS & CIA",Color("#937c91"),Color("#4f3d57"),false)
        return
    var footprint := Rect2(2039,754,337,246)
    var scale_factor := minf(footprint.size.x / float(crematorium_art.get_width()), footprint.size.y / float(crematorium_art.get_height()))
    var art_size := crematorium_art.get_size() * scale_factor
    var art_pos := Vector2(footprint.get_center().x - art_size.x / 2.0, footprint.end.y - art_size.y)
    draw_texture_rect(crematorium_art, Rect2(art_pos, art_size), false)

func _rect(r: Rect2, c: Color) -> void:
    draw_rect(r,c,true)
    draw_rect(r,INK,false,4.0)

func _text(pos: Vector2,t: String,s: int=18,c: Color=GOLD) -> void:
    draw_string(ThemeDB.fallback_font,pos,t,HORIZONTAL_ALIGNMENT_LEFT,-1,s,c)

func _walls() -> void:
    for x in range(1510,3072,91):
        _rect(Rect2(x,30,80,20),Color("#64596a"))
    for y in range(100,1370,80):
        if y < 510 or y > 690:
            _rect(Rect2(1492,y,18,75),Color("#64596a"))
        _rect(Rect2(3038,y,18,75),Color("#64596a"))
    for x in range(1510,3070,90):
        _rect(Rect2(x,1376,80,19),Color("#64596a"))

func _building(pos: Vector2,sz: Vector2,name: String,walls: Color,roof: Color,has_cross: bool) -> void:
    draw_rect(Rect2(pos+Vector2(11,17),sz),Color(0,0,0,0.23))
    _rect(Rect2(pos,sz),walls)
    var peaks := PackedVector2Array([pos+Vector2(-14,43),pos+Vector2(sz.x*0.5,-57),pos+Vector2(sz.x+15,43),pos+Vector2(sz.x,75),pos+Vector2(0,75)])
    draw_colored_polygon(peaks,roof)
    for i in range(peaks.size()):
        draw_line(peaks[i],peaks[(i+1)%peaks.size()],INK,5.0)
    _text(pos+Vector2(17,113),name,18,Color("#f6ddc6"))
    for n in range(3):
        var wx: float = pos.x+30+float(n)*110.0
        _rect(Rect2(wx,pos.y+144,37,51),BLUE if has_cross else Color("#e0b279"))
        draw_line(Vector2(wx+18,pos.y+145),Vector2(wx+18,pos.y+193),INK,3)
    _rect(Rect2(pos.x+sz.x*0.5-39,pos.y+sz.y-61,78,61),Color("#473443"))
    draw_line(Vector2(pos.x+sz.x*0.5,pos.y+sz.y-60),Vector2(pos.x+sz.x*0.5,pos.y+sz.y),GOLD,4.0)
    if has_cross:
        draw_line(pos+Vector2(sz.x*0.5,12),pos+Vector2(sz.x*0.5,53),Color("#f4c1d1"),8.0)
        draw_line(pos+Vector2(sz.x*0.5-19,33),pos+Vector2(sz.x*0.5+19,33),Color("#f4c1d1"),8.0)

func _hearse(pos: Vector2,scale_factor: float) -> void:
    draw_texture_rect(preload("res://assets/sprites/hearse.svg"),Rect2(pos-Vector2(0,25)*scale_factor,Vector2(236,118)*scale_factor),false)
    var sign_pos := pos+Vector2(12,92)*scale_factor
    draw_rect(Rect2(sign_pos-Vector2(5,18),Vector2(205,25)),Color("#24192f"))
    _text(sign_pos,"E · TRANSLADO DO ALEM",15,GOLD)

func _sign(r: Rect2,a: String,b: String) -> void:
    _rect(r,Color("#493448"))
    _text(r.position+Vector2(11,27),a,18)
    _text(r.position+Vector2(11,51),b,17)
