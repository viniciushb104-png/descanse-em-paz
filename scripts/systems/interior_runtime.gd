extends Node
## Gerenciador de transicoes, casos humanos e estoque: estado preservado no save principal.
const CATALOG = preload("res://scripts/world/interior_catalog.gd")
const CASES = preload("res://scripts/systems/customer_cases.gd")
const LEGAL = preload("res://scripts/systems/legal_lessons.gd")
const DIALOGUES = preload("res://scripts/systems/dialogue_scenes.gd")
var room: String = ""
var return_point := Vector2(748,714)
var case_index: int = 0
var pending_burial_id := ""
const BURIAL_CASES := [1,5,16]
const WAKE = preload("res://scripts/systems/wake_ceremony.gd")
const FIELD = preload("res://scripts/world/burial_field.gd")
var inventory: Dictionary = {"caixao":2,"urna":1}
var skip_entry: bool = false
var changing: bool = false
## Progress along one conversation, preserved in save.cfg.
var dialogue_step: int = 0
var dialogue_grades: Array = []
var awaiting_reaction: bool = false
var last_grade: int = -1
var last_reaction: String = ""
var humor_used: bool = false
var repairs: int = 0

func game() -> Node2D:
    return get_parent() as Node2D

func inside() -> bool:
    return not room.is_empty()

func save_state(cfg: ConfigFile) -> void:
    cfg.set_value("save","current_room",room)
    cfg.set_value("save","return_point",return_point)
    cfg.set_value("save","case_index",case_index)
    cfg.set_value("save","case_pending_burial",pending_burial_id)
    cfg.set_value("save","stock",inventory)
    cfg.set_value("save","case_dialogue_step",dialogue_step)
    cfg.set_value("save","case_dialogue_grades",dialogue_grades)
    cfg.set_value("save","case_awaiting_reaction",awaiting_reaction)
    cfg.set_value("save","case_last_grade",last_grade)
    cfg.set_value("save","case_last_reaction",last_reaction)
    cfg.set_value("save","case_humor_used",humor_used)
    cfg.set_value("save","case_repairs",repairs)

func load_state(cfg: ConfigFile) -> void:
    room = str(cfg.get_value("save","current_room",""))
    var legacy_archive := room == "biblioteca"
    if legacy_archive:
        room = "office"
    if not CATALOG.ROOMS.has(room):
        room = ""
    return_point = cfg.get_value("save","return_point",Vector2(748,714))
    if legacy_archive:
        return_point = Vector2(425,476)
    if room=="fiscalizacao" and return_point.distance_to(Vector2(2208,1155))<120.0:
        return_point = Vector2(2840,1085)
    if room=="garagem" and return_point.distance_to(Vector2(1818,1116))<120.0:
        return_point = Vector2(1860,1408)
    case_index = clampi(int(cfg.get_value("save","case_index",0)),0,CASES.total())
    pending_burial_id = str(cfg.get_value("save","case_pending_burial",""))
    inventory = cfg.get_value("save","stock",{"caixao":2,"urna":1})
    for product in ["caixao","urna"]:
        inventory[product] = maxi(0,int(inventory.get(product,0)))
    var max_steps: int = DIALOGUES.beat_keys(case_index).size()
    dialogue_step = clampi(int(cfg.get_value("save","case_dialogue_step",0)),0,max_steps)
    dialogue_grades = cfg.get_value("save","case_dialogue_grades",[])
    if not dialogue_grades is Array:
        dialogue_grades = []
    while dialogue_grades.size() > max_steps:
        dialogue_grades.pop_back()
    # Old saves have no dialogue state; their completed cases remain completed.
    dialogue_step = mini(dialogue_step,dialogue_grades.size())
    awaiting_reaction = bool(cfg.get_value("save","case_awaiting_reaction",false))
    last_grade = int(cfg.get_value("save","case_last_grade",-1))
    last_reaction = str(cfg.get_value("save","case_last_reaction",""))
    humor_used = bool(cfg.get_value("save","case_humor_used",false))
    repairs = maxi(0,int(cfg.get_value("save","case_repairs",0)))
    # Compatibilidade com saves antigos pausados na reacao positiva.
    if awaiting_reaction and last_grade > 0:
        awaiting_reaction = false
        dialogue_step = mini(max_steps,dialogue_step + 1)

