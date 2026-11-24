extends Control
## Arcade pseudo-3D: a pista avanca, o jogador controla velocidade e faixa.
signal finished(success: bool, bumps: int)
const LENGTH := 3000.0
const MAX_SPEED := 180.0
const VIEW := Vector2(960,480)
const HORIZON := 196.0
const PLAYER_WIDTH := 130.0
const PLAYER_Y := 430.0
const BUILD_LABEL := "ARCADE 2.6"
const DEPTH := 650.0
var distance := 0.0
var speed := 0.0
var lateral := 0.0
var steering := 0.0
var bumps := 0
var ended := false
var held := {}
var touch_keys := {}
var control_buttons := {}
var brake_active := false
const HEARSE = preload("res://assets/sprites/hearse_arcade/rear.png")
const TRAFFIC = [preload("res://assets/sprites/traffic/red.png"),preload("res://assets/sprites/traffic/blue.png"),preload("res://assets/sprites/traffic/wagon.png"),preload("res://assets/sprites/traffic/pickup.png"),preload("res://assets/sprites/traffic/van.png"),preload("res://assets/sprites/traffic/taxi.png")]
const ROAD_ASPHALT = preload("res://assets/road/asphalt.webp")
const ROAD_COBBLES = preload("res://assets/road/cobbles.webp")
const ROAD_SHOULDER = preload("res://assets/road/shoulder.webp")
const ROAD_CURB = preload("res://assets/road/curb.webp")
const ROAD_MARKINGS = preload("res://assets/road/markings.webp")
const ROAD_FINISH = preload("res://assets/road/finish.webp")
const ROAD_CURVE = preload("res://assets/road/curve.webp")
const ROAD_CEMETERY = preload("res://assets/road/cemetery.webp")
const PANORAMAS = [
    preload("res://assets/panoramas/translado/bg_bairro.webp"),
    preload("res://assets/panoramas/translado/bg_cidade.webp"),
    preload("res://assets/panoramas/translado/bg_montanhas.webp"),
    preload("res://assets/panoramas/translado/bg_castelo.webp"),
    preload("res://assets/panoramas/translado/bg_floresta.webp"),
    preload("res://assets/panoramas/translado/bg_cemiterio.webp")
]
const REGION_NAMES := ["Bairro gótico","Centro de Santa Mortalha","Montanhas da Névoa","Castelo das Almas","Floresta dos Esquecidos","Jardim do Último Suspiro"]
const REGION_SPAN := LENGTH / 6.0
var info: Label
var board: Control
var hit_timer := 0.0
var countdown := 3.0
var obstacles: Array[Dictionary] = []
var flash := 0.0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for i in range(1,14):
        obstacles.append({"z":float(i)*205.0+120.0,"lane": [-0.63,0.63,0.0,0.63,-0.63][i%5],"hit":false,"model":(i-1)%TRAFFIC.size()})
    var frame := VBoxContainer.new()
    add_child(frame)
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    info = Label.new()
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size",22)
    frame.add_child(info)
    board = Control.new()
    board.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
    board.clip_contents = true
    board.size_flags_vertical = Control.SIZE_EXPAND_FILL
    board.custom_minimum_size = Vector2(0,200)
    board.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.add_child(board)
    board.draw.connect(_paint)
    board.resized.connect(board.queue_redraw)
    var controls := HBoxContainer.new()
    controls.alignment = BoxContainer.ALIGNMENT_CENTER
    controls.add_theme_constant_override("separation",12)
    frame.add_child(controls)
    for pair in [["left","Esquerda"],["right","Direita"],["down","Freio"],["up","Acelerar"]]:
        var b := Button.new()
        b.text = pair[1]
        b.focus_mode = Control.FOCUS_NONE
        b.custom_minimum_size = Vector2(145,76)
        controls.add_child(b)
        var key: String = pair[0]
        control_buttons[key] = b
        b.button_down.connect(_set_held.bind(key,true))
        b.button_up.connect(_set_held.bind(key,false))
    var exit := Button.new()
    exit.text = "Sair"
    exit.focus_mode = Control.FOCUS_NONE
    exit.custom_minimum_size = Vector2(90,76)
    controls.add_child(exit)
    exit.pressed.connect(func(): _finish(false))
    info.text = "TRANSLADO DO ALÉM • Prepare-se!"

func _set_held(key: String, value: bool) -> void:
    held[key] = value

func _input(event: InputEvent) -> void:
    if ended:
        return
    if event is InputEventScreenTouch:
        if not event.pressed:
            if touch_keys.has(event.index):
                touch_keys.erase(event.index)
                get_viewport().set_input_as_handled()
            return
        for key in control_buttons:
            var button: Button = control_buttons[key]
            if button.get_global_rect().has_point(event.position):
                touch_keys[event.index] = key
                get_viewport().set_input_as_handled()
                return

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
        touch_keys.clear()
        held.clear()

