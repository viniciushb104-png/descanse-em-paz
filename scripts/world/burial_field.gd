extends Node2D
## Campo de trabalho: interacao contextual, sem CanvasLayer de minigame.
const GRAVES = [preload("res://assets/props/covas/Cova_01.png"),preload("res://assets/props/covas/Cova_02.png"),preload("res://assets/props/covas/Cova_03.png"),preload("res://assets/props/covas/Cova_04.png")]
const TOMB = preload("res://assets/props/tumulos/Tumulo_01.png")
const OLD_TOMBS = [preload("res://assets/props/tumulos/Tumulo_01.png"),preload("res://assets/props/tumulos/Tumulo_02.png"),preload("res://assets/props/tumulos/Tumulo_03.png"),preload("res://assets/props/tumulos/Tumulo_04.png"),preload("res://assets/props/tumulos/Tumulo_05.png"),preload("res://assets/props/tumulos/Tumulo_06.png")]
static func old_positions() -> Array[Vector2]:
    var result: Array[Vector2] = []
    for row in range(3):
        for col in range(5):
            result.append(Vector2(362+col*185,1560+row*228))
    return result
const TREE = preload("res://assets/trees/Arvore_01.png")
const LAMP = preload("res://assets/sprites/lantern.svg")
const FLOWERS = preload("res://assets/sprites/flowers.svg")
const PUMPKIN = preload("res://assets/sprites/pumpkin.svg")
const NPC = preload("res://assets/sprites/osvaldo_right_0.svg")
const NPC_MOVE = preload("res://assets/sprites/osvaldo_right_1.svg")
const NAMES := ["idle","raise","strike","effort","throw"]
var frames: Array[Texture2D] = []
var elapsed := -1.0
var target := ""
var order_id := ""
var landed := false
var origin := Vector2.ZERO
var worker := Vector2.ZERO
var active := false
var game: Node
var hd_count := 0

static func plots() -> Array[Dictionary]:
    var result: Array[Dictionary] = [{"id":"B-13","p":Vector2(1141,704)}]
    for row in range(3):
        for col in range(6):
            result.append({"id":"%s-%02d" % [["C","D","E"][row],col+1],"p":Vector2(270+col*185,1560+row*228)})
    return result

static func position_for(id: String) -> Vector2:
    for plot in plots():
        if plot["id"]==id:
            return plot["p"]
    return Vector2.ZERO

func _ready() -> void:
    game = get_parent()
    z_index = 10
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for key in NAMES:
        var path := "res://assets/sprites/osvaldo_dig/"+str(key)+".webp"
        var tex: Texture2D = NPC if key=="idle" else NPC_MOVE
        if ResourceLoader.exists(path):
            var art := load(path) as Texture2D
            if art != null:
                tex = art
                hd_count += 1
        frames.append(tex)
    queue_redraw()

func current() -> Dictionary:
    return game.burial_queue.pending()

func near(pos: Vector2) -> Dictionary:
    if not active:
        return {}
    var order := current()
    if order.is_empty():
        return {}
    var p := position_for(str(order["plot"]))
    if p != Vector2.ZERO and p.distance_to(pos)<112.0:
        return {"id":"field_dig","name":"Trabalhar jazigo "+str(order["plot"]),"p":p}
    return {}

func blocked(pos: Vector2) -> bool:
    for p in old_positions():
        if Rect2(p-Vector2(28,25),Vector2(56,50)).has_point(pos):
            return true
    for plot in plots():
        if plot["id"]!="B-13" and Rect2(plot["p"]-Vector2(40,34),Vector2(80,68)).has_point(pos):
            return true
    return false

func count_for(id: String) -> int:
    for order in game.burial_queue.orders:
        if str(order["plot"])==id:
            if bool(order["finished"]):
                return 7
            var progress: Dictionary = order["progress"]
            return clampi(int(progress.get("field_hits",0)),0,6)
    return 0

func begin() -> void:
    active = true
    queue_redraw()

func strike() -> void:
    if elapsed>=0.0 or not active:
        return
    var order := current()
    if order.is_empty():
        return
    var id := str(order["plot"])
    var p := position_for(id)
    if p==Vector2.ZERO or game.player.global_position.distance_to(p)>=112.0:
        return
    if count_for(id)>=6:
        game._on_choice("field_finish")
        return
    target = id
    order_id = str(order["id"])
    origin = game.player.global_position
    worker = p+Vector2(-49,23)
    elapsed = 0.0
    landed = false
    game.player.velocity = Vector2.ZERO
    game.player.virtual_direction = Vector2.ZERO
    game.player.set_physics_process(false)
    queue_redraw()

