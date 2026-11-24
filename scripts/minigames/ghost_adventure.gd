extends Control
signal finished(success: bool, score: int)
signal phase_saved(next_phase: int)
const TITLES = ["O Despertar dos Esquecidos","O Bosque das Lápides Perdidas","As Catacumbas do Silêncio","O Arquivo Assombrado","A Torre das Últimas Horas","Enfim, Descanse em Paz"]
const LESSONS = ["Identifique a quadra e o jazigo antes de qualquer serviço.","Mantenha acessos livres e caminhos conservados.","Confira a identificação de cada espaço funerário.","Registros permitem localizar e conferir informações.","Planeje a manutenção e a segurança da equipe.","Identificação e respeito à memória orientam o atendimento."]
const VIEW = Vector2(800,300)
const GHOST_HD = {
    "idle": [preload("res://assets/minigames/ghost/idle_00.png")],
    "walk": [preload("res://assets/minigames/ghost/walk_00.png"),preload("res://assets/minigames/ghost/walk_01.png"),preload("res://assets/minigames/ghost/walk_02.png"),preload("res://assets/minigames/ghost/walk_03.png"),preload("res://assets/minigames/ghost/walk_04.png"),preload("res://assets/minigames/ghost/walk_05.png")],
    "run": [preload("res://assets/minigames/ghost/run_00.png"),preload("res://assets/minigames/ghost/run_01.png"),preload("res://assets/minigames/ghost/run_02.png"),preload("res://assets/minigames/ghost/run_03.png"),preload("res://assets/minigames/ghost/run_04.png"),preload("res://assets/minigames/ghost/run_05.png")],
    "jump": [preload("res://assets/minigames/ghost/jump_00.png"),preload("res://assets/minigames/ghost/jump_01.png"),preload("res://assets/minigames/ghost/jump_02.png"),preload("res://assets/minigames/ghost/jump_03.png"),preload("res://assets/minigames/ghost/jump_04.png")],
    "float": [preload("res://assets/minigames/ghost/float_00.png"),preload("res://assets/minigames/ghost/float_01.png"),preload("res://assets/minigames/ghost/float_02.png"),preload("res://assets/minigames/ghost/float_03.png"),preload("res://assets/minigames/ghost/float_04.png"),preload("res://assets/minigames/ghost/float_05.png")],
    "hurt": [preload("res://assets/minigames/ghost/hurt_00.png"),preload("res://assets/minigames/ghost/hurt_01.png"),preload("res://assets/minigames/ghost/hurt_02.png"),preload("res://assets/minigames/ghost/hurt_03.png"),preload("res://assets/minigames/ghost/hurt_04.png")],
    "defeat": [preload("res://assets/minigames/ghost/defeat_00.png"),preload("res://assets/minigames/ghost/defeat_01.png"),preload("res://assets/minigames/ghost/defeat_02.png"),preload("res://assets/minigames/ghost/defeat_03.png"),preload("res://assets/minigames/ghost/defeat_04.png"),preload("res://assets/minigames/ghost/defeat_05.png")],
    "fall": [preload("res://assets/minigames/ghost/fall_00.png")],
    "portrait": [preload("res://assets/minigames/ghost/portrait_00.png"),preload("res://assets/minigames/ghost/portrait_01.png"),preload("res://assets/minigames/ghost/portrait_02.png"),preload("res://assets/minigames/ghost/portrait_03.png"),preload("res://assets/minigames/ghost/portrait_04.png"),preload("res://assets/minigames/ghost/portrait_05.png"),preload("res://assets/minigames/ghost/portrait_06.png"),preload("res://assets/minigames/ghost/portrait_07.png")],
    "turnaround": [preload("res://assets/minigames/ghost/turnaround_00.png"),preload("res://assets/minigames/ghost/turnaround_01.png"),preload("res://assets/minigames/ghost/turnaround_02.png"),preload("res://assets/minigames/ghost/turnaround_03.png"),preload("res://assets/minigames/ghost/turnaround_04.png")]
}
var ghost_frames: Dictionary = {}
var facing_left := false
var defeat_timer := 0.0
var phase := 0
var hp := 3
var deaths := 0
var pos := Vector2(35,240)
var checkpoint := Vector2(35,240)
var vel := Vector2.ZERO
var grounded := false
var float_left := 0.0
var jump_request := false
var left := false
var right := false
var jump_held := false
var run_held := false
var touches: Dictionary = {}
var controls: Dictionary = {}
var platforms: Array[Rect2] = []
var fragments: Array[Vector2] = []
var collected: Array[int] = []
var enemies: Array[Vector2] = []
var camera_x := 0.0
var elapsed := 0.0
var invulnerable := 0.0
var board: Control
var hud: Label
var message: Label
var next_button: Button
var paused := false
var ended := false
var goal_x := 1800.0
func setup(saved_phase: int = 0) -> void:
    phase = clampi(saved_phase,0,5)
