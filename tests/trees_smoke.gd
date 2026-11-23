extends SceneTree
const DATA = preload("res://scripts/world/trees_layout.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var level: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(level)
    await process_frame
    if not level.has_node("TreeLayer"):
        push_error("Camada TreeLayer ausente")
        quit(51)
        return
    if DATA.ITEMS.size() != 4:
        push_error("Lote inicial deve conter 4 arvores")
        quit(52)
        return
    var roots := {}
    for item in DATA.ITEMS:
        var id: String = str(item["id"])
        if roots.has(id):
            push_error("Identificador duplicado: " + id)
            quit(53)
            return
        roots[id] = true
        var sprite := level.get_node_or_null("TreeLayer/" + id) as Sprite2D
        if sprite == null or sprite.texture == null:
            push_error("Sprite da arvore ausente: " + id)
            quit(54)
            return
        var pos: Vector2 = item["pos"]
        var size: Vector2 = item["size"]
        if pos.x < 0 or pos.y < 0 or pos.x + size.x > 1536 or pos.y + size.y > 960:
            push_error("Arvore cortada no mapa: " + id)
            quit(55)
            return
    for path_point in [Vector2(748,714),Vector2(1125,630),Vector2(425,476),Vector2(1270,407),Vector2(778,638),Vector2(572,500)]:
        if DATA.is_blocked(path_point):
            push_error("Arvore bloqueou spawn ou interacao " + str(path_point))
            quit(56)
            return
    var player := level.get_node("Player") as CharacterBody2D
    if not level.is_walkable(player.global_position):
        push_error("Jogador aparece preso no mapa")
        quit(57)
        return
    print("TREES OK: 4 PNGs, escala, enquadramento, troncos e interacoes livres")
    quit(0)
