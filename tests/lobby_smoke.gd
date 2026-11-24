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
    for station in ["office","osvaldo","maintenance","ghost","plot","chapel"]:
        var found := false
        for target in game.STATIONS:
            if target["id"] == station:
                found = true
                if not game.is_walkable(target["p"]):
                    push_error("Sinalizacao ou decoracao bloqueou "+station)
                    quit(173)
                    return
        if not found:
            push_error("Interacao desapareceu: "+station)
            quit(174)
            return
    game.clock_minutes = 1080
    if decor.current_darkness() < 0.99:
        push_error("Iluminacao noturna nao acompanha o relogio")
        quit(175)
        return
    var rooms: Node = game.get_node("RoomsRuntime")
    rooms.room = "office"
    rooms.apply_room()
    if decor.visible:
        push_error("Ornamentacao do patio apareceu dentro do escritorio")
        quit(176)
        return
    rooms.room = ""
    rooms.apply_room()
    if not decor.visible:
        push_error("Decoracao nao voltou ao sair do escritorio")
        quit(177)
        return
    print("LOBBY OK: praça ornamental, sinalizacao, luzes, colisao e interiores.")
    quit(0)
