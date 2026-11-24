extends SceneTree
const WALLS = preload("res://scripts/world/boundary_art.gd")
const GROUND = preload("res://scripts/world/ground_tiles.gd")
const DISTRICT = preload("res://scripts/world/district_layout.gd")
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if WALLS.TEXTURES.size()!=10 or GROUND.TEXTURES.size()!=6:
        push_error("Pacotes de arte incompletos")
        quit(180)
        return
    for key in WALLS.TEXTURES:
        var tex: Texture2D = WALLS.TEXTURES[key]
        var im: Image = tex.get_image()
        if im==null or im.is_empty() or not im.detect_alpha():
            push_error("PNG sem transparencia: "+str(key))
            quit(181)
            return
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    for p in [Vector2(780,40),Vector2(780,-85),Vector2(780,944),Vector2(1500,600),Vector2(1860,1386),Vector2(2200,585),Vector2(2210,1310)]:
        if not game.is_walkable(p):
            push_error("Passagem bloqueada: "+str(p))
            quit(182)
            return
    for station in DISTRICT.STATIONS:
        if not game.is_walkable(station["p"]) or GROUND.material_at_world(station["p"]) in [GROUND.GRASS,GROUND.DIRT,-1]:
            push_error("Entrada invalida: "+str(station["id"]))
            quit(183)
            return
    for p in [Vector2(1499,400),Vector2(350,944),Vector2(1700,475)]:
        if game.is_walkable(p):
            push_error("Limite atravessavel: "+str(p))
            quit(184)
            return
    print("BOUNDARY OK: 10 PNGs, 6 pisos, entradas e colisoes.")
    quit(0)
