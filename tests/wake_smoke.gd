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
