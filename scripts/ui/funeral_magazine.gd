extends Control
signal action_requested(action: String)
signal close_requested
const SKIN = preload("res://scripts/ui/funeral_magazine_skin.gd")
var back_visible := false
var urn_book := false
var pages: Array = []
var context := ""
var mode := "browse"
var index := 0
var art: TextureRect
var heading: Label
var details: Label
var counter: Label
var select_button: Button
var previous: Button
var following: Button
var notice: Label
var section: Label
var editorial_button: Button
var editorial_overlay: ColorRect

func setup(data: Array, header: String, kind: String, first: int) -> void:
    pages = data
    urn_book = not pages.is_empty() and str(pages[0].get("book",""))=="urns"
    context = header
    mode = kind
    index = clampi(first,0,maxi(0,pages.size()-1))

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var backdrop := ColorRect.new()
    backdrop.color = Color("#211829")
    add_child(backdrop)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var margin := MarginContainer.new()
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","right","top","bottom"]:
        margin.add_theme_constant_override("margin_"+side,14)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation",8)
    margin.add_child(root)
    var top := HBoxContainer.new()
    root.add_child(top)
    var brand := _label("MEMÓRIAS QUE PERMANECEM" if urn_book else "A ETERNIDADE EM DETALHES",25)
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(brand)
    top.add_child(_button("Contracapa",_toggle_back,"back"))
    top.add_child(_button("Fechar",func(): close_requested.emit()))
    var tabs := HBoxContainer.new()
    root.add_child(tabs)
    var sections := [["Capa",0,"cover"],["Urnas",2,"urns_tab"],["Serviços",14,"services_tab"],["Orçamento",15,"quote_tab"]] if urn_book else [["Capa",0,"cover"],["Amália",1,"cover"],["Caixões",2,"coffins_tab"],["Serviços",14,"services_tab"],["Orçamento",19,"quote_tab"]]
    for data in sections:
        tabs.add_child(_button(str(data[0]),go.bind(int(data[1])),str(data[2])))
    var context_label := _label(context,17)
    context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(context_label)
    var book := Control.new()
    book.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(book)
    var paper := TextureRect.new()
    paper.texture = SKIN.texture("book")
    paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    paper.stretch_mode = TextureRect.STRETCH_SCALE
    paper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    book.add_child(paper)
    paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var body := HBoxContainer.new()
    body.add_theme_constant_override("separation",54)
    book.add_child(body)
    body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    body.offset_left = 58
    body.offset_right = -58
    body.offset_top = 37
    body.offset_bottom = -38
    var visual := Control.new()
    visual.custom_minimum_size = Vector2(260,200)
    visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(visual)
    var frame := TextureRect.new()
    frame.texture = SKIN.texture("frame")
    frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    visual.add_child(frame)
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art = TextureRect.new()
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    visual.add_child(art)
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art.offset_left=16
    art.offset_right=-16
    art.offset_top=16
    art.offset_bottom=-16
    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(info)
    section = _label("",17,true)
    info.add_child(section)
    heading = _label("",28,true)
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(heading)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    info.add_child(scroll)
    details = _label("",20,true)
    details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(details)
    notice = _label("",16,true)
    notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(notice)
    select_button = _button("Apresentar à família",_select)
    info.add_child(select_button)
    editorial_button = _button("Ler página completa",_open_editorial)
    info.add_child(editorial_button)
    if mode=="offer" and not urn_book:
        info.add_child(_button("Ouvir a história da família",func(): action_requested.emit("coffin_memory")))
    var foot := HBoxContainer.new()
    root.add_child(foot)
    previous = _button("Anterior",func(): go(index-1),"left")
    following = _button("Próxima",func(): go(index+1),"right")
    counter = _label("",18)
    counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    foot.add_child(previous)
    foot.add_child(counter)
    foot.add_child(following)
    go(index)

func _label(value: String, font_size: int, ink: bool = false) -> Label:
    var node := Label.new()
    node.text = value
    node.add_theme_font_size_override("font_size",font_size)
    node.add_theme_color_override("font_color",Color("#422b39") if ink else Color("#ead8b7"))
    return node

