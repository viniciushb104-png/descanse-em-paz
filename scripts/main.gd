extends Node2D
## Vertical slice 0.1: exploracao, documentacao, finanças e manutencao.
## Os valores sao ficticios; requisitos reais variam conforme municipio e servico.

const WORLD := Vector2(1536.0, 960.0)
const MAP_ART = preload("res://scripts/map_art.gd")
const PAPER := Color("#f0e5cb")
const NIGHT := Color("#24192f")
const GOLD := Color("#deb57c")
const BLUE := Color("#8dbddc")
const STATIONS := [
    {"id": "osvaldo", "name": "Seu Osvaldo", "p": Vector2(725, 670)},
    {"id": "office", "name": "Escritorio", "p": Vector2(430, 490)},
    {"id": "plot", "name": "Jazigo B-13", "p": Vector2(1110, 365)},
    {"id": "maintenance", "name": "Manutencao", "p": Vector2(1255, 870)},
    {"id": "ghost", "name": "Baltazar", "p": Vector2(365, 560)}
]
const OBJECTIVES := [
    "Fale com Seu Osvaldo, o coveiro.",
    "Confira os documentos no escritorio.",
    "Verifique e reserve o jazigo B-13.",
    "Volte ao escritorio e registre o atendimento.",
    "Autorize a manutencao da quadra leste.",
    "Missao concluida! Explore Santa Mortalha."
]
@onready var player: CharacterBody2D = $Player
var stage: int = 0
var day: int = 1
var clock_minutes: float = 480.0
var money: int = 3500
var reputation: int = 55
var compliance: int = 65
var reserved_plot: bool = false
var dialogue_open: bool = false
var visual_animation_elapsed: float = 0.0
var status_label: Label
var objective_label: Label
var prompt_label: Label
var dialog_panel: Panel
var dialog_title: Label
var dialog_body: Label
var options_box: VBoxContainer

func _ready() -> void:
    _build_ui()
    _load_game()
    _refresh_ui()
    queue_redraw()
    if stage == 0:
        _show("Bem-vindo a Santa Mortalha!", "Voce herdou um cemiterio em crise. Um contador fantasma, um coveiro experiente e montanhas de papelada esperam por voce. Fale com Seu Osvaldo!\n\nWASD ou setas: mover | E: interagir | Esc: fechar.", [{"text": "Comecar expediente", "action": "close"}])
    else:
        _show("Bem-vindo de volta!", "Seu progresso foi recuperado. A morte pode esperar; a burocracia, jamais.", [{"text": "Continuar", "action": "close"}])

func _process(delta: float) -> void:
    visual_animation_elapsed += delta
    if visual_animation_elapsed >= 0.35:
        visual_animation_elapsed = 0.0
        queue_redraw()
    if not dialogue_open:
        clock_minutes += delta * 1.8
        if clock_minutes >= 1080.0:
            _next_day()
    _refresh_ui()

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE and dialogue_open:
        _close()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_E and not dialogue_open:
        _try_interact()
        get_viewport().set_input_as_handled()

func _near_station() -> Dictionary:
    var nearest: Dictionary = {}
    var shortest := 98.0
    for station in STATIONS:
        var distance: float = player.global_position.distance_to(station["p"])
        if distance < shortest:
            shortest = distance
            nearest = station
    return nearest

func _try_interact() -> void:
    if dialogue_open:
        return
    var station := _near_station()
    if not station.is_empty():
        _interact(str(station["id"]))

