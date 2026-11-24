extends SceneTree
const MAP = preload("res://scripts/world/expansion_layout.gd")
const GROUND = preload("res://scripts/world/ground_tiles.gd")
const FIELD = preload("res://scripts/world/burial_field.gd")
const CATALOG = preload("res://scripts/systems/activity_catalog.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    if MAP.plots().size()!=24 or FIELD.north_plots().size()!=48:
        quit(201)
        return
    for p in [Vector2(2352,40),Vector2(2352,-100),Vector2(1522,-800),Vector2(2352,-800),Vector2(2200,2100)]:
        if not game.is_walkable(p) or GROUND.material_at_world(p)<0:
            push_error("Expansao inacessivel: "+str(p))
            quit(202)
            return
    for station in MAP.STATIONS:
        if not game.is_walkable(station["p"]) or not CATALOG.ACTIVITIES.has(station["activity"]):
            push_error("Estacao nova inacessivel: "+str(station["id"]))
            quit(203)
            return
        game.player.global_position=station["p"]
        if game._near_station().get("id","")!=station["id"]:
            quit(204)
            return
    if MAP.available("crypt",{}) or not MAP.available("crypt",{"restore":true}):
        quit(205)
        return
    var rooms: Node = game.get_node("RoomsRuntime")
    rooms.room="office"
    rooms.apply_room()
    if game.get_node("ExpansionLayer").visible:
        quit(206)
        return
    print("EXPANSION OK: quatro quadrantes, 24 jazigos novos e quatro missoes.")
    quit(0)
