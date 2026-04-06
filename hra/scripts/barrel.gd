extends CharacterBody2D
class_name Barrel

const GRAVITY: float = 1400.0
const SPEED: float = 150.0
const DROP_ALIGN_SPEED: float = 220.0

var direction: int = -1
var anim_timer: float = 0.0
var game_ref: Node = null
var drop_ladder = null
var is_dropping: bool = false
var destroyed: bool = false

@onready var body_shape: CollisionShape2D = CollisionShape2D.new()
@onready var hitbox: Area2D = Area2D.new()
@onready var sprite: Sprite2D = Sprite2D.new()

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	add_to_group("barrel")
	body_shape.shape = RectangleShape2D.new()
	(body_shape.shape as RectangleShape2D).size = Vector2(22, 22)
	add_child(body_shape)

	hitbox.collision_layer = 2
	hitbox.collision_mask = 4
	hitbox.add_to_group("danger")
	var hb_shape: CollisionShape2D = CollisionShape2D.new()
	hb_shape.shape = RectangleShape2D.new()
	(hb_shape.shape as RectangleShape2D).size = Vector2(24, 24)
	hitbox.add_child(hb_shape)
	add_child(hitbox)

	sprite.texture = preload("res://assets/sprites/barrel_sheet.png")
	sprite.hframes = 4
	add_child(sprite)

func set_game(value: Node) -> void:
	game_ref = value

func smashed_by_player() -> void:
	if destroyed:
		return
	destroyed = true
	queue_free()

func _physics_process(delta: float) -> void:
	if destroyed:
		return

	anim_timer += delta

	if is_dropping and drop_ladder != null and is_instance_valid(drop_ladder):
		var target_x: float = float(drop_ladder.get("center_x"))
		global_position.x = move_toward(global_position.x, target_x, DROP_ALIGN_SPEED * delta)
		velocity.x = 0.0
	else:
		is_dropping = false
		drop_ladder = null
		velocity.x = float(direction) * SPEED

	velocity.y += GRAVITY * delta
	move_and_slide()

	sprite.frame = int(anim_timer * 12.0) % 4
	sprite.flip_h = direction > 0

	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		if abs(col.get_normal().x) > 0.8:
			direction *= -1
			break

	if is_dropping and is_on_floor():
		is_dropping = false
		drop_ladder = null

	if not is_dropping and is_on_floor() and game_ref != null and game_ref.has_method("get_barrel_drop_ladder"):
		var next_ladder = game_ref.call("get_barrel_drop_ladder", global_position, direction)
		if next_ladder != null and randf() < 0.42:
			drop_ladder = next_ladder
			is_dropping = true

	if global_position.y > 760.0 or global_position.x < -50.0 or global_position.x > 1200.0:
		queue_free()
