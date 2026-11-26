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
const COFFIN_ART = preload("res://scripts/world/chapel_coffin_art.gd")
const COFFINS = preload("res://scripts/systems/coffin_catalog.gd")
const MAGAZINE = preload("res://scripts/systems/funeral_magazine_data.gd")
const URNS = preload("res://scripts/systems/urn_catalog.gd")
var urn_stock: Dictionary = {"essencia":1}
# Encaminhamento paralelo, independente dos 20 casos e da fila de sepultamento.
var cremation_referral: Dictionary = {}
const FUNERAL_LORE = preload("res://scripts/systems/funeral_lore.gd")
var coffin_stock: Dictionary = {"serenidade":2}
var coffin_selection: Dictionary = {}
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
    sync_coffin_stock()
    cfg.set_value("save","stock",inventory)
    cfg.set_value("save","coffin_stock",coffin_stock)
    sync_urn_stock()
    cfg.set_value("save","urn_stock",urn_stock)
    cfg.set_value("save","cremation_referral",cremation_referral)
    cfg.set_value("save","coffin_selection",coffin_selection)
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
    var stored_models: Variant = cfg.get_value("save","coffin_stock",{})
    coffin_stock = stored_models if stored_models is Dictionary else {}
    sync_coffin_stock()
    var stored_urns: Variant = cfg.get_value("save","urn_stock",{})
    urn_stock = stored_urns if stored_urns is Dictionary else {}
    sync_urn_stock()
    var saved_referral: Variant = cfg.get_value("save","cremation_referral",{})
    cremation_referral = saved_referral if saved_referral is Dictionary else {}
    var stored_selection: Variant = cfg.get_value("save","coffin_selection",{})
    coffin_selection = stored_selection if stored_selection is Dictionary else {}
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
    # Bases solidas do caixao e da tampa; entrada e demais salas preservadas.
    if room=="chapel" and (COFFIN_ART.SOLID_RECT.has_point(pos) or COFFIN_ART.LID_BASE.has_point(pos)):
        return false
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
                game()._show_character("Madame Amália Umbra","O cliente decide, nós orientamos. O único empurrão permitido aqui é no carrinho de arquivos.","diretora",[{"text":"Ver fila de atendimentos","action":"case_board"},{"text":"Direitos do consumidor","action":"legal_valores"},{"text":"Conheça Madame Amália na revista","action":"magazine_amalia"},{"text":"Como escolher um caixão?","action":"coffin_advice"},{"text":"Atendimento sobre cremação","action":"cremation_referral_menu"},{"text":"Fechar","action":"close"}],"ironico")
            else:
                game()._interact(room)
        "violeta":
            violet_menu()
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
                game()._show("Catalogo Umbra","Caixoes: %d em estoque. Urnas cinerarias: %d. Escolhas opcionais devem ser explicadas e nunca impostas." % [int(inventory["caixao"]),int(inventory["urna"])],[{"text":"Consultar modelos de caixões","action":"coffin_view"},{"text":"Montar homenagem floral","action":"activity_start_flowers"},{"text":"Consultar normas de consumo","action":"legal_valores"},{"text":"Fechar","action":"close"}])
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
    var office_note := ""
    if room == "office":
        match int(item["id"]):
            4:
                office_note = "\n\nBaltazar: Posso atravessar um arquivo, mas não posso alterar um cadastro sem conferir a legitimidade. Vamos agir com cautela."
            11:
                office_note = "\n\nBaltazar: Até quem flutua precisa lembrar que um cemitério está sobre o solo. Consulte as referências ambientais e oriente a estudante."
            17:
                office_note = "\n\nBaltazar: Ser transparente não significa tornar os dados dos clientes públicos. Vamos preservar a confidencialidade."
            _:
                office_note = "\n\nBaltazar: Cada pasta tem uma história, chefe. Vamos cuidar dela com respeito."
    var tier: int = DIALOGUES.tier(case_index)
    var tier_name: String = ["","Acolhimento","Contexto","Investigacao","Responsabilidade"][tier]
    game()._show("Pasta %02d/%02d - %s" % [case_index+1,CASES.total(),tier_name],
        str(item["client"])+" - "+str(item["profile"])+".\nLocal: "+str(CATALOG.ROOMS[item["room"]]["title"])+
        "\nSituacao: "+str(item["context"])+
        "\n\nEtapa da conversa: %d/%d. O humor pode acolher, mas nao substitui informacao ou documentos." % [dialogue_step,DIALOGUES.beat_keys(case_index).size()]+office_note,
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
    coffin_selection.clear()
    dialogue_step = 0
    dialogue_grades.clear()
    awaiting_reaction = false
    last_grade = -1
    last_reaction = ""
    humor_used = false
    repairs = 0

func stock_menu() -> void:
    game()._show("Gervasio Caixote - Emporio","Estoque: %d caixoes, %d urnas cinerarias. Valores ficticios de suprimentos. Comprar exige conferir procedencia, condicoes e nota fiscal." % [int(inventory["caixao"]),int(inventory["urna"])],
        [{"text":"Organizar depósito","action":"activity_start_stock"},{"text":"Comprar caixões por modelo","action":"coffin_shop"},{"text":"Folhear revista de compras","action":"magazine_shop"},{"text":"Comprar 2 urnas: R$ 160","action":"stock_urna"},{"text":"Revista de urnas / Violeta","action":"violeta_menu"},{"text":"Voltar","action":"close"}])

func purchase(kind: String) -> void:
    if not inside() or room != "fornecedor" or not inventory.has(kind):
        return
    if kind == "caixao":
        coffin_shop()
        return
    var cost: int = 160
    if game().money < cost:
        game()._show("Saldo insuficiente","Baltazar recomenda planejar as compras antes de autorizar despesas.",[{"text":"Voltar","action":"close"}])
        return
    game().money -= cost
    inventory[kind] = int(inventory[kind])+2
    game()._save_game()
    stock_menu()

func sync_urn_stock() -> void:
    urn_stock = URNS.normalize(urn_stock,int(inventory.get("urna",0)))

func open_urn_magazine(mode: String = "browse") -> void:
    if room!="fornecedor":
        return
    if mode=="offer" and str(cremation_referral.get("status",""))!="referred":
        return
    sync_urn_stock()
    var title := "Violeta • Catálogo de urnas" if case_index>=3 else "Gervásio • Catálogo de urnas"
    if mode=="offer":
        title = "Família de Celeste • Limite para urna R$ %d" % URNS.FAMILY_BUDGET
    elif mode=="shop":
        title = "Empório • Caixa R$ %d" % int(game().money)
    game().open_magazine(MAGAZINE.urn_pages(urn_stock,mode,int(game().money)),title,mode,0 if mode=="browse" else 2)

func buy_urn(id: String) -> void:
    if room!="fornecedor" or URNS.item(id).is_empty():
        return
    var price := URNS.cost(id)
    if game().money<price:
        game()._show("Saldo insuficiente","Gervásio: Até as urnas precisam de um orçamento!",[{"text":"Voltar à revista","action":"urn_shop"}])
        return
    sync_urn_stock()
    game().money -= price
    urn_stock[id] = int(urn_stock[id])+1
    inventory["urna"] = int(inventory["urna"])+1
    game()._save_game()
    game()._refresh_ui()
    open_urn_magazine("shop")

func referral_menu() -> void:
    if room!="funeraria":
        return
    if case_index<3:
        game()._show("Madame Amália Umbra","A Violeta ainda está conhecendo o Empório. Termine o atendimento dela no caso 03; depois teremos uma nova consulta sobre cremação.",[{"text":"Fechar","action":"close"}])
        return
    if not cremation_referral.is_empty():
        game()._show("Madame Amália Umbra","O encaminhamento da família de Celeste já está registrado. "+referral_hint(),[{"text":"Fechar","action":"close"}])
        return
    game()._show("Família de Celeste","Celeste conversava conosco sobre a vontade de ser cremada. Queremos saber quais são as opções, sem contratar nada antes de conferir os documentos.",[{"text":"Família escolhe conhecer a cremação","action":"cremation_refer"},{"text":"Respeitar o tempo da família","action":"close"}])

func referral_hint() -> String:
    match str(cremation_referral.get("status","")):
        "referred": return "Procure Violeta no Empório para escolher a urna."
        "quoted": return "Leve a proposta ao escritório de Baltazar."
        "reviewed": return "Procure Cinério no crematório para triagem."
        "waiting": return "Encaminhamento registrado; operação aguarda o futuro minigame e autorização."
    return ""

func refer_cremation() -> void:
    if room!="funeraria" or case_index<3 or not cremation_referral.is_empty():
        return
    cremation_referral = {"customer":"Família de Celeste","status":"referred"}
    game()._save_game()
    game()._show("Madame Amália Umbra","Encaminhei a família ao Empório. A Violeta conhece urnas como Baltazar conhece planilhas: com entusiasmo preocupante. A escolha não autoriza a cremação.",[{"text":"Ir ao Empório","action":"leave_room"},{"text":"Depois","action":"close"}])

func violet_menu() -> void:
    if room!="fornecedor":
        return
    var title := "Sra. Violeta" if case_index>=3 else "Gervásio Caixote"
    var words := "Voltei ao Empório depois do meu atendimento. Agora ajudo a escolher urnas! Uma abóbora pode guardar memórias, mas nunca substituir documentos." if case_index>=3 else "Violeta ainda é nossa cliente. Por enquanto eu apresento a coleção."
    var opts: Array = [{"text":"Folhear revista de urnas","action":"urn_browse"},{"text":"Comprar urnas por modelo","action":"urn_shop"}]
    if str(cremation_referral.get("status",""))=="referred":
        opts.push_front({"text":"Atender família de Celeste","action":"urn_offer"})
    elif str(cremation_referral.get("status",""))=="quoted":
        opts.push_front({"text":"Rever proposta da família","action":"urn_revise"})
    opts.append({"text":"Fechar","action":"close"})
    game()._show(title,words,opts)

func select_urn(id: String) -> void:
    if room!="fornecedor" or str(cremation_referral.get("status",""))!="referred":
        return
    sync_urn_stock()
    if not URNS.can_offer(id,urn_stock):
        open_urn_magazine("offer")
        return
    var model := URNS.item(id)
    game()._show("Família de Celeste","Gostamos da urna "+str(model["name"])+". O valor de R$ %d cabe no nosso orçamento. Entendemos que esta proposta não é autorização de cremação." % int(model["price"]),[{"text":"Confirmar proposta de urna","action":"urn_confirm_"+id},{"text":"Rever modelos","action":"urn_offer"},{"text":"Depois","action":"close"}])

func confirm_urn(id: String) -> void:
    if room!="fornecedor" or str(cremation_referral.get("status",""))!="referred":
        return
    sync_urn_stock()
    if not URNS.can_offer(id,urn_stock):
        open_urn_magazine("offer")
        return
    var model := URNS.item(id)
    cremation_referral["urn"] = id
    cremation_referral["name"] = model["name"]
    cremation_referral["price"] = model["price"]
    cremation_referral["status"] = "quoted"
    game()._save_game()
    game()._show("Sra. Violeta","Proposta anotada, sem cobrança nem reserva definitiva. Leve-a ao Baltazar; a urna será separada quando o serviço autorizado estiver pronto para execução.",[{"text":"Ir ao escritório","action":"leave_room"},{"text":"Depois","action":"close"}])

func cremation_office() -> void:
    if room!="office":
        return
    if str(cremation_referral.get("status",""))!="quoted":
        game()._show("Baltazar | Cremação","Nenhuma proposta nova para conferência. "+referral_hint(),[{"text":"Fechar","action":"close"}])
        return
    sync_urn_stock()
    if not URNS.can_offer(str(cremation_referral.get("urn","")),urn_stock):
        cremation_referral["status"] = "referred"
        game()._save_game()
        game()._show("Baltazar | Cremação","O estoque mudou. Volte à Violeta para revisar a proposta.",[{"text":"Fechar","action":"close"}])
        return
    game()._show("Baltazar | Cremação","Urna "+str(cremation_referral["name"])+" | R$ %d. Isso é proposta, não licença! Vamos encaminhar o pedido para a triagem de documentos, sem declarar autorização que ainda não existe." % int(cremation_referral["price"]),[{"text":"Registrar encaminhamento para triagem","action":"cremation_review"},{"text":"Depois","action":"close"}])

func cremation_triage() -> void:
    if room!="crematorio":
        return
    if str(cremation_referral.get("status",""))!="reviewed":
        game()._show("Seu Cinério Brasa","Nenhuma proposta nova para triagem. "+referral_hint(),[{"text":"Fechar","action":"close"}])
        return
    game()._show("Seu Cinério Brasa","Recebi a proposta da família de Celeste. Antes de qualquer serviço, precisamos da documentação e da autorização aplicáveis. Minha fornalha tem paciência; a lei não aceita atalhos.",[{"text":"Registrar pedido e aguardar autorização","action":"cremation_wait"},{"text":"Consultar referência","action":"legal_cremacao"},{"text":"Depois","action":"close"}])

func sync_coffin_stock() -> void:
    coffin_stock = COFFINS.normalize(coffin_stock,int(inventory.get("caixao",0)))

func take_coffin(model: String) -> bool:
    sync_coffin_stock()
    if int(coffin_stock.get(model,0)) <= 0:
        return false
    coffin_stock[model] = int(coffin_stock[model])-1
    inventory["caixao"] = int(inventory["caixao"])-1
    return true

func coffin_shop() -> void:
    if room != "fornecedor":
        return
    sync_coffin_stock()
    var opts: Array = []
    for id in COFFINS.MODELS:
        var model: Dictionary = COFFINS.MODELS[id]
        opts.append({"text":"%s | custo R$ %d | estoque %d" % [model["name"],model["cost"],coffin_stock[id]],"action":"coffin_buy_"+str(id)})
    opts.append({"text":"Voltar","action":"coffin_shop_back"})
    game()._show("Gervásio Caixote | Catálogo de compra","Caixa da empresa: R$ %d. Gervásio: Não compre pelo brilho das alças, chefe! Pense nas encomendas. Compra unitária com nota e procedência conferidas (simulação). Valores fictícios." % game().money,opts)

func buy_coffin(model: String) -> void:
    if room != "fornecedor" or not COFFINS.MODELS.has(model):
        return
    var cost: int = int(COFFINS.MODELS[model]["cost"])
    if game().money < cost:
        game()._show("Saldo insuficiente","Baltazar: Até minha paciência é limitada. Confira o caixa antes de comprar.",[{"text":"Voltar ao catálogo","action":"coffin_shop"}])
        return
    sync_coffin_stock()
    game().money -= cost
    coffin_stock[model] = int(coffin_stock[model])+1
    inventory["caixao"] = int(inventory["caixao"])+1
    game()._save_game()
    game()._refresh_ui()
    coffin_shop()

func coffin_view() -> void:
    if room != "funeraria":
        return
    sync_coffin_stock()
    game().open_magazine(MAGAZINE.pages(coffin_stock),"Madame Amália • Consulte modelos e serviços", "browse")

func coffin_text_view() -> void:
    if room != "funeraria":
        return
    sync_coffin_stock()
    var lines: Array[String] = []
    for id in COFFINS.MODELS:
        var model: Dictionary = COFFINS.MODELS[id]
        lines.append("%s — %s | R$ %d | estoque %d" % [model["name"],model["description"],model["price"],coffin_stock[id]])
    game()._show("Madame Amália Umbra | Catálogo","Preços fictícios de venda. Madame Amália: Uma despedida não é concurso de luxo. A escolha é da família; nenhum modelo mais caro garante atendimento melhor.\n\n"+"\n".join(lines),[{"text":"Fechar","action":"close"}])

func coffin_case_ready() -> bool:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty() or not pending_burial_id.is_empty() or not int(item["id"]) in BURIAL_CASES or room != str(item["room"]):
        return false
    var steps: int = DIALOGUES.beat_keys(case_index).size()
    if dialogue_step < steps or dialogue_grades.size() < steps or awaiting_reaction:
        return false
    var score := 0
    for grade in dialogue_grades:
        score += int(grade)
    return score >= DIALOGUES.required_score(case_index)

func coffin_case_menu() -> void:
    if not coffin_case_ready():
        return
    sync_coffin_stock()
    var item: Dictionary = CASES.active(case_index)
    var case_id := int(item["id"])
    var opts: Array = []
    var available: Array[String] = []
    for id in COFFINS.MODELS:
        var model: Dictionary = COFFINS.MODELS[id]
        if COFFINS.permitted(case_id,str(id)):
            if int(coffin_stock[id])>0:
                opts.append({"text":"Apresentar %s — R$ %d" % [model["name"],model["price"]],"action":"coffin_select_"+str(id)})
            else:
                available.append(str(model["name"])+" (sem estoque)")
    opts.append({"text":"Ouvir a história da família","action":"coffin_memory"})
    opts.append({"text":"Voltar depois / repor no Empório","action":"close"})
    var note := "\nSem estoque: "+", ".join(available) if not available.is_empty() else ""
    var memory: Dictionary = FUNERAL_LORE.story("case_%d" % case_id)
    opts.push_front({"text":"Abrir revista ilustrada","action":"magazine_offer"})
    game()._show_character(str(item["client"]),str(memory.get("family","Vamos comparar os modelos."))+"\n\nLimite fictício para o caixão: R$ %d. Apresente opções disponíveis e adequadas. A família confirma a escolha." % COFFINS.budget(case_id)+note,str(item["profile"]),opts,"sereno")

func coffin_memory() -> void:
    if not coffin_case_ready():
        return
    var item: Dictionary = CASES.active(case_index)
    var memory: Dictionary = FUNERAL_LORE.story("case_%d" % int(item["id"]))
    game()._show_character(str(item["client"]),str(memory.get("memory",""))+"\n\n"+str(memory.get("family","")),str(item["profile"]),[{"text":"Apresentar os modelos","action":"coffin_case_menu"},{"text":"Conversar depois","action":"close"}])

func coffin_advice() -> void:
    if room!="funeraria":
        return
    game()._show_character("Madame Amália Umbra","Pergunte sobre as lembranças da família, confira o orçamento e a disponibilidade. Um acabamento simples pode ser exatamente o que desejam. Se quiser mudar o modelo, volte à proposta antes de autorizar.","diretora",[{"text":"Consultar catálogo","action":"coffin_view"},{"text":"Fechar","action":"close"}],"alegre")

func coffin_ledger() -> void:
    if room!="office":
        return
    var lines: Array[String] = []
    for order in game().burial_queue.orders:
        var quote: Dictionary = order.get("coffin",COFFINS.legacy_snapshot())
        var label := "Incluído no atendimento anterior" if bool(quote.get("legacy",true)) else "R$ %d | custo de referência R$ %d" % [int(quote.get("price",0)),int(quote.get("cost",0))]
        var status := "Concluído" if bool(order.get("finished",false)) else "Agendado"
        lines.append("%s | %s | %s | %s" % [order["plot"],quote.get("name","Serenidade"),label,status])
    var body := "Chefe, eu sou transparente, mas a receita não pode ser invisível! Aqui estão os modelos autorizados e seus valores. Nenhuma nova cobrança é feita nesta consulta."
    body += "\n\n"+("Nenhuma ordem registrada." if lines.is_empty() else "\n".join(lines))
    game()._show("Baltazar | Livro dos caixões",body,[{"text":"Fechar","action":"close"}])

func select_coffin(model: String) -> void:
    if not coffin_case_ready():
        return
    var item: Dictionary = CASES.active(case_index)
    var case_id := int(item["id"])
    sync_coffin_stock()
    if not COFFINS.permitted(case_id,model) or int(coffin_stock.get(model,0))<=0:
        coffin_case_menu()
        return
    coffin_selection = {"case_id":case_id,"model":model}
    game()._save_game()
    finish_case()

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
    sync_coffin_stock()
    if not needed.is_empty():
        if int(inventory.get(needed,0)) <= 0:
            game()._show("Estoque insuficiente","Precisamos de um(a) "+needed+". Va ao Emporio e compre suprimentos antes de concluir.",[{"text":"Entendi","action":"close"}])
            return
    if burial_required:
        var model := str(coffin_selection.get("model",""))
        if int(coffin_selection.get("case_id",-1))!=int(item["id"]) or not COFFINS.permitted(int(item["id"]),model) or int(coffin_stock.get(model,0))<=0:
            coffin_case_menu()
            return
        var quote: Dictionary = COFFINS.snapshot(model)
        game()._show("Ordem de sepultamento", str(item["client"])+": "+FUNERAL_LORE.response(int(item["id"]),model)+"\n\nJazigo "+chosen_plot+". Modelo apresentado: %s, R$ %d. Confirme a concordância da família, a documentação e a autorização fictícias. O preço será registrado uma única vez após a conclusão." % [quote["name"],quote["price"]],[{"text":"Família confirma / autorizar","action":"case_authorize_burial"},{"text":"Rever modelo","action":"coffin_case_menu"},{"text":"Depois","action":"close"}])
        return
    if needed=="caixao":
        for model in COFFINS.MODELS:
            if take_coffin(str(model)):
                break
    elif not needed.is_empty():
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
    sync_coffin_stock()
    var model := str(coffin_selection.get("model",""))
    if int(coffin_selection.get("case_id",-1))!=int(item["id"]) or not COFFINS.permitted(int(item["id"]),model) or int(coffin_stock.get(model,0))<=0:
        coffin_case_menu()
        return
    var quote: Dictionary = COFFINS.snapshot(model)
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
        if game().burial_queue.enqueue(key,str(item["client"]),id,int(game().day),true,true,quote):
            take_coffin(model)
            coffin_selection.clear()
            pending_burial_id = key
            game()._save_game()
            game()._show("Servico agendado","Jazigo "+id+" reservado. "+str(quote["name"])+" separado para a cerimônia. Amália registra a escolha, Gervásio fornece o modelo, Baltazar confere a ordem e Anselmo aguarda na capela. A recompensa sera liberada somente apos o velorio e sepultamento. Visite a capela ao norte.",[{"text":"Ir ao cemiterio","action":"leave_room"}])
            return

func complete_burial(service_id: String) -> bool:
    if pending_burial_id.is_empty() or service_id!=pending_burial_id or not game().burial_queue.is_done(service_id):
        return false
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return false
    var sale := 0
    for order in game().burial_queue.orders:
        if str(order["id"])==service_id:
            var quote: Dictionary = order.get("coffin",COFFINS.legacy_snapshot())
            sale = maxi(0,int(quote.get("price",0)))
            break
    game().money += int(item["reward"])+sale
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
    if action.begins_with("urn_buy_"):
        buy_urn(action.trim_prefix("urn_buy_"))
        return true
    if action.begins_with("urn_select_"):
        select_urn(action.trim_prefix("urn_select_"))
        return true
    if action.begins_with("urn_confirm_"):
        confirm_urn(action.trim_prefix("urn_confirm_"))
        return true
    match action:
        "violeta_menu":
            violet_menu()
            return true
        "urn_browse":
            open_urn_magazine()
            return true
        "urn_shop":
            open_urn_magazine("shop")
            return true
        "urn_offer":
            open_urn_magazine("offer")
            return true
        "urn_revise":
            if room=="fornecedor" and str(cremation_referral.get("status",""))=="quoted":
                cremation_referral["status"]="referred"
                game()._save_game()
                open_urn_magazine("offer")
            return true
        "cremation_referral_menu":
            referral_menu()
            return true
        "cremation_refer":
            refer_cremation()
            return true
        "cremation_office":
            cremation_office()
            return true
        "cremation_review":
            if room=="office" and str(cremation_referral.get("status",""))=="quoted":
                cremation_referral["status"]="reviewed"
                game()._save_game()
                game()._show("Baltazar","Encaminhamento registrado. Cinério fará a triagem; nenhuma autorização foi emitida.",[{"text":"Ir ao crematório","action":"leave_room"}])
            return true
        "cremation_triage":
            cremation_triage()
            return true
        "cremation_wait":
            if room=="crematorio" and str(cremation_referral.get("status",""))=="reviewed":
                cremation_referral["status"]="waiting"
                game()._save_game()
                game()._show("Seu Cinério Brasa","Pedido registrado. A execução ficará bloqueada até a futura etapa de autorização e operação. Nenhum valor foi cobrado.",[{"text":"Voltar ao expediente","action":"close"}])
            return true
    if action.begins_with("coffin_buy_"):
        buy_coffin(action.trim_prefix("coffin_buy_"))
        return true
    if action.begins_with("coffin_select_"):
        select_coffin(action.trim_prefix("coffin_select_"))
        return true
    match action:
        "magazine_amalia":
            if room=="funeraria":
                sync_coffin_stock()
                game().open_magazine(MAGAZINE.pages(coffin_stock),"Madame Amália • Atendimento com respeito","browse",1)
            return true
        "magazine_offer":
            if coffin_case_ready():
                sync_coffin_stock()
                var item: Dictionary = CASES.active(case_index)
                var id := int(item["id"])
                game().open_magazine(MAGAZINE.pages(coffin_stock,id,"offer"),str(item["client"])+" • Limite R$ %d" % COFFINS.budget(id),"offer",2)
            return true
        "magazine_shop":
            if room=="fornecedor":
                sync_coffin_stock()
                game().open_magazine(MAGAZINE.pages(coffin_stock,0,"shop",int(game().money)),"Gervásio • Caixa R$ %d" % int(game().money),"shop",2)
            return true
        "coffin_shop":
            coffin_shop()
            return true
        "coffin_shop_back":
            if room=="fornecedor":
                stock_menu()
            return true
        "coffin_view":
            coffin_view()
            return true
        "coffin_case_menu":
            coffin_case_menu()
            return true
        "coffin_memory":
            coffin_memory()
            return true
        "coffin_advice":
            coffin_advice()
            return true
        "coffin_ledger":
            coffin_ledger()
            return true
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
            game()._show(str(order["customer"]),WAKE.farewell_text(order),[{"text":"Respeitar o momento de despedida","action":"wake_farewell"},{"text":"Voltar","action":"close"}])
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
            message = "Temos uma cerimônia organizada com "+str(order["customer"])+". O modelo autorizado já está registrado. Vamos preservar a vontade da família.\n"+WAKE.requests(order)+"\nPreparativos: %d/5." % WAKE.matches(order)
    game()._show("Sr. Anselmo Velario",message,[{"text":"Como organizar uma cerimonia?","action":"chapel_guide"},{"text":"Ate logo","action":"close"}])

func chapel_visitor() -> void:
    var lines := ["Meu Astolfo sempre dizia que descansaria quando morresse. Conhecendo aquele homem, deve estar dormindo ate agora.","Se encontrar um fantasma de gravata xadrez, diga que ainda estou esperando meus vinte reais.","Trouxe crisantemos para Astolfo. O jovem Anselmo tem muito bom gosto, so precisa aprender a sorrir."]
    game()._show("Dona Eudoxia Crisantemo",lines[randi_range(0,lines.size()-1)],[{"text":"Ate logo, Dona Eudoxia","action":"close"}])