func apply_room() -> void:
    for item in ["GroundLayer","LobbyBeauty","TreeLayer","PropsLayer","GravesLayer","DistrictLayer","ExpansionLayer","DepthLayer","CloudLayer"]:
        game().get_node(item).visible = not inside()
    game().get_node("InteriorLayer").set_room(room)
    var camera := game().get_node("Player/Camera2D") as Camera2D
    if inside():
        camera.zoom = Vector2.ONE
        camera.limit_left = 0
        camera.limit_top = 0
        camera.limit_right = 1152
        camera.limit_bottom = 648
    else:
        camera.zoom = Vector2(0.75,0.75)
        camera.limit_top = -1728
        camera.limit_right = 3072
        camera.limit_bottom = 2304
    update_client()

func update_client() -> void:
    if not inside():
        return
    var next: Dictionary = CASES.active(case_index)
    if next.is_empty() or str(next["room"]) != room:
        game().get_node("InteriorLayer").set_customer("VISITANTE","calmo")
    else:
        game().get_node("InteriorLayer").set_customer(str(next["client"]),str(next["profile"]))

func nearest(pos: Vector2) -> Dictionary:
    var found: Dictionary = {}
    var distance := 98.0
    for s in CATALOG.points(room):
        var d: float = pos.distance_to(s["p"])
        var reach: float = 62.0 if str(s["id"]) == "exit" else 98.0
        if d < distance and d < reach:
            distance=d
            found=s
    return found

func walkable(pos: Vector2) -> bool:
    # Limites permitem acessar a porta e atravessar o corredor ate o atendente.
    return pos.x >= 65.0 and pos.x <= 1088.0 and pos.y >= 164.0 and pos.y <= 575.0

func safe_spawn() -> Vector2:
    return CATALOG.ENTRY if inside() else Vector2(748,714)

func offer_entry(id: String) -> bool:
    if inside() or skip_entry or changing or not CATALOG.ROOMS.has(id):
        return false
    # A entrada agora e direta e animada: sem pergunta nem popup.
    enter(id)
    return true

func enter(id: String) -> void:
    if not CATALOG.ROOMS.has(id) or inside() or changing:
        return
    changing = true
    game().get_node("DoorTransition").travel(_enter_now.bind(id), _end_transition)

func _enter_now(id: String) -> void:
    return_point = game().player.global_position
    room = id
    game().player.global_position = CATALOG.ENTRY
    game().player.virtual_direction = Vector2.ZERO
    game().player.velocity = Vector2.ZERO
    apply_room()
    game()._save_game()
    game()._close()
    game()._notify(str(CATALOG.ROOMS[id]["title"])+"  |  E: interagir",1.65)

func leave() -> void:
    if not inside() or changing:
        return
    changing = true
    game().get_node("DoorTransition").travel(_leave_now, _end_transition)

func _leave_now() -> void:
    room = ""
    game().player.global_position = return_point
    game().player.virtual_direction = Vector2.ZERO
    game().player.velocity = Vector2.ZERO
    apply_room()
    game()._save_game()
    game()._close()
    game()._notify("Santa Mortalha  |  Explore o distrito",1.35)
    game()._refresh_ui()

func _end_transition() -> void:
    changing = false
    game()._refresh_ui()

