extends CanvasLayer
## Troca sincronizada no quadro coberto, sem flashes do mapa ou do interior.
const CURTAIN = preload("res://scripts/ui/transition_curtain.gd")
var curtain: Control
var busy: bool = false

func _ready() -> void:
    layer = 80
    curtain = CURTAIN.new()
    curtain.name = "GothicCurtain"
    curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    curtain.mouse_filter = Control.MOUSE_FILTER_STOP
    curtain.visible = false
    add_child(curtain)

func travel(midpoint: Callable, finished: Callable = Callable()) -> void:
    if busy:
        return
    busy = true
    # O modo headless executa o mesmo efeito logico sem aguardar animacao.
    # Isso permite testar trocas de sala de maneira deterministica.
    if DisplayServer.get_name() == "headless":
        midpoint.call()
        _finish(finished)
        return
    curtain.closure = 0.0
    curtain.visible = true
    var sequence := create_tween()
    sequence.tween_property(curtain, "closure", 1.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    sequence.tween_callback(midpoint)
    sequence.tween_interval(0.07)
    sequence.tween_property(curtain, "closure", 0.0, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    sequence.tween_callback(_finish.bind(finished))

func _finish(finished: Callable) -> void:
    curtain.visible = false
    busy = false
    if finished.is_valid():
        finished.call()
