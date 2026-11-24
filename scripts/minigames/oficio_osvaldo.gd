extends Control
## O Oficio de Osvaldo - miniatividade point-and-click / touch com 5 etapas.
## Interface e animacao 2D; nao ensina procedimentos tecnicos profissionais.
signal progress_changed(progress: Dictionary)
signal finished(success: bool, quality: int)

const VIEW := Vector2(960.0, 540.0)
const INK := Color("#171424")
const VIOLET := Color("#2c203b")
const PAPER := Color("#f5e8d0")
const GOLD := Color("#e4b875")
const CYAN := Color("#90d8df")
const OSVALDO: Texture2D = preload("res://assets/art/characters.png")
const TITLES := ["SEPARAR FERRAMENTAS", "LIMPAR O JAZIGO", "PREPARAR O TERRENO", "POSICIONAR O CAIXAO", "CONCLUIR E ORGANIZAR"]
const TIPS := [
    "Toque em luvas, pa e sinalizacao para organizar o carrinho.",
    "Recolha os cinco montinhos de folhas, um por um.",
    "Toque em um trecho de terra. Osvaldo caminha ate ele e cava.",
    "Arraste o controle dourado ate o fim, com calma.",
    "Finalize: nivelar, conferir a placa e acomodar flores."
]
const COUNTS := [3, 5, 6, 1, 3]
var order: Dictionary = {}
var phase: int = 0
var completed: Array = [[], [], [], [], []]
var lowering: float = 0.0
var mistakes: int = 0
var dragging: bool = false
var ended: bool = false
var feedback: String = "Prepare o local com cuidado. Osvaldo esta supervisionando."
var last_action_at: int = -1000
var last_slider_save_at: int = -1000
var leave_button: Button
const DIG_DIR := "res://assets/sprites/osvaldo_dig/"
const DIG_NAMES := ["idle","raise","strike","effort","throw"]
const DIG_TIMES := [0.10,0.16,0.13,0.14,0.20,0.12]
const DIG_IMPACT_SECONDS := 0.48
const DIG_COMPLETE_SECONDS := 1.05
var dig_frames: Array[Texture2D] = []
var dig_clock := -1.0
var dig_target := -1
var dig_committed := false
var dig_anchor := Vector2.ZERO
var dig_hd_count := 0
const DIG_FALLBACK = preload("res://assets/sprites/osvaldo_right_0.svg")
const DIG_FALLBACK_MOVE = preload("res://assets/sprites/osvaldo_right_1.svg")
const GRAVE_STAGES = [preload("res://assets/props/covas/Cova_01.png"),preload("res://assets/props/covas/Cova_02.png"),preload("res://assets/props/covas/Cova_03.png"),preload("res://assets/props/covas/Cova_04.png")]

func configure(job: Dictionary) -> void:
    order = job.duplicate(true)
    var raw: Variant = order.get("progress", {})
    if raw is Dictionary:
        phase = clampi(int(raw.get("phase", 0)), 0, 4)
        lowering = clampf(float(raw.get("lowering", 0.0)), 0.0, 1.0)
        mistakes = maxi(0, int(raw.get("mistakes", 0)))
        var batches: Variant = raw.get("completed", [])
        if batches is Array:
            for idx in range(mini(5, batches.size())):
                if batches[idx] is Array:
                    completed[idx] = batches[idx].duplicate()
    queue_redraw()

func snapshot() -> Dictionary:
    return {"phase": phase, "completed": completed.duplicate(true), "lowering": lowering, "mistakes": mistakes}

func _ready() -> void:
    name = "OficioDeOsvaldo"
    _load_dig_frames()
    mouse_filter = Control.MOUSE_FILTER_STOP
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    leave_button = Button.new()
    leave_button.name = "GuardarEVoltar"
    leave_button.text = "GUARDAR E VOLTAR"
    leave_button.anchor_left = 1.0
    leave_button.anchor_right = 1.0
    leave_button.offset_left = -209.0
    leave_button.offset_right = -15.0
    leave_button.offset_top = 15.0
    leave_button.offset_bottom = 64.0
    leave_button.custom_minimum_size = Vector2(190.0, 49.0)
    leave_button.add_theme_font_size_override("font_size", 16)
    leave_button.add_theme_color_override("font_color", PAPER)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#4f3145")
    style.border_color = GOLD
    style.set_border_width_all(2)
    style.set_corner_radius_all(9)
    for state in ["normal", "hover", "pressed", "focus"]:
        leave_button.add_theme_stylebox_override(state, style)
    add_child(leave_button)
    leave_button.pressed.connect(_leave)

