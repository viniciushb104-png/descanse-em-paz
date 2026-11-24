extends CanvasLayer
## Animacao com os oito quadros reais da porta gotica produzida para o jogo.
## Fechamento cobre o mundo ANTES da troca de sala; abertura revela a sala.
const CURTAIN = preload("res://scripts/ui/transition_curtain.gd")
const DOOR_FRAMES: Texture2D = preload("res://assets/interiors/transitions/door_anim_8.png")
const FRAME := Vector2i(68,95)
var curtain: Control
var door_sprite: TextureRect
var busy: bool = false

func _ready() -> void:
    layer = 80
    curtain = CURTAIN.new()
    curtain.name = "GothicCurtain"
    curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    curtain.mouse_filter = Control.MOUSE_FILTER_STOP
    curtain.visible = false
    add_child(curtain)

    door_sprite = TextureRect.new()
    door_sprite.name = "AnimatedGothicDoor"
    door_sprite.anchor_left = 0.5
    door_sprite.anchor_right = 0.5
    door_sprite.anchor_top = 0.5
    door_sprite.anchor_bottom = 0.5
    door_sprite.offset_left = -112.0
    door_sprite.offset_right = 112.0
    door_sprite.offset_top = -170.0
    door_sprite.offset_bottom = 146.0
    door_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    door_sprite.stretch_mode = TextureRect.STRETCH_SCALE
    door_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    door_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
    curtain.add_child(door_sprite)
    _show_frame(0)

func _show_frame(index: int) -> void:
    var frame := AtlasTexture.new()
    frame.atlas = DOOR_FRAMES
    frame.region = Rect2(Vector2((index % 4) * FRAME.x, (index / 4) * FRAME.y), Vector2(FRAME))
    door_sprite.texture = frame

func travel(midpoint: Callable, finished: Callable = Callable()) -> void:
    if busy:
        return
    busy = true
    # Headless executa troca sem atrasos e permite teste deterministico.
    if DisplayServer.get_name() == "headless":
        midpoint.call()
        _finish(finished)
        return
    curtain.closure = 0.0
    curtain.visible = true
    _show_frame(0)
    var sequence := create_tween()
    sequence.tween_property(curtain, "closure", 0.86, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    for frame_index in range(1, 4):
        sequence.tween_callback(_show_frame.bind(frame_index))
        sequence.tween_interval(0.035)
    sequence.tween_property(curtain, "closure", 1.0, 0.06)
    sequence.tween_callback(midpoint)
    for frame_index in range(4, 8):
        sequence.tween_callback(_show_frame.bind(frame_index))
        sequence.tween_interval(0.035)
    sequence.tween_property(curtain, "closure", 0.0, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    sequence.tween_callback(_finish.bind(finished))

func _finish(finished: Callable) -> void:
    curtain.visible = false
    busy = false
    if finished.is_valid():
        finished.call()
