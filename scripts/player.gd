extends CharacterBody2D
## Protagonista de oito direcoes. Desenho provisório: sera substituido por sprites.

const SPEED: float = 210.0
const WORLD_SIZE := Vector2(1536.0, 960.0)
var virtual_direction := Vector2.ZERO

func _physics_process(_delta: float) -> void:
    var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if Input.is_key_pressed(KEY_A):
        direction.x -= 1.0
    if Input.is_key_pressed(KEY_D):
        direction.x += 1.0
    if Input.is_key_pressed(KEY_W):
        direction.y -= 1.0
    if Input.is_key_pressed(KEY_S):
        direction.y += 1.0
    if virtual_direction.length_squared() > 0.0:
        direction = virtual_direction
    if get_parent().get("dialogue_open"):
        direction = Vector2.ZERO
    velocity = direction.normalized() * SPEED
    move_and_slide()
    global_position = global_position.clamp(Vector2(60, 90), WORLD_SIZE - Vector2(60, 60))
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2(0, 14), 16, Color("#17241f"))
    draw_rect(Rect2(-13, 6, 10, 14), Color("#211b28"))
    draw_rect(Rect2(3, 6, 10, 14), Color("#211b28"))
    draw_rect(Rect2(-16, -14, 32, 24), Color("#463451"))
    draw_rect(Rect2(-13, -11, 26, 18), Color("#84518b"))
    draw_rect(Rect2(-14, -31, 28, 21), Color("#e4b99b"))
    draw_rect(Rect2(-15, -35, 30, 9), Color("#20182a"))
    draw_rect(Rect2(-8, -22, 4, 4), Color("#20182a"))
    draw_rect(Rect2(5, -22, 4, 4), Color("#20182a"))