func _held(key: String, a: int, b: int) -> bool:
    return touch_keys.values().has(key) or bool(held.get(key,false)) or Input.is_physical_key_pressed(a) or Input.is_physical_key_pressed(b)

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
    brake_active = brake
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
    var contact_offset := (1.0-(PLAYER_Y-HORIZON)/(VIEW.y-HORIZON))*DEPTH
    for obstacle in obstacles:
        var z: float = obstacle["z"]
        if not obstacle["hit"] and previous + contact_offset <= z and distance + contact_offset >= z:
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
    board.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    board.draw_set_transform((board.size-VIEW*k)/2.0,0.0,Vector2.ONE*k)
    board.draw_rect(Rect2(Vector2.ZERO,VIEW),Color("#251d40"))
    _paint_panorama()
    _paint_road()
    _paint_finish()
    _paint_signs()
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
    var player_drawn := false
    for i in range(obstacles.size()-1,-1,-1):
        var obstacle: Dictionary = obstacles[i]
        var ahead := float(obstacle["z"])-distance
        if ahead<0.0 or ahead>DEPTH:
            continue
        var t := 1.0-ahead/DEPTH
        var p := _road_point(t,float(obstacle["lane"]))
        if not player_drawn and p.y > PLAYER_Y:
            _player_car(Vector2(480.0+lateral*365.0,PLAYER_Y))
            player_drawn = true
        _traffic(p, t,int(obstacle["model"]))
    if not player_drawn:
        _player_car(Vector2(480.0+lateral*365.0,PLAYER_Y))
    board.draw_rect(Rect2(8,6,385,69),Color(0.07,0.045,0.11,0.74))
    board.draw_rect(Rect2(16,14,240,12),Color("#15131c"))
    board.draw_rect(Rect2(16,14,240*clampf(distance/LENGTH,0,1),12),Color("#d8b477"))
    board.draw_string(ThemeDB.fallback_font,Vector2(16,45),"HOSPITAL - JARDIM DO ÚLTIMO SUSPIRO",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#f3e5c8"))
    board.draw_string(ThemeDB.fallback_font,Vector2(16,66),REGION_NAMES[_panorama_index(distance)]+" | "+BUILD_LABEL,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#d9b6ed"))
    if countdown>0.0:
        board.draw_string(ThemeDB.fallback_font,Vector2(450,260),str(ceili(countdown)),HORIZONTAL_ALIGNMENT_LEFT,-1,70,Color("#f6cf84"))
    elif speed<1.0 and distance<1.0:
        board.draw_string(ThemeDB.fallback_font,Vector2(300,245),"W / Acelerar para partir",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("#ffffff"))
    if flash>0.0:
        board.draw_rect(Rect2(0,0,960,480),Color(0.9,0.25,0.2,flash*0.45))
    board.draw_set_transform(Vector2.ZERO)

# Cada arte é um panorama completo. O deslocamento nas curvas é limitado
# à margem lateral da textura; não há repetição visível ou lua duplicada.
func _panorama_index(z: float) -> int:
    return clampi(floori(z/REGION_SPAN),0,PANORAMAS.size()-1)

func _panorama_blend(z: float) -> float:
    var index := _panorama_index(z)
    if index >= PANORAMAS.size()-1:
        return 0.0
    return smoothstep(0.78,1.0,clampf(z/REGION_SPAN-float(index),0.0,1.0))

func _paint_panorama() -> void:
    var index := _panorama_index(distance)
    var blend := _panorama_blend(distance)
    var drift := clampf(-_curve(distance)*35.0-lateral*14.0,-55.0,55.0)
    var area := Rect2(0.0,0.0,VIEW.x,HORIZON)
    _draw_panorama_region(PANORAMAS[index],area,drift,1.0)
    if blend>0.0 and index+1<PANORAMAS.size():
        _draw_panorama_region(PANORAMAS[index+1],area,drift,blend)

func _draw_panorama_region(tex: Texture2D, area: Rect2, drift: float, alpha: float) -> void:
    # Preserve the aspect ratio; crop vertically rather than squash buildings.
    var scale_factor := (area.size.x+120.0)/float(tex.get_width())
    var source_size := area.size/scale_factor
    var source_x := (float(tex.get_width())-source_size.x)/2.0-drift/scale_factor
    var source_y := (float(tex.get_height())-source_size.y)*0.62
    board.draw_texture_rect_region(tex,area,Rect2(Vector2(source_x,source_y),source_size),Color(1.0,1.0,1.0,alpha))

# UVs advance in world coordinates, not in screen coordinates.
func _road_strip(a: float,b: float,left: float,right: float,tex: Texture2D,tiles: float,period: float,tint: Color = Color.WHITE) -> void:
    var va := (distance+(1.0-a)*DEPTH)/period
    var vb := (distance+(1.0-b)*DEPTH)/period
    var points := PackedVector2Array([_road_point(a,left),_road_point(a,right),_road_point(b,right),_road_point(b,left)])
    var uv := PackedVector2Array([Vector2(0,va),Vector2(tiles,va),Vector2(tiles,vb),Vector2(0,vb)])
    board.draw_polygon(points,PackedColorArray([tint,tint,tint,tint]),uv,tex)

func _surface_at(z: float) -> Texture2D:
    var region := _panorama_index(z)
    return ROAD_COBBLES if region in [1,5] else ROAD_ASPHALT

func _paint_road() -> void:
    for i in range(64):
        var a := float(i)/64.0
        var b := float(i+1)/64.0
        var z := distance+(1.0-(a+b)*0.5)*DEPTH
        var p := _road_point(a,0.0)
        var q := _road_point(b,0.0)
        var light := lerpf(0.58,1.0,a)
        var tint := Color(light,light,light,1.0)
        board.draw_rect(Rect2(0,p.y,VIEW.x,q.y-p.y+1),Color("#3a4237"))
        _road_strip(a,b,-5.0,5.0,ROAD_SHOULDER,22.0,72.0,tint)
        if _panorama_index(z) in [0,1,5]:
            _road_strip(a,b,-1.19,-1.0,ROAD_CURB,1.0,100.0,tint)
            _road_strip(a,b,1.0,1.19,ROAD_CURB,1.0,100.0,tint)
        _road_strip(a,b,-1.0,1.0,_surface_at(z),6.0,65.0,tint)
        if int(z/24.0)%2==0:
            for lane in [-0.33,0.33]:
                _quad(_road_point(a,lane-0.012),_road_point(a,lane+0.012),_road_point(b,lane+0.012),_road_point(b,lane-0.012),Color("#c5b692"))
                _road_strip(a,b,lane-0.012,lane+0.012,ROAD_MARKINGS,1.0,48.0)

func _paint_finish() -> void:
    var ahead := LENGTH-distance
    if ahead<0.0 or ahead>DEPTH:
        return
    var t := 1.0-ahead/DEPTH
    var p := _road_point(t,0.0)
    var w := (_road_point(t,1.0)-_road_point(t,-1.0)).length()
    var height := maxf(3.0,32.0*t)
    board.draw_texture_rect(ROAD_FINISH,Rect2(p.x-w/2,p.y-height/2,w,height),false)
    board.draw_string(ThemeDB.fallback_font,p+Vector2(-36,-height-5),"CHEGADA",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#e8ffdd"))

func _paint_signs() -> void:
    for z in [180.0,620.0,1100.0,1650.0,2200.0,2720.0]:
        var ahead := float(z)-distance
        if ahead<0.0 or ahead>DEPTH:
            continue
        var t := 1.0-ahead/DEPTH
        var p := _road_point(t,1.32)
        var tex: Texture2D = ROAD_CEMETERY if z==2720.0 else ROAD_CURVE
        var h := lerpf(5.0,132.0,t)
        var w := h*float(tex.get_width())/float(tex.get_height())
        board.draw_texture_rect(tex,Rect2(p.x-w/2,p.y-h,w,h),false,Color.WHITE,false)
        # Direction sign retains its original readable orientation.

func _traffic_width(t: float, model: int) -> float:
    var player_depth := (PLAYER_Y-HORIZON)/(VIEW.y-HORIZON)
    var perspective := lerpf(28.0,445.0,clampf(t,0.0,1.0))/lerpf(28.0,445.0,player_depth)
    var relative_width: float = [0.88,0.98,1.04,1.10,1.13,0.98][model]
    return PLAYER_WIDTH*relative_width*perspective

func _traffic(p: Vector2,t: float,model: int) -> void:
    var tex: Texture2D = TRAFFIC[model]
    var w := _traffic_width(t,model)
    var h := w*float(tex.get_height())/float(tex.get_width())
    board.draw_rect(Rect2(p.x-w*0.4,p.y-2*t,w*0.8,5*t),Color(0,0,0,0.28))
    board.draw_texture_rect(tex,Rect2(p.x-w/2,p.y-h,w,h),false)

func _player_car(p: Vector2) -> void:
    var x := p.x+steering*5.0
    var bounce := sin(distance*0.18)*1.5*speed/MAX_SPEED
    var y := p.y+bounce
    var lean := steering*5.0
    board.draw_rect(Rect2(x-65,y-5,130,9),Color(0,0,0,0.35))
    board.draw_texture_rect(HEARSE,Rect2(x-65+lean,y-124,130,130),false)
    if brake_active:
        board.draw_circle(Vector2(x-49+lean,y-41),9,Color(1.0,0.12,0.05,0.28))
        board.draw_circle(Vector2(x+49+lean,y-41),9,Color(1.0,0.12,0.05,0.28))

func _finish(success: bool) -> void:
    if ended:
        return
    ended = true
    finished.emit(success,bumps)
    queue_free()
