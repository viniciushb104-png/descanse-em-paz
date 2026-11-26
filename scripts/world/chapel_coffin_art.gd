extends RefCounted
## Arte modular: base aberta, tampa independente, pessoa e borda frontal opcionais.
## Mantem proporcoes dos sprites e um encaixe comum para os doze modelos.
const COFFINS = preload("res://scripts/systems/coffin_catalog.gd")
const LORE = preload("res://scripts/systems/funeral_lore.gd")
const WAKE = preload("res://scripts/systems/wake_ceremony.gd")
const DIR := "res://assets/sprites/coffins/"
const OPEN = preload("res://assets/sprites/coffins/serenidade/aberto.png")
const LID = preload("res://assets/sprites/coffins/serenidade/tampa.png")
const OPEN_RECT := Rect2(528,235,94,184)
const BODY_RECT := Rect2(547,259,56,133)
const SOLID_RECT := Rect2(541,251,68,164)
const LID_BASE := Rect2(707,180,61,27)
const INTERACT_POINT := Vector2(575,435)

static func model_id(order: Dictionary) -> String:
    var quote: Dictionary = order.get("coffin",{})
    var id := str(quote.get("model",COFFINS.DEFAULT))
    return id if COFFINS.MODELS.has(id) else COFFINS.DEFAULT

static func optional_texture(path: String) -> Texture2D:
    if ResourceLoader.exists(path,"Texture2D"):
        return load(path) as Texture2D
    return null

static func model_texture(id: String, part: String) -> Texture2D:
    if id == COFFINS.DEFAULT:
        if part == "aberto":
            return OPEN
        if part == "tampa":
            return LID
    return optional_texture(DIR+id+"/"+part+".png")

static func fit(tex: Texture2D, area: Rect2) -> Rect2:
    var size := tex.get_size()
    var factor := minf(area.size.x/maxf(1.0,size.x),area.size.y/maxf(1.0,size.y))
    var fitted := size*factor
    return Rect2(area.get_center()-fitted*0.5,fitted)

static func paint(ctx: Node2D, order: Dictionary) -> void:
    var id := model_id(order)
    var base_tex := model_texture(id,"aberto")
    var lid_tex := model_texture(id,"tampa")
    var provisional := base_tex == null or lid_tex == null
    if base_tex == null:
        base_tex = OPEN
    if lid_tex == null:
        lid_tex = LID
    # Tampa apoiada junto a parede, entre os vitrais; desenho independente.
    ctx.draw_set_transform(Vector2(737,148),-0.10)
    ctx.draw_texture_rect(lid_tex,fit(lid_tex,Rect2(-32,-66,64,132)),false)
    ctx.draw_set_transform(Vector2.ZERO)
    # Base, futura pessoa homenageada e futuro recorte frontal em ordem fixa.
    ctx.draw_texture_rect(base_tex,fit(base_tex,OPEN_RECT),false)
    if not order.is_empty() and not WAKE.done(order):
        var story: Dictionary = LORE.story(str(order.get("id","")))
        var sprite_id := str(story.get("sprite",""))
        if not sprite_id.is_empty():
            var body := optional_texture("res://assets/sprites/funeral_people/"+sprite_id+".png")
            if body != null:
                ctx.draw_texture_rect(body,fit(body,BODY_RECT),false)
    var rim := model_texture(id,"borda_frontal")
    if rim != null:
        ctx.draw_texture_rect(rim,OPEN_RECT,false)
    if provisional and not order.is_empty():
        ctx.draw_string(ThemeDB.fallback_font,Vector2(641,220),"Arte provisoria: "+str(COFFINS.MODELS[id]["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#eadfd0"))
