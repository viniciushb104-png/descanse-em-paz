extends Control
## Menu de abertura original para Santa Mortalha.
## Botões reais: continuar, novo jogo, instrucoes e creditos.
## O jogo continua separado em scenes/main.tscn.
const SAVE_PATH := "user://save.cfg"
const GAME_PATH := "res://scenes/main.tscn"
const INK := Color("#16121e")
const VIOLET := Color("#291b32")
const GOLD := Color("#dfb978")
const CREAM := Color("#f5e9d5")
const LILAC := Color("#c8a8cc")
const WORLD_ATLAS: Texture2D = preload("res://assets/art/world.png")
const TREE_LILAC: Texture2D = preload("res://assets/trees/Arvore_01.png")
const TREE_GOTHIC: Texture2D = preload("res://assets/trees/Arvore_10.png")
const TREE_TWISTED: Texture2D = preload("res://assets/trees/Arvore_06.png")
const MENU_BACKGROUND_PATH := "res://assets/menu/menu_turma.png"
const MENU_LOGO: Texture2D = preload("res://assets/menu/logo_descanse_em_paz.png")
const GRAVE_MARKER_SCRIPT := preload("res://scripts/ui/menu_grave_marker.gd")

var elapsed: float = 0.0
var continue_button: Button
var continue_marker: Control
var menu_background: TextureRect
var menu_logo: TextureRect
var new_button: Button
var modal_overlay: ColorRect
var modal_title: Label
var modal_body: Label
var modal_actions: HBoxContainer

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _install_background()
    _install_logo()
    _build_menu()
    _build_modal()
    _refresh_continue()
    if FileAccess.file_exists(SAVE_PATH):
        continue_button.grab_focus()
    else:
        new_button.grab_focus()

func _process(delta: float) -> void:
    elapsed += delta
    if is_instance_valid(menu_logo):
        # Placa presa no topo: rotacao pequena ao redor do ponto de suspensao.
        # Periodo ~7.6s, amplitude 1.5 grau; nunca sai do canto do menu.
        menu_logo.rotation = sin(elapsed * 0.83) * deg_to_rad(1.5)
    if menu_background == null:
        queue_redraw()

func _draw() -> void:
    if menu_background != null:
        return
    var viewport_size: Vector2 = size
    var width: float = viewport_size.x
    var height: float = viewport_size.y
    draw_rect(Rect2(Vector2.ZERO, viewport_size), INK, true)

    # Ceu sombrio, manchas de luz e estrelas pequenas.
    for band in range(11):
        var proportion: float = float(band) / 10.0
        var band_color := Color("#20182a").lerp(Color("#373047"), proportion)
        draw_rect(Rect2(0, height * proportion, width, height / 10.0 + 2), band_color)
    for index in range(83):
        var sx: float = float((index * 179 + 41) % 1100)
        var sy: float = float((index * 113 + 53) % 368)
        var shimmer: float = 0.35 + 0.22 * sin(elapsed * 0.8 + float(index))
        draw_rect(Rect2(sx, sy, 2, 2), Color(0.85, 0.76, 0.91, shimmer))
    var moon_center := Vector2(943, 141)
    for ring in range(6, 0, -1):
        draw_circle(moon_center, 56.0 + float(ring * 11), Color(0.70, 0.60, 0.80, 0.015))
    draw_circle(moon_center, 55, Color("#d0bbbf"))
    draw_circle(moon_center + Vector2(-11, -10), 9, Color("#b9a6b6", 0.54))
    draw_circle(moon_center + Vector2(18, 13), 6, Color("#b9a6b6", 0.44))

    # Silhueta da mata; elementos reais das nossas artes aparecem por cima.
    draw_rect(Rect2(0, 527, width, height - 527), Color("#161c20"))
    for tree_index in range(10):
        var px: float = float(630 + tree_index * 56)
        draw_line(Vector2(px, 553), Vector2(px, 470 - float(tree_index % 3) * 26), Color("#1f2528"), 13)
        draw_circle(Vector2(px, 461 - float(tree_index % 3) * 26), 33, Color("#1f2528"))
    draw_texture_rect(TREE_LILAC, Rect2(654, 266, 179, 279), false, Color(0.82, 0.78, 0.91, 0.93))
    draw_texture_rect(TREE_TWISTED, Rect2(1022, 267, 138, 275), false, Color(0.70, 0.74, 0.84, 0.89))
    draw_texture_rect(TREE_GOTHIC, Rect2(748, 195, 115, 243), false, Color(0.64, 0.59, 0.75, 0.75))
    draw_texture_rect_region(
        WORLD_ATLAS, Rect2(778, 290, 331, 247),
        Rect2(214, 298, 300, 223),
        Color(0.89, 0.81, 0.88, 0.96), false, true
    )
    # Pequenas lanternas sob o arco da capela.
    var glow: float = 0.12 + 0.05 * sin(elapsed * 2.4)
    draw_circle(Vector2(875, 465), 32, Color(1.0, 0.61, 0.28, glow))
    draw_circle(Vector2(1023, 468), 30, Color(1.0, 0.61, 0.28, glow))
    for fog_index in range(5):
        var drift: float = fposmod(float(fog_index * 276) + elapsed * (9.0 + float(fog_index)), 1600.0) - 160.0
        draw_rect(Rect2(drift, 543 + fog_index * 19, 205, 12), Color(0.78, 0.73, 0.85, 0.035), true)
    draw_line(Vector2(0, 621), Vector2(width, 621), GOLD.darkened(0.55), 2.0)

