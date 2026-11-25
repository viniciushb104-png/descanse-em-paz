extends SceneTree
## Regressao da ornamentacao do lobby: sem alterar colisao, missoes ou interiores.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var decor := game.get_node_or_null("LobbyBeauty") as Node2D
    if decor == null or not decor.visible or decor.z_index >= game.get_node("PropsLayer").z_index:
        push_error("Camada ornamental ausente ou acima das fachadas")
        quit(171)
        return
    var spawn := Vector2(748,714)
    if not game.is_walkable(spawn):
        push_error("Lobby fechou o ponto de entrada do jogador")
        quit(172)
        return
    # Pontos de interacao conhecidos: independente do acesso a const do script.
    var points := {
        "office":Vector2(425,476), "osvaldo":Vector2(778,680),
        "maintenance":Vector2(1270,407), "ghost":Vector2(572,540),
        "plot":Vector2(1125,630), "chapel":Vector2(780,-175)
    }
    for station in points:
        if not game.is_walkable(points[station]):
            push_error("Sinalizacao ou decoracao bloqueou "+str(station))
            quit(173)
            return
    var field: Node = game.get_node("BurialField")
    if field.chapel_art != null:
        var old_height := minf(160.0,230.0*float(field.chapel_art.get_height())/maxf(1.0,float(field.chapel_art.get_width())))
        var body: Rect2 = field.chapel_body_rect()
        if not is_equal_approx(field._chapel_height(),old_height*1.45) or not is_equal_approx(body.end.y,-200.0) or body.size.x > 262.5:
            push_error("Escala ou base da capela incorreta")
            quit(182)
            return
        if game.can_player_stand(Vector2(780,-175)) == false or game.is_walkable(Vector2(780,-250)):
            push_error("Entrada ou colisao da capela invalida")
            quit(183)
            return
        for side in [Vector2(638,-365),Vector2(924,-365)]:
            if not game.can_player_stand(side):
                push_error("Corredor lateral da capela bloqueado: "+str(side))
                quit(184)
                return
    var ground = preload("res://scripts/world/ground_tiles.gd")
    for point in [Vector2(768,720),Vector2(768,800),Vector2(768,320),Vector2(768,192)]:
        if ground.material_at_world(point) != ground.STONE or not game.is_walkable(point):
            push_error("Alameda central ou praca interrompida: "+str(point))
            quit(178)
            return
    var clouds := game.get_node_or_null("CloudLayer") as Node2D
    if clouds == null or not clouds.visible or clouds.z_index <= game.get_node("DepthLayer").z_index or clouds.get_child_count() != 12:
        push_error("Camada de nuvens ausente ou incompleta")
        quit(179)
        return
    var cloud := clouds.get_child(0) as Sprite2D
    if cloud == null or cloud.texture == null or cloud.modulate.a <= 0.0 or cloud.modulate.a >= 0.5:
        push_error("Nuvem sem textura ou transparencia")
        quit(180)
        return
    var cloud_x := cloud.position.x
    clouds._process(1.0)
    if cloud.position.x == cloud_x:
        push_error("Nuvem sem movimento")
        quit(181)
        return
    game.clock_minutes = 1080
    if decor.current_darkness() < 0.99:
        push_error("Iluminacao noturna nao acompanha o relogio")
        quit(175)
        return
    var rooms: Node = game.get_node("RoomsRuntime")
    rooms.room = "office"
    rooms.apply_room()
    if decor.visible or clouds.visible:
        push_error("Ornamentacao do patio apareceu dentro do escritorio")
        quit(176)
        return
    rooms.room = ""
    rooms.apply_room()
    if not decor.visible or not clouds.visible:
        push_error("Decoracao nao voltou ao sair do escritorio")
        quit(177)
        return
    print("LOBBY OK: praça ornamental, sinalizacao, luzes, colisao e interiores.")
    quit(0)