func interact(id: String) -> void:
    if room=="chapel" and id=="chapel_attendant":
        chapel_attendant()
        return
    if room=="chapel" and id.begins_with("wake_"):
        wake_interact(id)
        return
    match id:
        "exit":
            leave()
        "agent":
            if room == "fornecedor":
                stock_menu()
            elif room == "funeraria":
                game()._show_character("Madame Amália Umbra","O cliente decide, nós orientamos. O único empurrão permitido aqui é no carrinho de arquivos.","diretora",[{"text":"Ver fila de atendimentos","action":"case_board"},{"text":"Direitos do consumidor","action":"legal_valores"},{"text":"Fechar","action":"close"}],"ironico")
            else:
                game()._interact(room)
        "client":
            show_case()
        "board":
            show_board()
        "catalog":
            if room == "office":
                game()._interact("biblioteca")
            elif room == "fornecedor":
                stock_menu()
            elif room == "funeraria":
                game()._show("Catalogo Umbra","Caixoes: %d em estoque. Urnas cinerarias: %d. Escolhas opcionais devem ser explicadas e nunca impostas." % [int(inventory["caixao"]),int(inventory["urna"])],[{"text":"Montar homenagem floral","action":"activity_start_flowers"},{"text":"Consultar normas de consumo","action":"legal_valores"},{"text":"Fechar","action":"close"}])
            else:
                var lesson: String = "registro"
                match room:
                    "preparo": lesson="preparo"
                    "crematorio": lesson="cremacao"
                    "garagem": lesson="transporte"
                    "fiscalizacao": lesson="ambiente"
                game()._show("Balcao de orientacao",str(CATALOG.ROOMS[room]["description"]),[{"text":"Consultar referencia","action":"legal_"+lesson},{"text":"Fechar","action":"close"}])

func show_board() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        game()._show("Livro de ocorrencias", "Todos os 20 casos foram concluidos. Agora cada pasta registra o que foi aprendido, nao so o que foi cobrado.",[{"text":"Fechar","action":"close"}])
        return
    var tier: int = DIALOGUES.tier(case_index)
    var tier_name: String = ["","Acolhimento","Contexto","Investigacao","Responsabilidade"][tier]
    game()._show("Pasta %02d/%02d - %s" % [case_index+1,CASES.total(),tier_name],
        str(item["client"])+" - "+str(item["profile"])+".\nLocal: "+str(CATALOG.ROOMS[item["room"]]["title"])+
        "\nSituacao: "+str(item["context"])+
        "\n\nEtapa da conversa: %d/%d. O humor pode acolher, mas nao substitui informacao ou documentos." % [dialogue_step,DIALOGUES.beat_keys(case_index).size()],
        [{"text":"Fechar","action":"close"}])

func show_case() -> void:
    if not pending_burial_id.is_empty():
        game()._show("Sepultamento pendente","O atendimento ainda nao terminou. Organize o velorio na capela antes de procurar Seu Osvaldo.",[{"text":"Voltar","action":"close"}])
        return
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        show_board()
        return
    if not inside() or str(item["room"]) != room:
        game()._show("Sala de espera","O proximo cliente aguarda em "+str(CATALOG.ROOMS[item["room"]]["title"])+".",[{"text":"Fechar","action":"close"}])
        return
    if awaiting_reaction:
        _show_reaction()
    elif dialogue_step >= DIALOGUES.beat_keys(case_index).size():
        _audit()
    else:
        _show_beat()

func _show_beat() -> void:
    var item: Dictionary = CASES.active(case_index)
    var beat: Dictionary = DIALOGUES.scene(case_index,dialogue_step,str(item.get("client","Cliente")))
    if beat.is_empty():
        _audit()
        return
    var responses: Array = []
    for index in range((beat["choices"] as Array).size()):
        var option: Dictionary = beat["choices"][index]
        responses.append({"text":str(option["text"]),"action":"case_pick_"+str(index)})
    responses.append({"text":"Consultar o livro de ocorrencias","action":"case_board"})
    var chapter: String = "Conversa %d/%d" % [dialogue_step+1,int(beat["total"])]
    var spoken_line: String = str(beat["line"])
    if not last_reaction.is_empty():
        spoken_line = "Antes: "+last_reaction+"\n\n"+spoken_line
    var speaking_profile: String = str(beat.get("profile",""))
    if speaking_profile.is_empty():
        speaking_profile = str(item["profile"])
    var emotion_by_mode: Dictionary = {
        "warm":"alegre", "verify":"preocupado",
        "deep":"surpreso", "plan":"ironico", "close":"alegre"
    }
    var emotion: String = str(emotion_by_mode.get(str(beat["mode"]),"alegre"))
    game()._show_character(str(beat["speaker"]),chapter+"\n\n"+spoken_line,speaking_profile,responses,emotion)