func _style(bg: Color, border_color: Color, radius_px: int = 9, border_width: int = 2) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border_color
    style.set_border_width_all(border_width)
    style.set_corner_radius_all(radius_px)
    return style

func _make_label(content: String, position_xy: Vector2, box_size: Vector2, font_size: int, color: Color, center: bool = false) -> Label:
    var label := Label.new()
    label.text = content
    label.position = position_xy
    label.size = box_size
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_outline_color", Color("#17121d"))
    label.add_theme_constant_override("outline_size", 2)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if center:
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(label)
    return label

func _make_button(title_text: String, font_size: int = 19) -> Button:
    var button := Button.new()
    button.text = title_text
    button.custom_minimum_size = Vector2(180, 48)
    button.add_theme_font_size_override("font_size", font_size)
    button.add_theme_color_override("font_color", CREAM)
    button.add_theme_color_override("font_hover_color", Color("#fff3cc"))
    button.add_theme_color_override("font_pressed_color", Color("#fff3cc"))
    button.add_theme_color_override("font_disabled_color", Color("#7c7288"))
    button.add_theme_stylebox_override("normal", _style(Color("#37253e"), Color("#93728a")))
    button.add_theme_stylebox_override("hover", _style(Color("#654267"), GOLD))
    button.add_theme_stylebox_override("pressed", _style(Color("#74516c"), Color("#f1d49d")))
    button.add_theme_stylebox_override("disabled", _style(Color("#29232f"), Color("#483f4d")))
    button.add_theme_stylebox_override("focus", _style(Color(0, 0, 0, 0), GOLD, 9, 3))
    return button

func _install_background() -> void:
    # A arte e um recurso opcional: testes e projeto continuam abrindo
    # enquanto o PNG esta sendo integrado ao repositorio.
    if not ResourceLoader.exists(MENU_BACKGROUND_PATH):
        return
    var image_texture := load(MENU_BACKGROUND_PATH) as Texture2D
    if image_texture == null:
        return
    menu_background = TextureRect.new()
    menu_background.name = "CemeteryMenuBackground"
    menu_background.texture = image_texture
    menu_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    menu_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    menu_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    menu_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_background.z_index = -5
    add_child(menu_background)
    menu_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _install_logo() -> void:
    menu_logo = TextureRect.new()
    menu_logo.name = "HangingGameLogo"
    # IMPORTANTE: ignorar o tamanho natural ANTES de atribuir a textura.
    # Caso contrario o Control conserva o minimo nativo (850px) e fica gigante.
    menu_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    menu_logo.stretch_mode = TextureRect.STRETCH_SCALE
    menu_logo.custom_minimum_size = Vector2.ZERO
    menu_logo.texture = MENU_LOGO

    # Mantem a placa pequena, no alto e a esquerda, acima dos personagens.
    var logo_width: float = 312.0
    var logo_height: float = logo_width * float(MENU_LOGO.get_height()) / float(MENU_LOGO.get_width())
    menu_logo.set_anchors_preset(Control.PRESET_TOP_LEFT)
    menu_logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    menu_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu_logo.z_index = 5
    menu_logo.modulate = Color.WHITE
    add_child(menu_logo)

    # Definir tamanho DEPOIS de adicionar ao pai garante geometria final.
    menu_logo.size = Vector2(logo_width,logo_height)
    menu_logo.position = Vector2(20,6)
    menu_logo.pivot_offset = Vector2(logo_width * 0.5,4.0)
    menu_logo.show()