func _interact(id: String) -> void:
    match id:
        "osvaldo":
            if stage == 0:
                _show("Seu Osvaldo, o coveiro", "Opa, chefe! Antes de um sepultamento, precisamos conferir documentos, disponibilidade de jazigo e registros. O balcao fica no escritorio. E nada de atalhos!", [{"text": "Entendido!", "action": "talk"}])
            else:
                _show("Seu Osvaldo", "O cemiterio nao se administra sozinho! Olhe o estado dos caminhos, os registros e o treinamento da equipe. E nao pise nas flores!", [{"text": "Ate mais", "action": "close"}])
        "office":
            if stage == 1:
                _show("Atendimento: documentacao", "Uma familia chegou com apenas a Declaracao de Obito. Qual deve ser a conduta do administrador?", [{"text": "Conferir os requisitos e orientar a familia", "action": "docs_ok"}, {"text": "Ignorar o problema e prosseguir", "action": "docs_bad"}, {"text": "Voltar", "action": "close"}])
            elif stage == 3:
                _show("Registro financeiro", "Documentos conferidos e jazigo reservado. Valores ficticios: receita R$ 720, custo operacional direto R$ 250. Registrar o atendimento?", [{"text": "Registrar e emitir comprovante", "action": "register"}, {"text": "Voltar", "action": "close"}])
            else:
                _show("Escritorio administrativo", "Saldo em caixa: R$ %d. A gestao inclui pagamentos, registros, contratos, custos e atendimento etico." % money, [{"text": "Ver aviso educativo", "action": "learn"}, {"text": "Fechar", "action": "close"}])
        "plot":
            if stage == 2 and not reserved_plot:
                _show("Quadra B, jazigo B-13", "O cadastro ficticio indica que este jazigo esta disponivel. Em casos reais, conferem-se tambem titularidade, direitos de uso e regras locais.", [{"text": "Reservar jazigo", "action": "reserve"}, {"text": "Voltar", "action": "close"}])
            else:
                _show("Quadra B, jazigo B-13", "Estado: %s. A rastreabilidade de cada sepultura e essencial." % ("RESERVADO" if reserved_plot else "LIVRE"), [{"text": "Fechar", "action": "close"}])
        "maintenance":
            if stage == 4:
                _show("Manutencao preventiva", "Revisar caminhos, vegetacao e drenagem reduz riscos. Investimento didatico: R$ 160. Deseja autorizar?", [{"text": "Autorizar R$ 160", "action": "maintain"}, {"text": "Deixar para depois", "action": "close"}])
            else:
                _show("Area de manutencao", "Visitas e trabalho seguros exigem caminhos, drenagem, sinalizacao e vegetacao bem cuidados.", [{"text": "Fechar", "action": "close"}])
        "ghost":
            _show("Baltazar, o contador fantasma", "Caixa positivo NAO significa lucro, meu jovem! Ainda existem salarios, materiais, impostos, manutencao e reservas. Morri esperando uma nota fiscal!", [{"text": "Cuidarei das contas", "action": "close"}])

func _on_choice(action: String) -> void:
    match action:
        "close":
            _close()
        "talk":
            stage = 1
            _close()
        "docs_ok":
            stage = 2
            compliance = mini(100, compliance + 7)
            _show("Procedimento responsavel", "Boa escolha! A Declaracao de Obito apoia o registro do obito; o sepultamento exige a documentacao legal aplicavel, com excecoes previstas na lei. Confira a Lei 6.015/1973 e normas locais.", [{"text": "Localizar jazigo", "action": "close"}])
        "docs_bad":
            compliance = maxi(0, compliance - 10)
            reputation = maxi(0, reputation - 5)
            _show("Nao conformidade!", "Ignorar a documentacao nao e opcao. Voce perdeu reputacao e conformidade. Volte ao balcao e faca a conferencia.", [{"text": "Tentar de novo", "action": "close"}])
        "reserve":
            reserved_plot = true
            stage = 3
            queue_redraw()
            _show("Reserva registrada", "Jazigo B-13 reservado. Agora retorne ao escritorio e registre o atendimento.", [{"text": "Continuar", "action": "close"}])
        "register":
            if not reserved_plot:
                _show("Cadastro incompleto", "Reserve o jazigo antes de registrar o atendimento.", [{"text": "Fechar", "action": "close"}])
                return
            money += 720 - 250
            reputation = mini(100, reputation + 10)
            stage = 4
            _show("Registro concluido", "Receita: +R$ 720. Custo direto: -R$ 250. Margem de contribuicao didatica: R$ 470 (nao e lucro final). Veja tambem as despesas fixas!", [{"text": "Ver manutencao", "action": "close"}])
        "maintain":
            if money < 160:
                _show("Saldo insuficiente", "Planeje o caixa antes de gastar.", [{"text": "Fechar", "action": "close"}])
                return
            money -= 160
            compliance = mini(100, compliance + 5)
            reputation = mini(100, reputation + 5)
            stage = 5
            _show("Parabens, administrador!", "Voce concluiu a primeira missao! Conferiu documentos, reservou um jazigo, registrou receitas e custos e autorizou manutencao. Santa Mortalha ainda tem muito trabalho!", [{"text": "Explorar", "action": "close"}])
        "learn":
            _show("Nota educativa", "Simulacao inspirada em procedimentos brasileiros. Normas variam por municipio, tipo de cemiterio e servico. Nao use esta demo como manual juridico ou sanitario.", [{"text": "Fechar", "action": "close"}])
    _save_game()
    _refresh_ui()

