extends SceneTree
const WAKE = preload("res://scripts/systems/wake_ceremony.gd")
const FIELD = preload("res://scripts/world/burial_field.gd")
const CATALOG = preload("res://scripts/world/interior_catalog.gd")
func _initialize() -> void:
    var order := {"id":"case_5","progress":{}}
    if WAKE.done(order) or WAKE.ready(order) or FIELD.north_plots().size()!=48 or not CATALOG.ROOMS.has("chapel"):
        quit(1)
        return
    var lore = preload("res://scripts/systems/funeral_lore.gd")
    if lore.STORIES.size()!=4 or not WAKE.requests(order).contains("Rosa") or not WAKE.farewell_text(order).contains("carta") or lore.response(1,"serenidade")==lore.response(1,"ultimo_suspiro") or not lore.story("field_unknown").is_empty():
        push_error("Memorias ou respostas funerarias invalidas")
        quit(4)
        return
    var art = preload("res://scripts/world/chapel_coffin_art.gd")
    if art.OPEN==null or art.LID==null or art.OPEN.get_image().get_pixel(0,0).a!=0.0 or art.LID.get_image().get_pixel(0,0).a!=0.0:
        push_error("Sprites do caixao ausentes ou sem transparencia")
        quit(5)
        return
    if not art.OPEN_RECT.encloses(art.BODY_RECT) or art.SOLID_RECT.has_point(art.INTERACT_POINT) or art.model_id({"coffin":{"model":"vesper"}})!="vesper":
        push_error("Encaixe modular ou interacao invalida")
        quit(6)
        return
    var ultimo_open: Texture2D = art.model_texture("ultimo_suspiro","aberto")
    var ultimo_lid: Texture2D = art.model_texture("ultimo_suspiro","tampa")
    if ultimo_open==null or ultimo_lid==null or ultimo_open.get_image().get_pixel(0,0).a!=0.0 or ultimo_lid.get_image().get_pixel(0,0).a!=0.0:
        push_error("Último Suspiro: sprites transparentes ausentes")
        quit(13)
        return
    if art.model_id({"coffin":{"model":"ultimo_suspiro"}})!="ultimo_suspiro" or not art.OPEN_RECT.encloses(art.fit(ultimo_open,art.OPEN_RECT)):
        push_error("Último Suspiro: seleção ou encaixe inválido")
        quit(14)
        return
    var skin = preload("res://scripts/ui/funeral_magazine_skin.gd")
    if skin.REGIONS.size()!=19 or skin.texture("book")==null or skin.texture("cover")==null or skin.texture("back")==null:
        push_error("Prancha modular da revista ausente")
        quit(9)
        return
    var magazine = preload("res://scripts/systems/funeral_magazine_data.gd")
    var pages: Array = magazine.pages({"serenidade":1},5,"offer")
    if pages.size()!=20 or str(pages[2]["action"])!="coffin_select_serenidade" or not str(pages[3]["action"]).is_empty() or not str(pages[15].get("action","")).is_empty():
        push_error("Revista ou filtro de orçamento inválido")
        quit(7)
        return
    if not bool(pages[1].get("editorial",false)) or not str(pages[1]["body"]).contains("Luxo sem sentido") or not str(pages[1].get("action","")).is_empty():
        push_error("Página editorial de Amália inválida")
        quit(11)
        return
    var shop: Array = magazine.pages({"serenidade":1},0,"shop",180)
    if not bool(pages[2].get("editorial",false)) or not str(pages[2]["body"]).contains("Venda: R$ 300") or not str(shop[2]["body"]).contains("Aquisição: R$ 180") or bool(shop[2].get("editorial",false)) or str(shop[2]["action"])!="coffin_buy_serenidade":
        push_error("Página 03 ou separação de preços inválida")
        quit(12)
        return
    var offer_ultimo: Array = magazine.pages({"ultimo_suspiro":1},1,"offer")
    var shop_ultimo: Array = magazine.pages({"ultimo_suspiro":1},0,"shop",240)
    if str(offer_ultimo[3].get("action",""))!="coffin_select_ultimo_suspiro" or not ResourceLoader.exists(str(offer_ultimo[3].get("spread","")),"Texture2D") or str(shop_ultimo[3].get("action",""))!="coffin_buy_ultimo_suspiro" or not str(shop_ultimo[3].get("spread","")).is_empty():
        push_error("Último Suspiro: página comercial ou preços inválidos")
        quit(15)
        return
    var descanso_open: Texture2D = art.model_texture("descanso_eterno","aberto")
    var descanso_lid: Texture2D = art.model_texture("descanso_eterno","tampa")
    if descanso_open==null or descanso_lid==null or descanso_open.get_image().get_pixel(0,0).a!=0.0 or descanso_lid.get_image().get_pixel(0,0).a!=0.0:
        push_error("Descanso Eterno: sprites transparentes ausentes")
        quit(16)
        return
    if art.model_id({"coffin":{"model":"descanso_eterno"}})!="descanso_eterno" or not art.OPEN_RECT.encloses(art.fit(descanso_open,art.OPEN_RECT)):
        push_error("Descanso Eterno: seleção ou encaixe inválido")
        quit(17)
        return
    var offer_descanso: Array = magazine.pages({"descanso_eterno":1},16,"offer")
    var blocked_descanso: Array = magazine.pages({"descanso_eterno":1},1,"offer")
    var shop_descanso: Array = magazine.pages({"descanso_eterno":1},0,"shop",320)
    if str(offer_descanso[4].get("action",""))!="coffin_select_descanso_eterno" or not ResourceLoader.exists(str(offer_descanso[4].get("spread","")),"Texture2D") or not str(blocked_descanso[4].get("action","")).is_empty() or str(shop_descanso[4].get("action",""))!="coffin_buy_descanso_eterno" or not str(shop_descanso[4].get("spread","")).is_empty():
        push_error("Descanso Eterno: catálogo, estoque ou orçamento inválido")
        quit(18)
        return
    var verified_models: Array = [{"id":"lirio_branco","page":5,"cost":380,"price":650},{"id":"rosa_da_saudade","page":6,"cost":450,"price":790},{"id":"memorias","page":7,"cost":520,"price":900}]
    # Permitir os uploads artísticos em commits separados, sem quebrar a versão publicada.
    if ResourceLoader.exists("res://assets/sprites/coffins/vesper/aberto.png","Texture2D") and ResourceLoader.exists("res://assets/sprites/coffins/vesper/tampa.png","Texture2D") and ResourceLoader.exists("res://assets/ui/funeral_magazine/duplas/vesper_dupla.webp","Texture2D"):
        verified_models.append({"id":"vesper","page":8,"cost":600,"price":1050})
    for model in verified_models:
        var model_id: String = str(model["id"])
        var page_index: int = int(model["page"])
        var opened: Texture2D = art.model_texture(model_id,"aberto")
        var lid: Texture2D = art.model_texture(model_id,"tampa")
        if opened==null or lid==null or opened.get_image().get_pixel(0,0).a!=0.0 or lid.get_image().get_pixel(0,0).a!=0.0:
            push_error("Sprites transparentes ausentes: "+model_id)
            quit(19)
            return
        if art.model_id({"coffin":{"model":model_id}})!=model_id or not art.OPEN_RECT.encloses(art.fit(opened,art.OPEN_RECT)):
            push_error("Seleção ou encaixe inválido: "+model_id)
            quit(20)
            return
        var stock: Dictionary = {}
        stock[model_id] = 1
        var eligible: Array = magazine.pages(stock,16,"offer")
        var blocked: Array = magazine.pages(stock,1,"offer")
        var supplier: Array = magazine.pages(stock,0,"shop",int(model["cost"]))
        var no_stock: Array = magazine.pages({},16,"offer")
        if str(eligible[page_index].get("action",""))!="coffin_select_"+model_id or not ResourceLoader.exists(str(eligible[page_index].get("spread","")),"Texture2D") or not str(blocked[page_index].get("action","")).is_empty() or not str(no_stock[page_index].get("action","")).is_empty() or str(supplier[page_index].get("action",""))!="coffin_buy_"+model_id or not str(supplier[page_index].get("spread","")).is_empty() or not str(eligible[page_index]["body"]).contains("Venda: R$ %d" % int(model["price"])):
            push_error("Catálogo, preço ou orçamento inválido: "+model_id)
            quit(21)
            return
    var urns = preload("res://scripts/systems/urn_catalog.gd")
    var urn_pages: Array = magazine.urn_pages({"essencia":1,"legado":1},"offer")
    if urn_pages.size()!=16 or urn_pages[2].get("action","")!="urn_select_essencia" or not str(urn_pages[13].get("action","")).is_empty() or urns.normalize({},3).get("essencia")!=3:
        push_error("Catálogo de urnas ou orçamento inválido")
        quit(10)
        return
    for page in pages+urn_pages:
        if not ResourceLoader.exists(str(page["art"]),"Texture2D"):
            push_error("Arte da revista ausente: "+str(page["art"]))
            quit(8)
            return
    var state := WAKE.new_state()
    var wanted: Array = WAKE.profile("case_5")["values"]
    for i in range(WAKE.KEYS.size()):
        state["choices"][WAKE.KEYS[i]]=wanted[i]
    order["progress"]["wake"]=state
    if not WAKE.ready(order) or WAKE.done(order):
        quit(2)
        return
    state["received"]=true
    state["farewell"]=true
    state["done"]=true
    if not WAKE.done(order):
        quit(3)
        return
    print("WAKE OK: preferences, chapel, 48 north plots")
    quit(0)
