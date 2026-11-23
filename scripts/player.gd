extends CharacterBody2D
## Jogador sempre visivel: sprite como no dedicado, nao desenhado no _draw
## junto com o mapa. O anel nos pes indica o controle do personagem.
const SPEED := 205.0
const ATLAS: Texture2D = preload("res://assets/art/characters.png")
const FRAMES = [
    [Rect2(3, 3, 52, 85), Rect2(115, 3, 52, 85), Rect2(171, 3, 52, 85)],
    [Rect2(227, 3, 52, 85), Rect2(339, 3, 52, 85), Rect2(395, 3, 52, 85)],
    [Rect2(451, 3, 52, 85), Rect2(563, 3, 52, 85), Rect2(619, 3, 52, 85)],
    [Rect2(675, 3, 52, 85), Rect2(787, 3, 52, 85), Rect2(843, 3, 52, 85)]
]
var virtual_direction := Vector2.ZERO
var facing: int = 0
var walk_clock: float = 0.0
var walking: bool = false
var character_sprite: Sprite2D

func _ready() -> void:
    z_index = 15
    character_sprite = Sprite2D.new()
    character_sprite.name = "CharacterVisual"
    character_sprite.texture = ATLAS
    character_sprite.region_enabled = true
    character_sprite.region_rect = FRAMES[0][0]
    character_sprite.position = Vector2(0, -33)
    character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    character_sprite.centered = true
    character_sprite.z_index = 1
    add_child(character_sprite)
    queue_redraw()

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
    if bool(get_parent().get("dialogue_open")):
        direction = Vector2.ZERO
    direction = direction.normalized()
    walking = direction.length_squared() > 0.0
    if walking:
        facing = (2 if direction.x > 0.0 else 1) if absf(direction.x) > absf(direction.y) else (0 if direction.y > 0.0 else 3)
        walk_clock += delta
    else:
        walk_clock = 0.0
    velocity = direction * SPEED
    # Se um salvamento antigo estiver perto de uma parede, deixar sair:
    # bloquear somente movimentos para DENTRO de uma area invalida.
    var next_position := global_position + velocity * delta
    if not bool(get_parent().is_walkable(next_position)):
        if bool(get_parent().is_walkable(global_position)):
            velocity = Vector2.ZERO
        else:
            var safe := Vector2(748, 714)
            velocity = (safe - global_position).normalized() * SPEED
    move_and_slide()
    character_sprite.region_rect = FRAMES[facing][(1 + int(walk_clock * 7.0) % 2) if walking else 0]
    queue_redraw()

func _draw() -> void:
    draw_ellipse_shadow()
    draw_arc(Vector2(0, 0), 22.0, 0.0, TAU, 32, Color("#f0cb6d"), 2.5)

func draw_ellipse_shadow() -> void:
    draw_circle(Vector2(0, 4), 13.0, Color(0.12, 0.10, 0.13, 0.35))
