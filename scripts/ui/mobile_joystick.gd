extends Control
## Joystick analogico com um dedo. Suporta outro dedo nos botoes.
signal direction_changed(direction: Vector2)
const BASE := Color("#271d32ba")
const RING := Color("#c7a376")
const HANDLE := Color("#b18bab")
var active_touch: int = -1
var mouse_drag: bool = false
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and active_touch == -1 and not mouse_drag:
            active_touch = event.index
            _set_direction(event.position)
            accept_event()
        elif not event.pressed and event.index == active_touch:
            reset()
            accept_event()
    elif event is InputEventScreenDrag:
        if event.index == active_touch:
            _set_direction(event.position)
            accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and active_touch == -1:
            mouse_drag = true
            _set_direction(event.position)
            accept_event()
        elif not event.pressed and mouse_drag:
            reset()
            accept_event()
    elif event is InputEventMouseMotion and mouse_drag:
        _set_direction(event.position)
        accept_event()

func _set_direction(local_pos: Vector2) -> void:
    var center: Vector2 = size * 0.5
    var movement: Vector2 = (local_pos-center)/maxf(1.0,minf(size.x,size.y)*0.34)
    direction = movement.limit_length(1.0)
    direction_changed.emit(direction)
    queue_redraw()

func reset() -> void:
    active_touch = -1
    mouse_drag = false
    direction = Vector2.ZERO
    direction_changed.emit(Vector2.ZERO)
    queue_redraw()

func _draw() -> void:
    var middle: Vector2 = size*0.5
    var radius: float = minf(size.x,size.y)*0.45
    draw_circle(middle,radius,BASE)
    draw_arc(middle,radius-4,0,TAU,48,RING,4.0)
    draw_line(middle+Vector2(-radius*0.55,0),middle+Vector2(radius*0.55,0),RING.darkened(0.6),2.0)
    draw_line(middle+Vector2(0,-radius*0.55),middle+Vector2(0,radius*0.55),RING.darkened(0.6),2.0)
    var knob: Vector2 = middle+direction*(radius*0.53)
    draw_circle(knob,radius*0.40,HANDLE)
    draw_arc(knob,radius*0.40,0,TAU,32,RING,3.0)
