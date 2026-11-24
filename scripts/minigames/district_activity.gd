extends Control
signal finished(success: bool, score: int)
const CATALOG = preload("res://scripts/systems/activity_catalog.gd")
var activity_id: String
var mode: String
var info: Dictionary
var title_label: Label
var status: Label
var area: VBoxContainer
var score := 0
var mistakes := 0
var ended := false
var buttons: Array[Button] = []
var values: Array = []
var selected := -1
var matched: Array[int] = []
var index := 0
var rows: Array = []
var cursor := Vector2i(0,0)
var targets: Array[Vector2i] = []
var walls: Array[Vector2i] = []
var occupied: Array[Vector2i] = []
var flower_count := 0
var flower_cost := 0
var flower_colors: Array[String] = []
var stage_view: Control
var pos := Vector2(30,170)
var velocity := Vector2.ZERO
var move_dir := 0
var jump_requested := false
var grounded := false
var collected: Array[int] = []
const LEDGES = [Rect2(0,200,150,20),Rect2(180,166,110,20),Rect2(320,132,110,20),Rect2(460,166,100,20),Rect2(590,200,130,20)]
const LIGHTS = [Vector2(240,140),Vector2(375,106),Vector2(510,140)]
func setup(id: String) -> void:
    activity_id = id
    info = CATALOG.ACTIVITIES[id]
    mode = str(info["mode"])
func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg := ColorRect.new()
    bg.color = Color("#21162d")
    add_child(bg)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var margin := MarginContainer.new()
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","right","top","bottom"]:
        margin.add_theme_constant_override("margin_"+side,12)
    var root_box := VBoxContainer.new()
    margin.add_child(root_box)
    title_label = Label.new()
    title_label.text = str(info["title"])
    title_label.add_theme_font_size_override("font_size",24)
    root_box.add_child(title_label)
    var intro := Label.new()
    intro.text = str(info["intro"])
    intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root_box.add_child(intro)
    status = Label.new()
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root_box.add_child(status)
    area = VBoxContainer.new()
    area.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root_box.add_child(area)
    var exit := _button("Voltar ao expediente",root_box)
    exit.pressed.connect(func(): _end(false))
    match mode:
        "memory": _memory()
        "sort": _sorting()
        "stock": _grid_start()
        "garden": _grid_start()
        "maze": _grid_start()
        "flowers": _flowers()
        "platform": _platform()
        "sequence": _sequence()
func _button(label_text: String, parent: Node) -> Button:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(0,44)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.focus_mode = Control.FOCUS_NONE
    button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#493351")
    style.border_color = Color("#c49a5b")
    style.set_border_width_all(1)
    style.set_corner_radius_all(5)
    button.add_theme_stylebox_override("normal",style)
    parent.add_child(button)
    return button
func _end(success: bool) -> void:
    if ended:
        return
    ended = true
    finished.emit(success,clampi(100-mistakes*10,0,100) if success else 0)
func _memory() -> void:
    values = ["A-01","A-01","B-07","B-07","N-02","N-02","C-04","C-04","A-09","A-09","N-06","N-06"]
    values.shuffle()
    var grid := GridContainer.new()
    grid.columns = 4
    area.add_child(grid)
    for i in range(values.size()):
        var b := _button("?",grid)
        buttons.append(b)
        b.pressed.connect(_flip.bind(i))
    status.text = "Encontre os seis pares."
func _flip(i: int) -> void:
    if ended or i in matched or i==selected or index==1:
        return
    buttons[i].text = str(values[i])
    if selected<0:
        selected=i
        return
    var previous := selected
    selected=-1
    if values[i]==values[previous]:
        matched.append(i)
        matched.append(previous)
        buttons[i].disabled=true
        buttons[previous].disabled=true
        status.text = "Pares: %d/6" % (matched.size()/2)
        if matched.size()==values.size():
            _end(true)
    else:
        mistakes+=1
        index=1
        await get_tree().create_timer(0.65).timeout
        if not is_inside_tree() or ended:
            return
        buttons[i].text="?"
        buttons[previous].text="?"
        index=0
func _sequence() -> void:
    values = ["Conferir o registro","Identificar a placa","Limpar com cuidado","Registrar a restauracao"]
    var shuffled := values.duplicate()
    shuffled.shuffle()
    for choice in shuffled:
        var b := _button(str(choice),area)
        b.pressed.connect(_sequence_pick.bind(str(choice),b))
    status.text = "Organize as quatro etapas do memorial."
func _sequence_pick(choice: String,b: Button) -> void:
    if ended:
        return
    if choice != values[index]:
        mistakes += 1
        status.text = "A ordem importa. Reveja o proximo passo."
        return
    b.disabled = true
    index += 1
    status.text = "Etapas: %d/4" % index
    if index == values.size():
        _end(true)
