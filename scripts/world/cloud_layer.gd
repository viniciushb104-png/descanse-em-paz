extends Node2D
## Atmosfera externa: tres formas do sprite autoral, sem fisica ou input.
const CLOUD_ATLAS: Texture2D = preload("res://assets/sprites/nuvens_lobby.png")
const CELL := Vector2(96,30)
const LEFT := -600.0
const RIGHT := 3672.0
# x inicial, y do vento, largura no mundo, velocidade em px/s
const DRIFTS := [
    Vector4(180,140,440,12), Vector4(910,430,370,9),
    Vector4(510,780,520,14), Vector4(2240,190,480,11),
    Vector4(2840,810,400,13), Vector4(1720,1180,530,9),
    Vector4(360,-280,480,12), Vector4(2300,-390,550,10),
    Vector4(1020,-920,420,13), Vector4(2780,-1280,480,9),
    Vector4(630,1650,480,12), Vector4(2360,2070,520,11)
]
var sprites: Array[Sprite2D] = []
var elapsed := 0.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    for i in range(DRIFTS.size()):
        var d: Vector4 = DRIFTS[i]
        var cloud := Sprite2D.new()
        cloud.name = "Nuvem%02d" % (i+1)
        cloud.texture = CLOUD_ATLAS
        cloud.region_enabled = true
        cloud.region_filter_clip_enabled = true
        cloud.region_rect = Rect2(Vector2(0,float(i%3)*CELL.y),CELL)
        cloud.scale = Vector2.ONE * (d.z / CELL.x)
        cloud.position = Vector2(d.x,d.y)
        cloud.modulate = Color(1.0,1.0,1.0,0.27)
        cloud.flip_h = i%2==1
        add_child(cloud)
        sprites.append(cloud)

func _process(delta: float) -> void:
    if not visible:
        return
    elapsed += delta
    var minutes := float(get_parent().get("clock_minutes"))
    var night := clampf((minutes-875.0)/205.0,0.0,1.0)
    for i in range(sprites.size()):
        var d: Vector4 = DRIFTS[i]
        var cloud: Sprite2D = sprites[i]
        cloud.position.x = wrapf(cloud.position.x+d.w*delta,LEFT,RIGHT)
        cloud.position.y = d.y+sin(elapsed*0.12+float(i)*1.7)*9.0
        var alpha := lerpf(0.29,0.22,night) + 0.025*sin(elapsed*0.17+float(i))
        cloud.modulate = Color(1.0-night*0.12,1.0-night*0.09,1.0,alpha)