func _add_memorial_button(title_text: String, y: float, is_coffin: bool) -> Button:
    var marker := GRAVE_MARKER_SCRIPT.new() as Control
    marker.name = "Memorial_" + title_text.replace(" ", "_")
    marker.position = Vector2(840, y)
    marker.size = Vector2(286, 56)
    marker.set("shape_kind", 1 if is_coffin else 0)
    marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(marker)

    var button := _make_button(title_text, 17)
    button.name = "Button_" + title_text.replace(" ", "_")
    button.position = marker.position
    button.size = marker.size
    button.custom_minimum_size = Vector2(250, 56)
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.focus_mode = Control.FOCUS_ALL
    # O Button e a area interativa; a lapide/caixao e desenhada atras.
    # Remove apenas o fundo padrao deste Button, nao dos botoes dos modais.
    var transparent_style := StyleBoxEmpty.new()
    for state in ["normal", "hover", "pressed", "disabled", "focus"]:
        button.add_theme_stylebox_override(state, transparent_style)
    button.add_theme_color_override("font_color", CREAM)
    button.add_theme_color_override("font_hover_color", Color("#fff2b8"))
    button.add_theme_color_override("font_pressed_color", GOLD)
    button.add_theme_color_override("font_focus_color", Color("#fff2b8"))
    button.add_theme_color_override("font_disabled_color", Color("#857983"))
    button.mouse_entered.connect(func() -> void: marker.set("highlighted", true))
    button.mouse_exited.connect(func() -> void: marker.set("highlighted", button.has_focus()))
    button.focus_entered.connect(func() -> void: marker.set("highlighted", true))
    button.focus_exited.connect(func() -> void: marker.set("highlighted", button.is_hovered()))
    add_child(button)
    if title_text == "CONTINUAR EXPEDIENTE":
        continue_marker = marker
    return button


func _build_menu() -> void:
    # A frase fica logo abaixo da placa, acima dos personagens.
    _make_label("A morte é inevitável. A burocracia também.", Vector2(30, 190), Vector2(420, 30), 15, LILAC)

    # Botões grandes sobre o gramado à direita; preservam mouse, teclado e toque.
    continue_button = _add_memorial_button("CONTINUAR EXPEDIENTE", 298.0, true)
    continue_button.pressed.connect(_continue_game)

    new_button = _add_memorial_button("NOVO JOGO", 361.0, true)
    new_button.pressed.connect(_request_new_game)

    var how_to := _add_memorial_button("COMO JOGAR", 424.0, false)
    how_to.pressed.connect(show_how_to_play)

    var credits := _add_memorial_button("CRÉDITOS", 487.0, false)
    credits.pressed.connect(show_credits)

    _make_label("VINICIUS DINIZ  ·  ASAS DO MEDO GAMES", Vector2(44, 612), Vector2(560, 25), 13, CREAM)


func _build_modal() -> void:
    modal_overlay = ColorRect.new()
    modal_overlay.name = "ModalOverlay"
    modal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_overlay.color = Color(0.045, 0.035, 0.09, 0.82)
    modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    # Quando abrir um modal, ele fica acima do logo animado.
    modal_overlay.z_index = 10
    add_child(modal_overlay)
    var panel := Panel.new()
    panel.name = "ModalPanel"
    panel.position = Vector2(252, 142)
    panel.size = Vector2(648, 363)
    panel.add_theme_stylebox_override("panel", _style(Color("#251b32"), GOLD, 12, 3))
    modal_overlay.add_child(panel)

    modal_title = Label.new()
    modal_title.position = Vector2(31, 24)
    modal_title.size = Vector2(585, 43)
    modal_title.add_theme_font_size_override("font_size", 28)
    modal_title.add_theme_color_override("font_color", GOLD)
    panel.add_child(modal_title)

    modal_body = Label.new()
    modal_body.position = Vector2(31, 83)
    modal_body.size = Vector2(588, 175)
    modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    modal_body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    modal_body.add_theme_font_size_override("font_size", 18)
    modal_body.add_theme_color_override("font_color", CREAM)
    panel.add_child(modal_body)

    modal_actions = HBoxContainer.new()
    modal_actions.position = Vector2(31, 289)
    modal_actions.size = Vector2(586, 54)
    modal_actions.alignment = BoxContainer.ALIGNMENT_CENTER
    modal_actions.add_theme_constant_override("separation", 12)
    panel.add_child(modal_actions)
    modal_overlay.visible = false