func _sorting() -> void:
    match activity_id:
        "finance": rows=[["Recebimento de serviço registrado","Entrada"],["Compra de urna com nota","Saída"],["Boleto já quitado","Revisar"],["Salário da equipe","Saída"],["Pagamento confirmado da família","Entrada"],["Cobrança sem comprovante","Revisar"]]
        "workshop": rows=[["Pneu danificado","Manutenção"],["Luzes funcionando","Conferido"],["Freio com falha","Manutenção"],["Documentação de inspeção conferida","Conferido"],["Vazamento identificado","Manutenção"],["Equipamento de segurança presente","Conferido"]]
        "memorial_records": rows=[["Placa ilegivel e cadastro ausente","Pendência"],["Nome e numero conferidos","Conferido"],["Duas fichas com numeros divergentes","Pendência"],["Restauracao registrada","Conferido"],["Data sem fonte","Pendência"],["Autorizacao e registro conferidos","Conferido"]]
        _: rows=[["Identidade divergente entre registros","Pendência"],["Autorização fictícia ausente","Pendência"],["Cadastro e identidade conferidos","Conferido"],["Comprovante sem identificação","Pendência"],["Registro fictício completo","Conferido"],["Dados de jazigo inconsistentes","Pendência"]]
    rows.shuffle()
    var options: Array = ["Entrada","Saída","Revisar"] if activity_id=="finance" else (["Manutenção","Conferido"] if activity_id=="workshop" else ["Pendência","Conferido"])
    for option in options:
        var b := _button(str(option),area)
        b.pressed.connect(_sort_pick.bind(str(option)))
    _sort_status()
func _sort_status() -> void:
    status.text = "Ficha %d/%d: %s" % [index+1,rows.size(),rows[index][0]]
func _sort_pick(option: String) -> void:
    if ended:
        return
    if option!=str(rows[index][1]):
        mistakes+=1
        status.text="Revise esta ficha: "+str(rows[index][0])
        return
    index+=1
    if index>=rows.size():
        _end(true)
    else:
        _sort_status()
func _grid_start() -> void:
    var grid := GridContainer.new()
    grid.columns=6
    area.add_child(grid)
    if mode=="stock":
        walls=[Vector2i(2,0),Vector2i(2,1),Vector2i(2,2),Vector2i(2,3)]
        status.text="Coloque três caixas de duas células em prateleiras livres."
    elif mode=="garden":
        targets=[Vector2i(1,0),Vector2i(4,1),Vector2i(2,2),Vector2i(5,3),Vector2i(0,3)]
        if activity_id=="nursery":
            walls=[Vector2i(2,0),Vector2i(2,1),Vector2i(4,2)]
            targets=[Vector2i(1,0),Vector2i(4,1),Vector2i(2,2),Vector2i(5,3),Vector2i(0,3),Vector2i(5,0)]
    else:
        walls=[Vector2i(1,0),Vector2i(1,1),Vector2i(3,1),Vector2i(3,2),Vector2i(4,2)]
        targets=[Vector2i(5,3)]
        if activity_id=="crypt":
            targets=[Vector2i(0,3),Vector2i(5,3)]
    for y in range(4):
        for x in range(6):
            var b := _button("",grid)
            buttons.append(b)
            b.pressed.connect(_grid_pick.bind(Vector2i(x,y)))
    _grid_render()
func _grid_render() -> void:
    for i in range(buttons.size()):
        var p := Vector2i(i%6,int(i/6))
        var mark := "·"
        if p in walls:
            mark="Parede" if mode=="maze" else "Corredor"
        elif p in occupied:
            mark="Caixa"
        elif p==cursor and mode!="stock":
            mark="Você"
        elif p in targets:
            if activity_id=="crypt":
                mark="Chave" if p==Vector2i(0,3) else "Saida"
            else:
                mark="Jazigo" if mode=="maze" else ("Muda" if activity_id=="nursery" else "Folhas")
        buttons[i].text=mark
    if mode=="garden":
        status.text="Toque numa célula vizinha para andar. Restantes: %d" % targets.size()
    elif mode=="maze":
        status.text="Encontre a chave, depois a saida." if activity_id=="crypt" else "Toque numa célula vizinha. Não atravesse paredes."
    else:
        status.text="Caixas guardadas: %d/3. Preserve o corredor." % (occupied.size()/2)
func _grid_pick(p: Vector2i) -> void:
    if ended:
        return
    if mode=="stock":
        var next := p+Vector2i(1,0)
        if p.x>=5 or p in walls or next in walls or p in occupied or next in occupied:
            mistakes+=1
            status.text="Espaço ocupado ou corredor. Escolha outra posição."
            return
        occupied.append(p)
        occupied.append(next)
        if occupied.size()==6:
            _end(true)
            return
    else:
        if absi(p.x-cursor.x)+absi(p.y-cursor.y)!=1 or p in walls:
            return
        if activity_id=="crypt" and p==Vector2i(5,3) and Vector2i(0,3) in targets:
            status.text="A porta precisa da chave."
            return
        cursor=p
        if p in targets:
            targets.erase(p)
        if targets.is_empty():
            _end(true)
            return
    _grid_render()
