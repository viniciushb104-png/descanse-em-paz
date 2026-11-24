extends SceneTree
const CASES = preload("res://scripts/systems/customer_cases.gd")
const DIALOGUES = preload("res://scripts/systems/dialogue_scenes.gd")
const CATALOG = preload("res://scripts/world/interior_catalog.gd")

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
    game._close()
    var rooms: Node = game.get_node("RoomsRuntime")
    rooms.case_index = 0
    rooms._reset_dialogue()
    game.money = 5000
    if CASES.total()!=20 or DIALOGUES.total()!=20:
        push_error("Historia nao cobre todos os 20 clientes")
        quit(121)
        return
    for idx in range(20):
        var room_id: String = str(CASES.CASES[idx]["room"])
        if rooms.inside():
            rooms.leave()
        rooms.enter(room_id)
        game._close()
        var item: Dictionary = CASES.CASES[idx]
        var need: String = str(item["stock"])
        if not need.is_empty():
            rooms.inventory[need] = 30
        var beats: int = DIALOGUES.beat_keys(idx).size()
        if beats != (2+int(idx/5)):
            push_error("Dificuldade escalonada incorreta: "+str(idx))
            quit(122)
            return
        rooms.show_case()
        for step in range(beats):
            var scene: Dictionary = DIALOGUES.scene(idx,step,str(item["client"]))
            var choices: Array = scene["choices"]
            var good_count: int = 0
            var selected: int = -1
            var allowed_tone: String = "humor" if idx % 2 == 0 else "sereno"
            for n in range(choices.size()):
                var option: Dictionary = choices[n]
                if int(option["grade"]) == 2:
                    good_count += 1
                    if selected < 0:
                        selected = n
                    if str(option["tone"]) == allowed_tone:
                        selected = n
            if choices.size()!=3 or good_count!=2 or selected<0:
                push_error("Caso sem escolhas plurais responsaveis: "+str(idx))
                quit(123)
                return
            rooms.choose_dialogue_option(selected)
            if step < beats-1 and (rooms.dialogue_step != step+1 or rooms.awaiting_reaction):
                push_error("Fala nao avancou automaticamente: "+str(idx))
                quit(124)
                return
        if not _finish_field_case(game,rooms,idx) or rooms.case_index != idx+1:
            push_error("Caso nao concluiu: "+str(idx))
            quit(126)
            return
        if rooms.dialogue_step != 0 or rooms.dialogue_grades.size() != 0:
            push_error("Estado de dialogo nao foi reiniciado")
            quit(127)
            return
    rooms.case_index = 19
    rooms._reset_dialogue()
    rooms.leave()
    rooms.enter("funeraria")
    game._close()
    rooms.show_case()
    var first_scene: Dictionary = DIALOGUES.scene(19,0,"Familia de Aurora")
    var safe: int = -1
    for n in range(3):
        if int(first_scene["choices"][n]["grade"]) == 2:
            safe = n
    rooms.choose_dialogue_option(safe)
    var before_compliance: int = game.compliance
    var second_scene: Dictionary = DIALOGUES.scene(19,1,"Familia de Aurora")
    var dangerous: int = -1
    for n in range(3):
        if int(second_scene["choices"][n]["grade"]) == 0:
            dangerous = n
    rooms.choose_dialogue_option(dangerous)
    if rooms.dialogue_step != 1 or rooms.last_grade != 0 or game.compliance >= before_compliance:
        push_error("Atalho inseguro nao bloqueado")
        quit(128)
        return
    rooms.retry_dialogue()
    var repaired: int = -1
    for n in range(3):
        if int(second_scene["choices"][n]["grade"]) == 2:
            repaired = n
    rooms.choose_dialogue_option(repaired)
    if rooms.dialogue_step != 2:
        push_error("Reparacao nao permitiu prosseguir")
        quit(129)
        return
    var snapshot := ConfigFile.new()
    rooms.save_state(snapshot)
    var clone := Node.new()
    clone.set_script(load("res://scripts/systems/interior_runtime.gd"))
    root.add_child(clone)
    clone.load_state(snapshot)
    if clone.case_index != rooms.case_index or clone.dialogue_step != rooms.dialogue_step or clone.dialogue_grades.size() != rooms.dialogue_grades.size():
        push_error("Salvamento nao conserva o progresso parcial")
        quit(130)
        return
    var portrait := game.dialog_panel.get_node_or_null("ClientPortrait") as Control
    if portrait == null or not portrait.visible:
        push_error("Retrato de personagem nao aparece no dialogo")
        quit(131)
        return
    print("DIALOGUES OK: 20 historias, dificuldade 2-5, 2 estilos corretos, riscos reparaveis e save no meio de falas")
    quit(0)
