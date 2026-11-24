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

    # Fundo aprovado integrado em PNG original; nao pode bloquear mouse/toque.
    var background := menu.get_node_or_null("CemeteryMenuBackground") as TextureRect
    if background == null or background.texture == null:
        push_error("Fundo da turminha nao foi carregado no menu.")
        quit(84)
        return
    if background.texture.get_width() != 1152 or background.texture.get_height() != 648:
        push_error("Fundo do menu tem dimensoes incorretas.")
        quit(85)
        return
    if background.mouse_filter != Control.MOUSE_FILTER_IGNORE:
        push_error("Fundo bloqueia a interacao dos botoes.")
        quit(86)
        return
    if background.get_index() != 0:
        push_error("Fundo do menu deve ficar atras do logo e dos botoes.")
        quit(87)
        return

    # O logotipo PNG nao pode bloquear os botoes nem perder seu efeito pendurado.
    var logo := menu.get_node_or_null("HangingGameLogo") as TextureRect
    if logo == null or logo.texture == null or logo.texture.get_width() < 800:
        push_error("Logo RGBA do menu nao foi carregado.")
        quit(81)
        return
    var logo_image: Image = logo.texture.get_image()
    if logo_image == null or logo_image.is_empty() or not logo_image.detect_alpha():
        push_error("Logo deve ter canal alfa valido.")
        quit(84)
        return
    var logo_center: Color = logo_image.get_pixel(logo_image.get_width()/2,logo_image.get_height()/2)
    if logo_center.a < 0.7:
        push_error("Centro do logo parece transparente demais para ficar visivel.")
        quit(85)
        return
    if not logo.visible or not logo.is_visible_in_tree() or logo.z_index <= 0:
        push_error("Logo oculto ou sob outra camada.")
        quit(86)
        return
    # Evita o problema visual da v1.2.2: logo em tamanho nativo cobria personagens.
    if logo.size.x > 340.0 or logo.size.x < 260.0 or logo.position.x > 30.0 or logo.position.y > 18.0:
        push_error("Logo grande demais ou fora do canto: size=%s position=%s" % [str(logo.size),str(logo.position)])
        quit(88)
        return
    if logo.position.y + logo.size.y > 185.0 or logo.position.x + logo.size.x > 370.0:
        push_error("Logo nao cabe na area acima dos personagens.")
        quit(89)
        return
    if logo.stretch_mode != TextureRect.STRETCH_SCALE:
        push_error("Logo precisa escalar dentro da area reservada, nao no tamanho nativo.")
        quit(90)
        return
    if logo.mouse_filter != Control.MOUSE_FILTER_IGNORE:
        push_error("Logo bloqueia toques do menu.")
        quit(82)
        return
    menu._process(1.0)
    if absf(logo.rotation) <= 0.002:
        push_error("Logo nao possui a oscilacao pendurada.")
        quit(83)
        return
    # O menu cinematografico deve manter quatro botoes reais com placas visuais.
    var markers := menu.find_children("Memorial_*", "Control", true, false)
    if markers.size() != 4:
        push_error("Placas funerarias ausentes no menu.")
        quit(79)
        return
    var coffin_count: int = 0
    var grave_count: int = 0
    for marker in markers:
        if int(marker.get("shape_kind")) == 1:
            coffin_count += 1
        else:
            grave_count += 1
    if coffin_count != 2 or grave_count != 2:
        push_error("Menu deveria ter dois caixoes e duas lapides.")
        quit(80)
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
    print("MENU OK: fundo original, logo pendurado, lapides, caixoes, salvar, continuar e pausa.")
    quit(0)