func _flowers() -> void:
    status.text="Pedido: 3 flores, duas cores, orçamento R$ 30."
    for pair in [["Lírio branco",10],["Rosa violeta",12],["Margarida amarela",7]]:
        var b := _button("%s • R$ %d" % pair,area)
        b.pressed.connect(_flower_pick.bind(str(pair[0]),int(pair[1])))
    var undo := _button("Desmontar arranjo",area)
    undo.pressed.connect(func(): flower_count=0; flower_cost=0; flower_colors.clear(); status.text="Arranjo vazio. Orçamento R$ 30.")
    var done := _button("Entregar arranjo",area)
    done.pressed.connect(_flower_finish)
func _flower_pick(name_text: String, cost: int) -> void:
    if flower_count>=3:
        return
    flower_count+=1
    flower_cost+=cost
    if not name_text in flower_colors:
        flower_colors.append(name_text)
    status.text="Flores %d/3 • Cores %d • Total R$ %d/30" % [flower_count,flower_colors.size(),flower_cost]
func _flower_finish() -> void:
    if flower_count==3 and flower_colors.size()>=2 and flower_cost<=30:
        _end(true)
    else:
        mistakes+=1
        status.text="Revise quantidade, cores e orçamento antes de entregar."
func _platform() -> void:
    status.text="A/D ou setas: andar. Espaço: pular. Recolha 3 lanternas."
    stage_view=Control.new()
    stage_view.custom_minimum_size=Vector2(0,210)
    stage_view.size_flags_vertical=Control.SIZE_EXPAND_FILL
    area.add_child(stage_view)
    stage_view.draw.connect(_draw_platform)
    var controls := HBoxContainer.new()
    area.add_child(controls)
    for pair in [["Esquerda",-1],["Direita",1]]:
        var b := _button(str(pair[0]),controls)
        b.button_down.connect(_move.bind(int(pair[1])))
        b.button_up.connect(_move.bind(0))
    var jump := _button("Pular",controls)
    jump.button_down.connect(func(): jump_requested=true)
func _move(direction: int) -> void:
    move_dir=direction
func _physics_process(delta: float) -> void:
    if mode!="platform" or ended or not is_instance_valid(stage_view):
        return
    var direction := move_dir
    if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
        direction=-1
    elif Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
        direction=1
    if grounded and (jump_requested or Input.is_physical_key_pressed(KEY_SPACE)):
        velocity.y=-320.0
    jump_requested=false
    var old_y := pos.y
    velocity.y+=720.0*delta
    pos.x=clampf(pos.x+float(direction)*175.0*delta,10.0,710.0)
    pos.y+=velocity.y*delta
    grounded=false
    for ledge in LEDGES:
        if velocity.y>=0.0 and old_y<=ledge.position.y and pos.y>=ledge.position.y and pos.x>=ledge.position.x and pos.x<=ledge.end.x:
            pos.y=ledge.position.y
            velocity.y=0.0
            grounded=true
    if pos.y>260.0:
        mistakes+=1
        pos=Vector2(30,170)
        velocity=Vector2.ZERO
    for i in range(LIGHTS.size()):
        if not i in collected and (pos-Vector2(0,14)).distance_to(LIGHTS[i])<24.0:
            collected.append(i)
    if pos.x>675.0 and grounded and collected.size()==3:
        _end(true)
        return
    status.text="Lanternas %d/3 • Quedas %d" % [collected.size(),mistakes]
    stage_view.queue_redraw()
func _draw_platform() -> void:
    var scale_value := minf(stage_view.size.x/720.0,stage_view.size.y/240.0)
    stage_view.draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE*scale_value)
    stage_view.draw_rect(Rect2(0,0,720,240),Color("#302240"))
    stage_view.draw_circle(Vector2(650,40),25,Color("#eac983"))
    for ledge in LEDGES:
        stage_view.draw_rect(ledge,Color("#66536e"))
        stage_view.draw_rect(Rect2(ledge.position,Vector2(ledge.size.x,4)),Color("#a68a67"))
    for i in range(LIGHTS.size()):
        if not i in collected:
            stage_view.draw_circle(LIGHTS[i],8,Color("#f3c36a"))
    stage_view.draw_rect(Rect2(680,164,24,36),Color("#8b6b9d"))
    stage_view.draw_circle(pos-Vector2(0,15),12,Color("#d8c4ef"))
    stage_view.draw_circle(pos-Vector2(4,18),2,Color("#20152b"))
    stage_view.draw_circle(pos-Vector2(-4,18),2,Color("#20152b"))
