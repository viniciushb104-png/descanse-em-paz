extends SceneTree
const CASES = preload("res://scripts/systems/customer_cases.gd")
const ROOM_CATALOG = preload("res://scripts/world/interior_catalog.gd")
func _initialize() -> void:
    call_deferred("_run")
func _finish_field_case(game: Node, runtime: Node, idx: int) -> bool:
    if not int(idx+1) in runtime.BURIAL_CASES:
        return true
    if runtime.case_index!=idx:
        return false
    runtime.authorize_burial()
    var key: String = runtime.pending_burial_id
    if key.is_empty() or runtime.case_index!=idx:
        return false
    var previous_money: int = game.money
    runtime.authorize_burial()
    if game.money!=previous_money:
        return false
    # Simulate completed field work, then assert single credit.
    if not game.burial_queue.complete(key) or not runtime.complete_burial(key):
        return false
    game._save_game()
    return runtime.case_index==idx+1 and not runtime.complete_burial(key)

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    var r: Node = game.get_node("RoomsRuntime")
    if CASES.total()!=20 or ROOM_CATALOG.ROOMS.size()!=11:
        push_error("20 casos ou 11 interiores ausentes")
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
    r.show_case()
    var partial: int = -1
    var first_scene: Dictionary = r.DIALOGUES.scene(0,0,"Sr. Afonso")
    for n in range(3):
        if int(first_scene["choices"][n]["grade"]) == 1:
            partial = n
    game._on_choice("case_pick_"+str(partial))
    var unsafe_option: int = -1
    var second_scene: Dictionary = r.DIALOGUES.scene(0,1,"Sr. Afonso")
    for n in range(3):
        if int(second_scene["choices"][n]["grade"]) == 0:
            unsafe_option = n
    game._on_choice("case_pick_"+str(unsafe_option))
    if r.case_index != 0 or r.dialogue_step != 1:
        push_error("Atalho nao pode concluir caso")
        quit(94)
        return
    game._on_choice("case_retry")
    var safe_option: int = 0
    for n in range(3):
        if int(second_scene["choices"][n]["grade"]) == 2:
            safe_option = n
    game._on_choice("case_pick_"+str(safe_option))
    # Uma escolha inicial parcial nao invalida todo o caso; o conjunto
    # das duas decisoes ainda pode atingir o criterio responsavel.
    if not _finish_field_case(game,r,0) or r.case_index != 1:
        push_error("Caso nao avancou apos dialogo completo")
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
        r.show_case()
        while r.case_index == idx and r.dialogue_step < r.DIALOGUES.beat_keys(idx).size():
            var beat: Dictionary = r.DIALOGUES.scene(idx,r.dialogue_step,str(item["client"]))
            var best: int = 0
            for n in range(3):
                if int(beat["choices"][n]["grade"]) == 2:
                    best = n
            game._on_choice("case_pick_"+str(best))
        if not _finish_field_case(game,r,idx) or r.case_index != idx+1:
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