func choose_dialogue_option(index: int) -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty() or not inside() or room != str(item["room"]) or awaiting_reaction:
        return
    var beat: Dictionary = DIALOGUES.scene(case_index,dialogue_step,str(item["client"]))
    if beat.is_empty() or index < 0 or index >= (beat["choices"] as Array).size():
        return
    var reaction: Dictionary = DIALOGUES.reaction(case_index,dialogue_step,index,str(item["client"]))
    if reaction.is_empty():
        return
    last_grade = int(reaction["score"])
    last_reaction = str(reaction["line"])
    if last_grade > 0:
        if dialogue_grades.size() == dialogue_step:
            dialogue_grades.append(last_grade)
        elif dialogue_step < dialogue_grades.size():
            dialogue_grades[dialogue_step] = last_grade
        if str(reaction["tone"]) == "humor":
            humor_used = true
    else:
        # A hypothetical shortcut is blocked before any non-compliant service occurs.
        repairs += 1
        game().reputation = maxi(0,game().reputation-1)
        game().compliance = maxi(0,game().compliance-2)
    # Resposta responsavel ja segue para o proximo dialogo.
    # Atalho inseguro exige reparo antes de qualquer servico.
    if last_grade > 0:
        dialogue_step += 1
        awaiting_reaction = false
        last_grade = -1
        last_reaction = str(reaction["line"])
        game()._save_game()
        show_case()
    else:
        awaiting_reaction = true
        game()._save_game()
        _show_reaction()
    game()._refresh_ui()

func _show_reaction() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return
    var response: Array = [{"text":"Corrigir a resposta","action":"case_retry"}] if last_grade == 0 else [{"text":"Continuar","action":"case_advance"}]
    response.append({"text":"Retomar mais tarde","action":"close"})
    var last: Dictionary = DIALOGUES.scene(case_index,dialogue_step,str(item["client"]))
    var speaking_profile: String = str(last.get("profile",""))
    if speaking_profile.is_empty():
        speaking_profile = str(item["profile"])
    var reaction_expression: String = "preocupado" if last_grade == 0 else "alegre"
    game()._show_character(str(last.get("speaker",item["client"])),last_reaction,speaking_profile,response,reaction_expression)

func advance_dialogue() -> void:
    if not awaiting_reaction:
        return
    awaiting_reaction = false
    if last_grade > 0:
        dialogue_step += 1
    last_grade = -1
    last_reaction = ""
    game()._save_game()
    show_case()

func retry_dialogue() -> void:
    if not awaiting_reaction or last_grade != 0:
        return
    awaiting_reaction = false
    last_grade = -1
    last_reaction = ""
    game()._save_game()
    show_case()

func _audit() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return
    var total_steps: int = DIALOGUES.beat_keys(case_index).size()
    if dialogue_step < total_steps or dialogue_grades.size() < total_steps:
        _show_beat()
        return
    var achieved: int = 0
    for grade in dialogue_grades:
        achieved += int(grade)
    if achieved < DIALOGUES.required_score(case_index):
        game()._show("Revisao do atendimento",
            "Voce ouviu o cliente, mas algumas partes ficaram incompletas. O trabalho profissional exige juntar clareza, procedimento e respeito.\n\nReleia as pistas e retome a conversa; nenhuma contratacao sera executada precipitadamente.",
            [{"text":"Revisar trechos pendentes","action":"case_review"},{"text":"Consultar a referencia","action":"legal_"+str(item["lesson"])},{"text":"Voltar depois","action":"close"}])
        return
    # A ultima decisao responsavel registra o caso, sem confirmacao duplicada.
    finish_case()

func review_dialogue() -> void:
    var first_partial: int = -1
    for idx in range(dialogue_grades.size()):
        if int(dialogue_grades[idx]) < 2:
            first_partial = idx
            break
    dialogue_step = maxi(0,first_partial)
    dialogue_grades.resize(dialogue_step)
    awaiting_reaction = false
    last_grade = -1
    last_reaction = ""
    game()._save_game()
    show_case()

func _reset_dialogue() -> void:
    dialogue_step = 0
    dialogue_grades.clear()
    awaiting_reaction = false
    last_grade = -1
    last_reaction = ""
    humor_used = false
    repairs = 0

