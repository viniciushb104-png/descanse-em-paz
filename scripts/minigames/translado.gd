extends Control
## Arcade pseudo-3D: a pista avanca, o jogador controla velocidade e faixa.
signal finished(success: bool, bumps: int)
const LENGTH := 3000.0
const MAX_SPEED := 180.0
const VIEW := Vector2(960,480)
const HORIZON := 144.0
const DEPTH := 650.0
var distance := 0.0
var speed := 0.0
var lateral := 0.0
var steering := 0.0
var bumps := 0
var ended := false
var held := {}
var info: Label
var board: Control
var hit_timer := 0.0
var countdown := 3.0
var obstacles: Array[Dictionary] = []
var flash := 0.0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for i in range(1,14):
        obstacles.append({"z":float(i)*205.0+120.0,"lane": [-0.63,0.63,0.0,0.63,-0.63][i%5],"hit":false})
    var frame := VBoxContainer.new()
    add_child(frame)
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    info = Label.new()
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size",22)
    frame.add_child(info)
    board = Control.new()
    board.size_flags_vertical = Control.SIZE_EXPAND_FILL
    board.custom_minimum_size = Vector2(0,200)
    board.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(board)
    board.draw.connect(_paint)
    board.resized.connect(board.queue_redraw)
    var controls := HBoxContainer.new()
    controls.alignment = BoxContainer.ALIGNMENT_CENTER
    frame.add_child(controls)
    for pair in [["left","◀ Esquerda"],["right","Direita ▶"],["down","Freio"],["up","Acelerar"]]:
        var b := Button.new()
        b.text = pair[1]
        b.focus_mode = Control.FOCUS_NONE
        b.custom_minimum_size = Vector2(125,58)
        controls.add_child(b)
        var key: String = pair[0]
        b.button_down.connect(_set_held.bind(key,true))
        b.button_up.connect(_set_held.bind(key,false))
    var exit := Button.new()
    exit.text = "Sair"
    exit.focus_mode = Control.FOCUS_NONE
    exit.custom_minimum_size = Vector2(90,58)
    controls.add_child(exit)
    exit.pressed.connect(func(): _finish(false))
    info.text = "TRANSLADO DO ALÉM • Prepare-se!"

func _set_held(key: String, value: bool) -> void:
    held[key] = value

func _held(key: String, a: int, b: int) -> bool:
    return bool(held.get(key,false)) or Input.is_physical_key_pressed(a) or Input.is_physical_key_pressed(b)

func _curve(z: float) -> float:
    return sin(z/290.0)*0.65 + sin(z/610.0)*0.35

func _physics_process(delta: float) -> void:
    if ended:
        return
    if countdown > 0:
        countdown -= delta
        board.queue_redraw()
        return
    var turn := float(_held("right",KEY_D,KEY_RIGHT))-float(_held("left",KEY_A,KEY_LEFT))
    var accel := _held("up",KEY_W,KEY_UP)
    var brake := _held("down",KEY_S,KEY_DOWN) or Input.is_physical_key_pressed(KEY_SPACE)
    steering = move_toward(steering,turn,delta*9.0)
    speed = move_toward(speed,0.0 if brake else (MAX_SPEED if accel else 0.0),delta*(260.0 if brake else (115.0 if accel else 38.0)))
    var ratio := speed/MAX_SPEED
    lateral += (steering*1.65 - _curve(distance)*ratio*0.29)*delta*ratio
    hit_timer = maxf(0.0,hit_timer-delta)
    flash = maxf(0.0,flash-delta)
    if absf(lateral)>1.0:
        speed = minf(speed,70.0)
        lateral = clampf(lateral,-1.12,1.12)
        if hit_timer<=0.0 and absf(lateral)>1.07:
            _impact()
    var previous := distance
    distance += speed*delta
    for obstacle in obstacles:
        var z: float = obstacle["z"]
        if not obstacle["hit"] and previous <= z and distance >= z:
            obstacle["hit"] = true
            if absf(lateral-float(obstacle["lane"]))<0.32:
                _impact()
    if distance>=LENGTH:
        _finish(true)
        return
    info.text = "TRANSLADO DO ALÉM   |   %03d km/h   |   Rota %d%%   |   Impactos %d" % [int(speed*0.68),int(distance/LENGTH*100.0),bumps]
    board.queue_redraw()

