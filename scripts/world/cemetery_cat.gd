extends Node2D
## Gato do Jardim do Ultimo Suspiro. Nao fala; mia e aceita carinho.
## Desenho pixelado provisório independente, substituivel por sprites finais.
signal meowed
const HOME := Vector2(937.0, 739.0)
const SPEED := 27.0
const WANDER_RADIUS := 105.0
var destination := HOME
var pause_left := 1.5
var animation_time := 0.0
var pet_time := 0.0
var step_time := 0.0
var flip := false
var random := RandomNumberGenerator.new()
# Optional PNG art: until assets/cat is uploaded, procedural artwork remains visible.
const FRAME_COUNTS = {"idle":4, "sit":5, "walk_right":8, "walk_left":8, "meow":4, "pet":6, "purr":4, "sleep":4}
var frames: Dictionary = {}
var sprite: Sprite2D
var idle_seconds: float = 0.0
var active_anim: String = "idle"
var anim_elapsed: float = 0.0
var meow_time: float = 0.0

func _ready() -> void:
    position = HOME
    z_index = 12
    random.randomize()
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _load_frames()
    set_process(true)

func _load_frames() -> void:
    for anim in FRAME_COUNTS:
        var images: Array[Texture2D] = []
        for index in range(int(FRAME_COUNTS[anim])):
            var path := "res://assets/cat/%s_%02d.png" % [anim,index]
            if ResourceLoader.exists(path):
                var img := load(path) as Texture2D
                if img != null:
                    images.append(img)
        if images.size() == int(FRAME_COUNTS[anim]):
            frames[anim] = images
    if frames.size() < FRAME_COUNTS.size():
        _load_zip_frames()
    if not frames.is_empty():
        sprite = Sprite2D.new()
        sprite.name = "CatSprite"
        sprite.position = Vector2(0,-48)
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.centered = true
        add_child(sprite)

func _load_zip_frames() -> void:
    # Pacote integrado no GitHub, sem exigir 43 PNGs soltos.
    var zip_path := "res://assets/cat/gato_santa_mortalha_sprites.zip"
    if not FileAccess.file_exists(zip_path):
        return
    var reader := ZIPReader.new()
    if reader.open(zip_path) != OK:
        push_warning("Pacote de sprites do gato nao pode ser aberto.")
        return
    for anim in FRAME_COUNTS:
        if frames.has(anim):
            continue
        var images: Array[Texture2D] = []
        for index in range(int(FRAME_COUNTS[anim])):
            var name := "assets/cat/%s_%02d.png" % [anim, index]
            var bytes: PackedByteArray = reader.read_file(name)
            if bytes.is_empty():
                break
            var picture := Image.new()
            if picture.load_png_from_buffer(bytes) != OK:
                break
            images.append(ImageTexture.create_from_image(picture))
        if images.size() == int(FRAME_COUNTS[anim]):
            frames[anim] = images
    reader.close()

func _set_animation(anim: String) -> void:
    if active_anim != anim:
        active_anim = anim
        anim_elapsed = 0.0

func _update_sprite(delta: float) -> void:
    if sprite == null:
        return
    anim_elapsed += delta
    var chosen := active_anim
    if not frames.has(chosen):
        chosen = "idle"
    if not frames.has(chosen):
        sprite.visible = false
        return
    var images: Array = frames[chosen]
    sprite.visible = true
    var fps := 6.0 if chosen in ["walk_right","walk_left"] else 4.0
    var index := int(anim_elapsed * fps)
    if chosen in ["meow","pet","sit"]:
        index = mini(index, images.size()-1)
    else:
        index = index % images.size()
    sprite.texture = images[index]

