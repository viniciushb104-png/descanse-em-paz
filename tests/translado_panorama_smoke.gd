extends SceneTree
const ARCADE = preload("res://scripts/minigames/translado.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game = ARCADE.new()
    root.add_child(game)
    game.set_physics_process(false)
    await process_frame
    if ARCADE.PANORAMAS.size()!=6 or ARCADE.REGION_NAMES.size()!=6:
        push_error("Panoramas ausentes")
        quit(101)
        return
    for i in range(6):
        var tex: Texture2D = ARCADE.PANORAMAS[i]
        if tex==null or tex.get_width()!=1536 or tex.get_height()!=512:
            push_error("Textura panoramica HD invalida")
            quit(102)
            return
        game.distance = (float(i)+0.5)*ARCADE.REGION_SPAN
        if game._panorama_index(game.distance)!=i:
            push_error("Regiao incorreta")
            quit(103)
            return
        game.board.queue_redraw()
        await process_frame
    if game._panorama_blend(0.0)!=0.0 or game._panorama_blend(490.0)<=0.0 or game._panorama_index(3000.0)!=5:
        push_error("Transicao de panorama invalida")
        quit(104)
        return
    var depth: float = (ARCADE.PLAYER_Y-ARCADE.HORIZON)/(ARCADE.VIEW.y-ARCADE.HORIZON)
    for model in range(6):
        var width: float = game._traffic_width(depth,model)
        if width < ARCADE.PLAYER_WIDTH*0.85 or width > ARCADE.PLAYER_WIDTH*1.16 or game._traffic_width(0.1,model)>=width:
            push_error("Escala de perspectiva incorreta")
            quit(105)
            return
    for tex in [ARCADE.ROAD_ASPHALT,ARCADE.ROAD_COBBLES,ARCADE.ROAD_SHOULDER,ARCADE.ROAD_CURB,ARCADE.ROAD_MARKINGS,ARCADE.ROAD_FINISH,ARCADE.ROAD_CURVE,ARCADE.ROAD_CEMETERY]:
        if tex == null or tex.get_width() < 1 or tex.get_height() < 1:
            push_error("Arte de estrada ausente")
            quit(106)
            return
    if game._surface_at(750.0)!=ARCADE.ROAD_COBBLES or game._surface_at(1200.0)!=ARCADE.ROAD_ASPHALT:
        push_error("Piso incorreto")
        quit(107)
        return
    print("TRANSLADO PANORAMAS OK: 6 texturas HD, 6 regioes e transicao.")
    quit(0)
