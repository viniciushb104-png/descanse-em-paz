extends Control
## Janela individual por personagem. Aceita PNG definitivo
## res://assets/portraits/<id>.png; usa busto proprio caso ainda nao exista.
const CHARACTERS = preload("res://scripts/ui/dialogue_characters.gd")
const EXPRESSIONS = preload("res://scripts/ui/portrait_expressions.gd")
var actor_name: String = ""
var profile: String = "calmo"
var identity: Dictionary = {}
var portrait_texture: Texture2D = null
var current_expression: String = ""
var embedded_frame: bool = false
var time_passed: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = true

func set_actor(speaker: String, mood: String = "", expression: String = "") -> void:
    actor_name = speaker
    identity = CHARACTERS.resolve(speaker)
    profile = mood if not mood.is_empty() else str(identity.get("profile","calmo"))
    var id: String = str(identity.get("id",""))
    current_expression = expression if not expression.is_empty() else "alegre"
    embedded_frame = EXPRESSIONS.has_actor(id) and EXPRESSIONS.has_frame(id)
    portrait_texture = EXPRESSIONS.texture(id,current_expression)
    if portrait_texture == null:
        var path: String = str(identity.get("portrait",""))
        if not path.is_empty() and ResourceLoader.exists(path):
            portrait_texture = load(path) as Texture2D
    time_passed = 0.0
    queue_redraw()

func _process(delta: float) -> void:
    if visible:
        time_passed += delta
        if time_passed >= 0.11:
            time_passed = 0.0
            queue_redraw()

func _draw() -> void:
    var w: float = size.x
    var h: float = size.y
    if w < 10.0 or h < 10.0:
        return
    var accent := Color(str(identity.get("accent","#b4a1cb")))
    var shade := Color(str(identity.get("shade","#42354b")))
    if not embedded_frame or portrait_texture == null:
        draw_rect(Rect2(0,0,w,h),shade.darkened(0.31))
        for j in range(6):
            draw_line(Vector2(0,float(j)*h/6.0),Vector2(w,float(j)*h/6.0),
                accent.darkened(0.47),1.0)
    if portrait_texture != null:
        var tex_size: Vector2 = portrait_texture.get_size()
        var margin: float = 0.0 if embedded_frame else 4.0
        var factor: float = minf((w-margin)/tex_size.x,(h-margin)/tex_size.y)
        var display_size: Vector2 = tex_size*factor
        draw_texture_rect(portrait_texture,
            Rect2((Vector2(w,h)-display_size)*0.5,display_size),false)
        return
    # Busto temporario estilizado e individual, sem reutilizar personagens errados.
    _bust(w,h,accent,shade)

