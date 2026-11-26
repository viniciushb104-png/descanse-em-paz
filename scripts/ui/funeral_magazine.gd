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
const ASSET_DIR := "res://assets/ui/funeral_magazine/"
var paper: TextureRect
var spread: TextureRect
var body: HBoxContainer
var tab_buttons: Array[Button] = []
var tab_indices: Array[int] = []
var page_tween: Tween
var transaction: Label
var display_book: Control

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
    var desk := TextureRect.new()
    desk.texture = _asset(ASSET_DIR+"duplas/mesa_de_leitura.webp",ASSET_DIR+"mesa_fallback.svg")
    desk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    desk.stretch_mode = TextureRect.STRETCH_SCALE
    desk.mouse_filter = Control.MOUSE_FILTER_IGNORE
    desk.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    add_child(desk)
    desk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var margin := MarginContainer.new()
    add_child(margin)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","right","top","bottom"]:
        margin.add_theme_constant_override("margin_"+side,14)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation",4)
    margin.add_child(root)
    var top := HBoxContainer.new()
    root.add_child(top)
    var brand := _label("MEMÓRIAS QUE PERMANECEM" if urn_book else "A ETERNIDADE EM DETALHES",23)
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(brand)
    var back_button := _button("Contracapa",_toggle_back)
    back_button.size_flags_horizontal = Control.SIZE_SHRINK_END
    back_button.custom_minimum_size.x = 150
    top.add_child(back_button)
    var close_button := _button("Fechar",func(): close_requested.emit())
    close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
    close_button.custom_minimum_size.x = 115
    top.add_child(close_button)
    var tabs := HBoxContainer.new()
    root.add_child(tabs)
    var sections := [["Capa",0,"cover"],["Urnas",2,"urns_tab"],["Serviços",14,"services_tab"],["Orçamento",15,"quote_tab"]] if urn_book else [["Capa",0,"cover"],["Amália",1,"cover"],["Caixões",2,"coffins_tab"],["Serviços",14,"services_tab"],["Orçamento",19,"quote_tab"]]
    for data in sections:
        var tab := _button(str(data[0]),go.bind(int(data[1])),"tab")
        tab_buttons.append(tab)
        tab_indices.append(int(data[1]))
        tabs.add_child(tab)
    var context_label := _label(context,17)
    context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(context_label)
    var book := Control.new()
    display_book = book
    book.size_flags_vertical = Control.SIZE_EXPAND_FILL
    book.custom_minimum_size.y = 230
    root.add_child(book)
    paper = TextureRect.new()
    paper.texture = preload("res://assets/ui/funeral_magazine/livro_fallback.svg")
    paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    paper.stretch_mode = TextureRect.STRETCH_SCALE
    paper.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    book.add_child(paper)
    paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    body = HBoxContainer.new()
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
    frame.visible = false
    frame.texture = null
    frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    visual.add_child(frame)
    frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art = TextureRect.new()
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
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
    # A arte dupla ocupa o livro inteiro, sem quadro nem texto duplicado.
    spread = TextureRect.new()
    spread.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    spread.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    spread.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    spread.mouse_filter = Control.MOUSE_FILTER_IGNORE
    book.add_child(spread)
    spread.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var status := HBoxContainer.new()
    root.add_child(status)
    transaction = _label("",17)
    transaction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status.add_child(transaction)
    notice.add_theme_color_override("font_color",Color("#f3d9b3"))
    notice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status.add_child(notice)
    var actions := HBoxContainer.new()
    root.add_child(actions)
    select_button = _button("Apresentar à família",_select)
    actions.add_child(select_button)
    editorial_button = _button("Ler texto / ampliar",_open_editorial)
    actions.add_child(editorial_button)
    if mode=="offer" and not urn_book:
        actions.add_child(_button("Ouvir a história da família",func(): action_requested.emit("coffin_memory")))
    var foot := HBoxContainer.new()
    root.add_child(foot)
    previous = _button("‹  Anterior",func(): go(index-1))
    following = _button("Próxima  ›",func(): go(index+1))
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
    node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _style_button(node,sprite=="tab",false)
    node.pressed.connect(handler)
    return node

