extends Control
## Treino de translado: pista fechada, sem alterar o mundo ou o caso ativo.
signal finished(success: bool, bumps: int)
var car := Vector2(100, 270)
var heading := 0.0
var speed := 0.0
var bumps := 0
var checkpoint := false
var ended := false
var held := {}
var info: Label
const TRACK := Rect2(35, 95, 890, 350)
const BLOCKS := [Rect2(250,95,85,195), Rect2(480,245,85,200), Rect2(700,95,75,185)]
const PICKUP := Rect2(370,115,85,85)
const DEST := Rect2(810,310,95,105)

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var frame := VBoxContainer.new()
    add_child(frame)
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    info = Label.new()
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    frame.add_child(info)
    var board := Control.new()
    board.size_flags_vertical = Control.SIZE_EXPAND_FILL
    board.custom_minimum_size = Vector2(0,180)
    board.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(board)
    var controls := HBoxContainer.new()
    controls.alignment = BoxContainer.ALIGNMENT_CENTER
    frame.add_child(controls)
    for pair in [["left","Esquerda"],["up","Acelerar"],["down","Frear / ré"],["right","Direita"]]:
        var b := Button.new()
        b.text = pair[1]
        b.custom_minimum_size = Vector2(100,56)
        controls.add_child(b)
        b.button_down.connect(func(): held[pair[0]] = true)
        b.button_up.connect(func(): held[pair[0]] = false)
    var exit := Button.new()
    exit.text = "Sair"
    exit.custom_minimum_size = Vector2(80,56)
    controls.add_child(exit)
    exit.pressed.connect(func(): _finish(false))
    board.draw.connect(func(): _paint(board))
    board.resized.connect(board.queue_redraw)
    set_meta("board",board)

func _physics_process(delta: float) -> void:
    if ended:
        return
    var turn := float(_held("right",KEY_D,KEY_RIGHT)) - float(_held("left",KEY_A,KEY_LEFT))
    var throttle := float(_held("up",KEY_W,KEY_UP)) - float(_held("down",KEY_S,KEY_DOWN))
    speed = move_toward(speed,throttle*180.0,delta*240.0)
    heading += turn * delta * 2.8 * clampf(absf(speed)/45.0,0.0,1.0)
    var candidate := car + Vector2.from_angle(heading)*speed*delta
    var hit := not TRACK.grow(-15).has_point(candidate)
    for obstacle in BLOCKS:
        hit = hit or obstacle.grow(15).has_point(candidate)
    if hit:
        if absf(speed)>12:
            bumps += 1
        speed = 0
    else:
        car = candidate
    if PICKUP.has_point(car) and absf(speed)<18:
        checkpoint = true
    if checkpoint and DEST.has_point(car) and absf(speed)<18:
        _finish(true)
        return
    info.text = ("Estacione na garagem verde" if checkpoint else "Pare na área dourada para conferir a ordem") + " | Impactos: %d" % bumps
    (get_meta("board") as Control).queue_redraw()

func _held(id: String, a: int, b: int) -> bool:
    return bool(held.get(id,false)) or Input.is_physical_key_pressed(a) or Input.is_physical_key_pressed(b)

func _paint(board: Control) -> void:
    var scale_factor := minf(board.size.x/960.0,board.size.y/480.0)
    var origin := (board.size-Vector2(960,480)*scale_factor)/2
    board.draw_set_transform(origin,0,Vector2.ONE*scale_factor)
    board.draw_rect(Rect2(0,0,960,480),Color("#24192f"))
    board.draw_rect(TRACK,Color("#655d70"))
    for obstacle in BLOCKS:
        board.draw_rect(obstacle,Color("#342c43"))
        board.draw_rect(obstacle,Color("#b29a86"),false,3)
    board.draw_rect(PICKUP,Color("#b99550") if not checkpoint else Color("#777777"))
    board.draw_rect(DEST,Color("#548d79"))
    board.draw_set_transform(origin+car*scale_factor,heading,Vector2.ONE*scale_factor)
    board.draw_texture_rect(preload("res://assets/sprites/hearse.svg"),Rect2(-24,-12,48,24),false,Color.WHITE,true)
    board.draw_set_transform(Vector2.ZERO)

func _finish(success: bool) -> void:
    if ended:
        return
    ended = true
    finished.emit(success,bumps)
    queue_free()
