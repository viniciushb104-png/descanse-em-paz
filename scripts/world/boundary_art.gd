extends RefCounted
## Dez PNGs definitivos, preloads explicitos para garantir importacao no Web.
const TEXTURES = {
    "wall":preload("res://assets/walls/wall.png"),
    "wall_skull":preload("res://assets/walls/wall_skull.png"),
    "wall_lamp":preload("res://assets/walls/wall_lamp.png"),
    "pillar":preload("res://assets/walls/pillar.png"),
    "pillar_ivy":preload("res://assets/walls/pillar_ivy.png"),
    "corner":preload("res://assets/walls/corner.png"),
    "fence":preload("res://assets/walls/fence.png"),
    "fence_ivy":preload("res://assets/walls/fence_ivy.png"),
    "gate":preload("res://assets/walls/gate.png"),
    "arch":preload("res://assets/walls/arch.png")
}
# Colisao apenas na base fisica dos limites, nunca na altura do desenho.
# Vao norte, entrada sul e ligacao leste permanecem livres.
const BLOCKS = [
    Rect2(0,70,640,14), Rect2(928,70,608,14),
    Rect2(18,80,24,800), Rect2(1490,80,24,430), Rect2(1490,700,24,180),
    Rect2(0,938,630,14), Rect2(910,938,626,14),
    Rect2(160,860,230,12), Rect2(960,870,120,12),
    Rect2(1536,38,1536,14), Rect2(3040,48,24,1328),
    Rect2(1536,1380,224,12), Rect2(1968,1380,1104,12),
    Rect2(1660,470,120,12), Rect2(1880,470,120,12),
    Rect2(2700,1120,80,12), Rect2(2910,1120,70,12),
    Rect2(65,-95,575,12), Rect2(928,-95,572,12),
    Rect2(65,-1660,1435,12)
]

static func is_blocked(p: Vector2) -> bool:
    for region in BLOCKS:
        if region.has_point(p):
            return true
    return false

static func art(ctx: Node2D, key: String, rect: Rect2) -> void:
    var tex: Texture2D = TEXTURES[key]
    ctx.draw_texture_rect(tex,rect,false)

static func object(ctx: Node2D, key: String, x: float, base: float, height: float) -> void:
    var tex: Texture2D = TEXTURES[key]
    var width := height*float(tex.get_width())/maxf(1.0,float(tex.get_height()))
    art(ctx,key,Rect2(x-width/2.0,base-height,width,height))

static func horizontal(ctx: Node2D, left: int, right: int, base: int, keys: Array, height: float = 64.0) -> void:
    # Divide o comprimento em modulos de tamanho parecido; evita ultimo retalho estreito.
    var count := maxi(1,roundi(float(right-left)/144.0))
    var span := float(right-left)/float(count)
    for i in range(count):
        art(ctx,str(keys[i%keys.size()]),Rect2(float(left)+float(i)*span,float(base)-height,span,height))

static func side(ctx: Node2D, x: int, top: int, bottom: int) -> void:
    ctx.draw_rect(Rect2(x,top,24,bottom-top),Color("#514354"))
    ctx.draw_rect(Rect2(x+3,top,18,bottom-top),Color("#817083"))
    for y in range(top,bottom,32):
        ctx.draw_rect(Rect2(x+3,y,18,2),Color("#514354"))
        ctx.draw_rect(Rect2(x+5,y+2,3,maxi(0,mini(28,bottom-y-2))),Color("#a08b9a"))
    for y in range(top+100,bottom,160):
        object(ctx,"pillar",x+12,y,55)

static func paint_cemetery(ctx: Node2D) -> void:
    horizontal(ctx,0,640,80,["wall","wall_skull","wall"])
    horizontal(ctx,928,1536,80,["wall","wall_lamp","wall"])
    side(ctx,18,80,880)
    side(ctx,1490,80,510)
    side(ctx,1490,700,880)
    horizontal(ctx,0,630,950,["wall","wall_lamp","wall"],62)
    horizontal(ctx,910,1536,950,["wall","wall_skull","wall"],62)
    object(ctx,"corner",55,950,66)
    object(ctx,"corner",1480,950,66)
    object(ctx,"arch",780,950,174)
    object(ctx,"pillar_ivy",630,950,75)
    object(ctx,"pillar_ivy",910,950,75)
    horizontal(ctx,160,390,870,["fence","fence_ivy"],40)
    horizontal(ctx,960,1080,880,["fence_ivy"],38)

static func paint_district(ctx: Node2D) -> void:
    horizontal(ctx,1536,3072,48,["wall","wall","wall_lamp"],44)
    side(ctx,3040,48,1376)
    horizontal(ctx,1536,1760,1390,["fence"],45)
    horizontal(ctx,1968,3072,1390,["fence","fence_ivy","fence"],45)
    object(ctx,"pillar",1760,1390,60)
    object(ctx,"pillar",1968,1390,60)
    horizontal(ctx,1660,1780,480,["fence"],36)
    horizontal(ctx,1880,2000,480,["fence_ivy"],36)
    horizontal(ctx,2700,2780,1130,["fence"],36)
    horizontal(ctx,2910,2980,1130,["fence_ivy"],36)

static func paint_north(ctx: Node2D) -> void:
    horizontal(ctx,65,640,-85,["fence","fence_ivy"],52)
    horizontal(ctx,928,1500,-85,["fence_ivy","fence"],52)
    horizontal(ctx,65,1500,-1650,["wall","wall_skull","wall_lamp"],52)
    # Portao fechado apenas no limite final do mapa, nao em uma rota jogavel.
    object(ctx,"gate",780,-1650,116)