func _asset(path: String, fallback: String = "") -> Texture2D:
    if not path.is_empty() and ResourceLoader.exists(path,"Texture2D"):
        return load(path) as Texture2D
    if not fallback.is_empty() and ResourceLoader.exists(fallback,"Texture2D"):
        return load(fallback) as Texture2D
    return null

func _plate(name: String) -> StyleBoxTexture:
    var style := StyleBoxTexture.new()
    style.texture = _asset(ASSET_DIR+"placa_"+name+".svg")
    style.set_texture_margin(SIDE_LEFT,34)
    style.set_texture_margin(SIDE_RIGHT,34)
    style.set_texture_margin(SIDE_TOP,12)
    style.set_texture_margin(SIDE_BOTTOM,12)
    style.content_margin_left = 20
    style.content_margin_right = 20
    style.content_margin_top = 7
    style.content_margin_bottom = 7
    return style

func _style_button(node: Button, tab: bool, active: bool) -> void:
    node.add_theme_stylebox_override("normal",_plate("tab_active" if active else ("tab" if tab else "normal")))
    node.add_theme_stylebox_override("hover",_plate("hover"))
    node.add_theme_stylebox_override("pressed",_plate("pressed"))
    node.add_theme_stylebox_override("disabled",_plate("disabled"))
    node.add_theme_color_override("font_color",Color("#4c252c") if tab and not active else Color("#f8e2b7"))
    node.add_theme_color_override("font_hover_color",Color("#fff0cb"))
    node.add_theme_color_override("font_pressed_color",Color("#fff0cb"))
    node.add_theme_color_override("font_disabled_color",Color("#b29b83"))

func _update_tabs() -> void:
    var active := 0
    for i in range(tab_indices.size()):
        if index>=tab_indices[i]:
            active=i
    for i in range(tab_buttons.size()):
        _style_button(tab_buttons[i],true,i==active and not back_visible)

func _page_transition() -> void:
    if DisplayServer.get_name()=="headless":
        return
    if is_instance_valid(page_tween):
        page_tween.kill()
    display_book.modulate.a = 0.72
    page_tween = create_tween()
    page_tween.tween_property(display_book,"modulate:a",1.0,0.18)

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
    art.texture = _asset(path)
    var full_spread := _asset(str(item.get("spread","")))
    if full_spread==null and index==0:
        full_spread = _asset(path)
    elif full_spread==null and bool(item.get("editorial",false)) and not bool(item.get("preview",true)):
        full_spread = _asset(path)
    spread.texture = full_spread
    spread.visible = full_spread!=null
    paper.visible = not spread.visible
    body.visible = not spread.visible
    transaction.text = str(item.get("transaction_line",""))
    transaction.visible = not transaction.text.is_empty()
    _update_tabs()
    _page_transition()
    var reason := str(item.get("reason",""))
    var editorial := bool(item.get("editorial",false))
    notice.text = reason+(" • " if not reason.is_empty() and bool(item.get("preview",false)) and not spread.visible else "")+("Arte provisória." if bool(item.get("preview",false)) and not spread.visible else "")
    notice.visible = not notice.text.is_empty()
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
    art.texture = null
    spread.texture = _asset(ASSET_DIR+"duplas/capa_fechada.webp",ASSET_DIR+"cover.svg") if not urn_book else _asset(str(pages[0]["art"]))
    spread.visible = true
    paper.visible = false
    body.visible = false
    transaction.visible = false
    notice.text = ""
    notice.visible = false
    _update_tabs()
    _page_transition()
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
    var image_texture := _asset(str(item.get("spread","")))
    if image_texture==null and not bool(item.get("preview",true)):
        image_texture = _asset(str(item["art"]))
    if image_texture!=null:
        var picture := TextureRect.new()
        picture.texture = image_texture
        picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        picture.custom_minimum_size = Vector2(0,640 if image_texture.get_width()>image_texture.get_height() else 1100)
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