func _show_modal(title_text: String, body_text: String, options: Array) -> void:
    modal_title.text = title_text
    modal_body.text = body_text
    for old_button in modal_actions.get_children():
        modal_actions.remove_child(old_button)
        old_button.queue_free()
    for option in options:
        var button: Button = _make_button(str(option["label"]), 16)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(option["callback"])
        modal_actions.add_child(button)
    modal_overlay.visible = true
    if modal_actions.get_child_count() > 0:
        (modal_actions.get_child(0) as Button).grab_focus()

func _close_modal() -> void:
    modal_overlay.visible = false
    _refresh_continue()
    if FileAccess.file_exists(SAVE_PATH):
        continue_button.grab_focus()
    else:
        new_button.grab_focus()

func _refresh_continue() -> void:
    var has_save := FileAccess.file_exists(SAVE_PATH)
    continue_button.disabled = not has_save
    continue_button.text = "CONTINUAR EXPEDIENTE" if has_save else "SEM SALVAMENTO"
    if is_instance_valid(continue_marker):
        continue_marker.set("disabled_visual", not has_save)

func _continue_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        _refresh_continue()
        return
    _open_game()

func _request_new_game() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        _show_modal(
            "UM NOVO COMEÇO?",
            "Já existe um expediente salvo em Santa Mortalha.\n\nComeçar um novo jogo vai substituir esse salvamento. Você deseja mesmo recomeçar?",
            [{"label":"CANCELAR", "callback":Callable(self, "_close_modal")}, {"label":"SIM, RECOMEÇAR", "callback":Callable(self, "_start_new_game")}]
        )
    else:
        _start_new_game()

func _start_new_game() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var result: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
        if result != OK:
            _show_modal(
                "NÃO FOI POSSÍVEL RECOMEÇAR",
                "O salvamento não pôde ser apagado. Seu progresso continua preservado. Tente novamente.",
                [{"label":"VOLTAR", "callback":Callable(self, "_close_modal")}]
            )
            return
    _open_game()

func _open_game() -> void:
    var result: Error = get_tree().change_scene_to_file(GAME_PATH)
    if result != OK:
        _show_modal("ERRO AO ABRIR O JOGO", "Não foi possível carregar o cemitério. Confira os arquivos da instalação.", [{"label":"VOLTAR", "callback":Callable(self, "_close_modal")}])

func show_how_to_play() -> void:
    _show_modal(
        "COMO JOGAR",
        "Você herdou um cemitério cheio de histórias e contas para pagar!\n\nWASD ou setas: caminhar  •  E: interagir\nR: voltar a uma posição segura  •  Esc: abrir o menu\n\nExplore predios por dentro, atenda familias e gerencie o estoque de urnas e caixoes. Todos os valores sao ficticios.",
        [{"label":"VOLTAR", "callback":Callable(self, "_close_modal")}]
    )

func show_credits() -> void:
    _show_modal(
        "CRÉDITOS",
        "Criação, universo e direção: Vinicius Diniz\nProdução: Asas do Medo Games\nDesenvolvimento com auxílio de ChatGPT\nMotor de jogo: Godot Engine\n\nSanta Mortalha é uma comédia gótica. A gestão funerária é apresentada de forma educativa e simplificada.",
        [{"label":"VOLTAR", "callback":Callable(self, "_close_modal")}]
    )

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and modal_overlay.visible:
        _close_modal()
        get_viewport().set_input_as_handled()
