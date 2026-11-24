extends SceneTree
const CASES = preload("res://scripts/systems/customer_cases.gd")
const ROOM_CATALOG = preload("res://scripts/world/interior_catalog.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    var r: Node = game.get_node("RoomsRuntime")
    if CASES.total()!=20 or ROOM_CATALOG.ROOMS.size()!=10:
        push_error("20 casos ou 10 interiores ausentes")
        quit(91)
        return
    game._close()
    if not game.has_node("DoorTransition"):
        push_error("Transicao de portas ausente")
        quit(90)
        return
    r.enter("funeraria")
    game._close()
    if not r.inside() or game.get_node("GroundLayer").visible or not game.get_node("InteriorLayer").visible:
        push_error("Transicao de entrada falhou")
        quit(92)
        return
    if not game.is_walkable(ROOM_CATALOG.ENTRY):
        push_error("Personagem preso no interior")
        quit(93)
        return
    game._on_choice("case_bad")
    if r.case_index != 0:
        push_error("Erro nao pode concluir caso")
        quit(94)
        return
    game._on_choice("case_best")
    if r.case_index != 1:
        push_error("Caso nao avancou")
        quit(95)
        return
    r.leave()
    if r.inside() or not game.get_node("GroundLayer").visible:
        push_error("Saida nao restaurou o exterior")
        quit(96)
        return
    r.enter("fornecedor")
    game._close()
    var before: int = int(r.inventory["urna"])
    game._on_choice("stock_urna")
    if int(r.inventory["urna"]) != before+2:
        push_error("Compra nao alterou estoque")
        quit(97)
        return
    for idx in range(1,CASES.total()):
        var item: Dictionary = CASES.active(idx)
        if r.inside():
            r.leave()
        r.enter(str(item["room"]))
        game._close()
        if not str(item["stock"]).is_empty():
            r.inventory[str(item["stock"])] = 6
        game._on_choice("case_best")
        if r.case_index != idx+1:
            push_error("Caso nao concluido: "+str(idx+1))
            quit(98)
            return
    if r.inside():
        r.leave()
    r.enter("maintenance")
    game._close()
    if not r.inside() or r.room != "maintenance" or not game.get_node("InteriorLayer").has_node("RoomArtwork"):
        push_error("Oficina sem interior proprio")
        quit(101)
        return
    var maintenance_art: Node2D = game.get_node("InteriorLayer/RoomArtwork")
    if maintenance_art.get_child_count() != 6 or not maintenance_art.has_node("Bancada"):
        push_error("Sprites reais da oficina incompletos")
        quit(103)
        return
    r.leave()
    r.enter("office")
    game._close()
    if not game.get_node("InteriorLayer").has_node("RoomArtwork"):
        push_error("Escritorio sem interior proprio")
        quit(102)
        return
    var office_art: Node2D = game.get_node("InteriorLayer/RoomArtwork")
    if office_art.get_child_count() != 6 or not office_art.has_node("Mesa"):
        push_error("Sprites reais do escritorio incompletos")
        quit(104)
        return
    for prop in office_art.get_children():
        var sprite := prop as Sprite2D
        if sprite == null or sprite.texture == null:
            push_error("Sprite com textura ausente")
            quit(105)
            return
    var transition: Node = game.get_node("DoorTransition")
    var door: TextureRect = transition.get_node_or_null("GothicCurtain/AnimatedGothicDoor")
    if door == null or door.texture == null:
        push_error("Animacao gotica de porta ausente")
        quit(106)
        return
    var cfg := ConfigFile.new()
    if cfg.load("user://save.cfg")!=OK:
        push_error("Salvamento de casos inexistente")
        quit(99)
        return
    if int(cfg.get_value("save","case_index",-1))!=CASES.total():
        push_error("Progresso de casos nao persistiu")
        quit(100)
        return
    print("INTERIORS OK: 10 salas, 20 casos, estoque, salvamento e transicoes.")
    quit(0)
