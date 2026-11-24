extends SceneTree
const WALLS = preload("res://scripts/world/boundary_art.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    for p in [Vector2(778,645),Vector2(572,505),Vector2(155,430),Vector2(550,800),Vector2(1141,704),Vector2(350,944),Vector2(940,480)]:
        if game.can_player_stand(p):
            push_error("Objeto atravessavel: "+str(p))
            quit(211)
            return
    for p in [Vector2(778,680),Vector2(572,540),Vector2(780,944),Vector2(780,960),Vector2(2352,40),Vector2(425,476),Vector2(1270,407),Vector2(1125,630)]:
        if not game.can_player_stand(p):
            push_error("Acesso bloqueado: "+str(p))
            quit(212)
            return
    for portal in WALLS.ARCHES:
        var rect: Rect2 = WALLS.arch_rect(portal)
        var pillar := Vector2(rect.position.x+rect.size.x*0.18,rect.end.y-10)
        if game.can_player_stand(pillar):
            push_error("Pilar sem colisao")
            quit(213)
            return
    var depth: Node2D = game.get_node("DepthLayer")
    if depth.portals.size()!=3 or depth.portal_depth(Vector2(780,900),950)<=game.player.z_index or depth.portal_depth(Vector2(780,975),950)>=game.player.z_index:
        push_error("Ordem de desenho do arco invalida")
        quit(214)
        return
    var start := Vector2(400,930)
    var end: Vector2 = game.player.resolve_motion(start,Vector2(0,65))
    if end.y>=938.0 or end.y<start.y:
        push_error("Movimento atravessou muro")
        quit(215)
        return
    var passage: Vector2 = game.player.resolve_motion(Vector2(780,910),Vector2(0,90))
    if passage.y<995.0:
        push_error("Portal central nao permite passagem")
        quit(216)
        return
    var rooms: Node = game.get_node("RoomsRuntime")
    rooms.room="office"
    rooms.apply_room()
    if depth.visible:
        quit(217)
        return
    print("PHYSICS OK: bases solidas, vao livre, profundidade, movimento e interiores.")
    quit(0)
