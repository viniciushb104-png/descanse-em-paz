extends Node2D
## Arquitetura gotica provisoria, sem arquivos de arte recortados.
## Futuras construcoes ganharao PNGs individuais como as arvores.
const INK := Color("#251b2c")
const GOLD := Color("#dec18f")
const BLUE := Color("#9fbdca")
const STONE := Color("#8b8092")

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    _walls()
    _building(Vector2(1654,148),Vector2(353,254),"HOSPITAL SANTA ULTIMA HORA",Color("#9a8a9e"),Color("#604e70"),true)
    _building(Vector2(1609,758),Vector2(337,233),"SALA DE CONSERVACAO",Color("#81778e"),Color("#684960"),false)
    _building(Vector2(2039,754),Vector2(337,246),"CREMATORIO CINZAS & CIA",Color("#937c91"),Color("#4f3d57"),false)
    _building(Vector2(1655,1151),Vector2(410,215),"GARAGEM FUNERARIA",Color("#71647a"),Color("#463348"),false)
    _rect(Rect2(2304,683,46,79),Color("#7c6b75"))
    _rect(Rect2(2311,664,32,22),Color("#afa2ad"))
    _hearse(Vector2(2083,459),1.0)
    _hearse(Vector2(2110,1194),0.9)
    _building(Vector2(2464,151),Vector2(288,260),"CASA FUNERARIA UMBRA",Color("#997d8d"),Color("#543b5b"),false)
    _building(Vector2(2785,153),Vector2(255,258),"EMPORIO DE URNAS",Color("#9b866f"),Color("#634854"),false)
    _text(Vector2(2518,449),"ATENDIMENTO",18,GOLD)
    _text(Vector2(2812,449),"SUPRIMENTOS",18,GOLD)
    _sign(Rect2(1551,695,139,69),"ARQUIVO","LEGAL")
    _sign(Rect2(2107,1127,194,54),"POSTO DE","FISCALIZACAO")
    _text(Vector2(1556,530),"DISTRITO DOS ETERNOS",24,GOLD)
    _text(Vector2(1853,624),"RUA DA ULTIMA VIAGEM",18,GOLD)
    _text(Vector2(1692,426),"Dra. Penelope Alvorada",18,GOLD)
    _text(Vector2(1674,1016),"Dona Clotilde",18,GOLD)
    _text(Vector2(2112,1025),"Seu Cinerio Brasa",18,GOLD)
    _text(Vector2(1695,1121),"Arquimedes Ossario",18,GOLD)

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
    var w: float = 236.0*scale_factor
    var h: float = 69.0*scale_factor
    _rect(Rect2(pos,w*Vector2(1,0)+Vector2(0,h)),Color("#2b2531"))
    _rect(Rect2(pos+Vector2(w*0.23,-19*scale_factor),Vector2(w*0.58,32*scale_factor)),Color("#51455b"))
    _rect(Rect2(pos+Vector2(w*0.34,6),Vector2(w*0.35,23*scale_factor)),Color("#718497"))
    for offset in [0.25,0.78]:
        draw_circle(pos+Vector2(w*offset,h+9.0),15*scale_factor,INK)
        draw_circle(pos+Vector2(w*offset,h+9.0),7*scale_factor,Color("#bab0ac"))
    _text(pos+Vector2(w*0.37,h*0.76),"S.M.",18,GOLD)

func _sign(r: Rect2,a: String,b: String) -> void:
    _rect(r,Color("#493448"))
    _text(r.position+Vector2(11,27),a,18)
    _text(r.position+Vector2(11,51),b,17)
