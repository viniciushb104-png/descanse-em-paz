extends Node
## Gerenciador de transicoes, casos humanos e estoque: estado preservado no save principal.
const CATALOG = preload("res://scripts/world/interior_catalog.gd")
const CASES = preload("res://scripts/systems/customer_cases.gd")
const LEGAL = preload("res://scripts/systems/legal_lessons.gd")
var room: String = ""
var return_point := Vector2(748,714)
var case_index: int = 0
var inventory: Dictionary = {"caixao":2,"urna":1}
var skip_entry: bool = false

func game() -> Node2D:
    return get_parent() as Node2D

func inside() -> bool:
    return not room.is_empty()

func save_state(cfg: ConfigFile) -> void:
    cfg.set_value("save","current_room",room)
    cfg.set_value("save","return_point",return_point)
    cfg.set_value("save","case_index",case_index)
    cfg.set_value("save","stock",inventory)

func load_state(cfg: ConfigFile) -> void:
    room = str(cfg.get_value("save","current_room",""))
    if not CATALOG.ROOMS.has(room):
        room = ""
    return_point = cfg.get_value("save","return_point",Vector2(748,714))
    case_index = clampi(int(cfg.get_value("save","case_index",0)),0,CASES.total())
    inventory = cfg.get_value("save","stock",{"caixao":2,"urna":1})
    for product in ["caixao","urna"]:
        inventory[product] = maxi(0,int(inventory.get(product,0)))

func apply_room() -> void:
    for item in ["GroundLayer","TreeLayer","PropsLayer","GravesLayer","DistrictLayer"]:
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
        camera.limit_right = 3072
        camera.limit_bottom = 1408
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
        if d < distance:
            distance=d
            found=s
    return found

func walkable(pos: Vector2) -> bool:
    # Limites permitem acessar a porta e atravessar o corredor ate o atendente.
    return pos.x >= 65.0 and pos.x <= 1088.0 and pos.y >= 164.0 and pos.y <= 575.0

func safe_spawn() -> Vector2:
    return CATALOG.ENTRY if inside() else Vector2(748,714)

func offer_entry(id: String) -> bool:
    if inside() or skip_entry or not CATALOG.ROOMS.has(id):
        return false
    var options: Array = [{"text":"Entrar e explorar o interior","action":"enter_"+id}]
    if id not in ["funeraria","fornecedor"]:
        options.append({"text":"Atendimento rapido na entrada","action":"outside_"+id})
    options.append({"text":"Voltar","action":"close"})
    game()._show(str(CATALOG.ROOMS[id]["title"]),"A porta esta aberta. Aqui ha atendentes, clientes, catalogos e livros de ocorrencias.",options)
    return true

func enter(id: String) -> void:
    if not CATALOG.ROOMS.has(id) or inside():
        return
    return_point = game().player.global_position
    room = id
    game().player.global_position = CATALOG.ENTRY
    game().player.virtual_direction = Vector2.ZERO
    game().player.velocity = Vector2.ZERO
    apply_room()
    game()._save_game()
    game()._show(str(CATALOG.ROOMS[id]["title"]),str(CATALOG.ROOMS[id]["description"])+"\n\nAnde pela sala. E interage; a saida fica embaixo.",[{"text":"Explorar","action":"close"}])

func leave() -> void:
    if not inside():
        return
    room = ""
    game().player.global_position = return_point
    game().player.virtual_direction = Vector2.ZERO
    game().player.velocity = Vector2.ZERO
    apply_room()
    game()._save_game()
    game()._close()
    game()._refresh_ui()

func interact(id: String) -> void:
    match id:
        "exit":
            leave()
        "agent":
            if room == "fornecedor":
                stock_menu()
            elif room == "funeraria":
                game()._show("Madame Amalia Umbra","O cliente decide, nos orientamos. O unico empurrao permitido aqui e no carrinho de arquivos.",[{"text":"Ver fila de atendimentos","action":"case_board"},{"text":"Direitos do consumidor","action":"legal_valores"},{"text":"Fechar","action":"close"}])
            else:
                game()._interact(room)
        "client":
            show_case()
        "board":
            show_board()
        "catalog":
            if room == "fornecedor":
                stock_menu()
            elif room == "funeraria":
                game()._show("Catalogo Umbra","Caixoes: %d em estoque. Urnas cinerarias: %d. Escolhas opcionais devem ser explicadas e nunca impostas." % [int(inventory["caixao"]),int(inventory["urna"])],[{"text":"Consultar normas de consumo","action":"legal_valores"},{"text":"Fechar","action":"close"}])
            else:
                var lesson: String = "registro"
                match room:
                    "preparo": lesson="preparo"
                    "crematorio": lesson="cremacao"
                    "garagem": lesson="transporte"
                    "fiscalizacao": lesson="ambiente"
                    "biblioteca": lesson="residuos"
                game()._show("Balcao de orientacao",str(CATALOG.ROOMS[room]["description"]),[{"text":"Consultar referencia","action":"legal_"+lesson},{"text":"Fechar","action":"close"}])