func _bust(w: float,h: float,accent: Color,shade: Color) -> void:
    var center := Vector2(w*0.5,h*0.48)
    var id: String = str(identity.get("id",actor_name))
    var variant: int = posmod(id.hash(),5)
    var accessory: String = str(identity.get("accessory","none"))
    var ghost: bool = accessory == "ghost"
    var coat := shade.lightened(0.10 if ghost else 0.16)
    var skin := Color("#cba690") if variant==0 else Color("#e2beaa") if variant==1 else Color("#a9786b") if variant==2 else Color("#c5a083") if variant==3 else Color("#b68d7c")
    if ghost:
        skin = Color("#9ef0ef",0.84)
    # Cabelo: cada personagem tem contorno, corte e paleta proprios.
    var hair := Color("#302632") if variant%3==0 else Color("#64504c") if variant%3==1 else Color("#483749")
    var shoulder_y: float = h*0.72
    draw_colored_polygon(PackedVector2Array([
        Vector2(8,h),Vector2(16,shoulder_y+5),Vector2(w*0.35,shoulder_y-6),
        Vector2(w*0.65,shoulder_y-6),Vector2(w-16,shoulder_y+5),Vector2(w-8,h)]),coat)
    draw_rect(Rect2(w*0.46,shoulder_y-10,w*0.08,16),skin)
    var head_center: Vector2 = center-Vector2(0,h*0.09)
    draw_circle(head_center,27.0,skin)
    draw_colored_polygon(PackedVector2Array([
        head_center+Vector2(-27,-8),head_center+Vector2(-29,-29),
        head_center+Vector2(-15,-36),head_center+Vector2(10,-34),
        head_center+Vector2(28,-19),head_center+Vector2(23,-4),
        head_center+Vector2(17,-20),head_center+Vector2(-17,-24)]),hair)
    if variant==1 or variant==4:
        draw_line(head_center+Vector2(22,-19),head_center+Vector2(25,20),hair,6)
    var eye_y: float = head_center.y+1.0
    var blink: bool = fmod(time_passed*11.0 + float(posmod(id.hash(),13)),45.0)<0.11
    var eye_width: float = 8.0 if blink or profile=="sofredor" else 4.0
    draw_line(Vector2(head_center.x-16,eye_y),Vector2(head_center.x-16+eye_width,eye_y),Color("#251a28"),2.0)
    draw_line(Vector2(head_center.x+10,eye_y),Vector2(head_center.x+10+eye_width,eye_y),Color("#251a28"),2.0)
    if profile == "sofredor":
        draw_line(head_center+Vector2(14,8),head_center+Vector2(14,17),Color("#8cbcd2"),2)
    if profile in ["calmo","estranho","curioso","profissional","fornecedor"]:
        draw_arc(head_center+Vector2(0,12),5.5,0.12,PI-0.12,10,Color("#664754"),1.9)
    else:
        draw_line(head_center+Vector2(-5,15),head_center+Vector2(5,14),Color("#664754"),2.0)
    match accessory:
        "ghost":
            draw_arc(head_center+Vector2(-12,3),10.5,0,TAU,18,Color("#253949"),2.2)
            draw_arc(head_center+Vector2(12,3),10.5,0,TAU,18,Color("#253949"),2.2)
            draw_line(head_center+Vector2(-2,3),head_center+Vector2(2,3),Color("#253949"),2.0)
            draw_colored_polygon(PackedVector2Array([
                Vector2(w*0.43,shoulder_y+7),Vector2(w*0.5,shoulder_y+14),
                Vector2(w*0.57,shoulder_y+7),Vector2(w*0.5,shoulder_y+2)]),accent)
        "worker","driver","hat":
            draw_rect(Rect2(head_center.x-27,head_center.y-31,54,8),hair)
            draw_rect(Rect2(head_center.x-18,head_center.y-45,36,15),shade)
            if accessory=="worker":
                draw_arc(head_center+Vector2(0,18),16,0,PI,14,Color("#71503d"),3)
        "doctor":
            draw_line(Vector2(w*0.37,shoulder_y+6),Vector2(w*0.50,h-6),Color("#edf0ec"),5.0)
            draw_line(Vector2(w*0.63,shoulder_y+6),Vector2(w*0.50,h-6),Color("#edf0ec"),5.0)
            draw_arc(Vector2(w*0.56,shoulder_y+19),12,0,PI,16,Color("#4c6779"),2)
        "lady":
            draw_line(head_center+Vector2(-26,-15),head_center+Vector2(-32,31),accent,4)
            draw_line(head_center+Vector2(26,-15),head_center+Vector2(32,31),accent,4)
            draw_circle(Vector2(w*0.5,shoulder_y+12),4,accent)
        "scientist":
            draw_line(Vector2(w*0.35,shoulder_y+7),Vector2(w*0.51,h-6),Color("#dedbd4"),3.0)
            draw_line(Vector2(w*0.64,shoulder_y+7),Vector2(w*0.51,h-6),Color("#dedbd4"),3.0)
        "inspector","scholar","merchant","tie","gentleman":
            draw_colored_polygon(PackedVector2Array([
                Vector2(w*0.47,shoulder_y),Vector2(w*0.53,shoulder_y),
                Vector2(w*0.50,shoulder_y+27)]),accent)
        "spectacles","glasses":
            for offset in [-12.0,12.0]:
                draw_arc(head_center+Vector2(offset,3),10,0,TAU,16,accent,1.8)
            draw_line(head_center+Vector2(-2,3),head_center+Vector2(2,3),accent,1.8)
        "scarf":
            draw_line(Vector2(w*0.37,shoulder_y),Vector2(w*0.63,shoulder_y+7),accent,7)
        "hood":
            draw_arc(head_center,36,-PI,0,18,shade.darkened(0.25),7)
        "crematorio":
            draw_line(Vector2(w*0.40,shoulder_y+4),Vector2(w*0.60,shoulder_y+4),accent,6)
    # Detalhe de familia / profissao, sem texto no retrato (evita ilegibilidade).
    draw_rect(Rect2(7,h-10,w-14,4),accent)
