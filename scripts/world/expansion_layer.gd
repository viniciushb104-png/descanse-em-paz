extends Node2D
const LAYOUT = preload("res://scripts/world/expansion_layout.gd")
const WALLS = preload("res://scripts/world/boundary_art.gd")
const TREE = preload("res://assets/trees/Arvore_01.png")
const LAMP = preload("res://assets/sprites/lantern.svg")
const MAUSOLEUM = preload("res://assets/roadside/mausoleum.webp")
const FLOWERS = preload("res://assets/sprites/flowers.svg")
const BENCH = preload("res://assets/sprites/bench.svg")
func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    queue_redraw()
func stamp(tex: Texture2D, p: Vector2, h: float) -> void:
    var w := h*float(tex.get_width())/maxf(1.0,float(tex.get_height()))
    draw_texture_rect(tex,Rect2(p.x-w/2,p.y-h,w,h),false)
func _draw() -> void:
    WALLS.horizontal(self,1536,3072,-1650,["wall","wall_lamp","wall_skull"],58)
    WALLS.side(self,3040,-1650,0)
    WALLS.side(self,1510,-1650,-910)
    WALLS.side(self,1510,-710,-100)
    WALLS.object(self,"arch",1522,-710,110)
    for i in range(LAYOUT.STATIONS.size()):
        var st: Dictionary = LAYOUT.STATIONS[i]
        var rect: Rect2 = LAYOUT.BUILDINGS[i]
        var p: Vector2 = st["p"]
        if i<2:
            draw_texture_rect(MAUSOLEUM,rect,false)
        else:
            draw_rect(rect,Color("#746378"))
            draw_rect(rect,Color("#2e2336"),false,5)
            draw_colored_polygon(PackedVector2Array([rect.position+Vector2(-14,25),rect.position+Vector2(rect.size.x/2,-55),rect.position+Vector2(rect.size.x+14,25)]),Color("#4d3657"))
            draw_rect(Rect2(rect.get_center().x-25,rect.end.y-65,50,65),Color("#423247"))
            for wx in [-70.0,70.0]:
                draw_rect(Rect2(rect.get_center().x+wx-19,rect.position.y+65,38,42),Color("#d9b87e"))
        draw_string(ThemeDB.fallback_font,Vector2(rect.position.x,rect.position.y-12),str(st["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#f1d6a5"))
        stamp(LAMP,p+Vector2(-98,0),66)
        stamp(LAMP,p+Vector2(98,0),66)
        stamp(FLOWERS,p+Vector2(-75,20),25)
        stamp(FLOWERS,p+Vector2(75,20),25)
    for y in [-1550.0,-950.0,-200.0,2120.0]:
        for x in [1610.0,2990.0]:
            stamp(TREE,Vector2(x,y),144)
    for y in [-1450.0,-1250.0,-1030.0,-750.0,-120.0,1510.0,2070.0]:
        stamp(LAMP,Vector2(2190,y),70)
        stamp(LAMP,Vector2(2440,y),70)
    for x in [1740.0,1940.0,2600.0,2860.0]:
        stamp(BENCH,Vector2(x,-910),45)
        stamp(FLOWERS,Vector2(x,2160),46)
    draw_string(ThemeDB.fallback_font,Vector2(2030,-1600),"NECROPOLE DOS ESQUECIDOS",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("#e4b875"))
    draw_string(ThemeDB.fallback_font,Vector2(2180,2220),"JARDIM DA MEMORIA",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("#e4b875"))
