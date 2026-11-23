extends CharacterBody2D
## Personagem jogavel em quatro direcoes, animacao 2 quadros e colisao simples.
const SPEED: float = 210.0
const WORLD_SIZE := Vector2(1536.0, 960.0)
const CHARACTER_ATLAS: Texture2D = preload("res://assets/art/characters.png")
# [parado, caminhada A, caminhada B] por direcao; recortes reais do concept.
const FRAMES = [
    [Rect2(3, 3, 52, 85), Rect2(115, 3, 52, 85), Rect2(171, 3, 52, 85)] # down,
    [Rect2(227, 3, 52, 85), Rect2(339, 3, 52, 85), Rect2(395, 3, 52, 85)] # left,
    [Rect2(451, 3, 52, 85), Rect2(563, 3, 52, 85), Rect2(619, 3, 52, 85)] # right,
    [Rect2(675, 3, 52, 85), Rect2(787, 3, 52, 85), Rect2(843, 3, 52, 85)] # up
]
var virtual_direction := Vector2.ZERO
var facing: int = 0
var walk_clock: float = 0.0
var walking: bool = false

func _physics_process(delta: float) -> void:
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
    direction = direction.normalized()
    walking = direction.length_squared() > 0.0
    if walking:
        if absf(direction.x) > absf(direction.y):
            facing = 2 if direction.x > 0 else 1
        else:
            facing = 0 if direction.y > 0 else 3
        walk_clock += delta
    else:
        walk_clock = 0.0
    velocity = direction * SPEED
    var next_position := global_position + velocity * delta
    if get_parent().has_method("is_walkable") and not get_parent().is_walkable(next_position):
        velocity = Vector2.ZERO
    move_and_slide()
    global_position = global_position.clamp(Vector2(65, 100), WORLD_SIZE - Vector2(65, 78))
    queue_redraw()

func _draw() -> void:
    var frame: int = 0 if not walking else 1 + (int(walk_clock * 7.0) % 2)
    draw_texture_rect_region(CHARACTER_ATLAS, Rect2(-28, -75, 56, 93), FRAMES[facing][frame], Color.WHITE, false, true)
