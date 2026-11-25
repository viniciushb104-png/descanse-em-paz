extends Control
## Opening cinematic. No video is required for the game to start.
const VIDEO_PATH := "res://assets/menu/abertura.ogv"
const STUDIO_LOGO_PATH := "res://assets/menu/logo_asas_do_medo.png"
const MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const COFFIN := preload("res://scripts/ui/menu_grave_marker.gd")
const CREDITS := [
    ["ASAS DO MEDO GAMES", "apresenta"],
    ["UMA CRIAÇÃO DE", "Vinicius Diniz"],
    ["HISTÓRIA E UNIVERSO", "Vinicius Diniz"],
    ["MÚSICA E DIREÇÃO ARTÍSTICA", "Vinicius Diniz"],
    ["DESENVOLVIMENTO", "Com auxílio de ChatGPT"],
    ["PRODUÇÃO AUDIOVISUAL", "Com auxílio de inteligência artificial"],
    ["DESENVOLVIDO COM", "Godot Engine"],
    ["ASAS DO MEDO GAMES", "Descanse em Paz & Pague em Dia"]
]
const CREDIT_SECONDS := 6.0

var video: VideoStreamPlayer
var credit_box: VBoxContainer
var credit_role: Label
var credit_name: Label
var start_button: Button
var start_marker: Control
var skip_button: Button
var closing := false
var started := false
var stalled_seconds := 0.0
var last_position := -1.0

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        _go_to_menu.call_deferred()
        return
    if ResourceLoader.exists(STUDIO_LOGO_PATH):
        var logo_texture := load(STUDIO_LOGO_PATH) as Texture2D
        if logo_texture != null:
            await _show_studio_logo(logo_texture)
    if closing or not is_inside_tree():
        return
    _prepare_video()

func _show_studio_logo(logo_texture: Texture2D) -> void:
    var splash := ColorRect.new()
    splash.name = "StudioLogoSplash"
    splash.color = Color.BLACK
    splash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(splash)
    splash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var logo := TextureRect.new()
    logo.name = "AsasDoMedoGamesLogo"
    logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    logo.texture = logo_texture
    splash.add_child(logo)
    logo.set_anchors_preset(Control.PRESET_CENTER)
    logo.offset_left = -390.0
    logo.offset_right = 390.0
    logo.offset_top = -165.0
    logo.offset_bottom = 95.0

    var presents := _credit_label(22, Color("#d9d0ca"))
    presents.text = "A P R E S E N T A"
    presents.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    splash.add_child(presents)
    presents.set_anchors_preset(Control.PRESET_CENTER)
    presents.offset_left = -300.0
    presents.offset_right = 300.0
    presents.offset_top = 110.0
    presents.offset_bottom = 152.0
    logo.modulate.a = 0.0
    presents.modulate.a = 0.0

    var fade := create_tween()
    fade.set_parallel(true)
    fade.tween_property(logo, "modulate:a", 1.0, 1.0)
    fade.tween_property(presents, "modulate:a", 1.0, 0.8).set_delay(0.35)
    fade.chain().tween_interval(1.8)
    fade.chain().tween_property(logo, "modulate:a", 0.0, 0.9)
    fade.parallel().tween_property(presents, "modulate:a", 0.0, 0.9)
    await fade.finished
    splash.queue_free()

func _prepare_video() -> void:
    if not ResourceLoader.exists(VIDEO_PATH):
        _go_to_menu.call_deferred()
        return
    var source := load(VIDEO_PATH) as VideoStream
    if source == null:
        _go_to_menu.call_deferred()
        return
    var background := ColorRect.new()
    background.color = Color.BLACK
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    video = VideoStreamPlayer.new()
    video.name = "OpeningVideo"
    video.expand = true
    video.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    video.mouse_filter = Control.MOUSE_FILTER_IGNORE
    video.stream = source
    video.finished.connect(_finish)
    add_child(video)
    video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_credits()
    skip_button = _coffin_button("PULAR ABERTURA  ›", Vector2(0.0, 0.0), true)
    skip_button.pressed.connect(_finish)
    if OS.has_feature("web"):
        # A gesture unlocks audio in browsers without playing the film silently.
        start_button = _coffin_button("ASSISTIR ABERTURA  ›", Vector2(0.0, 0.0), false)
        start_marker = start_button.get_parent() as Control
        start_button.pressed.connect(_start_video)
        start_button.grab_focus()
    else:
        _start_video()

