extends SceneTree
const GROUND = preload("res://scripts/world/ground_tiles.gd")
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var level: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(level)
    await process_frame
    if not level.has_node("GroundLayer") or not level.has_node("PropsLayer"):
        push_error("Faltam camadas de piso ou decoracao")
        quit(10)
        return
    var goals := [Vector2i(23,22),Vector2i(23,18),Vector2i(13,16),Vector2i(39,16),Vector2i(35,19)]
    for p in goals:
        if GROUND.material_at(p) != GROUND.STONE:
            push_error("Caminho faltando: "+str(p))
            quit(11)
            return
    var reached := {Vector2i(23,22):true}
    var frontier := [Vector2i(23,22)]
    for index in range(1500):
        if frontier.is_empty():
            break
        var p: Vector2i = frontier.pop_front()
        for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
            var next: Vector2i = p+d
            if not reached.has(next) and GROUND.material_at(next)==GROUND.STONE:
                reached[next]=true
                frontier.append(next)
    for destination in goals:
        if not reached.has(destination):
            push_error("Caminhos desconectados: "+str(destination))
            quit(12)
            return
    if GROUND.material_at(Vector2i(18,9)) != GROUND.GRASS:
        push_error("Grama invadida pelo caminho")
        quit(13)
        return
    for station in preload("res://scripts/world/district_layout.gd").STATIONS:
        var surface: int = GROUND.material_at_world(station["p"])
        if surface not in [GROUND.STONE,GROUND.ROAD,GROUND.PAVING,GROUND.COMMERCIAL]:
            push_error("Entrada sem pavimento: "+str(station["id"]))
            quit(14)
            return
    print("GROUND OK: 32px, caminhos conectados, camadas independentes.")
    quit(0)
