extends RefCounted
## Layout modular. Novos PNGs opcionais, recursos antigos como fallback.
const ATLAS = preload("res://assets/art/world.png")
const FENCE = preload("res://assets/sprites/fence.svg")
const GATE = preload("res://assets/sprites/gate.svg")
static var cache: Dictionary = {}

static func art(ctx: Node2D, key: String, rect: Rect2) -> void:
    if not cache.has(key):
        var path := "res://assets/walls/"+key+".png"
        cache[key] = load(path) if ResourceLoader.exists(path) else null
    var tex := cache[key] as Texture2D
    if tex != null:
        ctx.draw_texture_rect(tex,rect,false)
        return
    if key.begins_with("fence"):
        ctx.draw_texture_rect(FENCE,rect,false)
    elif key=="arch" or key=="gate":
        ctx.draw_texture_rect(GATE,rect,false)
    else:
        ctx.draw_texture_rect_region(ATLAS,rect,Rect2(179,3,137,80))

static func horizontal(ctx: Node2D, left: int, right: int, base: int, key: String, height: float = 64.0) -> void:
    var x := left
    while x < right:
        var w := mini(144,right-x)
        art(ctx,key,Rect2(x,base-height,w,height))
        x += w

static func side(ctx: Node2D, x: int, top: int, bottom: int) -> void:
    # Vista superior das pedras laterais, sem deformar sprite frontal.
    ctx.draw_rect(Rect2(x,top,24,bottom-top),Color("#514354"))
    ctx.draw_rect(Rect2(x+3,top,18,bottom-top),Color("#817083"))
    for y in range(top,bottom,32):
        ctx.draw_rect(Rect2(x+3,y,18,2),Color("#514354"))
        ctx.draw_rect(Rect2(x+5,y+2,3,mini(28,bottom-y)),Color("#a08b9a"))

static func paint_cemetery(ctx: Node2D) -> void:
    horizontal(ctx,0,640,80,"wall")
    horizontal(ctx,928,1536,80,"wall")
    side(ctx,18,80,880)
    side(ctx,1490,80,510)
    side(ctx,1490,700,880)
    horizontal(ctx,0,630,950,"wall",62)
    horizontal(ctx,910,1536,950,"wall",62)
    art(ctx,"arch",Rect2(650,815,250,135))
    # Cercas baixas decorativas longe dos pontos de interacao.
    horizontal(ctx,160,390,870,"fence",40)
    horizontal(ctx,960,1080,880,"fence_ivy",38)

static func paint_district(ctx: Node2D) -> void:
    horizontal(ctx,1536,3072,48,"wall",44)
    side(ctx,3040,48,1376)
    horizontal(ctx,1536,3072,1390,"fence",45)
    # Jardins institucionais nas laterais, sem cruzar portas e ruas.
    horizontal(ctx,1660,1780,480,"fence",36)
    horizontal(ctx,1880,2000,480,"fence",36)
    horizontal(ctx,2700,2780,1130,"fence",36)
    horizontal(ctx,2910,2980,1130,"fence",36)

static func paint_north(ctx: Node2D) -> void:
    horizontal(ctx,65,640,-85,"fence",52)
    horizontal(ctx,928,1500,-85,"fence",52)
    horizontal(ctx,65,1500,-1650,"wall",52)