func _coffin_button(caption: String, _unused: Vector2, corner: bool) -> Button:
    var marker := COFFIN.new() as Control
    marker.set("shape_kind", 1)
    add_child(marker)
    marker.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT if corner else Control.PRESET_CENTER)
    marker.offset_left = -268.0 if corner else -136.0
    marker.offset_right = -22.0 if corner else 136.0
    marker.offset_top = -76.0 if corner else -29.0
    marker.offset_bottom = -20.0 if corner else 29.0
    var button := Button.new()
    button.text = caption
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.add_theme_font_size_override("font_size", 18)
    button.add_theme_color_override("font_color", Color("#f5e9d5"))
    button.add_theme_color_override("font_hover_color", Color("#fff0b7"))
    var empty := StyleBoxEmpty.new()
    for state in ["normal", "hover", "pressed", "focus"]:
        button.add_theme_stylebox_override(state, empty)
    marker.add_child(button)
    button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    button.mouse_entered.connect(func() -> void: marker.set("highlighted", true))
    button.mouse_exited.connect(func() -> void: marker.set("highlighted", button.has_focus()))
    button.focus_entered.connect(func() -> void: marker.set("highlighted", true))
    button.focus_exited.connect(func() -> void: marker.set("highlighted", button.is_hovered()))
    return button

func _build_credits() -> void:
    credit_box = VBoxContainer.new()
    credit_box.name = "OpeningCredits"
    credit_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(credit_box)
    credit_box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    credit_box.offset_left = 42.0
    credit_box.offset_right = 690.0
    credit_box.offset_top = -146.0
    credit_box.offset_bottom = -49.0
    credit_box.add_theme_constant_override("separation", 5)
    credit_role = _credit_label(17, Color("#e2bb80"))
    credit_name = _credit_label(32, Color("#fff0d5"))
    credit_box.add_child(credit_role)
    credit_box.add_child(credit_name)
    credit_box.modulate.a = 0.0

func _credit_label(font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var serif := SystemFont.new()
    serif.font_names = PackedStringArray(["Georgia", "Liberation Serif", "Noto Serif", "serif"])
    label.add_theme_font_override("font", serif)
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    label.add_theme_color_override("font_outline_color", Color("#18111d"))
    label.add_theme_constant_override("outline_size", 6)
    return label

func _start_video() -> void:
    if started or closing:
        return
    started = true
    if is_instance_valid(start_marker):
        start_marker.hide()
    video.play()
    skip_button.grab_focus()

func _process(delta: float) -> void:
    if not started or closing or not is_instance_valid(video):
        return
    var position := video.stream_position
    if absf(position - last_position) < 0.001:
        stalled_seconds += delta
        if stalled_seconds > 10.0:
            _finish()
            return
    else:
        stalled_seconds = 0.0
    last_position = position
    var t := position - 1.5
    var index := int(floor(t / CREDIT_SECONDS))
    if t < 0.0 or index >= CREDITS.size():
        credit_box.modulate.a = 0.0
        return
    var local_time := fposmod(t, CREDIT_SECONDS)
    credit_role.text = str(CREDITS[index][0])
    credit_name.text = str(CREDITS[index][1])
    credit_box.modulate.a = clampf(minf(local_time / 0.9, (CREDIT_SECONDS - local_time) / 1.1), 0.0, 1.0)

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        _finish()
        get_viewport().set_input_as_handled()

func _finish() -> void:
    if closing:
        return
    closing = true
    if is_instance_valid(video):
        video.stop()
    var fade := ColorRect.new()
    fade.color = Color.BLACK
    fade.modulate.a = 0.0
    fade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(fade)
    fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var tween := create_tween()
    tween.tween_property(fade, "modulate:a", 1.0, 0.3)
    tween.tween_callback(_go_to_menu)

func _go_to_menu() -> void:
    get_tree().change_scene_to_file(MENU_SCENE)