func show_board() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        game()._show("Livro de ocorrencias","Todos os 20 casos foram concluidos. Santa Mortalha agradece seu cuidado.",[{"text":"Fechar","action":"close"}])
        return
    game()._show("Atendimento %02d / %02d" % [case_index+1,CASES.total()],
        str(item["client"])+" ("+str(item["profile"])+").\nLocal: "+str(CATALOG.ROOMS[item["room"]]["title"])+"\n"+str(item["context"]),
        [{"text":"Fechar","action":"close"}])

func show_case() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        show_board()
        return
    if str(item["room"]) != room:
        game()._show("Sala de espera","O proximo cliente aguarda em: "+str(CATALOG.ROOMS[item["room"]]["title"])+".",[{"text":"Fechar","action":"close"}])
        return
    game()._show(str(item["client"])+" | Caso %02d" % (case_index+1),
        str(item["context"])+"\n\nQual e a conduta adequada?",
        [{"text":str(item["best"]),"action":"case_best"},{"text":str(item["bad"]),"action":"case_bad"},{"text":"Fechar","action":"close"}])

func stock_menu() -> void:
    game()._show("Gervasio Caixote - Emporio","Estoque: %d caixoes, %d urnas cinerarias. Valores ficticios de suprimentos. Comprar exige conferir procedencia, condicoes e nota fiscal." % [int(inventory["caixao"]),int(inventory["urna"])],
        [{"text":"Comprar 2 caixoes: R$ 240","action":"stock_caixao"},{"text":"Comprar 2 urnas: R$ 160","action":"stock_urna"},{"text":"Voltar","action":"close"}])

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
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        show_board()
        return
    if not inside() or room != str(item["room"]):
        game()._show("Local incorreto","Encontre a pessoa na sala indicada pelo livro de casos.",[{"text":"Voltar","action":"close"}])
        return
    var needed: String = str(item["stock"])
    if not needed.is_empty():
        if int(inventory.get(needed,0)) <= 0:
            game()._show("Estoque insuficiente","Precisamos de um(a) "+needed+". Va ao Emporio e compre suprimentos antes de concluir.",[{"text":"Entendi","action":"close"}])
            return
        inventory[needed] = int(inventory[needed])-1
    game().money += int(item["reward"])
    game().reputation = mini(100,game().reputation+3)
    game().compliance = mini(100,game().compliance+2)
    case_index += 1
    game()._save_game()
    update_client()
    game()._show("Atendimento concluido","O atendimento de "+str(item["client"])+" foi responsavel.\nCaixa ficticio: +R$ %d; reputacao +3; conformidade +2.\n\nFonte educativa: %s" % [int(item["reward"]),str(LEGAL.ITEMS[str(item["lesson"])]["source"])],
        [{"text":"Continuar","action":"close"}])
    game()._refresh_ui()

func reject_case() -> void:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return
    game().reputation = maxi(0,game().reputation-3)
    game().compliance = maxi(0,game().compliance-4)
    game()._save_game()
    game()._show("Conduta inadequada","Essa alternativa prejudica o cliente. O caso continua pendente.\n\n"+LEGAL.info(str(item["lesson"])),[{"text":"Tentar novamente","action":"close"}])

func handle_choice(action: String) -> bool:
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
        "case_best":
            finish_case()
            return true
        "case_bad":
            reject_case()
            return true
        "stock_caixao":
            purchase("caixao")
            return true
        "stock_urna":
            purchase("urna")
            return true
    return false

func objective() -> String:
    var item: Dictionary = CASES.active(case_index)
    if item.is_empty():
        return "Campanha completa: 20 casos atendidos!"
    return "Caso %02d/%02d: %s.\nLocal: %s" % [case_index+1,CASES.total(),str(item["client"]),str(CATALOG.ROOMS[item["room"]]["title"])]
