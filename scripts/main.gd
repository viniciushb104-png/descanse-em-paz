extends Node2D
## Vertical slice 0.1: exploracao, documentacao, finanças e manutencao.
## Os valores sao ficticios; requisitos reais variam conforme municipio e servico.

const WORLD := Vector2(3072.0, 2304.0)
const WAKE = preload("res://scripts/systems/wake_ceremony.gd")
const BURIAL_FIELD = preload("res://scripts/world/burial_field.gd")
var burial_field: Node2D
const GRAVE_LAYOUT = preload("res://scripts/world/graves_layout.gd")
const TREE_LAYOUT = preload("res://scripts/world/trees_layout.gd")
const DISTRICT_LAYOUT = preload("res://scripts/world/district_layout.gd")
const LEGAL = preload("res://scripts/systems/legal_lessons.gd")
const MOBILE_HUD = preload("res://scripts/ui/mobile_hud.gd")
const CLIENT_PORTRAIT = preload("res://scripts/ui/client_portrait.gd")
const DIALOGUE_CHARACTERS = preload("res://scripts/ui/dialogue_characters.gd")
const DIALOGUE_FRAME = preload("res://scripts/ui/dialogue_frame.gd")
const DIALOGUE_ART = preload("res://scripts/ui/dialogue_art_lote_01.gd")
const PORTRAIT_EXPRESSIONS = preload("res://scripts/ui/portrait_expressions.gd")
const CEMETERY_CAT = preload("res://scripts/world/cemetery_cat.gd")
const BURIAL_QUEUE = preload("res://scripts/systems/burial_service_queue.gd")
const BURIAL_MINIGAME = preload("res://scripts/minigames/oficio_osvaldo.gd")
@onready var rooms: Node = $RoomsRuntime
## Piso e objetos agora vivem em camadas separadas.
const PAPER := Color("#f0e5cb")
const NIGHT := Color("#24192f")
const GOLD := Color("#deb57c")
const BLUE := Color("#8dbddc")
const STATIONS := [
    {"id":"chapel","name":"Capela do Ultimo Adeus","p":Vector2(780,-175)},
    {"id": "osvaldo", "name": "Seu Osvaldo", "p": Vector2(778, 638)},
    {"id": "office", "name": "Escritorio", "p": Vector2(425, 476)},
    {"id": "plot", "name": "Jazigo B-13", "p": Vector2(1125, 630)},
    {"id": "maintenance", "name": "Manutencao", "p": Vector2(1270, 407)},
    {"id": "ghost", "name": "Baltazar", "p": Vector2(572, 500)}
]
const OBJECTIVES := [
    "Fale com Seu Osvaldo, o coveiro.",
    "Confira os documentos no escritorio.",
    "Verifique e reserve o jazigo B-13.",
    "Volte ao escritorio e registre o atendimento.",
    "Autorize a manutencao da quadra leste.",
    "Visite o hospital e descubra quem emite a Declaracao de Obito.",
    "Volte ao escritorio e confira o papel do Registro Civil.",
    "Inspecione a garagem e os carros funerarios.",
    "Converse com Clotilde sobre conservacao e biosseguranca.",
    "Visite o crematorio e confira os requisitos legais.",
    "Procure o posto de fiscalizacao ambiental.",
    "Volte ao escritorio e prepare um orcamento transparente.",
    "Distrito dos Eternos concluido! Explore e consulte o Arquivo Legal."
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
const SPAWN := Vector2(748, 714)
const MAP_SAVE_VERSION := 4
var rescue_notice: String = ""
var location_hint: String = ""
var location_hint_seconds: float = 0.0
var visual_animation_elapsed: float = 0.0
var status_label: Label
var objective_label: Label
var prompt_label: Label
var dialog_panel: Panel
var dialog_title: Label
var dialog_body: Label
var dialog_portrait: Control
var dialog_frame: Control
var dialog_role: Label
var dialog_nameplate_art: TextureRect
var dialog_portrait_nameplate_text: Label
var dialog_portrait_frame_art: TextureRect
var options_box: VBoxContainer
var mobile_hud: Control
var driving_layer: CanvasLayer
var driving_completed: bool = false
var driving_job: bool = false
var burial_queue = BURIAL_QUEUE.new()
var burial_layer: CanvasLayer
var burial_marker: Label
var cemetery_cat: Node2D

func _ready() -> void:
    cemetery_cat = CEMETERY_CAT.new()
    cemetery_cat.name = "GatoDoCemiterio"
    add_child(cemetery_cat)
    _build_ui()
    _load_game()
    if burial_queue.ensure_initial_order(stage, reserved_plot, day):
        _save_game()
    burial_field = BURIAL_FIELD.new()
    burial_field.name = "BurialField"
    add_child(burial_field)
    _build_burial_marker()
    rooms.apply_room()
    _ensure_valid_player_position()
    _refresh_ui()
    $PropsLayer.queue_redraw()
    if stage == 0:
        _show("Bem-vindo a Santa Mortalha!", "Voce herdou um cemiterio em crise. Um contador fantasma, um coveiro experiente e montanhas de papelada esperam por voce. Fale com Seu Osvaldo!\n\nWASD ou setas: mover | E: interagir | Esc: fechar.", [{"text": "Comecar expediente", "action": "close"}])
    else:
        _notify("Bem-vindo de volta! O expediente continua.",1.8)

func _process(delta: float) -> void:
    location_hint_seconds = maxf(0.0,location_hint_seconds-delta)
    visual_animation_elapsed += delta
    if visual_animation_elapsed >= 0.35:
        visual_animation_elapsed = 0.0
        $PropsLayer.queue_redraw()
    if is_instance_valid(burial_marker):
        burial_marker.visible = burial_queue.has_pending() and not rooms.inside() and not is_instance_valid(burial_layer)
        burial_marker.position = Vector2(725.0, 515.0 + sin(float(Time.get_ticks_msec()) * 0.002) * 3.0)
    if not dialogue_open:
        clock_minutes += delta * 1.8
        if clock_minutes >= 1080.0:
            _next_day()
    _refresh_ui()

func _unhandled_key_input(event: InputEvent) -> void:
    if is_instance_valid(driving_layer) or is_instance_valid(burial_layer):
        return
    if not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return
    if dialogue_open and event.keycode >= KEY_1 and event.keycode <= KEY_4:
        var index: int = event.keycode - KEY_1
        var choices: Array = options_box.get_children()
        if index < choices.size():
            (choices[index] as Button).pressed.emit()
        get_viewport().set_input_as_handled()
        return
    if dialogue_open and event.keycode in [KEY_ENTER,KEY_KP_ENTER] and options_box.get_child_count() == 1:
        (options_box.get_child(0) as Button).pressed.emit()
        get_viewport().set_input_as_handled()
        return
    if event.keycode == KEY_J and not dialogue_open:
        _open_journal()
        get_viewport().set_input_as_handled()
        return
    if event.keycode == KEY_ESCAPE:
        if dialogue_open:
            _close()
        else:
            _open_pause_menu()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_E and not dialogue_open:
        _try_interact()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_R:
        _rescue_player()
        get_viewport().set_input_as_handled()

func _near_station() -> Dictionary:
    if rooms.inside():
        return rooms.nearest(player.global_position)
    if is_instance_valid(burial_field):
        var field_station: Dictionary = burial_field.near(player.global_position)
        if not field_station.is_empty():
            return field_station
    # Prioridade para portas e NPCs: o carro sul fica muito perto da
    # Fiscalizacao. Seu raio ampliado nao pode interceptar a entrada do posto.
    var nearest: Dictionary = {}
    var shortest := 98.0
    if is_instance_valid(cemetery_cat) and player.global_position.distance_to(cemetery_cat.global_position) < 76.0:
        shortest = player.global_position.distance_to(cemetery_cat.global_position)
        nearest = {"id":"cemetery_cat","name":"Gato do Cemiterio (carinho)","p":cemetery_cat.global_position}
    for station in STATIONS + DISTRICT_LAYOUT.STATIONS:
        var distance: float = player.global_position.distance_to(station["p"])
        if distance < shortest:
            shortest = distance
            nearest = station
    if not nearest.is_empty():
        return nearest
    # Fora do alcance de portas e NPCs, ambos os carros continuam acessiveis
    # pelas mesmas areas generosas (incluindo o controle por toque).
    for car_rect in DISTRICT_LAYOUT.HEARSE_AREAS:
        if car_rect.grow(75).has_point(player.global_position):
            return {"id":"carro","name":"Carro funerario - Translado do Alem","p":car_rect.get_center()}
    return {}

func _notify(message: String, duration: float = 1.5) -> void:
    location_hint = message
    location_hint_seconds = maxf(0.2,duration)

func _open_journal() -> void:
    if dialogue_open or rooms.changing:
        return
    var mission: String = rooms.objective() if stage >= 12 else OBJECTIVES[stage]
    var work_note: String = ""
    var order: Dictionary = burial_queue.pending()
    if not order.is_empty():
        work_note = "\n\nORDEM DE SEPULTAMENTO: %s\nServico liberado! Procure Seu Osvaldo no cemitério e interaja para preparar o jazigo. O trabalho pode ser retomado depois." % str(order.get("plot", "B-13"))
    elif burial_queue.is_done(BURIAL_QUEUE.INITIAL_ORDER):
        work_note = "\n\nJazigo B-13: servico concluido e registrado."
    _show("DIARIO DE SANTA MORTALHA", "Objetivo atual:\n" + mission + "\n\nAtendimentos concluidos: %d/20." % rooms.case_index + work_note + "\n\nConsulte os atendentes e o Arquivo Legal. Os valores sao ficticios.", [{"text":"Galeria de retratos (teste)","action":"portrait_gallery"},{"text":"Fechar diario","action":"close"}])
func _portrait_gallery() -> void:
    _show("GALERIA DE RETRATOS","Teste visual das expressoes. O progresso e o dinheiro nao serao alterados.",[
        {"text":"Baltazar — contador fantasma","action":"portrait_select_baltazar"},
        {"text":"Seu Osvaldo — coveiro","action":"portrait_select_osvaldo"},
        {"text":"Madame Amalia — funeraria","action":"portrait_select_amalia"},
        {"text":"Voltar ao jogo","action":"close"}
    ])

func _portrait_preview(identity: String, expression: String) -> void:
    var person: Dictionary = DIALOGUE_CHARACTERS.by_id(identity)
    if person.is_empty() or not PORTRAIT_EXPRESSIONS.has_actor(identity):
        _portrait_gallery()
        return
    var options: Array = []
    for emotion in PORTRAIT_EXPRESSIONS.EMOTIONS:
        options.append({"text":str(emotion).capitalize(),"action":"portrait_emotion_"+identity+"_"+str(emotion)})
    options.append({"text":"Voltar a galeria","action":"portrait_gallery"})
    _show_character(str(person["name"]),"PREVIA DOS RETRATOS\n\nConfira a expressao atual no canto esquerdo. Esta galeria nao altera as missoes.",str(person["profile"]),options,expression)

func _try_interact() -> void:
    if dialogue_open or rooms.changing or (is_instance_valid(burial_field) and burial_field.elapsed>=0.0):
        return
    var station := _near_station()
    if not station.is_empty():
        if rooms.inside():
            rooms.interact(str(station["id"]))
        else:
            _interact(str(station["id"]))

func _interact(id: String) -> void:
    if rooms.offer_entry(id):
        return
    match id:
        "field_dig":
            burial_field.strike()
        "cemetery_cat":
            if is_instance_valid(cemetery_cat):
                cemetery_cat.call("meow")
            _show("Gato do Cemiterio", "Miau!", [{"text":"Fazer carinho","action":"cat_pet"}, {"text":"Deixar descansar","action":"close"}])
        "osvaldo":
            if burial_queue.has_pending():
                _start_osvaldo_work()
            elif is_b13_buried():
                _show("Seu Osvaldo","Sem ordens autorizadas agora. O escritorio manda os proximos clientes. Ate o alem tem expediente!",[{"text":"Voltar","action":"close"}])
            elif stage == 0:
                _show("Seu Osvaldo, o coveiro", "Opa, chefe! Antes de um sepultamento, precisamos conferir documentos, disponibilidade de jazigo e registros. O balcao fica no escritorio. E nada de atalhos!", [{"text": "Entendido!", "action": "talk"}])
            else:
                _show("Seu Osvaldo", "O cemiterio nao se administra sozinho! Olhe o estado dos caminhos, os registros e o treinamento da equipe. E nao pise nas flores!", [{"text": "Ate mais", "action": "close"}])
        "office":
            if stage == 1:
                _show("Atendimento: documentacao", "Uma familia chegou com apenas a Declaracao de Obito. Qual deve ser a conduta do administrador?", [{"text": "Conferir os requisitos e orientar a familia", "action": "docs_ok"}, {"text": "Ignorar o problema e prosseguir", "action": "docs_bad"}, {"text": "Voltar", "action": "close"}])
            elif stage == 6:
                _show("Cartorio e Certidao de Obito", "Dra. Penelope informou que o hospital forneceu a Declaracao de Obito. Como conduzir o processo?", [{"text":"Orientar o registro civil e conferir certidao", "action":"cartorio_certo"}, {"text":"Tratar a DO como certidao pronta", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            elif stage == 11:
                _show("Orcamento transparente", "Exemplo ficticio: servico R$ 1.200, custos diretos R$ 800. O que entregar a familia?", [{"text":"Detalhar custos e obter concordancia", "action":"orcamento_certo"}, {"text":"Cobrar extras sem explicar", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            elif stage == 3:
                _show("Registro financeiro", "Documentos conferidos e jazigo reservado. Valores ficticios: receita R$ 720, custo operacional direto R$ 250. Registrar o atendimento?", [{"text": "Registrar e emitir comprovante", "action": "register"}, {"text": "Voltar", "action": "close"}])
            else:
                _show("Escritorio administrativo", "Saldo em caixa: R$ %d. A gestao inclui pagamentos, registros, contratos, custos e atendimento etico." % money, [{"text": "Ver aviso educativo", "action": "learn"}, {"text": "Fechar", "action": "close"}])
        "plot":
            if stage == 2 and not reserved_plot:
                _show("Quadra B, jazigo B-13", "O cadastro ficticio indica que este jazigo esta disponivel. Em casos reais, conferem-se tambem titularidade, direitos de uso e regras locais.", [{"text": "Reservar jazigo", "action": "reserve"}, {"text": "Voltar", "action": "close"}])
            else:
                var plot_status := "SEPULTAMENTO CONCLUIDO" if is_b13_buried() else ("RESERVADO" if reserved_plot else "LIVRE")
                _show("Quadra B, jazigo B-13", "Estado: %s. A rastreabilidade de cada sepultura e essencial." % plot_status, [{"text": "Fechar", "action": "close"}])
        "maintenance":
            if stage == 4:
                _show("Manutencao preventiva", "Revisar caminhos, vegetacao e drenagem reduz riscos. Investimento didatico: R$ 160. Deseja autorizar?", [{"text": "Autorizar R$ 160", "action": "maintain"}, {"text": "Deixar para depois", "action": "close"}])
            else:
                _show("Area de manutencao", "Visitas e trabalho seguros exigem caminhos, drenagem, sinalizacao e vegetacao bem cuidados.", [{"text": "Fechar", "action": "close"}])
        "hospital":
            if stage == 5:
                _show("Dra. Penelope Alvorada", "A familia precisa entender o que o hospital pode emitir. Eu sou medica, nao cartorio, apesar da minha pilha de papeis parecer um!", [{"text":"Conferir a Declaracao de Obito", "action":"hospital_certo"}, {"text":"Pedir ao hospital que invente certidao", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            else:
                _show("Hospital Santa Ultima Hora", "O hospital presta assistencia em saude. Em contexto apropriado, a Declaracao de Obito e emitida por medico; a certidao e providenciada no Registro Civil.", [{"text":"Ler referencia", "action":"legal_registro"}, {"text":"Voltar", "action":"close"}])
        "garagem":
            if stage == 7:
                _show("Arquimedes Ossario", "A limousine preta esta pronta. Mas antes: registro de rota, condicoes do veiculo, documentacao e normas de transporte. Fantasma sem carteira nao dirige!", [{"text":"Inspecionar frota (R$ 80)", "action":"garagem_certo"}, {"text":"Ignorar os requisitos", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            else:
                _show("Garagem da Ultima Viagem", "Frota com carros funerarios, limpeza, manutencao e rotas. A normativa de transporte depende da jurisdicao.", [{"text":"Treinar direção", "action":"drive_training"}, {"text":"Ler norma de translado", "action":"legal_transporte"}, {"text":"Voltar", "action":"close"}])
        "carro":
            _show("Seu Osvaldo", "Ô chefe! Este é o carro da Última Viagem. Use W ou seta para cima para acelerar, A/D para virar e S ou espaço para frear. Desvie dos carros e chegue ao destino. E não transforme translado em recrutamento!", [{"text":"Treinar sem custos", "action":"drive_training"}, {"text":"Aceitar translado remunerado", "action":"drive_job"}, {"text":"Sobre o translado", "action":"legal_transporte"}, {"text":"Voltar", "action":"close"}])
        "preparo":
            if stage == 8:
                _show("Dona Clotilde Eternelia", "Aqui nao existe formula milagrosa! Conservacao e tanatopraxia exigem condicoes sanitarias, pessoal competente, licencas aplicaveis e residuos sob controle.", [{"text":"Conferir estrutura e equipe (R$ 90)", "action":"preparo_certo"}, {"text":"Trabalhar sem controle sanitario", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            else:
                _show("Sala de Conservacao", "Area tecnica ficticia e sem procedimentos graficos. Verifique sempre vigilancia sanitaria e profissionais habilitados.", [{"text":"Ler a referencia", "action":"legal_preparo"}, {"text":"Voltar", "action":"close"}])
        "crematorio":
            if stage == 9:
                _show("Seu Cinerio Brasa", "Cremar nao e simplesmente apertar um botao! A Lei 6.015/1973 estabelece requisitos, inclusive vontade e atestado medico especifico.", [{"text":"Validar condicoes legais", "action":"crematorio_certo"}, {"text":"Crema sem verificacao", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            else:
                _show("Crematorio Cinzas & Cia", "Nosso fornalha esta desligada enquanto a documentacao nao esta em ordem. Uma longa fila de papeis espera por voce.", [{"text":"Estudar lei de cremacao", "action":"legal_cremacao"}, {"text":"Voltar", "action":"close"}])
        "fiscalizacao":
            if stage == 10:
                _show("Marcela Meia-Noite, Fiscal", "Licenciamento ambiental do cemiterio e gerenciamento de residuos nao sao aderecos goticos. Vamos conferir o plano e as exigencias!", [{"text":"Regularizar plano (R$ 140)", "action":"ambiente_certo"}, {"text":"Ignorar o licenciamento", "action":"distrito_erro"}, {"text":"Voltar", "action":"close"}])
            else:
                _show("Posto de Fiscalizacao", "O cemiterio tem impactos ambientais; setores tecnicos exigem gerenciamento de residuos. Regras locais variam.", [{"text":"Consultar normas", "action":"legal_ambiente"}, {"text":"Voltar", "action":"close"}])
        "biblioteca":
            _show("Arquivo Legal de Santa Mortalha", "Mais assustadoras que os nossos fantasmas: as pilhas de regulamentacoes. Escolha a estante!", [{"text":"Documentos e cremacao", "action":"arquivo_p1"}, {"text":"Residuos e ambiente", "action":"arquivo_p2"}, {"text":"Frota e conservacao", "action":"arquivo_p3"}])
        "ghost":
            _show("Baltazar, o contador fantasma", "Caixa positivo NAO significa lucro, meu jovem! Ainda existem salarios, materiais, impostos, manutencao e reservas. Morri esperando uma nota fiscal!", [{"text": "Cuidarei das contas", "action": "close"}])

func _on_choice(action: String) -> void:
    if action == "field_begin":
        if not WAKE.done(burial_queue.pending()):
            _close()
            _notify("Conclua o velorio na capela primeiro.",3.0)
            return
        _close()
        burial_field.begin()
        _notify("Siga ao jazigo marcado. E ou INTERAGIR para cavar.",4.0)
        return
    if action == "field_next":
        _close()
        return
    if action == "field_finish":
        var order: Dictionary = burial_queue.pending()
        if not order.is_empty() and WAKE.done(order) and burial_field.count_for(str(order["plot"]))>=6 and burial_field.near(player.global_position).get("id","")=="field_dig":
            _close()
            _burial_finished(true,100,str(order["id"]))
            burial_field.active = false
            burial_field.queue_redraw()
        return
    if action == "portrait_gallery":
        _portrait_gallery()
        return
    if action.begins_with("portrait_select_"):
        _portrait_preview(action.trim_prefix("portrait_select_"),"alegre")
        return
    if action.begins_with("portrait_emotion_"):
        var info: String = action.trim_prefix("portrait_emotion_")
        var separator: int = info.find("_")
        if separator > 0:
            _portrait_preview(info.substr(0,separator),info.substr(separator+1))
        return
    if action == "cat_pet":
        if is_instance_valid(cemetery_cat):
            cemetery_cat.call("pet")
        _close()
        _notify("Prrrr... Miau! O gatinho adorou o carinho.", 2.7)
        return
    if action in ["drive_training","drive_job"]:
        driving_job = action == "drive_job"
        _start_driving()
        return
    if rooms.handle_choice(action):
        _refresh_ui()
        return
    if action.begins_with("legal_"):
        var key: String = action.trim_prefix("legal_")
        var item: Dictionary = LEGAL.ITEMS.get(key,{})
        _show(str(item.get("title","Arquivo Legal")), LEGAL.info(key), [{"text":"Fechar", "action":"close"}])
        return
    if action == "menu_return":
        _save_game()
        get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
        return
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
            $PropsLayer.queue_redraw()
            _show("Reserva registrada", "Jazigo B-13 reservado. Agora retorne ao escritorio e registre o atendimento.", [{"text": "Continuar", "action": "close"}])
        "register":
            if not reserved_plot:
                _show("Cadastro incompleto", "Reserve o jazigo antes de registrar o atendimento.", [{"text": "Fechar", "action": "close"}])
                return
            money += 720 - 250
            reputation = mini(100, reputation + 10)
            stage = 4
            burial_queue.ensure_initial_order(stage, reserved_plot, day)
            _show("Registro concluido", "Receita: +R$ 720. Custo direto: -R$ 250. Margem didatica: R$ 470 antes das despesas fixas.\n\nA ordem de sepultamento B-13 foi agendada: procure Seu Osvaldo no cemiterio para preparar o jazigo.", [{"text": "Continuar expediente", "action": "close"}])
        "maintain":
            if money < 160:
                _show("Saldo insuficiente", "Planeje o caixa antes de gastar.", [{"text": "Fechar", "action": "close"}])
                return
            money -= 160
            compliance = mini(100, compliance + 5)
            reputation = mini(100, reputation + 5)
            stage = 5
            _show("Parabens, administrador!", "Voce concluiu a primeira missao! Conferiu documentos, reservou um jazigo, registrou receitas e custos e autorizou manutencao. Santa Mortalha ainda tem muito trabalho!", [{"text": "Explorar", "action": "close"}])
        "arquivo_p1":
            _show("Estante do Cartorio", "As duas perguntas que a familia mais precisa compreender:", [{"text":"Declaracao e certidao", "action":"legal_registro"}, {"text":"Requisitos de cremacao", "action":"legal_cremacao"}, {"text":"Voltar", "action":"close"}])
        "arquivo_p2":
            _show("Estante da Vigilancia", "Saude e ambiente exigem cuidados muito alem de uma boa lapide.", [{"text":"Residuos e biosseguranca", "action":"legal_residuos"}, {"text":"Licenciamento ambiental", "action":"legal_ambiente"}, {"text":"Voltar", "action":"close"}])
        "arquivo_p3":
            _show("Estante de Operacoes", "Conferir as regras antes de acionar a frota ou a sala tecnica.", [{"text":"Transporte e translado", "action":"legal_transporte"}, {"text":"Conservacao e preparo", "action":"legal_preparo"}, {"text":"Voltar", "action":"close"}])
        "distrito_erro":
            compliance = maxi(0, compliance - 8)
            reputation = maxi(0, reputation - 3)
            _show("Atalho reprovado!", "A familia precisa de informacao e seguranca, nao improviso. Conformidade -8 e reputacao -3. Confira a fonte e tente outra vez.", [{"text":"Entendi", "action":"close"}])
        "hospital_certo":
            if stage != 5:
                return
            stage = 6
            compliance = mini(100, compliance+4)
            _show("Licao: papel do hospital", "A Declaracao de Obito e documento do ambito da saude, enquanto a Certidao de Obito e expedida pelo registro civil. Fonte: Ministerio da Saude, SIM e Lei 6.015/1973.", [{"text":"Voltar ao escritorio", "action":"close"}])
        "cartorio_certo":
            if stage != 6:
                return
            stage = 7
            compliance = mini(100, compliance+4)
            _show("Licao: registro civil", "Boa escolha! A Lei 6.015/1973, art. 77, trata da documentacao para sepultamento, com as excecoes previstas em lei. Agora a frota precisa de cuidados.", [{"text":"Visitar garagem", "action":"close"}])
        "garagem_certo":
            if stage != 7:
                return
            if money < 80:
                _show("Caixa insuficiente", "Reserve recursos antes de autorizar a revisao da frota.", [{"text":"Voltar", "action":"close"}])
                return
            money -= 80
            stage = 8
            reputation = mini(100,reputation+3)
            _show("Frota revisada", "Custo ficticio: R$ 80. Confira autorizacoes e regras locais. A RDC 33/2011 aborda controle sanitario em portos, aeroportos e fronteiras em hipoteses especificas.", [{"text":"Ir para conservacao", "action":"close"}])
        "preparo_certo":
            if stage != 8:
                return
            if money < 90:
                _show("Caixa insuficiente", "A sala tecnica precisa de orcamento para adequacoes.", [{"text":"Voltar", "action":"close"}])
                return
            money -= 90
            stage = 9
            compliance = mini(100,compliance+5)
            _show("Equipe habilitada", "Simulacao sem tecnicas clinicas: confira licencas, competencia profissional, biosseguranca e PGRSS, conforme a atividade e a jurisdicao.", [{"text":"Ir ao crematorio", "action":"close"}])
        "crematorio_certo":
            if stage != 9:
                return
            stage = 10
            compliance = mini(100,compliance+5)
            _show("Licao: requisitos da cremacao", "Art. 77, paragrafo 2: vontade manifestada ou interesse de saude publica, assinaturas medicas exigidas e, em morte violenta, autorizacao judicial. Nenhuma cremacao foi executada nesta missao.", [{"text":"Conferir ambiente", "action":"close"}])
        "ambiente_certo":
            if stage != 10:
                return
            if money < 140:
                _show("Caixa insuficiente", "O plano ambiental exige recursos e planejamento financeiro.", [{"text":"Voltar", "action":"close"}])
                return
            money -= 140
            compliance = mini(100,compliance+6)
            stage = 11
            _show("Gestao ambiental", "Despesa ficticia R$ 140. CONAMA 335/2003 aborda licenciamento ambiental de cemiterios; RDC 222/2018 aborda residuos dos servicos incluidos em seu alcance.", [{"text":"Preparar orcamento", "action":"close"}])
        "orcamento_certo":
            if stage != 11:
                return
            stage = 12
            money += 400
            reputation = mini(100,reputation+10)
            compliance = mini(100,compliance+4)
            _show("Distrito em funcionamento!", "Orcamento ficticio detalhado: receita R$ 1.200 e custo direto R$ 800, margem R$ 400 antes dos custos fixos. A familia aceitou o servico sem adicionais impostos. Missao concluida!", [{"text":"Continuar explorando", "action":"close"}])
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
    cfg.set_value("save", "driving_completed", driving_completed)
    cfg.set_value("save", "stage", stage)
    cfg.set_value("save", "day", day)
    cfg.set_value("save", "money", money)
    cfg.set_value("save", "reputation", reputation)
    cfg.set_value("save", "compliance", compliance)
    cfg.set_value("save", "reserved_plot", reserved_plot)
    cfg.set_value("save", "position", player.global_position)
    cfg.set_value("save", "clock", clock_minutes)
    cfg.set_value("save", "map_version", MAP_SAVE_VERSION)
    rooms.save_state(cfg)
    burial_queue.save_state(cfg)
    cfg.save("user://save.cfg")

func _load_game() -> void:
    var cfg := ConfigFile.new()
    if cfg.load("user://save.cfg") != OK:
        return
    driving_completed = bool(cfg.get_value("save", "driving_completed", false))
    stage = clampi(int(cfg.get_value("save", "stage", 0)), 0, 12)
    day = maxi(1, int(cfg.get_value("save", "day", 1)))
    money = int(cfg.get_value("save", "money", 3500))
    reputation = clampi(int(cfg.get_value("save", "reputation", 55)), 0, 100)
    compliance = clampi(int(cfg.get_value("save", "compliance", 65)), 0, 100)
    reserved_plot = bool(cfg.get_value("save", "reserved_plot", false))
    clock_minutes = float(cfg.get_value("save", "clock", 480.0))
    rooms.load_state(cfg)
    burial_queue.load_state(cfg)
    var saved_map_version: int = int(cfg.get_value("save", "map_version", 0))
    if saved_map_version != MAP_SAVE_VERSION:
        # Preserva a missao, os indicadores e o caixa, mas nao uma posicao
        # que poderia estar presa dentro de um novo edificio.
        player.global_position = SPAWN
        rescue_notice = "Mapa reorganizado! Posicao restaurada; seu progresso foi mantido."
    else:
        player.global_position = cfg.get_value("save", "position", SPAWN)
    _save_game()

func _ensure_valid_player_position() -> void:
    if not is_walkable(player.global_position):
        player.global_position = rooms.safe_spawn()
        rescue_notice = "Personagem reposicionado em uma area segura."
        _save_game()

func _open_pause_menu() -> void:
    if dialogue_open or rooms.changing:
        return
    var menu_options: Array = [{"text":"Retomar expediente","action":"close"}]
    if rooms.inside():
        menu_options.append({"text":"Sair do predio","action":"leave_room"})
    menu_options.append({"text":"Salvar e ir ao menu inicial","action":"menu_return"})
    _show("PAUSAR EXPEDIENTE","Os mortos podem esperar, mas Baltazar continua de olho nas contas.",menu_options)

func _rescue_player() -> void:
    # Resgate seguro: nao altera missao, dinheiro ou reputacao.
    if rooms.changing:
        return
    if dialogue_open:
        _close()
    player.virtual_direction = Vector2.ZERO
    player.velocity = Vector2.ZERO
    player.global_position = rooms.safe_spawn()
    rescue_notice = "Posicao restaurada. Continue explorando!"
    _save_game()
    _refresh_ui()

func _close() -> void:
    dialogue_open = false
    dialog_panel.visible = false

func _show(heading: String, body: String, choices: Array) -> void:
    dialogue_open = true
    dialog_panel.visible = true
    dialog_title.text = heading
    dialog_body.text = body
    _apply_dialogue_identity(DIALOGUE_CHARACTERS.resolve(heading),heading,"",PORTRAIT_EXPRESSIONS.infer(body))
    var body_scroll := dialog_panel.get_node("BodyScroll") as ScrollContainer
    var choice_scroll := dialog_panel.get_node("ChoicesScroll") as ScrollContainer
    body_scroll.scroll_vertical = 0
    choice_scroll.scroll_vertical = 0
    for child in options_box.get_children():
        options_box.remove_child(child)
        child.queue_free()
    var character: Dictionary = DIALOGUE_CHARACTERS.resolve(heading)
    var accent := Color(str(character.get("accent","#d8b882")))
    var illustrated: bool = DIALOGUE_ART.supports(str(character.get("id","")))
    for choice in choices:
        var btn := Button.new()
        btn.text = "%d · %s" % [options_box.get_child_count()+1,str(choice["text"])]
        btn.custom_minimum_size = Vector2(0, 51)
        btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        btn.add_theme_font_size_override("font_size", 17)
        btn.add_theme_color_override("font_color",Color("#f8e9d5"))
        btn.add_theme_color_override("font_hover_color",Color("#ffffff"))
        var normal := StyleBoxFlat.new()
        normal.bg_color = Color("#35283c")
        normal.border_color = accent.darkened(0.37)
        normal.set_border_width_all(2)
        normal.set_corner_radius_all(5)
        btn.add_theme_stylebox_override("normal",normal)
        var selected := normal.duplicate() as StyleBoxFlat
        selected.bg_color = accent.darkened(0.70)
        selected.border_color = accent
        btn.add_theme_stylebox_override("hover",selected)
        btn.add_theme_stylebox_override("pressed",selected)
        btn.add_theme_stylebox_override("focus",selected)
        if illustrated:
            # Texto permanece nativo: evita corte, permite teclado e toque.
            btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
            btn.add_theme_stylebox_override("normal",DIALOGUE_ART.answer_style())
            btn.add_theme_stylebox_override("hover",DIALOGUE_ART.answer_style(Color("#d7c8de")))
            btn.add_theme_stylebox_override("pressed",DIALOGUE_ART.answer_style(Color("#bda7d1")))
            btn.add_theme_stylebox_override("focus",DIALOGUE_ART.answer_style(Color("#eee0b8")))
        btn.pressed.connect(_on_choice.bind(str(choice["action"])))
        options_box.add_child(btn)

func _apply_dialogue_identity(actor: Dictionary, speaker: String, mood: String = "", expression: String = "") -> void:
    var has_actor: bool = not actor.is_empty()
    var identity: String = str(actor.get("id",""))
    var illustrated: bool = DIALOGUE_ART.supports(identity)
    dialog_frame.call("set_identity",actor)
    dialog_portrait.visible = has_actor
    dialog_role.visible = has_actor
    var new_frame: bool = DIALOGUE_ART.has_integrated_nameplate(identity)
    dialog_nameplate_art.visible = illustrated and not new_frame
    dialog_portrait_frame_art.visible = illustrated
    dialog_portrait_nameplate_text.visible = new_frame
    if new_frame:
        dialog_portrait_nameplate_text.text = str(actor.get("name",speaker))
    var speech_scroll := dialog_panel.get_node("BodyScroll") as ScrollContainer
    var choices_scroll := dialog_panel.get_node("ChoicesScroll") as ScrollContainer
    if has_actor:
        dialog_portrait.call("set_actor",speaker,mood,expression)
        dialog_title.add_theme_font_size_override("font_size",23)
        dialog_title.add_theme_color_override("font_color",Color(str(actor["accent"])).lightened(0.16))
        dialog_role.text = str(actor["role"]).to_upper()
        dialog_role.add_theme_color_override("font_color",Color(str(actor["accent"])))
    else:
        dialog_title.add_theme_font_size_override("font_size",23)
        dialog_title.add_theme_color_override("font_color",Color("#dfbd87"))
    if illustrated:
        dialog_portrait_frame_art.texture = DIALOGUE_ART.portrait(identity)
        dialog_nameplate_art.texture = DIALOGUE_ART.nameplate(identity)
        # Baltazar e Osvaldo ja possuem molduras no proprio retrato.
        # A arte antiga fica oculta apenas nesses dois casos.
        var integrated_frame: bool = bool(dialog_portrait.get("embedded_frame"))
        dialog_portrait_frame_art.visible = not integrated_frame
        if integrated_frame:
            dialog_portrait.position = Vector2(34,78)
            dialog_portrait.size = Vector2(204,204)
        else:
            dialog_portrait.position = Vector2(79,108)
            dialog_portrait.size = Vector2(117,119)
        dialog_title.position = Vector2(344,25)
        dialog_title.size = Vector2(236,32)
        dialog_title.add_theme_font_size_override("font_size",19)
        dialog_title.add_theme_color_override("font_color",Color("#f8e8ca"))
        dialog_role.position = Vector2(611,51)
        dialog_role.size = Vector2(213,23)
        speech_scroll.position = Vector2(295,105)
        speech_scroll.size = Vector2(535,108)
        dialog_body.custom_minimum_size.x = 501.0
        choices_scroll.position = Vector2(294,234)
        choices_scroll.size = Vector2(561,123)
        options_box.custom_minimum_size.x = 531.0
    elif has_actor:
        dialog_portrait.position = Vector2(34,85)
        dialog_portrait.size = Vector2(118,132)
        dialog_title.position = Vector2(194,21)
        dialog_title.size = Vector2(502,35)
        dialog_role.position = Vector2(694,25)
        dialog_role.size = Vector2(156,27)
        speech_scroll.position = Vector2(191,92)
        speech_scroll.size = Vector2(667,125)
        dialog_body.custom_minimum_size.x = 625.0
        choices_scroll.position = Vector2(33,248)
        choices_scroll.size = Vector2(825,140)
        options_box.custom_minimum_size.x = 790.0
    else:
        dialog_title.position = Vector2(48,21)
        dialog_title.size = Vector2(755,35)
        speech_scroll.position = Vector2(33,92)
        speech_scroll.size = Vector2(825,125)
        dialog_body.custom_minimum_size.x = 782.0
        choices_scroll.position = Vector2(33,248)
        choices_scroll.size = Vector2(825,140)
        options_box.custom_minimum_size.x = 790.0
    speech_scroll.scroll_vertical = 0
    choices_scroll.scroll_vertical = 0

func _show_character(speaker: String, words: String, mood: String, choices: Array, expression: String = "") -> void:
    _show(speaker, words, choices)
    var actor: Dictionary = DIALOGUE_CHARACTERS.resolve(speaker)
    var chosen: String = expression if not expression.is_empty() else PORTRAIT_EXPRESSIONS.infer(words)
    _apply_dialogue_identity(actor,speaker,mood,chosen)

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

    # HUD compacto: duas linhas; sem faixa horizontal gigante.
    var bar := Panel.new()
    bar.position = Vector2(12, 10)
    bar.size = Vector2(650, 74)
    bar.add_theme_stylebox_override("panel", _style(NIGHT, GOLD))
    bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(bar)
    status_label = Label.new()
    status_label.position = Vector2(13, 7)
    status_label.size = Vector2(625, 60)
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", PAPER)
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bar.add_child(status_label)

    var mission := Panel.new()
    mission.anchor_left = 1.0
    mission.anchor_right = 1.0
    mission.offset_left = -453.0
    mission.offset_right = -13.0
    mission.offset_top = 10.0
    mission.offset_bottom = 104.0
    mission.add_theme_stylebox_override("panel", _style(Color("#302238"), Color("#917259")))
    mission.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(mission)
    objective_label = Label.new()
    objective_label.position = Vector2(14, 7)
    objective_label.size = Vector2(412, 75)
    objective_label.add_theme_font_size_override("font_size", 16)
    objective_label.add_theme_color_override("font_color", PAPER)
    objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mission.add_child(objective_label)

    var tip := Panel.new()
    tip.anchor_left = 0.5
    tip.anchor_right = 0.5
    tip.anchor_top = 1.0
    tip.anchor_bottom = 1.0
    tip.offset_left = -331.0
    tip.offset_right = 331.0
    tip.offset_top = -48.0
    tip.offset_bottom = -10.0
    tip.add_theme_stylebox_override("panel", _style(Color("#302238bb"), Color("#b79a6e")))
    tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(tip)
    prompt_label = Label.new()
    prompt_label.position = Vector2(12, 8)
    prompt_label.size = Vector2(640, 27)
    prompt_label.add_theme_font_size_override("font_size", 16)
    prompt_label.add_theme_color_override("font_color", PAPER)
    prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tip.add_child(prompt_label)

    # Caixa ornamental como a de Jack: retrato, placa do nome, fala e escolhas.
    # O painel fica na base da tela; a parte superior do mundo continua visivel.
    dialog_panel = Panel.new()
    dialog_panel.name = "DialoguePanel"
    dialog_panel.anchor_left = 0.5
    dialog_panel.anchor_right = 0.5
    dialog_panel.anchor_top = 1.0
    dialog_panel.anchor_bottom = 1.0
    dialog_panel.offset_left = -447.0
    dialog_panel.offset_right = 447.0
    dialog_panel.offset_top = -425.0
    dialog_panel.offset_bottom = -15.0
    dialog_panel.visible = false
    dialog_panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
    root.add_child(dialog_panel)

    dialog_frame = DIALOGUE_FRAME.new()
    dialog_frame.name = "DialogueFrame"
    dialog_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dialog_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_panel.add_child(dialog_frame)

    dialog_title = Label.new()
    dialog_title.name = "CharacterName"
    dialog_title.position = Vector2(194,21)
    dialog_title.size = Vector2(502,35)
    dialog_title.add_theme_font_size_override("font_size",23)
    dialog_title.add_theme_color_override("font_color",Color("#e1c392"))
    dialog_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_panel.add_child(dialog_title)

    dialog_role = Label.new()
    dialog_role.name = "CharacterRole"
    dialog_role.position = Vector2(694,25)
    dialog_role.size = Vector2(156,27)
    dialog_role.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    dialog_role.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    dialog_role.add_theme_font_size_override("font_size",12)
    dialog_role.add_theme_color_override("font_color",Color("#d6b98a"))
    dialog_role.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_panel.add_child(dialog_role)

    var body_scroll := ScrollContainer.new()
    body_scroll.name = "BodyScroll"
    body_scroll.position = Vector2(191,92)
    body_scroll.size = Vector2(667,125)
    body_scroll.follow_focus = true
    dialog_panel.add_child(body_scroll)
    dialog_body = Label.new()
    dialog_body.name = "DialogText"
    dialog_body.custom_minimum_size = Vector2(625,0)
    dialog_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    dialog_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialog_body.add_theme_font_size_override("font_size",18)
    dialog_body.add_theme_color_override("font_color",Color("#f3e4ce"))
    body_scroll.add_child(dialog_body)

    dialog_portrait = CLIENT_PORTRAIT.new()
    dialog_portrait.name = "ClientPortrait"
    dialog_portrait.position = Vector2(34,85)
    dialog_portrait.size = Vector2(118,132)
    dialog_portrait.visible = false
    dialog_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_panel.add_child(dialog_portrait)
    dialog_portrait.z_index = 1

    # Ornamentos PNG acima do busto, sem capturar mouse ou toque.
    dialog_portrait_frame_art = TextureRect.new()
    dialog_portrait_frame_art.name = "PortraitFrameArt"
    dialog_portrait_frame_art.position = Vector2(22,60)
    dialog_portrait_frame_art.size = Vector2(224,235)
    dialog_portrait_frame_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    dialog_portrait_frame_art.stretch_mode = TextureRect.STRETCH_SCALE
    dialog_portrait_frame_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    dialog_portrait_frame_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_portrait_frame_art.z_index = 2
    dialog_portrait_frame_art.visible = false
    dialog_panel.add_child(dialog_portrait_frame_art)

    dialog_nameplate_art = TextureRect.new()
    dialog_nameplate_art.name = "NameplateArt"
    dialog_nameplate_art.position = Vector2(298,0)
    dialog_nameplate_art.size = Vector2(272,100)
    dialog_nameplate_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    dialog_nameplate_art.stretch_mode = TextureRect.STRETCH_SCALE
    dialog_nameplate_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    dialog_nameplate_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_nameplate_art.z_index = 2
    dialog_nameplate_art.visible = false
    dialog_panel.add_child(dialog_nameplate_art)

    # Lote 2: nomes aplicados por codigo, sobre a placa vazia do proprio PNG.
    # Sem desenhar texto no arquivo de arte e sem bloquear mouse/toque.
    dialog_portrait_nameplate_text = Label.new()
    dialog_portrait_nameplate_text.name = "PortraitNameplateText"
    dialog_portrait_nameplate_text.position = Vector2(48, 245)
    dialog_portrait_nameplate_text.size = Vector2(171, 27)
    dialog_portrait_nameplate_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    dialog_portrait_nameplate_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    dialog_portrait_nameplate_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    dialog_portrait_nameplate_text.clip_text = true
    dialog_portrait_nameplate_text.add_theme_font_size_override("font_size",12)
    dialog_portrait_nameplate_text.add_theme_color_override("font_color",Color("#34212d"))
    dialog_portrait_nameplate_text.add_theme_color_override("font_shadow_color",Color("#f8e7cb"))
    dialog_portrait_nameplate_text.add_theme_constant_override("shadow_offset_x",1)
    dialog_portrait_nameplate_text.add_theme_constant_override("shadow_offset_y",1)
    dialog_portrait_nameplate_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
    dialog_portrait_nameplate_text.z_index = 3
    dialog_portrait_nameplate_text.visible = false
    dialog_panel.add_child(dialog_portrait_nameplate_text)

    dialog_title.z_index = 3
    dialog_role.z_index = 3
    body_scroll.z_index = 3

    var choices_scroll := ScrollContainer.new()
    choices_scroll.name = "ChoicesScroll"
    choices_scroll.position = Vector2(33,248)
    choices_scroll.size = Vector2(825,140)
    choices_scroll.follow_focus = true
    dialog_panel.add_child(choices_scroll)
    choices_scroll.z_index = 3
    options_box = VBoxContainer.new()
    options_box.name = "OptionsBox"
    options_box.custom_minimum_size = Vector2(790,0)
    options_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    options_box.add_theme_constant_override("separation",5)
    choices_scroll.add_child(options_box)

    # Botao de resgate acessivel mesmo se o teclado perder foco.
    var rescue := Button.new()
    rescue.text = "R  Resgatar personagem"
    rescue.anchor_left = 1.0
    rescue.anchor_right = 1.0
    rescue.anchor_top = 1.0
    rescue.anchor_bottom = 1.0
    rescue.offset_left = -211.0
    rescue.offset_right = -14.0
    rescue.offset_top = -49.0
    rescue.offset_bottom = -9.0
    rescue.visible = not (OS.has_feature("mobile") or DisplayServer.is_touchscreen_available())
    rescue.pressed.connect(_rescue_player)
    root.add_child(rescue)
    var menu_button := Button.new()
    menu_button.text = "MENU"
    menu_button.anchor_left = 1.0
    menu_button.anchor_right = 1.0
    menu_button.offset_left = -143.0
    menu_button.offset_right = -13.0
    menu_button.offset_top = 108.0
    menu_button.offset_bottom = 148.0
    menu_button.visible = not (OS.has_feature("mobile") or DisplayServer.is_touchscreen_available())
    menu_button.pressed.connect(_open_pause_menu)
    root.add_child(menu_button)
    var touch_layer := CanvasLayer.new()
    touch_layer.name = "MobileControlsLayer"
    touch_layer.layer = 8
    add_child(touch_layer)
    mobile_hud = MOBILE_HUD.new()
    mobile_hud.name = "MobileHud"
    touch_layer.add_child(mobile_hud)
    mobile_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mobile_hud.connect("direction_changed",func(value: Vector2) -> void: player.virtual_direction = value)
    mobile_hud.connect("interact_requested",_try_interact)
    mobile_hud.connect("menu_requested",_open_pause_menu)
    mobile_hud.connect("journal_requested",_open_journal)
    mobile_hud.call("set_playable",not dialogue_open and not rooms.changing)

func _refresh_ui() -> void:
    if status_label == null:
        return
    var minutes: int = int(clock_minutes)
    status_label.text = "SANTA MORTALHA  |  Dia %d  |  %02d:%02d\nCaixa R$ %d  ·  Reputacao %d/100  ·  Conformidade %d/100" % [day, int(minutes / 60.0), minutes % 60, money, reputation, compliance]
    objective_label.text = "MISSÃO DO EXPEDIENTE\n" + (rooms.objective() if stage >= 12 else OBJECTIVES[stage])
    var wake_order: Dictionary = burial_queue.pending()
    if not wake_order.is_empty() and not WAKE.done(wake_order):
        objective_label.text = "O ULTIMO ADEUS | "+str(wake_order["customer"])+"\nCapela ao norte: %d/5 pedidos. Despedida antes do enterro." % WAKE.matches(wake_order)
    if is_instance_valid(burial_field) and burial_field.active and not rooms.inside():
        var job: Dictionary = burial_queue.pending()
        if not job.is_empty():
            objective_label.text = "OFICIO DE OSVALDO | PA EQUIPADA\nJazigo %s - %d/6 pazadas | %s" % [str(job["plot"]),burial_field.count_for(str(job["plot"])),"Jardim ao norte" if str(job["plot"]).begins_with("N-") else ("Jardim ao sul" if str(job["plot"])!="B-13" else "Quadra B")]
    if mobile_hud != null:
        mobile_hud.call("set_playable",not dialogue_open and not rooms.changing and (not is_instance_valid(burial_field) or burial_field.elapsed<0.0))
    if dialogue_open:
        prompt_label.text = ""
    elif not rescue_notice.is_empty():
        prompt_label.text = rescue_notice
        rescue_notice = ""
    elif location_hint_seconds > 0.0:
        prompt_label.text = location_hint
    else:
        var near := _near_station()
        var target: String = str(near.get("name",""))
        if str(near.get("id","")) == "osvaldo" and burial_queue.has_pending():
            target = "Seu Osvaldo - SEPULTAMENTO AGENDADO"
        if not near.is_empty() and not rooms.inside() and rooms.CATALOG.ROOMS.has(str(near["id"])):
            target = "Entrar: " + target
        prompt_label.text = ("E  ·  " + target) if not near.is_empty() else "WASD / Setas: andar   ·   E: interagir   ·   R: resgatar"


func is_walkable(world_position: Vector2) -> bool:
    if rooms.inside():
        return rooms.walkable(world_position)
    # Sem barreiras invisiveis nas areas transitaveis. Os blocos abrangem
    # somente o corpo da administracao e do galpao, nao suas entradas.
    if world_position.x < 58.0 or world_position.x > 3025.0:
        return false
    if world_position.y < -1660.0 or world_position.y > 2245.0:
        return false
    if world_position.y<92.0 and (world_position.x<650.0 or world_position.x>925.0) and world_position.y>=-100.0:
        return false
    if world_position.y<0.0 and world_position.x>1510.0:
        return false
    if Rect2(665,-335,230,135).has_point(world_position):
        return false
    if Rect2(196, 150, 418, 280).has_point(world_position):
        return false
    if Rect2(1138, 168, 286, 203).has_point(world_position):
        return false
    if is_instance_valid(burial_field) and burial_field.blocked(world_position):
        return false
    if GRAVE_LAYOUT.is_blocked(world_position):
        return false
    if DISTRICT_LAYOUT.is_blocked(world_position):
        return false
    if TREE_LAYOUT.is_blocked(world_position):
        return false
    return true




func _build_burial_marker() -> void:
    burial_marker = Label.new()
    burial_marker.name = "OsvaldoServicoDisponivel"
    burial_marker.text = "SERVICO!"
    burial_marker.position = Vector2(725, 515)
    burial_marker.size = Vector2(145, 32)
    burial_marker.z_index = 24
    burial_marker.add_theme_font_size_override("font_size", 20)
    burial_marker.add_theme_color_override("font_color", GOLD)
    burial_marker.add_theme_color_override("font_outline_color", NIGHT)
    burial_marker.add_theme_constant_override("outline_size", 4)
    burial_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(burial_marker)
    burial_marker.visible = burial_queue.has_pending() and not rooms.inside()

func is_b13_buried() -> bool:
    return burial_queue.is_done(BURIAL_QUEUE.INITIAL_ORDER)

func _start_osvaldo_work() -> void:
    var service: Dictionary = burial_queue.pending()
    if service.is_empty() or rooms.inside():
        return
    if not WAKE.done(service):
        _show("Seu Osvaldo","Primeiro o ultimo adeus. A capela fica atras do escritorio e da oficina, pelo portao norte.",[{"text":"Entendi","action":"close"}])
        return
    _show("Seu Osvaldo","Chefe, nada de telinha! Pegue a pa e siga ao jazigo %s. Seis pazadas e um servico digno. O defunto nao tem pressa, mas o Baltazar tem planilha." % str(service["plot"]),[{"text":"Pegar a pa e trabalhar","action":"field_begin"},{"text":"Depois","action":"close"}])

func _offer_field_job() -> void:
    for plot in BURIAL_FIELD.plots():
        var id: String = plot["id"]
        if id!="B-13" and not burial_queue.is_done("field_"+id):
            _show("Seu Osvaldo","Temos outro atendimento ficticio conferido pelo escritorio: jazigo "+id+". Documentacao e autorizacao registradas. O jardim novo fica ao sul. Bora trabalhar antes que a terra cobre aluguel!",[{"text":"Aceitar ordem de servico","action":"field_next"},{"text":"Depois","action":"close"}])
            return
    _show("Seu Osvaldo","Todos os jazigos ocupados! Ate o alem tem limite de lotacao.",[{"text":"Voltar","action":"close"}])

func _create_field_job() -> void:
    if burial_queue.has_pending() or not is_b13_buried():
        _close()
        return
    for plot in BURIAL_FIELD.plots():
        var id: String = plot["id"]
        if id!="B-13" and not burial_queue.is_done("field_"+id):
            if burial_queue.enqueue("field_"+id,"Atendimento autorizado "+id,id,day,true,true):
                _save_game()
                _start_osvaldo_work()
            return

func _burial_progress(progress: Dictionary, service_id: String) -> void:
    burial_queue.update_progress(service_id, progress)
    _save_game()

func _burial_finished(success: bool, quality: int, service_id: String) -> void:
    if is_instance_valid(burial_layer):
        burial_layer.queue_free()
    burial_layer = null
    player.set_physics_process(true)
    player.virtual_direction = Vector2.ZERO
    dialogue_open = false
    var registered: bool = false
    if success:
        registered = burial_queue.complete(service_id)
        if registered:
            reputation = mini(100, reputation + (5 if quality >= 90 else 2))
            compliance = mini(100, compliance + 2)
            if service_id.begins_with("field_"):
                money += 180
            if service_id.begins_with("case_"):
                rooms.complete_burial(service_id)
    _save_game()
    if registered:
        _notify("Sepultamento registrado! Seu Osvaldo aprovou o servico. Qualidade: %d%%" % quality, 4.0)
        $GravesLayer.queue_redraw()
    else:
        _notify("Servico guardado. Seu Osvaldo pode retomar as etapas depois.", 3.5)
    _refresh_ui()

func _start_driving() -> void:
    if is_instance_valid(driving_layer):
        return
    _close()
    dialogue_open = true
    player.set_physics_process(false)
    driving_layer = CanvasLayer.new()
    driving_layer.layer = 100
    add_child(driving_layer)
    var backdrop := ColorRect.new()
    backdrop.color = NIGHT
    driving_layer.add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var activity = preload("res://scripts/minigames/translado.gd").new()
    backdrop.add_child(activity)
    activity.finished.connect(_driving_finished)

func _driving_finished(success: bool, bumps: int) -> void:
    driving_layer.queue_free()
    driving_layer = null
    player.set_physics_process(true)
    var balance: int = 0
    var trust: int = 0
    var comment: String = "Treino encerrado. Até o fantasma precisa praticar!"
    if driving_job:
        balance = (150 - mini(bumps, 8)*25) if success else -30
        trust = (5 if bumps == 0 else (2 if bumps == 1 else -4)) if success else -3
        money += balance
        reputation = clampi(reputation + trust,0,100)
        comment = "Bonito, chefe! Nem o Baltazar reclamou da viagem." if success and bumps < 2 else "Rapaz, desse jeito o próximo enterro será o da nossa reputação!"
    elif success:
        driving_completed = true
        comment = "Muito bem! O para-lama agradece. Agora tente um serviço de verdade."
    _save_game()
    _show("Seu Osvaldo",comment+"\nImpactos: %d | Caixa: R$ %d | Confiança: %+d" % [bumps,balance,trust],[{"text":"Voltar ao expediente","action":"close"}])
