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

func _ready() -> void:
    position = HOME
    z_index = 12
    random.randomize()
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    set_process(true)

func _process(delta: float) -> void:
    var world := get_parent()
    visible = not bool(world.get_node("RoomsRuntime").call("inside"))
    if not visible:
        return
    animation_time += delta
    pet_time = maxf(0.0, pet_time - delta)
    if pet_time > 0.0 or bool(world.get("dialogue_open")):
        queue_redraw()
        return
    pause_left -= delta
    if pause_left <= 0.0:
        if global_position.distance_to(destination) > 5.0:
            var direction := (destination - global_position).normalized()
            var next_position := global_position + direction * SPEED * delta
            if bool(world.call("is_walkable", next_position)) and next_position.distance_to(HOME) < WANDER_RADIUS + 12.0:
                position = next_position
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
    queue_redraw()

func pet() -> void:
    pet_time = 2.3
    pause_left = 2.6
    destination = global_position
    meowed.emit()
    queue_redraw()

func _draw() -> void:
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