func _button(value: String, handler: Callable, sprite: String = "") -> Button:
    var node := Button.new()
    node.text = value
    node.custom_minimum_size = Vector2(0,44)
    node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    node.add_theme_font_size_override("font_size",18)
    node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if not sprite.is_empty():
        node.icon = SKIN.texture(sprite)
        node.add_theme_constant_override("icon_max_width",26)
        node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#493351")
    style.border_color = Color("#b89a66")
    style.set_border_width_all(2)
    style.set_corner_radius_all(6)
    node.add_theme_stylebox_override("normal",style)
    node.pressed.connect(handler)
    return node

func go(next: int) -> void:
    if pages.is_empty():
        return
    _close_editorial()
    back_visible = false
    index = clampi(next,0,pages.size()-1)
    if not is_instance_valid(heading):
        return
    var item: Dictionary = pages[index]
    heading.text = str(item["title"])
    section.text = str(item["section"]).to_upper()
    details.text = str(item["body"])
    var path := str(item["art"])
    art.texture = SKIN.texture("cover") if index==0 and not urn_book else (load(path) as Texture2D if ResourceLoader.exists(path,"Texture2D") else null)
    var reason := str(item.get("reason",""))
    var editorial := bool(item.get("editorial",false))
    notice.text = reason+("\n" if not reason.is_empty() else "")+("Prévia compacta; texto integral disponível." if editorial and bool(item.get("preview",false)) else ("Ilustração provisória." if bool(item.get("preview",false)) else ""))
    editorial_button.visible = editorial
    select_button.visible = mode!="browse" and section.text in ["CAIXÕES","URNAS"]
    select_button.disabled = str(item.get("action","")).is_empty()
    select_button.text = "Comprar unidade" if mode=="shop" else "Apresentar à família"
    previous.disabled = index==0
    following.disabled = index==pages.size()-1
    counter.text = "%02d / %02d" % [index+1,pages.size()]

func _toggle_back() -> void:
    if back_visible:
        go(index)
        return
    _close_editorial()
    back_visible = true
    editorial_button.visible = false
    heading.text = "Empório das Últimas Coisas" if urn_book else "Casa Funerária Umbra"
    section.text = "CONTRACAPA"
    details.text = "Santa Mortalha\nToda memória merece respeito.\nCatálogo de produtos e serviços funerários. Valores fictícios."
    art.texture = load(str(pages[0]["art"])) as Texture2D if urn_book else SKIN.texture("back")
    notice.text = ""
    select_button.visible = false
    previous.disabled = false
    following.disabled = false
    counter.text = "Contracapa"

func _open_editorial() -> void:
    if back_visible or not bool(pages[index].get("editorial",false)) or is_instance_valid(editorial_overlay):
        return
    editorial_overlay = ColorRect.new()
    editorial_overlay.color = Color("#211829")
    editorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(editorial_overlay)
    editorial_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var margin := MarginContainer.new()
    editorial_overlay.add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","right","top","bottom"]:
        margin.add_theme_constant_override("margin_"+side,16)
    var column := VBoxContainer.new()
    margin.add_child(column)
    var header := _label("PÁGINA %02d — %s" % [index+1,str(pages[index]["title"]).to_upper()],25)
    column.add_child(header)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    column.add_child(scroll)
    var content := VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(content)
    var item: Dictionary = pages[index]
    if not bool(item.get("preview",true)):
        var picture := TextureRect.new()
        picture.texture = load(str(item["art"])) as Texture2D
        picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        picture.custom_minimum_size = Vector2(0,1100)
        content.add_child(picture)
    var reading := _label(str(item["body"]),24)
    reading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    reading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(reading)
    column.add_child(_button("Voltar à revista",_close_editorial))

func _close_editorial() -> void:
    if is_instance_valid(editorial_overlay):
        remove_child(editorial_overlay)
        editorial_overlay.queue_free()
    editorial_overlay = null

func _select() -> void:
    if back_visible:
        return
    var action := str(pages[index].get("action",""))
    if not action.is_empty():
        action_requested.emit(action)

func keyboard(key: int) -> void:
    if is_instance_valid(editorial_overlay):
        if key==KEY_ESCAPE:
            _close_editorial()
        return
    match key:
        KEY_ESCAPE: close_requested.emit()
        KEY_LEFT: go(index-1)
        KEY_RIGHT: go(index+1)