func stock_menu() -> void:
    game()._show("Gervasio Caixote - Emporio","Estoque: %d caixoes, %d urnas cinerarias. Valores ficticios de suprimentos. Comprar exige conferir procedencia, condicoes e nota fiscal." % [int(inventory["caixao"]),int(inventory["urna"])],
        [{"text":"Organizar depósito","action":"activity_start_stock"},{"text":"Comprar 2 caixoes: R$ 240","action":"stock_caixao"},{"text":"Comprar 2 urnas: R$ 160","action":"stock_urna"},{"text":"Voltar","action":"close"}])

func purchase(kind: String) -> void:
    if not inside() or room != "fornecedor" or not inventory.has(kind):
        return
    var cost: int = 240 if kind=="caixao" else 160
    if game().money < cost:
        game()._show("Saldo insuficiente","Baltazar recomenda planejar as compras antes de autorizar despesas.",[{"text":"Voltar","action":"close"}])
        return
    game().money -= cost
    inventory[kind] = int(inventory[kind])+2
    game()._save_game()
    stock_menu()

func finish_case() -> void:
    if not pending_burial_id.is_empty():
        show_case()
        return
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        show_board()
        return
    # Completion requires the whole conversation, not a single 'correct' button.
    var steps: int = DIALOGUES.beat_keys(case_index).size()
    if dialogue_step < steps or dialogue_grades.size() < steps or awaiting_reaction:
        show_case()
        return
    var total_grade: int = 0
    for grade in dialogue_grades:
        total_grade += int(grade)
    if total_grade < DIALOGUES.required_score(case_index):
        _audit()
        return
    if not inside() or room != str(item["room"]):
        game()._show("Local incorreto","Encontre a pessoa na sala indicada pelo livro de casos.",[{"text":"Voltar","action":"close"}])
        return
    var burial_required := int(item["id"]) in BURIAL_CASES
    var chosen_plot := ""
    if burial_required:
        for plot in FIELD.north_plots():
            var id: String = plot["id"]
            if id=="B-13":
                continue
            var used := false
            for order in game().burial_queue.orders:
                if str(order["plot"])==id:
                    used = true
                    break
            if not used:
                chosen_plot = id
                break
        if chosen_plot.is_empty():
            game()._show("Sem jazigos livres","Nao ha vaga para este atendimento.",[{"text":"Voltar","action":"close"}])
            return
    var needed: String = str(item["stock"])
    if not needed.is_empty():
        if int(inventory.get(needed,0)) <= 0:
            game()._show("Estoque insuficiente","Precisamos de um(a) "+needed+". Va ao Emporio e compre suprimentos antes de concluir.",[{"text":"Entendi","action":"close"}])
            return
    if burial_required:
        var id := "case_%d" % int(item["id"])
        # Confirmação explícita do contrato fictício antes de liberar o campo.
        game()._show("Ordem de sepultamento", "A familia solicita enterro no jazigo "+chosen_plot+". Confirme que a documentacao e a autorizacao ficticias foram conferidas.",[{"text":"Conferir e autorizar","action":"case_authorize_burial"},{"text":"Depois","action":"close"}])
        return
    if not needed.is_empty():
        inventory[needed] = int(inventory[needed])-1
    game().money += int(item["reward"])
    game().reputation = mini(100,game().reputation+3)
    game().compliance = mini(100,game().compliance+2)
    case_index += 1
    _reset_dialogue()
    game()._save_game()
    update_client()
    game()._show("Atendimento concluido",str(item["client"])+" recebeu orientacao responsavel.\nCaixa ficticio: +R$ %d  |  Reputacao +3  |  Conformidade +2.\n\nFonte: %s" % [int(item["reward"]),str(LEGAL.ITEMS[str(item["lesson"])]["source"])],
        [{"text":"Voltar ao jogo","action":"close"},{"text":"Estudar este assunto","action":"legal_"+str(item["lesson"])}])
    game()._refresh_ui()

