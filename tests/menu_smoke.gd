extends SceneTree
## Garante que a nova tela abre, os botoes atuam e o jogo permanece acessivel.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var configured_scene: String = str(ProjectSettings.get_setting("application/run/main_scene"))
    if configured_scene != "res://scenes/menu/main_menu.tscn":
        push_error("A cena principal nao e o menu.")
        quit(71)
        return

    var menu := load("res://scenes/menu/main_menu.tscn").instantiate() as Control
    root.add_child(menu)
    await process_frame
    var continue_button := menu.get("continue_button") as Button
    if continue_button == null:
        push_error("Botao Continuar ausente.")
        quit(72)
        return
    if continue_button.disabled == FileAccess.file_exists("user://save.cfg"):
        push_error("Estado de Continuar nao acompanha o salvamento.")
        quit(73)
        return

    menu.show_how_to_play()
    var overlay := menu.get_node_or_null("ModalOverlay") as ColorRect
    if overlay == null or not overlay.visible:
        push_error("Ajuda nao abriu.")
        quit(74)
        return
    menu._close_modal()
    if overlay.visible:
        push_error("Ajuda nao fechou.")
        quit(75)
        return
    menu.show_credits()
    if not overlay.visible:
        push_error("Creditos nao abriram.")
        quit(76)
        return

    var level := load("res://scenes/main.tscn").instantiate() as Node2D
    root.add_child(level)
    await process_frame
    var player := level.get_node_or_null("Player") as CharacterBody2D
    if player == null:
        push_error("Cena de jogo nao abre mais depois do menu.")
        quit(77)
        return
    level._close()
    level._open_pause_menu()
    if not bool(level.get("dialogue_open")):
        push_error("Menu de pausa nao abriu.")
        quit(78)
        return
    level._close()
    print("MENU OK: cena principal, botao continuar, ajuda, creditos e pausa.")
    quit(0)