func _zones() -> Array:
    var zones: Array = []
    match phase:
        0:
            for idx in range(3):
                zones.append(Rect2(177.0 + 215.0 * idx, 290.0, 175.0, 90.0))
        1:
            for pos in [Vector2(245,270),Vector2(405,235),Vector2(565,280),Vector2(330,365),Vector2(670,350)]:
                zones.append(Rect2(pos.x - 42.0, pos.y - 28.0, 84.0, 60.0))
        2:
            for row in range(2):
                for col in range(3):
                    zones.append(Rect2(293.0 + 120.0 * col, 267.0 + 77.0 * row, 100.0, 66.0))
        3:
            zones.append(Rect2(217.0, 322.0, 530.0, 60.0))
        4:
            for idx in range(3):
                zones.append(Rect2(169.0 + 214.0 * idx, 288.0, 182.0, 96.0))
    return zones

func _virtual_position(p: Vector2) -> Vector2:
    var scale_factor: float = minf(size.x / VIEW.x, size.y / VIEW.y)
    if scale_factor <= 0.0:
        return Vector2(-1000,-1000)
    return (p - (size - VIEW * scale_factor) * 0.5) / scale_factor

func _gui_input(event: InputEvent) -> void:
    if ended:
        return
    if event is InputEventMouseButton:
        if event.button_index != MOUSE_BUTTON_LEFT:
            return
        if event.pressed:
            _press(_virtual_position(event.position))
        else:
            _release()
        accept_event()
    elif event is InputEventMouseMotion and dragging:
        _move_slider(_virtual_position(event.position))
        accept_event()
    elif event is InputEventScreenTouch:
        if event.pressed:
            _press(_virtual_position(event.position))
        else:
            _release()
        accept_event()
    elif event is InputEventScreenDrag and dragging:
        _move_slider(_virtual_position(event.position))
        accept_event()

func _input(event: InputEvent) -> void:
    if ended or not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        _leave()
    elif phase == 3 and event.keycode in [KEY_RIGHT, KEY_D]:
        lowering = clampf(lowering + 0.14, 0.0, 1.0)
        _progress()
        if lowering >= 0.98:
            _advance()
    elif phase == 3 and event.keycode in [KEY_LEFT, KEY_A]:
        lowering = clampf(lowering - 0.14, 0.0, 1.0)
        _progress()
    elif phase != 3 and event.keycode >= KEY_1 and event.keycode <= KEY_6:
        _request_target(int(event.keycode - KEY_1))
    else:
        return
    get_viewport().set_input_as_handled()

func _press(p: Vector2) -> void:
    if dig_clock >= 0.0:
        return
    if Time.get_ticks_msec() - last_action_at < 110:
        return
    var zones := _zones()
    for idx in range(zones.size()):
        var candidate: Rect2 = zones[idx]
        if not candidate.has_point(p):
            continue
        last_action_at = Time.get_ticks_msec()
        if phase == 3:
            dragging = true
            _move_slider(p)
        else:
            _request_target(idx)
        return
    feedback = "Clique nas ferramentas ou areas destacadas."
    mistakes += 1
    _progress()

func _move_slider(p: Vector2) -> void:
    if phase != 3:
        return
    lowering = clampf((p.x - 240.0) / 483.0, 0.0, 1.0)
    feedback = "Descida controlada: %d%%" % int(lowering * 100.0)
    # Evita escrita em disco a cada pixel arrastado no Android/Web.
    var now: int = Time.get_ticks_msec()
    if now - last_slider_save_at >= 200:
        last_slider_save_at = now
        _progress()
    else:
        queue_redraw()

func _release() -> void:
    if not dragging:
        return
    dragging = false
    if phase == 3 and lowering >= 0.98:
        _advance()
    elif phase == 3:
        feedback = "Continue movendo o controle ate o ponto dourado."
        _progress()

func _load_dig_frames() -> void:
    dig_frames.clear()
    dig_hd_count = 0
    for key in DIG_NAMES:
        var path := DIG_DIR+str(key)+".webp"
        var tex: Texture2D = DIG_FALLBACK
        if ResourceLoader.exists(path):
            var loaded := load(path) as Texture2D
            if loaded != null:
                tex = loaded
                dig_hd_count += 1
        elif key != "idle":
            tex = DIG_FALLBACK_MOVE
        dig_frames.append(tex)

func _request_target(idx: int) -> void:
    if ended or dig_clock >= 0.0:
        return
    if phase != 2:
        activate_target(idx)
        return
    if idx < 0 or idx >= COUNTS[2] or completed[2].has(idx):
        return
    dig_target = idx
    dig_committed = false
    dig_clock = 0.0
    feedback = "Osvaldo: Esta terra nao vai se aposentar sozinha!"
    queue_redraw()

