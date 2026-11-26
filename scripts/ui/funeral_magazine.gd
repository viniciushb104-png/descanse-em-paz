extends Control
signal action_requested(action: String)
signal close_requested
const FRAME = preload("res://assets/ui/funeral_magazine/frame.svg")
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

func setup(data: Array, header: String, kind: String, first: int) -> void:
    pages = data
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
    var brand := _label("A ETERNIDADE EM DETALHES",25)
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(brand)
    top.add_child(_button("Fechar",func(): close_requested.emit()))
    var tabs := HBoxContainer.new()
    root.add_child(tabs)
    for data in [["Capa",0],["Caixões",2],["Urnas",14],["Serviços",26]]:
        tabs.add_child(_button(str(data[0]),go.bind(int(data[1]))))
    var context_label := _label(context,17)
    context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(context_label)
    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation",14)
    root.add_child(body)
    var visual := Panel.new()
    visual.custom_minimum_size = Vector2(260,200)
    visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(visual)
    var frame := TextureRect.new()
    frame.texture = FRAME
    frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    frame.stretch_mode = TextureRect.STRETCH_SCALE
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
    section = _label("",17)
    info.add_child(section)
    heading = _label("",28)
    heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(heading)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    info.add_child(scroll)
    details = _label("",20)
    details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(details)
    notice = _label("",16)
    notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(notice)
    select_button = _button("Apresentar à família",_select)
    info.add_child(select_button)
    if mode=="offer":
        info.add_child(_button("Ouvir a história da família",func(): action_requested.emit("coffin_memory")))
    var foot := HBoxContainer.new()
    root.add_child(foot)
    previous = _button("Anterior",func(): go(index-1))
    following = _button("Próxima",func(): go(index+1))
    counter = _label("",18)
    counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    foot.add_child(previous)
    foot.add_child(counter)
    foot.add_child(following)
    go(index)

func _label(value: String, font_size: int) -> Label:
    var node := Label.new()
    node.text = value
    node.add_theme_font_size_override("font_size",font_size)
    node.add_theme_color_override("font_color",Color("#ead8b7"))
    return node

func _button(value: String, handler: Callable) -> Button:
    var node := Button.new()
    node.text = value
    node.custom_minimum_size = Vector2(0,44)
    node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    node.add_theme_font_size_override("font_size",18)
    node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
    index = clampi(next,0,pages.size()-1)
    if not is_instance_valid(heading):
        return
    var item: Dictionary = pages[index]
    heading.text = str(item["title"])
    section.text = str(item["section"]).to_upper()
    details.text = str(item["body"])
    var path := str(item["art"])
    art.texture = load(path) as Texture2D if ResourceLoader.exists(path,"Texture2D") else null
    var reason := str(item.get("reason",""))
    notice.text = reason+("\n" if not reason.is_empty() else "")+("Ilustração provisória." if bool(item.get("preview",false)) else "")
    select_button.visible = mode!="browse" and section.text=="CAIXÕES"
    select_button.disabled = str(item.get("action","")).is_empty()
    select_button.text = "Comprar unidade" if mode=="shop" else "Apresentar à família"
    previous.disabled = index==0
    following.disabled = index==pages.size()-1
    counter.text = "%02d / %02d" % [index+1,pages.size()]

func _select() -> void:
    var action := str(pages[index].get("action",""))
    if not action.is_empty():
        action_requested.emit(action)

func keyboard(key: int) -> void:
    match key:
        KEY_ESCAPE: close_requested.emit()
        KEY_LEFT: go(index-1)
        KEY_RIGHT: go(index+1)
