extends SceneTree

# Executado pelo GitHub Actions no Godot headless.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var level: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(level)
    await process_frame
    var player: CharacterBody2D = level.get_node("Player")
    var sprite: Sprite2D = player.get_node("CharacterVisual")
    if sprite.texture == null or not sprite.visible:
        push_error("Personagem sem textura ou invisivel!")
        quit(1)
        return
    level._close()
    level._rescue_player()
    if player.global_position != Vector2(748, 714):
        push_error("Resgate nao posicionou no spawn!")
        quit(2)
        return
    Input.action_press("ui_right")
    await physics_frame
    await physics_frame
    await physics_frame
    Input.action_release("ui_right")
    if player.global_position.x <= 748.0:
        push_error("Personagem nao consegue caminhar!")
        quit(3)
        return
    if not level.is_walkable(player.global_position):
        push_error("Personagem caminhou para area invalida!")
        quit(4)
        return
    print("SMOKE OK: sprite visivel, resgate e movimento funcionando.")
    quit(0)
