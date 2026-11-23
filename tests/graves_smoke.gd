extends SceneTree
const LAYOUT = preload("res://scripts/world/graves_layout.gd")

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var stage: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(stage)
    await process_frame
    if not stage.has_node("GravesLayer"):
        push_error("GravesLayer nao presente na cena")
        quit(31)
        return
    if LAYOUT.ITEMS.size() != 10:
        push_error("O Lote 1 deve conter exatamente 10 assets")
        quit(32)
        return
    var layer: Node2D = stage.get_node("GravesLayer")
    for item in LAYOUT.ITEMS:
        var node: Sprite2D = layer.get_node_or_null(str(item["id"])) as Sprite2D
        if node == null or node.texture == null:
            push_error("Sprite individual ausente: " + str(item["id"]))
            quit(33)
            return
        if node.texture.get_width() < 64 or node.texture.get_height() < 64:
            push_error("Textura pequena ou incorreta: " + str(item["id"]))
            quit(34)
            return
    var b13: Dictionary = LAYOUT.item_by_id("Cova_01")
    if b13.is_empty() or str(b13.get("slot", "")) != "B-13":
        push_error("B-13 nao mapeado para Cova_01")
        quit(35)
        return
    if LAYOUT.is_blocked(Vector2(1125, 630)):
        push_error("A interacao do B-13 ficou inacessivel")
        quit(36)
        return
    if not LAYOUT.is_blocked(Vector2(1125, 700)):
        push_error("A cova B-13 nao possui area de colisao")
        quit(37)
        return
    var player: CharacterBody2D = stage.get_node("Player")
    if not stage.is_walkable(player.global_position):
        push_error("O personagem ficou preso no mapa")
        quit(38)
        return
    print("GRAVES OK: 10 sprites, posicoes, areas de colisao e B-13 acessivel")
    quit(0)
