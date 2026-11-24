extends Node2D
## Camada de oclusao: so redesenha os objetos que interceptam o corpo do heroi
## e estao a frente de seus pes. Arcos sao sprites independentes, sem duplicacao.
const MAP = preload("res://scripts/map_art.gd")
const WALLS = preload("res://scripts/world/boundary_art.gd")
var portals: Array[Sprite2D] = []
var foot := Vector2.ZERO
var last_foot := Vector2(INF,INF)
var last_frame := -1
func _ready() -> void:
    z_index = 18
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for portal in WALLS.ARCHES:
        var rect: Rect2 = WALLS.arch_rect(portal)
        var sprite := Sprite2D.new()
        sprite.name = "Portal%d" % portals.size()
        sprite.texture = WALLS.TEXTURES["arch"]
        sprite.centered = false
        sprite.position = rect.position
        sprite.scale = rect.size/sprite.texture.get_size()
        sprite.z_as_relative = false
        sprite.z_index = 18
        add_child(sprite)
        portals.append(sprite)
func portal_depth(p: Vector2, base: float) -> int:
    return 18 if p.y<=base+4.0 else 1
func _process(_delta: float) -> void:
    if not visible:
        return
    var game: Node = get_parent()
    foot = game.get_node("Player").global_position
    for i in range(portals.size()):
        var portal: Vector3 = WALLS.ARCHES[i]
        portals[i].z_index = portal_depth(foot,portal.y)
    var frame := int(float(game.get("clock_minutes"))/3.0)
    if foot!=last_foot or frame!=last_frame:
        last_foot=foot
        last_frame=frame
        queue_redraw()
func accept_stamp(rect: Rect2) -> bool:
    # Origem do personagem nos pes; o corpo se estende para cima.
    return foot.y<=rect.end.y and rect.intersects(Rect2(foot-Vector2(34,80),Vector2(68,94)))
func _draw() -> void:
    if not visible:
        return
    var game: Node = get_parent()
    MAP.stamp(self,"office",168,116,466,315)
    MAP.stamp(self,"shed",1101,132,340,226)
    MAP.paint_plots(self,bool(game.get("reserved_plot")))
    MAP.paint_decoration(self)
    MAP.paint_characters(self,float(game.get("clock_minutes")))
    WALLS.paint_cemetery(self)
    WALLS.paint_district(self)
    WALLS.paint_north(self)
    WALLS.horizontal(self,1536,3072,-1650,["wall","wall_lamp","wall_skull"],58)
    var field: Node = game.get_node_or_null("BurialField")
    if is_instance_valid(field):
        field.call("paint_depth",self)