func _process(delta: float) -> void:
    if ended or dig_clock < 0.0:
        return
    dig_clock += delta
    if dig_clock >= DIG_IMPACT_SECONDS and not dig_committed:
        dig_committed = true
        # Apply once, when the blade reaches the soil.
        var done: Array = completed[2]
        if not done.has(dig_target):
            done.append(dig_target)
            completed[2] = done
            _progress()
    if dig_clock >= DIG_COMPLETE_SECONDS:
        var target: Rect2 = _zones()[dig_target]
        dig_anchor = target.get_center()+Vector2(-38.0,22.0)
        dig_clock = -1.0
        dig_target = -1
        if completed[2].size() == COUNTS[2]:
            _advance()
        else:
            feedback = "Mais um trecho pronto. Osvaldo agradece."
    queue_redraw()

func _dig_pose() -> int:
    if dig_clock < 0.20: return 0
    if dig_clock < 0.36: return 1
    if dig_clock < 0.49: return 2
    if dig_clock < 0.68: return 3
    if dig_clock < 0.88: return 4
    return 0

func _paint_digger() -> void:
    if dig_frames.size()!=5:
        return
    var from := dig_anchor if dig_anchor != Vector2.ZERO else Vector2(220,346)
    var foot := from
    var pose := 0
    if dig_clock >= 0.0 and dig_target >= 0:
        var zone: Rect2 = _zones()[dig_target]
        var destination := zone.get_center()+Vector2(-38.0,22.0)
        foot = from.lerp(destination,clampf(dig_clock/0.20,0.0,1.0))
        pose = _dig_pose()
    var tex: Texture2D = dig_frames[pose]
    var h := 98.0
    var w := h*float(tex.get_width())/maxf(1.0,float(tex.get_height()))
    draw_texture_rect(tex,Rect2(foot.x-w*0.42,foot.y-h,w,h),false)
    if dig_clock >= DIG_IMPACT_SECONDS and dig_clock < 0.83 and dig_target >= 0:
        var zone: Rect2 = _zones()[dig_target]
        var t := (dig_clock-DIG_IMPACT_SECONDS)/0.35
        for i in range(10):
            var p := zone.get_center()+Vector2(float(i-4)*9.0*t,-sin(t*PI)*28.0-float(i%3)*5.0)
            draw_rect(Rect2(p,Vector2(4,4)),Color("#a96b41"))

func activate_target(idx: int) -> void:
    if ended or dig_clock >= 0.0 or phase == 3 or idx < 0 or idx >= COUNTS[phase]:
        return
    var done: Array = completed[phase]
    if done.has(idx):
        return
    if phase == 4 and idx != done.size():
        feedback = "Um passo de cada vez: primeiro a base, depois a placa e as flores."
        mistakes += 1
        _progress()
        return
    done.append(idx)
    completed[phase] = done
    feedback = ["Ferramenta separada!", "Area limpa!", "Solo preparado!", "", "Boa finalizacao!"][phase]
    _progress()
    if done.size() == COUNTS[phase]:
        _advance()

func _advance() -> void:
    if ended:
        return
    phase += 1
    dragging = false
    if phase >= TITLES.size():
        ended = true
        finished.emit(true, clampi(100 - mistakes * 4, 60, 100))
        return
    feedback = "Etapa concluida. Vamos para a proxima!"
    _progress()

func _progress() -> void:
    progress_changed.emit(snapshot())
    queue_redraw()

func _leave() -> void:
    if ended:
        return
    if phase == 2 and completed[2].size() == COUNTS[2]:
        _advance()
    ended = true
    finished.emit(false, 0)

func _text(p: Vector2, message: String, font_px: int, color: Color = PAPER) -> void:
    draw_string(ThemeDB.fallback_font, p, message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_px, color)

func _paint_coffin(p: Vector2, scale_factor: float = 1.0) -> void:
    var poly := PackedVector2Array([
        p + Vector2(-64,-22) * scale_factor,
        p + Vector2(39,-22) * scale_factor,
        p + Vector2(68,-7) * scale_factor,
        p + Vector2(51,25) * scale_factor,
        p + Vector2(-51,25) * scale_factor,
        p + Vector2(-68,-7) * scale_factor
    ])
    draw_colored_polygon(poly, Color("#67432f"))
    var line := poly.duplicate()
    line.append(poly[0])
    draw_polyline(line, GOLD, 3.0, false)
    draw_line(p + Vector2(-42,0) * scale_factor, p + Vector2(42,0) * scale_factor, GOLD, 2.0, false)

