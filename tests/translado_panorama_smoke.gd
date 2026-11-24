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
        if tex==null or tex.get_width()!=288 or tex.get_height()!=96:
            push_error("Textura panoramica invalida")
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
    print("TRANSLADO PANORAMAS OK: 6 texturas, 6 regioes e transicao.")
    quit(0)
