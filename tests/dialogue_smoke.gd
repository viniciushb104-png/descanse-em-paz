extends SceneTree
const CASES = preload("res://scripts/systems/customer_cases.gd")
const DIALOGUES = preload("res://scripts/systems/dialogue_scenes.gd")
const CATALOG = preload("res://scripts/world/interior_catalog.gd")

func _initialize() -> void:
    call_deferred("_run")

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
            if choices.size()!=3 or int(choices[0]["grade"]) != 2 or int(choices[1]["grade"]) != 2:
                push_error("Caso sem escolhas validas: "+str(idx))
                quit(123)
                return
            var selected: int = idx % 2
            rooms.choose_dialogue_option(selected)
            if rooms.dialogue_step != step or not rooms.awaiting_reaction:
                push_error("Fala nao teve repercussao: "+str(idx))
                quit(124)
                return
            rooms.advance_dialogue()
        if rooms.case_index != idx:
            push_error("Caso encerrou sem auditoria")
            quit(125)
            return
        rooms.finish_case()
        if rooms.case_index != idx+1:
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
    rooms.choose_dialogue_option(0)
    rooms.advance_dialogue()
    var before_compliance: int = game.compliance
    rooms.choose_dialogue_option(2)
    if rooms.dialogue_step != 1 or rooms.last_grade != 0 or game.compliance >= before_compliance:
        push_error("Atalho inseguro nao bloqueado")
        quit(128)
        return
    rooms.retry_dialogue()
    rooms.choose_dialogue_option(1)
    rooms.advance_dialogue()
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