func _draw() -> void:
    # A conclusao pode emitir finished e ainda receber um ultimo redraw.
    # Nunca indexar TITLES/TIPS/COUNTS com phase == 5.
    if ended or phase < 0 or phase >= TITLES.size():
        return
    var k: float = minf(size.x / VIEW.x, size.y / VIEW.y)
    if k <= 0.0:
        return
    var origin: Vector2 = (size - VIEW * k) * 0.5
    draw_rect(Rect2(Vector2.ZERO, size), INK)
    draw_set_transform(origin, 0.0, Vector2.ONE * k)

    # Cenário noturno de oficina/canteiro, sem imagens novas obrigatorias.
    draw_rect(Rect2(0,0,960,540),Color("#29233d"))
    draw_circle(Vector2(850,92),38,Color("#e6d7c3"))
    for idx in range(15):
        draw_circle(Vector2(38 + (idx * 73) % 850, 86 + (idx * 31) % 70),1.4,Color("#a99cb9"))
    draw_rect(Rect2(0,390,960,150),Color("#354438"))
    for idx in range(20):
        var x: float = float((idx * 59 + 17) % 920)
        draw_line(Vector2(x,425),Vector2(x+4,415),Color("#76825e"),2.0)
    draw_rect(Rect2(0,0,960,92),Color("#1b1628e8"))
    _text(Vector2(28,34),"O OFICIO DE OSVALDO",27,GOLD)
    _text(Vector2(30,65),"JARDIM DO ULTIMO SUSPIRO  |  %s" % str(order.get("plot","B-13")),16,PAPER)

    # Painel jogavel independente do resto do mapa.
    draw_rect(Rect2(74,103,812,349),Color("#211b2bdc"))
    draw_rect(Rect2(74,103,812,349),GOLD,false,2.0)
    _text(Vector2(105,139),"ETAPA %d/5  —  %s" % [phase + 1,TITLES[phase]],20,GOLD)
    _text(Vector2(105,170),TIPS[phase],16,PAPER)
    if phase != 2:
        draw_texture_rect_region(OSVALDO,Rect2(89,219,84,105),Rect2(3,92,52,65))
    if phase != 2:
        _text(Vector2(82,348),"OSVALDO",14,CYAN)
    else:
        _text(Vector2(105,194),"ESCAVACAO  |  %d/5 artes HD" % dig_hd_count,14,CYAN)
    draw_rect(Rect2(102,413,750,12),Color("#352b3e"))
    draw_rect(Rect2(102,413,(float(phase) + float(completed[phase].size()) / float(COUNTS[phase])) / 5.0 * 750.0,12),GOLD)

    var zones := _zones()
    var labels: Array = []
    match phase:
        0: labels = ["LUVAS", "PA", "SINALIZACAO"]
        1: labels = ["FOLHAS", "FOLHAS", "FOLHAS", "FOLHAS", "FOLHAS"]
        2: labels = ["TERRA","TERRA","TERRA","TERRA","TERRA","TERRA"]
        4: labels = ["NIVELAR", "IDENTIFICAR", "FLORES"]
    if phase == 3:
        draw_rect(Rect2(224,315,514,68),Color("#50394a"))
        draw_rect(Rect2(235,345,495,12),Color("#15101d"))
        draw_rect(Rect2(240,345,483.0*lowering,12),GOLD)
        draw_circle(Vector2(240+483.0*lowering,351),21,CYAN)
        _paint_coffin(Vector2(480,254),0.84)
        _text(Vector2(276,399),"ARRASTE OU USE A SETA DIREITA",16,PAPER)
    else:
        for idx in range(zones.size()):
            var area: Rect2 = zones[idx]
            var done: bool = (completed[phase] as Array).has(idx)
            var tone := Color("#3a5948") if done else Color("#55405c")
            draw_rect(area,tone)
            draw_rect(area,GOLD if not done else CYAN,false,2.0)
            if phase == 1 and not done:
                draw_circle(area.get_center()+Vector2(-11,2),12,Color("#b78952"))
                draw_circle(area.get_center()+Vector2(11,1),9,Color("#df9953"))
            elif phase == 2:
                draw_rect(area.grow(-3),Color("#48513a"))
                var stage := 3 if done else 0
                if dig_clock >= 0.0 and idx == dig_target and not done:
                    stage = 1 if dig_clock < 0.36 else 2
                draw_texture_rect(GRAVE_STAGES[stage],area.grow(-5),false)
                if not done:
                    draw_rect(area,GOLD,false,2.0)
            else:
                _text(area.position+Vector2(14,32),str(labels[idx]),16,PAPER)
            if done:
                _text(area.position+Vector2(14,area.size.y-14),"FEITO",14,CYAN)

    if phase == 2:
        _paint_digger()
    draw_rect(Rect2(75,464,808,51),Color("#191326"))
    _text(Vector2(92,495),feedback,16,PAPER)
    draw_set_transform(Vector2.ZERO)
