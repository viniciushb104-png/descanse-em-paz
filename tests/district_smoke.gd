extends SceneTree
const DISTRICT = preload("res://scripts/world/district_layout.gd")
const GROUND = preload("res://scripts/world/ground_tiles.gd")
const LEGAL = preload("res://scripts/systems/legal_lessons.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    if not game.has_node("DistrictLayer"):
        push_error("DistrictLayer ausente")
        quit(81)
        return
    if GROUND.WIDTH * GROUND.TILE != 3072 or GROUND.HEIGHT * GROUND.TILE != 1408:
        push_error("Mapa nao expandido")
        quit(82)
        return
    var camera := game.get_node_or_null("Player/Camera2D") as Camera2D
    if camera == null or not camera.enabled:
        push_error("Camera nao segue o protagonista")
        quit(83)
        return
    if DISTRICT.STATIONS.size() != 9:
        push_error("Setores incompletos")
        quit(84)
        return
    for station in DISTRICT.STATIONS:
        if not game.is_walkable(station["p"]):
            push_error("Interacao inacessivel: " + str(station["id"]))
            quit(85)
            return
    for key in ["registro","cremacao","residuos","ambiente","transporte","preparo","valores"]:
        if not LEGAL.ITEMS.has(key):
            push_error("Fonte legal ausente: " + key)
            quit(86)
            return
    game._close()
    game.stage = 5
    var before: int = game.compliance
    game._on_choice("distrito_erro")
    if game.stage != 5 or game.compliance >= before:
        push_error("Atalho sem penalidade")
        quit(87)
        return
    for action in ["hospital_certo","cartorio_certo","garagem_certo","preparo_certo","crematorio_certo","ambiente_certo","orcamento_certo"]:
        game._on_choice(action)
    if game.stage != 12:
        push_error("Nova campanha nao terminou")
        quit(88)
        return
    if game.money < 0:
        push_error("Caixa invalido")
        quit(89)
        return
    game._close()
    for point in [Vector2(2200,585),Vector2(2210,1310)]:
        if not game.is_walkable(point):
            push_error("Acesso ao carro bloqueado")
            quit(90)
            return
        game.player.global_position = point
        if game._near_station().get("id","") != "carro":
            push_error("Carro sem interacao")
            quit(91)
            return
        game._try_interact()
        if not game.dialogue_open or game.dialog_title.text != "Seu Osvaldo":
            push_error("Dialogo do carro ausente")
            quit(92)
            return
        game._on_choice("drive_training")
        if not is_instance_valid(game.driving_layer):
            push_error("Minigame nao abriu")
            quit(93)
            return
        game._driving_finished(false,0)
        game._close()
        await process_frame
    print("DISTRICT OK: 7 estacoes, camera, 8 etapas e fontes oficiais.")
    quit(0)