func authorize_burial() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty() or not pending_burial_id.is_empty() or not int(item["id"]) in BURIAL_CASES or not inside() or room!=str(item["room"]):
        return
    var steps: int = DIALOGUES.beat_keys(case_index).size()
    var score := 0
    for grade in dialogue_grades:
        score += int(grade)
    if dialogue_step<steps or dialogue_grades.size()<steps or awaiting_reaction or score<DIALOGUES.required_score(case_index):
        return
    var needed: String = item["stock"]
    if int(inventory.get(needed,0))<=0:
        return
    for plot in FIELD.north_plots():
        var id: String = plot["id"]
        if id=="B-13":
            continue
        var used := false
        for order in game().burial_queue.orders:
            if str(order["plot"])==id:
                used = true
                break
        if used:
            continue
        var key := "case_%d" % int(item["id"])
        if game().burial_queue.enqueue(key,str(item["client"]),id,int(game().day),true,true):
            inventory[needed] = int(inventory[needed])-1
            pending_burial_id = key
            game()._save_game()
            game()._show("Servico agendado","Jazigo "+id+" reservado. A recompensa sera liberada somente apos o velorio e sepultamento. Visite a capela ao norte.",[{"text":"Ir ao cemiterio","action":"leave_room"}])
            return

func complete_burial(service_id: String) -> bool:
    if pending_burial_id.is_empty() or service_id!=pending_burial_id or not game().burial_queue.is_done(service_id):
        return false
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return false
    game().money += int(item["reward"])
    game().reputation = mini(100,game().reputation+3)
    game().compliance = mini(100,game().compliance+2)
    pending_burial_id = ""
    case_index += 1
    _reset_dialogue()
    update_client()
    return true

func reject_case() -> void:
    # Legacy API removed: clients are resolved through multi-step conversations.
    show_case()

func handle_choice(action: String) -> bool:
    if action=="chapel_guide" and room=="chapel":
        game()._show("Anselmo Velario","Confira flores, luz, musica, cadeiras e homenagem. Depois receba a familia, respeite a despedida e encerre a cerimonia junto ao caixao.",[{"text":"Entendi","action":"close"}])
        return true
    if action.begins_with("wake_"):
        return wake_choice(action)
    if action.begins_with("case_pick_"):
        var number: String = action.trim_prefix("case_pick_")
        if number.is_valid_int():
            choose_dialogue_option(int(number))
        return true
    if action.begins_with("enter_"):
        enter(action.trim_prefix("enter_"))
        return true
    if action.begins_with("outside_"):
        skip_entry=true
        game()._interact(action.trim_prefix("outside_"))
        skip_entry=false
        return true
    match action:
        "leave_room":
            leave()
            return true
        "case_board":
            show_board()
            return true
        "case_advance":
            advance_dialogue()
            return true
        "case_retry":
            retry_dialogue()
            return true
        "case_review":
            review_dialogue()
            return true
        "case_authorize_burial":
            authorize_burial()
            return true
        "case_finalize":
            finish_case()
            return true
        "stock_caixao":
            purchase("caixao")
            return true
        "stock_urna":
            purchase("urna")
            return true
    return false

func objective() -> String:
    if not pending_burial_id.is_empty():
        return "Atendimento em andamento: velorio na capela, depois sepultamento com Osvaldo."
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return "Campanha completa: 20 casos atendidos!"
    return "Caso %02d/%02d | Nivel %d/4: %s.\nLocal: %s" % [case_index+1,CASES.total(),DIALOGUES.tier(case_index),str(item["client"]),str(CATALOG.ROOMS[item["room"]]["title"])]