func _impact() -> void:
    bumps += 1
    speed *= 0.5
    hit_timer = 1.15
    flash = 0.25

func _road_point(t: float, lane: float) -> Vector2:
    var half_width := lerpf(28.0,445.0,t)
    var z := distance+(1.0-t)*DEPTH
    var bend := (_curve(z)-_curve(distance))*145.0*(1.0-t)
    return Vector2(480.0+bend+lane*half_width,HORIZON+t*(480.0-HORIZON))

func _quad(a: Vector2,b: Vector2,c: Vector2,d: Vector2,color: Color) -> void:
    board.draw_colored_polygon(PackedVector2Array([a,b,c,d]),color)

func _paint() -> void:
    var k := minf(board.size.x/VIEW.x,board.size.y/VIEW.y)
    if k<=0.0:
        return
    board.draw_set_transform((board.size-VIEW*k)/2.0,0.0,Vector2.ONE*k)
    board.draw_rect(Rect2(Vector2.ZERO,VIEW),Color("#251d40"))
    board.draw_circle(Vector2(780,55),38,Color("#efdbad"))
    board.draw_circle(Vector2(795,43),33,Color("#251d40"))
    for i in range(18):
        var x := float(i)*61.0-fposmod(distance*0.022,61.0)
        var h := 22.0+float((i*37)%66)
        board.draw_rect(Rect2(x,HORIZON-h,38,h),Color("#181827"))
        board.draw_colored_polygon(PackedVector2Array([Vector2(x-5,HORIZON-h),Vector2(x+19,HORIZON-h-22),Vector2(x+43,HORIZON-h)]),Color("#181827"))
        board.draw_rect(Rect2(x+14,HORIZON-h+13,6,10),Color("#b38b54"))
    for i in range(48):
        var a := float(i)/48.0
        var b := float(i+1)/48.0
        var z := distance+(1.0-a)*DEPTH
        var stripe := int(z/24.0)%2==0
        var p := _road_point(a,0)
        var q := _road_point(b,0)
        board.draw_rect(Rect2(0,p.y,960,q.y-p.y+1),Color("#34463e") if stripe else Color("#2d3c38"))
        _quad(_road_point(a,-1.08),_road_point(a,1.08),_road_point(b,1.08),_road_point(b,-1.08),Color("#b5a38f") if stripe else Color("#694759"))
        _quad(_road_point(a,-1),_road_point(a,1),_road_point(b,1),_road_point(b,-1),Color("#555263") if stripe else Color("#504e60"))
        if stripe:
            for lane in [-0.33,0.33]:
                _quad(_road_point(a,lane-0.012),_road_point(a,lane+0.012),_road_point(b,lane+0.012),_road_point(b,lane-0.012),Color("#c5b692"))
    for i in range(15,0,-1):
        var z := floorf(distance/48.0)*48.0+float(i)*48.0
        var t := 1.0-(z-distance)/DEPTH
        if t<0.0 or t>1.0:
            continue
        for side in [-1.0,1.0]:
            var p := _road_point(t,side*1.17)
            var h := 14.0+65.0*t
            board.draw_rect(Rect2(p.x-2*t,p.y-h,4*t+1,h),Color("#22202e"))
            board.draw_rect(Rect2(p.x-5*t,p.y-h-8*t,10*t+1,10*t+1),Color("#f5c875"))
    for i in range(obstacles.size()-1,-1,-1):
        var obstacle: Dictionary = obstacles[i]
        var ahead := float(obstacle["z"])-distance
        if ahead<0.0 or ahead>DEPTH:
            continue
        var t := 1.0-ahead/DEPTH
        var p := _road_point(t,float(obstacle["lane"]))
        _traffic(p, maxf(0.08,t))
    var finish_ahead := LENGTH-distance
    if finish_ahead<DEPTH:
        var t := 1.0-finish_ahead/DEPTH
        var p := _road_point(t,0)
        var w := (_road_point(t,1)-_road_point(t,-1)).length()
        board.draw_rect(Rect2(p.x-w/2,p.y-5,w,9),Color("#90d6a6"))
        board.draw_string(ThemeDB.fallback_font,p+Vector2(-36,-12),"CHEGADA",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#e8ffdd"))
    _player_car(Vector2(480.0+lateral*365.0,430.0))
    board.draw_rect(Rect2(16,14,240,12),Color("#15131c"))
    board.draw_rect(Rect2(16,14,240*clampf(distance/LENGTH,0,1),12),Color("#d8b477"))
    board.draw_string(ThemeDB.fallback_font,Vector2(16,45),"HOSPITAL → JARDIM DO ÚLTIMO SUSPIRO",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#f3e5c8"))
    if countdown>0.0:
        board.draw_string(ThemeDB.fallback_font,Vector2(450,260),str(ceili(countdown)),HORIZONTAL_ALIGNMENT_LEFT,-1,70,Color("#f6cf84"))
    elif speed<1.0 and distance<1.0:
        board.draw_string(ThemeDB.fallback_font,Vector2(300,245),"W / ↑ para acelerar",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("#ffffff"))
    if flash>0.0:
        board.draw_rect(Rect2(0,0,960,480),Color(0.9,0.25,0.2,flash*0.45))
    board.draw_set_transform(Vector2.ZERO)

func _traffic(p: Vector2,t: float) -> void:
    var w := 70.0*t
    var h := 46.0*t
    board.draw_rect(Rect2(p.x-w/2,p.y-h,w,h),Color("#2d283a"))
    board.draw_rect(Rect2(p.x-w*0.36,p.y-h*0.85,w*0.72,h*0.36),Color("#807790"))
    board.draw_rect(Rect2(p.x-w*0.44,p.y-h*0.25,w*0.18,h*0.15),Color("#e36a58"))
    board.draw_rect(Rect2(p.x+w*0.26,p.y-h*0.25,w*0.18,h*0.15),Color("#e36a58"))

func _player_car(p: Vector2) -> void:
    var x := p.x+steering*5.0
    var y := p.y
    board.draw_rect(Rect2(x-68,y-8,136,16),Color(0,0,0,0.4))
    board.draw_rect(Rect2(x-57,y-53,19,55),Color("#14101b"))
    board.draw_rect(Rect2(x+38,y-53,19,55),Color("#14101b"))
    board.draw_rect(Rect2(x-58,y-68,116,65),Color("#171420"))
    board.draw_rect(Rect2(x-48,y-91,96,44),Color("#392c48"))
    board.draw_rect(Rect2(x-42,y-84,84,31),Color("#654377"))
    for i in range(4):
        board.draw_rect(Rect2(x-40+i*21,y-83,10,27),Color("#392343"))
    board.draw_rect(Rect2(x-52,y-48,104,34),Color("#292432"))
    board.draw_rect(Rect2(x-49,y-44,18,12),Color("#e65d55"))
    board.draw_rect(Rect2(x+31,y-44,18,12),Color("#e65d55"))
    board.draw_rect(Rect2(x-58,y-12,116,5),Color("#b5a7a4"))
    board.draw_rect(Rect2(x-4,y-81,8,24),Color("#d5b77d"))
    board.draw_rect(Rect2(x-12,y-74,24,7),Color("#d5b77d"))
    board.draw_rect(Rect2(x-17,y-29,34,13),Color("#d7c6a5"))
    board.draw_string(ThemeDB.fallback_font,Vector2(x-12,y-19),"S.M.",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#271d2c"))

func _finish(success: bool) -> void:
    if ended:
        return
    ended = true
    finished.emit(success,bumps)
    queue_free()
