extends SceneTree
## Regressao do NPC gato: interacao, carinho, mobilidade e missoes intocadas.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var cat := game.get_node_or_null("GatoDoCemiterio") as Node2D
    if cat == null or not game.is_walkable(cat.global_position):
        push_error("Gato ausente ou sobre uma area bloqueada")
        quit(201)
        return
    var money_before: int = game.money
    var stage_before: int = game.stage
    var case_before: int = game.get_node("RoomsRuntime").case_index
    var player := game.get_node("Player") as CharacterBody2D
    player.global_position = cat.global_position + Vector2(30, 0)
    var nearby: Dictionary = game._near_station()
    if str(nearby.get("id","")) != "cemetery_cat":
        push_error("Gato nao pode ser localizado para carinho")
        quit(202)
        return
    game._try_interact()
    if not game.dialogue_open or game.dialog_title.text != "Gato do Cemiterio" or game.dialog_body.text != "Miau!":
        push_error("Gato nao miou na interacao")
        quit(203)
        return
    game._on_choice("cat_pet")
    if game.dialogue_open or float(cat.get("pet_time")) <= 0.0:
        push_error("Carinho nao iniciou animacao ou fechou dialogo")
        quit(204)
        return
    if game.money != money_before or game.stage != stage_before or game.get_node("RoomsRuntime").case_index != case_before:
        push_error("Carinho alterou progresso financeiro ou missao")
        quit(205)
        return
    print("GATO OK: mia, recebe carinho, anima, nao cobra e nao altera missoes")
    quit(0)
