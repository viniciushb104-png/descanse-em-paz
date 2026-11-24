extends SceneTree
const GHOST = preload("res://scripts/minigames/ghost_adventure.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game = GHOST.new()
    game.setup(0)
    root.add_child(game)
    game.set_physics_process(false)
    await process_frame
    for i in range(6):
        game.phase=i
        game._load_phase()
        if game.platforms.size()<10 or game.fragments.is_empty() or game.goal_x<=800.0:
            push_error("Fase incompleta")
            quit(1)
            return
        for j in range(game.platforms.size()-1):
            if game.platforms[j+1].position.x-game.platforms[j].end.x>70.0:
                push_error("Salto excessivo")
                quit(2)
                return
        game.pos=Vector2(game.goal_x,240)
        for k in range(game.fragments.size()):
            game.collected.append(k)
        game._physics_process(0.016)
        if not game.paused:
            push_error("Portão não concluiu fase")
            quit(3)
            return
    print("FANTASMA OK: seis fases e portões.")
    quit(0)