func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg := ColorRect.new()
    bg.color=Color("#20152d")
    add_child(bg)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var layout := VBoxContainer.new()
    add_child(layout)
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud=Label.new()
    hud.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    hud.add_theme_font_size_override("font_size",18)
    layout.add_child(hud)
    message=Label.new()
    message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    layout.add_child(message)
    board=Control.new()
    board.clip_contents=true
    board.size_flags_vertical=Control.SIZE_EXPAND_FILL
    board.custom_minimum_size=Vector2(0,150)
    board.mouse_filter=Control.MOUSE_FILTER_IGNORE
    layout.add_child(board)
    board.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    _load_ghost_art()
    board.draw.connect(_paint)
    var bar := HBoxContainer.new()
    layout.add_child(bar)
    for item in [["left","Esquerda"],["right","Direita"],["run","Correr"],["jump","Pular / flutuar"]]:
        var b := Button.new()
        b.text=item[1]
        b.focus_mode=Control.FOCUS_NONE
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        b.custom_minimum_size=Vector2(0,52)
        bar.add_child(b)
        controls[item[0]]=b
        b.button_down.connect(_hold.bind(str(item[0]),true))
        b.button_up.connect(_hold.bind(str(item[0]),false))
    next_button=Button.new()
    next_button.text="Continuar aventura"
    layout.add_child(next_button)
    next_button.pressed.connect(_advance)
    var exit := Button.new()
    exit.text="Voltar ao cemitério"
    layout.add_child(exit)
    exit.pressed.connect(func(): _finish(false))
    _load_phase()
func _hold(key: String, pressed: bool) -> void:
    match key:
        "left": left=pressed
        "right": right=pressed
        "run": run_held=pressed
        "jump":
            jump_held=pressed
            if pressed:
                jump_request=true
func _input(event: InputEvent) -> void:
    if ended:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            if paused:
                return
            for key in controls:
                var b: Button=controls[key]
                if b.get_global_rect().has_point(event.position):
                    touches[event.index]=key
                    _hold(str(key),true)
                    get_viewport().set_input_as_handled()
                    return
        elif touches.has(event.index):
            var key: String=touches[event.index]
            touches.erase(event.index)
            if not touches.values().has(key):
                _hold(key,false)
            get_viewport().set_input_as_handled()
    elif not paused and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_SPACE:
        jump_request=true
func _notification(what: int) -> void:
    if what==NOTIFICATION_APPLICATION_FOCUS_OUT or what==NOTIFICATION_APPLICATION_PAUSED:
        touches.clear()
        left=false
        right=false
        run_held=false
        jump_held=false
        jump_request=false
func _load_phase() -> void:
    hp=3
    defeat_timer=0.0
    facing_left=false
    pos=Vector2(35,240)
    checkpoint=pos
    vel=Vector2.ZERO
    grounded=false
    float_left=0.0
    invulnerable=0.0
    collected.clear()
    platforms.clear()
    fragments.clear()
    enemies.clear()
    camera_x=0.0
    elapsed=0.0
    paused=false
    touches.clear()
    left=false
    right=false
    run_held=false
    jump_held=false
    jump_request=false
    next_button.visible=false
    goal_x=1760.0+phase*120.0
    platforms.append(Rect2(0,240,210,60))
    var x:=255.0
    var n:=8+phase
    for i in range(n):
        var y:=240.0-float((i+phase)%3)*28.0
        var width:=145.0 if i%2==0 else 125.0
        platforms.append(Rect2(x,y,width,300.0-y))
        if i%2==0:
            fragments.append(Vector2(x+width*0.5,y-26))
        elif phase>0:
            enemies.append(Vector2(x+width*0.5,y-10))
        x+=width+45.0+float(phase)*3.0
    platforms.append(Rect2(x,240,230,60))
    goal_x=x+165.0
    message.text="Baltazar: Recupere todos os fragmentos e siga até o portão. "+LESSONS[phase]
    _refresh()