func wake_interact(id: String) -> void:
    var order: Dictionary = game().burial_queue.pending()
    if id=="wake_family" and (order.is_empty() or WAKE.done(order)):
        chapel_visitor()
        return
    if order.is_empty():
        game()._show("Capela do Ultimo Adeus","Nenhuma cerimonia agendada. O salao esta aberto para visita.",[{"text":"Voltar","action":"close"}])
        return
    if WAKE.done(order):
        game()._show("Cerimonia encerrada","A despedida terminou. Procure Seu Osvaldo para o jazigo "+str(order["plot"])+".",[{"text":"Voltar","action":"close"}])
        return
    var state: Dictionary = WAKE.state(order)
    if id=="wake_family":
        var choices: Array = [{"text":"Receber a familia","action":"wake_receive"},{"text":"Voltar","action":"close"}] if WAKE.ready(order) and not bool(state["received"]) else [{"text":"Entendi","action":"close"}]
        game()._show(str(order["customer"]),WAKE.requests(order)+"\n\nPreparativos: %d/5." % WAKE.matches(order),choices)
        return
    if id=="wake_coffin":
        if not WAKE.ready(order) or not bool(state["received"]):
            game()._show("Preparativos pendentes","Confira os cinco pedidos e receba a familia antes da despedida.",[{"text":"Voltar","action":"close"}])
        elif not bool(state["farewell"]):
            game()._show(str(order["customer"]),str(WAKE.profile(str(order["id"]))["farewell"]),[{"text":"Respeitar o momento de despedida","action":"wake_farewell"},{"text":"Voltar","action":"close"}])
        else:
            game()._show("O ultimo adeus","A familia esta pronta para seguir ao cemiterio.",[{"text":"Encerrar cerimonia","action":"wake_finish"},{"text":"Voltar","action":"close"}])
        return
    var key := id.trim_prefix("wake_")
    if not WAKE.OPTIONS.has(key):
        return
    if bool(state["received"]):
        game()._show("Cerimonia em andamento","Os preparativos foram aprovados pela familia.",[{"text":"Voltar","action":"close"}])
        return
    var opts: Array = []
    for i in range(WAKE.OPTIONS[key].size()):
        opts.append({"text":str(WAKE.OPTIONS[key][i]),"action":"wake_set_"+key+"_"+str(i)})
    game()._show(str(WAKE.LABELS[key]),"Escolha conforme os pedidos da familia. Pode rever a escolha depois.",opts)

func wake_choice(action: String) -> bool:
    if room!="chapel" or changing:
        return true
    var order: Dictionary = game().burial_queue.pending()
    if order.is_empty() or WAKE.done(order):
        return true
    var state: Dictionary = WAKE.state(order)
    if action.begins_with("wake_set_"):
        var parts := action.trim_prefix("wake_set_").split("_")
        if parts.size()!=2 or not WAKE.OPTIONS.has(parts[0]) or not parts[1].is_valid_int() or bool(state["received"]):
            return true
        var n := int(parts[1])
        if n<0 or n>=WAKE.OPTIONS[parts[0]].size():
            return true
        state["choices"][parts[0]] = n
    elif action=="wake_receive" and WAKE.ready(order):
        state["received"] = true
    elif action=="wake_farewell" and WAKE.ready(order) and bool(state["received"]):
        state["farewell"] = true
    elif action=="wake_finish" and WAKE.ready(order) and bool(state["received"]) and bool(state["farewell"]):
        state["done"] = true
    else:
        return true
    var progress: Dictionary = order["progress"]
    progress["wake"] = state
    game().burial_queue.update_progress(str(order["id"]),progress)
    game()._save_game()
    game().get_node("InteriorLayer").queue_redraw()
    game()._close()
    if bool(state["done"]):
        game()._notify("Velorio concluido. Sepultamento liberado com Osvaldo.",4.0)
    else:
        game()._notify("Preparacao registrada.",1.7)
    return true

func chapel_attendant() -> void:
    var order: Dictionary = game().burial_queue.pending()
    var message := "Uma cadeira desalinhada e o principio do caos civilizacional. Hoje o salao esta aberto para visitas."
    if not order.is_empty():
        if WAKE.done(order):
            message = "A despedida terminou. Osvaldo aguarda para o jazigo "+str(order["plot"])+"."
        else:
            message = "Temos uma cerimonia para "+str(order["customer"])+".\n"+WAKE.requests(order)+"\nPreparativos: %d/5." % WAKE.matches(order)
    game()._show("Sr. Anselmo Velario",message,[{"text":"Como organizar uma cerimonia?","action":"chapel_guide"},{"text":"Ate logo","action":"close"}])

func chapel_visitor() -> void:
    var lines := ["Meu Astolfo sempre dizia que descansaria quando morresse. Conhecendo aquele homem, deve estar dormindo ate agora.","Se encontrar um fantasma de gravata xadrez, diga que ainda estou esperando meus vinte reais.","Trouxe crisantemos para Astolfo. O jovem Anselmo tem muito bom gosto, so precisa aprender a sorrir."]
    game()._show("Dona Eudoxia Crisantemo",lines[randi_range(0,lines.size()-1)],[{"text":"Ate logo, Dona Eudoxia","action":"close"}])
