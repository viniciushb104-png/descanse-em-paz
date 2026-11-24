extends SceneTree
## Testa escala logica, sinais de joystick e fechamento de dialogos.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game: Node2D = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game._close()
    var hud: Control = game.get("mobile_hud") as Control
    if hud == null:
        push_error("HUD touch nao criada")
        quit(111)
        return
    hud.set_touch_preview(true)
    hud.set_playable(true)
    if not hud.visible or not hud.has_node("Joystick"):
        push_error("Joystick touch nao apareceu")
        quit(112)
        return
    var stick: Control = hud.get_node("Joystick")
    stick._set_direction(Vector2(180,94))
    if game.player.virtual_direction.x < 0.5:
        push_error("Joystick nao transmite movimento ao personagem")
        quit(113)
        return
    stick.reset()
    if game.player.virtual_direction.length_squared() > 0.0:
        push_error("Joystick nao solta o controle")
        quit(114)
        return
    game._show("Texto longo para celular","Este texto deve caber em uma caixa com rolagem vertical e texto ajustado automaticamente. "+("informacao adicional. ".repeat(80)),[{"text":"Uma opcao bastante longa para testar quebra de linha e leitura","action":"close"}])
    await process_frame
    if not game.dialog_panel.visible or hud.visible:
        push_error("Controles nao foram ocultados durante dialogo")
        quit(115)
        return
    var scroll := game.dialog_panel.get_node_or_null("BodyScroll") as ScrollContainer
    if scroll == null or scroll.size.y < 90.0:
        push_error("Dialogo nao tem area rolavel")
        quit(116)
        return
    game._close()
    game._refresh_ui()
    if not hud.visible:
        push_error("Controles nao voltaram apos dialogo")
        quit(117)
        return
    print("MOBILE OK: touch, joystick, dialogo responsivo e HUD contextualmente visivel")
    quit(0)
