extends SceneTree
const CATALOG = preload("res://scripts/world/interior_catalog.gd")
const DIALOGUES = preload("res://scripts/systems/dialogue_scenes.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var rooms: Node = game.get_node("RoomsRuntime")
    rooms.room = ""
    rooms.apply_room()
    var starting_position: Vector2 = game.player.global_position
    game._interact("office")
    if not rooms.inside() or rooms.room != "office" or game.dialogue_open:
        push_error("E no escritorio deve entrar sem menu nem popup")
        quit(151)
        return
    if rooms.nearest(CATALOG.ENTRY).get("id","") == "exit":
        push_error("Spawn interno muito perto da saida")
        quit(152)
        return
    game.player.global_position = Vector2(575,551)
    game._try_interact()
    if rooms.inside() or game.dialogue_open:
        push_error("E na saida deve voltar para o mapa")
        quit(153)
        return
    if game.player.global_position.distance_to(starting_position)>1.0:
        push_error("Jogador nao voltou a origem")
        quit(154)
        return
    rooms.case_index = 0
    rooms._reset_dialogue()
    rooms.enter("funeraria")
    game._close()
    rooms.show_case()
    var first: Dictionary = DIALOGUES.scene(0,0,"Sr. Afonso")
    var good: int = -1
    for idx in range((first["choices"] as Array).size()):
        if int(first["choices"][idx]["grade"]) == 2:
            good = idx
    rooms.choose_dialogue_option(good)
    if rooms.dialogue_step != 1 or rooms.awaiting_reaction:
        push_error("Escolha segura deveria avancar diretamente")
        quit(155)
        return
    var dialog_text := game.dialog_panel.get_node("BodyScroll/DialogText") as Label
    if dialog_text == null or not game.dialog_panel.visible or dialog_text.text.find("Antes:")==-1:
        push_error("Fala seguinte precisa mostrar reacao")
        quit(156)
        return
    var second: Dictionary = DIALOGUES.scene(0,1,"Sr. Afonso")
    var unsafe: int = -1
    for idx in range((second["choices"] as Array).size()):
        if int(second["choices"][idx]["grade"]) == 0:
            unsafe = idx
    rooms.choose_dialogue_option(unsafe)
    if not rooms.awaiting_reaction or rooms.dialogue_step != 1:
        push_error("Atalho inseguro precisa de correcao")
        quit(157)
        return
    rooms.retry_dialogue()
    if rooms.awaiting_reaction or rooms.dialogue_step!=1:
        push_error("Jogador nao conseguiu corrigir conduta")
        quit(158)
        return
    print("PACING OK: entrada/saida sem pergunta, spawn seguro, reacoes em linha e reparo de risco.")
    quit(0)