func _process(delta: float) -> void:
    visible = not game.rooms.inside()
    if elapsed<0.0:
        return
    elapsed += delta
    if elapsed>=0.46 and not landed:
        landed = true
        var order := current()
        if not order.is_empty() and str(order["id"])==order_id:
            var progress: Dictionary = order["progress"]
            progress["field_hits"] = mini(6,int(progress.get("field_hits",0))+1)
            game.burial_queue.update_progress(order_id,progress)
            game._save_game()
    if elapsed>=0.95:
        elapsed = -1.0
        game.player.set_physics_process(true)
        var hits := count_for(target)
        game._notify("Seu Osvaldo: "+("Pronto! Interaja para concluir." if hits==6 else "Mais uma pazada! %d/6" % hits),1.8)
    queue_redraw()

func _sprite(tex: Texture2D,p: Vector2,h: float) -> void:
    var w := h*float(tex.get_width())/maxf(1.0,float(tex.get_height()))
    draw_texture_rect(tex,Rect2(p.x-w/2,p.y-h,w,h),false)

func _draw() -> void:
    if game==null:
        return
    var old := old_positions()
    for i in range(old.size()):
        var p: Vector2 = old[i]
        _sprite(OLD_TOMBS[i%OLD_TOMBS.size()],p+Vector2(0,25),85.0)
        if i%3==0:
            _sprite(FLOWERS,p+Vector2(21,27),25.0)
        if i%4==0:
            _sprite(PUMPKIN,p+Vector2(-30,24),27.0)
    for row in range(3):
        var y := 1560.0+row*228.0
        draw_string(ThemeDB.fallback_font,Vector2(125,y-80),"QUADRA "+["C - LANTERNAS","D - SAUDADES","E - ETERNIDADE"][row],HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("#e4b875"))
        for x in [150.0,1370.0]:
            _sprite(LAMP,Vector2(x,y+70),95)
        _sprite(TREE,Vector2(1480,y+60),150)
    for plot in plots():
        var id := str(plot["id"])
        var p: Vector2 = plot["p"]
        var hits := count_for(id)
        if id!="B-13" or (hits>0 and hits<7):
            if hits==0:
                _sprite(GRAVES[0],p+Vector2(0,34),72.0)
            elif hits==7:
                _sprite(TOMB,p+Vector2(0,34),94)
                _sprite(FLOWERS,p+Vector2(32,35),23)
            else:
                draw_texture_rect(GRAVES[mini(3, floori(float(hits-1)*4.0/6.0))],Rect2(p-Vector2(46,42),Vector2(92,84)),false)
        if id!="B-13":
            draw_string(ThemeDB.fallback_font,p+Vector2(-25,-47),id,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#e4b875"))
        var order := current()
        if active and not order.is_empty() and str(order["plot"])==id:
            draw_circle(p+Vector2(0,-66),5.0,Color("#f5cb74"))
            draw_line(p+Vector2(0,-60),p+Vector2(0,-48),Color("#f5cb74"),2.0)
            draw_string(ThemeDB.fallback_font,p+Vector2(-40,65),"%d/6 PAZADAS" % mini(hits,6),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#f5cb74"))
    for x in range(180,1400,220):
        _sprite(PUMPKIN,Vector2(x,2220),38)
    if elapsed>=0.0 and frames.size()==5:
        var pose := 0 if elapsed<0.16 else (1 if elapsed<0.32 else (2 if elapsed<0.48 else (3 if elapsed<0.65 else (4 if elapsed<0.84 else 0))))
        var foot := origin.lerp(worker,clampf(elapsed/0.16,0.0,1.0))
        _sprite(frames[pose],foot,88.0 if pose!=1 else 108.0)
        if elapsed>=0.46 and elapsed<0.82:
            var t := (elapsed-0.46)/0.36
            for i in range(12):
                var p := position_for(target)+Vector2(float(i-5)*8*t,-sin(t*PI)*35-float(i%3)*5)
                draw_rect(Rect2(p,Vector2(5,5)),Color("#b37d4b"))