func _refresh() -> void:
    hud.text="HD | Fase %d/6 — %s | Vida %d/3 | Memórias %d/%d" % [phase+1,TITLES[phase],hp,collected.size(),fragments.size()]
    board.queue_redraw()
func _damage() -> void:
    if invulnerable>0.0:
        return
    hp-=1
    deaths+=1
    invulnerable=1.2
    pos=checkpoint
    grounded=true
    float_left=0.0
    vel=Vector2.ZERO
    if hp<=0:
        defeat_timer=0.72
        message.text="Baltazar: Até os fantasmas merecem outra chance!"
func _physics_process(delta: float) -> void:
    if ended or paused or not is_instance_valid(board):
        return
    elapsed+=delta
    if defeat_timer>0.0:
        defeat_timer=maxf(0.0,defeat_timer-delta)
        if defeat_timer<=0.0:
            hp=3
            invulnerable=1.2
        _refresh()
        return
    invulnerable=maxf(0.0,invulnerable-delta)
    var direction:=int(right or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-int(left or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
    if direction!=0:
        facing_left=direction<0
    var running:=run_held or Input.is_physical_key_pressed(KEY_SHIFT)
    vel.x=move_toward(vel.x,float(direction)*(250.0 if running else 170.0),950.0*delta)
    if grounded and jump_request:
        vel.y=-365.0
        grounded=false
        float_left=0.65
    jump_request=false
    var floating:=not grounded and vel.y>0.0 and float_left>0.0 and (jump_held or Input.is_physical_key_pressed(KEY_SPACE))
    if floating:
        float_left-=delta
        vel.y=minf(vel.y+150.0*delta,65.0)
    else:
        vel.y+=850.0*delta
    var old:=pos
    pos.x=clampf(pos.x+vel.x*delta,12.0,goal_x+30.0)
    pos.y+=vel.y*delta
    grounded=false
    for p in platforms:
        if vel.y>=0.0 and old.y<=p.position.y+0.1 and pos.y>=p.position.y and pos.x>p.position.x+4 and pos.x<p.end.x-4:
            pos.y=p.position.y
            vel.y=0.0
            grounded=true
            if p.position.x>checkpoint.x+550.0:
                checkpoint=Vector2(p.position.x+20.0,p.position.y)
                message.text="Lanterna de checkpoint acesa!"
    if pos.y>340.0:
        invulnerable=0.0
        _damage()
    for i in range(fragments.size()):
        if not i in collected and (pos-Vector2(0,15)).distance_to(fragments[i])<25.0:
            collected.append(i)
    for i in range(enemies.size()):
        var enemy:=_enemy_position(i)
        if (pos-Vector2(0,12)).distance_to(enemy)<23.0:
            if vel.y>40.0 and old.y<enemy.y-8.0:
                enemies[i].y=-500.0
                vel.y=-230.0
            else:
                _damage()
    camera_x=clampf(pos.x-280.0,0.0,maxf(0.0,goal_x-700.0))
    if pos.x>=goal_x and grounded:
        if collected.size()==fragments.size():
            paused=true
            phase_saved.emit(mini(5,phase+1))
            message.text=LESSONS[phase]+" — Fase concluída!"
            next_button.visible=true
            next_button.text="Finalizar aventura" if phase==5 else "Próxima fase"
        else:
            message.text="Ainda faltam fragmentos. Volte e procure!"
    _refresh()
func _enemy_position(i: int) -> Vector2:
    return enemies[i]+Vector2(sin(elapsed*2.0+float(i))*22.0,0)
func _advance() -> void:
    if not paused:
        return
    if phase==5:
        _finish(true)
    else:
        phase+=1
        _load_phase()
func _finish(success: bool) -> void:
    if ended:
        return
    ended=true
    finished.emit(success,clampi(100-deaths*5,0,100) if success else 0)
func _paint() -> void:
    var factor:=minf(board.size.x/VIEW.x,board.size.y/VIEW.y)
    board.draw_set_transform((board.size-VIEW*factor)*0.5,0.0,Vector2.ONE*factor)
    var sky: Color=[Color("#3b254e"),Color("#243e3c"),Color("#292039"),Color("#44304e"),Color("#382940"),Color("#45324e")][phase]
    board.draw_rect(Rect2(Vector2.ZERO,VIEW),sky)
    board.draw_circle(Vector2(650,55),36,Color("#e9cf9a"))
    for i in range(13):
        var x:=fposmod(float(i)*83.0-camera_x*0.25,1080.0)-100.0
        var y:=160.0+float(i%3)*12.0
        board.draw_rect(Rect2(x,y,38,145),Color("#21182d"))
        board.draw_colored_polygon(PackedVector2Array([Vector2(x-7,y),Vector2(x+19,y-35),Vector2(x+45,y)]),Color("#21182d"))
    for p in platforms:
        var rect:=Rect2(p.position-Vector2(camera_x,0),p.size)
        board.draw_rect(rect,Color("#534454"))
        board.draw_rect(Rect2(rect.position,Vector2(rect.size.x,7)),Color("#9c9171"))
        for j in range(int(rect.size.x/24)):
            board.draw_rect(Rect2(rect.position+Vector2(j*24,12),Vector2(22,12)),Color("#67566d"),false,1.0)
    for i in range(fragments.size()):
        if not i in collected:
            var p:=fragments[i]-Vector2(camera_x,0)
            board.draw_circle(p,12,Color(1.0,0.76,0.3,0.2))
            board.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-9),p+Vector2(7,0),p+Vector2(0,9),p+Vector2(-7,0)]),Color("#f5ce79"))
    for i in range(enemies.size()):
        var p:=_enemy_position(i)-Vector2(camera_x,0)
        board.draw_circle(p,12,Color("#d98236"))
        board.draw_circle(p+Vector2(-4,-2),2,Color("#25182e"))
        board.draw_circle(p+Vector2(4,-2),2,Color("#25182e"))
    var cp:=checkpoint-Vector2(camera_x,0)
    board.draw_line(cp,cp-Vector2(0,35),Color("#b18b64"),3)
    board.draw_circle(cp-Vector2(0,35),7,Color("#ffcf75"))
    board.draw_rect(Rect2(goal_x-camera_x-12,194,24,46),Color("#9e7db0"))
    var p:=pos-Vector2(camera_x,0)
    var texture: Texture2D = _current_ghost_texture()
    var rect := Rect2(p-Vector2(26,46),Vector2(52,52))
    if facing_left:
        board.draw_set_transform((board.size-VIEW*factor)*0.5+Vector2(p.x*2.0*factor,0),0.0,Vector2(-factor,factor))
    var tint := Color.WHITE
    if invulnerable>0.0 and int(elapsed*12.0)%2!=0:
        tint.a=0.65
    board.draw_texture_rect(texture,rect,false,tint)
    board.draw_set_transform((board.size-VIEW*factor)*0.5,0.0,Vector2.ONE*factor)

func _load_ghost_art() -> void:
    ghost_frames=GHOST_HD.duplicate()

func _current_ghost_texture() -> Texture2D:
    var key := "idle"
    var frame := 0
    if defeat_timer>0.0:
        key="defeat"
        frame=clampi(int((0.72-defeat_timer)*9.0),0,5)
    elif invulnerable>0.65:
        key="hurt"
        frame=clampi(int((1.2-invulnerable)*9.0),0,4)
    elif not grounded:
        if vel.y<0.0:
            key="jump"
            frame=clampi(int((vel.y+365.0)/90.0),0,3)
        elif float_left>0.0 and (jump_held or Input.is_physical_key_pressed(KEY_SPACE)):
            key="float"
            frame=int(elapsed*9.0)
        else:
            key="fall"
    elif absf(vel.x)>8.0:
        key="run" if absf(vel.x)>185.0 else "walk"
        frame=int(elapsed*(14.0 if key=="run" else 9.0))
    var frames: Array = ghost_frames[key]
    return frames[frame%frames.size()]
