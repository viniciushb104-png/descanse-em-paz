extends CharacterBody2D
## Jogador sempre visivel: sprite como no dedicado, nao desenhado no _draw
## junto com o mapa. O anel nos pes indica o controle do personagem.
const SPEED := 205.0
const MAX_STEP := 4.0
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
    if bool(get_parent().get("dialogue_open")) or bool(get_parent().get_node("RoomsRuntime").get("changing")):
        direction = Vector2.ZERO
    direction = direction.normalized()
    walking = direction.length_squared() > 0.0
    if walking:
        facing = (2 if direction.x > 0.0 else 1) if absf(direction.x) > absf(direction.y) else (0 if direction.y > 0.0 else 3)
        walk_clock += delta
    else:
        walk_clock = 0.0
    var previous := global_position
    var world: Node = get_parent()
    if direction!=Vector2.ZERO:
        if not bool(world.call("can_player_stand",global_position)):
            global_position=world.call("nearest_safe_position",global_position)
        global_position=resolve_motion(global_position,direction*SPEED*delta)
    velocity=(global_position-previous)/maxf(delta,0.0001)
    walking=global_position.distance_to(previous)>0.1
    character_sprite.region_rect = FRAMES[facing][(1 + int(walk_clock * 7.0) % 2) if walking else 0]
    queue_redraw()

## Movimento em subpassos: cantos nao engolem o personagem; desliza ao longo da parede.
func resolve_motion(start: Vector2, motion: Vector2) -> Vector2:
    var world: Node = get_parent()
    var steps := maxi(1,ceili(motion.length()/MAX_STEP))
    var step := motion/float(steps)
    var p := start
    for i in range(steps):
        if bool(world.call("can_player_stand",p+step)):
            p+=step
        else:
            var x_step := Vector2(step.x,0)
            var y_step := Vector2(0,step.y)
            if bool(world.call("can_player_stand",p+x_step)):
                p+=x_step
            if bool(world.call("can_player_stand",p+y_step)):
                p+=y_step
    return p

func _draw() -> void:
    draw_ellipse_shadow()
    draw_arc(Vector2(0, 0), 13.0, 0.0, TAU, 24, Color("#f0cb6d",0.65), 1.5)

func draw_ellipse_shadow() -> void:
    draw_circle(Vector2(0, 4), 13.0, Color(0.12, 0.10, 0.13, 0.35))