func _next_day() -> void:
    day += 1
    clock_minutes = 480.0
    money -= 95
    _save_game()
    _show("Dia %d — novo expediente" % day, "Despesas fixas didaticas do dia anterior: R$ 95. Nem mesmo os mortos escapam da contabilidade.", [{"text": "Abrir o portao", "action": "close"}])

func _save_game() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("save", "stage", stage)
    cfg.set_value("save", "day", day)
    cfg.set_value("save", "money", money)
    cfg.set_value("save", "reputation", reputation)
    cfg.set_value("save", "compliance", compliance)
    cfg.set_value("save", "reserved_plot", reserved_plot)
    cfg.set_value("save", "position", player.global_position)
    cfg.set_value("save", "clock", clock_minutes)
    cfg.save("user://save.cfg")

func _load_game() -> void:
    var cfg := ConfigFile.new()
    if cfg.load("user://save.cfg") != OK:
        return
    stage = clampi(int(cfg.get_value("save", "stage", 0)), 0, 5)
    day = maxi(1, int(cfg.get_value("save", "day", 1)))
    money = int(cfg.get_value("save", "money", 3500))
    reputation = clampi(int(cfg.get_value("save", "reputation", 55)), 0, 100)
    compliance = clampi(int(cfg.get_value("save", "compliance", 65)), 0, 100)
    reserved_plot = bool(cfg.get_value("save", "reserved_plot", false))
    clock_minutes = float(cfg.get_value("save", "clock", 480.0))
    player.global_position = cfg.get_value("save", "position", player.global_position)

func _close() -> void:
    dialogue_open = false
    dialog_panel.visible = false

func _show(heading: String, body: String, choices: Array) -> void:
    dialogue_open = true
    dialog_panel.visible = true
    dialog_title.text = heading
    dialog_body.text = body
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    for choice in choices:
        var btn := Button.new()
        btn.text = str(choice["text"])
        btn.custom_minimum_size = Vector2(0, 34)
        btn.add_theme_font_size_override("font_size", 17)
        btn.pressed.connect(_on_choice.bind(str(choice["action"])))
        options_box.add_child(btn)