func _process(delta: float) -> void:
    var world := get_parent()
    visible = not bool(world.get_node("RoomsRuntime").call("inside"))
    if not visible:
        return
    animation_time += delta
    meow_time = maxf(0.0,meow_time-delta)
    pet_time = maxf(0.0, pet_time - delta)
    if pet_time > 0.0:
        _set_animation("pet" if pet_time > 0.7 else "purr")
        _update_sprite(delta)
        queue_redraw()
        return
    if meow_time > 0.0:
        _set_animation("meow")
        _update_sprite(delta)
        queue_redraw()
        return
    if bool(world.get("dialogue_open")):
        _set_animation("idle")
        _update_sprite(delta)
        queue_redraw()
        return
    var moved := false
    pause_left -= delta
    if pause_left <= 0.0:
        if global_position.distance_to(destination) > 5.0:
            var direction := (destination - global_position).normalized()
            var next_position := global_position + direction * SPEED * delta
            if bool(world.call("is_walkable", next_position)) and next_position.distance_to(HOME) < WANDER_RADIUS + 12.0:
                position = next_position
                moved = true
                flip = direction.x < 0.0
                step_time += delta
            else:
                pause_left = random.randf_range(1.0, 3.0)
                destination = global_position
        else:
            pause_left = random.randf_range(1.4, 4.5)
            destination = HOME + Vector2(random.randf_range(-WANDER_RADIUS, WANDER_RADIUS), random.randf_range(-55.0, 55.0))
            if not bool(world.call("is_walkable", destination)):
                destination = HOME
    if moved:
        idle_seconds = 0.0
        _set_animation("walk_left" if flip else "walk_right")
    else:
        idle_seconds += delta
        _set_animation("sleep" if idle_seconds > 16.0 else ("sit" if idle_seconds > 6.0 else "idle"))
    _update_sprite(delta)
    queue_redraw()

func meow() -> void:
    meow_time = 1.0
    idle_seconds = 0.0
    _set_animation("meow")
    _update_sprite(0.0)

func pet() -> void:
    pet_time = 2.3
    meow_time = 0.0
    idle_seconds = 0.0
    _set_animation("pet")
    pause_left = 2.6
    destination = global_position
    meowed.emit()
    queue_redraw()

func _draw() -> void:
    if sprite != null and sprite.visible:
        draw_ellipse_shadow()
        return
    # O ponto de origem e o chao. Corpo pequeno, proporcao de gato frente ao jogador.
    draw_ellipse_shadow()
    var bob := 1.0 if int(step_time * 8.0) % 2 == 0 else 0.0
    if pet_time > 0.0:
        bob = 1.0 + sin(animation_time * 10.0) * 1.2
    var fur := Color("#26202c")
    var highlight := Color("#655267")
    var eyes := Color("#d8c16c")
    var nose := Color("#dca8b9")
    var side := -1.0 if flip else 1.0
    # Cauda alta em forma de gancho, corpo, patas, cabeca e orelhas.
    draw_rect(Rect2(-18 * side, -22 - bob, 5, 13),fur)
    draw_rect(Rect2(-20 * side, -24 - bob, 9, 5),fur)
    draw_rect(Rect2(-11, -19 - bob, 23, 14),fur)
    draw_rect(Rect2(-8, -8 - bob, 5, 8),fur)
    draw_rect(Rect2(6, -8 - bob, 5, 8),fur)
    draw_rect(Rect2(-12, -33 - bob, 24, 18),fur)
    draw_rect(Rect2(-12, -39 - bob, 8, 9),fur)
    draw_rect(Rect2(4, -39 - bob, 8, 9),fur)
    draw_rect(Rect2(-7, -28 - bob, 5, 4),eyes)
    draw_rect(Rect2(3, -28 - bob, 5, 4),eyes)
    draw_rect(Rect2(-1, -21 - bob, 3, 2),nose)
    draw_rect(Rect2(-9, -17 - bob, 16, 2),highlight)
    if pet_time > 0.0:
        draw_arc(Vector2(0,-42), 17.0, PI * 0.15, PI * 0.85, 10, Color("#e8b7ce"), 2.0)
        draw_circle(Vector2(18,-47), 3.0, Color("#efb3c7"))

func draw_ellipse_shadow() -> void:
    draw_rect(Rect2(-13, 1, 27, 4), Color(0.08, 0.06, 0.10, 0.35))
