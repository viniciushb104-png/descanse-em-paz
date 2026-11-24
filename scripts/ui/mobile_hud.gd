extends Control
## Controles touch ancorados aos cantos da tela em landscape.
## Nao cobre o mundo com um painel gigante: apenas joystick e botoes capturam toque.
signal direction_changed(direction: Vector2)
signal interact_requested
signal menu_requested
signal journal_requested
const JOYSTICK = preload("res://scripts/ui/mobile_joystick.gd")
var touch_enabled: bool = false
var allowed_to_move: bool = true
var joystick: Control

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    touch_enabled = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
    _build()
    _sync_visibility()

func _build() -> void:
    joystick = JOYSTICK.new()
    joystick.name = "Joystick"
    add_child(joystick)
    joystick.anchor_left = 0.0
    joystick.anchor_right = 0.0
    joystick.anchor_top = 1.0
    joystick.anchor_bottom = 1.0
    joystick.offset_left = 18.0
    joystick.offset_right = 206.0
    joystick.offset_top = -211.0
    joystick.offset_bottom = -23.0
    joystick.direction_changed.connect(func(value: Vector2) -> void: direction_changed.emit(value))
    _make_button("INTERAGIR",Vector2(-147,-116),Vector2(131,90),interact_requested)
    _make_button("DIARIO",Vector2(-275,-91),Vector2(117,62),journal_requested)
    _make_button("MENU",Vector2(-151,-202),Vector2(129,67),menu_requested)

func _make_button(label_text: String, lower_right_offset: Vector2, dimensions: Vector2, signal_to_emit: Signal) -> void:
    var button := Button.new()
    button.name = label_text.capitalize()
    button.text = label_text
    button.anchor_left = 1.0
    button.anchor_right = 1.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.offset_left = lower_right_offset.x
    button.offset_top = lower_right_offset.y
    button.offset_right = lower_right_offset.x+dimensions.x
    button.offset_bottom = lower_right_offset.y+dimensions.y
    button.add_theme_font_size_override("font_size",19)
    button.add_theme_color_override("font_color",Color("#f7ead0"))
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#34223fd9")
    normal.border_color = Color("#dab47b")
    normal.set_border_width_all(3)
    normal.set_corner_radius_all(18)
    button.add_theme_stylebox_override("normal",normal)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("#7c486b")
    button.add_theme_stylebox_override("pressed",pressed)
    button.add_theme_stylebox_override("hover",pressed)
    button.pressed.connect(func() -> void: signal_to_emit.emit())
    add_child(button)

func set_touch_preview(enabled: bool) -> void:
    touch_enabled = enabled
    _sync_visibility()

func set_playable(allowed: bool) -> void:
    if allowed_to_move == allowed:
        return
    allowed_to_move = allowed
    if not allowed and joystick != null:
        joystick.reset()
    _sync_visibility()

func _sync_visibility() -> void:
    visible = touch_enabled and allowed_to_move
    if not visible and joystick != null and (joystick.direction as Vector2).length_squared()>0.0:
        joystick.reset()