func _style(bg: Color, edge: Color) -> StyleBoxFlat:
    var st := StyleBoxFlat.new()
    st.bg_color = bg
    st.border_color = edge
    st.set_border_width_all(3)
    st.set_corner_radius_all(9)
    return st

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var root := Control.new()
    layer.add_child(root)
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var bar := Panel.new()
    bar.position = Vector2.ZERO
    bar.size = Vector2(1152, 67)
    bar.add_theme_stylebox_override("panel", _style(NIGHT, GOLD))
    bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(bar)
    status_label = Label.new()
    status_label.position = Vector2(18, 14)
    status_label.size = Vector2(1110, 45)
    status_label.add_theme_font_size_override("font_size", 19)
    status_label.add_theme_color_override("font_color", PAPER)
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bar.add_child(status_label)

    var mission := Panel.new()
    mission.position = Vector2(674, 78)
    mission.size = Vector2(460, 112)
    mission.add_theme_stylebox_override("panel", _style(Color("#302238"), Color("#917259")))
    mission.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(mission)
    objective_label = Label.new()
    objective_label.position = Vector2(14, 10)
    objective_label.size = Vector2(433, 95)
    objective_label.add_theme_font_size_override("font_size", 19)
    objective_label.add_theme_color_override("font_color", PAPER)
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mission.add_child(objective_label)

    prompt_label = Label.new()
    prompt_label.position = Vector2(188, 598)
    prompt_label.size = Vector2(780, 34)
    prompt_label.add_theme_font_size_override("font_size", 18)
    prompt_label.add_theme_color_override("font_color", PAPER)
    prompt_label.add_theme_color_override("font_shadow_color", Color.BLACK)
    prompt_label.add_theme_constant_override("shadow_offset_x", 2)
    prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(prompt_label)

    dialog_panel = Panel.new()
    dialog_panel.position = Vector2(146, 306)
    dialog_panel.size = Vector2(860, 330)
    dialog_panel.visible = false
    dialog_panel.add_theme_stylebox_override("panel", _style(NIGHT, GOLD))
    root.add_child(dialog_panel)
    dialog_title = Label.new()
    dialog_title.position = Vector2(22, 13)
    dialog_title.size = Vector2(815, 38)
    dialog_title.add_theme_font_size_override("font_size", 24)
    dialog_title.add_theme_color_override("font_color", BLUE)
    dialog_panel.add_child(dialog_title)
    dialog_body = Label.new()
    dialog_body.position = Vector2(22, 56)
    dialog_body.size = Vector2(812, 128)
    dialog_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialog_body.add_theme_font_size_override("font_size", 17)
    dialog_body.add_theme_color_override("font_color", PAPER)
    dialog_panel.add_child(dialog_body)
    options_box = VBoxContainer.new()
    options_box.position = Vector2(22, 186)
    options_box.size = Vector2(812, 131)
    options_box.add_theme_constant_override("separation", 4)
    dialog_panel.add_child(options_box)

    _touch_controls(root)

func _touch_controls(root: Control) -> void:
    var directions := [
        {"label": "◀", "p": Vector2(24, 549), "d": Vector2.LEFT},
        {"label": "▲", "p": Vector2(80, 498), "d": Vector2.UP},
        {"label": "▼", "p": Vector2(80, 549), "d": Vector2.DOWN},
        {"label": "▶", "p": Vector2(136, 549), "d": Vector2.RIGHT}
    ]
    for info in directions:
        var btn := Button.new()
        btn.text = str(info["label"])
        btn.position = info["p"]
        btn.size = Vector2(50, 46)
        btn.modulate.a = 0.8
        var direction: Vector2 = info["d"]
        btn.button_down.connect(func() -> void: player.set("virtual_direction", direction))
        btn.button_up.connect(func() -> void: player.set("virtual_direction", Vector2.ZERO))
        root.add_child(btn)
    var interact := Button.new()
    interact.text = "INTERAGIR [E]"
    interact.position = Vector2(976, 549)
    interact.size = Vector2(160, 48)
    interact.pressed.connect(_try_interact)
    root.add_child(interact)

func _refresh_ui() -> void:
    if status_label == null:
        return
    var total: int = int(clock_minutes)
    status_label.text = "☠ SANTA MORTALHA   Dia %d  |  %02d:%02d  |  Caixa R$ %d  |  Reputacao %d/100  |  Conformidade %d/100" % [day, int(total / 60.0), total % 60, money, reputation, compliance]
    objective_label.text = "MISSAO DO EXPEDIENTE\n" + OBJECTIVES[stage]
    if dialogue_open:
        prompt_label.text = ""
    else:
        var near := _near_station()
        prompt_label.text = ("[E] " + str(near["name"])) if not near.is_empty() else "Aproxime-se de um marcador para interagir"

func is_walkable(world_position: Vector2) -> bool:
    # Os edificios possuem solidez basica. O escritorio e acessivel pela frente.
    if Rect2(224, 155, 435, 293).has_point(world_position):
        return false
    if Rect2(1136, 669, 266, 168).has_point(world_position):
        return false
    # Fora dos limites do cemitério
    return world_position.x >= 65.0 and world_position.x <= 1465.0 and world_position.y >= 100.0 and world_position.y <= 882.0

func _draw() -> void:
    MAP_ART.paint(self, reserved_plot, clock_minutes)
